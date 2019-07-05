local _, core = ...;
local _G = _G;
local MonDKP = core.MonDKP;

--------------------------------------
-- Slash Command
--------------------------------------
MonDKP.Commands = {
	["config"] = MonDKP.Toggle,
	["reset"] = MonDKP.ResetPosition,
	["help"] = function()
		print(" ");
		MonDKP:Print("List of slash commands:")
		MonDKP:Print("|cff00cc66/dkp|r - Launches DKP Window");
		MonDKP:Print("|cff00cc66/dkp ?|r - Shows Help Info");
		MonDKP:Print("|cff00cc66/dkp reset|r - Resets DKP Window Position/Size");
		print(" ");
	end,
	["bid"] = {
		["start"] = function() print("bidding started") end,	-- place holders to launch bidding windows 

		["stop"] = function() print("bidding stopped") end,

	},
};

local function HandleSlashCommands(str)	
	if (#str == 0) then
		MonDKP.Commands.config();
		return;		
	end	
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = MonDKP.Commands;
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg];
				end
			else
				MonDKP.Commands.help();
				return;
			end
		end
	end
end

function MonDKP:OnInitialize(event, name)		-- This is the FIRST function to run on load triggered by last 3 lines of this file
	if (name ~= "MonolithDKP") then return end 

	-- allows using left and right buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end
	
	----------------------------------
	-- Register Slash Commands!
	----------------------------------
	SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
	SlashCmdList.RELOADUI = ReloadUI;

	SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

	SLASH_MonolithDKP1 = "/dkp";
	SlashCmdList.MonolithDKP = HandleSlashCommands;
	
    MonDKP:Print("Welcome back, ", UnitName("player").."!");

    if(event == "ADDON_LOADED") then
    	core.loaded = 1;
		if (MonDKP_Log == nil) then MonDKP_Log = {} end;
		if (MonDKP_DKPTable == nil) then MonDKP_DKPTable = {} end;
		if (MonDKP_Tables == nil) then MonDKP_Tables = {} end;
		if (MonDKP_Loot == nil) then MonDKP_Loot = {} end;
	    if (MonDKP_DB == nil) then 
	    	MonDKP_DB = {
	    		DKPBonus = { OnTimeBonus = 15, BossKillBonus = 5, CompletionBonus = 10, NewBossKillBonus = 10, UnexcusedAbsence = -25},
	    	} 
	    end;

	    ------------------------------------
	    --	Import SavedVariables
	    ------------------------------------
	    core.settings = MonDKP_DB
	    core.WorkingTable = MonDKP_DKPTable;

		-- Populates SavedVariable MonDKP_DKPTable with fake values for testing purposes if they don't already exist
		-- Delete this section and \WTF\AccountACCOUNT_NAME\SavedVariables\MonolithDKP.lua prior to actual use.
		--[[local player_names = {"Qulyolalima", "Cadhangwong", "Gilingerth", "Emondeatt", "Puthuguth", "Eminin", "Mormiannis", "Hemilionter", "Malcologan", "Alerahm", "Cricordinus", "Arommoth", "Barnamnon", "Eughtor", "Aldreavus", "Loylencel", "Barredgar", "Gerneheav", "Julivente", "Barlannel", "Audeacell", "Derneth", "Fredeond", "Gutrichas", "Wiliannel", "Siertlan", "Simitram", "Ronettius", "Livendley", "Mordannichas", "Tevistavus", "Jaspian"}
		local classes = { "Druid", "Hunter", "Mage", "Priest", "Rogue", "Shaman", "Warlock", "Warrior" }

		for i=1, #player_names do
			local p = player_names[i]
			if (MonDKP:Table_Search(MonDKP_DKPTable, p) == false) then 		--
				tinsert(MonDKP_DKPTable, {
					player=p,
					class=classes[math.random(1, #classes)],
					previous_dkp=math.random(1000),
					dkp=math.random(0, 1000)
				})
			end
		end --]]
		-- End testing DB

		MonDKP:Print("Loaded "..#MonDKP_DKPTable.." records.");
		core.MonDKPUI = MonDKP.UIConfig or MonDKP:CreateMenu();
	end
end

----------------------------------
-- Initiallize Addon/SavedVariables
----------------------------------

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", MonDKP.OnInitialize); -- calls the above core:init function after addon_loaded event fires identifying the addon and SavedVariables are completely loaded
