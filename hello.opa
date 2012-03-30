import stdlib.themes.bootstrap

/** myFunction */
function myFunction(){
    <body onready={function(_){loadData()}}>
    <div class="navbar"><div class="navbar-inner"><div class="container"><span class="brand">My Application</></></></>
    <span>Name</span> <input id="name"/>
    <span>Age</span> <input id="age"/>
    <input type="button" value="Save" onclick={function(_){save()}}/>
    <ul id=#items></>
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
  Iter.iter(renderItem, it)
}

function removePerson(person p) {
  Db.remove(@/people/all[{id:p.id}])
  removeItem(p)
}

function renderItem(person p) {
  #items =+ <li id={p.id}>{p.id}:{p.name} - {p.age} <span onclick={function(_){removePerson(p)}}>x</></li>
}

function removeItem(person p)
{
  Dom.remove(#{intToString(p.id)})
}

function save(){
  name = Dom.get_value(#name)
  raw_age = Dom.get_value(#age)
  option(int) opt_age = Parser.try_parse(Rule.integer, raw_age)

  age = Option.default(10, opt_age)  
  id = /people/last_id
  /people/last_id = id + 1

  person p = {age:age, name:name, id: id}
  /people/all[{id: id}] <- p

  renderItem(p)
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
	 	{title:"mypage", page:myFunction}
	]
)
