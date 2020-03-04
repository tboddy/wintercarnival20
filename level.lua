-- https://www.youtube.com/watch?v=IWOhouJ7c04

local killBulletLimit = 60
local waveClock = 0
local nextWave

function waveOne()

  local function patternOne(enemy)
    local function lasers()
      local function spawnBullets(opposite)
        local count = 25
        local angle = 0
        if opposite then angle = angle + math.pi / count end
        local function spawnBullet()
          if angle < math.pi then
            stage.spawnBullet(function(bullet)
              bullet.x = enemy.x
              bullet.y = enemy.y
              bullet.angle = angle
              bullet.speed = 7
              bullet.type = 'pill'
            end)
          end
          angle = angle + math.tau / count
        end
        for i = 1, count do spawnBullet() end
      end
      local limit = 40
      if enemy.clock % limit <= 20 and enemy.clock % 2 == 0 then spawnBullets(enemy.clock % (limit * 2) >= limit) end
    end
    local function spray()
      local function spawnBullets()
        local count = 15
        local mod = math.pi / 3
        angle = math.pi / 2 - mod
        local function spawnBullet()
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle + (mod * 2) * math.random()
            bullet.speed = 2.5 + math.random() * 1.5
            bullet.type = 'bigRed'; if math.random() < .5 then bullet.type = 'smallRed' end
            bullet.top = true
          end)
        end
        for i = 1, count do spawnBullet() end
      end
      local interval = 30
      if enemy.clock % interval == 0 then spawnBullets() end
    end
    lasers()
    spray()
  end

  local function patternTwo(enemy)
    if not enemy.flags.ringAngleA then
      enemy.flags.ringAngleA = math.pi * 1.5
      enemy.flags.ringAngleB = math.pi * 1.5
    end
    local function spawnBullets(opposite) 
      local count = 15
      local angle = enemy.flags.ringAngleA; if opposite then angle = enemy.flags.ringAngleB end
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = angle
          bullet.speed = 3.25
          bullet.type = 'small'
          if opposite then
            bullet.type = 'bigRed'
            bullet.top = true
          end
        end)
        angle = angle + math.tau / count
      end
    end
    local interval = 5
    local limit = interval * 10
    local max = limit * 2
    if enemy.clock % interval == 0 then
      spawnBullets()
      if enemy.clock % (interval * 2) == 0 then spawnBullets(true) end
      local mod = .05
      if enemy.clock % max >= limit then mod = mod * -1  end
      enemy.flags.ringAngleA = enemy.flags.ringAngleA + mod
      enemy.flags.ringAngleB = enemy.flags.ringAngleB - mod
    end
  end

  local function spawnEnemy()
    stage.spawnEnemy(function(enemy)
      enemy.type = 'fairyred'
      enemy.x = stg.width / 2
      enemy.y = -stage.images[enemy.type .. 'Center1']:getHeight() / 2
      enemy.speed = 1.1
      enemy.angle = math.pi / 2
      enemy.health = 1000
    end, function(enemy)
      stg.slowEntity(enemy, 0, .013)
      if enemy.speed <= 0 then
        local interval = 60 * 6
        local min = interval - 60
        local max = interval * 2
        if enemy.clock % interval < min then
          if enemy.clock % max < interval then patternOne(enemy)
          else patternTwo(enemy) end
        end
      else enemy.clock = -1 end
    end)
  end
  spawnEnemy()
  nextWave = waveOne
end

local currentWave = waveOne

local function update()
  if stage.enemyCount == 0 then
    if waveClock >= 10 then
      currentWave()
      currentWave = nextWave
      waveClock = 0
    else waveClock = waveClock + 1 end
  end
end

return {
  update = update
}