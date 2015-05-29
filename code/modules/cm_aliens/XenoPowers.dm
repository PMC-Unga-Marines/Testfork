//Xenomorph Super - Colonial Marines - Apophis775 - Last Edit: 8FEB2015

//Their verbs are all actually procs, so we don't need to add them like 4 times copypaste for different species
//Just add the name to the caste's inherent_verbs() list

/mob/living/carbon/Xenomorph/verb/middle_mousetoggle()
	set name = "Toggle Middle Clicking"
	set desc = "Toggles middle mouse button for hugger throwing, neuro spit, and other abilities."
	set category = "Alien"

	if(!middle_mouse_toggle)
		src << "You turn middle mouse clicking ON for certain xeno abilities."
		middle_mouse_toggle = 1
	else
		src << "You turn middle mouse clicking OFF. Middle mouse button will instead change active hands."
		middle_mouse_toggle = 0

	return

/mob/living/carbon/Xenomorph/proc/plant()
	set name = "Plant Weeds (75)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	if(!check_state()) return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(!is_weedable(T))
		src << "Bad place for a garden!"
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		src << "There's a pod here already.!"
		return

	if(check_plasma(75))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] regurgitates a pulsating node and plants it on the ground!</B>"), 1)
		new /obj/effect/alien/weeds/node(loc)
		playsound(loc, 'sound/effects/splat.ogg', 30, 1) //splat!
	return

/mob/living/carbon/Xenomorph/proc/lay_egg()

	set name = "Lay Egg (100)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(!check_state()) return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(locate(/obj/effect/alien/egg) in get_turf(src) || locate(/obj/royaljelly) in get_turf(src)) //Turn em off for now
		src << "There's already an egg or royal jelly here."
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "Your eggs wouldn't grow well enough here. Lay them on resin."
		return

	if(check_plasma(100)) //New plasma check proc, removes/updates plasma automagically
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(T)
	return

/obj/royaljelly
	name = "royal jelly"
	desc = "A greenish-yellow blob of slime that encourages xenomorph evolution."
	icon = 'icons/Xeno/Colonial_Aliens1x1.dmi'
	icon_state = "jelly"
	anchored = 1
	opacity = 0
	density = 0
	layer = 3.4 //On top of most things

/obj/royaljelly/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(!istype(M,/mob/living/carbon/Xenomorph) || istype(M,/mob/living/carbon/Xenomorph/Larva))
		return

	if(M.jelly)
		M << "You're already filled with delicious jelly."
		return

	M.jelly = 1
	visible_message("\green [M] greedily devours the [src].","You greedily gulp down the [src].")

/mob/living/carbon/Xenomorph/proc/produce_jelly()

	set name = "Produce Jelly (350)"
	set desc = "Squirt out some royal jelly for hive advancement."
	set category = "Alien"

	if(!check_state())
		return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(locate(/obj/effect/alien/egg) in get_turf(src) || locate(/obj/royaljelly) in get_turf(src))
		src << "There's already an egg or royal jelly here."
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "Your jelly would rot here. Lay them on resin."
		return

	if(check_plasma(350)) //New plasma check proc, removes/updates plasma automagically
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] squirts out a greenish blob of jelly.</B>"), 1)
		new /obj/royaljelly(T)
	return

/mob/living/carbon/Xenomorph/proc/Pounce()
	set name = "Pounce (25)"
	set desc = "Pounce onto your prey."
	set category = "Alien"

	if(!check_state())
		return

	if(usedPounce)
		src << "\red You must wait before pouncing again.. Timer is at: \b[usedPounce] ticks."
		return

	if(check_plasma(25))
		var/targets[] = list()
		for(var/mob/living/carbon/human/M in oview())
			if(M.stat)	continue//Doesn't target corpses or paralyzed persons.
			targets.Add(M)

		if(targets.len)
			var/mob/living/carbon/human/target=pick(targets)
			var/atom/targloc = get_turf(target)
			if (!targloc || !istype(targloc, /turf) || get_dist(src.loc,targloc)>=3)
				src << "You cannot reach your prey!"
				return
			if(src.weakened >= 1 || src.paralysis >= 1 || src.stunned >= 1)
				src << "You cannot pounce if you are stunned.."
				return

			visible_message("\red <B>[src] pounces on [target]!</B>")
			if(src.m_intent == "walk")
				src.m_intent = "run"
				src.hud_used.move_intent.icon_state = "running"
			src.loc = targloc
			usedPounce = 5
			if(target.r_hand && istype(target.r_hand, /obj/item/weapon/shield/riot) || target.l_hand && istype(target.l_hand, /obj/item/weapon/shield/riot))
				if (prob(35))	// If the human has riot shield in his hand
					src.weakened = 5//Stun the fucker instead
					visible_message("\red <B>[src] bounces off [src]'s shield!</B>")
				else
					src.canmove = 0
					src.frozen = 1
					target.Weaken(3)
					spawn(18)
						src.frozen = 0
			else
				src.canmove = 0
				src.frozen = 1
				target.Weaken(3)

			spawn(18)
				src.frozen = 0
		else
			src << "\red You sense no prey.."

	return

