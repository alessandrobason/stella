argparse = require "argparse"
inspect = require "inspect"
import new_project from require "newproject"
import run_project from require "runproject"
import install_package from require "installpackage"
import remove_package from require "removepackage"

parser = argparse! name: "stella"

newcmd = parser\command("new n", "new project")
newcmd\argument("name", "name of the new project")\args("1")
newcmd\action (args) -> 
	new_project args.name

runcmd = parser\command "run r", "run project"
runcmd\argument("args", "optional arguments")\args("*")
runcmd\flag("-v --verbose")
runcmd\action (options) ->
	run_project options

install = parser\command "install i", "install package"
install\argument("pkgs", "packages to install")\args("1+")
install\flag("-v --verbose")
install\mutex(
   install\flag("-p --power", "install using luapower"),
   install\flag("-r --rocks", "install using luarocks")
)
install\action (opts) ->
	install_package opts

remove = parser\command "remove rm", "remove package"
remove\argument("pkgs", "packages to remove")\args("1+")
remove\flag("-v --verbose")
remove\mutex(
   remove\flag("-p --power", "remove using luapower"),
   remove\flag("-r --rocks", "remove using luarocks")
)
remove\action (opts) ->
	remove_package opts

args = parser\parse()