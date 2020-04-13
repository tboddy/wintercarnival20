local images = {}, zoom, angle, speed, bottomLines, scaleMod, bottomQuads

local function loadLines()
	scaleMod = 16
	local lineNumber = 0
	local height = stg.height / scaleMod
	bottomLines = {}
	bottomQuads = {}
	for i = 1, height do
		bottomLines[i] = height / (lineNumber - math.floor(height ^ 1)) * -1
		lineNumber = lineNumber - 1
	end
	local i, j = 1, #bottomLines
	while i < j do
		bottomLines[i], bottomLines[j] = bottomLines[j], bottomLines[i]
		i = i + 1
		j = j - 1
	end
	for i = 1, #bottomLines do
		bottomQuads[i] = love.graphics.newQuad(stg.width, 0, stg.width, images.bottom:getHeight(), images.bottom:getWidth() * bottomLines[i], images.bottom:getHeight())
	end
	images.bottom:setWrap('repeat', 'repeat')
end

local function load()
	images = {
    bottom = love.graphics.newImage('img/background/bottom.png'),
		top = love.graphics.newImage('img/background/top.png'),
    fade = love.graphics.newImage('img/background/fade.png'),
    boss1 = love.graphics.newImage('img/background/boss1.png')
	}
	stg.loadImages(images)
	zoom = 64 * 2
	angle = math.pi
	speed = 2
	loadLines()
end

local function update()
end

local function draw()
	-- if stage.bossHealth > 0 and stage.bossMaxHealth > 0 then
	--   love.graphics.draw(images.boss1, 0, 0)
	-- else
		love.graphics.setColor(stg.colors.black)
		love.graphics.rectangle('fill', 0, 0, stg.width, stg.height)
		love.graphics.setColor(stg.colors.white)
		local mMod = 4
		for i = 1, #bottomLines do
			local mod = bottomLines[i]
			local xDiff = stg.grid * mod * mMod
			local y = (i - 1) * scaleMod * mod + stg.grid * 2
			love.graphics.draw(images.bottom, bottomQuads[i], 0, y, 0, 1, mod, 0, 0, 0, 0)
			local vX, vY, vW, vH = bottomQuads[i]:getViewport()
			bottomQuads[i]:setViewport(vX + mod * speed, vY, vW, vH)
		end

		-- love.graphics.setColor(stg.colors.black)
	 --  love.graphics.draw(images.fade, 0, 0)
		-- love.graphics.setColor(stg.colors.white)
	-- end
end

return {
  load = load,
  update = update,
  draw = draw
}
