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

function testProbe() 
	if string.len(getValue()) == 0 then
		return false;
	end
	if string.len(getValue()) ~= 8 then
		return false;
	end
	if not string.find(getValue(), "%a%a/%a%a/%a%a") then
		return false;
	end
	return true;
end

function getAttribut( probe, nummer )
	if not testProbe() then
		return "?";
	end

	local a = string.lower(string.sub(probe, 1,2));
	local b = string.lower(string.sub(probe, 4,5));
	local c = string.lower(string.sub(probe, 7,8));

	local e = a;
	if nummer == 2 then
		e = b;
	end
	if nummer == 3 then
		e = c;
	end

	local node = getDatabaseNode().getParent().getParent().getParent().getParent().getChild("attribute");

	if e == "mu" then
		return node.getChild("mut.aktuell").getValue();
	end					
	if e == "kl" then
		return node.getChild("klugheit.aktuell").getValue();
	end	
	if e == "in" then
		return node.getChild("intuition.aktuell").getValue();
	end	
	if e == "ch" then
		return node.getChild("charisma.aktuell").getValue();
	end	
	if e == "ff" then
		return node.getChild("fingerfertigkeit.aktuell").getValue();
	end	
	if e == "ge" then
		return node.getChild("gewandtheit.aktuell").getValue();
	end							
	if e == "ko" then
		return node.getChild("konstitution.aktuell").getValue();
	end	
	if e == "kk" then
		return node.getChild("koerperkraft.aktuell").getValue();
	end	
	return "?";						
end 

function onDrag(button, x, y, draginfo)					
	draginfo.setType("fullattack");
	draginfo.setDescription("desc");
	local p = getDatabaseNode().getValue();
	local msg = getDatabaseNode().getParent().getChild("label").getValue();
	msg = msg .. " 0 - ";
	msg = msg .. p;
	msg = msg .. " (";
	msg = msg .. getAttribut(p, 1) .. "/";
	msg = msg .. getAttribut(p, 2) .. "/";
	msg = msg .. getAttribut(p, 3);
	msg = msg .. ") ";
	draginfo.setStringData(msg);
	draginfo.setDieList({ "d20", "d20", "d20" });
	return true;
end	
