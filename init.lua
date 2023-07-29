function detect()
    local store = {}
    local count = 0
    for _,tile in pairs(getTiles()) do
        if tile.flags == 0 and tile.fg ~= 0 then
            if store[tile.fg] then
                store[tile.fg].count = store[tile.fg].count + 1
            else
                store[tile.fg] = {fg = tile.fg, count = 1}
            end
        end
    end
    for _,tile in pairs(store) do
        if tile.count > count then
            count = tile.count
            itmSeed = tile.fg
            itmId = itmSeed - 1
        end
    end
    if not includesNumber(goods,itmId) then
        table.insert(goods,itmId)
    end
    if not includesNumber(goods,itmSeed) then
        table.insert(goods,itmSeed)
    end
end

function includesNumber(table, number)
    for _,num in pairs(table) do
        if num == number then
            return true
        end
    end
    return false
end

function bl(world)
    blist = {}
    fossil[world] = 0
    for _,tile in pairs(getTiles()) do
        if tile.fg == 6 then
            doorX = tile.x
            doorY = tile.y
        elseif tile.fg == 3918 then
            fossil[world] = fossil[world] + 1
        end
    end
    if blacklistTile then
        for _,tile in pairs(blacklist) do
            table.insert(blist,{x = doorX + tile.x, y = doorY + tile.y})
        end
    end
end

function tilePunch(x,y)
    for _,num in pairs(tileBreak) do
        if getTile(x - 1,y + num).fg ~= 0 or getTile(x - 1,y + num).bg ~= 0 then
            return true
        end
    end
    return false
end

function tilePlace(x,y)
    for _,num in pairs(tileBreak) do
        if getTile(x - 1,y + num).fg == 0 and getTile(x - 1,y + num).bg == 0 then
            return true
        end
    end
    return false
end

function check(x,y)
    for _,tile in pairs(blist) do
        if x == tile.x and y == tile.y then
            return false
        end
    end
    return true
end

function warp(world,id)
    cok = 0
    while getBot().world ~= world:upper() and not nuked do
        while getBot().status ~= "online" do
            connect()
            sleep(5000)
        end
        sendPacket("action|join_request\nname|"..world:upper().."\ninvitedWorld|0",3)
        sleep(5000)
        if cok == 10 then
            nuked = true
        else
            cok = cok + 1
        end
    end
    if id ~= "" and not nuked then
        while getTile(math.floor(getBot().x / 32),math.floor(getBot().y / 32)).fg == 6 and not nuked do
            while getBot().status ~= "online" do
                connect()
                sleep(5000)
            end
            sendPacket("action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0",3)
            sleep(1000)
        end
    end
end

function reconnect(world,id,x,y)
    if getBot().status ~= "online" then
        connect()
        sleep(10000)
        while true do
            sleep(10000)
            if getBot().status == "suspended" or getBot().status == "banned" then
                while true do
                    sleep(10000)
                end
            end
            while getBot().status == "online" and getBot().world ~= world:upper() do
                sendPacket("action|join_request\nname|"..world:upper().."\ninvitedWorld|0", 3)
                sleep(5000)
            end
            if getBot().status == "online" and getBot().world == world:upper() then
                if id ~= "" then
                    while getTile(math.floor(getBot().x / 32),math.floor(getBot().y / 32)).fg == 6 do
                        sendPacket("action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0", 3)
                        sleep(1000)
                    end
                end
                if x and y and getBot().status == "online" and getBot().world == world:upper() then
                    while math.floor(getBot().x / 32) ~= x or math.floor(getBot().y / 32) ~= y do
                        findPath(x,y,100)
                    end
                end
                if getBot().status == "online" and getBot().world == world:upper() then
                    if x and y then
                        if getBot().status == "online" and math.floor(getBot().x / 32) == x and math.floor(getBot().y / 32) == y then
                            break
                        end
                    elseif getBot().status == "online" then
                        break
                    end
                end
            end
        end
    end
end


function round(n)
    return n % 1 > 0.5 and math.ceil(n) or math.floor(n)
end

function tileDrop1(x,y,num)
    local count = 0
    local stack = 0
    for _,obj in pairs(getObjects()) do
        if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
            count = count + obj.count
            stack = stack + 1
        end
    end
    if stack < 15 and count <= (4000 - num) then
        return true
    end
    return false
end

function tileDrop2(x,y,num)
    local count = 0
    local stack = 0
    for _,obj in pairs(getObjects()) do
        if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
            count = count + obj.count
            stack = stack + 1
        end
    end
    if stack < 15 and count <= (4000 - num) then
        return true
    end
    return false
