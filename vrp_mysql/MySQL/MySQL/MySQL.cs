using CitizenFX.Core;
using CitizenFX.Core.Native;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;

using System.Data;
using MySql.Data.MySqlClient;

namespace vRP
{
  public class MySQL : BaseScript
  {
    public struct Connection{
      public Connection(IDbConnection con)
      {
        connection = (MySqlConnection)con;
        commands = new Dictionary<string, MySqlCommand>();
        mutex = new SemaphoreSlim(1,1);
      }

      public MySqlConnection connection;
      public Dictionary<string, MySqlCommand> commands; 
      public SemaphoreSlim mutex;
    }

    private Dictionary<uint, Task<object>> tasks = new Dictionary<uint, Task<object>>();
    private Dictionary<uint, string> task_paths = new Dictionary<uint, string>();
    private Dictionary<string, Connection> connections = new Dictionary<string, Connection>();
    private uint task_id;
    private uint tick;

    public MySQL()
    {
      Console.WriteLine("[vRP/C#] Load MySQL app.");
      task_id = 0;
      Exports.Add("createConnection", new Action<string,string>(e_createConnection));
      Exports.Add("createCommand", new Action<string,string>(e_createCommand));
      Exports.Add("query", new Action<string,IDictionary<string,object>, int>(e_query));
      EventHandlers["vRP:MySQL_query"] += new Action<string,IDictionary<string,object>, int>(e_query);
      EventHandlers["vRP:MySQL_tick"] += new Action(e_tick);
      //Exports.Add("checkTask", new Func<int,object>(e_checkTask));
    }

    public void e_tick()
    {
      try{
      Dictionary<uint, object> rmtasks = new Dictionary<uint, object>();

      //check each task
      foreach(var pair in tasks){
        var task = pair.Value;
        var path = "unknown";
        task_paths.TryGetValue(pair.Key, out path);

        //completed
        if(task.IsCompleted){
          Dictionary<string,object> dict = new Dictionary<string,object>();

          if(!task.IsFaulted){ //ok
            Dictionary<string, object> r = (Dictionary<string,object>)task.Result;

            if(r != null){
              dict["status"] = 1;
              foreach(var rpair in r)
                dict[rpair.Key] = rpair.Value;
            }
            else
              dict["status"] = -1;
          }
          else{ //faulted
            dict["status"] = -1;
            Console.WriteLine("[vRP/C#] query exception "+path+" : "+task.Exception.ToString());
          }

          rmtasks.Add(pair.Key, dict);
        }
        else;
          //Console.WriteLine(pair.Key+" not completed");
      }

      //remove completed tasks
      foreach(var pair in rmtasks){
        tasks.Remove(pair.Key);
        task_paths.Remove(pair.Key);
      }

      //trigger completed tasks
      foreach(var pair in rmtasks){
        TriggerEvent("vRP:MySQL_task", pair.Key, pair.Value);
      }

      }catch(Exception e){ Console.WriteLine(e.ToString()); }
    }

    //return [con,cmd] from "con/cmd"
    public string[] parsePath(string path)
    {
      var args = path.Split('/');
      if(args.Length >= 2)
        return args;
      else
        return new string[]{"none","none"};
    }

    // createConnection("conid", "host=...")
    public void e_createConnection(string name, string config)
    {
      try{
//      Console.WriteLine("[vRP/C#] create connection "+name);
      var connection = new Connection(new MySqlConnection(config));
      connection.connection.Open();
      connections.Add(name, connection);
      }catch(Exception e){ Console.WriteLine(e.ToString()); }
    }

    // createCommand("conid/name", "SELECT...")
    public void e_createCommand(string path, string sql)
    {
      try{
      var concmd = parsePath(path);

      Connection connection;
      if(connections.TryGetValue(concmd[0], out connection)){
        MySqlCommand cmd = (MySqlCommand)connection.connection.CreateCommand();
        cmd.CommandText = sql;
        connection.commands.Add(concmd[1], cmd);
//        Console.WriteLine("[vRP/C#] create command "+path);
      }
      else
        Console.WriteLine("[vRP/C#] connection "+concmd[0]+" not found");
      }catch(Exception e){ Console.WriteLine(e.ToString()); }
    }

