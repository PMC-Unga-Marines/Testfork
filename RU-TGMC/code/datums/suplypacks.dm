GLOBAL_LIST_INIT(all_supply_groups, list("Operations", "Weapons", "Tank Hardpoint Modules", "APC Hardpoint Modules", "Walker Hardpoint Modules", "Attachments", "Ammo", "Armor", "Clothing", "Medical", "Engineering", "Science", "Supplies"))

/*******************************************************************************
HARDPOINT MODULES (and their ammo)
*******************************************************************************/

/datum/supply_packs/ltb_cannon
	name = "M5 LTB Cannon Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/primary/cannon)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/autocannon
	name = "M21 Autocannon Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/primary/autocannon)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun
	name = "M74 LTAA-AP Minigun Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/primary/minigun)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/flamer_module
	name = "M7 \"Dragon\" Flamethrower Unit Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/secondary/flamer)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/towlauncher
	name = "M8-3 TOW Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/secondary/towlauncher)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/m56_cupola
	name = "M56 \"Cupola\" Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/secondary/m56cupola)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_glauncher
	name = "M92 Grenade Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/secondary/grenade_launcher)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/*/datum/supply_packs/tank_slauncher
	name = "Smoke Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/tank/support/smoke_launcher)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"
*/
/datum/supply_packs/weapons_sensor
	name = "M40 Integrated Weapons Sensor Array (x1)"
	contains = list(/obj/item/hardpoint/tank/support/weapons_sensor)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/artillery_module
	name = "M6 Artillery Module (x1)"
	contains = list(/obj/item/hardpoint/tank/support/artillery_module)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/overdrive_enhancer
	name = "M103 Overdrive Enhancer (x1)"
	contains = list(/obj/item/hardpoint/tank/support/overdrive_enhancer)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/ballistic_armor
	name = "M65-B Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/tank/armor/ballistic)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/caustic_armor
	name = "M70 \"Caustic\" Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/tank/armor/caustic)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/concussive_armor
	name = "M66-LC Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/tank/armor/concussive)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/paladin_armor
	name = "M90 \"Paladin\" Armor (x1)"
	contains = list(/obj/item/hardpoint/tank/armor/paladin)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/snowplow_armor
	name = "M37 \"Snowplow\" Armor (x1)"
	contains = list(/obj/item/hardpoint/tank/armor/snowplow)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_treads
	name = "M2 Tank Treads (x1)"
	contains = list(/obj/item/hardpoint/tank/treads/standard)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_treads_heavy
	name = "M2-R Tank Treads (x1)"
	contains = list(/obj/item/hardpoint/tank/treads/heavy)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/ltb_cannon_ammo/ap
	name = "M5 LTB Cannon AP Magazine (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltb_cannon/ap,
					/obj/item/ammo_magazine/tank/ltb_cannon/ap
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/ltb_cannon_ammo/he
	name = "M5 LTB Cannon HE Magazine (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltb_cannon/he,
					/obj/item/ammo_magazine/tank/ltb_cannon/he
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/ltb_cannon_ammo/heat
	name = "M5 LTB Cannon HEAT Magazine (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltb_cannon/heat,
					/obj/item/ammo_magazine/tank/ltb_cannon/heat
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/autocannon_ammo/scr
	name = "M21 Autocannon SCR Magazine (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/autocannon/scr,
					/obj/item/ammo_magazine/tank/autocannon/scr
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/autocannon_ammo/ap
	name = "M21 Autocannon AP Magazine (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/autocannon/ap,
					/obj/item/ammo_magazine/tank/autocannon/ap
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun_ammo
	name = "M74 LTAA-AP Minigun Magazines (x4)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_glauncher_ammo
	name = "M92 Grenade Launcher Magazines (x6)"
	contains = list(
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_slauncher_ammo
	name = "M75 Smoke Deploy System Magazines (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_towlauncher_ammo
	name = "M8-3 TOW Launcher Magazines (x3)"
	contains = list(/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_cupola_ammo
	name = "M56 Cupola Magazines (x3)"
	contains = list(
					/obj/item/ammo_magazine/tank/m56_cupola,
					/obj/item/ammo_magazine/tank/m56_cupola,
					/obj/item/ammo_magazine/tank/m56_cupola
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"

/datum/supply_packs/tank_flamer_ammo
	name = "M70 Flamer Tanks (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Tank Hardpoint Modules"


/*******************************************************************************
APC Hardpoint Modules (and their ammo)
*******************************************************************************/

/datum/supply_packs/dual_cannon
	name = "M78 Dual Cannon Assembly (x1)"
	contains = list(/obj/item/hardpoint/apc/primary/dual_cannon)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "APC Hardpoint Modules"

/datum/supply_packs/front_cannon
	name = "M26 Frontal Cannon Assembly (x1)"
	contains = list(/obj/item/hardpoint/apc/secondary/front_cannon)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "APC Hardpoint Modules"

/datum/supply_packs/flare_launcher
	name = "M9 Flare Launcher System Assembly (x1)"
	contains = list(/obj/item/hardpoint/apc/support/flare_launcher)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "APC Hardpoint Modules"

/datum/supply_packs/wheels
	name = "M3 APC Wheels Kit Assembly (x1)"
	contains = list(/obj/item/hardpoint/apc/wheels)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "APC Hardpoint Modules"

/datum/supply_packs/dual_cannon_ammo
	name = "M78 Dual Cannon Magazines (x6)"
	contains = list(
					/obj/item/ammo_magazine/apc/dual_cannon,
					/obj/item/ammo_magazine/apc/dual_cannon,
					/obj/item/ammo_magazine/apc/dual_cannon,
					/obj/item/ammo_magazine/apc/dual_cannon,
					/obj/item/ammo_magazine/apc/dual_cannon,
					/obj/item/ammo_magazine/apc/dual_cannon
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "apc ammo crate"
	group = "APC Hardpoint Modules"

/datum/supply_packs/front_cannon_ammo
	name = "M26 Frontal Cannon Magazines (x3)"
	contains = list(
					/obj/item/ammo_magazine/apc/front_cannon,
					/obj/item/ammo_magazine/apc/front_cannon,
					/obj/item/ammo_magazine/apc/front_cannon
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "apc ammo crate"
	group = "APC Hardpoint Modules"

/datum/supply_packs/flare_launcher_ammo
	name = "M9 Flare Launcher System Magazine (x5)"
	contains = list(
					/obj/item/ammo_magazine/apc/flare_launcher,
					/obj/item/ammo_magazine/apc/flare_launcher,
					/obj/item/ammo_magazine/apc/flare_launcher,
					/obj/item/ammo_magazine/apc/flare_launcher,
					/obj/item/ammo_magazine/apc/flare_launcher
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "apc ammo crate"
	group = "APC Hardpoint Modules"


/*******************************************************************************
Walker Hardpoint Modules (and their ammo)
*******************************************************************************/

/datum/supply_packs/walker_smartgun
	name = "M56 Double-Barrel Mounted Smartgun Assembly (x1)"
	contains = list(/obj/item/walker_gun/smartgun)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Walker Hardpoint Modules"

/datum/supply_packs/walker_hmg
	name = "M30 Machine Gun Assembly (x1)"
	contains = list(/obj/item/walker_gun/hmg)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Walker Hardpoint Modules"

/datum/supply_packs/walker_flamer
	name = "F40 \"Hellfire\" Flamethower Assembly (x1)"
	contains = list(/obj/item/walker_gun/flamer)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Walker Hardpoint Modules"

/datum/supply_packs/walker_smart_ammo
	name = "M56 Double-Barrel Magazines (x3)"
	contains = list(
					/obj/item/ammo_magazine/walker/smartgun,
					/obj/item/ammo_magazine/walker/smartgun,
					/obj/item/ammo_magazine/walker/smartgun
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "CW13 ammo crate"
	group = "Walker Hardpoint Modules"

/datum/supply_packs/walker_hmg_ammo
	name = "M30 Machine Gun Magazines (x3)"
	contains = list(
					/obj/item/ammo_magazine/walker/hmg,
					/obj/item/ammo_magazine/walker/hmg,
					/obj/item/ammo_magazine/walker/hmg
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "CW13 ammo crate"
	group = "Walker Hardpoint Modules"

/datum/supply_packs/walker_flamer_ammo
	name = "F40 Canisters (x2)"
	contains = list(
					/obj/item/ammo_magazine/walker/flamer,
					/obj/item/ammo_magazine/walker/flamer
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "CW13 ammo crate"
	group = "Walker Hardpoint Modules"