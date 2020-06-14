local pm = require('lib/playmat')

local images, bottomStep, topStep, bottomCam, topCam, wallOffset, speed

function load()
	bottomStep = 0
	topStep = 0
	images = stg.images('background', {'floor', 'top', 'fade', 'wall', 'fadewall', 'fadetop'})
	local zoom = 480 / 2
	bottomCam = pm.newCamera(stg.width, stg.height, 0, 0, 0, zoom, 1, 1)
	wallOffset = 0
	speed = 4
end

function updateFloor()
  bottomStep = bottomStep - speed
	topStep = topStep - speed * 1.5
end

function updateWall()
	wallOffset = wallOffset + speed
	if wallOffset >= images.wall:getWidth() then wallOffset = 0 end
end

function update()
	updateFloor()
	updateWall()
end

function drawFloor()
	love.graphics.setColor(stg.colors.black)
	love.graphics.rectangle('fill', 0, 0, stg.width, stg.height)
	love.graphics.setColor(stg.colors.brownDark)
	pm.drawPlane(bottomCam, images.floor, 0, bottomStep, 1, 1, true)
	love.graphics.setColor(stg.colors.white)
	love.graphics.setColor(stg.colors.black)
	love.graphics.draw(images.fade, stg.frameOffset, images.floor:getHeight() * 2)
end

function drawWall()
	local y = 0
	local width = images.wall:getWidth()
	local height = images.wall:getHeight()
	for i = 1, 2 do
		local x = stg.frameOffset - wallOffset
		for j = 1, stg.width / width do
			love.graphics.setColor(stg.colors.black)
			love.graphics.rectangle('fill', x, y, width, height)
			love.graphics.setColor(stg.colors.brownDark)
			love.graphics.draw(images.wall, x, y)
			x = x + width
		end
		y = y + height
	end
	love.graphics.setColor(stg.colors.black)
	love.graphics.draw(images.fadewall, stg.frameOffset, 0)
end

function draw()
	drawFloor()
	drawWall()
	love.graphics.setColor(stg.colors.black)
	love.graphics.draw(images.fadetop, stg.frameOffset, 0)
	love.graphics.setColor(stg.colors.white)
end

return {
  load = load,
  update = update,
  draw = draw
}
