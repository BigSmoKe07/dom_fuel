Config = {}

Config.Debug = false

Config.FuelUsage = {
    rpmUsage = {
        [1.0] = 0.14,
		[0.9] = 0.12,
		[0.8] = 0.10,
		[0.7] = 0.09,
		[0.6] = 0.08,
		[0.5] = 0.07,
		[0.4] = 0.05,
		[0.3] = 0.04,
		[0.2] = 0.02,
		[0.1] = 0.01,
		[0.0] = 0.00,
    },
    classUsage = {
        [13] = 0.0, -- Cycles
    }
}




Config.Blip = {
    Toggle = false,
    Sprite = 361, -- Jerry Can
    Scale = 0.7,
    Color = 47, -- Orange
}

Config.PumpTarget = {
    Radius = 1.0,
    Distance = 1.5,
}

Config.Refill = {
    RefillValue = 1.0,
    RefillTick = 250,
}

Config.FuelOrder = {
    NPCModel = 'ig_floyd',
    NPCLocation = vec3(591.8682, 2783.0234, 42.4812), --591.8682, 2783.0234, 43.4812, 4.4763
    NPCHeading = (4.4763),
    NPCZoneSize = vec3(55, 60, 20),
    NPCZoneRotation = 10,

    FuelTruck = 'phantom3',
    FuelTruckLocation = vec4(605.3388, 2792.4185, 41.7799, 277.1472), --605.3388, 2792.4185, 41.7799, 277.1472
    FuelTrailer = 'tanker',
    FuelTrailerLocation = vec4(594.9206, 2791.3794, 41.8011, 276.1976), --594.9206, 2791.3794, 41.8011, 276.1976

    DropOffSize = vec3(20, 20, 10),

    Small = {fuel = 5000, cost = 15000, duration = 30000},
    Medium = {fuel = 10000, cost = 30000, duration = 60000},
    Large = {fuel = 15000, cost = 45000, duration = 90000},

    MaxFuel = 100000
}
Config.FuelOrderSandy = {
    NPCModel = 'ig_floyd',
    NPCLocation = vec3(1716.4191, -1622.3763, 111.4767),
    NPCHeading = (185.8319), --1716.4191, -1622.3763, 112.4767, 185.8319
    NPCZoneSize = vec3(55, 60, 20),
    NPCZoneRotation = 10,

    FuelTruck = 'phantom3',
    FuelTruckLocation = vec4(1726.776, -1617.651, 112.651, 188.199),
    FuelTrailer = 'tanker',
    FuelTrailerLocation = vec4(1726.015, -1611.914, 112.463, 188.956),

    DropOffSize = vec3(20, 20, 10),

    Small = {fuel = 5000, cost = 2000, duration = 30000},
    Medium = {fuel = 10000, cost = 3000, duration = 60000},
    Large = {fuel = 15000, cost = 5000, duration = 90000},

    MaxFuel = 100000
}

