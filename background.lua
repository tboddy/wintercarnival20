local playmat = require('lib/playmat')

local images = {}, zoom, angle, bottomStep, bottomMeshes, bottomCam, topStep, topMeshes, topCam, speed

local function load()
	images = {
    bottom = love.graphics.newImage('img/background/bottom.png'),
		top = love.graphics.newImage('img/background/top.png'),
    fade = love.graphics.newImage('img/background/fade.png')
	}
	stg.loadImages(images)
	zoom = 64 * 4
	angle = -math.pi / 2
	speed = 18
	bottomStep = 0
	bottomMeshes = {}
	local fov = .1
	bottomCam = playmat.newCamera(stg.width, stg.height, 0, 0, angle, zoom, 1.5, 1)
	topStep = 0
	topMeshes = {}
	topCam = playmat.newCamera(stg.width, stg.height, 0, 0, angle, zoom, 1.5, 1)
end

local function update()
	bottomStep = bottomStep + speed
	topStep = topStep + speed * .75
end

local function draw()
	love.graphics.setColor(stg.colors.blueDark)
	love.graphics.rectangle('fill', 0, 0, stg.width, stg.height)
	love.graphics.setColor(stg.colors.purple)
	playmat.drawPlane(bottomCam, images.bottom, 0, bottomStep, 1, 1, true)
	love.graphics.setColor(stg.colors.black)
	stg.mask('half', function() playmat.drawPlane(topCam, images.top, 0, topStep, 1, 1, true) end)
	love.graphics.setColor(stg.colors.purple)
  love.graphics.draw(images.fade, -(stg.winWidth - stg.width) / 2, 0)
	love.graphics.setColor(stg.colors.white)
end

return {
  load = load,
  update = update,
  draw = draw
}
