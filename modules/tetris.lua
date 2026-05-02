-- Pure Tetris game logic module
-- No GUI or engine dependencies

local M = {}

M.COLS = 10
M.ROWS = 20

local SHAPES = {
	I = {
		{{0,0}, {1,0}, {2,0}, {3,0}},
		{{2,0}, {2,1}, {2,2}, {2,3}},
		{{0,1}, {1,1}, {2,1}, {3,1}},
		{{1,0}, {1,1}, {1,2}, {1,3}},
	},
	O = {
		{{0,0}, {1,0}, {0,1}, {1,1}},
		{{0,0}, {1,0}, {0,1}, {1,1}},
		{{0,0}, {1,0}, {0,1}, {1,1}},
		{{0,0}, {1,0}, {0,1}, {1,1}},
	},
	T = {
		{{1,0}, {0,1}, {1,1}, {2,1}},
		{{1,0}, {1,1}, {2,1}, {1,2}},
		{{0,1}, {1,1}, {2,1}, {1,2}},
		{{1,0}, {0,1}, {1,1}, {1,2}},
	},
	S = {
		{{1,0}, {2,0}, {0,1}, {1,1}},
		{{1,0}, {1,1}, {2,1}, {2,2}},
		{{1,1}, {2,1}, {0,2}, {1,2}},
		{{0,0}, {0,1}, {1,1}, {1,2}},
	},
	Z = {
		{{0,0}, {1,0}, {1,1}, {2,1}},
		{{2,0}, {1,1}, {2,1}, {1,2}},
		{{0,1}, {1,1}, {1,2}, {2,2}},
		{{1,0}, {0,1}, {1,1}, {0,2}},
	},
	J = {
		{{0,0}, {0,1}, {1,1}, {2,1}},
		{{1,0}, {2,0}, {1,1}, {1,2}},
		{{0,1}, {1,1}, {2,1}, {2,2}},
		{{1,0}, {1,1}, {0,2}, {1,2}},
	},
	L = {
		{{2,0}, {0,1}, {1,1}, {2,1}},
		{{1,0}, {1,1}, {1,2}, {2,2}},
		{{0,1}, {1,1}, {2,1}, {0,2}},
		{{0,0}, {1,0}, {1,1}, {1,2}},
	},
}

local PIECE_KEYS = {"I", "O", "T", "S", "Z", "J", "L"}

-- Deep copy a table
local function copy(t)
	local u = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			u[k] = copy(v)
		else
			u[k] = v
		end
	end
	return u
end

function M.new_game(level_up_lines)
	local self = {}
	self.board = {}
	for i = 1, M.COLS * M.ROWS do
		self.board[i] = false
	end

	self.score = 0
	self.lines = 0
	self.level = 1
	self.level_up_lines = level_up_lines or 10
	self.game_over = false

	self.bag = {}
	function self.refill_bag()
		self.bag = {}
		for i = 1, 7 do
			self.bag[i] = PIECE_KEYS[i]
		end
		for i = #self.bag, 2, -1 do
			local j = math.random(i)
			self.bag[i], self.bag[j] = self.bag[j], self.bag[i]
		end
	end

	function self.draw_piece()
		if #self.bag == 0 then
			self:refill_bag()
		end
		return table.remove(self.bag)
	end

	self:refill_bag()
	self.current_piece_key = self:draw_piece()
	self.next_piece_key = self:draw_piece()

	setmetatable(self, {__index = M})
	self:spawn_piece()
	return self
end

function M.get_piece_cells(shape_key, rotation)
	return copy(SHAPES[shape_key][rotation])
end

function M.check_collision(game, col, row, shape_key, rotation)
	local cells = SHAPES[shape_key][rotation]
	for _, c in ipairs(cells) do
		local bc = col + c[1]
		local br = row + c[2]
		if bc < 0 or bc >= M.COLS or br < 0 then
			return true
		end
		if br < M.ROWS and game.board[bc + br * M.COLS + 1] then
			return true
		end
	end
	return false
end

function M.spawn_piece(game)
	local key = game.current_piece_key
	local spawn_col = 3
	local spawn_row = M.ROWS - 2

	while spawn_row < M.ROWS - 1 do
		if not M.check_collision(game, spawn_col, spawn_row, key, 1) then
			break
		end
		spawn_row = spawn_row + 1
	end

	game.current_piece = {
		col = spawn_col,
		row = spawn_row,
		rotation = 1,
		key = key,
	}

	if M.check_collision(game, game.current_piece.col, game.current_piece.row, key, 1) then
		game.game_over = true
	end
end

function M.get_ghost_row(game)
	local piece = game.current_piece
	local key = game.current_piece_key
	local rot = piece.rotation
	local ghost_row = piece.row

	while true do
		local test_row = ghost_row - 1
		if M.check_collision(game, piece.col, test_row, key, rot) then
			break
		end
		ghost_row = test_row
	end
	return ghost_row
end

