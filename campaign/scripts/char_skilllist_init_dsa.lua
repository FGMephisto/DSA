function onInit() 
	local skilllist = getDatabaseNode().createChild("skilllist");
	local kampf = skilllist.createChild("kampf");
	initSkills(skillskampf, kampf);
	local koerper = skilllist.createChild("koerper");
	initSkills(skillskoerper, koerper);
	local gesellschaft = skilllist.createChild("gesellschaft");
	initSkills(skillsgesellschaft, gesellschaft);	
	local natur = skilllist.createChild("natur");
	initSkills(skillsnatur, natur);	
	local wissen = skilllist.createChild("wissen");
	initSkills(skillswissen, wissen);	
	local sprachen = skilllist.createChild("sprachen");
	initSkills(skillssprachen, sprachen);	
	local schriften = skilllist.createChild("schriften");
	initSkills(skillsschriften, schriften);
	local handwerk = skilllist.createChild("handwerk");
	initSkills(skillshandwerk, handwerk);	
	local sonstiges = skilllist.createChild("sonstiges");
	initSkills(skillssonstiges, sonstiges);	
	
end

function initSkills(table, node)
	local children = node.getChildren();
	for k,v in pairs(table) do
		if not children[k] then
			local n = node.createChild(k);
			n.createChild("label", "string").setValue(v["label"]);
			local p = v["probe"]
			if p then
				n.createChild("probe", "string").setValue(p);
			end
			local b = v["ebe"]
			if b then
				n.createChild("ebe", "string").setValue(b);
			end
			
		end
	end

end

skillskampf = {
	["Dolche"] = {
			label = "Dolche",
			ebe = "BE-1"
			},
	["Hiebwaffen"] = {
			label = "Hiebwaffen",
			ebe = "BE-4"
			},	
	["Raufen"] = {
			label = "Raufen",
			ebe = "BE"
			},		
	["Saebel"] = {
			label = "Saebel",
			ebe = "BE-2"
			},		
	["Wurfmesser"] = {
			label = "Wurfmesser",
			ebe = "BE-3"
			}			
	}

skillskoerper = {
	["Klettern"] = 	{
			label = "Klettern",
			probe = "MU/GE/KK",
			ebe = "BEx2"
			},
	["Koerperbeherrschung"] = 	{
			label = "Koerperbeherrschung",
			probe = "MU/IN/GE",
			ebe = "BEx2"
			},
	["Schleichen"] = 	{
			label = "Schleichen",
			probe = "MU/IN/GE",
			ebe = "BE"
			},
	["Schwimmen"] = 	{
			label = "Schwimmen",
			probe = "GE/KO/KK",
			ebe = "BEx2"
			},
	["Selbstbeherrschung"] = 	{
			label = "Selbstbeherrschung",
			probe = "MU/KO/KK",
			ebe = "-"
			},
	["SichVerstecken"] = 	{
			label = "Sich Verstecken",
			probe = "MU/IN/GE",
			ebe = "BE-2"
			},
	["Singen"] = 	{
			label = "Singen",
			probe = "IN/CH/KO",
			ebe = "BE-3"
			},
	["Sinnesschaerfe"] = 	{
			label = "Sinnesschaerfe",
			probe = "KL/IN/IN",
			ebe = "BE"
			},
	["Tanzen"] = 	{
			label = "Tanzen",
			probe = "CH/GE/GE",
			ebe = "BEx2"
			},
	["Zechen"] = 	{
			label = "Zechen",
			probe = "IN/KO/KK",
			ebe = "-"
			}			
	}
	
	
skillsgesellschaft = {
	["Menschenkenntnis"] = 	{
			label = "Menschenkenntnis",
			probe = "KL/IN/CH"
			},
	["Ueberreden"] = 	{
			label = "Ueberreden",
			probe = "MU/IN/CH"
			}		
	}

skillsnatur = {
	["Faehrtensuchen"] = 	{
			label = "Faehrtensuchen",
			probe ="KL/IN/KO"
			},
	["Orientierung"] = 	{
			label = "Orientierung",
			probe = "KL/IN/IN"
			},
	["Wildnisleben"] = 	{
			label = "Wildnisleben",
			probe = "IN/GE/KO"
			}
	}

skillswissen = {
	["GoetterKulte"] = 	{
			label = "Goetter/Kulte",
			probe ="KL/KL/IN"
			},
	["Rechnen"] = 	{
			label = "Rechnen",
			probe = "KL/KL/IN"
			},
	["SagenLegenden"] = 	{
			label = "Sagen/Legenden",
			probe = "KL/IN/CH"
			}
	}

skillssprachen = {
	["default"] = 	{
			label = ""
			}
	}

skillsschriften = {
	["default"] = 	{
			label = ""
			}
	}

skillshandwerk = {
	["HeilkundeWunden"] = 	{
			label = "Heilk. Wunden",
			probe = "KL/CH/FF"
			},
	["Holzbearbeitung"] = 	{
			label = "Holzbearbeitung",
			probe = "KL/FF/CH"
			},
	["Kochen"] = 	{
			label = "Kochen",
			probe = "KL/IN/FF"
			},
	["Lederarbeiten"] = 	{
			label = "Lederarbeiten",
			probe = "KL/FF/FF"
			},
	["MalenZeichnen"] = 	{
			label = "Malen/Zeichnen",
			probe = "KL/IN/FF"
			},
	["Schneidern"] = 	{
			label = "Schneidern",
			probe = "KL/FF/FF"
			}
			
	}

skillssonstiges = {
	["MetaKraeuter"] = 	{
			label = "Meta: Kraeuter suchen",
			probe = "MU/IN/FF"
			},
	["MetaNahrung"] = 	{
			label = "Meta: Nahrung sammeln",
			probe = "MU/IN/FF"
			},
	["MetaAnsitzjagd"] = 	{
			label = "Meta: Ansitzjagd",
			probe = "MU/IN/GE"
			},			
	["MetaPirschjagd"] = 	{
			label = "Meta: Pirschjagd",
			probe = "MU/IN/GE"
			}			
	}
	
