local cc = _G.companion_control

--UI
core:add_listener(
    "CharacterSelectedCompControl",
    "CharacterSelected",
    function(context)
        return context:character():faction():is_human()
    end,
    function(context)
        cc._currentChar = context:character():command_queue_index()
        if cc:is_char_companion(context:character():command_queue_index()) then
            cc:disable_buttons()
        else
            cc:enable_buttons()
        end
    end,
    true
)

--actually removing the waaagh
core:add_listener(
    "CharacterWaaaghOccurredCompControl",
    "CharacterWaaaghOccurred",
    function(context)
        return context:character():faction():is_human() or context:character():faction():name():find("_waaagh") or context:character():faction():name():find("_brayherd")
    end,
    function(context)
        cc:switch_out_waaagh(context:character():command_queue_index())
    end,
    true
)

--checking if the waaagh is still valid #1
core:add_listener(
    "CompControlUnitDisbandedChecks",
    "UnitDisbanded",
    function(context)
        return cc:is_army_linked(context:unit():force_commander():command_queue_index())
    end,
    function(context)
        cc:log("CompControlUnitDisbandedChecks sending a char validity check!")
        local char = context:unit():force_commander() --:CA_CHAR
        cc:check_linked_char_validity(char)
    end,
    true
)
core:add_listener(
    "CompControlUnitMergedAndDestroyedChecks",
    "UnitMergedAndDestroyed",
    function(context)
        return cc:is_army_linked(context:unit():force_commander():command_queue_index())
    end,
    function(context)
        cc:log("CompControlUnitMergedAndDestroyedChecks sending a char validity check!")
        local char = context:unit():force_commander() --:CA_CHAR
        cc:check_linked_char_validity(char)
    end,
    true
)
--checking if the waaagh is still valid #2
core:add_listener(
    "CompControlCharacterEventChecks",
    "CharacterTurnStart",
    function(context)
        return cc:is_army_linked(context:character():command_queue_index())
    end,
    function(context)
        local char = context:character()--:CA_CHAR
        cc:log("CompControlCharacterEventChecks sending a char validity check!")
        cc:check_linked_char_validity(char)
    end,
    true
)

--checking if the waaagh is still valid #3
core:add_listener(
    "CharactersLostBattle",
    "CharacterCompletedBattle",
    function(context)
        return context:character():won_battle()
    end,
    function(context)
        local pb = context:pending_battle() --:CA_PENDING_BATTLE
        local character = context:character() --:CA_CHAR
        if cc:is_army_linked(character:command_queue_index()) then
            cc:log("CharactersLostBattle first part sending a char validity check!")
            cc:check_linked_char_validity(character)
        end
        local enemies = cm:pending_battle_cache_get_enemies_of_char(character)
        for i = 1, #enemies do
            local enemy = enemies[i]
            if cc:is_army_linked(enemy:command_queue_index()) then
                cc:log("CharactersLostBattle loop sending a char validity check!")
                cc:check_linked_char_validity(enemy)
            end
        end
    end,
    true
)

--check if the force is still valid #4
core:add_listener(
    "CCBattleCompletedCheckForces",
    "CompletedBattle",
    function(context)
        local humans = cm:get_human_factions()
        for i = 1, #humans do
            if cm:pending_battle_cache_faction_is_involved(humans[i]) then
                return true
            end
        end
        return false
    end,
    function(context)
        for i = 1, cm:pending_battle_cache_num_attackers() do
            local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
            if cm:get_faction(current_faction_name):is_human() then
                if cc:is_char_companion(this_char_cqi) then
                    cc:log("CCBattleCompletedCheckForces sending a MF validity check!")
                    cc:check_companion_mf_validity(cm:model():military_force_for_command_queue_index(this_mf_cqi))
                end
            end
        end
        for i = 1, cm:pending_battle_cache_num_defenders() do
            local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
            if cm:get_faction(current_faction_name):is_human() then
                if cc:is_char_companion(this_char_cqi) then
                    cc:log("CCBattleCompletedCheckForces sending a MF validity check!")
                    cc:check_companion_mf_validity(cm:model():military_force_for_command_queue_index(this_mf_cqi))
                end
            end
        end
    end,
    true
)

