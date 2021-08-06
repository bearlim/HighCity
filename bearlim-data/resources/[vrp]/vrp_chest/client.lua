local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CONEXÃO ]----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("vrp_chest",src)
vSERVER = Tunnel.getInterface("vrp_chest")
-----------------------------------------------------------------------------------------------------------------------------------------
--[ VARIÁVEIS ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
local chestTimer = 0
local chestOpen = ""
-----------------------------------------------------------------------------------------------------------------------------------------
--[ STARTFOCUS ]-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	SetNuiFocus(false,false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CHESTCLOSE ]-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("chestClose",function(data)
	SetNuiFocus(false,false)
	SendNUIMessage({ action = "hideMenu" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ TAKEITEM ]---------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("takeItem",function(data)
	vSERVER.takeItem(tostring(chestOpen),data.item,data.amount)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ STOREITEM ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("storeItem",function(data)
	vSERVER.storeItem(tostring(chestOpen),data.item,data.amount)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ AUTO-UPDATE ]------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Creative:UpdateChest")
AddEventHandler("Creative:UpdateChest",function(action)
	SendNUIMessage({ action = action })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ REQUESTCHEST ]-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestChest",function(data,cb)
	local inventario,inventario2,peso,maxpeso,peso2,maxpeso2 = vSERVER.openChest(tostring(chestOpen))
	if inventario then
		cb({ inventario = inventario, inventario2 = inventario2, peso = peso, maxpeso = maxpeso, peso2 = peso2, maxpeso2 = maxpeso2 })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ VARIÁVEIS ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
local chest = {
	{ ['nome'] = "aDPLA", ['x'] = -1098.77, ['y'] = -826.01, ['z'] = 14.29, ['titulo'] = "[~g~E~w~] Para acessar o ~g~Arsenal~w~." },
	{ ['nome'] = "eDPLA", ['x'] = -1074.95, ['y'] = -821.42, ['z'] = 11.04, ['titulo'] = "[~g~E~w~] Para acessar o ~r~Armázem de Evidencias~w~." },
	{ ['nome'] = "sDMLA", ['x'] = 303.07, ['y'] = -599.04, ['z'] = 48.23, ['titulo'] = "[~g~E~w~] Para acessar o ~g~Armário de Suprimentos~w~." },

	{ ['nome'] = "motoclub", ['x'] = 609.03, ['y'] = -3089.6, ['z'] = 6.07, ['titulo'] = "[~r~E~w~] Para acessar o ~r~BAÚ~w~." },
	{ ['nome'] = "medellin", ['x'] = 1403.2, ['y'] = 1152.38, ['z'] = 114.34, ['titulo'] = "[~r~E~w~] Para acessar o ~r~BAÚ~w~." },

	{ ['nome'] = "grove", ['x'] = 1493.17, ['y'] = 6396.07, ['z'] = 20.79, ['titulo'] = "[~r~E~w~] Para acessar o ~r~BAÚ~w~." },
	{ ['nome'] = "vanilla", ['x'] = 92.76, ['y'] = -1291.69, ['z'] = 29.27, ['titulo'] = "[~r~E~w~] Para acessar o ~r~BAÚ~w~." },
	{ ['nome'] = "ballas", ['x'] = -1105.21, ['y'] = 4943.7, ['z'] = 218.65, ['titulo'] = "[~r~E~w~] Para acessar o ~r~BAÚ~w~." }
}
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CHESTTIMER ]-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		if chestTimer > 0 then
			chestTimer = chestTimer - 3
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CHEST ]------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("chest",function(source,args)
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped))
	for k,v in pairs(chest) do
		local distance = Vdist(x,y,z,v[2],v[3],v[4])
		if distance <= 2.0 and chestTimer <= 0 then
			chestTimer = 3
			if vSERVER.checkIntPermissions(v[1]) then
				SetNuiFocus(true,true)
				SendNUIMessage({ action = "showMenu" })
				chestOpen = v['nome']
			end
		end
	end
end)

Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	while true do
		local idle = 1000

		for k,v in pairs(chest) do
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
			local distance = GetDistanceBetweenCoords(v.x,v.y,cdz,x,y,z,true)
			local chest = chest[k]

			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), chest.x, chest.y, chest.z, true ) < 1.2 then
				DrawText3D(chest.x, chest.y, chest.z, chest.titulo)
			end
			
			if distance <= 5 then
				DrawMarker(23,chest.x,chest.y,chest.z-0.99, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.5, 232, 94, 72, 150, 0, 0, 0, 0)
				idle = 5
				if distance <= 1.2 and chestTimer <= 0 then
					if IsControlJustPressed(0,38) and vSERVER.checkIntPermissions(v['nome']) then
						chestTimer = 3
						SetNuiFocus(true,true)
						SendNUIMessage({ action = "showMenu" })
						chestOpen = v['nome']
					end
				end
			end
		end
		Citizen.Wait(idle)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ FUNÇÕES ]----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
end

