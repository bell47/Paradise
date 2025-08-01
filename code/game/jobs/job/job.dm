/datum/job

	//The name of the job
	var/title = "NOPE"

	/// Job access. A list of constants from access_defines.dm.
	var/list/access = list()

	///Job Bitflag, used for Database entries - DO NOT JUST EDIT THESE
	var/flag = 0
	///Department(s) Bitflag, used for Databse entries - DO NOT JUST EDIT THESE
	var/department_flag = 0
	///list of the names of departments heads (as strings)
	var/department_head = list()
	///List of the department(s) this job is a part of
	var/job_departments = list()
	///Can this role access its department money account?
	var/department_account_access = FALSE
	/// Does this job get a bank account?
	var/has_bank_account = TRUE
	//How many players can be this job
	var/total_positions = 0

	//How many players can spawn in as this job
	var/spawn_positions = 0

	//How many players have this job
	var/current_positions = 0

	//Supervisors, who this person answers to directly
	var/supervisors = ""

	/// Text which is shown to someone in BIG BOLG RED when they spawn. Use for critically important stuff that could make/break a round
	var/important_information = null

	//Sellection screen color
	var/selection_color = "#ffffff"

	//List of alternate titles, if any
	var/list/alt_titles

	//If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	/// Flags for identifying by department, because we need other shit that isnt for the database
	var/job_department_flags

	//If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0

	// Assoc list of EXP_TYPE_ defines and the amount of time needed in those departments
	var/list/exp_map = list()

	/// Cannot pick this job if the character has these disabilities
	var/list/blacklisted_disabilities = list()
	/// If this job could have any amputated limbs
	var/missing_limbs_allowed = TRUE

	var/transfer_allowed = TRUE // If false, ID computer will always discourage transfers to this job, even if player is eligible
	var/hidden_from_job_prefs = FALSE // if true, job preferences screen never shows this job.

	var/admin_only = 0
	var/mentor_only = 0
	var/spawn_ert = 0
	var/syndicate_command = 0

	var/outfit

	///Job Objectives that crew with this job will have a roundstart
	var/required_objectives = list()

	/// Boolean detailing if this job has been banned because of a gamemode restriction i.e. The revolution has won, no more command
	var/job_banned_gamemode = FALSE

	/// Standard paycheck amount for this job
	var/standard_paycheck = CREW_PAY_ASSISTANT

//Only override this proc
/datum/job/proc/after_spawn(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_SPAWN, src, H)

	H.mind.initial_account.payday_amount = standard_paycheck

/datum/job/proc/announce(mob/living/carbon/human/H)
	return

/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE)
	if(!H)
		return 0

	H.dna.species.before_equip_job(src, H, visualsOnly)

	if(outfit)
		H.equipOutfit(outfit, visualsOnly)

	H.dna.species.after_equip_job(src, H, visualsOnly)

	if(!visualsOnly && announce)
		announce(H)

/datum/job/proc/get_access()
	return access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0


/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!GLOB.configuration.jobs.restrict_jobs_on_account_age)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/// Returns true if the character has a disability the selected job doesn't allow
/datum/job/proc/barred_by_disability(client/C)
	if(!C || !length(blacklisted_disabilities))
		return FALSE
	for(var/disability in blacklisted_disabilities)
		if(C.prefs.active_character.disabilities & disability)
			return TRUE
	return FALSE

/// Returns true if the character has amputated limbs when their selected job doesn't allow it
/datum/job/proc/barred_by_missing_limbs(client/C)
	if(!C || missing_limbs_allowed)
		return FALSE

	var/organ_status
	var/list/active_character_organs = C.prefs.active_character.organ_data

	for(var/organ_name in active_character_organs)
		organ_status = active_character_organs[organ_name]
		if(organ_status == "amputated")
			return TRUE
	return FALSE

/datum/job/proc/is_position_available()
	if(job_banned_gamemode)
		return FALSE
	return (current_positions < total_positions) || (total_positions == -1)

/datum/job/proc/is_spawn_position_available()
	if(job_banned_gamemode)
		return FALSE
	return (current_positions < spawn_positions) || (spawn_positions == -1)

/datum/job/proc/is_command_position()
	return (title in GLOB.command_positions)

/datum/outfit/job
	name = "Standard Gear"
	collect_not_del = TRUE // we don't want anyone to lose their job shit

	var/allow_loadout = TRUE
	var/allow_backbag_choice = TRUE
	var/jobtype = null

	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id
	l_ear = /obj/item/radio/headset
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/black
	pda = /obj/item/pda

	var/backpack = /obj/item/storage/backpack
	var/satchel = /obj/item/storage/backpack/satchel_norm
	var/dufflebag = /obj/item/storage/backpack/duffel
	box = /obj/item/storage/box/survival

	var/tmp/list/gear_leftovers = list()

