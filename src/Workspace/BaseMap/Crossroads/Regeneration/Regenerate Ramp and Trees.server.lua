ramp = game.Workspace:findFirstChild("Overhead Ramp")
trees = game.Workspace.Trees

backup_ramp = ramp:clone()
backup_trees = trees:clone()

while true do
	wait(script.Parent.RegenerationTime.Value*(1-math.random()*0.8))

	ramp:remove()
        trees:remove()

	wait(script.Parent.RegenerationDelay.Value)

	ramp = backup_ramp:clone()
        ramp.Parent = game.Workspace
        ramp:makeJoints()

	trees = backup_trees:clone()
	trees.Parent = game.Workspace
	trees:makeJoints()


end
