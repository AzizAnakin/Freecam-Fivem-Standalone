-- ========= Commande freecam =========

local cam = nil
local freeCamActive = false
local initialPos = nil
local currentFOV = 90.0           -- FOV par défaut
local rollAngle = 0.0             -- Angle de roulis initial
local hudVisible = true           -- Contrôle la visibilité du HUD (scaleform)
local scaleform = nil

--------------------------------------------------
-- Fonctions d'activation et de désactivation
--------------------------------------------------
local function toggleFreeCam()
    local playerPed = PlayerPedId()

    if not freeCamActive then
        -- Activation du mode FreeCam
        freeCamActive = true
        initialPos = GetEntityCoords(playerPed)

        -- Création et positionnement de la caméra
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, initialPos.x, initialPos.y, initialPos.z + 1.0)
        SetCamRot(cam, 0.0, 0.0, 0.0)
        SetCamFov(cam, currentFOV)

        -- Activation de la caméra et rendu
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)

        -- Masquer HUD et radar
        DisplayHud(false)
        DisplayRadar(false)
        hudVisible = true
        scaleform = setupScaleform("instructional_buttons")

        -- Geler le joueur et désactiver ses collisions/invincibilité
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, true)
        SetPlayerInvincible(playerPed, true)

        -- Si le joueur est dans un véhicule, le geler également
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            FreezeEntityPosition(vehicle, true)
            SetEntityCollision(vehicle, false, true)
        end
    else
        -- Désactivation du mode FreeCam
        freeCamActive = false

        -- Détruire la caméra
        DestroyCam(cam, false)
        RenderScriptCams(false, false, 0, true, true)
        cam = nil

        -- Réafficher HUD et radar
        DisplayHud(true)
        DisplayRadar(true)

        -- Dégeler le joueur et réactiver ses collisions/invincibilité
        FreezeEntityPosition(playerPed, false)
        SetEntityCollision(playerPed, true, true)
        SetPlayerInvincible(playerPed, false)

        -- Si le joueur est dans un véhicule, le dégeler également
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            FreezeEntityPosition(vehicle, false)
            SetEntityCollision(vehicle, true, true)
        end

        -- Réinitialiser la scaleform
        scaleform = nil
    end
end

--------------------------------------------------
-- Fonctions utilitaires pour le calcul des vecteurs
--------------------------------------------------

-- Retourne le vecteur « forward » de la caméra à partir de sa rotation
local function GetCamForwardVector(cam)
    local rot = GetCamRot(cam, 2)
    local x = -math.sin(math.rad(rot.z)) * math.abs(math.cos(math.rad(rot.x)))
    local y =  math.cos(math.rad(rot.z)) * math.abs(math.cos(math.rad(rot.x)))
    local z =  math.sin(math.rad(rot.x))
    return vector3(x, y, z)
end

-- Retourne le vecteur droit de la caméra (perpendiculaire au vecteur forward)
local function GetCamRightVector(cam)
    local forwardVector = GetCamForwardVector(cam)
    return vector3(-forwardVector.y, forwardVector.x, 0.0)
end

--------------------------------------------------
-- Désactivation des contrôles du joueur
--------------------------------------------------

local function disablePlayerControls()
    -- Désactivation des mouvements et actions classiques du joueur
    DisableControlAction(0, 30, true)  -- Gauche/Droite
    DisableControlAction(0, 31, true)  -- Avant/Arrière
    DisableControlAction(0, 140, true) -- Attaque légère
    DisableControlAction(0, 141, true) -- Attaque lourde
    DisableControlAction(0, 142, true) -- Attaque alternative
    DisableControlAction(0, 24, true)  -- Tirer
    DisableControlAction(0, 25, true)  -- Viser
    DisableControlAction(0, 22, true)  -- Sauter
    DisableControlAction(0, 23, true)  -- Entrer dans un véhicule
    DisableControlAction(0, 75, true)  -- Sortir d'un véhicule
    DisableControlAction(0, 45, true)  -- Recharger
    DisableControlAction(0, 37, true)  -- Roue d'armes
end

--------------------------------------------------
-- Fonctions liées au Scaleform (HUD)
--------------------------------------------------

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function setupScaleform(scaleformName)
    local scaleform = RequestScaleformMovie(scaleformName)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    -- Instructions pour les déplacements horizontaux
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(1, 34, true))
    Button(GetControlInstructionalButton(1, 35, true))
    Button(GetControlInstructionalButton(1, 71, true))
    Button(GetControlInstructionalButton(1, 72, true))
    ButtonMessage("Gauche / Droite / Avant / Arrière")
    PopScaleformMovieFunctionVoid()

    -- Instructions pour le déplacement vertical
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(1, 44, true))
    Button(GetControlInstructionalButton(1, 38, true))
    ButtonMessage("Monter / Descendre")
    PopScaleformMovieFunctionVoid()

    -- Instructions pour le zoom
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(1, 16, true))
    Button(GetControlInstructionalButton(1, 17, true))
    ButtonMessage("Zoom caméra (Avant/Arrière)")
    PopScaleformMovieFunctionVoid()

    -- Instruction pour basculer l'affichage du HUD
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(1, 74, true))
    ButtonMessage("Afficher/Masquer HUD")
    PopScaleformMovieFunctionVoid()

    -- Slot pour l'affichage du FOV (sera mis à jour dynamiquement)
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    ButtonMessage("FOV:")
    PopScaleformMovieFunctionVoid()

    -- Instructions pour le roulis (flèches gauche/droite)
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    Button(GetControlInstructionalButton(1, 174, true))
    Button(GetControlInstructionalButton(1, 175, true))
    ButtonMessage("Incliner caméra (Roulis)")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

