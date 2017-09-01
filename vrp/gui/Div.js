
function Div(data)
{
  this.div = document.createElement("div");
  this.div.classList.add("div_"+data.name);

  this.style = document.createElement("style");
  this.style_css = document.createTextNode("");
  this.style.appendChild(this.style_css);

  this.setCss(data.css);
  this.setContent(data.content);
}

Div.prototype.setCss = function(css)
{
  this.style_css.nodeValue = css;
}

Div.prototype.setContent = function(content)
{
  this.div.innerHTML = content;
}

Div.prototype.executeJS = function(js)
{
  (new Function("",js)).apply(this.div, []);
}

Div.prototype.addDom = function()
{
  document.body.appendChild(this.div);
  document.head.appendChild(this.style);
}

Div.prototype.removeDom = function()
{
  document.body.removeChild(this.div);
  document.head.removeChild(this.style);
}
