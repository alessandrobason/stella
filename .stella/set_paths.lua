local version = _VERSION:match("%d+%.%d+")
local __rocks = "lua_modules/luarocks"
local __power = "lua_modules/luapower"
package.path = __rocks.."/share/lua/"..version.."/?.lua;"..__rocks.."/share/lua/"..version.."/?/init.lua;"..__power.."/?.lua;"..package.path
package.cpath = __rocks.."/lib/lua/"..version.."/?.so;"..__power.."/?.so;"..package.cpath