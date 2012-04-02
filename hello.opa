import stdlib.themes.bootstrap
import stdlib.web.client
import stdlib.widgets.{loginbox,tabs}

type state = {new} or {edit}
type userState = {string logged} or {unlogged}

function page(title, content) {
  body = <body>
    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <a href="/" class="brand">My Application</>
          <ul class="nav pull-right">
            <li>{User.loginForm()}</>
          </>
        </>
      </>
    </>
    <div class="container">
    {content}
    </>
  </>

  Resource.page(title, body)
}

function list(){    
    content = <>
    {toolbar()}
    {table()}
    </>
    page("List", content)
}

function add(){
  page("Add", form({new}))
}

function toolbar(){
  <div class="subnav">
    <ul class="nav nav-pills">
        <li><a href="/add" class="btn">Add new</></>        
    </>    
  </>
}

function form(state) {  
  <form id=form class="well" onready={function(_){Dom.give_focus(#name)}}>
    <input type="hidden" id=id />
    {renderInput("name", "Name")}
    {renderInput("age", "Age")}
    <a href="#" class="btn" onclick={function(_){save(state)}}>Save</> 
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
  <table class="table table-stripped table-bordered" onready={function(_){loadData()}} >
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
    renderItem(p)
    void
  }, it)
}

function edit(id) {
  p = /people/all[{~id}]
  if (p.id != 0) {
    content = <div onready={function(_){ editPerson(p) }}>
    {form({edit})}
    </>
    page("Edit {p.name}", content)
  } else {
    list()
  }
}

function removePerson(person p) {
  Db.remove(@/people/all[{id:p.id}])
  Client.goto("/")
}

function editPerson(person p) {
  Dom.set_value(#name, p.name)
  Dom.set_value(#age, intToString(p.age))
  Dom.set_value(#id, intToString(p.id))
}

function renderItem(person p) {
  editButton = <a class="btn btn-info" href="/edit/{p.id}">Edit</>
  removeButton = <button onclick={function(_){removePerson(p)}} class="btn btn-danger" href="#">Remove</>
  row = <tr id={p.id}>
  <td>{p.id}</><td>{p.name}</><td>{p.age}</><td>{editButton} {removeButton}</>
  </>  

  #items =+ row
}

function save(state){
  match(state){
  case {new}: /people/last_id = /people/last_id + 1
  case {edit}: void    
  }
  

  name = Dom.get_value(#name)
  raw_age = Dom.get_value(#age)
  raw_id = Dom.get_value(#id)
  opt_age = Parser.try_parse(Rule.integer, raw_age)
  age = Option.default(10, opt_age)

  opt_id = Parser.try_parse(Rule.integer, raw_id)
  id = Option.default(/people/last_id, opt_id)

  person p = {age:age, name:name, id: id}
  Log.info("Person being saved", "{p}")
  /people/all[{~id}] <- p

  Client.goto("/");
}

module User{
    private state = UserContext.make((userState) { unlogged })

    function login(name, pass) {
      if (name == "lucas" && pass == "123") {
        UserContext.change(function(_){{logged : "Lucas Souza"}}, state)
        Client.goto("/")
      }
    }

    function logout() {
      UserContext.change(function(_){{unlogged}}, state)
      Client.goto("/")
    }

    function getStatus() {
        UserContext.execute((function(a){a}), state)
    }

    function isLogged() {
      match(getStatus()){
        case {logged : _}: true        
        case {unlogged} : false        
      }
      
    }

    /** loginForm */
    function loginForm(){
      if (isLogged() == true) {
        name = match(getStatus()){
        case {~logged}:logged
        case _ : "User"          
        }
        <ul class=nav>
        <li><a href="#" class="active">Welcome {name}</></>
        <li><a onclick={function(_){logout()}}>Logout</></>
        </>
      } else {
        WLoginbox.html_default(Dom.fresh_id(), login, {none});
      }
    }
    

}



urls  = parser {
case "/add" : add()
case "/edit/" id = Rule.integer  : edit(id)
case .* : list()
}

Server.start(Server.http, [{custom : urls}])