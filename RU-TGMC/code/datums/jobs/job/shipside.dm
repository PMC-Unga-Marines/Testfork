//Walker Pilot
/datum/job/command/walker
	title = WALKER_PILOT
	paygrade = "E7"
	comm_title = "WP"
	total_positions = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_WALKER)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_WALKER, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/walker
	display_order = JOB_DISPLAY_ORDER_WALKER_PILOT
	outfit = /datum/outfit/job/command/walker
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL


/datum/job/command/walker/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to operate and maintain the ship's walker.
Your authority is limited to your own vehicle, but you are next in line on the field, after the field commander.
You could use MTs help to repair and replace hardpoints."})



/datum/outfit/job/command/walker
	name = WALKER_PILOT
	jobtype = /datum/job/command/walker

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/tanker
	wear_suit = /obj/item/clothing/suit/storage/marine/M3P/tanker
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/helmet/marine/tanker
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/marine/satchel