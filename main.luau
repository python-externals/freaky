local spr = loadstring(game:HttpGet('https://raw.githubusercontent.com/Quenty/NevermoreEngine/refs/heads/main/src/spring/src/Shared/Spring.lua'))()

local RunService = game:GetService("RunService")

local new = function(class, propertys)
	propertys = propertys or {}

	local create = Instance.new(class)

	for property, value in next, propertys do
		create[property] = value
	end

	return create
end

local cf = CFrame.new
local rd = math.rad
local c0 = cf()

local rot = function(x, y, z)
	x = x or 0
	y = y or 0
	z = z or 0

	return CFrame.Angles(rd(x), rd(y), rd(z))
end

local c3 = Color3.new
local v3 = Vector3.new

function c3mod(col, val)
	col = col or c3(1, 1, 1)
	val = val or 0.5

	local modified = c3(
		col.R * val,
		col.G * val,
		col.B * val
	)

	local distance = math.sqrt(
		(col.R - modified.R)^2
			+ (col.G - modified.G)^2
			+ (col.B - modified.B)^2
	)

	if distance < 0.15 then
		local brighten = 2 + val

		modified = c3(
			math.clamp(col.R * brighten, 0, 1),
			math.clamp(col.G * brighten, 0, 1),
			math.clamp(col.B * brighten, 0, 1)
		)
	end

	return modified
end

function p(size)
	local part = Instance.new("Part")
	part.Size = size
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide=false

	return part
end

function mesh(id, texture)
	local build = {
		MeshId = "rbxassetid://" .. id,
		Scale = v3(1, 1, 1),
		VertexColor = v3(1, 1, 1),
		Offset = v3(0, 0, 0)
	}

	if texture then
		build.TextureId = "rbxassetid://" .. texture
	end

	return new("SpecialMesh", build)
end

function decal(id)
	return new("Decal", {
		Texture = "rbxassetid://" .. id
	})
end

function m6(p0, p1, c0, c1)
	return new("Motor6D", {
		Part0 = p0,
		Part1 = p1,
		C0 = c0 or CFrame.new(),
		C1 = c1 or CFrame.new(),
		Parent = p1
	})
end

local left = p(v3(1.169, 1.224, 1.038))

local dec = decal(9065282081)
dec.Face = Enum.NormalId.Right
dec.Parent = left

local shape = mesh(85193503766229)
shape.Scale = v3(1, 1, 0.95)
shape.Parent = left

local right = left:Clone()
right:FindFirstChildOfClass("SpecialMesh").MeshId = "rbxassetid://132922517258698"

local torso = p(v3(2,1,1))
local mtorso = mesh(13755434958)
mtorso.Scale = v3(0.01, 0.01, 0.01)
mtorso.Parent = torso

local leftc0 = cf(-0.33, 0.39, -0.5) * rot(-2, 180, 0)
local rightc0 = cf(0.33, 0.39, -0.5) * rot(-2, 180, 0)

local api = {
	internal = {}
}

local _intr = api.internal

local function has(inst, cname)
	return inst:FindFirstChild(cname, true)
end

function api:evaluate(model)
	if
		not model
		or _intr[model]
		or not model:IsA("Model")
		or not model.Parent
	then
		return false
	end

	local root = has(model, "Torso")
		or has(model, "UpperTorso")
		or has(model, "HumanoidRootPart")

	local colorpick = has(model, "Torso")
		or has(model, "UpperTorso")
		or has(model, "Head")

	if not root or not root:IsA("BasePart") or not colorpick then
		return false
	end

	return true, root, colorpick.Color
end

local springtemplate = {
	Speed = 10,
	Damper = 0.2,

	PositionPhysicsMultiply = 1,
	RotationPhysicsMultiply = 7,

	ImpulseMultiply = 1.5
}

function api:register(model)
	local isValid, mainbind, color = api:evaluate(model)

	if not isValid then
		return false
	end

	local morph = Instance.new("Model")
	morph.Name = "__NSFW"
	

	mainbind.Transparency = 1
	
	local newtorso = torso:Clone()
	local nleft = left:Clone()
	local nright = right:Clone()
	local ldecal = nleft:FindFirstChildOfClass("Decal")
	local rdecal = nright:FindFirstChildOfClass("Decal")
	
	ldecal.Color3 = c3mod(color, 0.5)
	rdecal.Color3 = c3mod(color, 0.5)
	
	nleft.Color = color
	nright.Color = color
	newtorso.Color = color
	
	m6(mainbind, newtorso, rot(0,180,0))

	local positionspring = spr.new(Vector3.zero)
	local rotationspring = spr.new(Vector3.zero)

	for _, spring in ipairs({positionspring, rotationspring}) do
		spring.Speed = springtemplate.Speed
		spring.Damper = springtemplate.Damper
	end

	local reg = {
		main = mainbind,

		positionspring = positionspring,
		rotationspring = rotationspring,

		lastcf = mainbind.CFrame,
		lastpos = mainbind.Position,

		left = m6(mainbind, nleft, c0),
		right = m6(mainbind, nright, c0),

		morph = morph
	}

	nleft.Parent = morph
	nright.Parent = morph
	newtorso.Parent = morph

	morph.Parent = model

	_intr[model] = reg

	return true, reg
end

function api:unregister(model)
	local info = _intr[model]

	if not info then
		return false
	end

	if info.morph then
		info.morph:Destroy()
	end
	if info.main then
		info.main.Transparency = 0
	end

	_intr[model] = nil

	return true
end

function api:setconfig(config)
	for key, value in pairs(config) do
		if springtemplate[key] ~= nil then
			springtemplate[key] = value
		end
	end

	for _, info in pairs(_intr) do
		info.positionspring.Speed = springtemplate.Speed
		info.positionspring.Damper = springtemplate.Damper

		info.rotationspring.Speed = springtemplate.Speed
		info.rotationspring.Damper = springtemplate.Damper
	end
end

RunService.PreSimulation:Connect(function(dt)
	for model, info in pairs(_intr) do
		local root = info.main

		if not root.Parent or not model.Parent then
			api:unregister(model)
			continue
		end

		local positionspring = info.positionspring
		local rotationspring = info.rotationspring

		local left = info.left
		local right = info.right

		local currentcf = root.CFrame

		local posdiff = root.Position - info.lastpos
		local localpos = info.lastcf:VectorToObjectSpace(posdiff)

		local rotationdiff = info.lastcf:ToObjectSpace(currentcf)
		local rx, ry, rz = rotationdiff:ToOrientation()

		info.lastpos = root.Position
		info.lastcf = currentcf

		positionspring:Impulse(
			-localpos * springtemplate.ImpulseMultiply
		)

		rotationspring:Impulse(
			v3(rx, ry, rz) * springtemplate.ImpulseMultiply
		)

		positionspring:TimeSkip(dt)
		rotationspring:TimeSkip(dt)

		local positionvelocity = positionspring.Position
			* springtemplate.PositionPhysicsMultiply

		local rotationvelocity = rotationspring.Position
			* springtemplate.RotationPhysicsMultiply

		local offset = cf(positionvelocity)

		local rotation = CFrame.Angles(
			rotationvelocity.X,
			rotationvelocity.Y,
			rotationvelocity.Z
		)

		left.C0 = offset * rotation * leftc0
		right.C0 = offset * rotation * rightc0
	end
end)

return api
