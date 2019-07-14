//ATTENTION
//Due numerous changes related only to tank, some of which are, apparently, cannot be moved to tank.dm
//this file will be only for tank
//I will make cm_transport for APC, coping content of this file and editing it. A lot.

//NOT bitflags, just global constant values
#define HDPT_PRIMARY "primary"
#define HDPT_SECDGUN "secondary"
#define HDPT_SUPPORT "support"
#define HDPT_ARMOR "armor"
#define HDPT_TREADS "treads"
#define WEIGHT_LIGHT "light"
#define WEIGHT_MEDIUM "medium"
#define WEIGHT_HEAVY "heavy"

//Percentages of what hardpoints take what damage, e.g. armor takes 37.5% of the damage
GLOBAL_LIST_INIT(armorvic_dmg_distributions, list(
	HDPT_PRIMARY = 0.15,
	HDPT_SECDGUN = 0.125,
	HDPT_SUPPORT = 0.075,
	HDPT_ARMOR = 0.5,
	HDPT_TREADS = 0.15))

/client/proc/remove_players_from_tank()
	set name = "Eject TCs from tank (emergency only)"
	set category = "Admin"

	for(var/obj/vehicle/multitile/root/cm_armored/CA in view())
		CA.remove_all_players()
		log_admin("[src] forcibly removed all players from [CA]")
		message_admins("[src] forcibly removed all players from [CA]")

//The main object, should be an abstract class
/obj/vehicle/multitile/root/cm_armored
	name = "Armored Vehicle"
	desc = "Get inside to operate the vehicle."
	hitbox_type = /obj/vehicle/multitile/hitbox/cm_armored //Used for emergencies and respawning hitboxes

	//What slots the vehicle can have
	var/list/hardpoints = list(HDPT_SUPPORT, HDPT_TREADS, HDPT_ARMOR, HDPT_SECDGUN, HDPT_PRIMARY)

	//The next world.time when the tank can move
	var/next_move = 0

	//Tower
	var/tower_dir
	var/next_move_tower = 0
	var/tower_delay = 0
	var/tower_fixed = FALSE
	var/last_dir

	var/icon_tower = 'RU-TGMC/icons/obj/vehicles/tower.dmi'
	var/icon_state_tower = "tower_base"

	var/pixel_x_tower
	var/pixel_y_tower

	//smoke deploy system
	var/smoke_ammo_max = 12		//one use consumes 2 smoke nades, so always put even number
	var/smoke_ammo_current = 0
	var/smoke_next_use
	var/obj/item/hardpoint/tank/support/smoke_launcher/SML	//literally inbuilt smoke launcher.
	//needed to be referenced in firing proc as gun we fire from(for some reason, I couldn't use tank itself), that's why it's here


	//Below are vars that can be affected by hardpoints, generally used as ratios or decisecond timers

	move_delay = 70 //treads-less tank barely moves. Fix those damn treads, marine!
	var/speed
	resistance_flags = UNACIDABLE
	var/active_hp = null
	var/vehicle_weight = 0		//tank mass = summarized mass of all installed hardpoints, very important for new weight system
	var/vehicle_class = WEIGHT_LIGHT			//tank class. Depends on vehicle_weight. Xenos behaviour after tank bumps into them depends on tank class

	//list of damag distribution among all installed AND not broken hardpoint modules
	var/list/dmg_distribs = list()

	//weight buffs/debuffs
	var/list/w_ratios = list(
		"w_prim_acc" = 1.0,
		"w_secd_acc" = 1.0,
		"w_supp_acc" = 1.0)

	//Changes cooldowns and accuracies
	var/list/misc_ratios = list(
		"OD_buff" = FALSE,
		"prim_acc" = 1.0,
		"secd_acc" = 1.0,
		"supp_acc" = 1.0,
		"prim_cool" = 1.0,
		"secd_cool" = 1.0,
		"supp_cool" = 1.0)

	//Percentage accuracies for slot
	var/list/accuracies = list(
		"primary" = 0.97,
		"secondary" = 0.67,
		"support" = 0.5)

	//Changes how much damage the tank takes
	var/list/dmg_multipliers = list(
		"all" = 1.0,	//for when you want to make it invincible
		"acid" = 1.5,	//tank without armor will be quite fast, so it needs some serious weak spot, the most obvious thing is acid resistance.
		"slash" = 1.0,	//full slash damage without armor seems fair
		"bullet" = 0.67,	//it's a huge metal box, it has basic bullet protection
		"explosive" = 1.0,
		"blunt" = 0.9,
		"abstract" = 1.0) //abstract for when you just want to hurt it

	//Decisecond cooldowns for the slots
	var/list/cooldowns = list(
		"primary" = 300,
		"secondary" = 200,
		"support" = 150)

	//Which hardpoints need to be repaired before the module can be replaced
	var/list/damaged_hps = list()

	//Placeholders
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"

/obj/vehicle/multitile/root/cm_armored/Initialize()
	. = ..()
	GLOB.tank_list += src
	set_light(15)

/obj/vehicle/multitile/root/cm_armored/Destroy()
	for(var/i in linked_objs)
		var/obj/O = linked_objs[i]
		if(O == src) continue
		qdel(O, 1) //Delete all of the hitboxes etc
	GLOB.tank_list -= src
	return ..()

//What to do if all ofthe installed modules have been broken
/obj/vehicle/multitile/root/cm_armored/proc/handle_all_modules_broken()
	return

/obj/vehicle/multitile/root/cm_armored/proc/deactivate_all_hardpoints()
	var/list/slots = get_activatable_hardpoints()
	for(var/slot in slots)
		var/obj/item/hardpoint/tank/HP = hardpoints[slot]
		if(!HP) continue
		HP.deactivate()

/obj/vehicle/multitile/root/cm_armored/proc/remove_all_players()
	return


	//proc to calculate new speed, class and accuracy modificators depending on current weight
	//speed_min = 3 - if vehicle_weight below 8
	//speed_max = 17.5 - heaviest possible build
	//speed_delay = 30 - broken treads (OD won't affect speed with broken speed anymore)
	//numbers in vehicle_weight represent relative weight of tank - summary of tank modules weight
	//less than 8 vehicle_weight means tank lacks modules. To discourage going commando on the tank
	//AND to prevent serious debuff on already not fully functioning tank, below 8 has the same stats