end

function jandaBohay(jdn,px,py)
    place(jdn,px,py)
    pkt = {}
    pkt.type = 0
    if px >= 0 then
        pkt.flags = 3104
    elseif px < 0 then
        pkt.flags = 3120
    end
    pkt.int_data = jdn
    pkt.pos_x = getBot().x
    pkt.pos_y = getBot().y
    pkt.int_x = math.floor(getBot().x/32) + px
    pkt.int_y = math.floor(getBot().y/32) + py
    sendPacketRaw(pkt)
end

function mucikariPdi(px,py)
    punch(px,py)
    pkt = {}
    pkt.type = 0
    if px >= 0 then
        pkt.flags = 2592
    elseif px < 0 then
        pkt.flags = 2608
    end
    pkt.pos_x = getBot().x
    pkt.pos_y = getBot().y
    pkt.int_x = math.floor(getBot().x/32) + px
    pkt.int_y = math.floor(getBot().y/32) + py
    sendPacketRaw(pkt)
end

local function gaulWord()
    local gaulWords = {
        "Abis pulang tukang zizah, nongkrong di kampung kemang.",
        "Kalem, abang geos!",
        "Coy, lupa bawa rokok nih, gimana?",
        "Mantul, gw lagi onfire!",
        "Gue mah ogah, udah mager dari kemaren.",
        "Lagi pada sabi, gw kalah telak!",
        "Nih, jualan ramen di sini bukaan baru.",
        "Bentar lagi uda jarang ni lu kontak.",
        "Jangan males-malesan, harus usaha!",
        "Gak perlu ribut, slow aja lah.",
        "Lagi asik guling-guling, dikomentarin.",
        "Gak kepo kok sama urusan lo.",
        "Malam minggu mager gak ada arah.",
        "Iyalah, tuh kan, muka culun.",
        "Cape deh, ditinggal gebetan.",
        "Si doi lagi ngebet mau jadi pacar.",
        "Gemes banget sama kelakuan lo.",
        "Bentar lagi weekend, kayak gini sih paling enak.",
        "Maknyus nih, sambelnya enak banget.",
        "Sekarang lagi oyor kalem, nih di mall.",
        "Rasain aja, gak direncanain.",
        "Lagi galau gini, bingung mau gimana.",
        "Gimana nih, bingung pilih yang mana.",
        "Udah males, pindah aja dulu.",
        "Jangan asal gas, pikir dulu dong.",
        "Jangan diambil pusing, mending santai aja.",
        "Lagi woles, gak ada yang bisa gangguin.",
        "Santai aja dulu, gak usah tegang.",
        "Jangan gass terus, ambil napas dulu.",
        "Dia tuh bener-bener bucin, gak jelas.",
        "Kondisi lagi kacau, nih bener-bener gak karuan.",
        "Si dia lagi gebetan lo ya?",
        "Gak perlu galau, nanti juga ada jalan.",
        "Ayo ikutan gass bareng-bareng!",
        "Ngapain sih ikut-ikutan heboh?",
        "Cuma senyuman doang, udah bikin gemes.",
        "Si dia tuh selalu bikin penasaran.",
        "Lagi gebetan berat, nih pasti.",
        "Lagi pengen jajan makanan enak.",
        "Tuh kan, nih uda kaya gitu.",
        "Cape deh, jadi orang baik aja gak dibalas.",
        "Gak ada kabar lagi, bener-bener gak jelas.",
        "Lagi pada omdo semua, bete banget.",
        "Abis main game, coba nongkrong di sini.",
        "Sering-sering ketemuan, biar gak kangen.",
        "Nah, itu dia, kayak gini.",
        "Eh, jangan bener-bener bucin lah.",
        "Lagi nungguin, doi gak dateng-dateng.",
        "Si dia tuh orangnya sableng banget.",
        "Gak pake peduliin, tinggalin aja.",
        "Cuma bisa doain yang terbaik buat si dia.",
        "Lagi santai, gak usah terlalu serius.",
        "Males banget jadi orang baik.",
        "Lagi nungguin, doi malah gak kelar-kelar.",
        "Nggak terima aja, bete banget.",
        "Nggak suka sih, tapi ya sudahlah.",
        "Jangan overthinking, cuma bikin pusing.",
        "Hati-hati, banyak orang munafik.",
        "Lagi pada jualan rame-rame, nih bener-bener lagi trend.",
        "Gue tuh selalu berusaha baik, tapi ya gimana.",
        "Waktu itu bener-bener kepo sih, pengen tau aja.",
        "Cuma bisa pasrah aja, gimana lagi.",
        "Uda gak usah pernah ketemu, biar enak.",
        "Nggak suka sih, tapi gak apa-apa.",
        "Lagi bosen, pengen ke tempat baru.",
        "Ayo pada ngumpul bareng-bareng lagi.",
        "Gak ngerti deh sama orang kayak gini.",
        "Gue tuh bener-bener cuek, gapapa sih.",
        "Lagi pada heboh semua, nih bikin geger.",
        "Nih, lagi ada acara seru nih.",
        "Suka banget sama makanan ini, enak banget.",
        "Cuma bisa lihat dari jauh, gak bisa apa-apa.",
        "Gak perlu drama-dramaan, capek.",
        "Nggak usah pake baper, gak ada gunanya.",
        "Cuma bisa ngeliatin dari kejauhan, bener-bener gak berani.",
        "Lagi ditemenin, tuh seneng banget.",
        "Lagi asik guling-guling, ada yang ngomongin.",
        "Gak usah pada pake jaim-jaim, santai aja.",
        "Lagi dengerin lagu enak, bawaannya pengen joget.",
        "Nih, lagi pada rame-rame di tempat baru.",
        "Gue tuh kalem, gak perlu ribut.",
        "Udah capek-capek ngomong, doi malah gak dengerin.",
        "Asik banget nih, liburan seru.",
        "Gak usah sok asik, nih keliatan banget.",
        "Bentar lagi weekend, pasti seru banget nih.",
        "Cuma bisa bisa doa aja, gimana lagi.",
        "Lagi asik main, ada yang gangguin.",
        "Gue gak peduliin, tinggalin aja.",
        "Lagi mikirin, gak usah bener-bener serius.",
        "Jangan dibawa serius, nanti malah stress.",
        "Kondisi lagi kacau, bener-bener gak karuan.",
        "Nih, jualan makanan enak banget di sini.",
        "Abis pulang tukang zizah, langsung nongkrong di kampung kemang.",
        "Cuma senyuman doang, udah bikin gemes.",
        "Bentar lagi uda jarang ni lu nongkrong di sini.",
        "Kita ngapain sih, ikut-ikutan heboh?",
        "Gue tuh selalu berusaha baik, tapi gimana ya.",
        "Gak usah diambil pusing, santai aja dulu.",
        "Jangan sok asik, tuh keliatan banget.",
        "Santai aja dulu, gak usah tegang.",
        "Jangan bawa drama-dramaan, capek.",
        "Gak usah dibawa serius, nanti malah stress.",
        "Gue tuh kalem, gak usah ribut.",
        "Lagi asik nongkrong, ada yang ngomongin.",
        "Buat apa pake jaim-jaim, santai aja.",
        "Lagi asik main game, tiba-tiba ada yang gangguin.",
        "Gak usah sok asik, keliatan banget.",
        "Nggak perlu pake baper, gak ada gunanya.",
        "Gue gak peduliin, tinggalin aja.",
        "Santai aja dulu, gak usah terlalu serius.",
        "Nggak usah diambil pusing, biar enak.",
        "Hati-hati, banyak orang munafik.",
        "Lagi pada heboh semua, bikin geger.",
        "Gak usah pake jaim-jaim, santai aja.",
        "Lagi dengerin lagu enak, bawaannya pengen joget.",
        "Nih, lagi pada rame-rame di tempat baru.",
        "Gue tuh kalem, gak perlu ribut.",
        "Udah capek-capek ngomong, gak dengerin juga.",
        "Asik banget nih, liburan seru.",
        "Gak usah sok asik, keliatan banget.",
        "Bentar lagi weekend, pasti seru banget nih.",
        "Cuma bisa doa aja, gimana lagi.",
        "Lagi asik main, ada yang gangguin.",
        "Gue gak peduliin, tinggalin aja.",
        "Lagi mikirin, gak usah bener-bener serius.",
        "Jangan dibawa serius, nanti malah stress.",
        "Kondisi lagi kacau, gak karuan banget.",
        "Nih, jualan makanan enak banget di sini.",
    }

    local acakIndex = math.random(1, #gaulWords)
    local kataGaul = gaulWords[acakIndex]

    say(kataGaul)
end

function pukulBlock()
    gaulWord()
    sleep(100)
    for _,tile in pairs(getTiles()) do
        if tile.fg == itmId or tile.bg == itmId then
            findPath(tile.x,tile.y)
            sleep(100)
            while getTile(tile.x,tile.y).fg > 0 or getTile(tile.x,tile.y).bg > 0 do
                mucikariPdi(0,0)
                sleep(100)
            end
        end
    end
end
