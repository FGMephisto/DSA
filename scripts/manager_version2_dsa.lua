-- 
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
-- File adjusted for Chronicle System
--

local rsname = "DSA.Legacy";
local rsmajorversion = 5;

-- ===================================================================================================================
-- ===================================================================================================================
function onInit()
	if Session.IsHost or Session.IsLocal then
		VersionManager2.updateCampaign();
	end

	DB.onAuxCharLoad = onCharImport;
	DB.onImport = onImport;
	Module.onModuleLoad = onModuleLoad;
end

-- ===================================================================================================================
-- ===================================================================================================================
function onCharImport(nodePC)
	local _, _, aMajor, _ = DB.getImportRulesetVersion();
	VersionManager2.updateChar(nodePC, aMajor[rsname]);
end

-- ===================================================================================================================
-- ===================================================================================================================
function onImport(node)
	local apath = StringManager.split(node.getPath(), ".");
	if #apath == 2 and apath[1] == "charsheet" then
		local _, _, aMajor, _ = DB.getImportRulesetVersion();
		VersionManager2.updateChar(node, aMajor[rsname]);
	end
end

-- ===================================================================================================================
-- ===================================================================================================================
function onModuleLoad(sModule)
	local _, _, aMajor, _ = DB.getRulesetVersion(sModule);
	VersionManager2.updateModule(sModule, aMajor[rsname]);
end

-- ===================================================================================================================
-- ===================================================================================================================
function updateCampaign()
	local _, _, aMajor, aMinor = DB.getRulesetVersion();
	local major = aMajor[rsname];

	if not major then
		return;
	end

	if major > 0 and major < rsmajorversion then
		print("Migrating campaign database to latest data version.");
		DB.backup();
		
		-- Check for campaign major version
		if major < 5 then
			for _, nodeChar in pairs (DB.getChildren("charsheet")) do
				VersionManager2.migrateChar5(nodeChar);
			end
		end
	end
end

-- ===================================================================================================================
-- ===================================================================================================================
function updateChar(nodePC, nVersion)
	if not nVersion then
		nVersion = 0;
	end

	if nVersion < rsmajorversion then
		if nVersion < 5 then
			VersionManager2.migrateChar5(nodePC);
		end
	end
end

-- ===================================================================================================================
-- ===================================================================================================================
function updateModule(sModule, nVersion)
	return;
end

-- ===================================================================================================================
-- ===================================================================================================================
function migrateChar5(nodeChar)
	local nodeInventoryListOld = DB.getPath(nodeChar, "inventoryliste")
	local nodeInventoryList = DB.createChild(nodeChar, "inventorylist")
	local nodeItemNew
	local sItemName

	-- Get the old item name and create an entry in the new inventory list
	for _, v in pairs (DB.getChildren(nodeInventoryListOld)) do
		sItemName = DB.getValue(v, "label")
		nodeItemNew = DB.createChild(nodeInventoryList)
		DB.setValue(nodeItemNew, "name", "string", sItemName)
	end

	-- Delete old data node
	DB.deleteChild(nodeChar, "inventoryliste");
end