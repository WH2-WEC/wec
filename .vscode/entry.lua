require("mcm/ModConfigurationManager")
require("mcm/export_helpers__mcm_ui")
require("mcm/export_helpers__mcm_basic_settings")
_G.sfo = false --:boolean

---[[ Legendary Lord Respecs
require("llr/export_helpers__one_button_respec")
require("llr/respec_on_confed")
--]]

---[[ Old World Rites
require("owr/OldWorldRitesMod")
require("owr/export_helpers__owr_peasant_overwrite")
require("owr/export_helpers__owr_unlock_conditions")
require("owr/export_helpers__owr_ai_rites")
--faction specific
require("owr/export_helpers__owr_emp_policy")
require("owr/export_helpers__owr_dwf_holds")
require("owr/export_helpers__owr_grn_gorkmork")
require("owr/export_helpers__owr_chs_gods")
require("owr/export_helpers__owr_chs_cults")
require("owr/export_helpers__owr_vmp_intrigue")
--compat
require("owr/compat_scripts/export_helpers__owr_zf_stanks")
--]]

---[[ better behaved allies
require("bba/BetterBehavedAllies")
--]]

---[[ The Gates of Chaos
require("chaos_gates/export_helpers__chaos_gates")
--]]

---[[ Book of Grudges
require("grudges/BookOfGrudges")
--]]

---[[ Lords in Exile
require("lords_in_exile/LordsInExile")
require("lords_in_exile/export_helpers__exiled_lords_ebs")
require("controllable_waaghs/ControlWaaaghs")
require("controllable_waaghs/export_helpers__control_waaagh")
--]]

---[[delete far away factions
    require("delete_far_away_factions/delete_far_away")    
--]]

---[[tp spawns
require("teleport_spawns/teleport_spawns")
--]]


require("patreon_requests/StuckHeroFix")
--unupdated/vandies trash

--require("owr/wec_rites")
--require("runic_forge/wec_runic_forge")
--require("ci/wh_chaos_invasion")
--require("dev_tools/!!wec_development_tools")
--require("recruiter_controls")


require("exterior_scripting/export_helpers__alberic_boat_disease")
require("le/wec_loreful_empires")

--require("emil_qb/battle_script");

---[[war sentiment
require("war_sentiment/WarSentiment") 
require("war_sentiment/export_helpers__war_sentiment") 
--]]


CRYN_EXAMPLE_STRING = "put_default_value_here" --:string
CRYN_EXAMPLE_NUM_VAR_WITH_MCHOICE = 0 --:number
CRYN_EXAMPLE_NUM_VAR_WITH_VARIABLE = 0 --:number
CRYN_EXAMPLE_BOOLEAN = true --:boolean



