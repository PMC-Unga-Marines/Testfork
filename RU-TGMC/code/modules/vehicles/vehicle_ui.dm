//Here'll be dragons
//Also NanoUI for vehicles (yeah, I'm a bit of masochist).

//Tank goes first

//little QoL won't be bad, aight? Aiiiiight???
/obj/vehicle/multitile/root/cm_armored/tank/verb/access_ui()
	set name = "G Activate UI"
	set category = "Vehicle"
	set src = usr.loc

	ui_interact(usr)


/obj/vehicle/multitile/root/cm_armored/tank/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)

	if(user != gunner && user != driver && user != swap_seat)
		ui.close()
		return

	var/obj/item/hardpoint/tank/support/HP1 = hardpoints[HDPT_ARMOR]
	var/obj/item/hardpoint/tank/treads/HP2 = hardpoints[HDPT_TREADS]
	var/obj/item/hardpoint/tank/armor/HP3 = hardpoints[HDPT_SUPPORT]
	var/obj/item/hardpoint/tank/secondary/HP4 = hardpoints[HDPT_SECDGUN]
	var/obj/item/hardpoint/tank/primary/HP5 = hardpoints[HDPT_PRIMARY]
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

	var/smoke = smoke_ammo_current/2

	var/list/data = list(
							"integrity" = tank_health,
							"smoke_ammo" = smoke
						)

	if(HP3 && HP3.is_activatable)
		data += list("support_h" = HP3.obj_integrity)
		data += list("support_n" = HP3.name)
	else
		data += list("support_h" = null)
		data += list("support_n" = null)

	//secondary
	if(HP4)
		data += list("secd_gun_name" = HP4.name, "secd_gun_hp" = HP4.obj_integrity)
		var/timer = (HP4.next_use - world.time)/10
		var/reload_time = cooldowns["secondary"]/10
		if(reload_time < 6)
			reload_time = 6
		data += list("cd_secd_left" = timer, "cd_secd_full" = reload_time)

		if(active_hp)
			var/obj/item/hardpoint/tank/HP_active = hardpoints[active_hp]
			if(HP4.name == HP_active.name)
				data += list("secd_gun_sel" = TRUE)
			else
				data += list("secd_gun_sel" = FALSE)
		else
			data += list("secd_gun_sel" = FALSE)

		for(var/i = 1; i <= length(HP4.clips); i++)
			if(length(HP4.clips[i]) > 1)
				data += list("secd_gun_ammo_type_[i]" = HP4.clips[i][1])
			var/ammo = 0
			for(var/j = 2; j <= length(HP4.clips[i]); j++)
				var /obj/item/ammo_magazine/tank/A = HP4.clips[i][j]
				ammo += A.current_rounds
			data += list("secd_gun_ammo_[i]" = ammo)
		
		switch(HP4.cur_ammo_type)
			if(1)
				data += list("secd_gun_ammo_type_cur_1" = TRUE, "secd_gun_ammo_type_cur_2" = FALSE, "secd_gun_ammo_type_cur_3" = FALSE)
			if(2)
				data += list("secd_gun_ammo_type_cur_1" = FALSE, "secd_gun_ammo_type_cur_2" = TRUE, "secd_gun_ammo_type_cur_3" = FALSE)
			if(3)
				data += list("secd_gun_ammo_type_cur_1" = FALSE, "secd_gun_ammo_type_cur_2" = FALSE, "secd_gun_ammo_type_cur_3" = TRUE)

	else
		data += list("secd_gun_name" = null, "secd_gun_hp" = -100, "cd_secd_left" = null, "cd_secd_full" = null, "secd_gun_sel" = FALSE, "secd_gun_ammo_1" = -1, "secd_gun_ammo_2" = -1, "secd_gun_ammo_3" = -1, "secd_gun_ammo_type_1" = null, "secd_gun_ammo_type_2" = null, "secd_gun_ammo_type_3" = null, "secd_gun_ammo_type_cur_1" = FALSE, "secd_gun_ammo_type_cur_2" = FALSE, "secd_gun_ammo_type_cur_3" = FALSE)

	//primary
	if(HP5)
		data += list("main_gun_name" = HP5.name, "main_gun_hp" = HP5.obj_integrity)
		var/timer = (HP5.next_use - world.time)/10
		var/reload_time = cooldowns["primary"]/10
		if(reload_time < 6)
			reload_time = 6
		data += list("cd_main_left" = timer, "cd_main_full" = reload_time)

		if(active_hp)
			var/obj/item/hardpoint/tank/HP_active = hardpoints[active_hp]
			if(HP5.name == HP_active.name)
				data += list("main_gun_sel" = TRUE)
			else
				data += list("main_gun_sel" = FALSE)
		else
			data += list("main_gun_sel" = FALSE)

		for(var/i = 1; i <= HP5.clips.len; i++)
			if(HP5.clips[i].len > 1)
				data += list("main_gun_ammo_type_[i]" = HP5.clips[i][1])
			var/ammo = 0
			for(var/j = 2; j <= HP5.clips[i].len; j++)
				var /obj/item/ammo_magazine/tank/A = HP5.clips[i][j]
				ammo += A.current_rounds
			data += list("main_gun_ammo_[i]" = ammo)
		
		switch(HP5.cur_ammo_type)
			if(1)
				data += list("main_gun_ammo_type_cur_1" = TRUE, "main_gun_ammo_type_cur_2" = FALSE, "main_gun_ammo_type_cur_3" = FALSE)
			if(2)
				data += list("main_gun_ammo_type_cur_1" = FALSE, "main_gun_ammo_type_cur_2" = TRUE, "main_gun_ammo_type_cur_3" = FALSE)
			if(3)
				data += list("main_gun_ammo_type_cur_1" = FALSE, "main_gun_ammo_type_cur_2" = FALSE, "main_gun_ammo_type_cur_3" = TRUE)

	else
		data += list("main_gun_name" = null, "main_gun_hp" = -100, "cd_main_left" = null, "cd_main_full" = null, "main_gun_sel" = FALSE, "main_gun_ammo_1" = -1, "main_gun_ammo_2" = -1, "main_gun_ammo_3" = -1, "main_gun_ammo_type_1" = null, "main_gun_ammo_type_2" = null, "main_gun_ammo_type_3" = null, "main_gun_ammo_type_cur_1" = FALSE, "main_gun_ammo_type_cur_2" = FALSE, "main_gun_ammo_type_cur_3" = FALSE)

