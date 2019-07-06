//Disclaimer: this is not a real elevator or shuttle. It just imitates an elevator

/obj/effect/elevator_garage
	name = "empty space"
	desc = "There seems to be an awful lot of machinery down below"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "supply_elevator_lowered"

	pixel_x = 32
	pixel_y = -64

	resistance_flags = UNACIDABLE
	mouse_opacity = 0
	layer = 3

	var/obj/machinery/computer/vehicle_terminal/vic_comp
	var/turf/Center
	var/next_use = 0
	var/vehicle = "0"
	var/railing_id = "garage_railing"
	var/gear_id = "garage_gear"
	var/current_location = "LOWERED"

	ex_act(severity)
		return

/obj/effect/elevator_garage/New()
	..()

	Center = get_turf(src)
	Center = get_turf(get_step(Center, EAST))
	Center = get_turf(get_step(Center, EAST))
	Center = get_turf(get_step(Center, EAST))


/obj/effect/elevator_garage/proc/call_up()

	next_use = world.time + 300

	playsound(src, 'sound/machines/elevator_move.ogg', 50, 0)
	start_gears()
	sleep(70)
	flick("supply_elevator_raising", src)
	sleep(20)
	icon_state = "supply_elevator_raised"
	stop_gears()

	for(var/turf/T in range(2,Center))
		new /turf/open/floor/plating/plating_catwalk(T)

	if(vehicle == "1")
		new /obj/effect/multitile_spawner/cm_armored/tank(Center)
		vic_comp.vehicle_tokens--
	else
		if(vehicle == "2")
			new /obj/effect/multitile_spawner/cm_transport/apc(Center)
			vic_comp.vehicle_tokens--

	current_location = "RAISED"

	lower_railings()
	vehicle = "0"

/obj/effect/elevator_garage/proc/send_down()

	next_use = world.time + 300

	raise_railings()
	playsound(src, 'sound/machines/elevator_move.ogg', 50, 0)
	start_gears()

	for(var/mob/living/carbon/human/H in range(2,Center))
		to_chat(H, "<span class='danger'><FONT size=3><B>You are being crushed by ASRS machinery. You will be buried in a closed casket, it seems.</B></FONT></span>")
		H.apply_damage(90, BRUTE)
		sleep(5)

	for(var/obj/vehicle/multitile/root/VIC in range(2,Center))
		vic_comp.vehicle_tokens++
		qdel(VIC)

	for(var/mob/living/carbon/M in range(2,Center))
		log_admin("[M]([M.client ? M.client.ckey : "disconnected"]) took a ride on Garage elevator towards their death.")
		message_admins("[M]([M.client ? M.client.ckey : "disconnected"]) took a ride on Garage elevator towards their death.")

	for(var/turf/T in range(2,Center))
		new /turf/open/floor/almayer/empty(T)

	flick("supply_elevator_lowering", src)
	sleep(20)
	icon_state = "supply_elevator_lowered"
	sleep(70)
	stop_gears()
	current_location = "LOWERED"
	vehicle = "0"

/obj/effect/elevator_garage/proc/raise_railings()
	var/effective = FALSE
	for(var/obj/machinery/door/poddoor/M in SSmachines)
		if(M.id == railing_id && !M.density)
			effective = TRUE
			spawn()
				M.close()
	if(effective)
		playsound(src, 'sound/machines/elevator_openclose.ogg', 50, 0)


/obj/effect/elevator_garage/proc/lower_railings()
	var/effective = FALSE
	for(var/obj/machinery/door/poddoor/M in SSmachines)
		if(M.id == railing_id && M.density)
			effective = TRUE
			spawn()
				M.open()
	if(effective)
		playsound(src, 'sound/machines/elevator_openclose.ogg', 50, 0)

/obj/effect/elevator_garage/proc/start_gears()
	for(var/obj/machinery/gear/M in SSmachines)
		if(M.id == gear_id)
			spawn()
				M.icon_state = "gear_moving"
				if(current_location == "RAISED")
					M.dir = NORTH
				else
					M.dir = SOUTH

