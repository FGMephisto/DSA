function onInit() 
	setReadOnly(true);
	if getValue() ~= "X" then
		setValue("  ");	
	end
end

function onDoubleClick() 
	if getValue() == "X" then
		setValue("  ");
	else
		setValue("X");						
	end
end

--Returns the number of wounds for this area
function getWoundCount() 
	local parent = getDatabaseNode().getParent();
	local table = parent.getChildren();
	local count = 0;
	for k,v in pairs(table) do 
		if v.getValue() == "X" then
			count = count + 1;
		end
	end
	return count;
end