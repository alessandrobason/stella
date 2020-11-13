local lfs = require("lfs")
local parse = require("moonscript.parse")
local compile = require("moonscript.compile")
local logmsg = print
local fileexists
fileexists = function(fname)
  local f, err = io.open(fname)
  if f then
    f:close()
    return true, nil
  else
    return false, err
  end
end
local moontolua
moontolua = function(fname)
  if fname:match("%.moon$") == ".moon" then
    return fname:sub(1, -5) .. "lua"
  else
    return fname .. ".lua"
  end
end
local compilefile
compilefile = function(fname)
  local f, err = io.open(fname, "r")
  if err then
    return nil, err
  end
  local text = f:read("*a")
  f:close()
  local tree
  tree, err = parse.string(text)
  if err then
    return nil, "PARSER ERROR\n" .. tostring(err)
  end
  local code, posmap_or_err, err_pos = compile.tree(tree)
  if err then
    return nil, "COMPILE ERROR\n" .. tostring(err)
  end
  local luafile = moontolua(fname)
  local fw
  fw, err = io.open(luafile, "w")
  if err then
    return nil, err
  end
  fw:write(tostring(code) .. "\n")
  fw:close()
  return luafile
end
local is_file_newer
is_file_newer = function(f1, f2)
  return (lfs.attributes(f1, "modification") - lfs.attributes(f2, "modification")) > 0
end
local has_changed
has_changed = function(mfile)
  local lfile = mfile:sub(1, #mfile - 5) .. ".lua"
  local f = io.open(lfile)
  if f then
    f:close()
    return is_file_newer(mfile, lfile)
  else
    return true
  end
end
local normalize_directory
normalize_directory = function(dir)
  if dir:sub(#dir, #dir) ~= "/" then
    return tostring(dir) .. "/"
  else
    return dir
  end
end
local scanfolder
scanfolder = function(root, collected)
  root = normalize_directory(root)
  collected = collected or { }
  for fname in lfs.dir(root) do
    if fname ~= "." and fname ~= ".." then
      local full_path = root .. fname
      if lfs.attributes(full_path, "mode") == "directory" then
        scanfolder(full_path, collected)
      elseif fname:sub(#fname - 4, #fname) == ".moon" then
        if not collected[full_path] then
          logmsg("added " .. tostring(fname))
          collected[full_path] = 0
        end
      end
    end
  end
  return collected
end
local compilefolder
compilefolder = function(dir, verbose)
  dir = dir or "."
  if not verbose then
    logmsg = function() end
  end
  local files = scanfolder(dir)
  local successfull = true
  for f in pairs(files) do
    if has_changed(f) then
      logmsg("compiling " .. tostring(f))
      local lfile, err = compilefile(f)
      if lfile then
        logmsg("compiled successfully to " .. tostring(lfile))
      else
        logmsg("compilation failed: " .. tostring(err))
        successfull = false
      end
    end
  end
  return successfull
end
return {
  fileexists = fileexists,
  compilefile = compilefile,
  compilefolder = compilefolder,
  moontolua = moontolua
}
