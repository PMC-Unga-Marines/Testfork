//PROC AMMO
/datum/ammo/proc/area_stagger_burst(turf/Center, obj/item/projectile/P, var/max_range = 2, var/stun = 0, var/weaken = 1, var/stagger = 2, var/slowdown = 1, var/knockback = 1, var/shake = 1, var/soft_size_threshold = 3, var/hard_size_threshold = 2)	//by Jeser specifically for autocannon. Mix of Burst() and Stagger(): Deals damage in area + applies stagger to mobs in area
	if(!Center || !P)
		return
	for(var/mob/living/carbon/M in range(1,Center))
		M.visible_message("<span class='danger'>[M] got a concussion from \a [P.name]!</span>","[isxeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]You are concussed from \a </b>[P.name] explosion</b>!</span>")
		M.apply_damage(rand(10,P.damage/2))
		staggerstun(M, P, max_range, stun, weaken, stagger, slowdown, knockback, shake, soft_size_threshold, hard_size_threshold)

/*
//================================================
				  Bullet AMMO
//================================================
*/
/datum/ammo/bullet/minigun/tank
	name = "minigun bullet"

/datum/ammo/bullet/minigun/tank/New()
	..()
	accurate_range = CONFIG_GET(number/combat_define/short_shell_range)
	damage = CONFIG_GET(number/combat_define/lmmed_hit_damage)

/datum/ammo/bullet/front_cannon		//APC front cannon bullets
	name = "frontcannon bullet"
	icon_state = "bullet"
	flags_ammo_behavior = AMMO_BALLISTIC

/datum/ammo/bullet/front_cannon/New()
	..()
	accurate_range = CONFIG_GET(number/combat_define/screen_shell_range)
	damage = CONFIG_GET(number/combat_define/llow_hit_damage)
	penetration = CONFIG_GET(number/combat_define/low_armor_penetration)

/*
//================================================
					Rocket Ammo
//================================================
*/
/datum/ammo/rocket/tow
	name = "TOW rocket"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/tow/New()
	..()
	accuracy = CONFIG_GET(number/combat_define/high_hit_accuracy)
	accurate_range = CONFIG_GET(number/combat_define/short_shell_range)
	max_range = CONFIG_GET(number/combat_define/max_shell_range)
	damage = CONFIG_GET(number/combat_define/low_hit_damage)
	penetration= CONFIG_GET(number/combat_define/max_armor_penetration)

/datum/ammo/rocket/tow/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_turf(M), 1, 1, 1, 3)

/datum/ammo/rocket/tow/on_hit_obj(obj/O, obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 1, 3)

/datum/ammo/rocket/tow/on_hit_turf(turf/T, obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 1, 3)

/datum/ammo/rocket/tow/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 1, 3)

/datum/ammo/rocket/tow/m8_1_tow
	name = "TOW emplacement rocket"

/datum/ammo/rocket/ltb
	name = "cannon round"
	icon_state = "ltb"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/ltb/New()
	. = ..()
	accuracy = CONFIG_GET(number/combat_define/med_hit_accuracy)
	accurate_range = CONFIG_GET(number/combat_define/long_shell_range)
	max_range = CONFIG_GET(number/combat_define/max_shell_range)
	penetration = CONFIG_GET(number/combat_define/ltb_armor_penetration)
	damage = CONFIG_GET(number/combat_define/ltb_hit_damage)
	shell_speed = CONFIG_GET(number/combat_define/fast_shell_speed)

/datum/ammo/rocket/ltb/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_turf(M), -1, 3, 5, 6)

/datum/ammo/rocket/ltb/on_hit_obj(obj/O, obj/item/projectile/P)
	explosion(get_turf(P), -1, 3, 5, 6)

/datum/ammo/rocket/ltb/on_hit_turf(turf/T, obj/item/projectile/P)
	explosion(get_turf(P), -1, 3, 5, 6)

/datum/ammo/rocket/ltb/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P), -1, 3, 5, 6)

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	hud_state = "rocket_fire"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_INCENDIARY|AMMO_EXPLOSIVE
	damage_type = BURN
/datum/ammo/rocket/wp/New()
	..()
	accuracy_var_low = CONFIG_GET(number/combat_define/med_proj_variance)
	accurate_range = CONFIG_GET(number/combat_define/short_shell_range)
	damage = CONFIG_GET(number/combat_define/super_hit_damage)
	max_range = CONFIG_GET(number/combat_define/norm_shell_range)