//part regarding tankers
	if(user == gunner)
		data += list("user_gunner" = TRUE)
		if(driver)
			data += list("second_AC" = driver.name)
			var/mob/living/carbon/AC = driver
			if(!AC.client || AC.stat == UNCONSCIOUS)
				data += list("second_AC_uncon" = TRUE)
			else
				data += list("second_AC_uncon" = FALSE)
		else
			data += list("second_AC" = null)
	else
		if(user == driver)
			data += list("user_gunner" = FALSE)
			if(gunner)
				data += list("second_AC" = gunner.name)
				var/mob/living/carbon/AC = gunner
				if(!AC.client || AC.stat == UNCONSCIOUS)
					data += list("second_AC_uncon" == TRUE)
				else
					data += list("second_AC_uncon" = FALSE)
			else
				data += list("second_AC" = null)
		else
			to_chat(user, "<span class='debuginfo'>Error WrUs4 occurred. Please, report this bug.</span>")
			ui.close()
			return

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "tank_ui.tmpl", "Tank's Interface" , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/vehicle/multitile/root/cm_armored/tank/Topic(href, href_list)

	if(usr.incapacitated())
		return

	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["smoke"])
			smoke_shot()

		if (href_list["weapon"])
			var/selected = text2num(href_list["weapon"])
			select_hp(selected, usr)

		if (href_list["ammo"])
			var/selected = text2num(href_list["ammo"])
			select_ammo(selected, usr)

		if (href_list["unload"])
			var/selected = text2num(href_list["unload"])
			unload_mag(selected, usr)	

		if (href_list["crew"])
			var/selected = text2num(href_list["crew"])
			crew_interaction(selected)

		ui_interact(usr) //updates the nanoUI window

