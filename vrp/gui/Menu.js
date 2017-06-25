
//events
// .onValid(choice)
// .onClose()

function Menu()
{
  this.name = "Menu";
  this.choices = [];
  this.opened = false;
  this.selected = -1;
  this.el_choices = [];

  this.div_desc = document.createElement("div");
  this.div_desc.classList.add("menu_description");

  this.div = document.createElement("div");
  this.div.classList.add("menu");

  this.div_header = document.createElement("h1");
  this.div_choices = document.createElement("div");
  this.div_choices.classList.add("choices");

  this.div.appendChild(this.div_header);
  this.div.appendChild(this.div_choices);

  document.body.appendChild(this.div);
  document.body.appendChild(this.div_desc);
  this.div.style.display = "none";
  this.div_desc.style.display = "none";
}

Menu.prototype.open = function(name,choices) //menu name and choices as [name,desc] array
{
  this.close();
  this.opened = true;

  this.div.style.display = "block";

  this.name = name;
  this.choices = choices;

  this.div_choices.innerHTML = "";
  this.el_choices = [];
  for(var i = 0; i < this.choices.length; i++){
    var el = document.createElement("div");
    el.innerHTML = this.choices[i][0];

    this.el_choices.push(el);
    this.div_choices.appendChild(el);
  }

  //build dom
  this.div_header.innerHTML = name;

  this.div_choices.style.height = (this.div.offsetHeight-this.div_choices.offsetTop)+"px";

  this.setSelected(0);
}

Menu.prototype.setSelected = function(i)
{
  //check validity
  if(this.selected >= 0 && this.selected < this.el_choices.length){
    //remove previous selected class
    this.el_choices[this.selected].classList.remove("selected");
    //hide desc
    this.div_desc.style.display = "none";
  }

  this.selected = i;
  if(this.selected < 0)
    this.selected = this.choices.length-1;
  else if(this.selected >= this.choices.length)
    this.selected = 0;

  //check validity
  if(this.selected >= 0 && this.selected < this.el_choices.length){
    //add selected class
    this.el_choices[this.selected].classList.add("selected");

    //scroll to selected
    var scrollto = $(this.el_choices[this.selected])
    var container = $(this.div_choices)
    if(scrollto.offset().top < container.offset().top || scrollto.offset().top + scrollto.height() >= container.offset().top+container.height())
      container.scrollTop(scrollto.offset().top - container.offset().top + container.scrollTop());

    //show desc if exists
    var choice = this.choices[this.selected];
    if(choice.length > 1){
      this.div_desc.innerHTML = choice[1];
      this.div_desc.style.display = "block";

      this.div_desc.style.left = (this.div.offsetLeft+this.div.offsetWidth)+"px";
      this.div_desc.style.top = (this.div.offsetTop+this.div_header.offsetHeight)+"px";
    }
  }
}

Menu.prototype.close = function()
{
  if(this.opened){
    this.opened = false;
    this.choices = [];
    this.name = "Menu";

    this.div.style.display = "none";
    this.div_desc.style.display = "none";

    if(this.onClose) this.onClose();
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
  if(this.selected >= 0 && this.selected < this.choices.length){
    if(this.onValid && this.opened)
      this.onValid(this.choices[this.selected][0], mod)
  }
}
