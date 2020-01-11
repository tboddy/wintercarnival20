local images, sounds, initX, initY, x, y, width, height, bulletWidth, bulletHeight, bulletSpeed, bullets, hitboxSize, invulnerableLimit, clock, canShoot, shotClock, lives, invulnerableClock, power

local function loadImages()
  images = {}
  local imageFiles = {'idle', 'hitbox', 'bullet-double', 'bullet-single', 'border'}
  for i = 1, #imageFiles do images[imageFiles[i]] = love.graphics.newImage('img/player/' .. imageFiles[i] .. '.png') end
  stg.loadImages(images)
end

local function load()
  loadImages()
  initX = stg.width / 2
  initY = stg.height - stg.grid * 2
  x = initX
  y = initY
  width = 28
  height = 34
  bulletWidth = 28
  bulletHeight = 8
  bulletSpeed = 28
  borderSize = 54
  bullets = {}
  for i = 1, 64 do bullets[i] = {} end
  hitboxSize = 8
  invulnerableLimit = 60 * 2.5
  clock = 0
  canShoot = true
  shotClock = 0
  lives = 2
  invulnerableClock = 0
  power = 0
end

local function updateMove()
  local speed = 2.75; if controls.focus() then speed = 1.5 end
  local xSpeed = 0; if controls.left() then xSpeed = -1 elseif controls.right() then xSpeed = 1 end
  local ySpeed = 0; if controls.up() then ySpeed = -1 elseif controls.down() then ySpeed = 1 end
  local fSpeed = speed / math.sqrt(math.max(xSpeed + ySpeed, 1))
  x = x + fSpeed * xSpeed
  y = y + fSpeed * ySpeed
  player.x = x
  player.y = y
  if x < hitboxSize / 2 then x = hitboxSize / 2 elseif x > stg.width - hitboxSize / 2 + 1 then x = stg.width - hitboxSize / 2 + 1 end
  if y < hitboxSize / 2 then y = hitboxSize / 2 elseif y > stg.height - hitboxSize / 2 + 1 then y = stg.height - hitboxSize / 2 + 1 end
end

local function spawnBullet(opts)
	local diff = math.pi / 8
  local bullet = bullets[stg.getIndex(bullets)]
  local offset = 4
	bullet.active = true
	bullet.angle = diff * opts.mod - math.pi / 2
  if opts.double then bullet.double = true else bullet.double = false end
  if opts.bottom then bullet.angle = bullet.angle + math.pi end
	bullet.x = x + math.cos(bullet.angle) * offset
	bullet.y = y + math.sin(bullet.angle) * offset
  local size = bulletHeight / 2; if bullet.double then size = size * 2 end
  -- bullet.collider = hc.circle(bullet.x, bullet.y, size)
  -- bullet.collider.type = 'playerBullet'
  if opts.bottom then bullet.y = bullet.y + 4 else bullet.y = bullet.y - 4 end
  local drunk = .025
  bullet.angle = bullet.angle - drunk + drunk * 2 * math.random()
end

local function updateBullet(bullet)
  local drunkMod = 8
	bullet.x = bullet.x + math.cos(bullet.angle) * bulletSpeed
	bullet.y = bullet.y + math.sin(bullet.angle) * bulletSpeed
	if bullet.x < -bulletWidth * 2 or bullet.x > stg.width + bulletWidth * 2 or bullet.y < -bulletHeight * 2 or bullet.y > stg.height + bulletHeight * 2 then bullet.active = false
  else
    local kill = false
    local size = bulletHeight / 2; if bullet.double then size = size * 2 end
    for i = 1, #stage.enemies do
      if stage.enemies[i].active and stage.enemies[i].seen then
        if math.sqrt((stage.enemies[i].x - bullet.x) * (stage.enemies[i].x - bullet.x) + (stage.enemies[i].y - bullet.y) * (stage.enemies[i].y - bullet.y)) < stage.enemies[i].height / 2 + size then
          stage.enemies[i].health = stage.enemies[i].health - 1
          kill = true
        end
      end
    end
    for i = 1, #stage.blocks do
      if stage.blocks[i].active and stage.blocks[i].seen then
        if math.sqrt((stage.blocks[i].x + 16 - bullet.x) * (stage.blocks[i].x + 16 - bullet.x) + (stage.blocks[i].y + 16 - bullet.y) * (stage.blocks[i].y + 16 - bullet.y)) < 16 + size then
          stage.blocks[i].health = stage.blocks[i].health - 1
          kill = true
        end
      end
    end
    if kill then
      explosion.spawn({x = bullet.x, y = bullet.y, type = 'gray'})
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
	if not canShoot and not stg.gameOver then
		if shotClock % interval == 0 and shotClock < limit then
      sound.sfx = 'playerbullet'
      spawnBullet({mod = 0, double = true})
      spawnBullet({mod = 1})
      spawnBullet({mod = -1})
      -- spawnBullet({mod = 1, bottom = true})
      -- spawnBullet({mod = -1, bottom = true})
    end
		shotClock = shotClock + 1
  end
	if shotClock >= max then canShoot = true end
  for i = 1, #bullets do if bullets[i].active then updateBullet(bullets[i]) end end
end

local function kill()
end

local function getHit(bullet)
  if invulnerableClock == 0 then
    stage.killBullets = true
    bullet.active = false
    local expObj = {x = x, y = y, big = true}
    if string.find(bullet.type, 'Red') then expObj.type = 'red' end
    explosion.spawn(expObj)
    if lives > 0 then
      lives = lives - 1
      invulnerableClock = invulnerableLimit
      x = initX
      y = initY
    end
    -- else stg.gameOver = true end
  end
end

local function update()
  if not stg.gameOver and invulnerableClock < invulnerableLimit - 20 then updateMove() end
  updateShot()
  if invulnerableClock > 0 then invulnerableClock = invulnerableClock - 1 end
  clock = clock + 1
  player.invulnerableClock = invulnerableClock
  player.lives = lives
end

local function drawBullet(bullet)
  local img = images['bullet-single']; if bullet.double then img = images['bullet-double'] end
  local size = bulletHeight; if bullet.double then size = size * 2 end
  love.graphics.draw(img, bullet.x, bullet.y, bullet.angle, 1, 1, bulletWidth / 2, size / 2)
end

local function drawPlayer()
  local canDraw = false
  local interval = 30
  if invulnerableClock % interval < interval / 2 then canDraw = true end
  if canDraw then
    love.graphics.draw(images.idle, x, y, 0, 1, 1, width / 2, height / 2)
    if controls.focus() then love.graphics.draw(images.hitbox, x, y, 0, 1, 1, hitboxSize / 2, hitboxSize / 2) end
  end
end

local function draw()
  -- if controls.focus() then
  --   love.graphics.setColor(stg.colors.red)
  --   love.graphics.draw(images.border, x - 1, y, 0, 1, 1, borderSize / 2, borderSize / 2)
  --   love.graphics.setColor(stg.colors.white)
  -- end
  stg.mask('half', function() for i = 1, #bullets do if bullets[i].active then drawBullet(bullets[i]) end end end)

  drawPlayer()
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
  lives = 0
}
