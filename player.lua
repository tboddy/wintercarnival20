local images, sounds, initX, initY, x, y, width, height, bullets, invulnerableLimit, clock, canShoot, laserWidth,
  shotClock, lives, invulnerableClock, borderCurrent, laserSpeed, laserXMod, laserKill, laserClock, lastX, lastY, playerSpeed

local function load()
  images = stg.images('player', {'suika1', 'miyoi1', 'hitbox', 'bullet', 'bullet', 'border', 'hearts'})
  initX = stg.grid * 4
  initY = stg.height / 2
  x = initX
  y = initY
  lastX = x
  lastY = y
  width = images.miyoi1:getWidth()
  height = images.miyoi1:getHeight()
  borderSize = 164
  bullets = {}
  for i = 1, 64 do bullets[i] = {} end
  invulnerableLimit = 60 * 2.5
  clock = 0
  canShoot = true
  shotClock = 0
  lives = 2
  invulnerableClock = 0
  borderCurrent = 0
  laserWidth = 32
  laserXMod = 20
  laserHeight = 12
  laserSpeed = 64
  laserKill = 0
  laserClock = 0
end

local function updateMove()
  lastX = x
  lastY = y
  playerSpeed = 5.5; if controls.focus() then playerSpeed = 3 end
  local xSpeed = 0; if controls.left() then xSpeed = -1 elseif controls.right() then xSpeed = 1 end
  local ySpeed = 0; if controls.up() then ySpeed = -1 elseif controls.down() then ySpeed = 1 end
  local fSpeed = playerSpeed / math.sqrt(math.max(xSpeed + ySpeed, 1))
  x = x + fSpeed * xSpeed
  y = y + fSpeed * ySpeed
  player.x = x
  player.y = y
  if x < images.hitbox:getWidth() / 2 then x = images.hitbox:getWidth() / 2
  elseif x > stg.width - images.hitbox:getWidth() / 2 - stg.frameOffset * 2 then x = stg.width - images.hitbox:getWidth() / 2 - stg.frameOffset * 2 end
  if y < images.hitbox:getHeight() / 2 then y = images.hitbox:getHeight() / 2
  elseif y > stg.height - images.hitbox:getHeight() / 2 then y = stg.height - images.hitbox:getHeight() / 2 end
end

local function spawnBullet(opts)
	local diff = math.pi / 9
  local bullet = bullets[stg.getIndex(bullets)]
  local offset = 4
	bullet.active = true
  bullet.laser = false; if opts.laser then bullet.laser = true end
	bullet.angle = diff * opts.mod
  if opts.double then bullet.double = true else bullet.double = false end
	bullet.x = x + math.cos(bullet.angle) * offset
	bullet.y = y + math.sin(bullet.angle) * offset
  if opts.laser then
    bullet.laserWidth = laserWidth
    if x < lastX then
      bullet.laserWidth = laserWidth + playerSpeed
      if y < lastY or y > lastY then
        -- bullet.laserWidth = bullet.laserWidth
      end
    end
    if x > lastX then
      bullet.laserWidth = laserWidth - playerSpeed
      if y < lastY or y > lastY then
        bullet.laserWidth = bullet.laserWidth + 2
      end
    end
  else
    local drunk = .025
    bullet.angle = bullet.angle - drunk + drunk * 2 * math.random()
  end
end

local function updateBullet(bullet)
  local bulletWidth = images.bullet:getWidth()
  local bulletHeight = images.bullet:getHeight()
  local bulletSpeed = bulletWidth
  if bullet.laser then
    bulletHeight = laserHeight
    bulletWidth = bullet.laserWidth
    bulletSpeed = laserWidth
  end
  local drunkMod = 8

	bullet.x = bullet.x + math.cos(bullet.angle) * bulletSpeed
	bullet.y = bullet.y + math.sin(bullet.angle) * bulletSpeed

	if bullet.x < -bulletWidth * 2 or bullet.x > stg.width - stg.frameOffset or
    bullet.y < -bulletHeight * 2 or bullet.y > stg.height + bulletHeight * 2 then bullet.active = false
  else
    local kill = false
    for i = 1, #stage.enemies do
      if stage.enemies[i].active and stage.enemies[i].seen then
        if math.sqrt((stage.enemies[i].x - bullet.x) * (stage.enemies[i].x - bullet.x) + (stage.enemies[i].y - bullet.y) * (stage.enemies[i].y - bullet.y)) < stage.enemies[i].height / 2 + bulletHeight / 2 then
          stage.enemies[i].health = stage.enemies[i].health - 1
          kill = true
        end
      end
    end
    if kill then
      local explosionObj = {x = bullet.x, y = bullet.y, big = true}
      if not bullet.laser then explosionObj.type = 'gray' end
      explosion.spawn(explosionObj)
      bullet.active = false
    end
    if kill then bullet.active = false end
  end
end

local function updateShot()
	if controls.shot() and canShoot then
		canShoot = false
		shotClock = 0
	end
	local interval = 10
	local limit = interval * 2
	local max = limit
	if not canShoot and not stg.gameOver and not controls.focus() then
		if shotClock % interval == 0 and shotClock < limit then
      sound.sfx = 'playerbullet'
      spawnBullet({mod = 0})
      -- if player.power >= 1 then
      --   spawnBullet({mod = 1})
      --   spawnBullet({mod = -1})
      -- end
    end
		shotClock = shotClock + 1
  elseif controls.focus() and controls.shot() then
    spawnBullet({mod = 0, laser = true})
  end
	if shotClock >= max then canShoot = true end
  for i = 1, #bullets do if bullets[i].active then updateBullet(bullets[i]) end end
  -- updateLaser()
