local stuff = {

}
local g
local helper = require(game.ReplicatedStorage.Modules.ModchartHelper)
return {
    preStart = function()
        camControls.StayOnCenter = true
        local dad = playerObjects.Dad.Obj
        local bf = playerObjects.BF.Obj
        dad.PrimaryPart = dad.HumanoidRootPart
        bf.PrimaryPart = bf.HumanoidRootPart
        print(mapProps)
        dad:PivotTo(mapProps.Dad.CFrame)
        bf:PivotTo(mapProps.Boyfriend.CFrame)
        gameHandler.PositioningParts.Right.CFrame = mapProps.Dad.CFrame
		gameHandler.PositioningParts.Left.CFrame = mapProps.Boyfriend.CFrame
        g = addSprite("Evil", Color3.new(0,0,0))
        g.Transparency = 1
        for _, scr in script:GetChildren() do
            print(_, scr)
            stuff[scr.Name] = scr:Clone()
            stuff[scr.Name].Parent = g
        end
    end,
    EventTrigger = function(name, value1, value2)
        if name == "object play animation" then
            if stuff[value1] then
                local gs = value2 == "opentext"
                stuff[value1].Visible = gs
            end
        end
    end,
    cleanUp = function()
        if g then
            g:Destroy()
        end
        g = nil;
        stuff.gaytext = nil;
        stuff.thugtext = nil;
    end
}