https = require "ssl.https"
lfs = require "lfs"
import fileexists from require "moonfile"

logmsg = print
logwrite = io.write

from_lpower = (pkg) ->
    -- get package page from luapower
    res, status = https.request "https://luapower.com/#{pkg}/download"
    if status != 200
        return false, "the request failed: status #{status}"

    -- find the line with the command to install pkg + all dependencies
    command = res\match("./mgit.*")
    command = command\sub 1, command\find("\n") - 1

    _, endcmd = command\find("./mgit clone #{pkg}")

    -- removing ./mgit clone to print which packages are being installed
    installing = command\sub endcmd + 2, #command
    installing = "installing #{installing} ~~~~~~~~~~~~~~~~~"

    -- pretty print
    logmsg command
    logmsg installing
    for i=1, #installing do logwrite "~"
    logmsg!

    -- enter luapower folder then run command
    f = io.popen "cd lua_modules/luapower ; #{command}"
    for l in f\lines!
        logmsg l
    f\close!

    -- pretty print
    for i=1, #installing do logwrite "~"
    logmsg!

    true, nil

from_lrocks = (pkg) ->
    -- TODO
    -- quick and dirty implementation, should be made better
    f, err = io.popen "luarocks install #{pkg} --tree lua_modules/luarocks"
    if err
        return false, err
    for l in f\lines!
        logmsg l
    f\close!
    return true, err

install_package = (opts) ->
    -- mute messages if verbose is not enabled
    unless opts.verbose
        logmsg = () ->
        logwrite = () ->
    pkgs = opts.pkgs or nil
    unless pkgs
        print "no packages given"
        return

    installer = if opts.power 
        from_lpower 
    elseif opts.rocks
        from_lrocks
    else
        print "no package manager given"
        os.exit 1

    -- create and initalize luapower folder if it doesn't exists
    unless fileexists "lua_modules/luapower/mgit"
        print "initializing luapower folder"
        os.execute [[
            cd lua_modules;
            git clone https://github.com/capr/multigit luapower
            cd luapower
            ./mgit clone https://github.com/luapower/luapower-repos
        ]]

    -- install every packages
    for _,v in pairs pkgs
        print "> installing #{v}"
        success, err = installer v
        if err
           print err

return {
    :install_package
}