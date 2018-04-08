-- Benjamin Fichet
-- 2018 - 04 - 08 - 03:38pm / drunk
-- Because skinning must be an elegant task!
---------------------------------------------------------
struct HandySkinManipulator (

	on create do ()
)




struct SkinAbsWeightManipBackend (

	default_multiplier =  0.001,
	node               = undefined,
	sknmod             = undefined,
	cursorBasePos      = undefined,
	selectedVerts      = undefined,
	selectedBone       = undefined,
	_vertexBoneid      = undefined,


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
			
			if shiftKey and (_vertexBoneid == undefined) then ( -- use the base weight as starting point
				-- find vertex's bone id
				local theb = undefined
				local vertex_bone_count = skinOps.GetVertexWeightCount this.sknmod i
				for bn = 1 to vertex_bone_count where ((skinOps.GetVertexWeightBoneID this.sknmod i bn) == this.selectedBone) do (base_weight  = skinops.getvertexweight this.sknmod i bn)
			)

			local mvt_2d = (this.cursorBasePos - viewPoint)*this.default_multiplier
			local mvt_1d = base_weight + ((((mvt_2d.x*-1) + mvt_2d.y)*0.5))

			skinOps.SetVertexWeights this.sknmod i this.selectedBone mvt_1d --(oWeight)
			--skinOps.SetVertexWeights this.sknmod i this.selectedBone mvt_1d --(oWeight)
		)
	),


	on create do ()
)


tool SkinAbsWeightManip (
	local backend  = undefined

	on mousePoint click do --coordsys grid
	(
		if click == 1 then (
			backend = SkinAbsWeightManipBackend()
			if (not backend.init viewPoint:viewPoint) then (throw "Unable to initialize SkinAbsWeightManipBackend")
		)
		if click == 3 then #stop
	)
	on mouseMove click do
	(
		if click == 2 then (backend.moveEvent ctrlKey:ctrlKey altKey:altKey shiftKey:shiftKey viewPoint:viewPoint)
	)
)