/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(allow_backbag_choice)
		switch(H.backbag)
			if(GBACKPACK)
				back = /obj/item/storage/backpack //Grey backpack
			if(GSATCHEL)
				back = /obj/item/storage/backpack/satchel_norm //Grey satchel
			if(GDUFFLEBAG)
				back = /obj/item/storage/backpack/duffel //Grey Dufflebag
			if(LSATCHEL)
				back = /obj/item/storage/backpack/satchel //Leather Satchel
			if(DSATCHEL)
				back = satchel //Department satchel
			if(DDUFFLEBAG)
				back = dufflebag //Department dufflebag
			else
				back = backpack //Department backpack

	if(box && H.dna.species.speciesbox)
		box = H.dna.species.speciesbox

	if(allow_loadout && H.client && length(H.client.prefs.active_character.loadout_gear))
		for(var/gear in H.client.prefs.active_character.loadout_gear)
			var/datum/gear/G = GLOB.gear_datums[text2path(gear) || gear]
			if(G)
				var/permitted = FALSE

				if(G.allowed_roles)
					if(name in G.allowed_roles)
						permitted = TRUE
				else
					permitted = TRUE

				if(!permitted)
					to_chat(H, "<span class='warning'>Your current job or whitelist status does not permit you to spawn with [G.display_name]!</span>")
					continue

				if(G.slot)
					if(H.equip_to_slot_or_del(G.spawn_item(H, H.client.prefs.active_character.get_gear_metadata(G)), G.slot, TRUE))
						to_chat(H, "<span class='notice'>Equipping you with [G.display_name]!</span>")
					else
						gear_leftovers += G
				else
					gear_leftovers += G

/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	imprint_idcard(H)

	H.sec_hud_set_ID()

	imprint_pda(H)

	if(length(gear_leftovers))
		for(var/datum/gear/G in gear_leftovers)
			var/atom/placed_in = H.equip_or_collect(G.spawn_item(null, H.client.prefs.active_character.get_gear_metadata(G)))
			if(istype(placed_in))
				if(isturf(placed_in))
					to_chat(H, "<span class='notice'>Placing [G.display_name] on [placed_in]!</span>")
				else
					to_chat(H, "<span class='notice'>Placing [G.display_name] in your [placed_in.name].</span>")
				continue
			if(H.equip_to_appropriate_slot(G))
				to_chat(H, "<span class='notice'>Placing [G.display_name] in your inventory!</span>")
				continue
			if(H.put_in_hands(G))
				to_chat(H, "<span class='notice'>Placing [G.display_name] in your hands!</span>")
				continue
			to_chat(H, "<span class='danger'>Failed to locate a storage object on your mob, either you spawned with no hands free and no backpack or this is a bug.</span>")
			qdel(G)

		gear_leftovers.Cut()

	return 1

/datum/outfit/job/proc/imprint_idcard(mob/living/carbon/human/H)
	var/datum/job/J = SSjobs.GetJobType(jobtype)
	if(!J)
		J = SSjobs.GetJob(H.job)

	var/alt_title
	if(H.mind)
		alt_title = H.mind.role_alt_title

	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		C.access = J.get_access()
		C.registered_name = H.real_name
		C.rank = J.title
		C.assignment = alt_title ? alt_title : J.title
		C.sex = capitalize(H.gender)
		C.age = H.age
		C.name = "[C.registered_name]'s ID Card ([C.assignment])"
		C.photo = get_id_photo(H)

		if(H.mind && H.mind.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number
		C.owner_uid = H.UID()
		C.owner_ckey = H.ckey

/datum/outfit/job/proc/imprint_pda(mob/living/carbon/human/H)
	var/obj/item/pda/PDA = H.wear_pda
	var/obj/item/card/id/C = H.wear_id
	if(istype(PDA) && istype(C))
		PDA.owner = H.real_name
		PDA.ownjob = C.assignment
		PDA.ownrank = C.rank
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"
		if(H.client?.prefs.active_character.pda_ringtone)
			PDA.ttone = H.client.prefs.active_character.pda_ringtone

/datum/outfit/job/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/card/id/id = H.wear_id
	if(!id)
		return
	var/datum/job/J = SSjobs.GetJobType(jobtype)
	if(!J)
		J = SSjobs.GetJob(H.job)
	if(H.mind.role_alt_title)
		id.assignment = H.mind.role_alt_title
	else if(J)
		id.assignment = J.title
	else
		id.assignment = H.job // ERTs and other things without job datums

	if(!H.mind.initial_account)
		return
	id.associated_account_number = H.mind.initial_account.account_number

/// Used to give the gaze ability to NTReps and IAAs
/datum/outfit/job/proc/give_gaze(mob/living/carbon/human/user)
	user.AddSpell(new /datum/spell/inspectors_gaze(null))

/// Gives the imaginary space law booklet verb
/mob/living/carbon/human/proc/space_law()
	set name = "Open Space Law"
	set desc = "Open a memorized version of the space law booklet."
	set category = "Space Law"

	var/obj/item/book/manual/wiki/security_space_law/imaginary/book = new()
	if(!put_in_any_hand_if_possible(book))
		QDEL_NULL(book)

/// Gives the imaginary legal sop booklet verb
/mob/living/carbon/human/proc/sop_legal()
	set name = "Open Legal SOP"
	set desc = "Open a memorized version of the legal SOP booklet."
	set category = "Space Law"

	var/obj/item/book/manual/wiki/sop_legal/imaginary/book = new()
	if(!put_in_any_hand_if_possible(book))
		QDEL_NULL(book)
