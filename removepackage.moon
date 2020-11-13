logmsg = print

from_lpower = (pkg) ->
    -- TODO
    -- add option to remove all files that
    -- package depended on
    f, err = io.popen [[
        cd lua_modules/luapower
        echo "yes" | ./mgit remove ]] .. pkg
    if err
        return nil, err
    output = f\read "*a"
    if output\match("ERROR:")
        io.write output
    else
        logmsg output
    f\close!

from_lrocks = (pkg) ->
    -- TODO

remove_package = (opts) ->
    unless opts.verbose
        logmsg = ()->
    pkgs = opts.pkgs or nil
    unless pkgs
        print "no packages given"
        return
    
    remover = if opts.power 
        from_lpower 
    elseif opts.rocks
        from_lrocks
    else
        print "no package manager given"
        os.exit 1
    
    for _,v in pairs pkgs
        print "> removing #{v}"
        success, err = remover v
        if err
           print err

return {
    :remove_package
}