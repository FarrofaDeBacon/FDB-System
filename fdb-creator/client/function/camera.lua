ActiveCam = 0
currentCamDestionation = ""
camCoords = {}
baseHeading = false
rotatePedIndex = 0
ActualCamera = nil
function MoveCam(destination, data, tpcam, target)
	local ped = tonumber(target) or CachePed
	if destination == "mouth" or destination == "facial" or destination == "eyesandbrows" then
		destination	= "head"
	end
	if ped == nil then return end
	if destination == currentCamDestionation then return end
	currentCamDestionation = destination
	if not camCoords[ped] then
		camCoords[ped] = {}
		camCoords[ped].default = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.3),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.0),
			fov = 30.0,
		}
		camCoords[ped].edit = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.5, 5.0, 0.3),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.5, 0.0, 0.0),
			fov = 30.0,
		}
		camCoords[ped].Body = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.25, 4.0, 0.5),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.25, 0.0, 0.3),
			fov = 30.0
		}
		camCoords[ped].head = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.65),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, 0.65),
			fov = 30.0
		}
		camCoords[ped].selected = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.7, 0.65),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, 0.65),
			fov = 40.0
		}
		camCoords[ped].eyesandbrows = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.65),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, 0.65),
			fov = 30.0
		}
		camCoords[ped].facial = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.65),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, 0.65),
			fov = 30.0
		}
		camCoords[ped].mouth = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.65),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, 0.65),
			fov = 30.0
		}
		camCoords[ped].upperbody = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.2),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, 0.2),
			fov = 30.0
		}
		camCoords[ped].lowerbody = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, -0.4),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, -0.4),
			fov = 30.0
		}
	end
	local coords, target, fov
	if destination == "head" then
		local headBone = 21030 -- Hash du bone "head"
		local pedCoords = GetEntityCoords(ped)
		local headCoords = GetPedBoneCoords(ped, headBone, 0.0, 0.0, 0.0)
		local headOffsetZ = headCoords.z - pedCoords.z
		camCoords[ped].head = {
			coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, headOffsetZ),
			target = GetOffsetFromEntityInWorldCoords(ped, 0.1, 0.0, headOffsetZ),
			fov = 30.0
		}
	end
	if not camCoords[ped][destination] then
		if not data then
			coords = camCoords[ped].default.coords
			target = camCoords[ped].default.target
			fov = camCoords[ped].default.fov
		else
			coords = data.coords
			target = data.target
			fov = data.fov
		end
	else
		coords = camCoords[ped][destination].coords
		target = camCoords[ped][destination].target
		fov = camCoords[ped][destination].fov
	end
	CamFov = fov
	BaseCamFov = fov
	if ActiveCam == 0 then
		Cam1 = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
		SetCamCoord(Cam1, coords)
		PointCamAtCoord(Cam1, target)
		SetCamActive(Cam1, true);
		if not tpcam then
			RenderScriptCams(true, true, 1000, true, true)
		else
			RenderScriptCams(true, false, 0, true, true)
		end
		SetCamFov(Cam1, fov)
		SetCamFocusDistance(Cam1, #(GetCamCoord(Cam1) - GetEntityCoords(ped)))
		ActualCamera = Cam1
		ActiveCam = 1
	else
		if not DoesCamExist(Cam2) then
			Cam2 = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
		end
		local from, to = 0, 0
		if ActiveCam == 1 then
			from = Cam1
			to = Cam2
			ActiveCam = 2
		else
			from = Cam2
			to = Cam1
			ActiveCam = 1
		end
		SetCamCoord(to, coords)
		PointCamAtCoord(to, target)
		SetCamFov(to, fov)
		if not tpcam then
			SetCamActiveWithInterp(to, from, 1000, true, true)
		else
			SetCamActive(to, true);
		end
		-- Wait(1000)
		SetCamFocusDistance(Cam2, #(GetCamCoord(Cam2) - GetEntityCoords(ped)))
		ActualCamera = Cam2
	end
end

function SwitchOffCam(ease)
	if ease then
		RenderScriptCams(false, true, 2000, true, true)
	else
		RenderScriptCams(false, false, 0, true, true)
	end
	if DoesCamExist(Cam1) then DestroyCam(Cam1) end
	if DoesCamExist(Cam2) then DestroyCam(Cam2) end
	ActiveCam = 0
	currentCamDestionation = ""
	camCoords = {}
	baseHeading = false
	rotatePedIndex = 0
end

function CameraZoom(sens)
	if sens then
		CamFov -= 0.5
	else
		CamFov += 0.5
	end
	if ActiveCam == 1 then
		SetCamFov(Cam1, CamFov)
	else
		SetCamFov(Cam2, CamFov)
	end
end

lamp = nil
lamp2 = nil
CreatorLight = false
function Light()
	Citizen.CreateThread(function()
		local ped = CachePed
		if lamp ~= nil and lamp2 ~= nil then
			return
		end
		CreatorLight = true
		Wait(1000)
		local lightCoords = GetOffsetFromEntityInWorldCoords(ped, 1.2, 1.2, 0.5)
		RequestModel(GetHashKey("p_lamphanging06x"))
		while not HasModelLoaded(GetHashKey("p_lamphanging06x")) do
			Wait(0)
		end
		if CreatorLight == false then
			return
		end
		lamp = CreateObject(GetHashKey("p_lamphanging06x"), lightCoords.x, lightCoords.y, lightCoords.z, false, true,
			true)
		-- PlaceEntityOnGroundProperly(lamp)
		SetEntityLightsEnabled(lamp, true)
		SetLightsTypeForEntity(lamp, 20)
		SetLightsColorForEntity(lamp, 255, 200, 170)
		SetLightsIntensityForEntity(lamp, 0.0)
		AttachEntityToEntity(lamp, ped, GetEntityBoneIndexByName(ped, 'skel_pelvis'), 0.56, 1.82, 1.75, -41.0, 3.0, -9.0,
			false, false, false, false, 0, false)
		SetEntityAlpha(lamp, 0, false)

		lamp2 = CreateObject(GetHashKey("p_lamphanging06x"), lightCoords.x, lightCoords.y, lightCoords.z, false, true,
			true)
		-- PlaceEntityOnGroundProperly(lamp)
		SetEntityLightsEnabled(lamp2, true)
		SetLightsTypeForEntity(lamp2, 20)
		SetLightsColorForEntity(lamp2, 255, 200, 170)
		SetLightsIntensityForEntity(lamp2, 0.0)
		AttachEntityToEntity(lamp2, ped, GetEntityBoneIndexByName(ped, 'skel_pelvis'), 0.6, -1.7, 2.2, 39.0, 38.0, -19.0,
			false, false, false, false, 0, false)
		SetEntityAlpha(lamp2, 0, false)
		if CreatorLight == false then
			return
		end

		-- Gradually increase the light intensity over 500ms

		local duration = 500
		local steps = 50
		local stepDuration = duration / steps
		local factor, factor2 = 10.0, 5.0
		for i = 1, steps do
			local intensity = (i / steps) * factor
			local intensity2 = (i / steps) * factor2
			SetLightsIntensityForEntity(lamp, intensity)
			SetLightsIntensityForEntity(lamp2, intensity2)
			Wait(stepDuration)
		end

		while CreatorLight == true do
			SetLightsIntensityForEntity(lamp, 10.0) -- Pleine intensité pendant la journée
			UpdateLightsOnEntity(lamp)
			SetLightsIntensityForEntity(lamp2, 5.0) -- Pleine intensité pendant la journée
			UpdateLightsOnEntity(lamp2)
			Wait(0)
		end
		local duration = 500
		local steps = 50
		local stepDuration = duration / steps
		local factor, factor2 = 10.0, 5.0
		for i = steps, 1, -1 do
			local intensity = (i / steps) * factor
			local intensity2 = (i / steps) * factor2
			SetLightsIntensityForEntity(lamp, intensity)
			SetLightsIntensityForEntity(lamp2, intensity2)
			Wait(stepDuration)
		end

		DeleteObject(lamp)
		DeleteObject(lamp2)
		lamp = nil
		lamp2 = nil
	end)
end

AddEventHandler("onResourceStop", function(resourceName)
	if resourceName == GetCurrentResourceName() then
		DeletePed(CachePed)
		SwitchOffCam()
		if lamp ~= nil then
			DeleteObject(lamp)
		end
		if lamp2 ~= nil then
			DeleteObject(lamp2)
		end
		DisplayRadar(true)
	end
end)