/obj/vehicle/multitile/root/cm_armored/proc/vehicle_class_update()

	switch (vehicle_weight)
		if(8)
			speed = 3.5 * ( (misc_ratios["OD_buff"]) ? 0.9 : 1 )	//this is needed for tweaking OD buff for different classes of tank
			vehicle_class = WEIGHT_LIGHT
			w_ratios["w_prim_acc"] = 0.91
			w_ratios["w_secd_acc"] = 0.93
			//w_ratios["w_supp_acc"] = 0.92
		if(9)
			speed = 4.2 * ( (misc_ratios["OD_buff"]) ? 0.8 : 1 )
			vehicle_class = WEIGHT_LIGHT
			w_ratios["w_prim_acc"] = 0.93
			w_ratios["w_secd_acc"] = 0.96
			//w_ratios["w_supp_acc"] = 0.95
		if(10)
			speed = 5 * ( (misc_ratios["OD_buff"]) ? 0.7 : 1 )
			vehicle_class = WEIGHT_LIGHT
			w_ratios["w_prim_acc"] = 0.96
			w_ratios["w_secd_acc"] = 0.99
			//w_ratios["w_supp_acc"] = 0.97
		if(11)
			speed = 5.5 * ( (misc_ratios["OD_buff"]) ? 0.65 : 1 )
			vehicle_class = WEIGHT_MEDIUM
			w_ratios["w_prim_acc"] = 1.0
			w_ratios["w_secd_acc"] = 1.0
			//w_ratios["w_supp_acc"] = 1.0
		if(12)
			speed = 6 * ( (misc_ratios["OD_buff"]) ? 0.7 : 1 )
			vehicle_class = WEIGHT_MEDIUM
			w_ratios["w_prim_acc"] = 1.0
			w_ratios["w_secd_acc"] = 1.0
			//w_ratios["w_supp_acc"] = 1.0
		if(13)
			speed = 7 * ( (misc_ratios["OD_buff"]) ? 0.75 : 1 )
			vehicle_class = WEIGHT_MEDIUM
			w_ratios["w_prim_acc"] = 1.0
			w_ratios["w_secd_acc"] = 1.0
			//w_ratios["w_supp_acc"] = 1.0
		if(14)
			speed = 7.5 * ( (misc_ratios["OD_buff"]) ? 0.8 : 1 )
			vehicle_class = WEIGHT_MEDIUM
			w_ratios["w_prim_acc"] = 1.0
			w_ratios["w_secd_acc"] = 1.0
			//w_ratios["w_supp_acc"] = 1.0
		if(15)
			speed = 8 * ( (misc_ratios["OD_buff"]) ? 0.85 : 1 )
			vehicle_class = WEIGHT_MEDIUM
			w_ratios["w_prim_acc"] = 1.0
			w_ratios["w_secd_acc"] = 1.0
			//w_ratios["w_supp_acc"] = 1.0
		if(16)
			speed = 10 * ( (misc_ratios["OD_buff"]) ? 0.7 : 1 )
			vehicle_class = WEIGHT_HEAVY
			w_ratios["w_prim_acc"] = 1.02
			w_ratios["w_secd_acc"] = 1.01
			//w_ratios["w_supp_acc"] = 1.01
		if(17)
			speed = 11.5 * ( (misc_ratios["OD_buff"]) ? 0.74 : 1 )
			vehicle_class = WEIGHT_HEAVY
			w_ratios["w_prim_acc"] = 1.03
			w_ratios["w_secd_acc"] = 1.02
			//w_ratios["w_supp_acc"] = 1.02
		if(18)
			vehicle_class = WEIGHT_HEAVY
			w_ratios["w_prim_acc"] = 1.04
			w_ratios["w_secd_acc"] = 1.03
			//w_ratios["w_supp_acc"] = 1.03
		if(19)
			speed = 14.5 * ( (misc_ratios["OD_buff"]) ? 0.82 : 1 )
			vehicle_class = WEIGHT_HEAVY
			w_ratios["w_prim_acc"] = 1.05
			w_ratios["w_secd_acc"] = 1.04
			//w_ratios["w_supp_acc"] = 1.04

		else
			speed = 3.0 * ( (misc_ratios["OD_buff"]) ? 0.95 : 1 )
			vehicle_class = WEIGHT_LIGHT
			w_ratios["w_prim_acc"] = 0.9
			w_ratios["w_secd_acc"] = 0.9
			//w_ratios["w_supp_acc"] = 0.90


//The basic vehicle code that moves the tank, with movement delay implemented
/obj/vehicle/multitile/root/cm_armored/relaymove(mob/user, direction)
	if(world.time < next_move) return
	var/obj/item/hardpoint/HP = hardpoints[HDPT_TREADS]
	if(HP && HP.obj_integrity > 0)	//OD doesn't affect moving without treads anymore
		next_move = world.time + src.speed
	else
		next_move = world.time + move_delay
	return ..()

//Same thing but for rotations
/obj/vehicle/multitile/root/cm_armored/try_rotate(var/deg, var/mob/user, var/force = 0)
	if(world.time < next_move && !force) return
	var/obj/item/hardpoint/HP = hardpoints[HDPT_TREADS]
	if(HP && HP.obj_integrity > 0)	//same goes for turning
		next_move = world.time + src.speed * (force ? 2 : 3) //3 for a 3 point turn, idk
	else
		next_move = world.time + move_delay * (force ? 2 : 3)
	return ..()

/obj/vehicle/multitile/root/cm_armored/proc/can_use_hp(var/mob/M)
	return 1

//No one but the gunner can gun
//And other checks to make sure you aren't breaking the law
/obj/vehicle/multitile/root/cm_armored/proc/click_action(A, mob/user, params)

//sadly, point-to requires mob to give message in chat and probably is the reason why it doesn't work from inside of a tank
//	if (mods["shift"] && mods["middle"])
//		user.point_to(A)
//		return
	var/list/mods = params2list(params)


	if(istype(A, /obj/screen) || A == src || mods["middle"] || mods["shift"] || mods["alt"])
		return

	if(!can_use_hp(user)) return

	if(!hardpoints.Find(active_hp))
		to_chat(user, "<span class='warning'>Please select an active hardpoint first.</span>")
		return

	var/obj/item/hardpoint/tank/HP = hardpoints[active_hp]

	if(!HP)
		return

	if(!HP.is_ready())
		return

	if(!HP.firing_arc(A))
		to_chat(user, "<span class='warning'>The target is not within your firing arc.</span>")
		return

	HP.active_effect(get_turf(A))

//Used by the gunner to swap which module they are using
//e.g. from the minigun to the smoke launcher
//Only the active hardpoint module can be used
/obj/vehicle/multitile/root/cm_armored/verb/switch_active_hp()
	set name = "W Change Active Weapon"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	if(!can_use_hp(usr))
		return

	var/mob/living/carbon/human/M = usr
	var/obj/item/card/id/I = M.wear_id
	if(I && I.rank == "Synthetic" && I.registered_name == M.real_name)
		to_chat(usr, "<span class='notice'>Your programm doesn't allow operating tank weapons.</span>")
		return

	var/list/slots = get_activatable_hardpoints()

	if(!length(slots))
		to_chat(usr, "<span class='warning'>All of the modules can't be activated or are broken.</span>")
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/tank/HP = hardpoints[slot]
	if(!(HP?.obj_integrity))
		to_chat(usr, "<span class='warning'>There's nothing installed on that hardpoint.</span>")

	deactivate_binos(usr)
	active_hp = slot
	to_chat(usr, "<span class='notice'>You select the [HP.name].</span>")
	if(isliving(usr))
		M.set_interaction(src)



//anti-binoculars exploit fix
/obj/vehicle/multitile/root/cm_armored/proc/deactivate_binos(var/mob/user)
	for(var/obj/item/binoculars/BN in user.contents)
		if(BN.zoom)
			to_chat(usr, "<span class='warning'>You realize using [BN.name] and operating tank weapons at the same time is impossible!</span>")
			BN.zoom(user)

