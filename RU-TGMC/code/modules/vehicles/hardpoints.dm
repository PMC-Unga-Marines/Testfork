/*
All of the hardpoints, for the tank and APC
*/

/obj/item/hardpoint

	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "tires" //Placeholder

	max_integrity = 100
	w_class = 15

	//If we use ammo, put it here
	var/obj/item/ammo_magazine/ammo_type = null //weapon ammo type to check with the magazine type we are trying to add

	//Strings, used to get the overlay for the armored vic
	var/disp_icon //This also differentiates tank vs apc vs other
	var/disp_icon_state

	var/next_use = 0
	var/ammo_switch_timer = 60
	var/is_activatable = 0
	var/max_angle = 180
	var/point_cost = 0

	var/list/clips = list()
	var/max_clips = 1
	var/cur_clips = 0
	var/cur_ammo_type = 1

//changed how ammo works. No more AMMO obj, we take what we need straight from first obj in CLIPS list (ex-backup_clips) and work with it.
//Every ammo mag now has CURRENT_AMMO value, also it is possible now to unload ALL mags from the gun, not only backup clips.

/obj/item/hardpoint/examine(mob/user)
	. = ..()
	var/status = obj_integrity <= 0.1 ? "broken" : "functional"
	var/span_class = obj_integrity <= 0.1 ? "<span class = 'danger'>" : "<span class = 'notice'>"
	if((user?.mind?.cm_skills && user.mind.cm_skills.engineer >= SKILL_ENGINEER_METAL) || isobserver(user))
		switch(PERCENT(obj_integrity / max_integrity))
			if(0.1 to 33)
				status = "heavily damaged"
				span_class = "<span class = 'warning'>"
			if(33.1 to 66)
				status = "damaged"
				span_class = "<span class = 'warning'>"
			if(66.1 to 90)
				status = "slighty damaged"
			if(90.1 to 100)
				status = "intact"
	to_chat(user, "[span_class]It's [status].</span>")

/obj/item/hardpoint/tank

	var/slot //What slot do we attach to?
	var/obj/vehicle/multitile/root/cm_armored/owner //Who do we work for?

	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "tires" //Placeholder

	var/hp_weight = 1	//this is new variable for weight of every single module as a part of new tank weight system

//Called on attaching, for weapons sets the actual cooldowns
/obj/item/hardpoint/tank/proc/apply_buff()
	return

//Called when removing, resets cooldown lengths, move delay, etc
/obj/item/hardpoint/tank/proc/remove_buff()
	return

//new proc for unloading specific type ammo mag
/obj/item/hardpoint/tank/proc/unload_mag()
	return

//new proc for switching current ammo type
/obj/item/hardpoint/tank/proc/change_ammo()
	return

//Called when you want to activate the hardpoint, such as a gun
//This can also be used for some type of temporary buff, up to you
/obj/item/hardpoint/tank/proc/active_effect(var/turf/T)
	return

/obj/item/hardpoint/tank/proc/deactivate()
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	if(C.gunner.client)
		C.gunner.client.mouse_pointer_icon = initial(C.gunner.client.mouse_pointer_icon)
	return

/obj/item/hardpoint/tank/proc/livingmob_interact(var/mob/living/M)
	return

//If our cooldown has elapsed
/obj/item/hardpoint/tank/proc/is_ready()
	if(world.time < next_use)
		to_chat(usr, "<span class='warning'>This module is not ready to be used yet.</span>")
		return FALSE
	if(!obj_integrity)
		to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
		return FALSE
	return TRUE

/obj/item/hardpoint/tank/proc/try_add_clip(var/obj/item/ammo_magazine/tank/A, var/mob/user)

	if(A.loc != user)
		return 0
	if(!max_clips)
		to_chat(user, "<span class='warning'>This module does not have room for additional ammo.</span>")
		return FALSE
	else if(length(clips) >= max_clips)
		to_chat(user, "<span class='warning'>The reloader is full.</span>")
		return FALSE
	else if(!istype(A, cur_ammo_type))
		to_chat(user, "<span class='warning'>That is the wrong ammo type.</span>")
		return FALSE

	to_chat(user, "<span class='notice'>Loading \the [A] in \the [owner].</span>")

	if(!do_after(user, 10, TRUE))
		to_chat(user, "<span class='warning'>Something interrupted you while reloading [owner].</span>")
		return 0

	user.temporarilyRemoveItemFromInventory(A, 0)
	user.visible_message("<span class='notice'>[user] installs [A] into [owner].</span>",
		"<span class='notice'>You install \the [A] in \the [owner].</span>")
	if (cur_clips == 0)
		user.visible_message("<span class='notice'>You hear clanking as \the [A] is getting automatically loaded into \the weapon.</span>")
		playsound(src, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
	else
		playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)

	for(var/j = 1; j <= length(clips); j++)
		if(A.ammo_tag == clips[j][1])
			clips[j] += A
			cur_clips ++
			break
	return 1

//Returns the image object to overlay onto the root object
/obj/item/hardpoint/tank/proc/get_icon_image(var/x_offset, var/y_offset, var/new_dir)

	var/icon_suffix = "NS"
	var/icon_state_suffix = "0"

	if(new_dir in list(NORTH, SOUTH))
		icon_suffix = "NS"
	else if(new_dir in list(EAST, WEST))
		icon_suffix = "EW"

	if(obj_integrity <= 0)
		icon_state_suffix = "1"

	return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

/obj/item/hardpoint/tank/proc/firing_arc(var/atom/A)
	var/turf/T = get_turf(A)
	var/dx = T.x - owner.x
	var/dy = T.y - owner.y
	var/deg = 0
	switch(owner.dir)
		if(EAST) deg = 0
		if(NORTH) deg = -90
		if(WEST) deg = -180
		if(SOUTH) deg = -270

	var/nx = dx * cos(deg) - dy * sin(deg)
	var/ny = dx * sin(deg) + dy * cos(deg)
	if(nx == 0) return max_angle >= 180
	var/angle = arctan(ny/nx)
	if(nx < 0) angle += 180
	return abs(angle) <= max_angle

//Delineating between slots
/obj/item/hardpoint/tank/primary
	slot = HDPT_PRIMARY
	is_activatable = 1

	remove_buff(var/mob/user)
		for(var/i in 1 to length(clips))
			var/list/ammo_type = clips[i]
			if(length(ammo_type) > 1)
				var/obj/item/ammo_magazine/A
				for(var/j = 2; j <= length(ammo_type); j++)
					A = ammo_type[j]
					A.Move(owner.entrance.loc)
					A.update_icon()
					ammo_type.Remove(A)
				user.visible_message("<span class='notice'>[user] removes [ammo_type[1]] ammunition from \the [src].</span>", "<span class='notice'>You remove [ammo_type[1]] ammunition from \the [src].</span>")

	unload_mag(var/mag_type, var/mob/user)
		to_chat(user, "<span class='notice'>Unloading [clips[mag_type][1]] magazine.</span>")
		var /obj/item/ammo_magazine/tank/A = clips[mag_type][2]
		sleep(10)
		A.Move(owner.entrance.loc)
		A.update_icon()
		var/list/list_mag_type = clips[mag_type]
		list_mag_type.Remove(A)
		clips[mag_type] = list_mag_type
		cur_clips--
		playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)

	change_ammo(var/type_choice, var/mob/user)

		cur_ammo_type = type_choice

		to_chat(user, "<span class='notice'>You select [clips[cur_ammo_type][1]]. Rearming will take 6 seconds.</span>")

		if(next_use < world.time + ammo_switch_timer)
			next_use = world.time + ammo_switch_timer
		return

//this will switch to any ammo that's left after unloading last mag
	proc/change_ammo_left(var/mob/user)
		if(length(clips[cur_ammo_type]) == 1)
			to_chat(user, "<span class='warning'>Warning! No [clips[cur_ammo_type][1]] ammo left.</span>")
		for(var/i = 1; i <= length(clips); i++)
			if(length(clips[i]) > 1)
				cur_ammo_type = i
				to_chat(user, "<span class='notice'>Switching to [clips[cur_ammo_type][1]]. Rearming will take 6 seconds.</span>")
				return
		to_chat(user, "<span class='danger'>Warning! All ammunition depleted!</span>")
		return


