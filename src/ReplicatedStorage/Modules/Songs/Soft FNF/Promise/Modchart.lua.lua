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
    end
}