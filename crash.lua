local function crash(msg)
    print("ERROR: " .. tostring(msg))
    os.exit(1)
end

local function crash_if(err, msg) 
    msg = msg or err
    if err then 
        crash(msg)
    end
end

return {
    crash = crash,
    crash_if = crash_if
}