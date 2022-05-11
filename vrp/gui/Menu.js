// https://github.com/ImagicTheCat/vRP
// MIT license (see LICENSE or vrp/vRPShared.lua)

//events
// .onValid(option_index)

function Menu()
{
  this.title = "Menu";
  this.options = [];
  this.opened = false;
  this.selected = -1;
  this.el_options = [];

  this.div_desc = document.createElement("div");
  this.div_desc.classList.add("menu_description");

  this.div = document.createElement("div");
  this.div.classList.add("menu");

  this.div_header = document.createElement("h1");
  this.div_options = document.createElement("div");
  this.div_options.classList.add("options");

  this.div.appendChild(this.div_header);
  this.div.appendChild(this.div_options);

  document.body.appendChild(this.div);
  document.body.appendChild(this.div_desc);
  this.div.style.display = "none";
  this.div_desc.style.display = "none";
}

Menu.prototype.open = function(data) 
{
  this.close();
  this.opened = true;

  this.div.style.display = "block";

  this.title = data.title;
  this.options = data.options;

  this.div_options.innerHTML = "";
  this.el_options = [];
  for(var i = 0; i < this.options.length; i++){
    var el = document.createElement("div");
    el.innerHTML = this.options[i][0];

    this.el_options.push(el);
    this.div_options.appendChild(el);
  }

  //customize menu
  if(data.css.header_color)
    this.div_header.style.backgroundColor = data.css.header_color;

  //build dom
  this.div_header.innerHTML = this.title;

  this.div_options.style.height = (this.div.offsetHeight-this.div_options.offsetTop)+"px";

  this.setSelected(0);
}

Menu.prototype.updateOption = function(i, title, description)
{
  if(i >= 0 && i < this.options.length){
    var option = this.options[i];

    if(title){
      option[0] = title;
      this.el_options[i].innerHTML = title;
    }

    if(description){
      if(option.length > 1)
        option[1] = description;
      else
        option.push(description);

      if(this.selected == i){
        this.div_desc.innerHTML = option[1];

        this.div_desc.style.display = "block";
        this.div_desc.style.left = (this.div.offsetLeft+this.div.offsetWidth)+"px";
        this.div_desc.style.top = (this.div.offsetTop+this.div_header.offsetHeight)+"px";
      }
    }
  }
}

Menu.prototype.setSelected = function(i)
{
  //check validity
  if(this.selected >= 0 && this.selected < this.el_options.length){
    //remove previous selected class
    this.el_options[this.selected].classList.remove("selected");
    //hide desc
    this.div_desc.style.display = "none";
  }

  var prev_selected = this.selected;

  this.selected = i;
  if(this.selected < 0)
    this.selected = this.options.length-1;
  else if(this.selected >= this.options.length)
    this.selected = 0;

  //trigger select event
  if(this.selected != prev_selected){
    if(this.onSelect)
      this.onSelect(this.selected);
  }

  //check validity
  if(this.selected >= 0 && this.selected < this.el_options.length){
    //add selected class
    this.el_options[this.selected].classList.add("selected");

    //scroll to selected
    var scrollto = $(this.el_options[this.selected])
    var container = $(this.div_options)
    if(scrollto.offset().top < container.offset().top || scrollto.offset().top + scrollto.height() >= container.offset().top+container.height())
      container.scrollTop(scrollto.offset().top - container.offset().top + container.scrollTop());

    //show desc if exists
    var option = this.options[this.selected];
    if(option.length > 1){
      this.div_desc.innerHTML = option[1];
      this.div_desc.style.display = "block";

      this.div_desc.style.left = (this.div.offsetLeft+this.div.offsetWidth)+"px";
      this.div_desc.style.top = (this.div.offsetTop+this.div_header.offsetHeight)+"px";
    }
  }
}

Menu.prototype.close = function()
{
  if(this.opened){
    this.selected = -1;
    this.opened = false;
    this.options = [];
    this.title = "Menu";

    this.div.style.display = "none";
    this.div_desc.style.display = "none";
  }
}

Menu.prototype.moveUp = function()
{
  if(this.opened)
    this.setSelected(this.selected-1);
}

Menu.prototype.moveDown = function()
{
  if(this.opened)
    this.setSelected(this.selected+1);
}

Menu.prototype.valid = function(mod)
{
  if(this.selected >= 0 && this.selected < this.options.length){
    if(this.onValid && this.opened)
      this.onValid(this.selected, mod)
  }
}