//proc to actually shoot smoke grenades
/obj/vehicle/multitile/root/cm_armored/proc/smoke_shot()

	if(world.time < smoke_next_use)
		to_chat(usr, "<span class='warning'>Smoke Deploy System is not ready!</span>")
		return

	//need to figure out better way to locate needed turfs to fire at
	var/turf/F
	var/turf/S
	var/right_dir
	var/left_dir
	F = get_step(loc, dir)
	F = get_step(F, dir)
	F = get_step(F, dir)
	F = get_step(F, dir)
	F = get_step(F, dir)
	left_dir = turn(dir, -90)
	S = get_step(F, left_dir)
	S = get_step(S, left_dir)
	right_dir = turn(dir, 90)
	F = get_step(F, right_dir)
	F = get_step(F, right_dir)

	//this is basically a copypasta from Hardpoints shooting proc with a modifcations
	var/obj/item/ammo_magazine/tank/tank_slauncher/A = new
	smoke_next_use = world.time + 150
	var/obj/item/projectile/P = new
	P.generate_bullet(new A.default_ammo)
	P.fire_at(F, src, SML, 6, P.ammo.shell_speed)
	playsound(get_turf(src), 'RU-TGMC/sound/weapons/tank_smokelauncher_fire2.ogg', 60, 1)
	smoke_ammo_current--
	sleep (10)
	var/obj/item/projectile/G = new
	G.generate_bullet(new A.default_ammo)
	G.fire_at(S, src, SML, 6, G.ammo.shell_speed)
	playsound(get_turf(src), 'RU-TGMC/sound/weapons/tank_smokelauncher_fire2.ogg', 60, 1)
	smoke_ammo_current--

	if(smoke_ammo_current <= 0)
		to_chat(usr, "<span class='warning'>Ammo depleted. Ejecting empty magazine.</span>")
		A.Move(entrance.loc)
		A.current_rounds = 0
		A.update_icon()


//verb shows only to TCs status update on their tank including: ammo and backup clips in weapons and combined health of all modules showed in %
/obj/vehicle/multitile/root/cm_armored/verb/tank_status()
	set name = "G Check Vehicle Status"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	var/obj/item/hardpoint/tank/HP1 = hardpoints[HDPT_ARMOR]
	var/obj/item/hardpoint/tank/HP2 = hardpoints[HDPT_TREADS]
	var/obj/item/hardpoint/tank/HP3 = hardpoints[HDPT_SUPPORT]
	var/obj/item/hardpoint/tank/HP4 = hardpoints[HDPT_SECDGUN]
	var/obj/item/hardpoint/tank/HP5 = hardpoints[HDPT_PRIMARY]
	var divider = 0
	var tank_health = 0

	if (HP1)
		if(HP1.obj_integrity > 0)
			tank_health += HP1.obj_integrity
		divider += abs(HP1.max_integrity)
	if (HP2)
		if(HP2.obj_integrity > 0)
			tank_health += HP2.obj_integrity
		divider += abs(HP2.max_integrity)
	if (HP3)
		if(HP3.obj_integrity > 0)
			tank_health += HP3.obj_integrity
		divider += abs(HP3.max_integrity)
	if (HP4)
		if(HP4.obj_integrity > 0)
			tank_health += HP4.obj_integrity
		divider += abs(HP4.max_integrity)
	if (HP5)
		if(HP5.obj_integrity > 0)
			tank_health += HP5.obj_integrity
		divider += abs(HP5.max_integrity)

	if(divider == 0)
		tank_health = round(tank_health * 100 / (divider + 1))
	else
		tank_health = round(tank_health * 100 / (divider))

	if(tank_health <= 5)
		to_chat(usr, "<span class='warning'>Warning! Systems failure, eject!</span><br>")
		return

	to_chat(usr, "<span class='warning'>Vehicle Status:</span><br>")
	to_chat(usr, "<span class='warning'>Overall vehicle integrity: [tank_health] percent.</span>")
	to_chat(usr, "<span class='warning'>M75 Smoke Deploy System: [smoke_ammo_current / 2] uses left.</span><br>")

	if(HP5 == null || HP5.obj_integrity <= 0)
		to_chat(usr, "<span class='danger'>Primary weapon: Unavailable.</span>")
	else
		to_chat(usr, "<span class='notice'>Primary weapon: [HP5.name].</span>")
		var/empty = TRUE
		for(var/i = 1; i <= length(HP5.clips); i++)
			if(length(HP5.clips[i]) > 1)
				empty = FALSE
				var/ammo = 0
				for(var/j = 2; j <= length(HP5.clips[i]); j++)
					var /obj/item/ammo_magazine/tank/A = HP5.clips[i][j]
					ammo += A.current_rounds
				to_chat(usr, "<span class='notice'>[HP5.clips[i][1]] ammunition: [ammo].</span>")
		if(empty)
			to_chat(usr, "<span class='danger'>Ammunition depleted.</span>")

	if(HP4 == null || HP4.obj_integrity <= 0)
		to_chat(usr, "<span class='danger'>Secondary weapon: Unavailable.</span>")
	else
		to_chat(usr, "<br><span class='notice'>Secondary weapon: [HP4.name].</span>")
		var/empty = TRUE
		for(var/i = 1; i <= length(HP4.clips); i++)
			if(length(HP4.clips[i]) > 1)
				empty = FALSE
				var/ammo = 0
				for(var/j = 2; j <= length(HP4.clips[i]); j++)
					var /obj/item/ammo_magazine/tank/A = HP4.clips[i][j]
					ammo += A.current_rounds
				to_chat(usr, "<span class='notice'>[HP4.clips[i][1]] ammunition: [ammo].</span><br>")
		if(empty)
			to_chat(usr, "<span class='danger'>Ammunition depleted.</span><br>")

/obj/vehicle/multitile/root/cm_armored/verb/switch_hp_ammo()
	set name = "W Switch Ammo"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	if(!can_use_hp(usr)) return

	var/list/slots = get_activatable_hardpoints()

	if(!length(slots))
		to_chat(usr, "<span class='warning'>All of the modules can't be unloaded or are broken.</span>")
		return

	var/slot = input("Select a slot.") in slots

	if(slot != HDPT_PRIMARY && slot != HDPT_SECDGUN)
		to_chat(usr, "<span class='warning'>Error. Unsupported module selected. Stopping operation.</span>")
		return

	var/obj/item/hardpoint/tank/HP = hardpoints[slot]

	if(!HP)
		to_chat(usr, "<span class='warning'>Primary weapon is not installed.</span>")
		return

	if(HP.obj_integrity < 0)
		to_chat(usr, "<span class='danger'>Warning! [HP.name] sustained critical damage and is not operatable!</span>")
		return

	var/list/ammo_type
	for(var/i = 1; i <= length(HP.clips); i++)
		if(length(HP.clips[i]) > 1)
			ammo_type += list(HP.clips[i][1])
	var/choice = input("Select a ammo type to reload.") in ammo_type
	for(var/i = 1; i <= length(ammo_type); i++)
		if(choice == ammo_type[i])
			choice = i
			break
	HP.change_ammo(choice, usr)

