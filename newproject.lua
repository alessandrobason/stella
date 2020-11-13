local lfs = require("lfs")
local new_project
new_project = function(pname)
  lfs.mkdir(tostring(pname))
  lfs.mkdir(tostring(pname) .. "/lua_modules")
  lfs.mkdir(tostring(pname) .. "/.stella")
  local main = io.open(tostring(pname) .. "/" .. tostring(pname) .. ".lua", "w")
  main:write("print(\"hello world!\")")
  main:close()
  local paths = io.open(tostring(pname) .. "/.stella/set_paths.lua", "w")
  paths:write([[local version = _VERSION:match("%d+%.%d+")
local __rocks = "lua_modules/luarocks"
local __power = "lua_modules/luapower"
package.path = __rocks.."/share/lua/"..version.."/?.lua;"..__rocks.."/share/lua/"..version.."/?/init.lua;"..__power.."/?.lua;"..package.path
package.cpath = __rocks.."/lib/lua/"..version.."/?.so;"..__power.."/?.so;"..package.cpath]])
  paths:close()
  local settings = io.open(tostring(pname) .. "/.stella/settings.lua", "w")
  settings:write([[return {
    lang = "lua",
    main = "]] .. pname .. [[.lua",
    mode = "commandline"
}]])
  settings:close()
  local package = io.open(tostring(pname) .. "/package.stella", "w")
  package:write([[return {
    name = "]] .. pname .. [[",
    description = "",
    version = "1.0.0",
    scripts = {},
    repository = {
        -- example:
        -- type = "git"
        -- url = "https://etc"
    },
    author = "",
    dependencies = {
        -- examples
        -- "libname" = "1.0.0"   exact version
        -- "libname" = ">=1.0.0" at least 1.0.0
        -- "libname" = ">1.0.0"  more than 1.0.0
        -- "libname" = "*"       any version
    }
}]])
  return package:close()
end
return {
  new_project = new_project
}