/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())	return
	handle_ventcrawl()
	return

/mob/living/carbon/Xenomorph/proc/xenohide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"
	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot do this in your current state."
		return
	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")

/mob/living/carbon/Xenomorph/proc/gut()
	set category = "Alien"
	set name = "Gut (200)"
	set desc = "While pulling someone, rip their guts out or tear them apart."

	if(!check_state())	return

	if(last_special > world.time)
		return

	var/mob/living/victim = src.pulling
	if(!victim || isnull(victim) || !istype(victim))
		src << "You're not pulling anyone that can be gutted."
		return

	if(locate(/obj/item/alien_embryo) in victim || locate(/obj/item/alien_embryo) in victim.contents) // Maybe they ate it??
		src << "Not with a widdle alium inside! How cruel!"
		return

	var/turf/cur_loc = victim.loc
	if(!cur_loc) return //logic
	if(!cur_loc || !istype(cur_loc)) return

	if(!check_plasma(200))
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> lifts [victim] into the air...</span>")
	if(do_after(src,60))
		if(!victim || isnull(victim)) return
		if(victim.loc != cur_loc) return
		visible_message("<span class='warning'><b>\The [src]</b> viciously wrenches [victim] apart!</span>")
		emote("roar")
		src.attack_log += text("\[[time_stamp()]\] <font color='red'>gibbed [victim.name] ([victim.ckey])</font>")
		victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>was gibbed by [src.name] ([src.ckey])</font>")
		victim.gib() //Splut


/mob/living/carbon/Xenomorph/proc/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Alien"

	if(!check_state())	return

	if(stomach_contents.len)
		for(var/mob/M in src)
			if(M in stomach_contents)
				stomach_contents.Remove(M)
				M.loc = loc
		src.visible_message("\red <B>\The [src] hurls out the contents of their stomach!</B>")
	else
		src << "There's nothing in your belly that needs regurgitating."
	return

/mob/living/carbon/Xenomorph/proc/psychic_whisper(mob/M as mob in oview())
	set name = "Psychic Whisper"
	set desc = "Whisper silently to someone over a distance."
	set category = "Alien"

	if(!check_state())	return

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_say("PsychicWhisper: [key_name(src)]->[M.key] : [msg]")
		M << "\green You hear a strange, alien voice in your head... \italic [msg]"
		src << "\green You said: \"[msg]\" to [M]"
	return

/mob/living/carbon/Xenomorph/proc/transfer_plasma(mob/living/carbon/Xenomorph/M as mob in oview(1))
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Alien"

	if(!check_state())	return

	if (get_dist(src,M) <= 3)
		src << "\green You need to be closer."
		return

	var/amount = input("Amount:", "Transfer Plasma to [M]") as num
	if (amount)
		amount = abs(round(amount))
		if(storedplasma < amount)
			src << "You don't have that much. You only have: [storedplasma]."
			return
		storedplasma -= amount
		M.storedplasma += amount
		if(M.storedplasma > M.maxplasma) M.storedplasma = M.maxplasma
		M << "\green [src] has transfered [amount] plasma to you. You now have [M.storedplasma]."
		src << "\green You have transferred [amount] plasma to [M]. You now have [src.storedplasma]."
	return

