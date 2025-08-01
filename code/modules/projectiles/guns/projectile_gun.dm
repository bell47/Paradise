/obj/item/gun/projectile
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason"
	name = "projectile gun"
	icon_state = "tommygun"
	origin_tech = "combat=2;materials=2"
	materials = list(MAT_METAL=1000)

	var/mag_type = /obj/item/ammo_box/magazine/m10mm //Removes the need for max_ammo and caliber info
	var/obj/item/ammo_box/magazine/magazine
	var/can_tactical = FALSE //check to see if the gun can tactically reload
	/// The sound it will make when the gun suppression is TRUE
	var/suppressed_sound = 'sound/weapons/gunshots/gunshot_silenced.ogg'

/obj/item/gun/projectile/Initialize(mapload)
	. = ..()
	if(!magazine)
		magazine = new mag_type(src)
	chamber_round()
	update_icon()

/obj/item/gun/projectile/Destroy()
	QDEL_NULL(magazine)
	return ..()

/obj/item/gun/projectile/update_name()
	. = ..()
	if(sawn_state)
		name = "sawn-off [name]"
	else
		name = initial(name)

/obj/item/gun/projectile/update_desc()
	. = ..()
	if(sawn_state)
		desc = sawn_desc
	else
		desc = initial(desc)

/obj/item/gun/projectile/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][suppressed ? "-suppressed" : ""][sawn_state ? "_sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][suppressed ? "-suppressed" : ""][sawn_state ? "_sawn" : ""]"

/obj/item/gun/projectile/update_overlays()
	. = ..()
	if(bayonet && can_bayonet)
		. += knife_overlay

/obj/item/gun/projectile/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	var/obj/item/ammo_casing/ammo_chambered = chambered //Find chambered round
	if(!istype(ammo_chambered))
		chamber_round()
		return
	if(eject_casing && !QDELETED(ammo_chambered))
		ammo_chambered.forceMove(get_turf(src)) //Eject casing onto ground.
		ammo_chambered.SpinAnimation(10, 1) //next gen special effects
		playsound(src, chambered.casing_drop_sound, 60, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	if(empty_chamber)
		chambered = null
	chamber_round()
	return

/obj/item/gun/projectile/proc/chamber_round()
	if(chambered || !magazine)
		return
	else if(magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.loc = src
	return

/obj/item/gun/projectile/can_shoot()
	if(!magazine || !magazine.ammo_count(0))
		return 0
	return 1

/obj/item/gun/projectile/proc/can_reload()
	return !magazine

/obj/item/gun/projectile/proc/reload(obj/item/ammo_box/magazine/AM, mob/user)
	user.unequip(AM)
	magazine = AM
	magazine.forceMove(src)
	if(w_class >= WEIGHT_CLASS_NORMAL && !suppressed)
		playsound(src, magin_sound, 50, TRUE)
	else
		playsound(src, magin_sound, 50, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	chamber_round()
	AM.update_icon()
	update_icon()
	if(!user)
		return
	// Update the hand opposite of the one holding ammo (the current one)
	if(user.hand)
		user.update_inv_r_hand()
	else
		user.update_inv_l_hand()
	return

/obj/item/gun/projectile/attackby__legacy__attackchain(obj/item/A as obj, mob/user as mob, params)
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			if(can_reload())
				reload(AM, user)
				to_chat(user, "<span class='notice'>You load a new magazine into \the [src].</span>")
				return TRUE
			else if(!can_tactical)
				to_chat(user, "<span class='notice'>There's already a magazine in \the [src].</span>")
				return TRUE
			else
				to_chat(user, "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>")
				magazine.loc = get_turf(loc)
				magazine.update_icon()
				magazine = null
				reload(AM, user)
				return TRUE
		else
			to_chat(user, "<span class='notice'>You can't put this type of ammo in \the [src].</span>")
			return TRUE
	if(istype(A, /obj/item/suppressor))
		var/obj/item/suppressor/S = A
		if(can_suppress)
			if(!suppressed)
				if(!user.unequip(A))
					return
				A.forceMove(src)
				to_chat(user, "<span class='notice'>You screw [S] onto [src].</span>")
				playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
				suppressed = A
				S.oldsound = fire_sound
				S.initial_w_class = w_class
				fire_sound = suppressed_sound
				w_class = WEIGHT_CLASS_NORMAL //so pistols do not fit in pockets when suppressed
				A.loc = src
				update_icon()
				return
			else
				to_chat(user, "<span class='warning'>[src] already has a suppressor.</span>")
				return
		else
			to_chat(user, "<span class='warning'>You can't seem to figure out how to fit [S] on [src].</span>")
			return
	else
		return ..()

/obj/item/gun/projectile/attack_hand(mob/user)
	if(loc == user)
		if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			if(!user.is_holding(src))
				..()
				return
			to_chat(user, "<span class='notice'>You unscrew [suppressed] from [src].</span>")
			playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
			user.put_in_hands(suppressed)
			fire_sound = S.oldsound
			w_class = S.initial_w_class
			suppressed = FALSE
			update_icon()
			return
	..()

/obj/item/gun/projectile/attack_self__legacy__attackchain(mob/living/user as mob)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(magazine)
		magazine.loc = get_turf(loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
		playsound(src, magout_sound, 50, 1)
	else if(chambered)
		AC.loc = get_turf(src)
		AC.SpinAnimation(10, 1)
		chambered = null
		to_chat(user, "<span class='notice'>You unload the round from \the [src]'s chamber.</span>")
		playsound(src, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, 1)
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	update_icon()
	return

/obj/item/gun/projectile/examine(mob/user)
	. = ..()
	. += "Has [get_ammo()] round\s remaining."
	. += "<span class='notice'>Use in hand to empty the gun's ammo reserves.</span>"

/obj/item/gun/projectile/proc/get_ammo(countchambered = 1)
	var/boolets = 0 //mature var names for mature people
	if(chambered && countchambered)
		boolets++
	if(magazine)
		boolets += magazine.ammo_count()
	return boolets

/obj/item/gun/projectile/suicide_act(mob/user)
	if(chambered && chambered.BB && !chambered.BB.nodamage)
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			process_fire(user, user, 0, zone_override = "head")
			user.visible_message("<span class='suicide'>[user] blows [user.p_their()] brains out with [src]!</span>")
			return BRUTELOSS
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return OXYLOSS
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow [user.p_their()] brains out with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, TRUE, -1)
		return OXYLOSS

/obj/item/gun/projectile/proc/sawoff(mob/user)
	if(sawn_state == SAWN_OFF)
		to_chat(user, "<span class='warning'>\The [src] is already shortened!</span>")
		return
	if(bayonet)
		to_chat(user, "<span class='warning'>You cannot saw-off [src] with [bayonet] attached!</span>")
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] begins to shorten \the [src].", "<span class='notice'>You begin to shorten \the [src]...</span>")

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
		return

	if(do_after(user, 30, target = src))
		if(sawn_state == SAWN_OFF)
			return
		user.visible_message("[user] shortens \the [src]!", "<span class='notice'>You shorten \the [src].</span>")
		w_class = WEIGHT_CLASS_NORMAL
		item_state = "gun"//phil235 is it different with different skin?
		slot_flags &= ~ITEM_SLOT_BACK	//you can't sling it on your back
		slot_flags |= ITEM_SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
		sawn_state = SAWN_OFF
		update_appearance()
		return 1

// Sawing guns related proc
/obj/item/gun/projectile/proc/blow_up(mob/user)
	. = 0
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.BB)
			process_fire(user, user,0)
			. = 1