    // query("con/cmd", {...})
    public void e_query(string path, IDictionary<string,object> _parameters, int mode)
    {
      IDictionary<string,object> parameters = new Dictionary<string,object>(_parameters);

      try{
      var concmd = parsePath(path);
      var task = -1;

      Connection connection;
      if(connections.TryGetValue(concmd[0], out connection)){
        MySqlCommand command;
        if(connection.commands.TryGetValue(concmd[1], out command)){
          task_paths.Add(task_id, path);
          tasks.Add(task_id, Task.Run(async () => {
            object r = null;
            //await connection.connection.OpenAsync();

            await connection.mutex.WaitAsync();
//            Console.WriteLine("[vRP/C#] do query "+path);

//            Console.WriteLine("[vRP/C#] add params");
            //set parameters
            foreach(var param in parameters ?? Enumerable.Empty<KeyValuePair<string, object>>())
              command.Parameters.AddWithValue("@"+param.Key, param.Value);

            Dictionary<string, object> dict = new Dictionary<string,object>();
            dict["mode"] = mode;

            if(mode == 0){ //NonQuery
//              Console.WriteLine("[vRP/C#] try non query");
              int affected = await command.ExecuteNonQueryAsync();
//              Console.WriteLine("[vRP/C#] returns");
              dict["affected"] = affected;

              r = (object)dict;
            }
            else if(mode == 1){ //Scalar
//              Console.WriteLine("[vRP/C#] try scalar");
              object scalar = await command.ExecuteScalarAsync();
//              Console.WriteLine("[vRP/C#] returns");
              dict["scalar"] = scalar;

              r = (object)dict;
            }
            else if(mode == 2){ //Reader
//              Console.WriteLine("[vRP/C#] try reader");
              using (var reader = await command.ExecuteReaderAsync())
              {
                var results = new List<Dictionary<string, object>>();

//                Console.WriteLine("[vRP/C#] in reader");
                while (await reader.ReadAsync())
                {
//                  Console.WriteLine("[vRP/C#] read async");
                  var entry = new Dictionary<string, object>();
                  for (int i = 0; i < reader.FieldCount; i++)
                    entry[reader.GetName(i)] = reader.GetValue(i);

                  results.Add(entry);
                }

//                Console.WriteLine("[vRP/C#] returns");
                dict["rows"] = results;
                dict["affected"] = reader.RecordsAffected;

                r = (object)dict;
              }
            }

//            Console.WriteLine("[vRP/C#] end query "+path);
            connection.mutex.Release();
//            Console.WriteLine("[vRP/C#] released");

            return r;
          }));

          task = (int)task_id++;
        }
        else
          Console.WriteLine("[vRP/C#] connection/command path "+path+" not found");

//        Console.WriteLine("[vRP/C#] query "+path+" id "+task);
      }
      else
        Console.WriteLine("[vRP/C#] connection/command path "+path+" not found");

      TriggerEvent("vRP:MySQL_taskid", task);
      }catch(Exception e){ Console.WriteLine(e.ToString()); }
    }

    /*
    public object e_checkTask(int id)
    {
      Console.WriteLine("[vRP/C#] check task "+id);
      Dictionary<string,object> dict = new Dictionary<string,object>();

      TriggerEvent("vrptestevent", 5);

      Task<object> task = null;
      if(tasks.TryGetValue((uint)id, out task)){
        Console.WriteLine("[vRP/C#] have task "+id);
        if(!task.IsFaulted){
          Console.WriteLine("[vRP/C#] task not faulted "+id);
          if(task.IsCompleted){
            Console.WriteLine("[vRP/C#] send back mysql result to "+id);

            if(task.Result != null){
              Dictionary<string, object> r = (Dictionary<string,object>)task.Result;

              dict["status"] = 1;
              dict["rows"] = r["rows"];
              dict["affected"] = r["affected"];
              tasks.Remove((uint)id);

              return dict;
            }
            else{
              Console.WriteLine("[vRP/C#] task "+id+" null result");
              dict["status"] = -1;
              tasks.Remove((uint)id);
              return dict;
            }
          }
          else{
            dict["status"] = 0;
            return dict;
          }
        }
        else{
          Console.WriteLine("[vRP/C#] task "+id+" faulted: "+task.Exception.ToString());
          tasks.Remove((uint)id);
          dict["status"] = -1;
          return dict;
        }
      }
      else{
        Console.WriteLine("[vRP/C#] task "+id+" missing");
        dict["status"] = -1;
        return dict;
      }

      dict["status"] = -1;
      return dict;
    }
    */
  }
}
