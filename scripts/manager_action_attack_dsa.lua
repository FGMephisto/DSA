-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

OOB_MSGTYPE_APPLYATK = "applyatk";
OOB_MSGTYPE_APPLYHRFC = "applyhrfc";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATK, handleApplyAttack);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYHRFC, handleApplyHRFC);

	ActionsManager.registerTargetingHandler("attack", onTargeting);

	ActionsManager.registerModHandler("attack", modAttack);
	ActionsManager.registerModHandler("grapple", modAttack);
	
	ActionsManager.registerResultHandler("attack", onAttack);
	ActionsManager.registerResultHandler("critconfirm", onAttack);
	ActionsManager.registerResultHandler("misschance", onMissChance);
	ActionsManager.registerResultHandler("grapple", onGrapple);
end

function handleApplyAttack(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	
	local nTotal = tonumber(msgOOB.nTotal) or 0;
	applyAttack(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sAttackType, msgOOB.sDesc, nTotal, msgOOB.sResults);
end

function notifyApplyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	if not rTarget then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYATK;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sAttackType = sAttackType;
	msgOOB.nTotal = nTotal;
	msgOOB.sDesc = sDesc;
	msgOOB.sResults = sResults;

	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);
	msgOOB.sTargetNode = ActorManager.getCreatureNodeName(rTarget);

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyHRFC(msgOOB)
	TableManager.processTableRoll("", msgOOB.sTable);
end

function notifyApplyHRFC(sTable)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYHRFC;
	
	msgOOB.sTable = sTable;

	Comm.deliverOOBMessage(msgOOB, "");
end

function onTargeting(rSource, aTargeting, rRolls)
	if OptionsManager.isOption("RMMT", "multi") then
		local aTargets = {};
		for _,vTargetGroup in ipairs(aTargeting) do
			for _,vTarget in ipairs(vTargetGroup) do
				table.insert(aTargets, vTarget);
			end
		end
		if #aTargets > 1 then
			for _,vRoll in ipairs(rRolls) do
				if not string.match(vRoll.sDesc, "%[FULL%]") then
					vRoll.bRemoveOnMiss = "true";
				end
			end
		end
	end
	return aTargeting;
end

function performPartySheetVsRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(nil, rAction);
	
	if DB.getValue("partysheet.hiderollresults", 0) == 1 then
		rRoll.bSecret = true;
		rRoll.bTower = true;
	end
	
	ActionsManager.actionDirect(nil, "attack", { rRoll }, { { rActor } });
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
	local rRoll = {};
	if rAction.cm then
		rRoll.sType = "grapple";
	else
		rRoll.sType = "attack";
	end
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.modifier or 0;
	
	if rAction.cm then
		rRoll.sDesc = "[CMB";
		if rAction.order and rAction.order > 1 then
			rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
		end
		rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	else
		rRoll.sDesc = "[ATTACK";
		if rAction.order and rAction.order > 1 then
			rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
		end
		if rAction.range then
			rRoll.sDesc = rRoll.sDesc .. " (" .. rAction.range .. ")";
		end
		rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	end
	
	-- Add ability modifiers
	if rAction.stat then
		if (rAction.range == "M" and rAction.stat ~= "strength") or (rAction.range == "R" and rAction.stat ~= "dexterity") then
			local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
	end
	
	-- Add other modifiers
	if rAction.crit and rAction.crit < 20 then
		rRoll.sDesc = rRoll.sDesc .. " [CRIT " .. rAction.crit .. "]";
	end
	if rAction.touch then
		rRoll.sDesc = rRoll.sDesc .. " [TOUCH]";
	end
	
	return rRoll;
end

