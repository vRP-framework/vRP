// https://github.com/ImagicTheCat/vRP
// MIT license (see LICENSE or vrp/vRPShared.lua)

// dynamic class countdown (duration in seconds)

var updateCountdown = function(el, value)
{
  if(value > 60)
    el.innerText = Math.floor(value/60)+"m"+(value%60)+"s";
  else
    el.innerText = value+"s";
}

defineDynamicClass("countdown", function(el){
  var duration = parseInt(el.dataset.duration);

  updateCountdown(el, duration);

  var interval = setInterval(function(){
    duration--;
    if(duration < 0){
      duration = 0;
      clearInterval(interval);
    }

    updateCountdown(el, duration);
  }, 1000);
});