--check if force is still valid #5
core:add_listener(
    "CCFactionTurnStartCheckAll",
    "FactionTurnStart",
    function(context)
        return context:faction():is_human()
    end,
    function(context)
        for mf_cqi, link_cqi in pairs(cc._companionForces) do
            cc:log("CCFactionTurnStartCheckAll sending a MF validity check!")
            cc:check_companion_mf_validity(cm:model():military_force_for_command_queue_index(mf_cqi))
        end
    end,
    true
)


--disabling exchanges 
--function stolen from RM in weo lib
--v function() --> CA_CQI
local function find_second_army()
    --v function(ax: number, ay: number, bx: number, by: number) --> number
    local function distance_2D(ax, ay, bx, by)
        return (((bx - ax) ^ 2 + (by - ay) ^ 2) ^ 0.5);
    end;
    local first_char = cm:get_character_by_cqi(cc._currentChar)
    local char_list = first_char:faction():character_list()
    local closest_char --:CA_CHAR
    local last_distance = 50 --:number
    local ax = first_char:logical_position_x()
    local ay = first_char:logical_position_y()
    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if cm:char_is_mobile_general_with_army(char) then
            if char:command_queue_index() == first_char:command_queue_index() then

            else
                local dist = distance_2D(ax, ay, char:logical_position_x(), char:logical_position_y())
                if dist < last_distance then
                    last_distance = dist
                    closest_char = char
                end
            end
        end
    end
    if closest_char then
        return closest_char:command_queue_index()
    else
        return nil
    end
end
--v function()
local function LockExchangeButton()
    local ok_button = find_uicomponent(core:get_ui_root(), "unit_exchange", "hud_center_docker", "ok_cancel_buttongroup", "button_ok")
    if not not ok_button then
        ok_button:SetInteractive(false)
        ok_button:SetImage("ui/skins/default/icon_disband.png")
    end
end

--v function()
local function UnlockExchangeButton()
    local ok_button = find_uicomponent(core:get_ui_root(), "unit_exchange", "hud_center_docker", "ok_cancel_buttongroup", "button_ok")
    if not not ok_button then
        ok_button:SetInteractive(true)
        ok_button:SetImage("ui/skins/default/icon_check.png")
    end
end


core:add_listener(
    "ExilesPanelOpenedExchange",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "unit_exchange"; 
    end,
    function(context)
        cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to change it!
            local first = cc._currentChar
            local second = find_second_army()
            --if either army is an companion army, disable the exchange!
            if cc:is_char_companion(first) or cc:is_char_companion(second) then
                LockExchangeButton()
            else
                UnlockExchangeButton()
            end
        end, 0.1)
    end,
    true
)

--OVERWRITE CA FUNCTION
--[[
-- loop through the player's armys and apply
--v function(faction: CA_FACTION)
function apply_upkeep_penalty(faction)
	local difficulty = cm:model():combined_difficulty_level();
	
	local effect_bundle = "wh_main_bundle_force_additional_army_upkeep_easy";				-- easy
	
	if difficulty == 0 then
		effect_bundle = "wh_main_bundle_force_additional_army_upkeep_normal";				-- normal
	elseif difficulty == -1 then
		effect_bundle = "wh_main_bundle_force_additional_army_upkeep_hard";					-- hard
	elseif difficulty == -2 then
		effect_bundle = "wh_main_bundle_force_additional_army_upkeep_very_hard";			-- very hard
	elseif difficulty == -3 then
		effect_bundle = "wh_main_bundle_force_additional_army_upkeep_legendary";			-- legendary
	end;
	
	local mf_list = faction:military_force_list();
	local num_items = mf_list:num_items();
	--# assume character_is_black_ark: function(character: CA_CHAR) --> boolean
	-- go through every general the player has, ignoring the first, and apply the effect bundles	
	for i = 1, mf_list:num_items() - 1 do
		current_mf = mf_list:item_at(i);
		
		if not current_mf:is_armed_citizenry() and not current_mf:has_effect_bundle(effect_bundle) and current_mf:has_general() and not character_is_black_ark(current_mf:general_character()) and (not _G.companion_control:is_army_linked(current_mf:general_character():command_queue_index())) then
			cm:apply_effect_bundle_to_characters_force(effect_bundle, current_mf:general_character():command_queue_index(), 0, true);
		end;
	end;
end;
--]]