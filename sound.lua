local currentSound, sfxTypes, bgmTypes

local function load()
  sfxTypes = {'bullet1', 'bullet2', 'playerbullet', 'graze', 'release', 'bomb', 'startgame', 'changeselect', 'gameover'}
  bgmTypes = {'title', 'level1', 'level2', 'boss1', 'boss2'}
  for i = 1, #sfxTypes do
    sound.sfxFiles[sfxTypes[i]] = love.audio.newSource('sfx/' .. sfxTypes[i] .. '.wav', 'static')
    sound.sfxFiles[sfxTypes[i]]:setVolume(sound.sfxVolume)
  end
  for i = 1, #bgmTypes do
    sound.bgmFiles[bgmTypes[i]] = love.audio.newSource('bgm/' .. bgmTypes[i] .. '.mp3', 'static')
		sound.bgmFiles[bgmTypes[i]]:setVolume(sound.bgmVolume)
		sound.bgmFiles[bgmTypes[i]]:setLooping(true)
  end
end

local function updateSfx()
  if sound.sfx then
    for i = 1, #sfxTypes do if sound.sfxFiles[sfxTypes[i]]:isPlaying() then sound.sfxFiles[sfxTypes[i]]:stop() end end
    sound.sfxFiles[sound.sfx]:play()
    sound.sfx = false
  end
end

local function update()
  updateSfx()
end

return {
  load = load,
  update = update,
  sfxFiles = {},
  bgmFiles = {},
  sfx = false,
  bgm = false,
	sfxVolume = 0,
	bgmVolume = 0
}
