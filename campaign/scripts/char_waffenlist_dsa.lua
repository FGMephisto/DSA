function onInit() 
	local count = getDatabaseNode().getChildCount();
	if count == 0 then
		local default = getDatabaseNode().createChild("default");
	end
end
