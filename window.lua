local Manager = {}

Manager.__index = Manager

function Manager:new(name)
	local self = setmetatable({}, Manager)
	self.name = name
	self.windows = {}
	return self
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
		hs.printf("Couldnt set window to half screen no windew")
		return
	end
	sides[side]()
end

local function openTerminal()
	local appName = "Terminal"
	local side = "right"
	hs.printf("opening terminal")
	hs.application.launchOrFocus("Terminal")
	hs.timer.doAfter(0.5, function()
		local app = hs.application.get(appName)
		if not app then
			hs.printf("couldnt find terminal after launch")
			return
		end
		local win = app:mainWindow()
		setToHalfScreen(win, side)
		self.windows["slot1"] = app:mainWindow()
		return app
	end)
end
function Manager:handleTerminal()
	local side = "right"
	--check for open terminal app
	local termApp = hs.application.find("Terminal")
	if not termApp then
		termApp = openTerminal()
	else
		hs.printf("found terminal app")
	end
	-- check if the manager has instance of the terminal
	if not self.windows["slot1"] then
		hs.printf("no terminal in the manager")
		self.windows["slot1"] = termApp:mainWindow()
	end
	local win = self.windows["slot1"]
	if win == hs.window.focusedWindow() then
		hs.printf("term is at the front")
		hs.printf("making bigger")
		if not win then
			hs.printf("couldnt get main window")
			return
		end
		win:setFullScreen(not win:isFullScreen())
	else
		hs.printf("terminal not in focus")
		win:focus()
		setToHalfScreen(win, side)
	end
end

function Manager:openChatGPT(identifier)
	--if not manager.windows[chatgpt]
	if not self.windows[identifier] then
		hs.printf("self windows identifier is")
		print(self.windows[identifier])
		hs.osascript.applescript([[
		tell application "Terminal"
			activate
			set newWin to(do script "echo -ne '\\033]0;tomstest\\a' && echo 'hello'")
			set frontmost to true
		end tell
	]])
		local term = hs.application.find("Terminal")
		local win = term:mainWindow()
		win:watchForEvents({
			hs.uielement.watcher.elementDesthroyed,
		}, function()
			self.windows[identifier] = nil
		end)
		self.windows[identifier] = win
	end
	return self.windows[identifier]
end
return Manager