/mob/living/carbon/Xenomorph/proc/build_resin() // -- TLE
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"

	if(!check_state())	return

	if(!is_weedable(loc))
		src << "Bad place for a garden!"
		return

	var/turf/T = loc
	if(!T) //logic
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "You can only shape on weeds. Find some resin before you start building!"
		return

	if(locate(/obj/structure/mineral_door/resin) in T || locate(/obj/effect/alien/resin/wall) in T || locate(/obj/effect/alien/resin/membrane) in T || locate(/obj/structure/stool/bed/nest) in T )
		src << "There's something built here already."
		return

	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door","resin wall","resin membrane","resin nest")

	if(!choice)
		return

	if(!check_plasma(75))
		return

	src << "\green You shape a [choice]."
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] vomits up a thick purple substance and begins to shape it!</B>"), 1)
	switch(choice)
		if("resin door")
			new /obj/structure/mineral_door/resin(T)
		if("resin wall")
			new /obj/effect/alien/resin/wall(T)
		if("resin membrane")
			new /obj/effect/alien/resin/membrane(T)
		if("resin nest")
			new /obj/structure/stool/bed/nest(T)
	return

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/neurotoxin(mob/target as mob in oview())
	set name = "Spit Neurotoxin (50)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	set category = "Alien"

	if(!check_state())	return

	if(has_spat)
		usr << "You must wait for your neurotoxin glands to refill."
		return

	if(!istype(target)) //hmm. no shooting at floors?
		return


	if(!check_plasma(50))
		return

	has_spat = 1
	spawn(spit_delay)
		has_spat = 0
		usr << "You feel your neuro glands swell with ichor. You can spit again."

	visible_message("<span class='warning'><b>\The [src]</b> spits at [target]!</span>","You spit at [target]!")

	//I'm not motivated enough to revise this. Prjectile code in general needs update.
	// Maybe change this to use throw_at? ~ Z
	var/turf/T = loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		usr.bullet_act(new /obj/item/projectile/energy/neuro_weak(usr.loc), get_organ_target())
		return
	if(!istype(U, /turf))
		return

	var/obj/item/projectile/energy/neuro_weak/A = new /obj/item/projectile/energy/neuro_weak(usr.loc)
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.process()
	return

/mob/living/carbon/Xenomorph/proc/throw_hugger(var/mob/living/carbon/T)
	set name = "Throw Facehugger"
	set desc = "Throw one of your facehuggers. MIDDLE MOUSE BUTTON quick-throws."
	set category = "Alien"

	if(!check_state())	return

	if(!istype(src,/mob/living/carbon/Xenomorph/Carrier))
		src << "How did you get this verb??" //Lel. Shouldn't be possible, butcha never know. Since this uses carrier vars, only carriers.
		return

	if(src:huggers_cur <= 0)
		src << "\red You don't have any facehuggers to throw!"
		return

	if(!src:threw_a_hugger)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(src, "Who should you throw at?") as null|anything in victims

		if(T)
			var/obj/item/clothing/mask/facehugger/throw = new()
			src:huggers_cur -= 1
			throw.loc = src.loc
			throw.throw_at(T, 5, src:throwspeed)
			src << "You throw a facehugger at [throw]."
			visible_message("\red <B>[src] throws something towards [T]!</B>")
			src:threw_a_hugger = 1
			spawn(40)
				src:threw_a_hugger = 0
		else
			src << "\blue You cannot throw at nothing!"
	return

/mob/living/carbon/Xenomorph/proc/charge(var/atom/T)
	set name = "Charge (10)"
	set desc = "Charge towards something! Raaaugh!"
	set category = "Alien"

	if(!check_state())	return

	if(!check_plasma(10))
		return

	if(!istype(src,/mob/living/carbon/Xenomorph/Ravager))
		src << "How did you get this verb??" //Shouldn't be possible. Ravagers have some vars here that aren't in other castes.
		return

	//Hate using :
	var/mob/living/carbon/Xenomorph/Ravager/X = src

	if(!X.usedcharge)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(X, "Who should you charge towards?") as null|anything in victims

		if(T)
			visible_message("\red <B>[X] charges towards [T]!</B>","\red <b> You charge at [T]!</B>" )
			emote("roar") //heheh
			X.throw_at(T, X.CHARGEDISTANCE, X.CHARGESPEED)
			if(istype(T,/mob/living/carbon/human)) //Small addition -- auto-attacks whoever we charged at.
				if(T in oview(1) && T:stat) //Hate using : but here we know it's safe, since we checked if is human
					T:attack_alien(X)
					T:Weaken(1)

			X.usedcharge = 1
			spawn(X.CHARGECOOLDOWN)
				X.usedcharge = 0
				X << "Your exoskeleton quivers as you get ready to charge again."

		else
			src.storedplasma += 10 //Since we already stole 10
			X << "\blue You cannot charge at nothing!"

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/neurotoxin2(mob/target as mob in oview())
	set name = "Spit Neurotoxin (75)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a while."
	set category = "Alien"

	if(!check_state())	return

	if(!istype(target))
		usr << "You must aim your spit at someone!"
		return

	if(has_spat)
		usr << "You must wait for your neurotoxin glands to refill."
		return

	if(!check_plasma(75))
		return

	has_spat = 1
	spawn(spit_delay)
		has_spat = 0
		usr << "You feel your neuro glands swell with ichor. You can spit again."

	visible_message("<span class='warning'><b>\The [src]</b> spits at [target]!</span>","You spit at [target]!")

	//I'm not motivated enough to revise this. Prjectile code in general needs update.
	// Maybe change this to use throw_at? ~ Z
	var/turf/T = loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		usr.bullet_act(new /obj/item/projectile/energy/neurotoxin(usr.loc), get_organ_target())
		return
	if(!istype(U, /turf))
		return

	var/obj/item/projectile/energy/neurotoxin/A = new /obj/item/projectile/energy/neurotoxin(usr.loc)
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.process()
	return

