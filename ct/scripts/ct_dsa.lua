function addNpc(source)
	local newentry = createWindow();

	--newentry.setType("npc");

	-- Name
	if source.getChild("name") then
		newentry.name.setValue(source.getChild("name").getValue());
	end
	
	return newentry;
end

function addPc(source, token)
	local newentry = createWindow();

	--newentry.setType("pc");

	-- Shortcut
	newentry.name.setReadOnly(true);
	newentry.name.setFrame(nil);

	--newentry.link.setValue("charsheet", source.getNodeName());
	--newentry.link.setVisible(true);

	-- Token
	if token then
	--	newentry.token.setPrototype(token);
	end

	-- FoF
	--newentry.friendfoe.setState("friend");

	-- Linked fields
	newentry.name.setLink(source.getChild("name"));	
	newentry.hp.setLink(source.getChild("lebensenergie.aktuell"));
end

function onDrop(x, y, draginfo)
	if draginfo.isType("playercharacter")  then
		local source = draginfo.getDatabaseNode();
		local token = draginfo.getTokenData();

		if source then
			local newentry = addPc(source, token);
		end

		return true;				
	elseif draginfo.isType("shortcut")  then
			local class, datasource = draginfo.getShortcutData();
			local source = draginfo.getDatabaseNode();
	
			if source and class == "npc" then
				local newentry = addNpc(source);
				--newentry.link.setValue(class, datasource);
				--newentry.link.setVisible(true);
			end
	
			return true;
	end
end

function onSortCompare(w1, w2)
	return w1.ini.getValue() < w2.ini.getValue();
end;