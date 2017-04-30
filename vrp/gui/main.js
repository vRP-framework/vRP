
window.addEventListener("load",function(){
  errdiv = document.createElement("div");
  if(true){ //debug
    errdiv.classList.add("console");
    document.body.appendChild(errdiv);
    window.onerror = function(errorMsg, url, lineNumber, column, errorObj){
        errdiv.innerHTML += '<br />Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber
                + ' Column: ' + column + ' StackTrace: ' +  errorObj;
    }
  }

  //init dynamic menu
  var dynamic_menu = new Menu();
  dynamic_menu.onClose = function(){ $.post("http://vrp/menu",JSON.stringify({act: "close", id: dynamic_menu.id})); }
  dynamic_menu.onValid = function(choice){ $.post("http://vrp/menu",JSON.stringify({act: "valid", id: dynamic_menu.id, choice: choice})); }

  var current_menu = dynamic_menu;
  var pbars = {}

  //progress bar ticks (25fps)
  setInterval(function(){
    for(var k in pbars){
      pbars[k].frame(1/25.0*1000);
    }

  }, 1/25.0*1000);

  //MESSAGES
  window.addEventListener("message",function(evt){ //lua actions
    var data = evt.data;

    if(data.act == "open_menu"){ //OPEN DYNAMIC MENU
      current_menu.close();
      dynamic_menu.open(data.menudata.name,data.menudata.choices);
      dynamic_menu.id = data.menudata.id;

      //customize menu
      var css = data.menudata.css
      if(css.top)
        dynamic_menu.div.style.top = css.top;
      if(css.header_color)
        dynamic_menu.div_header.style.backgroundColor = css.header_color;

      current_menu = dynamic_menu;
    }
    else if(data.act == "close_menu"){ //CLOSE MENU
      current_menu.close();
    }
    else if(data.act == "set_pbar"){
      var pbar = pbars[data.pbar.name];
      if(pbar)
        pbar.removeDom();

      pbars[data.pbar.name] = new ProgressBar(data.pbar);
      pbars[data.pbar.name].addDom();
    }
    else if(data.act == "set_pbar_val"){
      var pbar = pbars[data.name];
      if(pbar)
        pbar.setValue(data.value);
    }
    else if(data.act == "set_pbar_text"){
      var pbar = pbars[data.name];
      if(pbar)
        pbar.setText(data.text);
    }
    else if(data.act == "remove_pbar"){
      var pbar = pbars[data.name]
      if(pbar){
        pbar.removeDom();
        delete pbars[data.name];
      }
    }
    else if(data.act == "event"){ //EVENTS
      if(data.event == "UP"){
        current_menu.moveUp();
      }
      else if(data.event == "DOWN"){
        current_menu.moveDown();
      }
      else if(data.event == "LEFT"){
      }
      else if(data.event == "RIGHT"){
      }
      else if(data.event == "SELECT"){
        current_menu.valid();
      }
      else if(data.event == "CANCEL"){
        current_menu.close();
      }
    }
  });
});