/obj/item/hardpoint/tank/secondary
	slot = HDPT_SECDGUN
	is_activatable = 1

	remove_buff(var/mob/user)
		for(var/i in 1 to length(clips))
			var/list/ammo_type = clips[i]
			if(length(ammo_type) > 1)
				var/obj/item/ammo_magazine/A
				for(var/j = 2; j <= length(ammo_type); j++)
					A = ammo_type[j]
					A.Move(owner.entrance.loc)
					A.update_icon()
					ammo_type.Remove(A)
				user.visible_message("<span class='notice'>[user] removes [ammo_type[1]] ammunition from \the [src].</span>", "<span class='notice'>You remove [ammo_type[1]] ammunition from \the [src].</span>")

	unload_mag(var/mag_type, var/mob/user)
		to_chat(user, "<span class='notice'>Unloading [clips[mag_type][1]] magazine.</span>")
		var /obj/item/ammo_magazine/tank/A = clips[mag_type][2]
		sleep(10)
		A.Move(owner.entrance.loc)
		A.update_icon()
		var/list/list_mag_type = clips[mag_type]
		list_mag_type.Remove(A)
		clips[mag_type] = list_mag_type
		cur_clips--
		playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)

	change_ammo(var/type_choice, var/mob/user)

		cur_ammo_type = type_choice

		to_chat(user, "<span class='notice'>You select [clips[cur_ammo_type][1]]. Rearming will take 6 seconds.</span>")

		if(next_use < world.time + ammo_switch_timer)
			next_use = world.time + ammo_switch_timer
		return

//this will switch to any ammo that's left after unloading last mag
	proc/change_ammo_left(var/mob/user)
		if(length(clips[cur_ammo_type]) == 1)
			to_chat(user, "<span class='warning'>Warning! No [clips[cur_ammo_type][1]] ammo left.</span>")
		for(var/i = 1; i <= length(clips); i++)
			if(length(clips[i]) > 1)
				cur_ammo_type = i
				to_chat(user, "<span class='notice'>Switching to [clips[cur_ammo_type][1]]. Rearming will take 6 seconds.</span>")
				return
		to_chat(user, "<span class='danger'>Warning! All ammunition depleted!</span>")
		return

/obj/item/hardpoint/tank/support
	slot = HDPT_SUPPORT

/obj/item/hardpoint/tank/armor
	slot = HDPT_ARMOR

/obj/item/hardpoint/tank/treads
	slot = HDPT_TREADS

//examine() that tells the player condition of the module
/obj/item/hardpoint/tank/examine(var/mob/user)
	..()
	if((user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer >= SKILL_ENGINEER_ENGI) || isobserver(user))
		var/cond = round(obj_integrity * 100 / max_integrity)
		if (cond > 0)
			to_chat(user, "Integrity: [cond]%.")
		else
			to_chat(user, "Integrity: 0%.")

////////////////////
// PRIMARY SLOTS // START
////////////////////
// USCM
////////////////////

/obj/item/hardpoint/tank/primary/cannon
	name = "M5 LTB Cannon"
	desc = "A primary 86mm cannon for tank."

	max_integrity = 500
	obj_integrity = 500
	point_cost = 100
	hp_weight = 2
	icon_state = "ltb_cannon"

	disp_icon = "tank"
	disp_icon_state = "ltb_cannon"

	ammo_type = new /obj/item/ammo_magazine/tank/ltb_cannon

	max_clips = 4
	max_angle = 45

	clips = list(
				list("AP"),
				list("HE"),
				list("HEAT")
				)

	apply_buff()
		owner.cooldowns["primary"] = 200
		owner.accuracies["primary"] = 0.97

	is_ready()
		if(world.time < next_use)
			var/CD = round(next_use - world.time) / 10
			to_chat(usr, "<span class='warning'>[src] will be ready to fire in [CD] seconds.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)
		var /obj/item/ammo_magazine/tank/ltb_cannon/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["primary"] * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"] * owner.w_ratios["w_prim_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), pick('sound/weapons/tank_cannon_fire1.ogg', 'sound/weapons/tank_cannon_fire2.ogg'), 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading magazine.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/primary/autocannon
	name = "M21 Autocannon"
	desc = "A primary light autocannon for tank. Designed for light scout tank. Shoots 30mm light HE rounds. Fire rate was reduced with adding IFF support."

	max_integrity = 400
	obj_integrity = 400
	point_cost = 100
	hp_weight = 1

	icon_state = "autocannon"

	disp_icon = "tank"
	disp_icon_state = "autocannon"

	ammo_type = new /obj/item/ammo_magazine/tank/autocannon

	max_clips = 3
	max_angle = 60
	clips = list(
				list("AP"),
				list("SCR")
				)

	apply_buff()
		owner.cooldowns["primary"] = 5
		owner.accuracies["primary"] = 0.97

	is_ready()
		if(world.time < next_use)
			to_chat(usr, "<span class='warning'>This module is not ready to be used yet.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)
		var /obj/item/ammo_magazine/tank/autocannon/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["primary"] * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"] * owner.w_ratios["w_prim_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'RU-TGMC/sound/weapons/tank_autocannon_fire1.ogg', 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading magazine.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/primary/minigun
	name = "M74 LTAA-AP Minigun"
	desc = "It's a minigun, what is not clear? Just go pew-pew-pew."

	max_integrity = 350
	obj_integrity = 350
	point_cost = 100
	hp_weight = 3

	icon_state = "ltaaap_minigun"

	disp_icon = "tank"
	disp_icon_state = "ltaaap_minigun"

	ammo_type = new /obj/item/ammo_magazine/tank/ltaaap_minigun
	max_clips = 2
	max_angle = 45

	clips = list(
				list("AP")
				)

	//Miniguns don't use a conventional cooldown
	//If you fire quickly enough, the cooldown decreases according to chain_delays
	//If you fire too slowly, you slowly slow back down
	//Also, different sounds play and it sounds sick, thanks Rahlzel
	var/chained = 0 //how many quick succession shots we've fired
	var/list/chain_delays = list(4, 4, 3, 3, 2, 2, 2, 1, 1) //the different cooldowns in deciseconds, sequentially

	//MAIN PROBLEM WITH THIS IMPLEMENTATION OF DELAYS:
	//If you spin all the way up and then stop firing, your chained shots will only decrease by 1
	//TODO: Implement a rolling average for seconds per shot that determines chain length without being slow or buggy
	//You'd probably have to normalize it between the length of the list and the actual ROF
	//But you don't want to map it below a certain point probably since seconds per shot would go to infinity

	//So, I came back to this and changed it by adding a fixed reset at 1.5 seconds or later, which seems reasonable
	//Now the cutoff is a little abrupt, but at least it exists. --MadSnailDisease

	apply_buff()
		owner.cooldowns["primary"] = 60 //will be overridden, please ignore
		owner.accuracies["primary"] = 0.33

	is_ready()
		if(world.time < next_use)
			to_chat(usr, "<span class='warning'>This module is not ready to be used yet.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)
		var /obj/item/ammo_magazine/tank/ltaaap_minigun/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		var/S = 'sound/weapons/tank_minigun_start.ogg'
		if(world.time - next_use <= 5)
			chained++ //minigun spins up, minigun spins down
			S = 'sound/weapons/tank_minigun_loop.ogg'
		else if(world.time - next_use >= 15) //Too long of a delay, they restart the chain
			chained = 1
		else //In between 5 and 15 it slows down but doesn't stop
			chained--
			S = 'sound/weapons/tank_minigun_stop.ogg'
		if(chained <= 0) chained = 1

		next_use = world.time + (chained > length(chain_delays) ? 0.5 : chain_delays[chained]) * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"] * owner.w_ratios["w_prim_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)

		playsound(get_turf(src), S, 60)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading magazine.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)


////////////////////
// USCM // END
////////////////////
// UPP // START
////////////////////
/obj/item/hardpoint/tank/primary/cannon/upp
	name = "Type 43 Cannon"
	desc = "A primary 86mm cannon for tank that shoots explosive rounds."
	point_cost = 0
	color = "#c2b678"

	ammo_type = new /obj/item/ammo_magazine/tank/ltb_cannon/upp

	active_effect(var/turf/T)
		var /obj/item/ammo_magazine/tank/ltb_cannon/upp/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["primary"] * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"] * owner.w_ratios["w_prim_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), pick('sound/weapons/tank_cannon_fire1.ogg', 'sound/weapons/tank_cannon_fire2.ogg'), 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading magazine.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/primary/autocannon/upp
	name = "Type 41 Autocannon"
	desc = "A primary light autocannon for tank. Designed for light scout tank. Shoots 30mm HE rounds."
	point_cost = 0
	color = "#c2b678"

	ammo_type = new /obj/item/ammo_magazine/tank/autocannon/ap/upp

	active_effect(var/turf/T)
		var /obj/item/ammo_magazine/tank/autocannon/ap/upp/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["primary"] * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"] * owner.w_ratios["w_prim_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'RU-TGMC/sound/weapons/tank_autocannon_fire1.ogg', 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading magazine.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)