/datum/ammo/rocket/wp/drop_flame(turf/T, radius = 3) //~Art updated fire.
	if(!T || !isturf(T))
		return
	smoke.set_up(1, T)
	smoke.start()
	playsound(T, 'sound/weapons/gun_flamethrower2.ogg', 50, 1, 4)
	flame_radius(radius, T, 25, 25, 25, 15)


/datum/ammo/rocket/wp/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(M), 3)

/datum/ammo/rocket/wp/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(O), 3)

/datum/ammo/rocket/wp/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(T, 3)

/datum/ammo/rocket/wp/do_at_max_range(obj/item/projectile/P)
	drop_flame(get_turf(P), 3)

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	hud_state = "rocket_thermobaric"
	flags_ammo_behavior = AMMO_ROCKET
/datum/ammo/rocket/wp/quad/New()
	..()
	damage = CONFIG_GET(number/combat_define/ultra_hit_damage)
	max_range = CONFIG_GET(number/combat_define/long_shell_range)

/datum/ammo/rocket/wp/quad/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(M))
	explosion(P.loc,  -1, 2, 4, 5)

/datum/ammo/rocket/wp/quad/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(O))
	explosion(P.loc,  -1, 2, 4, 5)

/datum/ammo/rocket/wp/quad/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(T)
	explosion(P.loc,  -1, 2, 4, 5)

/datum/ammo/rocket/wp/quad/do_at_max_range(obj/item/projectile/P)
	drop_flame(get_turf(P))
	explosion(P.loc,  -1, 2, 4, 5)

/datum/ammo/rocket/ltb/ap
	name = "AP cannon round"
	icon_state = "ltb_ap"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/ltb/ap/New()
	. = ..()
	accuracy = CONFIG_GET(number/combat_define/max_hit_accuracy)
	accurate_range = CONFIG_GET(number/combat_define/short_shell_range)
	damage = CONFIG_GET(number/combat_define/med_hit_damage)

/datum/ammo/rocket/ltb/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_turf(M), 1, 1, 1, 3)

/datum/ammo/rocket/ltb/on_hit_obj(obj/O, obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 1, 3)

/datum/ammo/rocket/ltb/on_hit_turf(turf/T, obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 1, 3)

/datum/ammo/rocket/ltb/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 1, 3)

/datum/ammo/rocket/ltb/he
	name = "HE cannon round"
	icon_state = "ltb_he"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/ltb/he/New()
	. = ..()
	accuracy = CONFIG_GET(number/combat_define/high_hit_accuracy)
	accurate_range = CONFIG_GET(number/combat_define/short_shell_range)
	penetration = CONFIG_GET(number/combat_define/low_armor_penetration)
	damage = CONFIG_GET(number/combat_define/high_hit_damage)

/datum/ammo/rocket/ltb/he/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_turf(M), -1, -1, 5, 6)

/datum/ammo/rocket/ltb/he/on_hit_obj(obj/O, obj/item/projectile/P)
	explosion(get_turf(P), -1, -1, 5, 6)

/datum/ammo/rocket/ltb/he/on_hit_turf(turf/T, obj/item/projectile/P)
	explosion(get_turf(P), -1, -1, 5, 6)

/datum/ammo/rocket/ltb/he/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P), -1, -1, 5, 6)

/datum/ammo/rocket/ltb/heat
	name = "HEAT cannon round"
	icon_state = "ltb_heat"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/ltb/heat/New()
	. = ..()
	accuracy = CONFIG_GET(number/combat_define/high_hit_accuracy)
	accurate_range = CONFIG_GET(number/combat_define/short_shell_range)
	penetration = CONFIG_GET(number/combat_define/low_armor_penetration)
	damage = CONFIG_GET(number/combat_define/high_hit_damage)

/datum/ammo/rocket/ltb/heat/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_step(get_turf(M), P.dir), -1, 2, 3, 4)

/datum/ammo/rocket/ltb/heat/on_hit_turf(turf/T, obj/item/projectile/P)
	var/turf/closed/wall/W = T
	if(istype(W) && !W.hull)
		explosion(get_step(W, P.dir), -1, 2, 3, 4)
		qdel(W)
	explosion(T, -1, 2, 3, 4)

