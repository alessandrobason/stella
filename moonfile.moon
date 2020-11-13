lfs = require "lfs"
parse = require("moonscript.parse")
compile = require("moonscript.compile")

logmsg = print

fileexists = (fname) ->
    f, err = io.open fname
    if f
        f\close!
        true, nil
    else
        false, err

-- convert .moon filenames to .lua, or make it .lua.lua (same behaviour as moonc)
moontolua = (fname) ->
    if fname\match("%.moon$") == ".moon" 
        fname\sub(1, -5) .. "lua" 
    else 
        fname .. ".lua"

compilefile = (fname) ->
    f, err = io.open fname, "r"
    if err then return nil, err
    text = f\read("*a")
    f\close!
    
    tree, err = parse.string text
    if err then return nil, "PARSER ERROR\n#{err}"

    code, posmap_or_err, err_pos = compile.tree tree
    if err then return nil, "COMPILE ERROR\n#{err}"

    luafile = moontolua fname

    fw, err = io.open luafile, "w"
    if err then return nil, err
    fw\write "#{code}\n"
    fw\close!

    luafile

is_file_newer = (f1, f2) ->
    (lfs.attributes(f1, "modification") - lfs.attributes(f2, "modification")) > 0

has_changed = (mfile) ->
    lfile = mfile\sub(1, #mfile-5) .. ".lua"
    f = io.open lfile
    if f
        f\close!
        -- if moonfile is newer, compile
        is_file_newer mfile, lfile
    -- if file doesn't exists, compile
    else 
        true

normalize_directory = (dir) ->
    if dir\sub(#dir, #dir) != "/"
        "#{dir}/"
    else
        dir

scanfolder = (root, collected) ->
    root = normalize_directory root
    collected = collected or {}

    for fname in lfs.dir(root)
        -- if filename doesn't start with .
        if fname != "." and fname != ".."
            full_path = root .. fname

            if lfs.attributes(full_path, "mode") == "directory"
                scanfolder full_path, collected
            -- if filename ends with .moon
            elseif fname\sub(#fname - 4, #fname) == ".moon"
                if not collected[full_path]
                    logmsg "added #{fname}"
                    collected[full_path] = 0
    
    collected

compilefolder = (dir, verbose) ->
    dir = dir or "."
    if not verbose then logmsg = () ->
    files = scanfolder(dir)

    successfull = true
    for f in pairs files
        if has_changed f
            logmsg "compiling #{f}"
            lfile, err = compilefile f
            if lfile then logmsg "compiled successfully to #{lfile}"
            else          
                logmsg "compilation failed: #{err}"
                successfull = false
    return successfull

return {
    :fileexists
    :compilefile
    :compilefolder
    :moontolua
}