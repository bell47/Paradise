/datum/species/vox
	name = "Vox"
	name_plural = "Vox"
	max_age = 90 // vox stacks can be older than this, but let's assume their body fails beyond repair after such ages.
	icobase = 'icons/mob/human_races/vox/r_voxlime.dmi'
	dangerous_existence = TRUE
	language = "Vox-pidgin"
	tail = "voxtail_lime"
	speech_sounds = list('sound/voice/shriek1.ogg')
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/claws	//I dont think it will hurt to give vox claws too.

	blurb = "The Vox are remnants of an ancient race, that originate from arkships. \
	These bioengineered, reptilian, beaked, and quilled beings have a physiological caste system and follow 'The Inviolate' tenets.<br/><br/> \
	Breathing pure nitrogen, they need specialized masks and tanks for survival outside their arkships. \
	Their insular nature limits their involvement in broader galactic affairs, maintaining a distinct, yet isolated presence away from other species."

	breathid = "n2"

	eyes = "vox_eyes_s"

	species_traits = list(NO_CLONESCAN)
	inherent_traits = list(TRAIT_NOGERMS, TRAIT_NODECAY)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS //Species-fitted 'em all.
	dietflags = DIET_OMNI
	bodyflags = HAS_ICON_SKIN_TONE | HAS_TAIL | TAIL_WAGGING | TAIL_OVERLAPPED | HAS_BODY_MARKINGS | HAS_TAIL_MARKINGS | HAS_BODYACC_COLOR
	own_species_blood = TRUE

	blood_color = "#2299FC"
	flesh_color = "#808D11"
	//Default styles for created mobs.
	default_hair = "Short Vox Quills"
	default_hair_colour = "#614f19" //R: 97, G: 79, B: 25
	butt_sprite = "vox"

	reagent_tag = PROCESS_ORG | PROCESS_SYN
	scream_verb = "shrieks"
	male_scream_sound = 'sound/voice/shriek1.ogg'
	female_scream_sound = 'sound/voice/shriek1.ogg'
	male_cough_sounds = list('sound/voice/shriekcough.ogg')
	female_cough_sounds = list('sound/voice/shriekcough.ogg')
	male_sneeze_sound = 'sound/voice/shrieksneeze.ogg'
	female_sneeze_sound = 'sound/voice/shrieksneeze.ogg'

	icon_skin_tones = list(
		1 = "Default Lime",
		2 = "Plum",
		3 = "Brown",
		4 = "Grey",
		5 = "Emerald",
		6 = "Azure",
		7 = "Crimson",
		8 = "Nebula"
		)

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/vox,
		"lungs" =    /obj/item/organ/internal/lungs/vox,
		"liver" =    /obj/item/organ/internal/liver/vox,
		"kidneys" =  /obj/item/organ/internal/kidneys/vox,
		"brain" =    /obj/item/organ/internal/brain/vox,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/vox, //Default darksight of 2.
		)												//for determining the success of the heist game-mode's 'leave nobody behind' objective, while this is just an organ.

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!",
		"is deeply inhaling oxygen!")

	speciesbox = /obj/item/storage/box/survival_vox

	plushie_type = /obj/item/toy/plushie/voxplushie

/datum/species/vox/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/vox/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	if(!H.mind || !H.mind.assigned_role || H.mind.assigned_role != "Clown" && H.mind.assigned_role != "Mime")
		H.drop_item_to_ground(H.wear_mask)

	H.equip_or_collect(new /obj/item/clothing/mask/breath/vox/respirator(H), ITEM_SLOT_MASK)
	var/tank_pref = H.client && H.client.prefs ? H.client.prefs.active_character.speciesprefs : null
	var/obj/item/tank/internal_tank
	if(tank_pref)//Diseasel, here you go
		internal_tank = new /obj/item/tank/internals/nitrogen(H)
	else
		internal_tank = new /obj/item/tank/internals/emergency_oxygen/double/vox(H)
	if(!H.equip_to_appropriate_slot(internal_tank))
		if(!H.put_in_any_hand_if_possible(internal_tank))
			H.drop_item_to_ground(H.l_hand)
			H.equip_or_collect(internal_tank, ITEM_SLOT_LEFT_HAND)
			to_chat(H, "<span class='boldannounceooc'>Could not find an empty slot for internals! Please report this as a bug</span>")
	H.internal = internal_tank
	to_chat(H, "<span class='notice'>You are now running on nitrogen internals from [internal_tank]. Your species finds oxygen toxic, so you must breathe nitrogen only.</span>")
	H.update_action_buttons_icon()

/datum/species/vox/on_species_gain(mob/living/carbon/human/H)
	..()
	updatespeciescolor(H)
	H.update_icons()

/datum/species/vox/updatespeciescolor(mob/living/carbon/human/H, owner_sensitive = 1) //Handling species-specific skin-tones for the Vox race.
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/new_icobase = 'icons/mob/human_races/vox/r_voxlime.dmi' //Default Lime Vox.
		switch(H.s_tone)
			if(8) //Nebula Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxpurp.dmi'
				H.tail = "voxtail_purp"
			if(7) //Crimson Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxcrim.dmi'
				H.tail = "voxtail_crim"
			if(6) //Azure Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxazu.dmi'
				H.tail = "voxtail_azu"
			if(5) //Emerald Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxemrl.dmi'
				H.tail = "voxtail_emrl"
			if(4) //Grey Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxgry.dmi'
				H.tail = "voxtail_gry"
			if(3) //Brown Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxbrn.dmi'
				H.tail = "voxtail_brn"
			if(2) //Plum Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxplum.dmi'
				H.tail = "voxtail_plum"
			else  //Default Lime Vox.
				H.tail = "voxtail_lime" //Ensures they get an appropriately coloured tail depending on the skin-tone.

		H.change_icobase(new_icobase, owner_sensitive) //Update the icobase of all our organs, but make sure we don't mess with frankenstein limbs in doing so.

/datum/species/vox/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "oxygen")
		H.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER) //Same as plasma.
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE //Handling reagent removal on our own.

	return ..()

/datum/species/vox/do_compressor_grind(mob/living/carbon/human/H)
	new /obj/item/food/fried_vox(H.loc)