/obj/vehicle/multitile/root/cm_armored/verb/unload_hp()
	set name = "W Unload Weapon"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	if(!can_use_hp(usr)) return

	//TODO: make this a proc so I don't keep repeating this code
	var/list/slots = get_activatable_hardpoints()

	if(!length(slots))
		to_chat(usr, "<span class='warning'>All of the modules can't be reloaded or are broken.</span>")
		return

	var/answer = alert(usr, "Are you sure you want to reload?", , "Yes", "No") // added confirmation window, because you can't cancel reload once list of modules shows up
	if(answer == "No")
		return

	var/slot = input("Select a slot.") in slots

	if(slot != HDPT_PRIMARY && slot != HDPT_SECDGUN)
		to_chat(usr, "<span class='warning'>Error. Unsupported module selected. Stopping operation.</span>")
		return

	var/obj/item/hardpoint/tank/HP = hardpoints[slot]
	var/list/ammo_type
	for(var/i = 1; i <= length(HP.clips); i++)
		if(length(HP.clips[i]) > 1)
			ammo_type += list(HP.clips[i][1])
	var/choice = input("Select a ammo type to reload.") in ammo_type
	for(var/i = 1; i <= length(ammo_type); i++)
		if(choice == ammo_type[i])
			choice = i
			break

	to_chat(usr, "<span class='warning'>[HP.name]'s [HP.clips[choice][1]] magazine will be unloaded.</span>")
	HP.unload_mag(choice, usr)

/obj/vehicle/multitile/root/cm_armored/proc/get_activatable_hardpoints()
	var/list/slots = list()
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/tank/HP = hardpoints[slot]
		if(!HP) continue
		if(HP.obj_integrity <= 0) continue
		if(!HP.is_activatable) continue
		slots += slot
	return slots

//Specialness for armored vics
/obj/vehicle/multitile/root/cm_armored/load_hitboxes(datum/coords/dimensions, datum/coords/root_pos)

	var/start_x = -1 * root_pos.x_pos
	var/start_y = -1 * root_pos.x_pos
	var/end_x = start_x + dimensions.x_pos - 1
	var/end_y = start_y + dimensions.y_pos - 1

	for(var/i = start_x to end_x)

		for(var/j = start_y to end_y)

			if(i == 0 && j == 0)
				continue

			var/datum/coords/C = new
			C.x_pos = i
			C.y_pos = j
			C.z_pos = 0

			var/obj/vehicle/multitile/hitbox/cm_armored/H = new(locate(src.x + C.x_pos, src.y + C.y_pos, src.z))
			H.dir = dir
			H.root = src
			linked_objs[C] = H

/obj/vehicle/multitile/root/cm_armored/load_entrance_marker(var/datum/coords/rel_pos)

	entrance = new(locate(src.x + rel_pos.x_pos, src.y + rel_pos.y_pos, src.z))
	entrance.master = src
	linked_objs[rel_pos] = entrance

//Returns 1 or 0 if the slot in question has a broken installed hardpoint or not
/obj/vehicle/multitile/root/cm_armored/proc/is_slot_damaged(var/slot)
	var/obj/item/hardpoint/tank/HP = hardpoints[slot]

	if(!HP) return 0

	if(HP.obj_integrity <= 0) return 1

//Normal examine() but tells the player what is installed and if it's broken
/obj/vehicle/multitile/root/cm_armored/examine(var/mob/user)
	..()
	for(var/i in hardpoints)
		var/obj/item/hardpoint/tank/HP = hardpoints[i]
		if(!HP)
			to_chat(user, "There is nothing installed on the [i] hardpoint slot.")
		else
			if(isxeno(user))
				if(HP.obj_integrity <= 0)
					to_chat(user, "There is a broken module installed on [i] hardpoint slot.")
				if(HP.obj_integrity > 0 && (HP.obj_integrity < (HP.max_integrity / 3)))
					to_chat(user, "There is a heavily damaged module installed on [i] hardpoint slot.")
				if((HP.obj_integrity > (HP.max_integrity / 3)) && (HP.obj_integrity < (HP.max_integrity * (2/3))))
					to_chat(user, "There is a damaged module installed on [i] hardpoint slot.")			//removed modules' names for aliens.
				if((HP.obj_integrity > (HP.max_integrity * (2/3))) && (HP.obj_integrity < HP.max_integrity))
					to_chat(user, "There is a lightly damaged module installed on [i] hardpoint slot.")
				if(HP.obj_integrity == HP.max_integrity)
					to_chat(user, "There is a non-damaged module installed on [i] hardpoint slot.")
			else
				if(HP.obj_integrity <= 0)
					to_chat(user, "There is a broken [HP] installed on [i] hardpoint slot.")
				if(HP.obj_integrity > 0 && (HP.obj_integrity < (HP.max_integrity / 3)))
					to_chat(user, "There is a heavily damaged [HP] installed on [i] hardpoint slot.")
				if((HP.obj_integrity > (HP.max_integrity / 3)) && (HP.obj_integrity < (HP.max_integrity * (2/3))))
					to_chat(user, "There is a damaged [HP] installed on [i] hardpoint slot.")			//removed skills check, because any baldie PFC can tell if module is unscratched or will fall apart from touching it
				if((HP.obj_integrity > (HP.max_integrity * (2/3))) && (HP.obj_integrity < HP.max_integrity))
					to_chat(user, "There is a lightly damaged [HP] installed on [i] hardpoint slot.")
				if(HP.obj_integrity == HP.max_integrity)
					to_chat(user, "There is a non-damaged [HP] installed on [i] hardpoint slot.")
			//else
			//	to_chat(user, "There is a [HP.obj_integrity <= 0 ? "broken" : "working"] [HP] installed on the [i] hardpoint slot.")


//Special armored vic healthcheck that mainly updates the hardpoint states
/obj/vehicle/multitile/root/cm_armored/healthcheck()
	obj_integrity = max_integrity//The tank itself doesn't take damage
	var/i
	var/remove_person = 1 //Whether or not to call handle_all_modules_broken()
	for(i in hardpoints)
		var/obj/item/hardpoint/tank/H = hardpoints[i]
		if(!H) continue
		if(!H.obj_integrity)
			H.remove_buff()
			if(H.slot != HDPT_TREADS) damaged_hps |= H.slot //Not treads since their broken module overlay is the same as the broken hardpoint overlay
		else remove_person = FALSE //if something exists but isnt broken

	if(remove_person)
		handle_all_modules_broken()

	update_icon()


//Since the vics are 3x4 we need to swap between the two files with different dimensions
//Also need to offset to center the tank about the root object
/obj/vehicle/multitile/root/cm_armored/proc/rotate_tower(rotate_dir, updates_icon = TRUE)
	if(world.time < next_move_tower) return
	next_move_tower = world.time + tower_delay
	if(rotate_dir)
		switch(tower_dir)
			if(EAST)
				tower_dir = SOUTH
			if(WEST)
				tower_dir = NORTH
			if(SOUTH)
				tower_dir = WEST
			if(NORTH)
				tower_dir = EAST
	else
		switch(tower_dir)
			if(EAST)
				tower_dir = NORTH
			if(WEST)
				tower_dir = SOUTH
			if(SOUTH)
				tower_dir = EAST
			if(NORTH)
				tower_dir = WEST
	if(updates_icon)
		update_icon()

