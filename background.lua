local pm = require('lib/playmat')

local images, bottomStep, topStep, bottomCam, topCam

function load()
	bottomStep = 0
	topStep = 0
	images = stg.images('background', {'bottom', 'top', 'fade'})
	local zoom = 480 / 2
	bottomCam = pm.newCamera(stg.width, stg.height, 0, 0, 0, zoom, 1, 1)
	topCam = pm.newCamera(stg.width, stg.height, 0, 0, 0, zoom, 1, 1)
end

function update()
  local speed = 10
  bottomStep = bottomStep - speed
	topStep = topStep - speed * .75
end

function draw()
	love.graphics.setColor(stg.colors.black)
	love.graphics.rectangle('fill', 0, 0, stg.width, stg.height)

	love.graphics.setColor(stg.colors.purple)
	pm.drawPlane(bottomCam, images.bottom, 0, bottomStep, 1, 1, true)

	love.graphics.setColor(stg.colors.brownDark)

	stg.mask('quarter', function() pm.drawPlane(topCam, images.top, 0, topStep, 1, 1, true) end)

	love.graphics.setColor(stg.colors.black)
	love.graphics.draw(images.fade, stg.frameOffset, 0)

	love.graphics.setColor(stg.colors.white)
end

return {
  load = load,
  update = update,
  draw = draw
}
