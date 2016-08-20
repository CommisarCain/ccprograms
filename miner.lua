
mastrot = getRotation()
droprot = 0
dropx = 0
dropy = 0
dropz = 0
 
function shaft(depth)
    turtle.forward()
    suc = true
    count = depth
    count2 = 0
    while count > 0 and suc do
        turtle.digDown()
        suc = turtle.down()
        count = count - 1
        count2 = count2 + 1
    end
    while count2 > 0 do
        turtle.up()
    end
    turtle.back()
    turtle.turnRight()
    emptyInventory()
    turtle.turnLeft()
end
 
function emptyInventory()
    for i = 1, 16 do
        turtle.select(i)
        if not turtle.drop() then
            print("External Drop Off inverntory full")
            return false
        end
    end
    return true
end
 
function shortTunnel(length)
    count = length
    mvDigFUD(length)
    tr()
    tr()
    turtle.down()
    turtle.select(1)
    while count > 0 do
        while turtle.detect() do
            turtle.dig()
            os.sleep(0.5)
        end
        if not turtle.detectDown() then
            turtle.placeDown()
        end
        turtle.forward()
        count = count - 1
    end
end
 
function invFull()
    for i = 1,16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end
 
function cleanMove(tx,ty,tz,rot)
--target coords in followed by optional rotation 1=x+aligned 2=z+aligned 3=x- 4=z-
    local x, y, z = gps.locate()
    rot =  rot or getRotation()
    local dx = tx - x
    local dy = ty - y
    local dz = tz - z
   
    if dy > 0 then
        for i = 1, dy do
            turtle.up()
        end
    elseif dy < 0 then
        for i = 1, Math.abs(dy) do
            turtle.down()
        end
    end
    if dx > 0 then
        turnTo(1)
        mvF(dx)
    elseif dx < 0 then
        turnTo(3)
        mvF(Math.abs(dx))
    end
    if dz > 0 then
        turnTo(2)
        mvF(dz)
    elseif dz < 0 then
        turnTo(4)
        mvF(Math.abs(dz))
    end
   
    turnTo(rot)
    --move success check
    x, y, z = gps.locate()
    if x == tx and y == ty and z == tz then
        return true
    else
        print("Clean move failed")
        return false
    end
   
end
 
function getRotation()
    x,y,z = gps.locate()
    turtle.forward()
    x2,y2,z2 = gps.locate()
   
    xf = x2 - x
    zf = z2 - z
    turtle.back()
   
    if(xf == 1) then
        return 1
    end
    if(xf == -1) then
        return 3
    end
    if(zf == 1) then
        return 2
    end
    if(zf == -1) then
        return 4
    end
   
    print("Rotation calculation error")
    return 0
 
end

 mastrot = getRotation()
 
function turnTo(trot, rot)
    rot = rot or mastrot
    m = trot - rot
    if m > 0 then
        if m == 3 then
            tl()
        else
            while m ~= 0 do
                tr()
                m = m - 1
            end
        end
    elseif m < 0 then
        if m == 3 then
            tr()
        else
            while m ~= 0 do
                tl()
                m = m + 1
            end
        end
    end
   
end
 
function mvF(count)
    count = count or 1
    for i=1,count do
        turtle.forward()
    end
end
 
function mvB(count)
    count = count or 1
    for i=1,count do
        turtle.back()
    end
end
 
function mvDigF(count)
    count = count or 1
    for i=1,count do
        while turtle.detect() do
            turtle.dig()
            os.sleep(.2)
        end
        turtle.forward()
    end
end
 
function mvDigFUD(count)
    count = count or 1
    for i=1,count do
        while turtle.detect() do
            turtle.dig()
            os.sleep(.1)
        end
        turtle.forward()
        while turtle.detectUp() do
            turtle.digUp()
            os.sleep(.1)
        end
        while turtle.detectDown() do
            turtle.digDown()
            os.sleep(.1)
        end
    end
end
 
function descendDig(count)
    count = count or 1
    for i=1,count do
        turtle.digDown()
        os.sleep(.1)
        turtle.down()
    end
end
 
function rev()
    tr()
    tr()
end
 
function tl()
    turtle.turnLeft()
    mastrot = mastrot - 1
    if mastrot == 0 then
        mastrot = 4
    end
end
   
function tr()
    turtle.turnRight()
    mastrot = mastrot + 1
    if mastrot == 5 then
        mastrot = 1
    end
end
 
function qInvControl()
    if invFull() then
        local crot = mastrot
        local cx, cy, cz = gps.locate()
        turtle.up()
        turtle.up()
        cleanMove(dropx,dropy,dropz,droprot)
        emptyInventory()
        cleanMove(cx,cy,cz,crot)
        turtle.down()
        turtle.down()
    end
end
 
function quarry(l,w,d)
   
    local sx, sy, sz = gps.locate()
    local srot = mastrot()
    --set target y and make sure its 2 above bedrock
    fy = sy - d
    if fy < 2 then
        fy = 2
    end
   
    --establish dropoff
    turtle.forward()
    tr()
    turtle.forward()
    tr()
    dropx, dropy, dropz = gps.locate()
    droprot = mastrot
    tr()
    turtle.forward()
    tr()
    turtle.back()
   
    rev()
    turtle.forward()
    turtle.turnRight()
    turtle.forward()
    turtle.down()
    local cx, cy, cz = gps.locate()
    while cy > fy do
        descendDig(2)
        cx, cy, cz = gps.locate()
        if cy < 2 then
            turtle.up()
        end
        lw = w
        alt = 1
        for i=0,w do
            if alt == 1 then
                mvDigFUD(l-1)
                tr()
                mvDigFUD()
                tr()
                alt = 2
                qInvControl()
                cx, cy, cz = gps.locate()
            elseif alt == 2 then
                mvDigFUD(l-1)
                tl()
                mvDigFUD()
                tl()
                alt = 1
                qInvControl()
                cx, cy, cz = gps.locate()
            end
        end
    end
    cleanMove(sx,sy+1,sz,srot) 
   
end
 
function nav(x, y, z, rot)
 
     
 
end
