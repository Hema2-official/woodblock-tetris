-- Settings and persistence module
-- Handles save/load of settings and high score

local M = {}

local SAVE_FILE = "blockwood_settings"

-- Default settings
local defaults = {
	ghost_piece = true,
	level_up_lines = 10,             -- lines cleared to level up
	swipe_sensitivity = 30,          -- pixels threshold
	high_score = 0,
}

local current = {}

function M.load()
	local data = sys.load(sys.get_save_file("blockwood", SAVE_FILE))
	if data then
		for k, v in pairs(defaults) do
			current[k] = data[k] ~= nil and data[k] or v
		end
	else
		for k, v in pairs(defaults) do
			current[k] = v
		end
	end
end

function M.save()
	sys.save(sys.get_save_file("blockwood", SAVE_FILE), current)
end

function M.get(key)
	return current[key]
end

function M.set(key, value)
	current[key] = value
	M.save()
end

function M.get_high_score()
	return current.high_score
end

function M.set_high_score(score)
	if score > current.high_score then
		current.high_score = score
		M.save()
	end
end

function M.reset_high_score()
	current.high_score = 0
	M.save()
end

function M.reset_all()
	for k, v in pairs(defaults) do
		current[k] = v
	end
	M.save()
end

-- Ensure loaded on module require
M.load()

return M
