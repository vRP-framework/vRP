
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

  this.div = document.createElement("div");
  this.div.classList.add("menu");

  this.div_header = document.createElement("h1");
  this.div_choices = document.createElement("div");
  this.div_choices.classList.add("choices");

  this.div.appendChild(this.div_header);
  this.div.appendChild(this.div_choices);

  document.body.appendChild(this.div);
  this.div.style.display = "none";
}

Menu.prototype.open = function(name,choices) //menu name and choices as string array
{
  this.close();
  this.opened = true;

  this.div.style.display = "block";

  this.name = name;
  this.choices = choices;
  this.selected = -1;
  if(this.choices.length > 0)
    this.selected = 0;

  this.div_choices.innerHTML = "";
  this.el_choices = [];
  for(var i = 0; i < this.choices.length; i++){
    var el = document.createElement("div");
    el.innerHTML = this.choices[i];

    this.el_choices.push(el);
    this.div_choices.appendChild(el);
  }

  //build dom
  this.div_header.innerHTML = name;
}

Menu.prototype.setSelected = function(i)
{
  //remove previous selected class
  if(this.selected >= 0 && this.selected < this.el_choices.length)
    this.el_choices[this.selected].classList.remove("selected");


  this.selected = i;
  if(this.selected < 0)
    this.selected = this.choices.length-1;
  else if(this.selected >= this.choices.length)
    this.selected = 0;

  //add selected class
  if(this.selected >= 0 && this.selected < this.el_choices.length)
    this.el_choices[this.selected].classList.add("selected");
}

Menu.prototype.close = function()
{
  if(this.opened){
    this.opened = false;
    this.choices = [];
    this.name = "Menu";

    this.div.style.display = "none";

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

Menu.prototype.valid = function()
{
  if(this.selected >= 0 && this.selected < this.choices.length){
    if(this.onValid && this.opened)
      this.onValid(this.choices[this.selected])
  }
}