function M.get_piece_absolute_cells(game)
	local piece = game.current_piece
	if not piece then return {} end
	local cells = SHAPES[piece.key][piece.rotation]
	local result = {}
	for i, c in ipairs(cells) do
		result[i] = {
			col = piece.col + c[1],
			row = piece.row + c[2],
		}
	end
	return result
end

function M.get_ghost_absolute_cells(game)
	local piece = game.current_piece
	if not piece then return {} end
	local ghost_row = M.get_ghost_row(game)
	local cells = SHAPES[piece.key][piece.rotation]
	local result = {}
	for i, c in ipairs(cells) do
		result[i] = {
			col = piece.col + c[1],
			row = ghost_row + c[2],
		}
	end
	return result
end

function M.get_next_piece_cells(game)
	local key = game.next_piece_key
	local cells = SHAPES[key][1]
	local min_col, min_row = 99, 99
	for _, c in ipairs(cells) do
		if c[1] < min_col then min_col = c[1] end
		if c[2] < min_row then min_row = c[2] end
	end
	local result = {}
	for i, c in ipairs(cells) do
		result[i] = {col = c[1] - min_col, row = c[2] - min_row}
	end
	return result
end

function M.move_piece(game, dx, dy)
	if game.game_over then return false end
	local piece = game.current_piece
	local new_col = piece.col + dx
	local new_row = piece.row + dy
	if M.check_collision(game, new_col, new_row, piece.key, piece.rotation) then
		return false
	end
	piece.col = new_col
	piece.row = new_row
	return true
end

function M.rotate_piece(game, clockwise)
	if game.game_over then return false end
	local piece = game.current_piece
	local new_rot = piece.rotation
	if clockwise then
		new_rot = new_rot - 1
		if new_rot < 1 then new_rot = 4 end
	else
		new_rot = new_rot + 1
		if new_rot > 4 then new_rot = 1 end
	end

	if not M.check_collision(game, piece.col, piece.row, piece.key, new_rot) then
		piece.rotation = new_rot
		return true
	end

	local kicks = {{1,0}, {-1,0}, {0,1}, {1,1}, {-1,1}}
	for _, k in ipairs(kicks) do
		if not M.check_collision(game, piece.col + k[1], piece.row + k[2], piece.key, new_rot) then
			piece.col = piece.col + k[1]
			piece.row = piece.row + k[2]
			piece.rotation = new_rot
			return true
		end
	end
	return false
end

function M.hard_drop(game)
	if game.game_over then return 0, {} end
	local piece = game.current_piece
	local start_row = piece.row
	while M.move_piece(game, 0, -1) do
	end
	local dropped = start_row - piece.row
	game.score = game.score + dropped * 2
	local cleared = M.lock_piece(game)
	return dropped, cleared
end

function M.lock_piece(game)
	local piece = game.current_piece
	local cells = SHAPES[piece.key][piece.rotation]

	local min_row = 99
	for _, c in ipairs(cells) do
		local br = piece.row + c[2]
		if br < min_row then min_row = br end
	end
	local placement_score = (M.ROWS - 1 - min_row) * 2
	game.score = game.score + placement_score

	for _, c in ipairs(cells) do
		local bc = piece.col + c[1]
		local br = piece.row + c[2]
		if br >= 0 and br < M.ROWS and bc >= 0 and bc < M.COLS then
			game.board[bc + br * M.COLS + 1] = true
		end
	end

	local cleared_rows = {}
	for r = 0, M.ROWS - 1 do
		local full = true
		for c = 0, M.COLS - 1 do
			if not game.board[c + r * M.COLS + 1] then
				full = false
				break
			end
		end
		if full then
			table.insert(cleared_rows, r)
		end
	end

	local num_cleared = #cleared_rows
	if num_cleared > 0 then
		-- Build a set of cleared row indices
		local is_cleared = {}
		for _, cr in ipairs(cleared_rows) do
			is_cleared[cr] = true
		end

		-- Compact: copy non-cleared rows to a new board, shifted down
		local new_board = {}
		for i = 1, M.COLS * M.ROWS do
			new_board[i] = false
		end

		local shift = 0
		for r = 0, M.ROWS - 1 do
			if is_cleared[r] then
				shift = shift + 1
			else
				local new_r = r - shift
				for c = 0, M.COLS - 1 do
					new_board[c + new_r * M.COLS + 1] = game.board[c + r * M.COLS + 1]
				end
			end
		end

		for i = 1, M.COLS * M.ROWS do
			game.board[i] = new_board[i]
		end

		local line_scores = {100, 250, 400, 600}
		game.score = game.score + line_scores[num_cleared] * game.level
		game.lines = game.lines + num_cleared

		if game.lines >= game.level * game.level_up_lines then
			game.level = math.floor(game.lines / game.level_up_lines) + 1
		end
	end

	game.current_piece_key = game.next_piece_key
	game.next_piece_key = game:draw_piece()
	game:spawn_piece()

	return cleared_rows
end

function M.drop_speed(game)
	local speed_per_row = 0.75 - (game.level - 1) * 0.08125
	if speed_per_row < 0.1 then speed_per_row = 0.1 end
	return speed_per_row
end

function M.can_spawn_next(game)
	return not game.game_over
end

return M
