/obj/item/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	desc = "A vending machine restock cart."
	usesound = 'sound/items/deconstruct.ogg'
	flags = CONDUCT
	force = 7
	throwforce = 10
	throw_speed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 70, ACID = 30)

	// Built automatically from the corresponding vending machine.
	// If null, considered to be full upon being restocked.
	var/list/products
	var/list/contraband
	var/list/premium

/obj/item/vending_refill/Initialize(mapload)
	. = ..()
	name = "\improper [machine_name] restocking unit"

/obj/item/vending_refill/examine(mob/user)
	. = ..()
	var/num = get_part_rating()
	if(num == INFINITY)
		. += "It's sealed tight, completely full of supplies."
	else if(num == 0)
		. += "It's empty!"
	else if(!isnull(num)) // If it's null, then the items haven't been properly added yet.
		. += "It can restock [num] item\s."

/obj/item/vending_refill/get_part_rating()
	. = 0
	if(isnull(products) && isnull(contraband) && isnull(premium))
		return null
	for(var/key in products)
		. += products[key]
	for(var/key in contraband)
		. += contraband[key]
	for(var/key in premium)
		. += premium[key]

	if(. > 30)
		return INFINITY

/obj/item/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"

/obj/item/vending_refill/coffee
	machine_name = "hot drinks"
	icon_state = "refill_joe"

/obj/item/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"

/obj/item/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"

/obj/item/vending_refill/cigarette
	machine_name = "cigarette"
	icon_state = "refill_smoke"

/obj/item/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"

/obj/item/vending_refill/hatdispenser
	machine_name = "hat"
	icon_state = "refill_costume"

/obj/item/vending_refill/suitdispenser
	machine_name = "suit"
	icon_state = "refill_costume"

/obj/item/vending_refill/shoedispenser
	machine_name = "shoe"
	icon_state = "refill_costume"

/obj/item/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"

/obj/item/vending_refill/crittercare
	machine_name = "CritterCare"
	icon_state = "refill_pet"

/obj/item/vending_refill/chinese
	machine_name = "MrChangs"

/obj/item/vending_refill/hydroseeds
	machine_name = "MegaSeed Servitor"
	icon_state = "refill_plant"

/obj/item/vending_refill/assist
	machine_name = "Vendomat"
	icon_state = "refill_engi"

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"

/obj/item/vending_refill/dinnerware
	machine_name = "Plasteel Chef's Dinnerware Vendor"
	icon_state = "refill_smoke"

/obj/item/vending_refill/engineering
	machine_name = "Robco Tool Maker"
	icon_state = "refill_engi"

/obj/item/vending_refill/youtool
	machine_name = "YouTool"
	icon_state = "refill_engi"

/obj/item/vending_refill/engivend
	machine_name = "Engi-Vend"
	icon_state = "refill_engi"

/obj/item/vending_refill/medical
	machine_name = "NanoMed Plus"
	icon_state = "refill_medical"

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/item/vending_refill/hydronutrients
	machine_name = "NutriMax"
	icon_state = "refill_plant"

/obj/item/vending_refill/security
	icon_state = "refill_sec"

/obj/item/vending_refill/sovietsoda
	machine_name = "BODA"
	icon_state = "refill_cola"

/obj/item/vending_refill/sustenance
	machine_name = "Sustenance Vendor"

/obj/item/vending_refill/donksoft
	machine_name = "Donksoft Toy Vendor"
	icon_state = "refill_donksoft"

/obj/item/vending_refill/robotics
	machine_name = "Robotech Deluxe"
	icon_state = "refill_engi"

/obj/item/vending_refill/smith
	machine_name = "Castivend"
	icon_state = "refill_custom"

//Departmental clothing vendors

/obj/item/vending_refill/secdrobe
	machine_name = "SecDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/detdrobe
	machine_name = "DetDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/medidrobe
	machine_name = "MediDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/virodrobe
	machine_name = "ViroDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/chemdrobe
	machine_name = "ChemDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/genedrobe
	machine_name = "GeneDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/scidrobe
	machine_name = "SciDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/robodrobe
	machine_name = "RoboDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/engidrobe
	machine_name = "EngiDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/atmosdrobe
	machine_name = "AtmosDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/cargodrobe
	machine_name = "CargoDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/exploredrobe
	machine_name = "ExploreDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/chefdrobe
	machine_name = "ChefDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/bardrobe
	machine_name = "BarDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/hydrodrobe
	machine_name = "HydroDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/janidrobe
	machine_name = "JaniDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/lawdrobe
	machine_name = "LawDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/traindrobe
	machine_name = "TrainDrobe"
	icon_state = "refill_clothes"

/obj/item/vending_refill/minedrobe
	machine_name = "MineDrobe"
	icon_state = "refill_clothes"