/obj/effect/elevator_garage/proc/stop_gears()
	for(var/obj/machinery/gear/M in SSmachines)
		if(M.id == gear_id)
			spawn()
				M.icon_state = "gear"


// ------------ terminal for ordering vehicles -----------------//


/obj/machinery/computer/vehicle_terminal
	name = "ColMarTech Vehicle Console"
	desc = "Used to retrieve armored vehicles from ASRS."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "supply"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = 1
	idle_power_usage = 20

	var/vehicle_tokens = 1	//this is a vehicle token. If you need more vehicles - simply inscrease amount of these.

	var/list/vendor_role = list("Tank Crewman") //everyone else, mind your business

	var/obj/effect/elevator_garage/elevator

/obj/machinery/computer/vehicle_terminal/Initialize()
	..()

	elevator = locate(/obj/effect/elevator_garage/) in world
	elevator.vic_comp = src

	start_processing()

/obj/machinery/computer/vehicle_terminal/power_change()
	..()
	if (CHECK_BITFIELD(machine_stat, NOPOWER))
		icon_state = "supply0"

/obj/machinery/computer/vehicle_terminal/process()
	if(SSticker.current_state < GAME_STATE_PLAYING)
		return
	if(CHECK_BITFIELD(machine_stat, NOPOWER))
		icon_state = "supply0"
		return
	icon_state = "supply"

/obj/machinery/computer/vehicle_terminal/attack_hand(mob/user as mob)

	if(..())
		return

	if(CHECK_BITFIELD(machine_stat, BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

	user.set_interaction(src)
	ui_interact(user)

/obj/machinery/computer/vehicle_terminal/attackby(obj/item/W, mob/user)

//	if(..())
//		return

	if(CHECK_BITFIELD(machine_stat, BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

/obj/machinery/computer/vehicle_terminal/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)

	if(!ishuman(user))
		return

	var/busy = FALSE
	if(world.time < elevator.next_use)
		busy = TRUE
	else
		busy = FALSE
	var/choice = 0
	if(elevator.vehicle == "1")
		choice = "M46 \"Stingray\" Tank"
	if(elevator.vehicle == "2")
		choice = "M580 APC"

	var/list/data = list(
							"vendor_name" = name,
							"tokens" = vehicle_tokens,
							"choice" = choice,
							"busy" = busy,
							"location" = elevator.current_location,
							"tank_name" = "M46 \"Stingray\" Tank",
							"tank_desc" = "M46 \"Stingray\" Modular Multipurpose Tank. A giant piece of armor, was made as a budget version of a tank specifically for USCM. Supports installing different types of modules and weapons, allowing technicians to refit tank for any type of operation. Has inbuilt M75 Smoke Deploy System. Entrance in the back.",
							"tank_mod" = "Has a choice between 3 main, 4 secondary weaponry modules, 3 support modules, 5 armor and 2 treads modules.",
							"apc_name" = "M580 APC",
							"apc_desc" = "M580 Armored Personnel Carrier. Combat transport for delivering and supporting infantry. Entrance on the right side.",
							"apc_mod" = "Supports 4 hardpoints modules and 1 internal specialization module."
						)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "vehicle_terminal.tmpl", name , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/computer/vehicle_terminal/Topic(href, href_list)
	if(CHECK_BITFIELD(machine_stat, BROKEN|NOPOWER))
		return
	if(usr.incapacitated())
		return

	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["select"])

			var/mob/living/carbon/human/H = usr

			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return

			if(!vendor_role.Find(I.rank))
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return

			elevator.vehicle = (href_list["select"])

		if (href_list["call"])

			var/mob/living/carbon/human/H = usr

			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return

			if(!vendor_role.Find(I.rank))
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return

			elevator.call_up()

		if (href_list["send"])

			var/mob/living/carbon/human/H = usr

			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return

			if(!vendor_role.Find(I.rank))
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return

			elevator.send_down()

		src.add_fingerprint(usr)
		if (in_range(src, usr) && isturf(loc) && ishuman(usr))
			ui_interact(usr) //updates the nanoUI window
		else
			usr.unset_interaction()