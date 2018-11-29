try (destroyDialog ::create_wall) catch()
rollout create_wall "         + CREAR MURO"
(
	local walls = #()
	fn filterLine shape = isKindOf shape SplineShape or isKindOf shape Line
 
											/*INTERFACES */
	group "Nombre de muro" 
	(
		edittext et_wallname "" pos:[5,25] width:135 height:17 text:"Nuevo_muro"
		colorPicker cp_wire "" color:[61,135,6] pos:[138,25] width:15 height:17
		checkbox cb_unique "Usar nombre unico" pos:[10,45]
		checkbox cb_random "Color aleatorio" pos:[10,65] 
	)
	group " Parametros de Muro" 
	(
		radiobuttons rb_mode "Mode:" labels:#("Outline-Extrude", "Extrude-Shell") pos:[10,110] 
		spinner spn_outline "Outline   =  " range:[-1e5,1e5,0.00] type:#worldunits pos:[11,160] fieldwidth:70
		spinner spn_extrude "Extrude  =  " range:[-1e5,1e5,1.80] type:#worldunits pos:[10,180] fieldwidth:70
		spinner spn_extsegs "E - Segs  =  " range:[1,1e2,1] type:#integer pos:[10,200] fieldwidth:70
		checkbox cb_extsmooth "Smooth" pos:[10,220] width:60 checked:off
		checkbox cb_mapcoords "Map Coords" pos:[72,220] checked:off
		checkbox cb_capE "Cap End" pos:[10,240] width:60 checked:on
		checkbox cb_capS "Cap Start" pos:[72,240] checked:on
		checkbox cb_extrude "Instance Extrude Modifier" checked:off pos:[10,260]

	)
	
 	button btn_create "► LEVANTAR MURO"     pos:[4,285] width:152 height:30
/* 	 
	button btn_delete "▓  ELIMINAR MURO" pos:[4,315] width:152 height:18
	
	*/
	button detach_cara  " CONFIGURAR CARA"     pos:[4,315] width:152 height:18
    /*FUNCIONES */
	
	
		on detach_cara pressed do 
	
	(
select $Nuevo_muro
modPanel.addModToSelection (Edit_Poly ()) ui:on
subobjectLevel = 4
$.modifiers[#Edit_Poly].selectByMaterialID = 0
$.modifiers[#Edit_Poly].ButtonOp #SelectByMaterial
$.modifiers[#Edit_Poly].SetOperation #Inset
$.modifiers[#Edit_Poly].insetAmount = 0.02
$.modifiers[#Edit_Poly].Commit ()
$.modifiers[#Edit_Poly].SetOperation #ExtrudeFace
$.modifiers[#Edit_Poly].extrudeFaceHeight = -0.04
$.modifiers[#Edit_Poly].Commit ()
	
	
$.modifiers[#Edit_Poly].ButtonOp #DetachFace
$.modifiers[#Edit_Poly].DetachToObject "INTERIOR_FACE"
$.wirecolor = color 196 88 225

macros.run "Modifier Stack" "Convert_to_Poly"
	
	
	
/* 	
$.modifiers[#Edit_Poly].ButtonOp #SelectByMaterial
$.modifiers[#Edit_Poly].SetOperation #Inset
$Nuevo_muro.modifiers[#Edit_Poly].insetAmount = 0.02
$.modifiers[#Edit_Poly].SetOperation #ExtrudeFace
$Nuevo_muro.modifiers[#Edit_Poly].extrudeFaceHeight = -0.04		
$.modifiers[#Edit_Poly].Commit ()	
select $Nuevo_muro
macros.run "Modifier Stack" "Convert_to_Poly"
	
*/
	
/* 	
$.modifiers[#Edit_Poly].SetOperation #Inset
$Nuevo_muro.modifiers[#Edit_Poly].insetAmount = 0.02
$.modifiers[#Edit_Poly].materialIDToSet = 1
$.modifiers[#Edit_Poly].Commit ()	
$.modifiers[#Edit_Poly].Select #Face #{6}
$Nuevo_muro.modifiers[#Edit_Poly].materialIDToSet = 1
$.modifiers[#Edit_Poly].SetOperation #ExtrudeFace
$Nuevo_muro.modifiers[#Edit_Poly].extrudeFaceHeight = -0.04	
$.modifiers[#Edit_Poly].Commit ()
select $Nuevo_muro
macros.run "Modifier Stack" "Convert_to_Poly"
*/ 

		
		)
	
	
	
	
	on rb_mode changed state do 
	(
		if state == 1 then 
		(
			spn_outline.enabled = on
			spn_shellin.enabled = spn_shellout.enabled = spn_shellsegs.enabled = cb_shell.enabled = cb_capS.checked = cb_capE.checked = off
			cb_shellsmooth.enabled = cb_ids.enabled = spn_smooth.enabled = et_matid.enabled = cb_mat.enabled = off
			cp_in.enabled = cp_out.enabled = cp_edge.enabled = off
		)
		else 
		(
			spn_outline.enabled = off
			spn_shellin.enabled = spn_shellout.enabled = spn_shellsegs.enabled = cb_shell.enabled = cb_capS.checked = cb_capE.checked = on
			cb_shellsmooth.enabled = cb_ids.enabled = cb_mat.enabled = on
			if cb_shellsmooth.checked then spn_smooth.enabled = on else spn_smooth.enabled = off
			if cb_ids.checked then et_matid.enabled = on else et_matid.enabled = off
			if cb_mat.checked then cp_in.enabled = cp_out.enabled = cp_edge.enabled = on else  cp_in.enabled = cp_out.enabled = cp_edge.enabled = off
		)
	)
	on cb_shellsmooth changed state do spn_smooth.enabled = state
	on cb_ids changed state do et_matid.enabled = state
	on cb_mat changed state do (cp_in.enabled = cp_out.enabled = cp_edge.enabled = state)
	on btn_convert pressed do if selection.count == 0 then messagebox "Select Shape Object" title:"Warning" beep:off else
	(
		with redraw off (for sp in selection where not filterLine sp do convertToSplineShape sp)
	)
	on btn_reverse pressed do if selection.count == 0 then messagebox "Select Shape Object" title:"Warning" beep:off else
	(
		with redraw off
		(
			for sp in selection where filterLine sp do 
			(
				integer = numSplines sp
				number = if (e = getSplineSelection sp).count == 0 then (#{1..numsplines sp} as array) else e
				for n in number do reverse sp n
			)
		)
	)

	on btn_delete pressed do (delete (for node in walls where isValidNode node collect node) ; free walls)
	on btn_create pressed do if selection.count == 0 then messagebox "Select Shape Object" title:"Warning" beep:off else
	(
		
		
		if et_wallname.text == "" then messagebox "Enter Some Name" title:"Warning" beep:off else
		(
			if GetCommandPanelTaskMode() != #create do setCommandPanelTaskMode #create
			node = (Extrude amount:spn_extrude.value segs:spn_extsegs.value capStart:cb_capS.checked capEnd:cb_capE.checked smooth:cb_extsmooth.checked mapcoords:cb_mapcoords.checked)
			modifier = if rb_mode.state == 2 do 
			(
				array = #(1,2,3)
				if cb_ids.checked do
				(
					if et_matid.text == "" then et_matid.text = "1-2-3" else
					(
						if (e = FilterString et_matid.text " - ").count != 3 then (et_matid.text = "1-2-3") else
						(
							if (e = for s in e where (number = s as integer) != undefined collect number).count != 3 then et_matid.text = "1-2-3" else array = #(e[1], e[2],e[3])
						)
					)
					
	
					
					
				)
				Shell innerAmount:spn_shellin.value outerAmount:spn_shellout.value Segments:spn_shellsegs.value straightenCorners:on \
				overrideInnerMatID:cb_ids.checked matInnerID:(array[1]) overrideOuterMatID:cb_ids.checked matOuterID:(array[2]) overrideMatID:cb_ids.checked matID:(array[3]) \
				autosmooth:cb_shellsmooth.checked autoSmoothAngle:spn_smooth.value
				

				
				
				
			)
			material = if rb_mode.state == 2 and cb_mat.checked do
			(
				color = #(cp_in.color, cp_out.color, cp_edge.color)
				Multimaterial materialList:(for i = 1 to 3 collect standard diffuse:color[i])
			)
			
			
			
			with redraw off
			(

				for sp in selection where isKindOf sp shape do 
				(
					shape = copy sp name:(if cb_unique.checked then uniquename et_wallname.text else et_wallname.text) \
					wirecolor:(if cb_random.checked then (random black white) else cp_wire.color)
					append walls shape
					if spn_outline.value != 0 and rb_mode.state == 1 do applyOffset shape spn_outline.value
					
					if spn_extrude.value != 0 do
					(
						if not cb_extrude.checked then addmodifier shape (copy node) else addmodifier shape node
					)
		
					if rb_mode.state == 2 do
					(
						if not (spn_shellin.value == 0 and spn_shellout.value == 0) do
						(
							if not cb_shell.checked then addmodifier shape (copy modifier) else addmodifier shape modifier
						)
						if cb_mat.checked do shape.mat = material
					)	
					
					)
					
					
					
					
					
			)
		)
	)
)
createDialog create_wall 160 400 10 110 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
