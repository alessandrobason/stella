local argparse = require("argparse")
local inspect = require("inspect")
local new_project
new_project = require("newproject").new_project
local run_project
run_project = require("runproject").run_project
local install_package
install_package = require("installpackage").install_package
local remove_package
remove_package = require("removepackage").remove_package
local parser = argparse()({
  name = "stella"
})
local newcmd = parser:command("new n", "new project")
newcmd:argument("name", "name of the new project"):args("1")
newcmd:action(function(args)
  return new_project(args.name)
end)
local runcmd = parser:command("run r", "run project")
runcmd:argument("args", "optional arguments"):args("*")
runcmd:flag("-v --verbose")
runcmd:action(function(options)
  return run_project(options)
end)
local install = parser:command("install i", "install package")
install:argument("pkgs", "packages to install"):args("1+")
install:flag("-v --verbose")
install:mutex(install:flag("-p --power", "install using luapower"), install:flag("-r --rocks", "install using luarocks"))
install:action(function(opts)
  return install_package(opts)
end)
local remove = parser:command("remove rm", "remove package")
remove:argument("pkgs", "packages to remove"):args("1+")
remove:flag("-v --verbose")
remove:mutex(remove:flag("-p --power", "remove using luapower"), remove:flag("-r --rocks", "remove using luarocks"))
remove:action(function(opts)
  return remove_package(opts)
end)
local args = parser:parse()
