-- https://www.youtube.com/watch?v=IWOhouJ7c04

local killBulletLimit = 60
local waveClock = 0
local nextWave

function waveOne()

  local patterns = {

    function(enemy)
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
                bullet.type = 'bolt'
              end)
            end
            angle = angle + math.tau / count
          end
          for i = 1, count do spawnBullet() end
        end
        local limit = 40
        if enemy.clock % limit <= 20 and enemy.clock % 4 == 0 then spawnBullets(enemy.clock % (limit * 2) >= limit) end
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
    end,

    function(enemy)
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
    end,

    function(enemy)
      local function bulletsA()
        local interval = 3
        local limit = interval * 10
        local max = interval * 20
        if enemy.clock % max == 0 then
          enemy.flags.bulletAngleA = math.tau * math.random()
          enemy.flags.bulletAngleB = math.tau * math.random()
        end
        local function spawnBullets(opposite)
          local count = 15
          local angle = enemy.flags.bulletAngleA
          local x = stg.width / 4
          if opposite then
            x = x * 3
            angle = enemy.flags.bulletAngleB
          end
          explosion.spawn({x = x, y = enemy.y, shadow = true})
          for i = 1, count do
            stage.spawnBullet(function(bullet)
              bullet.x = x
              bullet.y = enemy.y
              bullet.angle = angle
              bullet.speed = 4
              bullet.type = 'arrow'
              bullet.top = true
            end)
            angle = angle + math.tau / count
          end
          local mod = .025
          enemy.flags.bulletAngleB = enemy.flags.bulletAngleB + mod
          enemy.flags.bulletAngleA = enemy.flags.bulletAngleA - mod
        end
        if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets(enemy.clock % (max * 2) >= max) end
      end
      local function bulletsB()
        local interval = 3
        local limit = interval * 10
        local max = interval * 20
        if enemy.clock % max == limit then
          enemy.flags.bulletAngleC = math.tau * math.random()
          enemy.flags.bulletAngleD = math.tau * math.random()
        end
        local function spawnBullets(opposite)
          local count = 15
          local angle = enemy.flags.bulletAngleC
          local x = stg.width / 8 * 3
          if opposite then
            x = stg.width / 8 * 5
            angle = enemy.flags.bulletAngleD
          end
          explosion.spawn({x = x, y = enemy.y, type = 'red', shadow = true})
          for i = 1, count do
            stage.spawnBullet(function(bullet)
              bullet.x = x
              bullet.y = enemy.y
              bullet.angle = angle
              bullet.speed = 4.5
              bullet.type = 'arrowRed'
            end)
            angle = angle + math.tau / count
          end
          local mod = math.pi / 2 / count
          enemy.flags.bulletAngleC = enemy.flags.bulletAngleC + mod
          enemy.flags.bulletAngleD = enemy.flags.bulletAngleD - mod
        end
        if enemy.clock % interval == 0 and enemy.clock % max >= limit then spawnBullets(enemy.clock % (max * 2) >= limit + max) end
      end
      bulletsA()
      bulletsB()
    end,

    function(enemy)
      local function spawnBullets(opposite)
        local x = stg.width / 5 * 2
        local count = 25
        local angle = enemy.flags.bulletAngle
        if opposite then
          x = stg.width / 5 * 3
          angle = -angle
        end
        explosion.spawn({x = x, y = enemy.y, shadow = true})
        for i = 1, count do
          stage.spawnBullet(function(bullet)
            bullet.x = x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.speed = 4.5
            bullet.type = 'bolt'
          end)
          angle = angle + math.tau / count
        end
      end
      local interval = 5
      local limit = interval * 3
      local max = interval * 6
      if not enemy.flags.bulletAngle then enemy.flags.bulletAngle = math.pi / 2 end
      if enemy.clock % interval == 0 and enemy.clock % max < limit then
        spawnBullets()
        spawnBullets(true)
        enemy.flags.bulletAngle = enemy.flags.bulletAngle + .0125
      end
    end,

    function(enemy)
      local function spawnBullets()
        local count = 30
        local angle = enemy.flags.bulletAngle
        explosion.spawn({x = enemy.flags.bulletPos.x, y = enemy.flags.bulletPos.y, shadow = true, type = 'red'})
        for i = 0, count do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.flags.bulletPos.x
            bullet.y = enemy.flags.bulletPos.y
            bullet.angle = angle
            bullet.speed = 4
            bullet.type = 'arrowRed'
          end, function(bullet)
            if bullet.flags.flipped then
              bullet.speed = bullet.speed + .1
            else
              stg.slowEntity(bullet, 0, .125)
              if bullet.speed <= 0 then bullet.flags.flipped = true end
            end
          end)
          angle = angle + math.tau / count
        end
        local speed = 12
        enemy.flags.bulletPos.x = enemy.flags.bulletPos.x + math.cos(enemy.flags.bulletAngle) * speed
        enemy.flags.bulletPos.y = enemy.flags.bulletPos.y + math.sin(enemy.flags.bulletAngle) * speed
      end
      local function burst()
        for i = 1, 25 do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.top = true
            bullet.angle = math.pi * math.random()
            bullet.speed = 3.5 + math.random() * 2
            if math.random() < .5 then bullet.type = 'big' else bullet.type = 'small' end
            bullet.flags.minSpeed = bullet.speed - 2
          end, function(bullet)
            stg.slowEntity(bullet, bullet.flags.minSpeed, .05)
          end)
        end
      end
      local interval = 10
      local limit = interval * 5
      local max = limit * 3
      if enemy.clock % max == 0 then
        enemy.flags.bulletPos = {x = enemy.x, y = enemy.y}
        enemy.flags.bulletAngle = math.pi * math.random()
      end
      if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets() end
      if enemy.clock % max == limit * 2 then burst() end
    end,

    function(enemy)
      local function spawnBullets(opposite)
        local angle = enemy.flags.bulletAngle
        local count = 25
        local expObj = {x = enemy.flags.bulletPos.x, y = enemy.flags.bulletPos.y, shadow = true}
        if opposite then expObj.type = 'red' end
        explosion.spawn(expObj)
        for i = 1, count do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.flags.bulletPos.x
            bullet.y = enemy.flags.bulletPos.y
            bullet.angle = angle
            bullet.speed = 3
            bullet.type = 'big'
            if opposite then
              bullet.flags.opposite = true
              bullet.speed = 3.5
              bullet.type = 'bigRed'
              bullet.top = true
            end
          end, function(bullet)
            bullet.speed = bullet.speed - .125
            local mod = .015
            if bullet.flags.opposite then
              mod = mod * -1
            end
            bullet.angle = bullet.angle + mod
          end)
          angle = angle + math.tau / count
        end
        local speed = 12
        enemy.flags.bulletPos.x = enemy.flags.bulletPos.x + math.cos(enemy.flags.bulletTarget) * speed
        enemy.flags.bulletPos.y = enemy.flags.bulletPos.y + math.sin(enemy.flags.bulletTarget) * speed
      end
      local interval = 5
      local limit = interval * 10
      local max = interval * 12
      if enemy.clock % max == 0 then
        enemy.flags.bulletAngle = math.tau * math.random()
        enemy.flags.bulletPos = {x = stg.width / 5, y = stg.grid * 2}
        if enemy.clock % (max * 2) == max then enemy.flags.bulletPos.x = stg.width - enemy.flags.bulletPos.x end
        enemy.flags.bulletTarget = stg.getAngle(enemy.flags.bulletPos, {x = stg.width / 2, y = stg.height / 2})
      end
      if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets(enemy.clock % (max * 2) >= max) end
    end,

    function(enemy)
      local function sides()
        local function spawnBullets(opposite, second)
          local x = stg.width / 4
          local count = 3
          local mod = math.pi / 8
          local angle = math.pi / 2 - mod
          if second then
            count = 4
            angle = angle - mod / 2
          end
          if opposite then x = stg.width / 4 * 3 end
          explosion.spawn({x = x, y = enemy.y, type = 'red', shadow = 'true'})
          for i = 1, count do
            stage.spawnBullet(function(bullet)
              bullet.x = x
              bullet.y = enemy.y
              bullet.angle = angle
              bullet.speed = 5
              bullet.top = true
              bullet.type = 'arrowRed'
            end)
            angle = angle + mod
          end
        end
        local interval = 5
        local limit = interval * 3
        local max = limit * 2
        if enemy.clock % interval == 0 and enemy.clock % max < limit then
          spawnBullets(false, enemy.clock % (max * 2) >= limit)
          spawnBullets(true, enemy.clock % (max * 2) >= limit)
        end
      end
      local function spray()
        local function spawnBullet()
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = math.pi * math.random()
            bullet.speed = 3.5 + math.random() * 2
            if math.random() < .5 then bullet.type = 'big' else bullet.type = 'small' end
            bullet.flags.minSpeed = bullet.speed - 2
          end, function(bullet)
            stg.slowEntity(bullet, bullet.flags.minSpeed, .05)
          end)
        end
        if enemy.clock % 2 == 0 then spawnBullet() end
      end
      sides()
      spray()
    end,

    function(enemy)
    end

  }

  local function spawnEnemy()
    stage.spawnEnemy(function(enemy)
      enemy.type = 'fairyred'
      enemy.x = stg.width / 2
      enemy.y = -stage.images[enemy.type .. 'Center1']:getHeight() / 2
      enemy.speed = 1.1
      enemy.angle = math.pi / 2
      enemy.health = 250
      enemy.flags.initHealth = enemy.health
      enemy.flags.pattern = 1
    end, function(enemy)
      stg.slowEntity(enemy, 0, .013)
      if enemy.speed <= 0 then
        local pattern = 1
        for i = 1, #patterns do
          if enemy.health > enemy.flags.initHealth / #patterns * i then pattern = i end
        end
        pattern = #patterns - pattern
        if enemy.flags.pattern ~= pattern then
          enemy.flags.pattern = pattern
          enemy.clock = -1
        end
        patterns[pattern](enemy)
        -- patterns[7](enemy)
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