/mob/living/carbon/Xenomorph/proc/neurotoxin3(mob/target as mob in oview())
	set name = "Spit Neurotoxin (100)"
	set desc = "Spits neurotoxin at someone, paralyzing and damaging them."
	set category = "Alien"

	if(!check_state()) return

	if(has_spat)
		usr << "You must wait for your neurotoxin glands to refill."
		return

	if(!check_plasma(100))
		return

	has_spat = 1
	spawn(spit_delay)
		has_spat = 0
		usr << "You feel your neuro glands swell with ichor. You can spit again."

	visible_message("<span class='warning'><b>\The [src]</b> spits at [target]!</span>","You spit at [target]!")

	//I'm not motivated enough to revise this. Prjectile code in general needs update.
	// Maybe change this to use throw_at? ~ Z
	var/turf/T = loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		usr.bullet_act(new /obj/item/projectile/energy/neuro_uber(usr.loc), get_organ_target())
		return
	if(!istype(U, /turf))
		return

	var/obj/item/projectile/energy/neuro_uber/A = new /obj/item/projectile/energy/neuro_uber(usr.loc)
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.process()
	return

/mob/living/carbon/Xenomorph/proc/screech()
	set name = "Screech (250)"
	set desc = "Emit a screech that stuns prey."
	set category = "Alien"

	if(!check_state()) return

	if(has_screeched)
		src << "\red Your vocal chords are not yet prepared."
		return

	if(!check_plasma(250))
		return

	has_screeched = 1
	spawn(80)
		has_screeched = 0
		src << "You feel your throat muscles vibrate. You are ready to screech again."

	//Ours uses screech2.....
	playsound(loc, 'sound/effects/screech.ogg', 100, 1)
	visible_message("\red <B> \The [src] emits a high pitched screech!</B>")
	for (var/mob/living/carbon/human/M in oview())
		if(istype(M.l_ear, /obj/item/clothing/ears/earmuffs) || istype(M.r_ear, /obj/item/clothing/ears/earmuffs))
			continue
		if (get_dist(src.loc, M.loc) <= 4)
			M << "You spasm in agony as the noise fills your head!"
			M.stunned += 3
			M.Weaken(1)
//			M.drop_l_hand() //Weaken will drop them on the floor anyway
//			M.drop_r_hand()
			M.ear_deaf += 60 //Deafens them temporarily (about 8 seconds)
		else if(get_dist(src.loc, M.loc) >= 5)
			M.stunned += 2
			M << "The sound stuns you!"
	return

//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (variable)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Alien"

	if(!check_state())	return

	if(!O in oview(1))
		src << "\green [O] is too far away."
		return

	// OBJ CHECK
	if(isobj(O))
		var/obj/I = O
		if(I.unacidable || istype(I,/obj/machinery/computer) || istype(I,/obj/effect))	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			src << "\green You cannot dissolve this object." // ^^ Note for obj/effect.. this might check for unwanted stuff. Oh well
			return

	// TURF CHECK
	else if(istype(O, /turf/simulated))
		var/turf/T = O
		// R WALL
		if(istype(T, /turf/simulated/wall/r_wall))
			src << "\green You cannot dissolve this object."
			return
		if(istype(T, /turf/simulated/shuttle))
			src << "\green You cannot dissolve this object."
			return
		// NO FLOORS! NONE!
		if(istype(T, /turf/simulated/floor) || istype(T,/turf/unsimulated/floor))
			src << "\green You cannot dissolve this object."
			return
	else
		src << "\green You cannot dissolve this object."
		return

	if(istype(src,/mob/living/carbon/Xenomorph/Sentinel)) //weak level
		if(!check_plasma(75)) return
		new /obj/effect/xenomorph/acid/weak(get_turf(O), O)
	else if(istype(src,/mob/living/carbon/Xenomorph/Praetorian)) //strong level
		if(!check_plasma(200)) return
		new /obj/effect/xenomorph/acid/strong(get_turf(O), O)
	else
		if(!check_plasma(100)) return
		new /obj/effect/xenomorph/acid(get_turf(O), O) //Everything else? Medium.

	visible_message("\green <B>[src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</B>")
	return