/obj/vehicle/multitile/root/cm_armored/proc/select_hp(var/selected, var/mob/living/carbon/human/M)

	if(!can_use_hp(M))
		return

	var/obj/item/card/id/I = M.wear_id
	if(I && I.rank == "Synthetic" && I.registered_name == M.real_name)
		to_chat(M, "<span class='notice'>Your programm doesn't allow operating tank weapons.</span>")
		return

	var/slot
	switch(selected)
		if(5)
			slot = HDPT_PRIMARY
		if(4)
			slot = HDPT_SECDGUN
		if(3)
			var/obj/item/hardpoint/tank/arty_hp = hardpoints[HDPT_SUPPORT]
			var/turf/T = get_step(src, dir)
			T = get_step(src, dir)
			arty_hp.active_effect(T)
			to_chat(M, "<span class='notice'>You toggle [arty_hp.name].</span>")
			if(isliving(M))
				M.set_interaction(src)
				return
			return


	var/obj/item/hardpoint/tank/HP = hardpoints[slot]
	if(!HP)
		to_chat(usr, "<span class='warning'>There's nothing installed on that hardpoint.</span>")

	deactivate_binos(M)
	active_hp = slot
	to_chat(M, "<span class='notice'>You select the [HP.name].</span>")

	if(isliving(M))
		M.set_interaction(src)

/obj/vehicle/multitile/root/cm_armored/proc/select_ammo(var/selected, var/mob/M)

	if(!can_use_hp(M))
		return

	var/obj/item/hardpoint/tank/HP = hardpoints[HDPT_PRIMARY]
	HP.change_ammo(selected, M)
	return
	
/obj/vehicle/multitile/root/cm_armored/proc/unload_mag(var/selected, var/mob/M)

	if(!can_use_hp(M))
		return

	var/obj/item/hardpoint/tank/HP = hardpoints[HDPT_PRIMARY]
	HP.unload_mag(selected, M)
	return

