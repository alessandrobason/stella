local logmsg = print
local from_lpower
from_lpower = function(pkg)
  local f, err = io.popen([[        cd lua_modules/luapower
        echo "yes" | ./mgit remove ]] .. pkg)
  if err then
    return nil, err
  end
  local output = f:read("*a")
  if output:match("ERROR:") then
    io.write(output)
  else
    logmsg(output)
  end
  return f:close()
end
local from_lrocks
from_lrocks = function(pkg) end
local remove_package
remove_package = function(opts)
  if not (opts.verbose) then
    logmsg = function() end
  end
  local pkgs = opts.pkgs or nil
  if not (pkgs) then
    print("no packages given")
    return 
  end
  local remover
  if opts.power then
    remover = from_lpower
  elseif opts.rocks then
    remover = from_lrocks
  else
    print("no package manager given")
    remover = os.exit(1)
  end
  for _, v in pairs(pkgs) do
    print("> removing " .. tostring(v))
    local success, err = remover(v)
    if err then
      print(err)
    end
  end
end
return {
  remove_package = remove_package
}