/datum/ammo/rocket/ltb/heat/on_hit_obj(obj/O, obj/item/projectile/P)
	if(CHECK_BITFIELD(O.resistance_flags, UNACIDABLE))
		var/turf/closed/wall/T = get_turf(O)
		if(istype(T) && !T.hull)
			qdel(T)
		explosion(get_step(O, P.dir), -1, 2, 3, 4)
	else
		explosion(get_turf(O), -1, 2, 3, 4)

/datum/ammo/rocket/ltb/heat/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P), -1, 2, 3, 4)

/datum/ammo/rocket/autocannon
	name = "autocannon round"
	icon_state = "autocannon_ap"
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SKIPS_HUMANS

/datum/ammo/rocket/autocannon/New()
	..()
	accuracy = CONFIG_GET(number/combat_define/med_hit_accuracy)
	accurate_range = CONFIG_GET(number/combat_define/long_shell_range)
	max_range = CONFIG_GET(number/combat_define/max_shell_range)
	damage = CONFIG_GET(number/combat_define/hlow_hit_damage)
	penetration = CONFIG_GET(number/combat_define/mlow_armor_penetration)
	shell_speed = CONFIG_GET(number/combat_define/fast_shell_speed)

/datum/ammo/rocket/autocannon/scr
	name = "autocannon round"
	icon_state = "autocannon_scr"

/datum/ammo/rocket/autocannon/scr/on_hit_mob(mob/M, obj/item/projectile/P)
	staggerstun(M, P, CONFIG_GET(number/combat_define/max_shell_range), 0, 0, 3, 7, 0, 1, 3, 2)

/datum/ammo/rocket/autocannon/scr/on_hit_obj(obj/O, obj/item/projectile/P)
	area_stagger_burst(get_turf(P), P, 0, 0, 3, 5, 0, 1, 3, 2)

/datum/ammo/rocket/autocannon/scr/on_hit_turf(turf/T, obj/item/projectile/P)
	area_stagger_burst(get_turf(P), P, 0, 0, 3, 5, 0, 1, 3, 2)

/datum/ammo/rocket/autocannon/scr/do_at_max_range(obj/item/projectile/P)
	area_stagger_burst(get_turf(P), P, 0, 0, 3, 5, 0, 1, 3, 2)

/datum/ammo/rocket/autocannon/scr/apc
	name = "autocannon round"
	icon_state = "autocannon_scr_apc"

/datum/ammo/rocket/autocannon/ap
	name = "autocannon round"
	icon_state = "autocannon_ap"

/datum/ammo/rocket/autocannon/ap/New()
	..()
	accuracy = CONFIG_GET(number/combat_define/med_hit_accuracy)
	accurate_range = CONFIG_GET(number/combat_define/long_shell_range)
	max_range = CONFIG_GET(number/combat_define/max_shell_range)
	damage = CONFIG_GET(number/combat_define/lmed_hit_damage)
	penetration = CONFIG_GET(number/combat_define/hmed_armor_penetration)

/datum/ammo/rocket/autocannon/ap/on_hit_mob(mob/M, obj/item/projectile/P)
	return

/datum/ammo/rocket/autocannon/ap/on_hit_obj(obj/O, obj/item/projectile/P)
	return

/datum/ammo/rocket/autocannon/ap/on_hit_turf(turf/T, obj/item/projectile/P)
	return

/datum/ammo/rocket/autocannon/ap/do_at_max_range(obj/item/projectile/P)
	return

//no IFF for communistic pigs!
/datum/ammo/rocket/autocannon/ap/upp
	iff_signal = null
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/autocannon/ap/upp/New()
	..()
	damage = CONFIG_GET(number/combat_define/hmed_hit_damage)

/datum/ammo/rocket/autocannon/ap/upp/on_hit_mob(mob/M, obj/item/projectile/P)
	return

/datum/ammo/rocket/autocannon/ap/upp/on_hit_obj(obj/O, obj/item/projectile/P)
	return

/datum/ammo/rocket/autocannon/ap/upp/on_hit_turf(turf/T, obj/item/projectile/P)
	return

/datum/ammo/rocket/autocannon/ap/upp/do_at_max_range(obj/item/projectile/P)
	return