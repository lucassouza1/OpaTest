import stdlib.themes.bootstrap

type state = {new} or {edit}

function init(){
    <body onready={function(_){loadData();hideForm()}}>
    <div class="navbar"><div class="navbar-inner"><div class="container"><span class="brand">My Application</></></></>
    <div class="container">
    {toolbar()}
    {form()}
    {table()}
    </>
    </>
}

function toolbar(){
  <div class="subnav">
    <ul class="nav nav-pills">
        <li><a href="#" class="btn" onclick={function(_){new()}}>New</></>
        <li><a href="#" type="button" class="btn" onclick={function(_){save()}}>Save</></>
    </>
  </>
}

function form() {
  <form id=form class="well">
    <input type="hidden" id=id />
    {renderInput("name", "Name")}
    {renderInput("age", "Age")}
  </>
}

function renderInput(id, label){
  <div class="clearfix">
    <label>{label}</label>
    <div class="input">
        <input id={id} type="text" />
    </div>
  </div>
}

function table() {
  <table class="table table-stripped table-bordered">
    <thread>
      <tr>
        <th>Id</>
        <th>Name</>
        <th>Age</>
        <th>Actions</>
      </>
    </>
    <tbody id=#items>        
    </>
  </>
}

type person = {int id, int age, string name};

database people {
  person /all[{id}]
  int /last_id = 1
}

function loadData(){
  l = /people/all
  it = DbSet.iterator(l)
  Iter.iter(function(person p) {
    renderItem(p, {new})
    void
  }, it)
}

function showForm() {
  Dom.show(#form)
}

function hideForm() {
  Dom.hide(#form)
}

function new() {
  clearForm()
  showForm()
  Dom.set_value(#state, "I")
  Dom.give_focus(#name)
}

function removePerson(person p) {
  Db.remove(@/people/all[{id:p.id}])
  removeItem(p)
}

function editPerson(person p) {
  showForm()
  Dom.set_value(#name, p.name)
  Dom.set_value(#age, intToString(p.age))
  Dom.set_value(#id, intToString(p.id))
}

function renderItem(person p, state s) {
  match(s){
    case {edit}: updateRenderedItem(p)
    case {new} : addRenderedItem(p)
  }

  void
}

function updateRenderedItem(person p) {
  editButton = <button onclick={function(_){editPerson(p)}} class="btn btn-info" href="#">Edit</>
  removeButton = <button onclick={function(_){removePerson(p)}} class="btn btn-danger" href="#">Remove</>
  tr =  <td>{p.id}</><td>{p.name}</><td>{p.age}</><td>{editButton} {removeButton}</>
  #{intToString(p.id)} = tr
}

function addRenderedItem(person p) {
  editButton = <button onclick={function(_){editPerson(p)}} class="btn btn-info" href="#">Edit</>
  removeButton = <button onclick={function(_){removePerson(p)}} class="btn btn-danger" href="#">Remove</>
  row = <tr id={p.id}>
  <td>{p.id}</><td>{p.name}</><td>{p.age}</><td>{editButton} {removeButton}</>
  </>  

  #items =+ row
}

function removeItem(person p)
{
  Dom.remove(#{intToString(p.id)})
}

type t_id_and_state = {int, state}

function save(){
  name = Dom.get_value(#name)
  raw_age = Dom.get_value(#age)
  raw_id = Dom.get_value(#id)
  option(int) opt_age = Parser.try_parse(Rule.integer, raw_age)
  age = Option.default(10, opt_age)

  id_and_state = match(Parser.try_parse(Rule.integer, raw_id)){
    case {some:i}: {id : i, state : {edit}}
    case _ : {
      i = /people/last_id
      /people/last_id = i + 1
      {id : i, state : {new}}
    }
    
  }  

  id = id_and_state.id
  person p = {age:age, name:name, id: id}
  /people/all[{id: id}] <- p

  renderItem(p, id_and_state.state)
  clearForm()
  hideForm()
}

function clearForm()
{
  Dom.clear_value(#name)
  Dom.clear_value(#age)
  Dom.clear_value(#id)
}

Server.start(
	Server.http, // default configuration for a http server, default port is 8080
	// Below is the Server.handler that will handle your requests,
	// Select Server.start and do [ctrl+d] to obtain the doc
	[
		// embbed resources in resources directory
		// {resources:@static_resource_directory("resources") },
		// other js and css resources
	 	// [],
	 	// the standard dispatcher for urls
	 	// {dispatcher:},

	 	// a simple page response for all page request, mostly for tutorials and beginners:)
	 	{title:"My Application", page:init}
	]
)
