local https = require("ssl.https")
local lfs = require("lfs")
local fileexists
fileexists = require("moonfile").fileexists
local logmsg = print
local logwrite = io.write
local from_lpower
from_lpower = function(pkg)
  local res, status = https.request("https://luapower.com/" .. tostring(pkg) .. "/download")
  if status ~= 200 then
    return false, "the request failed: status " .. tostring(status)
  end
  local command = res:match("./mgit.*")
  command = command:sub(1, command:find("\n") - 1)
  local _, endcmd = command:find("./mgit clone " .. tostring(pkg))
  local installing = command:sub(endcmd + 2, #command)
  installing = "installing " .. tostring(installing) .. " ~~~~~~~~~~~~~~~~~"
  logmsg(command)
  logmsg(installing)
  for i = 1, #installing do
    logwrite("~")
  end
  logmsg()
  local f = io.popen("cd lua_modules/luapower ; " .. tostring(command))
  for l in f:lines() do
    logmsg(l)
  end
  f:close()
  for i = 1, #installing do
    logwrite("~")
  end
  logmsg()
  return true, nil
end
local from_lrocks
from_lrocks = function(pkg)
  local f, err = io.popen("luarocks install " .. tostring(pkg) .. " --tree lua_modules/luarocks")
  if err then
    return false, err
  end
  for l in f:lines() do
    logmsg(l)
  end
  f:close()
  return true, err
end
local install_package
install_package = function(opts)
  if not (opts.verbose) then
    logmsg = function() end
    logwrite = function() end
  end
  local pkgs = opts.pkgs or nil
  if not (pkgs) then
    print("no packages given")
    return 
  end
  local installer
  if opts.power then
    installer = from_lpower
  elseif opts.rocks then
    installer = from_lrocks
  else
    print("no package manager given")
    installer = os.exit(1)
  end
  if not (fileexists("lua_modules/luapower/mgit")) then
    print("initializing luapower folder")
    os.execute([[            cd lua_modules;
            git clone https://github.com/capr/multigit luapower
            cd luapower
            ./mgit clone https://github.com/luapower/luapower-repos
        ]])
  end
  for _, v in pairs(pkgs) do
    print("> installing " .. tostring(v))
    local success, err = installer(v)
    if err then
      print(err)
    end
  end
end
return {
  install_package = install_package
}
