local function waveOne()
  local function circle(enemy)
    local angle = math.tau * math.random()
    local count = 15
    local function spawnBullets(fast)
      local function spawnBullet()
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.speed = 1.7 + math.random() * .05
          if fast then bullet.speed = bullet.speed + .6 end
          bullet.angle = angle
          bullet.type = 'big'
        end)
        angle = angle + math.tau / count
      end
      for i = 1, count do spawnBullet() end
    end
    spawnBullets()
    angle = angle + math.pi / count
    spawnBullets(true)
  end
  local function ray(enemy)
    local function spawnBullet()
      local mod = math.pi / 25
      local angle = stg.getAngle(enemy, player) - mod + mod * 2 * math.random()
      stage.spawnBullet(function(bullet)
        bullet.x = enemy.x
        bullet.y = enemy.y
        bullet.speed = 2 + math.random() * 1.25
        bullet.angle = angle
        bullet.top = true
        if math.random() < .5 then bullet.type = 'bigRed' else bullet.type = 'smallRed' end
      end)
    end
    for i = 1, 15 do spawnBullet() end
  end
  local function spawnEnemy(opposite1, opposite2, yOffset)
    stage.spawnEnemy(function(enemy)
      local offset1 = stg.grid * 3 - 2
      local offset2 = stg.grid * 3
      enemy.x = stg.width - offset1; if opposite2 then enemy.x = offset1 end
      enemy.y = -16 - yOffset * (stg.grid * 4)
      enemy.speed = 1.75
      enemy.angle = math.pi / 2
      enemy.type = 'fairygreen'; if opposite2 then enemy.type = 'fairyred' end
      if opposite1 then
        if opposite2 then enemy.x = enemy.x + offset2 else enemy.x = enemy.x - offset2 end
        enemy.y = enemy.y - stg.grid * 2
      end
      if opposite2 then enemy.flags.opposite = true end
      if opposite1 then enemy.flags.opposite2 = true end
    end, function(enemy)
      stg.slowEntity(enemy, .7, .025)
      local limit = 80
      local rayLimit = 30
      local mod = .0075
      if enemy.flags.opposite then mod = mod * -1 end
      if enemy.clock < limit then enemy.angle = enemy.angle + mod
      elseif enemy.clock >= limit and enemy.clock < limit * 2 then enemy.angle = enemy.angle - mod end
      if enemy.clock == 10 then
        if enemy.flags.opposite2 then ray(enemy) else circle(enemy) end
      end
    end)
  end
  local yOffset = 4.75
  local function spawnEnemies()
    for i = 0, 3 do
      spawnEnemy(false, false, i)
      spawnEnemy(true, false, i)
      spawnEnemy(false, true, i + yOffset)
      spawnEnemy(true, true, i + yOffset)
    end
  end
  local function spawnBlocks()
    stage.spawnBlock({x = 1, y = 0})
    stage.spawnBlock({x = 3, y = 0, type = 'power'})
    stage.spawnBlock({x = 2, y = 1})
    stage.spawnBlock({x = 4, y = 1})
    stage.spawnBlock({x = 1, y = 2})
    stage.spawnBlock({x = 3, y = 2})

    stage.spawnBlock({x = 4, y = yOffset, type = 'power'})
    stage.spawnBlock({x = 6, y = yOffset})
    stage.spawnBlock({x = 3, y = 1 + yOffset})
    stage.spawnBlock({x = 5, y = 1 + yOffset})
    stage.spawnBlock({x = 4, y = 2 + yOffset})
    stage.spawnBlock({x = 6, y = 2 + yOffset})
  end
  spawnEnemies()
  spawnBlocks()
  currentWave = waveTwo
end

