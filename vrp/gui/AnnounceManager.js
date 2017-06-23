
function AnnounceManager()
{
  var _this = this;
  setInterval(function(){ _this.tick(); }, 30000);

  this.announces = []
  this.div = document.createElement("div");
  this.div.classList.add("announce");

  document.body.appendChild(this.div);
}

AnnounceManager.prototype.addAnnounce = function(background, content)
{
  var announce = {background: background, content: content}
  this.announces.push(announce);
}

AnnounceManager.prototype.tick = function()
{
  //next announce
  var _this = this;
  var jdiv = $(this.div);
  jdiv.fadeOut(1500,function(){
    setTimeout(function(){
      if(_this.announces.length > 0){
        var announce = _this.announces[0];
        _this.announces.splice(0,1);
        _this.div.style.backgroundImage = "url('"+announce.background+"')";
        _this.div.innerHTML = announce.content;

        jdiv.fadeIn(800,function(){});
      }
    }, 2000);
  });
}