/obj/vehicle/multitile/root/cm_armored/proc/get_dir_tower(last_dir)
	switch(last_dir)
		if(EAST)
			if(dir == NORTH)
				return 0
			else
				return 1
		if(WEST)
			if(dir == SOUTH)
				return 0
			else
				return 1
		if(SOUTH)
			if(dir == EAST)
				return 0
			else
				return 1
		if(NORTH)
			if(dir == WEST)
				return 0
			else
				return 1

/obj/vehicle/multitile/root/cm_armored/update_icon()

	overlays.Cut()
	if(!tower_fixed && last_dir != dir)
		var/K = get_dir_tower(last_dir)
		rotate_tower(K, FALSE)
	last_dir = dir

	//Assuming 3x3 with half block overlaps in the tank's direction
	if(dir in list(NORTH, SOUTH))
		pixel_x = -32
		pixel_y = -48
		icon = 'RU-TGMC/icons/obj/vehicles/tank_NS.dmi'
		if (dir == NORTH)
			switch(tower_dir)
				if(EAST)
					pixel_x_tower = 15
					pixel_y_tower = -20
				if(WEST)
					pixel_x_tower = -50
					pixel_y_tower = -20
				if(SOUTH)
					pixel_x_tower = -24
					pixel_y_tower = -50
				if(NORTH)
					pixel_x_tower = -24
					pixel_y_tower = 20
		else
			switch(tower_dir)
				if(EAST)
					pixel_x_tower = 15
					pixel_y_tower = 30
				if(WEST)
					pixel_x_tower = -50
					pixel_y_tower = 30
				if(SOUTH)
					pixel_x_tower = -24
					pixel_y_tower = -5
				if(NORTH)
					pixel_x_tower = -24
					pixel_y_tower = 70

	else if(dir in list(EAST, WEST))
		pixel_x = -48
		pixel_y = -32
		icon = 'RU-TGMC/icons/obj/vehicles/tank_EW.dmi'
		if (dir == EAST)
			switch(tower_dir)
				if(EAST)
					pixel_x_tower = 0
					pixel_y_tower = -10
				if(WEST)
					pixel_x_tower = -70
					pixel_y_tower = -10
				if(SOUTH)
					pixel_x_tower = -30
					pixel_y_tower = -45
				if(NORTH)
					pixel_x_tower = -30
					pixel_y_tower = 25
		else
			switch(tower_dir)
				if(EAST)
					pixel_x_tower = 70
					pixel_y_tower = -10
				if(WEST)
					pixel_x_tower = 0
					pixel_y_tower = -10
				if(SOUTH)
					pixel_x_tower = 30
					pixel_y_tower = -45
				if(NORTH)
					pixel_x_tower = 30
					pixel_y_tower = 25

	//Tower tank
	var/image/I = image(icon = icon_tower, icon_state = icon_state_tower, dir = tower_dir, pixel_x = pixel_x_tower, pixel_y = pixel_y_tower)
	overlays += I

	//Basic iteration that snags the overlay from the hardpoint module object
	var/i
	for(i in hardpoints)
		var/obj/item/hardpoint/tank/H = hardpoints[i]

		if(i == HDPT_TREADS && (!H || !H.obj_integrity)) //Treads not installed or broken
			I = image(icon, icon_state = "damaged_hardpt_[i]")
			overlays += I
			continue

		if(H && !(i in list(HDPT_PRIMARY, HDPT_SECDGUN)))
			I = H.get_icon_image(0, 0, dir)
			overlays += I

		if(H && i in list(HDPT_PRIMARY, HDPT_SECDGUN, HDPT_ARMOR))
			var/icon_state_suffix = "0"
			var/icon_state_module = H.disp_icon_state
			if(H.obj_integrity <= 0)
				icon_state_suffix = "1"
			I = image(icon = icon_tower, icon_state = "[icon_state_module]_[icon_state_suffix]", dir = tower_dir, pixel_x = pixel_x_tower, pixel_y = pixel_y_tower)
			overlays += I

		if(damaged_hps.Find(i) && (i in list(HDPT_PRIMARY, HDPT_SECDGUN)))
			I = image(icon_tower, icon_state = "damaged_hardpt_[i]", dir = tower_dir)
			I.pixel_x = pixel_x_tower
			I.pixel_y = pixel_y_tower
			overlays += I
			continue

		if(damaged_hps.Find(i))
			I = image(icon, icon_state = "damaged_hardpt_[i]")
			overlays += I

//Hitboxes but with new names
/obj/vehicle/multitile/hitbox/cm_armored
	name = "Armored Vehicle"
	desc = "Get inside to operate the vehicle."
	luminosity = 7
	throwpass = 1 //You can lob nades over tanks, and there's some dumb check somewhere that requires this
	var/lastsound = 0

//If something want to delete this, it's probably either an admin or the shuttle
//If it's an admin, they want to disable this
//If it's the shuttle, it should do damage
//If fully repaired and moves at least once, the broken hitboxes will respawn according to multitile.dm
/obj/vehicle/multitile/hitbox/cm_armored/Destroy()
	var/obj/vehicle/multitile/root/cm_armored/C = root
	if(C) C.take_damage_type(1000000, "abstract")
	..()

//Tramplin' time, but other than that identical
/obj/vehicle/multitile/hitbox/cm_armored/Bump(atom/A)
	. = ..()
	var/facing = get_dir(src, A)
	var/turf/temp = loc
	var/turf/T = loc
	A.tank_collision(src, facing, T, temp)
	if(isliving(A))
		log_attack("[get_driver()] drove over [A] with [root]")

/obj/vehicle/multitile/hitbox/cm_armored/proc/get_driver()
	return "Someone"

/atom/proc/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	return

