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


categories = {};

function onInit()
	print("Ja");
	for k,v in pairs(getWindows()) do
	print("Eintrag:");
	if v.getDatabaseNode() then
		print(v.getDatabaseNode().getName());
	end
	end
end

function onListRearranged(listchanged)
	-- Close all category headings
	for k, v in pairs(categories) do
		v.window.close();
	end
	
	categories = {};

	-- Create new category headings
	for k, v in ipairs(getWindows()) do
		if v.getDatabaseNode() and v.getDatabaseNode().getChild("categoryname") then
			local categoryname = v.getDatabaseNode().getChild("categoryname").getValue();
	
			if not categories[categoryname] then
				-- Create category header
				local c = {};
				c.window = createWindowWithClass("library_booklistcategory");
				c.window.name.setValue(categoryname);
				
				categories[categoryname] = c;
			end
		end
	end
	
	applySort();
end

function onSortCompare(w1, w2)
	-- Get window properties
	local category1, category2;
	local iscategory1, iscategory2
	
	if w1.getClass() == "library_booklistentry" then
		if w1.getDatabaseNode() and w1.getDatabaseNode().getChild("categoryname") then
			category1 = w1.getDatabaseNode().getChild("categoryname").getValue();
		end
		iscategory1 = false;
	elseif w1.getClass() == "library_booklistcategory" then
		category1 = w1.name.getValue();
		iscategory1 = true;
	end
		
	if w2.getClass() == "library_booklistentry" then
		if w2.getDatabaseNode() and w2.getDatabaseNode().getChild("categoryname") then
			category2 = w2.getDatabaseNode().getChild("categoryname").getValue();
		end
		iscategory2 = false;
	elseif w2.getClass() == "library_booklistcategory" then
		category2 = w2.name.getValue();
		iscategory2 = true;
	end
	
	if category1 == category2 then
		if iscategory1 then
			return false;
		elseif iscategory2 then
			return true;
		else
			return w1.name.getValue() < w2.name.getValue();
		end
	else
		return category1 < category2;
	end
end