//proc that will be pushing another unconcious AC out of tank
/obj/vehicle/multitile/root/cm_armored/tank/proc/crew_interaction(var/choice)

	switch(choice)
		if(1)
			var/confirmation = alert(usr, "Are you sure you want to push your driver outside? You won't stop unless they become concious.", , "Yes", "No")//added confirmation window
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>You decide not to push your driver outside.</span>")
				return
			var/mob/living/carbon/M = driver
			to_chat(usr, "<span class='notice'>You start pushing your driver out of their seat.</span>")
			sleep(100)
			if(!driver)
				to_chat(usr, "<span class='warning'>Your driver is gone already.</span>")
				return
			if(M.client && M.stat != UNCONSCIOUS)
				to_chat(M, "<span class='warning'>Your driver just woke up and you stopped pushing them out!</span>")
				return
			to_chat(M, "<span class='warning'>You push your driver out!</span>")
			driver = null
			M.forceMove(entrance.loc)
			M.unset_interaction()
			log_admin("[usr]([usr.client ? usr.client.ckey : "disconnected"]) pushed unconcious/disconnected [M]([M.client ? M.client.ckey : "disconnected"]), his driver, from the [name].")
			message_admins("[usr]([usr.client ? usr.client.ckey : "disconnected"]) pushed unconcious/disconnected [M]([M.client ? M.client.ckey : "disconnected"]), his driver, from the [name].")

		if(2)
			var/confirmation = alert(usr, "Are you sure you want to push your gunner outside? You won't stop unless they become concious.", , "Yes", "No")//added confirmation window
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>You decide not to push your gunner outside.</span>")
				return
			var/mob/living/carbon/M = gunner
			to_chat(usr, "<span class='notice'>You start pushing your gunner out of their seat.</span>")
			sleep(100)
			if(!gunner)
				to_chat(usr, "<span class='warning'>Your gunner is gone already.</span>")
				return
			if(M.client && M.stat != UNCONSCIOUS)
				to_chat(M, "<span class='warning'>Your gunner just woke up and you stopped pushing them out!</span>")
				return
			to_chat(M, "<span class='warning'>You push your gunner out!</span>")
			gunner = null
			M.forceMove(entrance.loc)
			M.unset_interaction()
			log_admin("[usr]([usr.client ? usr.client.ckey : "disconnected"]) pushed unconcious/disconnected [M]([M.client ? M.client.ckey : "disconnected"]), his gunner, from the [name].")
			message_admins("[usr]([usr.client ? usr.client.ckey : "disconnected"]) dragged unconcious/disconnected [M]([M.client ? M.client.ckey : "disconnected"]), his gunner, from the [name].")

		if(3)
			var/confirmation = alert(usr, "Are you sure you want to ask your driver to swap seats?", , "Yes", "No")//added confirmation window
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>You decide not to swap seats with your driver.</span>")
				return
			confirmation = alert(driver, "Your gunner offers you to swap seats.", , "Yes", "No")
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>Driver has refused to swap seats with you.</span>")
				return

			to_chat(usr, "<span class='notice'>You start getting into the driver seat.</span>")
			to_chat(driver, "<span class='notice'>You start getting into the gunner seat.</span>")
			sleep(60)
			to_chat(usr, "<span class='notice'>You switch seats and get yourself comfortable in driver seat.</span>")
			to_chat(driver, "<span class='notice'>You switch seats and get yourself comfortable in gunner seat.</span>")
			deactivate_all_hardpoints()

			swap_seat = gunner
			gunner = driver
			deactivate_binos(gunner)
			if(gunner.client)
				gunner.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
			driver = swap_seat
			if(driver.client)
				driver.client.mouse_pointer_icon = initial(driver.client.mouse_pointer_icon)
			swap_seat = null
			return

		if(4)
			var/confirmation = alert(usr, "Are you sure you want to ask your driver to swap seats?", , "Yes", "No")//added confirmation window
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>You decide not to swap seats with your driver.</span>")
				return
			confirmation = alert(driver, "Your driver offers you to swap seats.", , "Yes", "No")
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>Gunner has refused to swap seats with you.</span>")
				return

			to_chat(usr, "<span class='notice'>You start getting into the gunner seat.</span>")
			to_chat(driver, "<span class='notice'>You start getting into the driver seat.</span>")
			sleep(60)
			to_chat(usr, "<span class='notice'>You switch to gunner seat.</span>")
			to_chat(driver, "<span class='notice'>You switch to driver seat.</span>")
			deactivate_all_hardpoints()

			swap_seat = driver
			driver = gunner
			deactivate_binos(gunner)
			if(gunner.client)
				gunner.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
			driver = swap_seat
			if(driver.client)
				driver.client.mouse_pointer_icon = initial(driver.client.mouse_pointer_icon)
			swap_seat = null
			return

		if(5)
			var/confirmation = alert(usr, "Are you sure you want to get into driver seat?", , "Yes", "No")//added confirmation window
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>You decide not to change seat.</span>")
				return
			to_chat(usr, "<span class='notice'>You start getting into driver seat.</span>")
			sleep(30)
			if(driver)
				to_chat(usr, "<span class='notice'>Someone beat you to the driver seat!</span>")
				return
			to_chat(usr, "<span class='notice'>You get into driver seat.</span>")
			deactivate_all_hardpoints()

			driver = gunner
			gunner = null
			if(driver.client)
				driver.client.mouse_pointer_icon = initial(driver.client.mouse_pointer_icon)
			return

		if(6)
			var/confirmation = alert(usr, "Are you sure you want to get into gunner seat?", , "Yes", "No")//added confirmation window
			if(confirmation == "No")
				to_chat(usr, "<span class='notice'>You decide not to change seat.</span>")
				return
			to_chat(usr, "<span class='notice'>You start getting into gunner seat.</span>")
			sleep(30)
			if(gunner)
				to_chat(usr, "<span class='notice'>Someone beat you to the gunner seat!</span>")
				return
			to_chat(usr, "<span class='notice'>You get into gunner seat.</span>")
			deactivate_all_hardpoints()

			gunner = driver
			driver = null
			deactivate_binos(gunner)
			if(gunner.client)
				gunner.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")