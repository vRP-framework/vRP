// https://github.com/ImagicTheCat/vRP
// MIT license (see LICENSE or vrp/vRPShared.lua)

function RadioDisplay()
{
  this.div = document.createElement("div");
  this.div.classList.add("radio_display");

  this.players = {};

  document.body.appendChild(this.div);
}

RadioDisplay.prototype.setPlayerSpeakingState = function(data)
{
  if(data.state){ // add div
    var pdata = {data: data.data};
    this.players[data.player] = pdata;

    pdata.div = document.createElement("div");
    pdata.div.dataset.group = data.data.group;
    
    var group_div = document.createElement("div");
    group_div.classList.add("group");
    group_div.innerText = data.data.group_title;

    var title_div = document.createElement("div");
    title_div.classList.add("title");
    title_div.innerText = data.data.title;

    pdata.div.appendChild(group_div);
    pdata.div.appendChild(title_div);

    this.div.appendChild(pdata.div);
  }
  else{ // remove div
    var pdata = this.players[data.player];
    if(pdata){
      this.div.removeChild(pdata.div);
      delete this.players[data.player];
    }
  }
}
