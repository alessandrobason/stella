local moonfile = require("moonfile")
local compilefolder, moontolua
compilefolder, moontolua = moonfile.compilefolder, moonfile.moontolua
local logmsg = print
local run_project
run_project = function(options)
  assert(options)
  if not options.verbose then
    logmsg = function() end
  end
  local args = options.args or { }
  local args_str = ""
  for _, v in pairs(args) do
    args_str = args_str .. tostring(v) .. " "
  end
  local settings = dofile(".stella/settings.lua")
  local main = settings.main
  local lang = settings.lang
  local _exp_0 = settings.lang
  if "moon" == _exp_0 then
    lang = "lua"
  elseif "moonjit" == _exp_0 then
    lang = "luajit"
  end
  local _exp_1 = settings.mode
  if "other" == _exp_1 then
    return print("TODO")
  elseif "commandline" == _exp_1 then
    local luafile = settings.main
    if settings.lang == "moon" or settings.lang == "moonjit" then
      local success = compilefolder(".", options.verbose)
      if not success then
        return 
      end
      luafile = moontolua(settings.main)
    end
    local command = tostring(lang) .. " -e 'dofile(\".stella/set_paths.lua\")' " .. tostring(luafile) .. " " .. tostring(args_str)
    logmsg("> " .. tostring(command))
    print("running file +-+-+-+-+-+-+-+-")
    local f = io.popen(command)
    for line in f:lines() do
      print(line)
    end
    print("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+")
    return f:close()
  end
end
return {
  run_project = run_project
}
