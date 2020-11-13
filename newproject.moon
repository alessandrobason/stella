lfs = require "lfs"

new_project = (pname) ->
    lfs.mkdir("#{pname}")
    lfs.mkdir("#{pname}/lua_modules")
    lfs.mkdir("#{pname}/.stella")

    main = io.open "#{pname}/#{pname}.lua", "w"
    main\write "print(\"hello world!\")"
    main\close!

    paths = io.open "#{pname}/.stella/set_paths.lua", "w"
    paths\write [[
local version = _VERSION:match("%d+%.%d+")
local __rocks = "lua_modules/luarocks"
local __power = "lua_modules/luapower"
package.path = __rocks.."/share/lua/"..version.."/?.lua;"..__rocks.."/share/lua/"..version.."/?/init.lua;"..__power.."/?.lua;"..package.path
package.cpath = __rocks.."/lib/lua/"..version.."/?.so;"..__power.."/?.so;"..package.cpath]]
    paths\close!

    settings = io.open "#{pname}/.stella/settings.lua", "w"
    settings\write [[
return {
    lang = "lua",
    main = "]] .. pname .. [[.lua",
    mode = "commandline"
}]]
    settings\close!

    package = io.open "#{pname}/package.stella", "w"
    package\write [[
return {
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
}]]
    package\close!

return {
    :new_project
}