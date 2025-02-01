--[[
--Todo
--	have key binds that asign the top window to that key or if there isnt anything asigned then default to a predefined program
--	have keys for:
-- 	alt +
--		i	blank
--		u	terminal
--			terminal2
--		e	chatgpt
--		o	browser
--		a	blank
--	
--	have key bind to clear selection
--	persistence between sessions
--	maybe a set for each workspace?
--	
--	key to cycle the above windows in a tiled layout
--	have each window remember its position
--	key cycle window through potential positions eg left right up down quater left up, right up, bottom left, bottom right
--]]
--
--

--	have key binds that asign the top window to that key or if there isnt anything asigned then default to a predefined program
--	have keys for:
--	alt +
local Manager = require("window")
myManager = Manager.new("tomsManager")
local function focusBrave()
	if brave then
		-- brave exists
		-- focus on toggle fullscreen
		if brave:isFrontmost() then
			hs.printf("brave is at the front")
			hs.printf("making bigger")
			local win = brave:mainWindow()
			if not win then
				hs.printf("couldnt get main window")
				return
			end
			win:setFullScreen(not win:isFullScreen())
		else
			hs.printf("brave not in focus")
			launchOrFocusAndResize("Brave Browser", "left")
		end
	end
end

--		i	blank
--		u	terminal
hs.application.enableSpotlightForNameSearches(true)
hs.hotkey.bind({ "ctrl", "shift" }, "R", function()
	hs.alert.show("Config reloaded!")
	hs.reload()
end)

-- function toggleTerminal()
-- 	hs.alert.show("inside toggle terminal")
-- 	local terminalApp = "terminal"
-- 	local app = hs.appfinder.appFromName(terminalApp)
-- 	if not app then
-- 		hs.application.launchOrFocus(terminalApp)
-- 	end
-- end
function tableToString(t)
	local result = "{"
	for k, v in pairs(t) do
		-- Format keys and values
		local key = '"' .. k .. '"'
		local value = type(v)
		if type(v) == "string" or type(v) == "int" then
			value = '"' .. v .. '"'
		end
		if type(v) == "table" then
			value = '"' .. tableToString(v) .. '"'
			result = result .. "[" .. key .. "]=" .. value .. ", "
		end
		hs.printf("table is ")
		hs.printf(result)
	end
	return result:sub(1, -3) .. "}" -- Remove the trailing comma and space
end

function showAllWindows()
	local windows = hs.window.allWindows()
	local titles = {}
	for _, window in ipairs(windows) do
		table.insert(titles, window:title())
	end
	for _, title in ipairs(titles) do
		print(title)
	end
end
local function setToHalfScreen(win, side)
	local sides = {
		right = function()
			win:moveToUnit(hs.layout.right50)
		end,
		left = function()
			win:moveToUnit(hs.layout.left50)
		end,
	}
	if not win then
		hs.printf("Couldnt se window to half screen no windew")
		return
	end
	sides[side]()
end
local function launchOrFocusAndResize(win, side)
	win:focus()
	hs.timer.doAfter(0.5, function()
		local app = hs.application.get(appName)
		if not app then
			hs.printf("couldnt find app after launch")
			return
		end
		local win = app:mainWindow()
		setToHalfScreen(win, side)
	end)
end
function openTerminal()
	-- check if the terminal is open at all
	local term = hs.application.find("Terminal")
	if not term then
		hs.printf("terminal isnt open")
		term = launchOrFocusAndResize("Terminal", "right")
		return
	end
	if term:isFrontmost() then
		hs.printf("term is at the front")
		hs.printf("making bigger")
		local win = term:mainWindow()
		if not win then
			hs.printf("couldnt get main window")
			return
		end
		win:setFullScreen(not win:isFullScreen())
	else
		hs.printf("terminal not in focus")
		launchOrFocusAndResize("Terminal", "right")
	end
end
function openWebSite()
	local url = "https://chatgpt.com/c/675bfdfc-2f28-8002-9047-756e01e3aa69"
	hs.osascript.applescript([[
		tell application "Brave Browser"
			make new window
			set URL of active tab of front window to "]] .. url .. [["
			activate
			end tell
	]])
end
function openChatGPT(command, identifier)
	--if not manager.windows[chatgpt]
	hs.osascript.applescript([[
		tell application "Terminal"
			activate
			set newWin to(do script "echo -ne '\\033]0;tomstest\\a' && echo 'hello'")
			set frontmost to true
		end tell
	]])
	local term = hs.application.find("Terminal")
	local win = term:mainWindow()
	return win
end
function testWrapper()
	myManager:getWindow("hop")
end
function openBraveChatGpt()
	local brave = hs.application.find("Brave Browser")
	if not brave then
		hs.printf("brave isnt open")
		openChatGPT()
		return
	end
	local windows = brave:allWindows()
	for _, win in ipairs(windows) do
		if win:title() then
			hs.printf(win:title())
		else
			hs.printf("couldnt find window title")
		end
	end
end
function openBrave()
	-- check if the terminal is open at all
	local term = hs.application.find("Brave Browser")
	if not term then
		hs.printf("terminal isnt open")
		term = launchOrFocusAndResize("Brave Browser", "left")
		return
	end
	if term:isFrontmost() then
		hs.printf("term is at the front")
		hs.printf("making bigger")
		local win = term:mainWindow()
		if not win then
			hs.printf("couldnt get main window")
			return
		end
		win:setFullScreen(not win:isFullScreen())
	else
		hs.printf("terminal not in focus")
		launchOrFocusAndResize("Brave Browser", "left")
	end
end

function test()
	local brave = hs.application.find("Brave Browser")
	if not brave then
		hs.printf("brave isnt open")
		openChatGPT()
		return
	end
	local windows = brave:allWindows()
	for _, win in ipairs(windows) do
		if win:title() then
			hs.printf(win:title())
		else
			hs.printf("couldnt find window title")
		end
	end
end

hs.hotkey.bind({ "ctrl", "shift" }, "H", openTerminal)
hs.hotkey.bind({ "ctrl", "shift" }, "T", focusBrave)
hs.hotkey.bind({ "ctrl", "shift" }, "N", openChatGPT)
--hs.hotkey.bind({ "ctrl", "shift" }, "S", function()
--	myManager:handleTerminal()
--end)
hs.hotkey.bind({ "ctrl", "shift" }, "S", function()
	testWrapper()
end)
