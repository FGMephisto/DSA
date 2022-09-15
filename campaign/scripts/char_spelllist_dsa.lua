function onInit() 
	local spelllist = getDatabaseNode().createChild("spelllist");	
	local count = spelllist.getChildCount();
	if count == 0 then
		local default = spelllist.createChild("default");
	end
	
end

function onSortCompare(w1, w2)
	return w1.label.getValue() > w2.label.getValue();
end;