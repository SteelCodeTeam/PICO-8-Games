--pico_os!
cmd=""
co=7
files={}
fc={}
hi={}
t=0
fs={
    ls="list files",
    cat="read file", 
    echo="print text",
    cls="clear screen",
    uptime="show uptime",
    exit="shutdown system",
    help="show commands"
}

function _init()
    poke(0x5f2d,0x1)
    poke(0x5f30,1)
    op("pico-os v.1k")
    op("type 'help' for commands")
    cls()
end

function _update()
    t += 1
    poke(0x5f30,1)
    local key,keyp=stat(30),stat(31)
    if key then
        if keyp=="\b" then
            if #cmd>0 then cmd=sub(cmd,1,#cmd-1) end
        elseif keyp=="\r" or keyp=="\n" then
            run(cmd)
            cmd=""
        elseif keyp>=" " then
            cmd=cmd..keyp
        end
    end
end

function _draw()
    cls()
    local y=0
    for h in all(hi) do
        if y>110 then
            del(hi,hi[1])
            y=0
        end
        y+=7
        print(h,0,y,co)
    end
    y+=7
    print("> "..cmd..(time()%1<0.5 and "_" or " "),0,y,co)
end

function op(text)
    add(hi,text)
end

function trim(str)
    while sub(str,1,1)==" " do str=sub(str,2) end
    while #str>0 and sub(str,#str,#str)==" " do str=sub(str,1,#str-1) end
    return str
end

function ga(cmm,sp)
    local i=sp
    while i<=#cmm and sub(cmm,i,i)==" " do i+=1 end
    return i<=#cmm and sub(cmm,i) or ""
end

function run(cmm)
    if cmm=="cls" then
        hi={}
        return
    else
        op("> "..cmm)
    end

    if cmm=="help" then
        for cmd,desc in pairs(fs) do
            op(" "..cmd.." - "..desc)
        end
    elseif sub(cmm,1,4)=="echo" then
        local parts=split(cmm,">")
        parts[1]=trim(sub(parts[1],6))
        if #parts[1]>0 then
            if not parts[2] then
                op(parts[1])
            else
                local fnm=trim(parts[2])
                add(files,fnm)
                fc[fnm]=parts[1]
            end
        end
    elseif sub(cmm,1,3)=="cat" then
        local fnm=ga(cmm,4)
        if fnm!="" and fc[fnm] then
            op(" "..fc[fnm])
        else
            op(" cat: "..fnm..": no such file or directory")
        end
    elseif cmm=="ls" then
        if #files==0 then
            op("no files")
        else
            for file in all(files) do
                op(" "..file)
            end
        end
    elseif cmm=="uptime" then
        op("system up: "..flr(t/30).."s")
    elseif cmm=="exit" then
        print("seeya!")
        stop()
    else
        op("command: '"..cmm.."' not found")
    end
end
