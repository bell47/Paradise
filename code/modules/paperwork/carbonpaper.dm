/obj/item/paper/carbon
	icon_state = "paper_stack"
	var/copied = 0
	var/iscopy = 0


/obj/item/paper/carbon/update_icon_state()
	if(iscopy)
		if(info)
			icon_state = "cpaper_words"
			return
		icon_state = "cpaper"
	else if(copied)
		if(info)
			icon_state = "paper_words"
			return
		icon_state = "paper"
	else
		if(info)
			icon_state = "paper_stack_words"
			return
		icon_state = "paper_stack"



/obj/item/paper/carbon/verb/removecopy()
	set name = "Remove carbon-copy"
	set category = "Object"

	if(copied == 0)
		var/obj/item/paper/carbon/c = src
		var/copycontents = html_decode(c.info)
		var/obj/item/paper/carbon/copy = new /obj/item/paper/carbon (usr.loc)
		copycontents = replacetext(copycontents, "<font face=\"[c.deffont]\" color=", "<font face=\"[c.deffont]\" nocolor=")	//state of the art techniques in action
		copycontents = replacetext(copycontents, "<font face=\"[c.crayonfont]\" color=", "<font face=\"[c.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
		copy.info += copycontents
		copy.info += "</font>"
		copy.name = "Copy - " + c.name
		copy.fields = c.fields
		copy.updateinfolinks()
		to_chat(usr, "<span class='notice'>You tear off the carbon-copy!</span>")
		c.copied = 1
		copy.iscopy = 1
		copy.update_icon()
		c.update_icon()
	else
		to_chat(usr, "There are no more carbon copies attached to this paper!")