/mob/living/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/CA = C.root
	if(isxeno(src))
		var/mob/living/carbon/xenomorph/XEN = src
		switch(CA.vehicle_class)
			if(WEIGHT_LIGHT)
				switch(XEN.t_squish_level)
					if(0)
						knock_down(5)
					if(1)
						for(var/i=0;i<3;i++)
							temp = get_step(temp, facing)
						T = get_step(temp, pick(CARDINAL_DIRS))
						throw_at(T, 4, 1, CA, 1)
						knock_down(1)
						apply_damage(5 + rand(5, 10), BRUTE)
						if(istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow))
							apply_damage(10 + rand(5, 10), BRUTE)
					if(2)
						if(istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow))
							apply_damage(10 + rand(5, 10), BRUTE)
						step_away(src, C.root,0)
						step_away(src, C.root,0)
					if(3)
						//M.visible_message("<span class='danger'>[M] pushes against the [src], holding it in place with ease!</span>", "<span class='xenodanger'>You stopped [src]! It's no match to you!</span>")
						return
			if(WEIGHT_MEDIUM)
				switch(XEN.t_squish_level)
					if(0)
						knock_down(5)
					if(1)
						temp = get_step(temp, facing)
						temp = get_step(temp, facing)
						T = get_step(temp, pick(CARDINAL_DIRS))
						throw_at(T, 2, 1, C, 1)
						knock_down(1)
						apply_damage(5 + rand(5, 10), BRUTE)
						if(istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow))
							apply_damage(5 + rand(5, 10), BRUTE)
					if(2)
						step_away(src, C.root,0)
						knock_down(2)
						apply_damage(5 + rand(5, 10), BRUTE)
						if(istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow))
							apply_damage(5 + rand(5, 10), BRUTE)
					if(3)
						//M.visible_message("<span class='danger'>[M] pushes against the [src], holding it in place with effort!</span>", "<span class='xenodanger'>You stopped [src]!</span>")
						return
			if(WEIGHT_HEAVY)
				switch(XEN.t_squish_level)
					if(0)
						knock_down(5)
					if(1)
						knock_down(4)
						apply_damage(5 + rand(5, 10), BRUTE)
					if(2)
						step_away(src,C.root,0)
						knock_down(4)
						apply_damage(5 + rand(5, 10), BRUTE)
					if(3)
						step_away(src,C.root,0)
						//M.visible_message("<span class='danger'>[M] pushes against the [src], trying to hold it in place, but fails!</span>", "<span class='danger'>[src] is much heavier, you can't hold it in place!</span>")
						return
	if(!isxeno(src))
		if(buckled)
			buckled.unbuckle()
		step_away(src,C.root,0,0)
		knock_down(3)
		apply_damage(10 + rand(0, 10), BRUTE)
		if(istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow))
			apply_damage(10 + rand(5, 10), BRUTE)

/turf/closed/wall/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/tank/CA = C.root
	var/damage = 30
	var/tank_damage = 5

	if(facing == CA.old_dir && istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow) ) //Snowplow eliminates collision damage, and doubles damage dealt if we're facing the thing we're crushing
		var/obj/item/hardpoint/tank/armor/snowplow/SP = CA.hardpoints[HDPT_ARMOR]
		if(SP.obj_integrity)
			damage = 45
			tank_damage = 1

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time

/obj/machinery/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/tank/CA = C.root
	var/damage = 30
	var/tank_damage = 2

	if(facing == CA.old_dir && istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow) ) //Snowplow eliminates collision damage, and doubles damage dealt if we're facing the thing we're crushing
		var/obj/item/hardpoint/tank/armor/snowplow/SP = CA.hardpoints[HDPT_ARMOR]
		if(SP.obj_integrity)
			damage = 60
			tank_damage = 0

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[CA] rams into \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time

/obj/structure/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/tank/CA = C.root
	var/damage = 30
	var/tank_damage = 2

	if(facing == CA.old_dir && istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow) ) //Snowplow eliminates collision damage, and doubles damage dealt if we're facing the thing we're crushing
		var/obj/item/hardpoint/tank/armor/snowplow/SP = CA.hardpoints[HDPT_ARMOR]
		if(SP.obj_integrity)
			damage = 60
			tank_damage = 0

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[CA] crushes \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time

/obj/effect/alien/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	take_damage(40)

/obj/effect/alien/weeds/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	return

/obj/vehicle/multitile/hitbox/cm_armored/Move(atom/A, direction)
	for(var/mob/living/M in get_turf(src))
		M.tank_collision(src)

	. = ..()

	if(.)
		for(var/mob/living/M in get_turf(A))
			M.tank_collision(src)

/obj/vehicle/multitile/hitbox/cm_armored/Uncrossed(atom/movable/A)
	if(isliving(A))
		var/mob/living/M = A
		M.sleeping = 2

	return ..()

//Can't hit yourself with your own bullet
/obj/vehicle/multitile/hitbox/cm_armored/get_projectile_hit_chance(obj/item/projectile/P)
	if(P.firer == root) //Don't hit our own hitboxes
		return FALSE

	. = ..(P)

//For the next few, we're just tossing the handling up to the rot object
/obj/vehicle/multitile/hitbox/cm_armored/bullet_act(obj/item/projectile/P)
	return root.bullet_act(P)

/obj/vehicle/multitile/hitbox/cm_armored/ex_act(severity)
	return root.ex_act(severity)

/obj/vehicle/multitile/hitbox/cm_armored/attackby(obj/item/O, mob/user)
	return root.attackby(O, user)

/obj/vehicle/multitile/hitbox/cm_armored/attack_alien(mob/living/carbon/xenomorph/M, dam_bonus)
	return root.attack_alien(M, dam_bonus)

/obj/vehicle/multitile/hitbox/cm_armored/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		var/obj/vehicle/multitile/root/cm_armored/T = root
		T.take_damage_type(30, "acid")

//A bit icky, but basically if you're adjacent to the tank hitbox, you are then adjacent to the root object
/obj/vehicle/multitile/root/cm_armored/Adjacent(atom/A)
	for(var/i in linked_objs)
		var/obj/vehicle/multitile/hitbox/cm_armored/H = linked_objs[i]
		if(!H) continue
		if(get_dist(H, A) <= 1) return TRUE //Using get_dist() to avoid hidden code that recurs infinitely here
	return ..()

//Returns the ratio of damage to take, just a housekeeping thing
/obj/vehicle/multitile/root/cm_armored/proc/get_dmg_multi(type)
	if(!dmg_multipliers.Find(type)) return 0
	return dmg_multipliers[type] * dmg_multipliers["all"]

//Generic proc for taking damage
//ALWAYS USE THIS WHEN INFLICTING DAMAGE TO THE VEHICLES
/obj/vehicle/multitile/root/cm_armored/proc/take_damage_type(damage, type, atom/attacker)
	var/i
	for(i in hardpoints)
		var/obj/item/hardpoint/tank/HP = hardpoints[i]
		if(!istype(HP)) continue
		HP.obj_integrity -= damage * dmg_distribs[i] * get_dmg_multi(type)

	healthcheck()

	if(istype(attacker, /mob))
		var/mob/M = attacker
		log_attack("[src] took [damage] [type] damage from [M] ([M.client ? M.client.ckey : "disconnected"]).")
	else
		log_attack("[src] took [damage] [type] damage from [attacker].")

/obj/vehicle/multitile/root/cm_armored/get_projectile_hit_chance(obj/item/projectile/P)
	if(P.firer == src) //Don't hit our own hitboxes
		return FALSE

	return ..()

//Differentiates between damage types from different bullets
//Applies a linear transformation to bullet damage that will generally decrease damage done
/obj/vehicle/multitile/root/cm_armored/bullet_act(obj/item/projectile/P)

	var/dam_type = "bullet"


	if(istype(P, /datum/ammo/xeno/boiler_gas/corrosive))
		dam_type = "acid"
		take_damage_type(P.damage * 4, dam_type, P.firer)
		return
	if(P.ammo.flags_ammo_behavior & AMMO_XENO_ACID)
		dam_type = "acid"
		take_damage_type(P.damage * (0.75 + P.ammo.penetration/100), dam_type, P.firer)
		return
	if(istype(P, /datum/ammo/rocket/ap))
		dam_type = "explosive"
		take_damage_type(P.damage * (1.2 + P.ammo.penetration/100), dam_type, P.firer)
		return
	/*if(istype(P, /datum/ammo/rocket/tow))
		dam_type = "explosive"
		take_damage_type(P.damage * (1.5 + P.ammo.penetration/100), dam_type, P.firer)
		return*/
	if(istype(P, /datum/ammo/rocket/ltb))
		dam_type = "explosive"
		take_damage_type(P.damage * (3 + P.ammo.penetration/100), dam_type, P.firer)
		return

	take_damage_type(P.damage * (0.75 + P.ammo.penetration/100), dam_type, P.firer)
	playsound(src.loc, pick('sound/bullets/bullet_ricochet2.ogg', 'sound/bullets/bullet_ricochet3.ogg', 'sound/bullets/bullet_ricochet4.ogg', 'sound/bullets/bullet_ricochet5.ogg'), 25, 1)

