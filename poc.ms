-- Benjamin Fichet
-- 2018 - 04 - 08 - 03:38pm / drunk
-- Because skinning should be an elegant task!
---------------------------------------------------------

/* Class: SkinAbsWeightMToolController */
struct SkinAbsWeightMToolController (

	default_multiplier = 0.001,     -- the default multiplier (mousePosition/Weights)
	node               = undefined, -- selected node
	sknmod             = undefined, -- selected skin
	cursorBasePos      = undefined, -- used internally to calculate weights changes
	selectedVerts      = undefined, -- vertices to work with
	selectedBone       = undefined, -- bone to work with

	_vertexBoneid      = undefined, -- prob. unused


	fn init viewPoint:[0,0] = (
		local ret = false
		if selection.count == 1 then (
			local selectedMod = modPanel.getCurrentObject()

			if (classof(selectedMod) == Skin) then (

				this.node           = selection[1] -- safe, selection[1] is obviously defined if modPanel.getCurrentObject() is defined
				this.sknmod         = selectedMod  -- base data..
				this.cursorBasePos  = viewPoint

				-- Get-store selected vertices
				this.selectedVerts  = for i=1 to this.node.numverts where (skinOps.IsVertexSelected this.sknmod i) collect i
				--break()

				-- Get selected bone
				this.selectedBone = skinOps.GetSelectedBone this.sknmod

				-- Should be ready
				isReady = true
				ret     = true
			)
		)
		ret
	),

	fn moveEvent ctrlKey:false altKey:false shiftKey:false viewPoint:[0,0] = (
		-- Multipliers
		if ctrlKey  then (this.default_multiplier = 0.1)
		if altKey   then (this.default_multiplier = 0.00001)

		for i in this.selectedVerts do (
			local base_weight = 0
			
			if (not shiftKey) then ( -- use the base weight as starting point
				-- find vertex's bone id
				local theb = undefined
				local vertex_bone_count = skinOps.GetVertexWeightCount this.sknmod i
				for bn = 1 to vertex_bone_count where ((skinOps.GetVertexWeightBoneID this.sknmod i bn) == this.selectedBone) do (base_weight  = skinops.getvertexweight this.sknmod i bn)
			)

			local mvt_2d = (this.cursorBasePos - viewPoint)*this.default_multiplier
			local mvt_1d = base_weight + ((mvt_2d.x*-1)*0.5)
			
			-- Cap movements at 0 weight
			if mvt_1d < 0 then (this.cursorBasePos = viewPoint)

			skinOps.SetVertexWeights this.sknmod i this.selectedBone mvt_1d --(oWeight)
			--format "Set vertex: (%) weight: (%)\n" (i as string) (mvt_1d as string)
		)
	),

	on create do ()
)


/* 
Tool: SkinAbsWeightMTool 
	Skin Absolute Weight Mouse Tool
*/
tool SkinAbsWeightMTool (

	local tool_controller  = undefined
	on mousePoint click do --coordsys grid
	(
		if click == 1 then (
			tool_controller = SkinAbsWeightMToolController()
			if (not tool_controller.init viewPoint:viewPoint) then (throw "Unable to initialize SkinAbsWeightMToolController")
		)
		if click == 3 then #stop
	)
	on mouseMove click do
	(
		if click == 2 then (tool_controller.moveEvent ctrlKey:ctrlKey altKey:altKey shiftKey:shiftKey viewPoint:viewPoint)
	)
)
startTool SkinAbsWeightMTool
