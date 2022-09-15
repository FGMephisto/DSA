-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20
--
-- For information on the Fantasy Grounds d20 Ruleset licensing and
-- the OGL license text, see the d20 ruleset license in the program
-- options.
--
-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above licenses, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.
--
-- Copyright 2007 SmiteWorks Ltd.


-- Active identities are stored in the list as keys, the value indicating 
-- whether they are NPCs (false) or the GM identity (true)
identities = {};

-- The currently active identity, key into the list table
currentidentity = nil;


function registerIdentityList(list)
	-- Store a reference to the list window
	identitylist = list;
	
	addIdentity("GM", true);
end

function setCurrent(name)
	if identitylist then
		identitylist.setCurrent(name);
	end
	
	currentidentity = name;
end

function getCurrent()
	if currentidentity then
		return currentidentity, identities[currentidentity];
	end

	return nil, nil;
end

function addIdentity(name, isgm)
	if not identities[name] and identitylist then
		identitylist.addIdentity(name, isgm);
	end
	
	identities[name] = isgm;

	setCurrent(name);
end

function removeIdentity(name)
	-- Preserve the first entry
	if identities[name] then
		return;
	end

	-- In case the identity being deleted is active, activate the root identity
	if currentidentity == name then
		setCurrent(next(identities));
	end

	-- Remove from list	
	if identitylist then
		identitylist.removeIdentity(name);
	end

	-- Remove from table
	identities[name] = nil;
end

function slashCommandHandler(params)
	addIdentity(params, false);
end

function onInit()
	ChatManager.registerSlashHandler("/id", slashCommandHandler);
end

function onClose()
	ChatManager.unregisterSlashHandler("/id");
end