//severity 1.0 explosions never really happen so we're gonna follow everyone else's example
/obj/vehicle/multitile/root/cm_armored/ex_act(var/severity)

	switch(severity)
		if(1.0)
			take_damage_type(rand(100, 150), "explosive")
			take_damage_type(rand(20, 40), "slash")

		if(2.0)
			take_damage_type(rand(60,80), "explosive")
			take_damage_type(rand(10, 15), "slash")

		if(3.0)
			take_damage_type(rand(20, 25), "explosive")

//Honestly copies some code from the Xeno files, just handling some special cases
/obj/vehicle/multitile/root/cm_armored/attack_alien(mob/living/carbon/xenomorph/M, dam_bonus)

	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper) + dam_bonus

	//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
	if(M.frenzy_aura > 0)
		damage += (M.frenzy_aura * 2)

	//Somehow we will deal no damage on this attack
	if(!damage)
		playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		M.do_attack_animation(src)
		M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
		"<span class='danger'>You lunge at [src]!</span>")
		return FALSE

	M.do_attack_animation(src)
	playsound(M.loc, pick('sound/weapons/alien_claw_metal1.ogg', 'sound/weapons/alien_claw_metal2.ogg', 'sound/weapons/alien_claw_metal3.ogg'), 25, 1)
	M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")

	take_damage_type(damage * ( (isxenoravager(M)) ? 2 : 1 ), "slash", M) //Ravs do a bitchin double damage

//used when entrance is blocked by something awful
/obj/vehicle/multitile/root/cm_armored/tank/proc/get_new_exit_point()
	var dir = pick(1, 2, 4, 5, 6, 8, 9, 10)
	var/turf/T
	T = get_step(src, dir)
	T = get_step(T, dir)
	return T

//checks entrance tile for closed turfs and un-passable objects and returns TRUE if it is so
/obj/vehicle/multitile/root/cm_armored/proc/tile_blocked_check(var/turf/Location)
	if(!isturf(Location))
		return TRUE
	var/turf/T = Location
	if(T.density)
		return TRUE
	for(var/atom/A in T.contents)
		if(A.density)
			return TRUE
	return FALSE

//Special case for entering the vehicle without using the verb
/obj/vehicle/multitile/root/cm_armored/attack_hand(var/mob/user)

	if(user.a_intent == "hurt")
		handle_harm_attack(user)
		return

	if(user.loc == entrance.loc)
		handle_player_entrance(user)
		return


	if(tile_blocked_check(get_turf(entrance)))		//vehicle entrance cannot be blocked to prevent TCs getting in
		handle_player_entrance(user)
		return

	. = ..()

/obj/vehicle/multitile/root/cm_armored/Entered(var/atom/movable/A)
	if(istype(A, /obj) && !istype(A, /obj/item/ammo_magazine/tank))
		A.forceMove(src.loc)
		return

	return ..()

//Need to take damage from crushers, probably too little atm
/obj/vehicle/multitile/root/cm_armored/Bumped(var/atom/A)
	..()

	if(istype(A, /mob/living/carbon/xenomorph/crusher))

		var/mob/living/carbon/xenomorph/crusher/C = A

		if(C.charge_speed < CHARGE_SPEED_MAX/(1.1)) //Arbitrary ratio here, might want to apply a linear transformation instead
			return

		take_damage_type(C.charge_speed * CRUSHER_CHARGE_TANK_MULTI, "blunt", C)

//Redistributes damage ratios based off of what things are attached (no armor means the armor doesn't mitigate any damage)
/obj/vehicle/multitile/root/cm_armored/proc/update_damage_distribs()
	dmg_distribs = GLOB.armorvic_dmg_distributions.Copy()//Assume full installs
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/tank/HP = hardpoints[slot]
		if(!HP) dmg_distribs[slot] = 0.0 //Remove empty slots' damage mitigation
	var/acc = 0
	for(var/slot in dmg_distribs)
		var/ratio = dmg_distribs[slot]
		acc += ratio //Get total current ratio applications
	if(acc == 0)
		return
	for(var/slot in dmg_distribs)
		var/ratio = dmg_distribs[slot]
		dmg_distribs[slot] = ratio/acc //Redistribute according to previous ratios for full damage taking, but ignoring empty slots

//Special cases abound, handled below or in subclasses
/obj/vehicle/multitile/root/cm_armored/attackby(var/obj/item/O, var/mob/user)

	if(istype(O, /obj/item/hardpoint/tank)) //Are we trying to install stuff?
		var/obj/item/hardpoint/tank/HP = O
		install_hardpoint(HP, user)
		update_damage_distribs()
		return

	if(istype(O, /obj/item/ammo_magazine)) //Are we trying to reload?
		var/obj/item/ammo_magazine/AM = O
		if(istype(O, /obj/item/ammo_magazine/tank/tank_slauncher))
			if(smoke_ammo_current == 0)
				smoke_ammo_current = smoke_ammo_max
				user.temporarilyRemoveItemFromInventory(O, 0)
				to_chat(user, "<span class='notice'>You load smoke system magazine into [src].</span>")
				playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
				return
			else
				to_chat(user, "<span class='notice'>You can't load new magazine until smoke launcher system automatically unload emptied one.</span>")
				return
		else
			handle_ammomag_attackby(AM, user)
		return

	if(iswelder(O) || iswrench(O)) //Are we trying to repair stuff?
		handle_hardpoint_repair(O, user)
		update_damage_distribs()
		return

	if(iscrowbar(O)) //Are we trying to remove stuff?
		uninstall_hardpoint(O, user)
		update_damage_distribs()
		return

	take_damage_type(O.force * 0.05, "blunt", user) //Melee weapons from people do very little damage

	. = ..()

