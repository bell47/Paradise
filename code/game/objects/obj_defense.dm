//the essential proc to call when an obj must receive damage of any kind.
/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration_flat = 0, armour_penetration_percentage = 0)
	if(QDELETED(src))
		stack_trace("[src] taking damage after deletion")
		return
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if((resistance_flags & INDESTRUCTIBLE) || obj_integrity <= 0)
		return
	damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration_flat, armour_penetration_percentage)
	if(damage_amount < DAMAGE_PRECISION)
		return
	. = damage_amount
	obj_integrity = max(obj_integrity - damage_amount, 0)
	//BREAKING FIRST
	if(integrity_failure && obj_integrity <= integrity_failure)
		obj_break(damage_flag)
	//DESTROYING SECOND
	if(obj_integrity <= 0)
		obj_destruction(damage_flag)

///returns the damage value of the attack after processing the obj's various armor protections
/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration_flat = 0, armour_penetration_percentage = 0)
	if(damage_flag == MELEE && damage_amount < damage_deflection)
		return 0
	if(damage_type != BRUTE && damage_type != BURN)
		return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = clamp((armor_protection * ((100 - armour_penetration_percentage) / 100)) - armour_penetration_flat, min(armor_protection, 0), 100)
	var/damage_multiplier = (100 - armor_protection) / 100
	return round(damage_amount * damage_multiplier, DAMAGE_PRECISION)

/// returns the amount of damage required to destroy this object in a single hit.
/obj/proc/calculate_oneshot_damage(damage_type, damage_flag = 0, attack_dir, armour_penetration_flat = 0, armour_penetration_percentage = 0)
	if(obj_integrity <= 0)
		return 0
	if(resistance_flags & INDESTRUCTIBLE)
		return INFINITY
	if(damage_type != BRUTE && damage_type != BURN)
		return INFINITY

	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection)        // Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = clamp((armor_protection * ((100 - armour_penetration_percentage) / 100)) - armour_penetration_flat, min(armor_protection, 0), 100)

	var/damage_multiplier = (100 - armor_protection) / 100
	if(damage_multiplier <= 0)
		return INFINITY

	var/oneshot = obj_integrity / damage_multiplier
	if(damage_flag == MELEE)
		oneshot = max(oneshot, damage_deflection)
	return oneshot

///the sound played when the obj is damaged.
/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, MELEE, 1, get_dir(src, AM))

/obj/ex_act(severity)
	if(QDELETED(src))
		return
	if(resistance_flags & INDESTRUCTIBLE)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity)
	switch(severity)
		if(1)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(2)
			take_damage(rand(100, 250), BRUTE, BOMB, 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, BOMB, 0)

/obj/bullet_act(obj/item/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, TRUE)
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180), P.armour_penetration_flat, P.armour_penetration_percentage)

///Called to get the damage that hulks will deal to the obj.
/obj/proc/hulk_damage()
	return 150 //the damage hulks do on punches to this object, is affected by melee armor

/obj/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		..(user, TRUE)
		visible_message("<span class='danger'>[user] smashes [src]!</span>")
		if(density)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		take_damage(hulk_damage(), BRUTE, MELEE, 0, get_dir(src, user))
		return TRUE
	return FALSE

/obj/blob_act(obj/structure/blob/B)
	if(isturf(loc))
		var/turf/T = loc
		if(level == 1 && (T.intact||T.transparent_floor)) //the blob doesn't destroy thing below the floor
			return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armour_penetration_flat = 0, armour_penetration_percentage = 0) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user), armour_penetration_flat, armour_penetration_percentage)

/obj/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(attack_generic(user, 60, BRUTE, MELEE, 0))
		playsound(loc, 'sound/weapons/slash.ogg', 100, TRUE)

