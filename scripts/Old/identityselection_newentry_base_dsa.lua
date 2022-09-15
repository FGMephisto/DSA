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

function onDoubleClick(x, y)
	if not User.isLocal() then
		User.requestIdentity(nil, "charsheet", "name", nil, window.requestResponse);
	else
		Interface.openWindow("charsheet", User.createLocalIdentity());
		window.windowlist.window.close();
	end
	return true;
end

function onClickDown(button, x, y)
	window.windowlist.clearSelection();
	setFrame("sheetfocus", -2, -2, -1, -1);
	return true;
end