function performGrappleRoll(draginfo, rActor, rAction)
	local rRoll = getGrappleRoll(rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getGrappleRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "grapple";
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.modifier or 0;
	
	if DataCommon.isPFRPG() then
		rRoll.sDesc = "[CMB]";
	else
		rRoll.sDesc = "[GRAPPLE]";
	end
	if rAction.label and rAction.label ~= "" then
		rRoll.sDesc = rRoll.sDesc .. " " .. rAction.label;
	end
	
	-- Add ability modifiers
	if rAction.stat then
		if rAction.stat ~= "strength" then
			local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
	end
	
	return rRoll;
end

function modAttack(rSource, rTarget, rRoll)
	clearCritState(rSource);
	
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;

	-- Check for opportunity attack
	local bOpportunity = ModifierManager.getKey("ATT_OPP") or Input.isShiftPressed();

	-- Check attack modifiers
	local bMultifire = ModifierManager.getKey("ATT_MFI");
	local bAutofire = ModifierManager.getKey("ATT_AFI");
	local bMultiShot = ModifierManager.getKey("ATT_MSO");
	local bRapidShot = ModifierManager.getKey("ATT_RSO");
	local bPointBlank = ModifierManager.getKey("ATT_PBL");
	local bFireintoMelee = ModifierManager.getKey("ATT_ITM");
	local bFlanking = ModifierManager.getKey("ATT_FLA");
	local bHigherGround = ModifierManager.getKey("ATT_HGR");	
	local bAProne = ModifierManager.getKey("ATT_PRO");
	local bAConceal = ModifierManager.getKey("ATT_CONC");	

	-- Check defense modifiers
	local bTouch = ModifierManager.getKey("ATT_TCH");
	local bFlatFooted = ModifierManager.getKey("ATT_FF");

	local bMinimumCover = ModifierManager.getKey("DEF_MCOVER");
	local bPartialCover = ModifierManager.getKey("DEF_PCOVER");
	local bCover = ModifierManager.getKey("DEF_COVER");
	local bSuperiorCover = ModifierManager.getKey("DEF_SCOVER");

	local bTotalDefense = ModifierManager.getKey("DEF_TDEF");
	local bDodging = ModifierManager.getKey("DEF_DOD");
	local bKneeling = ModifierManager.getKey("DEF_KNE");
	local bProne = ModifierManager.getKey("DEF_PRO");
	local bRunning = ModifierManager.getKey("DEF_RUN");
	local bPinned = ModifierManager.getKey("DEF_PIN");

	local bMinimumConceal = ModifierManager.getKey("DEF_MCONC");
	local bPartialConceal = ModifierManager.getKey("DEF_PCONC");
	local bConceal = ModifierManager.getKey("DEF_CONC");
	local bSuperiosConceal = ModifierManager.getKey("DEF_SCONC");
	local bTotalConceal = ModifierManager.getKey("DEF_TCONC");

	-- Add attack modifiers and adjust attack roll string
	if bOpportunity then
		table.insert(aAddDesc, "[OPPORTUNITY]");
	end

	if bMultifire then
		table.insert(aAddDesc, "[Multifire]");
		nAddMod = nAddMod - 4;
	end

	if bAutofire then
		table.insert(aAddDesc, "[Autofire]");
		nAddMod = nAddMod - 6;
	end
	
	if bMultiShot then
		table.insert(aAddDesc, "[MultiShot]");
		nAddMod = nAddMod + 2;
	end

	if bRapidShot then
		table.insert(aAddDesc, "[Rapid Shot]");
		nAddMod = nAddMod - 2;
	end

	if bPointBlank then
		table.insert(aAddDesc, "[Point Blank]");
		nAddMod = nAddMod + 1;
	end

	if bFireintoMelee then
		table.insert(aAddDesc, "[Fire into Melee]");
		nAddMod = nAddMod - 4;
	end

	if bFlanking then
		table.insert(aAddDesc, "[Flanking]");
		nAddMod = nAddMod + 2;
	end
	
	if bHigherGround then
		table.insert(aAddDesc, "[Higher Ground]");
		nAddMod = nAddMod + 1;
	end	

	if bAProne then
		table.insert(aAddDesc, "[Attacker prone]");
		nAddMod = nAddMod - 4;
	end
	
	if bAConceal then
		table.insert(aAddDesc, "[Attacker Concealed]");
		nAddMod = nAddMod + 2;
	end	

	-- Add defense modifiers and adjust attack roll string
	if bTouch then
		if not string.match(rRoll.sDesc, "%[TOUCH%]") then
			table.insert(aAddDesc, "[TOUCH]");
		end
	end
	
	if bFlatFooted then
		table.insert(aAddDesc, "[FF]");
	end

	if bSuperiorCover then
		table.insert(aAddDesc, "[COVER -10]");
		nAddMod = nAddMod - 10;
	elseif bCover then
		table.insert(aAddDesc, "[COVER -7]");
		nAddMod = nAddMod - 7;		
	elseif bPartialCover then
		table.insert(aAddDesc, "[COVER -4]");
		nAddMod = nAddMod - 4;
	elseif bMinimumCover then
		nAddMod = nAddMod - 2;
		table.insert(aAddDesc, "[COVER -2]");		
	end

	if bTotalDefense then
		table.insert(aAddDesc, "[Total Defense]");
		nAddMod = nAddMod - 4;
	end

	if bDodging then
		table.insert(aAddDesc, "[Dodging]");
		nAddMod = nAddMod - 1;
	end
	
	if bKneeling then
		table.insert(aAddDesc, "[Defender kneeling]");
		nAddMod = nAddMod + 2;
	end

	if bProne then
		table.insert(aAddDesc, "[Defender prone]");
		nAddMod = nAddMod + 4;
	end
	
	if bRunning then
		table.insert(aAddDesc, "[Defender running]");
		nAddMod = nAddMod - 2;
	end

	if bPinned then
		table.insert(aAddDesc, "[Defender pinned]");
		nAddMod = nAddMod + 4;
	end

	if rSource then
		-- Determine attack type
		local sAttackType = nil;
		if rRoll.sType == "attack" then
			sAttackType = string.match(rRoll.sDesc, "%[ATTACK.*%((%w+)%)%]");
			if not sAttackType then
				sAttackType = "M";
			end
		elseif rRoll.sType == "grapple" then
			sAttackType = "M";
		end

		-- Determine ability used
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end
		if not sActionStat then
			if sAttackType == "M" then
				sActionStat = "strength";
			elseif sAttackType == "R" then
				sActionStat = "dexterity";
			end
		end

		-- Build attack filter
		local aAttackFilter = {};
		
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		end
		if bOpportunity then
			table.insert(aAttackFilter, "opportunity");
		end

		-- Get attack effect modifiers
		local bEffects = false;
		local nEffectCount;

		aAddDice, nAddMod, nEffectCount = EffectManager35E.getEffectsBonus(rSource, {"ATK"}, false, aAttackFilter, rTarget);

		if (nEffectCount > 0) then
			bEffects = true;
		end

		if rRoll.sType == "grapple" then
			local aPFDice, nPFMod, nPFCount = EffectManager35E.getEffectsBonus(rSource, {"CMB"}, false, aAttackFilter, rTarget);
			if nPFCount > 0 then
				bEffects = true;
				for k, v in ipairs(aPFDice) do
					table.insert(aAddDice, v);
				end
				nAddMod = nAddMod + nPFMod;
			end
		end

		-- Get condition modifiers
		if EffectManager35E.hasEffect(rSource, "Invisible") then
			bEffects = true;
			nAddMod = nAddMod + 2;
			table.insert(aAddDesc, "[CA]");
		elseif EffectManager35E.hasEffect(rSource, "CA") then
			bEffects = true;
			table.insert(aAddDesc, "[CA]");
		end

		if EffectManager35E.hasEffect(rSource, "Blinded") then
			bEffects = true;
			table.insert(aAddDesc, "[BLINDED]");
		end

		if not DataCommon.isPFRPG() then
			if EffectManager35E.hasEffect(rSource, "Incorporeal") and sAttackType == "M" and not string.match(string.lower(rRoll.sDesc), "incorporeal touch") then
				bEffects = true;
				table.insert(aAddDesc, "[INCORPOREAL]");
			end
		end

		if EffectManager35E.hasEffectCondition(rSource, "Dazzled") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end

		if EffectManager35E.hasEffectCondition(rSource, "Slowed") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end

		if EffectManager35E.hasEffectCondition(rSource, "Entangled") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		if rRoll.sType == "attack" and 
				(EffectManager35E.hasEffectCondition(rSource, "Pinned") or
				EffectManager35E.hasEffectCondition(rSource, "Grappled")) then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		if EffectManager35E.hasEffectCondition(rSource, "Frightened") or 
				EffectManager35E.hasEffectCondition(rSource, "Panicked") or
				EffectManager35E.hasEffectCondition(rSource, "Shaken") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		if EffectManager35E.hasEffectCondition(rSource, "Sickened") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		-- Get other effect modifiers
		if EffectManager35E.hasEffectCondition(rSource, "Squeezing") then
			bEffects = true;
			nAddMod = nAddMod - 4;
		end
		if EffectManager35E.hasEffectCondition(rSource, "Prone") then
			if sAttackType == "M" then
				bEffects = true;
				nAddMod = nAddMod - 4;
			end
		end

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager35E.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- Get negative levels
		local nNegLevelMod, nNegLevelCount = EffectManager35E.getEffectsBonus(rSource, {"NLVL"}, true);
		if nNegLevelCount > 0 then
			bEffects = true;
			nAddMod = nAddMod - nNegLevelMod;
		end

		-- If effects, then add them
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end

	for _,vDie in ipairs(aAddDice) do
		if vDie:sub(1,1) == "-" then
			table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
		else
			table.insert(rRoll.aDice, "p" .. vDie:sub(2));
		end
	end

	rRoll.nMod = rRoll.nMod + nAddMod;
end


function onAttack(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local bIsSourcePC = ActorManager.isPC(rSource);
	local bAllowCC = OptionsManager.isOption("HRCC", "on") or (not bIsSourcePC and OptionsManager.isOption("HRCC", "npc"));
	
	if rRoll.sDesc:match("%[CMB") then
		rRoll.sType = "grapple";
	end
	
	local rAction = {};
	rAction.nTotal = ActionsManager.total(rRoll);
	rAction.aMessages = {};
	
	-- If we have a target, then calculate the defense we need to exceed
	local nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus, nMissChance;
	if rRoll.sType == "critconfirm" then
		local sDefenseVal = rRoll.sDesc:match(" %[AC (%d+)%]");
		if sDefenseVal then
			nDefenseVal = tonumber(sDefenseVal);
		end
		nMissChance = tonumber(rRoll.sDesc:match("%[MISS CHANCE (%d+)%%%]")) or 0;
		rMessage.text = rMessage.text:gsub(" %[AC %d+%]", "");
		rMessage.text = rMessage.text:gsub(" %[MISS CHANCE %d+%%%]", "");
	else
		nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus, nMissChance = ActorManager35E.getDefenseValue(rSource, rTarget, rRoll);
		if nAtkEffectsBonus ~= 0 then
			rAction.nTotal = rAction.nTotal + nAtkEffectsBonus;
			local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]";
			table.insert(rAction.aMessages, string.format(sFormat, nAtkEffectsBonus));
		end
		if nDefEffectsBonus ~= 0 then
			nDefenseVal = nDefenseVal + nDefEffectsBonus;
			local sFormat = "[" .. Interface.getString("effects_def_tag") .. " %+d]";
			table.insert(rAction.aMessages, string.format(sFormat, nDefEffectsBonus));
		end
	end

	-- Get the crit threshold
	rAction.nCrit = 20;	
	local sAltCritRange = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
	if sAltCritRange then
		rAction.nCrit = tonumber(sAltCritRange) or 20;
		if (rAction.nCrit <= 1) or (rAction.nCrit > 20) then
			rAction.nCrit = 20;
		end
	end
	
	rAction.nFirstDie = 0;
	if #(rRoll.aDice) > 0 then
		rAction.nFirstDie = rRoll.aDice[1].result or 0;
	end
	rAction.bCritThreat = false;
	if rAction.nFirstDie >= 20 then
		rAction.bSpecial = true;
		if rRoll.sType == "critconfirm" then
			rAction.sResult = "crit";
			table.insert(rAction.aMessages, "[CRITICAL HIT]");
		elseif rRoll.sType == "attack" then
			if bAllowCC then
				rAction.sResult = "hit";
				rAction.bCritThreat = true;
				table.insert(rAction.aMessages, "[AUTOMATIC HIT]");
			else
				rAction.sResult = "crit";
				table.insert(rAction.aMessages, "[CRITICAL HIT]");
			end
		else
			rAction.sResult = "hit";
			table.insert(rAction.aMessages, "[AUTOMATIC HIT]");
		end
	elseif rAction.nFirstDie == 1 then
		if rRoll.sType == "critconfirm" then
			table.insert(rAction.aMessages, "[CRIT NOT CONFIRMED]");
			rAction.sResult = "miss";
		else
			table.insert(rAction.aMessages, "[AUTOMATIC MISS]");
			rAction.sResult = "fumble";
		end
	elseif nDefenseVal then
		if rAction.nTotal >= nDefenseVal then
			if rRoll.sType == "critconfirm" then
				rAction.sResult = "crit";
				table.insert(rAction.aMessages, "[CRITICAL HIT]");
			elseif rRoll.sType == "attack" and rAction.nFirstDie >= rAction.nCrit then
				if bAllowCC then
					rAction.sResult = "hit";
					rAction.bCritThreat = true;
					table.insert(rAction.aMessages, "[CRITICAL THREAT]");
				else
					rAction.sResult = "crit";
					table.insert(rAction.aMessages, "[CRITICAL HIT]");
				end
			else
				rAction.sResult = "hit";
				table.insert(rAction.aMessages, "[HIT]");
			end
		else
			rAction.sResult = "miss";
			if rRoll.sType == "critconfirm" then
				table.insert(rAction.aMessages, "[CRIT NOT CONFIRMED]");
			else
				table.insert(rAction.aMessages, "[MISS]");
			end
		end
	elseif rRoll.sType == "critconfirm" then
		rAction.sResult = "crit";
		table.insert(rAction.aMessages, "[CHECK FOR CRITICAL]");
	elseif rRoll.sType == "attack" and rAction.nFirstDie >= rAction.nCrit then
		if bAllowCC then
			rAction.sResult = "hit";
			rAction.bCritThreat = true;
		else
			rAction.sResult = "crit";
		end
		table.insert(rAction.aMessages, "[CHECK FOR CRITICAL]");
	end
	
	if ((rRoll.sType == "critconfirm") or not rAction.bCritThreat) and (nMissChance > 0) then
		table.insert(rAction.aMessages, "[MISS CHANCE " .. nMissChance .. "%]");
	end

	Comm.deliverChatMessage(rMessage);

	if rAction.sResult == "crit" then
		setCritState(rSource, rTarget);
	end
	
	local bRollMissChance = false;
	if rRoll.sType == "critconfirm" then
		bRollMissChance = true;
	else
		if rAction.bCritThreat then
			local rCritConfirmRoll = { sType = "critconfirm", aDice = {"d20"}, bTower = rRoll.bTower, bSecret = rRoll.bSecret };
				
			local nCCMod = EffectManager35E.getEffectsBonus(rSource, {"CC"}, true, nil, rTarget);
			if nCCMod ~= 0 then
				rCritConfirmRoll.sDesc = string.format("%s [CONFIRM %+d]", rRoll.sDesc, nCCMod);
			else
				rCritConfirmRoll.sDesc = rRoll.sDesc .. " [CONFIRM]";
			end
			if nMissChance > 0 then
				rCritConfirmRoll.sDesc = rCritConfirmRoll.sDesc .. " [MISS CHANCE " .. nMissChance .. "%]";
			end
			rCritConfirmRoll.nMod = rRoll.nMod + nCCMod;
			
			if nDefenseVal then
				rCritConfirmRoll.sDesc = rCritConfirmRoll.sDesc .. " [AC " .. nDefenseVal .. "]";
			end

			if nAtkEffectsBonus and nAtkEffectsBonus ~= 0 then
				local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]";
				rCritConfirmRoll.sDesc = rCritConfirmRoll.sDesc .. " " .. string.format(sFormat, nAtkEffectsBonus);
			end
			
			ActionsManager.roll(rSource, { rTarget }, rCritConfirmRoll, true);
		elseif (rAction.sResult ~= "miss") and (rAction.sResult ~= "fumble") then
			bRollMissChance = true;
		end
	end
	if bRollMissChance and (nMissChance > 0) then
		local aMissChanceDice = { "d100" };
		local sMissChanceText;
		sMissChanceText = string.gsub(rMessage.text, " %[CRIT %d+%]", "");
		sMissChanceText = string.gsub(sMissChanceText, " %[CONFIRM%]", "");
		local rMissChanceRoll = { sType = "misschance", sDesc = sMissChanceText .. " [MISS CHANCE " .. nMissChance .. "%]", aDice = aMissChanceDice, nMod = 0 };
		ActionsManager.roll(rSource, rTarget, rMissChanceRoll);
	end

	if rTarget then
		notifyApplyAttack(rSource, rTarget, rRoll.bTower, rRoll.sType, rRoll.sDesc, rAction.nTotal, table.concat(rAction.aMessages, " "));
		
		-- REMOVE TARGET ON MISS OPTION
		if (rAction.sResult == "miss" or rAction.sResult == "fumble") and rRoll.sType ~= "critconfirm" and not string.match(rRoll.sDesc, "%[FULL%]") then
			local bRemoveTarget = false;
			if OptionsManager.isOption("RMMT", "on") then
				bRemoveTarget = true;
			elseif rRoll.bRemoveOnMiss then
				bRemoveTarget = true;
			end
			
			if bRemoveTarget then
				TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
			end
		end
	end
	
	-- HANDLE FUMBLE/CRIT HOUSE RULES
	local sOptionHRFC = OptionsManager.getOption("HRFC");
	if rAction.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
		notifyApplyHRFC("Fumble");
	end
	if rAction.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
		notifyApplyHRFC("Critical Hit");
	end