local function waveTwo()
  local function spawnBullets(enemy, clockOffset, opposite)
    local angle = enemy.flags.angle
    local count = 7
    local function spawnBullet()
      stage.spawnBullet(function(bullet)
        bullet.x = enemy.flags.x
        bullet.y = enemy.flags.y
        bullet.speed = 1 + clockOffset * .075
        local angleMod = .005
        bullet.angle = angle - angleMod + angleMod * 2 * math.random()
        bullet.type = 'bigRed'
        bullet.flags.mod = .005
        if opposite then bullet.flags.mod = bullet.flags.mod * -1 end
      end, function(bullet)
        bullet.angle = bullet.angle + bullet.flags.mod
      end)
      angle = angle + math.tau / count
    end
    for i = 1, count do spawnBullet() end
  end
  local function spawnEnemy(yOffset, opposite)
    stage.spawnEnemy(function(enemy)
      enemy.x = stg.grid * 2.5 + math.random() * stg.grid
      enemy.y = -16 - yOffset * (stg.grid * 10)
      if opposite then enemy.x = enemy.x + stg.grid * 3.75 end
      enemy.angle = math.pi / 2
      enemy.type = 'russian'
      enemy.speed = 1.25
      enemy.flags.angle = 0
    end, function(enemy)
      local speedLimit = .5
      local clockLimit = 60
      stg.slowEntity(enemy, speedLimit, .015)
      if enemy.clock % clockLimit == clockLimit / 2 then
        enemy.flags.angle = enemy.flags.angle + math.pi / 2
        enemy.flags.x = enemy.x
        enemy.flags.y = enemy.y
      end
      if enemy.clock % clockLimit >= clockLimit / 2 and enemy.clock % 5 == 0 and enemy.clock > 0 and enemy.clock < clockLimit * 3 then
        spawnBullets(enemy, (enemy.clock % clockLimit - clockLimit / 2) / 5, enemy.clock % (clockLimit * 2) > clockLimit)
      end
    end)
  end
  local function spawnEnemies()
    for i = 0, 1 do
      spawnEnemy(i)
      spawnEnemy(i + .5, true)
    end
  end
  local function spawnBigEnemy()
    local function spawnBullets(enemy)
      local function spawnBullet(opposite)
        if opposite then angle = enemy.flags.angle else angle = enemy.flags.angle2 end
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.speed = 1
          bullet.angle = angle
          bullet.type = 'bolt'
        end)
        local mod = math.pi / 15
        if opposite then enemy.flags.angle = enemy.flags.angle + mod else enemy.flags.angle2 = enemy.flags.angle2 - mod end
      end
      spawnBullet()
      spawnBullet(true)
    end
    stage.spawnEnemy(function(enemy)
      enemy.x = stg.width - stg.grid * 3
      enemy.y = -stg.grid * 6
      enemy.angle =  math.pi / 2
      enemy.type = 'mule'
      enemy.speed = 2
      enemy.health = 5
      enemy.flags.angle = 0
    end, function(enemy)
      local speedLimit = .65
      if enemy.speed > speedLimit then
        enemy.speed = enemy.speed - .05
        enemy.clock = -1
      else
        if not enemy.flags.flipped then
          enemy.speed = speedLimit
          enemy.angle = stg.getAngle(enemy, player)
          enemy.flags.angle = enemy.angle
          enemy.flags.angle2 = enemy.angle
          enemy.flags.flipped = true
        end
        if enemy.clock % 2 == 0 then spawnBullets(enemy) end
      end
    end)
  end
  local function spawnBlocks()
    stage.spawnBlock({x = 5, y = 0})
    stage.spawnBlock({x = 6, y = 1})
    stage.spawnBlock({x = 5, y = 2})
  end
  spawnEnemies()
  -- spawnBigEnemy()
  -- spawnBlocks()
  currentWave = waveTwo
end

local function waveThree()
end

local function waveFour()
end

local function bossOne()
  local function spellOne(enemy)
    local function ring()
      local count = 90
      local mod = 13
      local function spawnBullets(opposite)
        local angle = enemy.flags.ringAngle
        local function spawnBullet()
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.speed = 1.8 + math.random() * .04
            bullet.angle = angle
            bullet.type = 'bigRed'
          end)
        end
        local diff = count / mod
        for i = 1, count do
          local limit = i % diff < diff / 2
          if opposite then limit = i % diff >= diff / 2 end
          if angle < enemy.flags.ringAngle + math.pi and limit then spawnBullet() end
          angle = angle + math.tau / count
        end
      end
      local interval = 30
      if enemy.clock % interval == 0 then
        if enemy.clock % interval == 0 then enemy.flags.ringAngle = 0 end
        spawnBullets(enemy.clock % (interval * 2) == interval)
      end
    end
    local function middle()
      local function spawnBullets(exp)
        local function spawnBullet(xOffset)
          local x = stg.width / 2 + stg.grid * xOffset
          local y = stg.grid * 4 - enemy.flags.yOffset * 6
          if exp then explosion.spawn({x = x, y = y}) end
          stage.spawnBullet(function(bullet)
            local mod = .03
            bullet.x = x
            bullet.y = y
            bullet.speed = 3.25
            bullet.angle = stg.getAngle({x = x, y = y}, enemy.flags.target) - mod + mod * 2 * math.random()
            bullet.type = 'bolt'
            bullet.top = true
          end)
        end
        spawnBullet(-1)
        spawnBullet(1)
      end
      local interval = 5
      local limit = 30
      local max = 55
      if not enemy.flags.yOffset then enemy.flags.yOffset = -1 end
      if enemy.clock % max == 0 then
        enemy.flags.target = {x = player.x, y = player.y}
        enemy.flags.yOffset = enemy.flags.yOffset + 1
        if enemy.flags.yOffset == 4 then enemy.flags.yOffset = 0 end
      end
      if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets(enemy.clock % (limit / 2) == 0) end
    end
    ring()
    middle()
  end
  local function spellTwo(enemy) end
  local function spellThree(enemy) end
  stage.spawnEnemy(function(enemy)
    enemy.x = stg.width / 2
    enemy.y = -84 / 2
    enemy.type = 'scorpion'
    enemy.speed = 2.9
    enemy.angle = math.pi / 2
    enemy.rotation = 0
    enemy.health = 150
    enemy.xScale = -1
    enemy.flags.rotateCount = 0
    enemy.flags.hitSpellTwo = false
    enemy.flags.hitSpellThree = false
  end, function(enemy)
    stg.slowEntity(enemy, 0, .05)
    if enemy.speed == 0 then
      local currentSpell = spellOne
      if enemy.health < enemy.maxHealth / 3 * 2 and enemy.health >= enemy.maxHealth / 3 then
        currentSpell = spellTwo
        if not enemy.flags.hitSpellTwo then
          enemy.flags.hitSpellTwo = true
          enemy.clock = -1
        end
      elseif enemy.health < enemy.maxHealth / 3 then
        currentSpell = spellThree
        if not enemy.flags.hitSpellThree then
          enemy.flags.hitSpellThree = true
          enemy.clock = -1
        end
      end
      currentSpell(enemy)
    else enemy.clock = -1 end
    enemy.rotation = math.sin(enemy.flags.rotateCount) / 60
    enemy.flags.rotateCount = enemy.flags.rotateCount + .01
  end)