--------------------------------------------------
-- Enregistrement de la commande d'activation
--------------------------------------------------

-- Utilisation de la commande définie dans config.lua
if Config and Config.ActivationCommand then
    RegisterKeyMapping(Config.ActivationCommand, 'freecam', 'keyboard', 'F16')
    RegisterCommand(Config.ActivationCommand, function()
        toggleFreeCam()
    end, false)
else
    print("^1[SecuCMD] ERREUR: Config.ActivationCommand est nil ! Vérifiez config.lua et l'ordre de chargement.^7")
end

--------------------------------------------------
-- Gestion du HUD (toggle avec la touche H)
--------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if freeCamActive and IsControlJustPressed(0, 74) then -- Touche H
            hudVisible = not hudVisible
            if hudVisible then
                scaleform = setupScaleform("instructional_buttons")
            else
                if scaleform then
                    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
                    PopScaleformMovieFunctionVoid()
                end
            end
        end
    end
end)

--------------------------------------------------
-- Boucle principale de la FreeCam
--------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if freeCamActive then
            disablePlayerControls()

            local camPos = GetCamCoord(cam)
            local camRot = GetCamRot(cam, 2)

            -- Calcul du multiplicateur de vitesse
            local speedMultiplier = 1.0
            if IsControlPressed(0, 21) then
                speedMultiplier = Config.FastSpeedMultiplier
            elseif IsControlPressed(0, 36) then
                speedMultiplier = Config.SlowSpeedMultiplier
            end
            local moveSpeed = Config.BaseSpeed * speedMultiplier

            -- Déplacement caméra
            if IsControlPressed(1, 71) then -- Avancer
                camPos = camPos + (GetCamForwardVector(cam) * moveSpeed)
            end
            if IsControlPressed(1, 72) then -- Reculer
                camPos = camPos - (GetCamForwardVector(cam) * moveSpeed)
            end
            if IsControlPressed(0, 34) then -- Gauche
                camPos = camPos + (GetCamRightVector(cam) * moveSpeed)
            end
            if IsControlPressed(0, 35) then -- Droite
                camPos = camPos - (GetCamRightVector(cam) * moveSpeed)
            end
            if IsControlPressed(0, 44) then -- Monter
                camPos = camPos + vector3(0.0, 0.0, moveSpeed)
            end
            if IsControlPressed(0, 38) then -- Descendre
                camPos = camPos - vector3(0.0, 0.0, moveSpeed)
            end

            -- Limite de distance
            local offset = camPos - initialPos
            local distance = #(offset)
            if distance > Config.CameraRange then
                local clampedOffset = (offset / distance) * Config.CameraRange
                camPos = initialPos + clampedOffset
            end

            SetCamCoord(cam, camPos)

            -- Rotation caméra (souris)
            local xMagnitude = GetControlNormal(0, 1) * Config.MouseSensitivity
            local yMagnitude = GetControlNormal(0, 2) * Config.MouseSensitivity

            -- Clamp du pitch pour éviter les retournements
            local newPitch = math.max(-89.0, math.min(89.0, camRot.x - yMagnitude))
            local newYaw = camRot.z - xMagnitude

            -- Roulis (flèches gauche/droite)
            if IsControlPressed(1, 174) then -- Flèche gauche
                rollAngle = rollAngle - 1.0
            end
            if IsControlPressed(1, 175) then -- Flèche droite
                rollAngle = rollAngle + 1.0
            end

            -- Clamp du roulis pour éviter les valeurs extrêmes
            if rollAngle > 180.0 then rollAngle = -180.0 end
            if rollAngle < -180.0 then rollAngle = 180.0 end

            SetCamRot(cam, newPitch, rollAngle, newYaw, 2)

            -- Zoom caméra (molette)
            if IsControlPressed(2, 241) then
                currentFOV = math.max(Config.MinFOV, currentFOV - 1.0)
                SetCamFov(cam, currentFOV)
            end
            if IsControlPressed(2, 242) then
                currentFOV = math.min(Config.MaxFOV, currentFOV + 1.0)
                SetCamFov(cam, currentFOV)
            end

            -- Mise à jour du HUD (scaleform)
            if hudVisible and scaleform then
                local fovPercentage = ((currentFOV - Config.MinFOV) / (Config.MaxFOV - Config.MinFOV)) * 100
                PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
                PushScaleformMovieFunctionParameterInt(5)
                ButtonMessage(string.format("FOV: %.1f%%", fovPercentage))
                PopScaleformMovieFunctionVoid()
                DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            end
        else
            EnableControlAction(0, 37, true)
            EnableControlAction(0, 261, true)
            EnableControlAction(0, 262, true)
        end
    end
end)

--------------------------------------------------
-- Gestion de l'arrêt de la ressource pour restaurer l'état du joueur
--------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and freeCamActive then
        toggleFreeCam()
    end
end)