end

function onGrapple(rSource, rTarget, rRoll)
	if DataCommon.isPFRPG() then
		onAttack(rSource, rTarget, rRoll);
	else
		local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
		
		if rTarget then
			rMessage.text = rMessage.text .. " [at " .. ActorManager.getDisplayName(rTarget) .. "]";
		end
		
		if not rSource then
			rMessage.sender = nil;
		end
		Comm.deliverChatMessage(rMessage);
	end
end

function onMissChance(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local nTotal = ActionsManager.total(rRoll);
	local nMissChance = tonumber(string.match(rMessage.text, "%[MISS CHANCE (%d+)%%%]")) or 0;
	if nTotal <= nMissChance then
		rMessage.text = rMessage.text .. " [MISS]";
		if rTarget then
			rMessage.icon = "roll_attack_miss";
			clearCritState(rSource, rTarget);
		else
			rMessage.icon = "roll_attack";
		end
	else
		rMessage.text = rMessage.text .. " [HIT]";
		if rTarget then
			rMessage.icon = "roll_attack_hit";
		else
			rMessage.icon = "roll_attack";
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end

function applyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};
	
	if sAttackType == "grapple" then
		msgShort.text = "Combat Man. ->";
		msgLong.text = "Combat Man. [" .. nTotal .. "] ->";
	else
		msgShort.text = "Attack ->";
		msgLong.text = "Attack [" .. nTotal .. "] ->";
	end
	if rTarget then
		local sName = ActorManager.getDisplayName(rTarget);
		msgShort.text = msgShort.text .. " [at " .. sName .. "]";
		msgLong.text = msgLong.text .. " [at " .. sName .. "]";
	end
	if sResults ~= "" then
		msgLong.text = msgLong.text .. " " .. sResults;
	end
	
	msgShort.icon = "roll_attack";
	if string.match(sResults, "%[CRITICAL HIT%]") then
		msgLong.icon = "roll_attack_crit";
	elseif string.match(sResults, "HIT%]") then
		msgLong.icon = "roll_attack_hit";
	elseif string.match(sResults, "MISS%]") then
		msgLong.icon = "roll_attack_miss";
	elseif string.match(sResults, "CRITICAL THREAT%]") then
		msgLong.icon = "roll_attack_hit";
	else
		msgLong.icon = "roll_attack";
	end
		
	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

aCritState = {};

function setCritState(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end
	
	if not aCritState[sSourceCT] then
		aCritState[sSourceCT] = {};
	end
	table.insert(aCritState[sSourceCT], sTargetCT);
end

function clearCritState(rSource, rTarget)
	if rTarget then
		isCrit(rSource, rTarget);
		return;
	end
	
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT ~= "" then
		aCritState[sSourceCT] = nil;
	end
end

function isCrit(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end

	if not aCritState[sSourceCT] then
		return false;
	end
	
	for k,v in ipairs(aCritState[sSourceCT]) do
		if v == sTargetCT then
			table.remove(aCritState[sSourceCT], k);
			return true;
		end
	end
	
	return false;
end