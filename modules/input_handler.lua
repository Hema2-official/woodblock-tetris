-- Input handler module
-- Processes raw touch input into game actions: tap, swipe_left, swipe_right, swipe_down

local M = {}

function M.new(sensitivity)
	local self = {}
	self.sensitivity = sensitivity or 30
	self.touch_start = nil
	self.touch_time = 0

	function self:on_pressed(x, y)
		self.touch_start = {x = x, y = y}
		self.touch_time = socket.gettime()
	end

	function self:on_released(x, y)
		if not self.touch_start then return nil end
		
		local dx = x - self.touch_start.x
		local dy = y - self.touch_start.y
		local dist = math.sqrt(dx*dx + dy*dy)
		local duration = (socket.gettime() - self.touch_time) * 1000
		
		self.touch_start = nil
		
		-- Tap: short duration, small movement
		if duration < 250 and dist < self.sensitivity * 0.5 then
			return "tap"
		end
		
		-- Swipe: distance must exceed sensitivity
		if dist >= self.sensitivity then
			if math.abs(dx) > math.abs(dy) then
				-- Horizontal
				if dx > 0 then
					return "swipe_right"
				else
					return "swipe_left"
				end
			else
				-- Vertical
				if dy < 0 then
					return "swipe_down"
				else
					return "swipe_up"
				end
			end
		end
		
		return nil
	end

	return self
end

return M