end

local function kill()
end

local function getHit(bullet)
  if invulnerableClock == 0 then
    -- stage.killBullets = true
    -- bullet.active = false
    -- local expObj = {x = x, y = y, big = true}
    -- if string.find(bullet.type, 'Red') then expObj.type = 'red' end
    -- explosion.spawn(expObj)
    -- if lives > 0 then
    --   lives = lives - 1
    --   invulnerableClock = invulnerableLimit
    --   x = initX
    --   y = initY
    -- end
    -- else stg.gameOver = true end
  end
end

local function updateBorderSize()
  if controls.focus() then
    local mod = 10
    if borderCurrent < borderSize / 2 - mod then borderCurrent = borderCurrent + mod
    elseif borderCurrent ~= borderSize / 2 then borderCurrent = borderSize / 2 end
  elseif borderCurrent ~= 0 then borderCurrent = 0 end
end

local function update()
  if not stg.gameOver and invulnerableClock < invulnerableLimit - 20 then updateMove() end
  updateShot()
  updateBorderSize()
  if invulnerableClock > 0 then invulnerableClock = invulnerableClock - 1 end
  clock = clock + 1
  player.invulnerableClock = invulnerableClock
  player.lives = lives
end

local function drawLaser(bullet)
  local laserX = bullet.x - laserWidth + stg.frameOffset
  local laserY = bullet.y - laserHeight / 2
  local offset = 4
  love.graphics.setColor(stg.colors.blueLight)
  stg.mask('half', function() love.graphics.rectangle('fill', laserX + laserWidth, laserY - offset, bullet.laserWidth, laserHeight + offset * 2) end)
  love.graphics.setColor(stg.colors.offWhite)
  love.graphics.rectangle('fill', laserX + laserWidth, laserY, bullet.laserWidth, laserHeight)
  love.graphics.setColor(stg.colors.white)
end

local function drawLaserBall()
  local offset = stg.grid * 2 - 2
  local rectWidth = 12
  local yOffset = 4
  local ballX = x + offset + stg.frameOffset
  local rectY = y - laserHeight / 2
  love.graphics.setColor(stg.colors.blueLight)
  stg.mask('half', function()
    love.graphics.rectangle('fill', ballX, rectY - yOffset, rectWidth, laserHeight + yOffset * 2)
    love.graphics.circle('fill', ballX, y, laserHeight / 2 + yOffset)
  end)
  love.graphics.setColor(stg.colors.white)
  love.graphics.rectangle('fill', ballX, rectY, rectWidth, laserHeight)
  love.graphics.circle('fill', ballX, y, laserHeight / 2)
  love.graphics.setColor(stg.colors.white)
end

local function drawBullet(bullet)
  if bullet.laser then drawLaser(bullet)
  else
    stg.mask('half', function()
      love.graphics.draw(images.bullet, bullet.x + stg.frameOffset, bullet.y, bullet.angle, 1, 1, images.bullet:getWidth() / 2, images.bullet:getHeight() / 2)
    end)
  end
end

local function animateImage(shadow)
  local interval = 30
  local img = 'miyoi1'
  if clock % interval >= interval / 2 then img = 'miyoi1' end
  return images[img]
end

local function drawBorder()
  local borderWidth = 12
  love.graphics.setLineWidth(borderWidth)
  love.graphics.setColor(stg.colors.blueDark)
  stg.mask('most', function() love.graphics.circle('line', x + stg.frameOffset, y, borderCurrent - borderWidth / 2) end)
  stg.mask('half', function() love.graphics.circle('line', x + stg.frameOffset, y, borderCurrent - borderWidth * 1.5 + 1) end)
  stg.mask('quarter', function() love.graphics.circle('line', x + stg.frameOffset, y, borderCurrent - borderWidth * 2.5 + 2) end)
  love.graphics.setLineWidth(2)
  love.graphics.circle('line', x + stg.frameOffset, y, borderCurrent - borderWidth / 2 + borderWidth / 2)
  love.graphics.setColor(stg.colors.white)
end

local function drawPlayer()
  local canDraw = false
  local interval = 30
  if invulnerableClock % interval < interval / 2 then canDraw = true end
  if canDraw then
    if controls.focus() then
      drawBorder()
      love.graphics.draw(images.miyoi1, x + stg.frameOffset, y, 0, 1, 1, width / 2, height / 2)
      love.graphics.draw(images.hitbox, x + stg.frameOffset, y, 0, 1, 1, images.hitbox:getWidth() / 2, images.hitbox:getHeight() / 2)
    else
      -- love.graphics.draw(images.miyoi1, x + stg.frameOffset, y, 0, 1, 1, width / 2, height / 2)
      love.graphics.draw(images.suika1, x + stg.frameOffset, y + 4, 0, 1, 1, images.suika1:getWidth() / 2, images.suika1:getHeight() / 2)
    end
  end
end

local function draw()
  drawPlayer()
  for i = 1, #bullets do if bullets[i].active then
    drawBullet(bullets[i])
  end end
  if controls.focus() and controls.shot() then drawLaserBall() end
end

return {
  load = load,
  update = update,
  draw = draw,
  x = x,
  y = y,
  height = height,
  hit = false,
  invulnerableClock = 0,
  getHit = getHit,
  lives = 0,
  power = 0
}