end

local function waveFive()
end

local function bossTwo()
  local function spellOne(enemy)
    local function sides()
      local function spawnBullet(xOffset)
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x - stg.grid * 2.5 * xOffset
          bullet.y = enemy.y
          bullet.speed = 2.25 + math.random() / 2
          bullet.angle = math.tau * math.random()
          bullet.flags.limit = 1.5 + 1 * math.random()
          if math.random() < .5 then bullet.type = 'pill' else bullet.type = 'bolt' end
        end)
      end
      if enemy.clock % 30 == 0 then explosion.spawn({x = enemy.x - stg.grid * 2, y = enemy.y}) end
      if enemy.clock % 30 == 15 then explosion.spawn({x = enemy.x + stg.grid * 2, y = enemy.y}) end
      spawnBullet(-1)
      spawnBullet(1)
    end
    local function middle()
    --   const spawnBullets = () => {
    --     const angle = stg.getAngle({pos: r.Vector2(enemy.pos.x, enemy.flags.spellY)}, player), angleMod = .1
    --     spawnBullet = () => {
    --       stage.spawnBullet(bullet => {
    --         bullet.pos = r.Vector2(enemy.pos.x, enemy.flags.spellY)
    --         bullet.speed = 1.75 + Math.random()
    --         bullet.angle = angle - angleMod + angleMod * 2 * Math.random()
    --         bullet.type = Math.random() < .5 ? 'smallRed' : 'bigRed'
    --       })
    --     }
    --     for(j = 0; j < 16; j++) spawnBullet()
    --   }
    --   if(enemy.clock % 90 == 60){
    --     spawnBullets()
    --     explosion.spawn({x: enemy.pos.x, y: enemy.flags.spellY, red: true, big: true})
    --   }
    end
    sides()
    middle()
  end
  local function spellTwo(enemy) end
  local function spellThree(enemy) end
  stage.spawnEnemy(function(enemy)
    enemy.x = stg.width / 2
    enemy.y = -134 / 2
    enemy.type = 'keg'
    enemy.speed = 3.25
    enemy.angle = math.pi / 2
    enemy.rotation = 0
    enemy.health = 150
    enemy.xScale = 1
    enemy.flags.rotateCount = 0
    enemy.flags.hitSpellTwo = false
    enemy.flags.hitSpellThree = false
  end, function(enemy)
    stg.slowEntity(enemy, 0, .05)
    if enemy.speed == 0 then
      local currentSpell = spellOne
      if enemy.health < enemy.maxHealth / 3 * 2 and enemy.health >= enemy.maxHealth / 3 then
        currentSpell = spellTwo
        if not enemy.flags.hitSpellTwo then
          enemy.flags.hitSpellTwo = true
          enemy.clock = -1
        end
      elseif enemy.health < enemy.maxHealth / 3 then
        currentSpell = spellThree
        if not enemy.flags.hitSpellThree then
          enemy.flags.hitSpellThree = true
          enemy.clock = -1
        end
      end
      currentSpell(enemy)
    else enemy.clock = -1 end
    enemy.rotation = math.sin(enemy.flags.rotateCount) / 60
    enemy.flags.rotateCount = enemy.flags.rotateCount + .01
  end)
end

local currentWave = waveThree
local clock = 0
local waveClock = 0

local function update()
  if stage.enemyCount == 0 then
    if waveClock >= 10 then
      currentWave()
      clock = -1
      waveClock = 0
    else waveClock = waveClock + 1 end
  end
  clock = clock + 1
end

return {
  update = update
}