////////////////////
// PRIMARY SLOTS // END
////////////////////

/////////////////////
// SECONDARY SLOTS //
/////////////////////
// USCM // START
/////////////////////
/obj/item/hardpoint/tank/secondary/flamer
	name = "M7 \"Dragon\" Flamethrower Unit"
	desc = "A secondary weapon for tank. Don't let it fool you, it's not your ordinary flamer, this thing literally shoots fireballs. No kidding."

	max_integrity = 300
	obj_integrity = 300
	point_cost = 100
	hp_weight = 2

	icon_state = "flamer"

	disp_icon = "tank"
	disp_icon_state = "flamer"

	ammo_type = new /obj/item/ammo_magazine/tank/flamer
	max_clips = 2
	max_angle = 90
	clips = list(
				list("NPL")
				)

	apply_buff()
		owner.cooldowns["secondary"] = 20
		owner.accuracies["secondary"] = 0.5

	is_ready()
		if(world.time < next_use)
			var/CD = round(next_use - world.time) / 10
			to_chat(usr, "<span class='warning'>[src] will be ready to fire in [CD] seconds.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/tank/flamer/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/tank_flamethrower.ogg', 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Fuel tank emptied, unloading fuel tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/secondary/towlauncher
	name = "M8-3 TOW Launcher"
	desc = "A secondary weapon for tank that shoots powerful AP rockets. Deals heavy damage, but only on direct hits."

	max_integrity = 500
	obj_integrity = 500
	point_cost = 100
	hp_weight = 2

	icon_state = "tow_launcher"

	disp_icon = "tank"
	disp_icon_state = "towlauncher"

	ammo_type = new /obj/item/ammo_magazine/tank/towlauncher
	max_clips = 2
	max_angle = 90
	clips = list(
				list("TOW")
				)

	apply_buff()
		owner.cooldowns["secondary"] = 150
		owner.accuracies["secondary"] = 0.97

	is_ready()
		if(world.time < next_use)
			var/CD = round(next_use - world.time) / 10
			to_chat(usr, "<span class='warning'>[src] will be ready to fire in [CD] seconds.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)

		var obj/item/ammo_magazine/tank/towlauncher/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/secondary/m56cupola
	name = "M56 \"Cupola\""
	desc = "A secondary weapon for tank. Refitted M56 has higher accuracy and rate of fire. Compatible with IFF system."

	max_integrity = 350
	obj_integrity = 350
	point_cost = 100
	hp_weight = 2
	var/burst_amount = 3

	icon_state = "m56_cupola"

	disp_icon = "tank"
	disp_icon_state = "m56cupola"

	ammo_type = new /obj/item/ammo_magazine/tank/m56_cupola
	max_clips = 2
	max_angle = 75
	clips = list(
				list("SMR")
				)


	apply_buff()
		owner.cooldowns["secondary"] = 8
		owner.accuracies["secondary"] = 0.8

	is_ready()
		if(world.time < next_use)
			to_chat(usr, "<span class='warning'>This module is not ready to be used yet.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/tank/m56_cupola/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		var/bullets_fired = burst_amount
		if(A.current_rounds < burst_amount)
			bullets_fired = A.current_rounds

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		for(var/i = 0; i <= bullets_fired; i++)
			if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
				T = get_step(T, pick(CARDINAL_DIRS))
			var/obj/item/projectile/P = new
			P.generate_bullet(new A.default_ammo)
			P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
			playsound(get_turf(src), pick(list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')), 60, 1)
			sleep(2)
		A.current_rounds -= bullets_fired

		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/secondary/grenade_launcher
	name = "M92 Grenade Launcher"
	desc = "A secondary weapon for tank that shoots HEDP grenades further than you see. No, seriously, that's how it works."

	max_integrity = 500
	obj_integrity = 500
	point_cost = 100
	hp_weight = 2

	icon_state = "glauncher"

	disp_icon = "tank"
	disp_icon_state = "glauncher"

	ammo_type = new /obj/item/ammo_magazine/tank/tank_glauncher
	max_clips = 2
	max_angle = 90
	clips = list(
				list("GRN")
				)

	apply_buff()
		owner.cooldowns["secondary"] = 7
		owner.accuracies["secondary"] = 0.8

	is_ready()
		if(world.time < next_use)
			to_chat(usr, "<span class='warning'>[src] is not ready to fire yet.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/tank/tank_glauncher/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/gun_m92_attachable.ogg', 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/////////////////////
// USCM // END
/////////////////////
// UPP // START
/////////////////////

/obj/item/hardpoint/tank/secondary/flamer/upp
	name = "Type 04 Flamethrower"
	desc = "A secondary weapon for tank. Don't let it fool you, it's not your ordinary flamer, this thing literally shoots fireballs. Not kidding."
	point_cost = 0
	color = "#c2b678"

	ammo_type = new /obj/item/ammo_magazine/tank/flamer/upp

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/tank/flamer/upp/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/tank_flamethrower.ogg', 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Fuel tank emptied, unloading fuel tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/secondary/towlauncher/upp
	name = "Type 05 PTRK"
	desc = "A secondary weapon for tank that shoots powerful AP rockets. Deals heavy damage, but only on direct hits."
	point_cost = 0
	color = "#c2b678"

	ammo_type = new /obj/item/ammo_magazine/tank/towlauncher/upp

	active_effect(var/turf/T)

		var obj/item/ammo_magazine/tank/towlauncher/upp/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/secondary/m56cupola/upp
	name = "Type 01 PKT"
	desc = "A secondary weapon for tank. Heavy-hitting machine gun."
	point_cost = 0
	color = "#c2b678"

	ammo_type = new /obj/item/ammo_magazine/tank/m56_cupola/upp

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/tank/m56_cupola/upp/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), pick(list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')), 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/obj/item/hardpoint/tank/secondary/grenade_launcher/upp
	name = "Type 02 AGS"
	point_cost = 0
	color = "#c2b678"

	ammo_type = new /obj/item/ammo_magazine/tank/tank_glauncher/upp

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/tank/tank_glauncher/upp/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"] * owner.w_ratios["w_secd_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/gun_m92_attachable.ogg', 60, 1)
		A.current_rounds--
		if(!A.current_rounds)
			to_chat(usr, "<span class='notice'>Magazine emptied, unloading tank.</span>")
			sleep(10)
			A.Move(owner.entrance.loc)
			A.update_icon()
			var/list/list_cur_type = clips[cur_ammo_type]
			list_cur_type.Remove(A)
			cur_clips--
			playsound(owner, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
			change_ammo_left(usr)

/////////////////////
// SECONDARY SLOTS // END
/////////////////////

///////////////////
// SUPPORT SLOTS
///////////////////
// USCM // START
///////////////////
//Slauncher was built in tank.
/obj/item/hardpoint/tank/support/smoke_launcher
	name = "M75 Smoke Deploy System"
	desc = "Launches smoke forward to obscure vision."

	max_integrity = 300
	obj_integrity = 300
	point_cost = 0
	hp_weight = 1

	icon_state = "slauncher_0"

	disp_icon = "tank"
	disp_icon_state = "slauncher"

	ammo_type = new /obj/item/ammo_magazine/tank/tank_slauncher
	max_clips = 4
	is_activatable = 1
	clips = list(
				list("SMK")
				)

	apply_buff()
		owner.cooldowns["support"] = 30
		owner.accuracies["support"] = 0.8

	is_ready()
		if(world.time < next_use)
			var/CD = round(next_use - world.time) / 10
			to_chat(usr, "<span class='warning'>[src] will be ready to fire in [CD] seconds.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/tank/tank_slauncher/A = clips[cur_ammo_type][2]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>This module does not have any ammo.</span>")
			return

		next_use = world.time + owner.cooldowns["support"] * owner.misc_ratios["supp_cool"]
		if(!prob(owner.accuracies["support"] * 100 * owner.misc_ratios["supp_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/tank_smokelauncher_fire.ogg', 60, 1)
		A.current_rounds--

	get_icon_image(var/x_offset, var/y_offset, var/new_dir)

		var/icon_suffix = "NS"
		var/icon_state_suffix = "0"

		if(new_dir in list(NORTH, SOUTH))
			icon_suffix = "NS"
		else if(new_dir in list(EAST, WEST))
			icon_suffix = "EW"

		var /obj/item/ammo_magazine/tank/tank_slauncher/A = clips[cur_ammo_type][2]
		if(obj_integrity <= 0) icon_state_suffix = "1"
		else if(A.current_rounds <= 0) icon_state_suffix = "2"

		return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

/obj/item/hardpoint/tank/support/weapons_sensor
	name = "M40 Integrated Weapons Sensor Array"
	desc = "Improves the accuracy and fire rate of all installed weapons. Actually more useful than you may think."

	max_integrity = 250
	obj_integrity = 250
	point_cost = 100
	hp_weight = 1

	icon_state = "warray"

	disp_icon = "tank"
	disp_icon_state = "warray"

	apply_buff()
		owner.misc_ratios["prim_cool"] = 0.67
		owner.misc_ratios["secd_cool"] = 0.67
		owner.misc_ratios["supp_cool"] = 0.67

		owner.misc_ratios["prim_acc"] = 1.67
		owner.misc_ratios["secd_acc"] = 1.67
		owner.misc_ratios["supp_acc"] = 1.67

	remove_buff()
		owner.misc_ratios["prim_cool"] = 1.0
		owner.misc_ratios["secd_cool"] = 1.0
		owner.misc_ratios["supp_cool"] = 1.0

		owner.misc_ratios["prim_acc"] = 1.0
		owner.misc_ratios["secd_acc"] = 1.0
		owner.misc_ratios["supp_acc"] = 1.0

/obj/item/hardpoint/tank/support/overdrive_enhancer
	name = "M103 Overdrive Enhancer"
	desc = "Pimp your ride. Increases the movement and turn speed of the vehicle it's attached to."

	max_integrity = 250
	obj_integrity = 250
	point_cost = 100
	hp_weight = 1

	icon_state = "odrive_enhancer"

	disp_icon = "tank"
	disp_icon_state = "odrive_enhancer"

	apply_buff()
		owner.misc_ratios["OD_buff"] = TRUE

	remove_buff()
		owner.misc_ratios["OD_buff"] = FALSE

/obj/item/hardpoint/tank/support/artillery_module
	name = "M6 Artillery Module"
	desc = "A bunch of enhanced optics and targeting computers. Greatly increases range of view of a gunner. Also adds structures visibility even in complete darkness."

	max_integrity = 250
	obj_integrity = 250
	point_cost = 100
	is_activatable = 1
	var/is_active = 0
	hp_weight = 1

	var/view_buff = 12 //This way you can VV for more or less fun
	var/view_tile_offset = 5

	icon_state = "artillery"

	disp_icon = "tank"
	disp_icon_state = "artillerymod"

	active_effect(var/turf/T)
		var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
		if(!C.gunner) return
		var/mob/M = C.gunner
		if(!M.client) return
		if(is_active)
			M.client.change_view(7)
			M.client.pixel_x = 0
			M.client.pixel_y = 0
			C.is_zoomed = 0
			is_active = 0
			return
		M.client.change_view(view_buff)
		C.is_zoomed = 1
		is_active = 1
		switch(C.dir)
			if(NORTH)
				M.client.pixel_x = 0
				M.client.pixel_y = view_tile_offset * 32
			if(SOUTH)
				M.client.pixel_x = 0
				M.client.pixel_y = -1 * view_tile_offset * 32
			if(EAST)
				M.client.pixel_x = view_tile_offset * 32
				M.client.pixel_y = 0
			if(WEST)
				M.client.pixel_x = -1 * view_tile_offset * 32
				M.client.pixel_y = 0

	deactivate()
		var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
		if(!C.gunner) return
		var/mob/M = C.gunner
		if(!M.client) return
		is_active = 0
		M.client.change_view(7)
		M.client.pixel_x = 0
		M.client.pixel_y = 0
		C.is_zoomed = 0
		if(M.client)
			M.client.mouse_pointer_icon = initial(M.client.mouse_pointer_icon)

	remove_buff()
		deactivate()

	is_ready()
		return 1

///////////////////
// USCM // END
///////////////////
// UPP // START
///////////////////

/obj/item/hardpoint/tank/support/weapons_sensor/upp
	name = "Type 31 Weapons Modernization Kit"
	point_cost = 0
	color = "#c2b678"

/obj/item/hardpoint/tank/support/artillery_module/upp
	name = "Type 33 Artillery Module"
	point_cost = 0
	color = "#c2b678"

///////////////////
// SUPPORT SLOTS // END
///////////////////

/////////////////
// ARMOR SLOTS // START
/////////////////

/obj/item/hardpoint/tank/armor/ballistic
	name = "M65-B Armor"
	desc = "Standard tank armor. Middle ground in everything, from damage resistance to weight."

	max_integrity = 800
	obj_integrity = 800
	point_cost = 100
	hp_weight = 7

	icon_state = "ballistic_armor"

	disp_icon = "tank"
	disp_icon_state = "ballistic_armor"

	apply_buff()
		owner.dmg_multipliers["acid"] = 0.9
		owner.dmg_multipliers["slash"] = 0.67
		owner.dmg_multipliers["explosive"] = 0.7
		owner.dmg_multipliers["blunt"] = 0.7
		owner.dmg_multipliers["bullet"] = 0.2

	remove_buff()
		owner.dmg_multipliers["acid"] = 1.5
		owner.dmg_multipliers["slash"] = 1.0
		owner.dmg_multipliers["explosive"] = 1.0
		owner.dmg_multipliers["blunt"] = 0.9
		owner.dmg_multipliers["bullet"] = 0.67

/obj/item/hardpoint/tank/armor/caustic
	name = "M70 \"Caustic\" Armor"
	desc = "Special set of tank armor. Purpose: reduce vehicle parts degradation in hostile surroundings on planets with unstable and highly corrosive atmosphere."

	max_integrity = 700
	obj_integrity = 700
	point_cost = 100
	hp_weight = 5

	icon_state = "caustic_armor"

	disp_icon = "tank"
	disp_icon_state = "caustic_armor"

	apply_buff()
		owner.dmg_multipliers["acid"] = 0.1
		owner.dmg_multipliers["slash"] = 0.9
		owner.dmg_multipliers["explosive"] = 0.9
		owner.dmg_multipliers["bullet"] = 0.4

	remove_buff()
		owner.dmg_multipliers["acid"] = 1.5
		owner.dmg_multipliers["slash"] = 1.0
		owner.dmg_multipliers["explosive"] = 1.0
		owner.dmg_multipliers["bullet"] = 0.67

/obj/item/hardpoint/tank/armor/concussive
	name = "M66-LC Armor"
	desc = "Light armor, designed for recon type of tank loadouts. Offers less protection in exchange for better maneuverability. After initial tests resistance to blunt damage was increased due to drivers driving into walls."

	max_integrity = 600
	obj_integrity = 600

	point_cost = 100
	hp_weight = 3

	icon_state = "concussive_armor"

	disp_icon = "tank"
	disp_icon_state = "concussive_armor"

	apply_buff()
		owner.dmg_multipliers["acid"] = 1.0
		owner.dmg_multipliers["slash"] = 0.67
		owner.dmg_multipliers["explosive"] = 0.8
		owner.dmg_multipliers["blunt"] = 0.5
		owner.dmg_multipliers["bullet"] = 0.4

	remove_buff()
		owner.dmg_multipliers["acid"] = 1.5
		owner.dmg_multipliers["slash"] = 1.0
		owner.dmg_multipliers["explosive"] = 1.0
		owner.dmg_multipliers["blunt"] = 0.9
		owner.dmg_multipliers["bullet"] = 0.67

/obj/item/hardpoint/tank/armor/paladin
	name = "M90 \"Paladin\" Armor"
	desc = "Heavy armor for heavy tank. Converts your tank into what an essentially is a slowly moving bunker. High resistance to almost all types of damage."

	max_integrity = 1000
	obj_integrity = 1000
	point_cost = 100
	hp_weight = 10

	icon_state = "paladin_armor"

	disp_icon = "tank"
	disp_icon_state = "paladin_armor"

	apply_buff()
		owner.dmg_multipliers["acid"] = 0.4
		owner.dmg_multipliers["slash"] = 0.3
		owner.dmg_multipliers["explosive"] = 0.4
		owner.dmg_multipliers["blunt"] = 0.4
		owner.dmg_multipliers["bullet"] = 0.05 //juggernaut is not meant to be just shot, fuck off

	remove_buff()
		owner.dmg_multipliers["acid"] = 1.5
		owner.dmg_multipliers["slash"] = 1.0
		owner.dmg_multipliers["explosive"] = 1.0
		owner.dmg_multipliers["blunt"] = 0.9
		owner.dmg_multipliers["bullet"] = 0.67

/obj/item/hardpoint/tank/armor/snowplow
	name = "M37 \"Snowplow\" Armor"
	desc = "Special set of tank armor, equipped with multipurpose front \"snowplow\". Designed to remove snow and demine minefields. As a result armor has high explosion damage resistance in front, while offering low protection from other types of damage."

	max_integrity = 700
	obj_integrity = 700
	point_cost = 100
	hp_weight = 4

	icon_state = "snowplow"

	disp_icon = "tank"
	disp_icon_state = "snowplow"

	apply_buff()
		owner.dmg_multipliers["acid"] = 1.0
		owner.dmg_multipliers["slash"] = 0.9
		owner.dmg_multipliers["explosive"] = 0.5	//demining minefields, after all
		owner.dmg_multipliers["blunt"] = 0.4
		owner.dmg_multipliers["bullet"] = 0.5

	remove_buff()
		owner.dmg_multipliers["acid"] = 1.5
		owner.dmg_multipliers["slash"] = 1.0
		owner.dmg_multipliers["explosive"] = 1.0
		owner.dmg_multipliers["blunt"] = 0.9
		owner.dmg_multipliers["bullet"] = 0.67

	livingmob_interact(var/mob/living/M)
		var/turf/targ = get_step(M, owner.dir)
		targ = get_step(M, owner.dir)
		targ = get_step(M, owner.dir)
		M.throw_at(targ, 4, 2, src, 1)
		M.apply_damage(7 + rand(0, 13), BRUTE)

/////////////////
// USCM // END
/////////////////
// UPP // START
/////////////////

/obj/item/hardpoint/tank/armor/ballistic/upp
	name = "Type 50 MBT Armor"
	desc = "Standard UPP tank armor. Offers some decent explosion protection."
	point_cost = 0
	color = "#c2b678"

	max_integrity = 900
	obj_integrity = 900

	apply_buff()
		owner.dmg_multipliers["acid"] = 0.8
		owner.dmg_multipliers["slash"] = 0.67
		owner.dmg_multipliers["explosive"] = 0.5
		owner.dmg_multipliers["blunt"] = 0.5
		owner.dmg_multipliers["bullet"] = 0.2

/////////////////
// ARMOR SLOTS // END
/////////////////

/////////////////
// TREAD SLOTS // START
/////////////////

/obj/item/hardpoint/tank/treads/standard
	name = "M2 Tank Treads"
	desc = "Standard tank treads. Suprisingly, greatly improves vehicle moving speed."

	max_integrity = 500
	obj_integrity = 500
	point_cost = 25
	hp_weight = 1

	icon_state = "treads"

	disp_icon = "tank"
	disp_icon_state = "treads"

	get_icon_image(var/x_offset, var/y_offset, var/new_dir)
		return null //Handled in update_icon()


/obj/item/hardpoint/tank/treads/heavy
	name = "M2-R Tank Treads"
	desc = "Heavily reinforced tank treads. Three times heavier but can endure more damage. Has special protective layer akin to M70 armor."

	max_integrity = 750
	obj_integrity = 750
	point_cost = 25
	hp_weight = 3

	icon_state = "treads"

	disp_icon = "tank"
	disp_icon_state = "treads"

	get_icon_image(var/x_offset, var/y_offset, var/new_dir)
		return null //Handled in update_icon()

//repairing treads in field
/obj/item/hardpoint/tank/treads/attackby(var/obj/item/O, var/mob/user)

	//Need to the what the hell you're doing
	if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		to_chat(user, "<span class='warning'>You don't know what to do with [O] on [src].</span>")
		return
	if(!iswelder(O))
		to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
		return
	var/obj/item/tool/weldingtool/WT = O
	if(!WT.isOn())
		to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
		return
	if(WT.get_fuel() < 8)
		to_chat(user, "<span class='warning'>You don't have enough fuel in your [WT].</span>")
		return
	var/q_health = round(src.max_integrity * 0.25)
	if(obj_integrity >= q_health)
		to_chat(user, "<span class='warning'>You can't repair treads more than that in the field.</span>")
		return
	user.visible_message("<span class='notice'>[user] starts field repair on the [src].</span>", "<span class='notice'>You start field repair on the [src].</span>")

	if(!do_after(user, 150, TRUE))
		user.visible_message("<span class='notice'>[user] stops repairing the [src].</span>", "<span class='notice'>You stop repairing the [src].</span>")
		return
	if(!Adjacent(user))
		user.visible_message("<span class='notice'>[user] stops repairing the [src].</span>", "<span class='notice'>You stop repairing the [src].</span>")
		return
	WT.remove_fuel(8, user)
	user.visible_message("<span class='notice'>[user] finishes repairing the [src].</span>", "<span class='notice'>You repair the [src] as best as you can in field conditions.</span>")

	src.obj_integrity = q_health //We repaired it to 25%, good job

	. = ..()


/////////////////
// USCM // END
/////////////////
// UPP // START
/////////////////

/obj/item/hardpoint/tank/treads/standard/upp
	name = "Type 07 Tank Treads"
	desc = "Standard UPP tank treads. They look quite tough."
	point_cost = 0
	color = "#c2b678"

	max_integrity = 650
	obj_integrity = 650

/////////////////
// TREAD SLOTS // END
/////////////////

///////////////
// AMMO MAGS // START
///////////////

//Special ammo magazines for hardpoint modules. Some aren't here since you can use normal magazines on them
/obj/item/ammo_magazine/tank
	icon = 'RU-TGMC/icons/obj/items/ammo.dmi'
	flags_magazine = 0 //No refilling
	var/point_cost = 0
	var/ammo_tag = null

/obj/item/ammo_magazine/tank/ltb_cannon
	name = "!Generic LTB mag. Do not use!"
	desc = "DELETETHIS"
	caliber = "86mm" //Making this unique on purpose
	icon_state = "ltbcannon_4"
	w_class = 15 //Heavy fucker
	default_ammo = /datum/ammo/rocket/ltb
	current_rounds = 4
	max_rounds = 4
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/primary

	update_icon()
		icon_state = "ltbcannon_[current_rounds]"

/obj/item/ammo_magazine/tank/ltb_cannon/ap
	name = "M5 LTB Cannon AP Magazine"
	desc = "A primary armament cannon AP shells magazine"
	default_ammo = /datum/ammo/rocket/ltb/ap
	ammo_tag = "AP"
	icon_state = "ltbcannon_ap_4"
	gun_type = /obj/item/hardpoint/tank/primary/cannon

	update_icon()
		icon_state = "ltbcannon_ap_[current_rounds]"

/obj/item/ammo_magazine/tank/ltb_cannon/he
	name = "M5 LTB Cannon HE Magazine"
	desc = "A primary armament cannon HE shells magazine"
	default_ammo = /datum/ammo/rocket/ltb/he
	ammo_tag = "HE"
	icon_state = "ltbcannon_he_4"
	gun_type = /obj/item/hardpoint/tank/primary/cannon

	update_icon()
		icon_state = "ltbcannon_he_[current_rounds]"

/obj/item/ammo_magazine/tank/ltb_cannon/heat
	name = "M5 LTB Cannon HEAT Magazine"
	desc = "A primary armament cannon HEAT shells magazine"
	default_ammo = /datum/ammo/rocket/ltb/heat
	ammo_tag = "HEAT"
	icon_state = "ltbcannon_heat_4"
	gun_type = /obj/item/hardpoint/tank/primary/cannon

	update_icon()
		icon_state = "ltbcannon_heat_[current_rounds]"

/obj/item/ammo_magazine/tank/autocannon
	name = "M21 Autocannon Magazine"
	desc = "A primary armament autocannon magazine"
	caliber = "30mm"
	icon_state = "autocannon_1"
	w_class = 10
	default_ammo = /datum/ammo/rocket/autocannon
	current_rounds = 40
	max_rounds = 40
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/primary/autocannon

	update_icon()
		if(current_rounds >0)
			icon_state = "autocannon_1"
		else
			icon_state = "autocannon_0"

/obj/item/ammo_magazine/tank/autocannon/scr
	name = "M21 Autocannon SCR Magazine"
	desc = "A primary armament autocannon SCR magazine. Special Concussion Round is Anti Personnel round developed and used by USCM."
	icon_state = "autocannon_scr_1"
	default_ammo = /datum/ammo/rocket/autocannon/scr
	ammo_tag = "SCR"

	update_icon()
		if(current_rounds >0)
			icon_state = "autocannon_scr_1"
		else
			icon_state = "autocannon_scr_0"

/obj/item/ammo_magazine/tank/autocannon/ap
	name = "M21 Autocannon AP Magazine"
	desc = "A primary armament autocannon AP magazine. Standard Armor Piercing 30mm round."
	caliber = "30mm"
	icon_state = "autocannon_ap_1"
	w_class = 10
	default_ammo = /datum/ammo/rocket/autocannon/ap
	ammo_tag = "AP"

	update_icon()
		if(current_rounds >0)
			icon_state = "autocannon_ap_1"
		else
			icon_state = "autocannon_ap_0"

/obj/item/ammo_magazine/tank/ltaaap_minigun
	name = "M74 LTAA-AP Minigun Magazine"
	desc = "A primary armament minigun magazine"
	caliber = "7.62x51mm" //Correlates to miniguns
	icon_state = "painless"
	w_class = 10
	default_ammo = /datum/ammo/bullet/minigun/tank
	ammo_tag = "AP"
	current_rounds = 300
	max_rounds = 300
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/primary/minigun

/obj/item/ammo_magazine/tank/flamer
	name = "M70 Flamer Tank"
	desc = "A secondary armament flamethrower magazine"
	caliber = "UT-Napthal Fuel" //correlates to flamer mags
	icon_state = "flametank_large"
	w_class = 12
	default_ammo = /datum/ammo/flamethrower/tank_flamer
	ammo_tag = "NPL"
	current_rounds = 120
	max_rounds = 120
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/secondary/flamer


/obj/item/ammo_magazine/tank/towlauncher
	name = "M8-3 TOW Launcher Magazine"
	desc = "A secondary armament rocket magazine"
	caliber = "rocket" //correlates to any rocket mags
	icon_state = "quad_rocket"
	w_class = 10
	default_ammo = /datum/ammo/rocket/tow
	ammo_tag = "TOW"
	current_rounds = 3
	max_rounds = 3
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/secondary/towlauncher


/obj/item/ammo_magazine/tank/m56_cupola
	name = "M56 Cupola Magazine"
	desc = "A secondary armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "big_ammo_box"
	w_class = 12
	default_ammo = /datum/ammo/bullet/smartgun
	ammo_tag = "SMR"
	current_rounds = 500
	max_rounds = 500
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/secondary/m56cupola


/obj/item/ammo_magazine/tank/tank_glauncher
	name = "M92 Grenade Launcher Magazine"
	desc = "A secondary armament grenade magazine"
	caliber = "grenade"
	icon_state = "glauncher_2"
	w_class = 9
	default_ammo = /datum/ammo/grenade_container
	ammo_tag = "GRN"
	current_rounds = 20
	max_rounds = 20
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/secondary/grenade_launcher

	update_icon()
		if(current_rounds >= max_rounds)
			icon_state = "glauncher_2"
		else if(current_rounds <= 0)
			icon_state = "glauncher_0"
		else
			icon_state = "glauncher_1"


/obj/item/ammo_magazine/tank/tank_slauncher
	name = "Smoke Deploy System Magazine"
	desc = "A smoke cover system grenade magazine"
	caliber = "grenade"
	icon_state = "slauncher_1"
	w_class = 12
	default_ammo = /datum/ammo/grenade_container/smoke
	ammo_tag = "SMK"
	current_rounds = 12
	max_rounds = 12
	point_cost = 0
	gun_type = /obj/item/hardpoint/tank/support/smoke_launcher

	update_icon()
		icon_state = "slauncher_[current_rounds <= 0 ? "0" : "1"]"
///////////////
// USCM // END
///////////////
// UPP // START
///////////////

/obj/item/ammo_magazine/tank/ltb_cannon/upp
	name = "!Generic UPP LTB mag. Do not use!"
	gun_type = /obj/item/hardpoint/tank/primary/cannon/upp
	color = "#c2b678"

/obj/item/ammo_magazine/tank/ltb_cannon/upp/ap
	name = "Type 43 Cannon AP Magazine"
	desc = "A primary armament AP shells cannon magazine"
	default_ammo = /datum/ammo/rocket/ltb/ap
	ammo_tag = "AP"
	icon_state = "ltbcannon_ap_4"
	gun_type = /obj/item/hardpoint/tank/primary/cannon/upp

	update_icon()
		icon_state = "ltbcannon_ap_[current_rounds]"

/obj/item/ammo_magazine/tank/ltb_cannon/upp/he
	name = "Type 43 Cannon HE Magazine"
	desc = "A primary armament HE shells cannon magazine"
	default_ammo = /datum/ammo/rocket/ltb/he
	ammo_tag = "HE"
	icon_state = "ltbcannon_he_4"
	gun_type = /obj/item/hardpoint/tank/primary/cannon/upp

	update_icon()
		icon_state = "ltbcannon_he_[current_rounds]"

/obj/item/ammo_magazine/tank/autocannon/ap/upp
	name = "Type 41 Autocannon Magazine"
	default_ammo = /datum/ammo/rocket/autocannon/ap/upp
	gun_type = /obj/item/hardpoint/tank/primary/autocannon/upp
	point_cost = 0
	color = "#c2b678"

/obj/item/ammo_magazine/tank/m56_cupola/upp
	name = "Type 01 PKT Magazine"
	default_ammo = /datum/ammo/bullet/smartgun/lethal
	gun_type = /obj/item/hardpoint/tank/secondary/m56cupola/upp
	point_cost = 0
	color = "#c2b678"

/obj/item/ammo_magazine/tank/flamer/upp
	name = "Type 04 Flamethrower Tank"
	gun_type = /obj/item/hardpoint/tank/secondary/flamer/upp
	point_cost = 0
	color = "#c2b678"

/obj/item/ammo_magazine/tank/towlauncher/upp
	name = "Type 05 PTRK Magazine"
	gun_type = /obj/item/hardpoint/tank/secondary/towlauncher/upp
	point_cost = 0
	color = "#c2b678"

/obj/item/ammo_magazine/tank/tank_glauncher/upp
	name = "Type 02 AGS Magazine"
	gun_type = /obj/item/hardpoint/tank/secondary/grenade_launcher/upp
	point_cost = 0
	color = "#c2b678"

/obj/item/ammo_magazine/tank/tank_slauncher/upp
	point_cost = 0
	color = "#c2b678"

///////////////
// AMMO MAGS // END
///////////////
// TANK HARDPOINTS // END
///////////////

////////////////////////////////////////////////////////////////////////////
//							APC HARDPOINTS // START
////////////////////////////////////////////////////////////////////////////

/obj/item/hardpoint/apc

	var/slot //What slot do we attach to?
	var/obj/vehicle/multitile/root/cm_transport/owner //Who do we work for?

	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "tires" //Placeholder

//Called on attaching, for weapons sets the actual cooldowns
/obj/item/hardpoint/apc/proc/apply_buff()
	return

//Called when removing, resets cooldown lengths, move delay, etc
/obj/item/hardpoint/apc/proc/remove_buff()
	return

//Called when you want to activate the hardpoint, such as a gun
//This can also be used for some type of temporary buff, up to you
/obj/item/hardpoint/apc/proc/active_effect(var/turf/T)
	return

/obj/item/hardpoint/apc/proc/deactivate()
	var/obj/vehicle/multitile/root/cm_transport/apc/C = owner
	if(C.gunner.client)
		C.gunner.client.mouse_pointer_icon = initial(C.gunner.client.mouse_pointer_icon)
	return

/obj/item/hardpoint/apc/proc/livingmob_interact(var/mob/living/M)
	return

//If our cooldown has elapsed
/obj/item/hardpoint/apc/proc/is_ready()
	if(owner.z == 2 || owner.z == 3)
		to_chat(usr, "<span class='warning'>Don't fire here, you'll blow a hole in the ship!</span>")
		return 0
	return 1

/obj/item/hardpoint/apc/proc/try_add_clip(var/obj/item/ammo_magazine/apc/A, var/mob/user)

	if(max_clips == 0)
		to_chat(user, "<span class='warning'>This module does not have room for additional ammo.</span>")
		return 0
	else if(length(clips) >= max_clips)
		to_chat(user, "<span class='warning'>The reloader is full.</span>")
		return 0
	else if(!istype(A, ammo_type.type))
		to_chat(user, "<span class='warning'>That is the wrong ammo type.</span>")
		return 0

	to_chat(user, "<span class='notice'>Installing \the [A] in \the [owner].</span>")

	if(!do_after(user, 10, TRUE))
		to_chat(user, "<span class='warning'>Something interrupted you while reloading [owner].</span>")
		return 0

	user.temporarilyRemoveItemFromInventory(A, 0)
	user.visible_message("<span class='notice'>[user] installs [A] into [owner].</span>",
		"<span class='notice'>You install \the [A] in \the [owner].</span>")
	if (length(clips) == 0)
		user.visible_message("<span class='notice'>You hear clanking as \the [A] is getting automatically loaded into \the weapon.</span>")
		playsound(src, 'sound/weapons/gun_mortar_unpack.ogg', 40, 1)
	else
		playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	clips += A
	return 1

//Returns the image object to overlay onto the root object
/obj/item/hardpoint/apc/proc/get_icon_image(var/x_offset, var/y_offset, var/new_dir)

	var/icon_suffix = "NS"
	var/icon_state_suffix = "0"

	if(new_dir in list(NORTH, SOUTH))
		icon_suffix = "NS"
	else if(new_dir in list(EAST, WEST))
		icon_suffix = "EW"

	if(obj_integrity <= 0)
		icon_state_suffix = "1"

	return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

/obj/item/hardpoint/apc/proc/firing_arc(var/atom/A)
	var/turf/T = get_turf(A)
	var/dx = T.x - owner.x
	var/dy = T.y - owner.y
	var/deg = 0
	switch(owner.dir)
		if(EAST) deg = 0
		if(NORTH) deg = -90
		if(WEST) deg = -180
		if(SOUTH) deg = -270

	var/nx = dx * cos(deg) - dy * sin(deg)
	var/ny = dx * sin(deg) + dy * cos(deg)
	if(nx == 0) return max_angle >= 180
	var/angle = arctan(ny/nx)
	if(nx < 0) angle += 180
	return abs(angle) <= max_angle

//Delineating between slots
/obj/item/hardpoint/apc/primary
	slot = HDPT_PRIMARY
	is_activatable = 1

/obj/item/hardpoint/apc/secondary
	slot = HDPT_SECDGUN
	is_activatable = 1

/obj/item/hardpoint/apc/support
	slot = HDPT_SUPPORT

/obj/item/hardpoint/apc/wheels
	slot = HDPT_WHEELS

//examine() that tells the player condition of the module
/obj/item/hardpoint/apc/examine(var/mob/user)
	..()
	if(!istype(src, /obj/item/hardpoint/apc/wheels) && (user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer >= SKILL_ENGINEER_ENGI) || isobserver(user))
		var/cond = round(obj_integrity * 100 / max_integrity)
		if (cond > 0)
			to_chat(user, "Integrity: [cond]%.")
		else
			to_chat(user, "Integrity: 0%.")

/obj/item/hardpoint/apc/wheels/examine(var/mob/user)
	..()
	if((user.mind && user.mind.cm_skills) || isobserver(user))
		var/cond = round(obj_integrity * 100 / max_integrity)
		if (cond > 0)
			to_chat(user, "Integrity: [cond]%.")
		else
			to_chat(user, "Integrity: 0%.")

////////////////////
// PRIMARY SLOTS // START
////////////////////
// USCM
////////////////////

/obj/item/hardpoint/apc/primary/dual_cannon
	name = "M78 Dual Cannon"
	desc = "A primary 45mm dual cannon for APC."

	max_integrity = 500
	obj_integrity = 500
	point_cost = 100

	icon_state = "dual_cannon"

	disp_icon = "apcarrier"
	disp_icon_state = "dual_cannon"

	ammo_type = new /obj/item/ammo_magazine/apc/dual_cannon

	max_clips = 3
	max_angle = 100

	apply_buff()
		owner.cooldowns["primary"] = 8
		owner.accuracies["primary"] = 0.97

	is_ready()
		if(world.time < next_use)
			to_chat(usr, "<span class='warning'>[src] is not ready to fire yet.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)
		var /obj/item/ammo_magazine/apc/dual_cannon/A = clips[1]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>No ammo. Reloading is required.</span>")
			return

		next_use = world.time + owner.cooldowns["primary"] * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'RU-TGMC/sound/weapons/tank_autocannon_fire1.ogg', 60, 1)
		A.current_rounds--

////////////////////
// USCM // END
////////////////////
// UPP // START
////////////////////
/obj/item/hardpoint/apc/primary/dual_cannon/upp
	name = "Type 60 \"Dvustvolka\""
	desc = "A primary 45mm dual cannon for BTR."
	color = "#c2b678"

	point_cost = 0

	ammo_type = new /obj/item/ammo_magazine/apc/dual_cannon/upp

	active_effect(var/turf/T)
		var /obj/item/ammo_magazine/apc/dual_cannon/upp/A = clips[1]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>No ammo. Reloading is required.</span>")
			return

		next_use = world.time + owner.cooldowns["primary"] * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"]))
			T = get_step(T, pick(CARDINAL_DIRS))
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'RU-TGMC/sound/weapons/tank_autocannon_fire1.ogg', 60, 1)
		A.current_rounds--
////////////////////
// PRIMARY SLOTS // END
////////////////////

/////////////////////
// SECONDARY SLOTS //
/////////////////////
// USCM // START
/////////////////////
/obj/item/hardpoint/apc/secondary/front_cannon
	name = "M26 Frontal Cannon"
	desc = "A secondary frontal cannon for APC."

	max_integrity = 300
	obj_integrity = 300
	point_cost = 100

	icon_state = "front_cannon"

	disp_icon = "apcarrier"
	disp_icon_state = "front_cannon"

	ammo_type = new /obj/item/ammo_magazine/apc/front_cannon
	max_clips = 2
	max_angle = 80
	var/burst_amount = 4

	apply_buff()
		owner.cooldowns["secondary"] = 10
		owner.accuracies["secondary"] = 0.6

	is_ready()
		if(world.time < next_use)
			to_chat(usr, "<span class='warning'>[src] is not ready to fire yet.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/apc/front_cannon/A = clips[1]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>No ammo. Reloading is required.</span>")
			return

		var/bullets_fired = burst_amount
		if(A.current_rounds < burst_amount)
			bullets_fired = A.current_rounds

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]

		for(var/i = 0; i <= bullets_fired; i++)
			if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
				T = get_step(T, pick(CARDINAL_DIRS))
			var/obj/item/projectile/P = new
			P.generate_bullet(new A.default_ammo)
			P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
			playsound(get_turf(src), pick(list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')), 60, 1)
			sleep(2)
		A.current_rounds -= bullets_fired
/////////////////////
// USCM // END
/////////////////////
// UPP // START
/////////////////////

/obj/item/hardpoint/apc/secondary/front_cannon/upp
	name = "Type 08 \"Minipushka\""
	desc = "A secondary frontal cannon for BTR."
	color = "#c2b678"

	point_cost = 0

	ammo_type = new /obj/item/ammo_magazine/apc/front_cannon/upp

	active_effect(var/turf/T)

		var /obj/item/ammo_magazine/apc/front_cannon/upp/A = clips[1]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>No ammo. Reloading is required.</span>")
			return

		var/bullets_fired = burst_amount
		if(A.current_rounds < burst_amount)
			bullets_fired = A.current_rounds

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]

		for(var/i = 0; i <= bullets_fired; i++)
			if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
				T = get_step(T, pick(CARDINAL_DIRS))
			var/obj/item/projectile/P = new
			P.generate_bullet(new A.default_ammo)
			P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
			playsound(get_turf(src), pick(list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')), 60, 1)
			sleep(2)
		A.current_rounds -= bullets_fired
/////////////////////

/////////////////////
// SECONDARY SLOTS // END
/////////////////////


///////////////////
// SUPPORT SLOTS
///////////////////
// USCM // START
///////////////////
/obj/item/hardpoint/apc/support/flare_launcher
	name = "M9 Flare Launcher System"
	desc = "Launches flares forward light up the area."

	max_integrity = 300
	obj_integrity = 300
	point_cost = 100

	icon_state = "flare_launcher"

	disp_icon = "apcarrier"
	disp_icon_state = "flare_launcher"

	ammo_type = new /obj/item/ammo_magazine/apc/flare_launcher
	max_clips = 3
	is_activatable = 1


	apply_buff()
		owner.cooldowns["support"] = 50

	is_ready()
		if(world.time < next_use)
			var/CD = round(next_use - world.time) / 10
			to_chat(usr, "<span class='warning'>[src] will be ready to fire in [CD] seconds.</span>")
			return 0
		if(obj_integrity <= 0)
			to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
			return 0
		return 1

	active_effect(var/turf/T)

		var/obj/item/ammo_magazine/apc/flare_launcher/A = clips[1]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>No ammo. Reloading is required.</span>")
			return

		var/turf/F
		var/turf/S
		var/right_dir
		var/left_dir
		F = get_step(owner.loc, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		left_dir = turn(owner.dir, -90)
		S = get_step(F, left_dir)
		S = get_step(S, left_dir)
		S = get_step(S, left_dir)
		right_dir = turn(owner.dir, 90)
		F = get_step(F, right_dir)
		F = get_step(F, right_dir)
		F = get_step(F, right_dir)


		next_use = world.time + owner.cooldowns["support"] * owner.misc_ratios["support"]
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(F, owner, src, 8, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/gun_flare.ogg', 60, 1)
		A.current_rounds--
		sleep (10)
		var/obj/item/projectile/G = new
		G.generate_bullet(new A.default_ammo)
		G.fire_at(S, owner, src, 8, G.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/gun_flare.ogg', 60, 1)
		A.current_rounds--

	get_icon_image(var/x_offset, var/y_offset, var/new_dir)

		var/icon_suffix = "NS"
		var/icon_state_suffix = "0"

		if(new_dir in list(NORTH, SOUTH))
			icon_suffix = "NS"
		else if(new_dir in list(EAST, WEST))
			icon_suffix = "EW"

		var /obj/item/ammo_magazine/apc/flare_launcher/A = clips[1]
		if(obj_integrity <= 0)
			icon_state_suffix = "1"
		else
			if(clips[1] == null || A.current_rounds <= 0)
				icon_state_suffix = "2"

		return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)
////////////////////
// USCM // END
////////////////////
// UPP // START
////////////////////

/obj/item/hardpoint/apc/support/flare_launcher/upp
	name = "Type 67 \"Bengalskiy Ogon\""
	desc = "Launches flares forward light up the area."
	color = "#c2b678"

	point_cost = 0

	ammo_type = new /obj/item/ammo_magazine/apc/flare_launcher/upp

	active_effect(var/turf/T)

		var/obj/item/ammo_magazine/apc/flare_launcher/upp/A = clips[1]
		if(A == null || A.current_rounds <= 0)
			to_chat(usr, "<span class='warning'>No ammo. Reloading is required.</span>")
			return

		var/turf/F
		var/turf/S
		var/right_dir
		var/left_dir
		F = get_step(owner.loc, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		F = get_step(F, owner.dir)
		left_dir = turn(owner.dir, -90)
		S = get_step(F, left_dir)
		S = get_step(S, left_dir)
		S = get_step(S, left_dir)
		right_dir = turn(owner.dir, 90)
		F = get_step(F, right_dir)
		F = get_step(F, right_dir)
		F = get_step(F, right_dir)


		next_use = world.time + owner.cooldowns["support"] * owner.misc_ratios["support"]
		var/obj/item/projectile/P = new
		P.generate_bullet(new A.default_ammo)
		P.fire_at(F, owner, src, 8, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/gun_flare.ogg', 60, 1)
		A.current_rounds--
		sleep (10)
		var/obj/item/projectile/G = new
		G.generate_bullet(new A.default_ammo)
		G.fire_at(S, owner, src, 8, G.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/gun_flare.ogg', 60, 1)
		A.current_rounds--

///////////////////
// SUPPORT SLOTS // END
///////////////////

/////////////////
// WHEELS SLOTS // START
/////////////////

/obj/item/hardpoint/apc/wheels
	name = "M3 APC Wheels Kit"
	desc = "Standard armored APC wheels. Suprisingly, greatly improves vehicle moving speed."

	max_integrity = 500
	obj_integrity = 500
	point_cost = 25

	icon_state = "wheels"

	disp_icon = "apcarrier"
	disp_icon_state = "wheels"

	get_icon_image(var/x_offset, var/y_offset, var/new_dir)
		return null //Handled in update_icon()

	apply_buff()
		owner.move_delay = 2.5

	remove_buff()
		owner.move_delay = 50

//repairing wheels in field
/obj/item/hardpoint/apc/wheels/attackby(var/obj/item/O, var/mob/user)

	if(!user.mind || !user.mind.cm_skills)
		to_chat(user, "<span class='warning'>You don't know what to do with [O] on [src].</span>")
		return
	if(!iswrench(O))
		to_chat(user, "<span class='warning'>That's the wrong tool. Use a wrench.</span>")
		return
	var/q_health = round(src.max_integrity * 0.25)
	if(obj_integrity >= q_health)
		to_chat(user, "<span class='warning'>You can't repair [src] more than that in the field.</span>")
		return
	user.visible_message("<span class='notice'>[user] starts field repair on the [src].</span>", "<span class='notice'>You start field repair on the [src].</span>")

	if(!do_after(user, 150, TRUE))
		user.visible_message("<span class='notice'>[user] stops repairing the [src].</span>", "<span class='notice'>You stop repairing the [src].</span>")
		return
	if(!Adjacent(user))
		user.visible_message("<span class='notice'>[user] stops repairing the [src].</span>", "<span class='notice'>You stop repairing the [src].</span>")
		return
	user.visible_message("<span class='notice'>[user] finishes repairing the [src].</span>", "<span class='notice'>You repair the [src] as best as you can in field conditions.</span>")

	src.obj_integrity = q_health //We repaired it to 25%, good job

	. = ..()
//////////////////
// USCM // END
//////////////////
// UPP // START
//////////////////

/obj/item/hardpoint/apc/wheels/upp
	name = "Type 06 Nabor Kolyos BTR"
	desc = "Standard armored BTR wheels. Suprisingly, greatly improves vehicle moving speed."
	color = "#c2b678"

	point_cost = 0

/////////////////
// WHEELS SLOTS // END
/////////////////

///////////////
// AMMO MAGS // START
///////////////

//Special ammo magazines for hardpoint modules. Some aren't here since you can use normal magazines on them
/obj/item/ammo_magazine/apc
	icon = 'RU-TGMC/icons/obj/items/ammo.dmi'
	flags_magazine = 0 //No refilling
	var/point_cost = 0

/obj/item/ammo_magazine/apc/dual_cannon
	name = "M78 Dualcannon Magazine"
	desc = "A primary armament dualcannon magazine"
	caliber = "45mm"
	icon_state = "autocannon_scr_apc_1"
	w_class = 10
	default_ammo = /datum/ammo/rocket/autocannon/scr/apc
	current_rounds = 30
	max_rounds = 30
	point_cost = 0
	gun_type = /obj/item/hardpoint/apc/primary/dual_cannon

	update_icon()
		if(current_rounds >0)
			icon_state = "autocannon_scr_apc_1"
		else
			icon_state = "autocannon_scr_apc_0"

/obj/item/ammo_magazine/apc/front_cannon
	name = "M26 Frontal Cannon Magazine"
	desc = "A secondary armament cannon magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "front_cannon_1"
	w_class = 12
	default_ammo = /datum/ammo/bullet/front_cannon
	current_rounds = 400
	max_rounds = 400
	point_cost = 0
	gun_type = /obj/item/hardpoint/apc/secondary/front_cannon

	update_icon()
		if(current_rounds >0)
			icon_state = "front_cannon_1"
		else
			icon_state = "front_cannon_0"

/obj/item/ammo_magazine/apc/flare_launcher
	name = "M9 Flare Launcher System Magazine"
	desc = "A flare launcher system magazine"
	caliber = "flare"
	icon_state = "flauncher_1"
	w_class = 12
	default_ammo = /datum/ammo/flare
	current_rounds = 10
	max_rounds = 10
	point_cost = 0
	gun_type = /obj/item/hardpoint/apc/support/flare_launcher

	update_icon()
		icon_state = "flauncher_[current_rounds <= 0 ? "0" : "1"]"

////////////////
// USCM // END
////////////////
// UPP // START
////////////////

/obj/item/ammo_magazine/apc/dual_cannon/upp
	name = "Type 60 \"Dvustvolka\" Magazine"
	desc = "A primary armament dualcannon magazine"
	color = "#c2b678"

	point_cost = 0
	default_ammo = /datum/ammo/rocket/autocannon/ap/upp
	gun_type = /obj/item/hardpoint/apc/primary/dual_cannon/upp

/obj/item/ammo_magazine/apc/front_cannon/upp
	name = "Type 08 \"Minipushka\" Magazine"
	desc = "A secondary armament cannon magazine"
	color = "#c2b678"

	point_cost = 0
	default_ammo = /datum/ammo/bullet/front_cannon
	gun_type = /obj/item/hardpoint/apc/secondary/front_cannon/upp


/obj/item/ammo_magazine/apc/flare_launcher/upp
	name = "Type 67 \"Bengalskiy Ogon\" Magazine"
	desc = "A flare launcher system magazine"
	color = "#c2b678"

	point_cost = 0
	gun_type = /obj/item/hardpoint/apc/support/flare_launcher/upp

///////////////
// AMMO MAGS // END
///////////////
// APC HARDPOINTS // END
///////////////

////////////////////
// BROKEN MODULES //
////////////////////

/obj/item/hardpoint/tank/primary/cannon/broken
	obj_integrity = 0

/obj/item/hardpoint/tank/secondary/m56cupola/broken
	obj_integrity = 0

/obj/item/hardpoint/tank/support/smoke_launcher/broken
	obj_integrity = 0

 /obj/item/hardpoint/tank/armor/ballistic/broken
	obj_integrity = 0

 /obj/item/hardpoint/tank/treads/standard/broken
	obj_integrity = 0