/obj/attack_animal(mob/living/simple_animal/M)
	if((M.a_intent == INTENT_HELP && M.ckey) || (!M.melee_damage_upper && !M.obj_damage))
		M.emote("me", EMOTE_VISIBLE, "[M.friendly] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(istype(M) && M.environment_smash)
			play_soundeffect = 0
		var/obj_turf = get_turf(src)  // play from the turf in case the object gets deleted mid attack
		if(M.obj_damage)
			. = attack_generic(M, M.obj_damage, M.melee_damage_type, MELEE, play_soundeffect, M.armour_penetration_flat, M.armour_penetration_percentage)
		else
			. = attack_generic(M, rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type, MELEE, play_soundeffect, M.armour_penetration_flat, M.armour_penetration_percentage)
		if(. && !play_soundeffect)
			playsound(QDELETED(src) ? obj_turf : src, 'sound/effects/meteorimpact.ogg', 100, TRUE)

/obj/handle_basic_attack(mob/living/basic/attacker, modifiers)
	if((attacker.a_intent == INTENT_HELP && attacker.ckey) || attacker.melee_damage_upper == 0)
		attacker.custom_emote(EMOTE_VISIBLE, "[attacker.friendly_verb_continuous] [src].")
		return FALSE
	else
		var/play_soundeffect = TRUE
		if(attacker.environment_smash)
			play_soundeffect = FALSE
		var/obj_turf = get_turf(src)  // play from the turf in case the object gets deleted mid attack
		if(attacker.obj_damage)
			. = attack_generic(attacker, attacker.obj_damage, attacker.melee_damage_type, MELEE, play_soundeffect, attacker.armour_penetration_flat, attacker.armour_penetration_percentage)
		else
			. = attack_generic(attacker, rand(attacker.melee_damage_lower, attacker.melee_damage_upper), attacker.melee_damage_type, MELEE, play_soundeffect, attacker.armour_penetration_flat, attacker.armour_penetration_percentage)
		if(. && !play_soundeffect)
			playsound(QDELETED(src) ? obj_turf : src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	return TRUE

/obj/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return TRUE

/obj/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	collision_damage(pusher, force, direction)
	return TRUE

/obj/proc/collision_damage(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	var/amt = max(0, ((force - (move_resist * MOVE_FORCE_CRUSH_RATIO)) / (move_resist * MOVE_FORCE_CRUSH_RATIO)) * 10)
	take_damage(amt, BRUTE)

/obj/attack_slime(mob/living/simple_animal/slime/user)
	if(!user.is_adult)
		return
	attack_generic(user, rand(10, 15), BRUTE, MELEE, 1)

/obj/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	var/play_soundeffect = 0
	var/mech_damtype = M.damtype
	if(M.selected)
		mech_damtype = M.selected.damtype
		play_soundeffect = 1
	else
		switch(M.damtype)
			if(BRUTE)
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if(BURN)
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if(TOX)
				playsound(src, 'sound/effects/spray2.ogg', 50, TRUE)
				return 0
			else
				return 0
	M.visible_message("<span class='danger'>[M.name] hits [src]!</span>", "<span class='danger'>You hit [src]!</span>")
	return take_damage(M.force*3, mech_damtype, MELEE, play_soundeffect, get_dir(src, M)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/obj/singularity_act()
	ex_act(EXPLODE_DEVASTATE)
	if(src && !QDELETED(src))
		qdel(src)
	return 2

///// ACID

GLOBAL_DATUM_INIT(acid_overlay, /mutable_appearance, mutable_appearance('icons/effects/effects.dmi', "acid"))

///the obj's reaction when touched by acid
/obj/acid_act(acidpwr, acid_volume)
	if(!(resistance_flags & UNACIDABLE) && acid_volume)
		if(!acid_level)
			SSacid.processing[src] = src
			add_overlay(GLOB.acid_overlay, TRUE)
		var/acid_cap = acidpwr * 300 //so we cannot use huge amounts of weak acids to do as well as strong acids.
		if(acid_level < acid_cap)
			acid_level = min(acid_level + acidpwr * acid_volume, acid_cap)
		return TRUE

///the proc called by the acid subsystem to process the acid that's on the obj
/obj/proc/acid_processing()
	. = TRUE
	if(!(resistance_flags & ACID_PROOF))
		if(prob(33))
			playsound(loc, 'sound/items/welder.ogg', 150, TRUE)
		take_damage(min(1 + round(sqrt(acid_level) * 0.3), 300), BURN, ACID, 0)

	acid_level = max(acid_level - (5 + 3 * round(sqrt(acid_level))), 0)
	if(!acid_level)
		return FALSE

///called when the obj is destroyed by acid.
/obj/proc/acid_melt()
	SSacid.processing -= src
	deconstruct(FALSE)

/obj/cleaning_act(mob/user, atom/cleaner, cleanspeed, text_verb, text_description, text_targetname)
	. = ..()
	if(acid_level)
		acid_level = 0

//// FIRE

/obj/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(isturf(loc))
		var/turf/T = loc
		if(level == 1 && (T.intact||T.transparent_floor)) //fire can't damage things hidden below the floor.
			return
	..()
	if(QDELETED(src))  // Some items, like patches, might get qdeled in the parent call
		return
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, FIRE, 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		resistance_flags |= ON_FIRE
		SSfires.processing[src] = src
		add_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay)
		return TRUE

///called when the obj is destroyed by fire
/obj/proc/burn()
	if(resistance_flags & ON_FIRE)
		SSfires.processing -= src
	deconstruct(FALSE)

///Called when the obj is no longer on fire.
/obj/proc/extinguish()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		cut_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay, TRUE)
		SSfires.processing -= src

///Called when the obj is hit by a tesla bolt.
/obj/zap_act(power, zap_flags)
	if(QDELETED(src))
		return FALSE
	being_shocked = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_shocked)), 1 SECONDS)
	return power / 2

/obj/proc/reset_shocked()
	being_shocked = FALSE

//The surgeon general warns that being buckled to certain objects receiving powerful shocks is greatly hazardous to your health
///Only tesla coils, vehicles, and grounding rods currently call this because mobs are already targeted over all other objects, but this might be useful for more things later.
/obj/proc/zap_buckle_check(strength)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.electrocute_act((clamp(round(strength / 400), 10, 90) + rand(-5, 5)), src, flags = SHOCK_TESLA)

//the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)

//what happens when the obj's health is below integrity_failure level.
/obj/proc/obj_break(damage_flag)
	return

///what happens when the obj's integrity reaches zero.
/obj/proc/obj_destruction(damage_flag)
	if(damage_flag == ACID)
		acid_melt()
	else if(damage_flag == FIRE)
		burn()
	else
		deconstruct(FALSE)

///changes max_integrity while retaining current health percentage, returns TRUE if the obj got broken.
/obj/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE, new_failure_integrity = null)
	var/current_integrity = obj_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max))	//don't destroy it as a result
		obj_integrity = current_integrity

	max_integrity = new_max

	if(new_failure_integrity != null)
		integrity_failure = new_failure_integrity

	if(can_break && integrity_failure && current_integrity <= integrity_failure)
		obj_break(damage_type)
		return TRUE
	return FALSE

///returns how much the object blocks an explosion. Used by subtypes.
/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")
