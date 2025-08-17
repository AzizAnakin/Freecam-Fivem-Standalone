-- config.lua freecam
Config = {}

-- Distance maximale par rapport à la position initiale
Config.CameraRange = 100.0

-- Commande pour activer/désactiver la FreeCam
Config.ActivationCommand = "freecam"

-- Vitesse de déplacement de base de la caméra
Config.BaseSpeed = 0.1

-- Multiplicateur de vitesse lorsque Shift est maintenu (accélérer)
Config.FastSpeedMultiplier = 3.0

-- Multiplicateur de vitesse lorsque Ctrl est maintenu (ralentir)
Config.SlowSpeedMultiplier = 0.5

-- Sensibilité de la souris pour la rotation de la caméra
Config.MouseSensitivity = 8.0

-- Valeurs minimales et maximales pour le FOV
Config.MinFOV = 5.0    -- Pour zoomer très près
Config.MaxFOV = 150.0  -- Pour dézoomer très loin

Config = {
    -- Freecam
    CameraRange = 100.0,
    ActivationCommand = "freecam",
    BaseSpeed = 0.1,
    FastSpeedMultiplier = 3.0,
    SlowSpeedMultiplier = 0.5,
    MouseSensitivity = 8.0,
    MinFOV = 5.0,
    MaxFOV = 150.0,

}