/obj/vehicle/multitile/root/cm_armored/proc/handle_hardpoint_repair(var/obj/item/O, var/mob/user)

	//Need to the what the hell you're doing
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		to_chat(user, "<span class='warning'>You don't know what to do with [O] on [src].</span>")
		return

	if(!length(damaged_hps))
		to_chat(user, "<span class='notice'>All of the hardpoints are in working order.</span>")
		return

	//Pick what to repair
	var/slot = input("Select a slot to try and repair") in damaged_hps

	var/obj/item/hardpoint/tank/old = hardpoints[slot] //Is there something there already?

	if(old) //If so, fuck you get it outta here
		to_chat(user, "<span class='warning'>Please remove the attached hardpoint module first.</span>")
		return

	//Determine how many 3 second intervals to wait and if you have the right tool
	var/num_delays = 1
	switch(slot)
		if(HDPT_PRIMARY)
			num_delays = 5
			if(!iswelder(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
				return
			var/obj/item/tool/weldingtool/WT = O
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
				return
			WT.remove_fuel(num_delays, user)

		if(HDPT_SECDGUN)
			num_delays = 3
			if(!iswrench(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a wrench.</span>")
				return

		if(HDPT_SUPPORT)
			num_delays = 2
			if(!iswrench(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a wrench.</span>")
				return

		if(HDPT_ARMOR)
			num_delays = 10
			if(!iswelder(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
				return
			var/obj/item/tool/weldingtool/WT = O
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
				return
			WT.remove_fuel(num_delays, user)

	user.visible_message("<span class='notice'>[user] starts repairing the [slot] slot on [src].</span>",
		"<span class='notice'>You start repairing the [slot] slot on [src].</span>")

	if(!do_after(user, 30*num_delays))
		user.visible_message("<span class='notice'>[user] stops repairing the [slot] slot on [src].</span>",
			"<span class='notice'>You stop repairing the [slot] slot on [src].</span>")
		return

	if(!Adjacent(user))
		user.visible_message("<span class='notice'>[user] stops repairing the [slot] slot on [src].</span>",
			"<span class='notice'>You stop repairing the [slot] slot on [src].</span>")
		return

	user.visible_message("<span class='notice'>[user] repairs the [slot] slot on [src].</span>",
		"<span class='notice'>You repair the [slot] slot on [src].</span>")

	damaged_hps -= slot //We repaired it, good job

	update_icon()

//Relaoding stuff, pretty bare-bones and basic
/obj/vehicle/multitile/root/cm_armored/proc/handle_ammomag_attackby(var/obj/item/ammo_magazine/AM, var/mob/user)

	//No skill checks for reloading
	//Maybe I should delineate levels of skill for reloading, installation, and repairs?
	//That would make it easier to differentiate between the two for skills
	//Instead of using MT skills for these procs and AC skills for operation
	//Oh but wait then the MTs would be able to drive fuck that
	var/slot = input("Select a slot to try and refill") in hardpoints
	var/obj/item/hardpoint/tank/HP = hardpoints[slot]

	if(!HP)
		to_chat(user, "<span class='warning'>There is nothing installed on that slot.</span>")
		return

	HP.try_add_clip(AM, user)

//Putting on hardpoints
//Similar to repairing stuff, down to the time delay
/obj/vehicle/multitile/root/cm_armored/proc/install_hardpoint(var/obj/item/hardpoint/tank/HP, var/mob/user)

	if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		to_chat(user, "<span class='warning'>You don't know what to do with [HP] on [src].</span>")
		return

	if(HP.slot != HDPT_TREADS && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		to_chat(user, "<span class='warning'>You only know how to remove, install and field repair treads.</span>")
		return

	if(damaged_hps.Find(HP.slot))
		to_chat(user, "<span class='warning'>You need to fix the hardpoint first.</span>")
		return

	var/obj/item/hardpoint/tank/old = hardpoints[HP.slot]

	if(old)
		to_chat(user, "<span class='warning'>Remove the previous hardpoint module first.</span>")
		return

	user.visible_message("<span class='notice'>[user] begins installing [HP] on the [HP.slot] hardpoint slot on [src].</span>",
		"<span class='notice'>You begin installing [HP] on the [HP.slot] hardpoint slot on [src].</span>")

	var/num_delays = 1

	switch(HP.slot)
		if(HDPT_PRIMARY) num_delays = 5
		if(HDPT_SECDGUN) num_delays = 3
		if(HDPT_SUPPORT) num_delays = 2
		if(HDPT_ARMOR) num_delays = 10
		if(HDPT_TREADS) num_delays = 7

	if(!do_after(user, 30*num_delays))
		user.visible_message("<span class='warning'>[user] stops installing \the [HP] on [src].</span>", "<span class='warning'>You stop installing \the [HP] on [src].</span>")
		return

	user.visible_message("<span class='notice'>[user] installs \the [HP] on [src].</span>", "<span class='notice'>You install \the [HP] on [src].</span>")

	user.temporarilyRemoveItemFromInventory(HP, 0)

	add_hardpoint(HP, user)

//User-orientated proc for taking of hardpoints
//Again, similar to the above ones
/obj/vehicle/multitile/root/cm_armored/proc/uninstall_hardpoint(var/obj/item/O, var/mob/user)

	if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		to_chat(user, "<span class='warning'>You don't know what to do with [O] on [src].</span>")
		return

	var/slot = input("Select a slot to try and remove") in hardpoints

	if(slot != HDPT_TREADS && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		to_chat(user, "<span class='warning'>You only know how to remove, install and field repair treads.</span>")
		return

	var/obj/item/hardpoint/tank/old = hardpoints[slot]

	if(!old)
		to_chat(user, "<span class='warning'>There is nothing installed there.</span>")
		return

	user.visible_message("<span class='notice'>[user] begins removing [old] on the [old.slot] hardpoint slot on [src].</span>",
		"<span class='notice'>You begin removing [old] on the [old.slot] hardpoint slot on [src].</span>")

	var/num_delays = 1

	switch(slot)
		if(HDPT_PRIMARY) num_delays = 5
		if(HDPT_SECDGUN) num_delays = 3
		if(HDPT_SUPPORT) num_delays = 2
		if(HDPT_ARMOR) num_delays = 10
		if(HDPT_TREADS) num_delays = 7


	if(!do_after(user, 30*num_delays, TRUE))
		user.visible_message("<span class='warning'>[user] stops removing \the [old] on [src].</span>", "<span class='warning'>You stop removing \the [old] on [src].</span>")
		return
	if(old == hardpoints[HDPT_PRIMARY] || old == hardpoints[HDPT_SECDGUN])
		old.remove_buff(user)

	user.visible_message("<span class='notice'>[user] removes \the [old] on [src].</span>", "<span class='notice'>You remove \the [old] on [src].</span>")

	remove_hardpoint(old, user)

//General proc for putting on hardpoints
//ALWAYS CALL THIS WHEN ATTACHING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/add_hardpoint(var/obj/item/hardpoint/tank/HP, var/mob/user)

	HP.owner = src
	HP.apply_buff()
	HP.loc = src
	src.vehicle_weight += HP.hp_weight
	src.vehicle_class_update()

	hardpoints[HP.slot] = HP

	update_icon()

//General proc for taking off hardpoints
//ALWAYS CALL THIS WHEN REMOVING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/remove_hardpoint(var/obj/item/hardpoint/tank/old, var/mob/user)
	if(user)
		old.loc = user.loc
	else
		old.loc = entrance.loc
	old.remove_buff()

	src.vehicle_weight -= old.hp_weight
	src.vehicle_class_update()

	//if(old.obj_integrity <= 0)
	//	cdel(old)

	hardpoints[old.slot] = null
	update_icon()

/obj/vehicle/multitile/root/cm_armored/contents_explosion(severity, target)
	return