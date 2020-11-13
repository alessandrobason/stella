moonfile = require("moonfile")
import compilefolder, moontolua from moonfile

logmsg = print

run_project = (options) ->
    assert options
    if not options.verbose
        logmsg = () ->
    args = options.args or {}
    args_str = ""
    for _,v in pairs args
        args_str ..= "#{v} "

    settings = dofile ".stella/settings.lua"
    main = settings.main
    lang = settings.lang

    switch settings.lang
        when "moon"    then lang = "lua"
        when "moonjit" then lang = "luajit"
    
    switch settings.mode
        when "other"
            print "TODO"
        when "commandline"
            luafile = settings.main
            if settings.lang == "moon" or settings.lang == "moonjit"
                success = compilefolder ".", options.verbose
                if not success then return
                luafile = moontolua settings.main
            command = "#{lang} -e 'dofile(\".stella/set_paths.lua\")' #{luafile} #{args_str}"
            logmsg "> #{command}"
            print "running file +-+-+-+-+-+-+-+-"
            f = io.popen command
            for line in f\lines()
                print line
            print "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            f\close!
    
    
    
    
    
    -- if settings.mode == "debug"
    --     print "debug"
    -- elseif settings.mode == "release"
    --     os.execute settings.lang .. ""

    --for k,v in pairs(settings) do print k,v

    -- f = io.open fname
    -- if f then f\close!
    -- else
    --     print "no file in #{dir}" 
    --     return

    -- export arg = args or { }
    -- arg[-1] = "lua"
    -- arg[0] = fname
    -- dofile ".stella/set_paths.lua"
    -- func, err = loadfile fname
    -- if err
    --     print err
    --     return
    -- paths, err = loadfile ".stella/set_paths.lua"
    -- if err
    --     print err
    --     return
    
    -- package.path = package.path\match "%./%?%.lua.+"
    -- package.cpath = package.cpath\match "%./%?%.so.+"

    -- print "running file +-+-+-+-+-+-+-+-"
    -- paths!
    -- func!
    -- print "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

return {
    :run_project
}