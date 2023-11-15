local Target = exports.ox_target
local Input = lib.inputDialog
local Zone = lib.zones
local Inventory = exports.ox_inventory

local inJob = false
local GotFuelJob = false
local hasCurrentPumpProp = false
local isPump = false
local CurrentPumpProp
local CurrentPumpObj = {}
local CurrentRope = {}
local function GetModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(100)
    end
end 

-- Formats values with a (,) for front end display
function comma_value_format(n)
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function createBlip(station)
	local pumpblip = AddBlipForCoord(station)
	SetBlipSprite(pumpblip, 361)
	SetBlipDisplay(pumpblip, 2)
	SetBlipScale(pumpblip, 0.8)
	SetBlipColour(pumpblip, 6)
	SetBlipAsShortRange(pumpblip, true)
	BeginTextCommandSetBlipName('FUEL blips')
	EndTextCommandSetBlipName(pumpblip)

	return pumpblip
end

CreateThread(function()
	local blip
	while true do
		local playerCoords = GetEntityCoords(cache.ped)
        for k, v in pairs(Data.Stations) do
			local stationDistance = #(playerCoords - v.coords)
			if stationDistance < 60 then
				if Config.showBlips == 1 and not blip then
					blip = createBlip(v.coords)
				end
            end
        end
        Wait(600)
    end
end)
-- Create the owned gas stations
TriggerServerEvent('dom_fuel:GrabStationOwnership')
RegisterNetEvent('dom_fuel:CreateOwnedGasStations', function(result)
    for i = 1, #result do 
        local station = result[i].GasStation
        for k, v in pairs(Data.Stations) do
            if v.name == station then 
                -- Creates blip is true
                if Config.Blip.Toggle then 
                    -- local blip = AddBlipForCoord(v.coords)
                    -- SetBlipSprite(blip, 361)
                    -- SetBlipDisplay(blip, 2)
                    -- SetBlipScale(blip, Config.Blip.Scale)
                    -- SetBlipColour(blip, Config.Blip.Color)
                    -- SetBlipAsShortRange(blip, true)
                    -- AddTextEntry('FUEL BLIP', 'Gas Station')
                    -- BeginTextCommandSetBlipName('FUEL BLIP')
                    -- EndTextCommandSetBlipName(blip)
                end 
                -- Creates target for owner menu
                Target:addSphereZone({
                    coords = v.ownerMenu,
                    radius = Config.PumpTarget.Radius,
                    debug = Config.Debug,
                    options = {{
                        name = 'OwnerMenu',
                        icon = 'fa-solid fa-laptop',
                        distance = Config.PumpTarget.Distance,
                        label = 'Gas Station Details',
                        onSelect = function()
                            lib.callback('dom_fuel:GetIdentifier', false, function(player)
                                if player ~= result[i].id then 
                                    lib.notify({title = v.name..' Gas Station', description = 'You don\'t have the log-in', type = 'error'})
                                else 
                                    local station = v.name
                                    TriggerEvent('dom_fuel:OpenGasStationMenu', station)
                                end 
                            end)
                        end 
                    }}
                })
                -- Creates target for the pumps
		-- Someone tell Linden to allow a way to pass a variable when referencing a function in a ox_target on select so I don't have to nest a rainbow
                for b = 1, #v.pumps do 
                    Target:addSphereZone({
                        coords = v.pumps[b],
                        radius = Config.PumpTarget.Radius,
                        debug = Config.Debug,
                        options = {{
                            name = 'Pump',
                            icon = 'fas fa-gas-pump',
                            distance = Config.PumpTarget.Distance,
                            label = 'Fuel Pump',
                            onSelect = function()
                                lib.registerContext({
                                    id = 'pump_menu',
                                    title = station..' Gas Pump',
                                    options = {
                                        {
                                            title = 'Price',
                                            description = '$'..GlobalState[station].price..' / per gallon',
                                            icon = "fa-dollar-sign",
                                        },
                                        {
                                            title = 'Fuel Vehicle',
                                            icon = "fa-gas-pump",
                                            onSelect = function()
                                                local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4, false)
                                                if not vehicle then return lib.notify({description = 'No Vehicles nearby', type = 'error'}) end 
                                                local state = Entity(vehicle).state
                                                local fuel  = state.fuel or GetVehicleFuelLevel(vehicle)
                                                local price, money = 0
                                                local duration = math.ceil((100 - fuel) / Config.Refill.RefillValue) * Config.Refill.RefillTick

                                                if 100 - fuel < Config.Refill.RefillValue then 
                                                    return lib.notify({description = 'The fuel tank is full', type = 'error'})
                                                end 

                                                if 100 - fuel > GlobalState[station].gas then 
                                                    return lib.notify({description = 'There isn\'t enough fuel in the station', type = 'error'})
                                                end

                                                money = getMoney()

                                                if GlobalState[station].price > money then 
                                                    return lib.notify({description = 'You don\'t have enough money', type = 'error'})
                                                end 

                                                isFueling = true

                                                TaskTurnPedToFaceEntity(cache.ped, vehicle, duration)
                                                Wait(500)

                                                CreateThread(function()
                                                    lib.progressCircle({
                                                        duration = duration,
                                                        label = 'Fueling Car',
                                                        position = 'bottom',
                                                        useWhileDead = false,
                                                        canCancel = true,
                                                        disable = {
                                                            move = true,
                                                            car = true,
                                                            combat = true,
                                                        },
                                                        anim = {
                                                            dict = 'timetable@gardener@filling_can',
                                                            clip = 'gar_ig_5_filling_can',
                                                        }
                                                    })

                                                    isFueling = false
                                                end)

                                                while isFueling do 
                                                    price += GlobalState[station].price

                                                    if price + GlobalState[station].price >= money then 
                                                        lib.cancelProgress()
                                                    end

                                                    fuel += Config.Refill.RefillValue

                                                    if fuel >= 100 then 
                                                        isFueling = false
                                                        fuel = 100.0
                                                    end 

                                                    Wait(Config.Refill.RefillTick)
                                                end 

                                                ClearPedTasks(cache.ped)

                                                TriggerServerEvent('dom_fuel:pay', price, fuel, NetworkGetNetworkIdFromEntity(vehicle), station)

                                            
                                                
                                            end 
                                        },
                                        {
                                            title = 'Buy GasCan',
                                            icon = "fa-oil-can",
                                            onSelect = function()
                                                local fuel  = 30
                                                local price, money = 0
                                                local duration = math.ceil((100 - fuel) / Config.Refill.RefillValue) * Config.Refill.RefillTick

                                                if 100 - fuel < Config.Refill.RefillValue then 
                                                    return lib.notify({description = 'The fuel tank is full', type = 'error'})
                                                end 

                                                if 100 - fuel > GlobalState[station].gas then 
                                                    return lib.notify({description = 'There isn\'t enough fuel in the station', type = 'error'})
                                                end

                                                money = getMoney()

                                                if GlobalState[station].price > money then 
                                                    return lib.notify({description = 'You don\'t have enough money', type = 'error'})
                                                end 

                                                isFueling = true

                                                
                                                Wait(500)

                                                CreateThread(function()
                                                    lib.progressCircle({
                                                        duration = duration,
                                                        label = 'Fueling Can',
                                                        position = 'bottom',
                                                        useWhileDead = false,
                                                        canCancel = true,
                                                        disable = {
                                                            move = true,
                                                            car = true,
                                                            combat = true,
                                                        },
                                                        anim = {
                                                            dict = 'timetable@gardener@filling_can',
                                                            clip = 'gar_ig_5_filling_can',
                                                        }
                                                    })

                                                    isFueling = false
                                                end)

                                                while isFueling do 
                                                    price += GlobalState[station].price

                                                    if price + GlobalState[station].price >= money then 
                                                        lib.cancelProgress()
                                                    end

                                                    fuel += Config.Refill.RefillValue

                                                    if fuel >= 100 then 
                                                        isFueling = false
                                                        fuel = 100.0
                                                    end 

                                                    Wait(Config.Refill.RefillTick)
                                                end 

                                                ClearPedTasks(cache.ped)
                                                if GetSelectedPedWeapon(cache.ped) == `WEAPON_PETROLCAN` then 
                                                    print("REFILL")
                                                    TriggerServerEvent('dom_fuel:pay', price, fuel, "refill", station)
                                                else 
                                                    price = price + 1000
                                                    TriggerServerEvent('dom_fuel:pay', price, fuel, "gascan", station)
                                                end
                                                
                                            end 
                                        },
                                        
                                    }
                                })
                                lib.showContext('pump_menu')
                            end 
                        }}
                    })
                end
            end 
        end 
    end
end)



function getMoney()
    local count = Inventory:Search('count', 'money')
    return count
end 

-- Admin drop down menu
RegisterNetEvent('dom_fuel:admingasstationmenu', function()
    local stations = {}
    for i, station in ipairs(Data.Stations) do
        table.insert(stations, { value = station.name, label = value })
    end
    local input = Input('Select a Gas Station', {
        {
            type = 'select',
            options = stations
        }
    })

    if not input then return else 
        TriggerServerEvent('dom_fuel:AdminGrabStationInfo', input)
    end 
end)

function CanDoFuelOrder(fuel, cost, duration, station, dropoff)
    if ((GlobalState[station].gas + fuel) <  Config.FuelOrder.MaxFuel) then 
        if GotFuelJob == false then 
            lib.callback('dom_fuel:FuelOrderPay', false , function(success)
                local success1 = success
                if success1 == true then 
                    GotFuelJob = true
                    FuelOrderStart(fuel, cost, duration, dropoff, station)
                    lib.notify({description = 'Go pickup the truck', type = 'inform'})
                else 
                    lib.notify({description = 'You don\'t have enough money', type = 'error'})
                end 
            end, cost)
        else 
            lib.notify({description = 'You already have a job to do', type = 'error'})
        end 
    else 
        lib.notify({description = 'You can\'t hold anymore fuel', type = 'error'})
    end 
end 

-- Owner Gas Station Menu
RegisterNetEvent('dom_fuel:OpenGasStationMenu', function(station)
    local GasFormated = comma_value_format(GlobalState[station].gas)
    local MoneyFormated = comma_value_format(GlobalState[station].money)
    local dropoff
    for k, v in pairs(Data.Stations) do 
        if v.name == station then 
            dropoff = v.coords
        end 
    end 

    lib.registerContext({
        id = 'OrderFuel',
        title = station..' Fuel Order',
        options = {
            {
                title = 'Small Order',
                metadata = {
                    {label = 'Cost', value = '$'..comma_value_format(Config.FuelOrder.Small.cost)},
                    {label = 'Fuel', value = comma_value_format(Config.FuelOrder.Small.fuel)}
                },
                icon = "fa-truck-field",
                onSelect = function()
                    local fuel = Config.FuelOrder.Small.fuel
                    local cost = Config.FuelOrder.Small.cost
                    local duration = Config.FuelOrder.Small.duration
                    CanDoFuelOrder(fuel, cost, duration, station, dropoff)
                end 
            },
            {
                title = 'Medium Order',
                icon = "fa-truck",
                metadata = {
                    {label = 'Cost', value = '$'..comma_value_format(Config.FuelOrder.Medium.cost)},
                    {label = 'Fuel', value = comma_value_format(Config.FuelOrder.Medium.fuel)}
                },
                onSelect = function()
                    local fuel = Config.FuelOrder.Medium.fuel
                    local cost = Config.FuelOrder.Medium.cost
                    local duration = Config.FuelOrder.Medium.duration
                    CanDoFuelOrder(fuel, cost, duration, station, dropoff)
                end 
            },
            {
                title = 'Large Order',
                icon = "fa-truck-moving",
                metadata = {
                    {label = 'Cost', value = '$'..comma_value_format(Config.FuelOrder.Large.cost)},
                    {label = 'Fuel', value = comma_value_format(Config.FuelOrder.Large.fuel)}
                },
                onSelect = function()
                    local fuel = Config.FuelOrder.Large.fuel
                    local cost = Config.FuelOrder.Large.cost
                    local duration = Config.FuelOrder.Large.duration
                    CanDoFuelOrder(fuel, cost, duration, station, dropoff)
                end 
            },
        }
    })

    lib.registerContext({
        id = 'GasStationMenu',
        title = "⛽ "..station..' Gas Station',
        options = {
            {
                title = 'Money',
                description = MoneyFormated,
                icon = "fa-sack-dollar",
                onSelect = function()
                    local input = Input('Withdraw from '..station, {
                        {type = 'number', icon = 'fa-solid fa-dollar-sign'}
                    })
                    if not input then return else 
                        TriggerServerEvent('dom_fuel:WithdrawCash', input, station)
                    end 
                end 
            },
            {
                title = 'Gas',
                description = GasFormated..' / 100,000',
                progress = ((GlobalState[station].gas/Config.FuelOrder.MaxFuel)*100),
                icon = "fa-gas-pump",
                colorScheme = 'orange'
            },
            {
                title = 'Price',
                description = '$'..GlobalState[station].price..' / per gallon',
                icon = "fa-dollar-sign",
                onSelect = function()
                    local input = Input('Set the price of '..station, {
                        {type = 'slider', icon = 'fa-solid fa-dollar-sign',required = true, min = 0 , max = 20 ,step = 0.10}
                    })
                    if not input then return else 
                        TriggerServerEvent('dom_fuel:UpdatePrice', input, station)
                    end 
                end 
            },
            {
                title = 'Order Fuel',
                description = 'Order more fuel for your gas station',
                icon = "fa-cart-shopping",
                menu = 'OrderFuel'
            }
        }
    })
    lib.showContext('GasStationMenu')
end)

-- Admins gas station info menu
RegisterNetEvent('dom_fuel:AdminOpenGasStationMenu', function(result)
    if result.Owner == nil then 
        result.Owner = 'Gas station not owned'
    end 

    local MoneyFormated = comma_value_format(result.Money)


    local GasFormated = comma_value_format(result.Gas)

    lib.registerContext({
        id = 'AdminGasStationMenu',
        title = result.GasStation.." Gas Station",
        options = {
            {
                title = 'Ownership',
                description = result.Owner,
                icon = "fa-person",
                onSelect = function()
                    local input = Input('Set an owner of '..result.GasStation, {
                        {type = 'number', label = 'Enter a Server ID', icon = 'hashtag'}
                    })
                    if not input then return else 
                        TriggerServerEvent('dom_fuel:UpdateOwner', input, result)
                    end 
                end 
            },
            {
                title = 'Money',
                description = MoneyFormated,
                icon = "fa-sack-dollar"
            },
            {
                title = 'Gas',
                description = GasFormated..' / 100,000',
                icon = "fa-gas-pump",
                progress = ((result.Gas/Config.FuelOrder.MaxFuel)*100),
                colorScheme = 'orange'
            },
            {
                title = 'Price',
                description = '$'..result.Price..' / per gallon',
                icon = "fa-dollar-sign"
            }
        }
    })
    lib.showContext('AdminGasStationMenu')
end)

-- Zone for fuel order NPC
function FuelOrderStart(fuel, cost, duration, dropoff, station)
    if inJob == true then 
        lib.notify({description = 'You already have a job', type = 'error'})
    else 
        if station == "3008" or station == "4023" or station == "3051" then 
            corrdsnpc = Config.FuelOrderSandy.NPCLocation
            corrdsheading = Config.FuelOrderSandy.NPCHeading
        else 
            corrdsnpc = Config.FuelOrder.NPCLocation
            corrdsheading = Config.FuelOrder.NPCHeading
        end
        targetBlip = AddBlipForCoord(corrdsnpc)
                SetBlipColour(targetBlip, 3)
                SetBlipHiddenOnLegend(targetBlip, true)
                SetBlipRoute(targetBlip, true)
                SetBlipDisplay(targetBlip, 8)
                SetBlipRouteColour(targetBlip, 3)
        local function FuelOrderBoxOnEnter()
            local model = Config.FuelOrder.NPCModel
            GetModel(model)
            FuelOrderNPC = CreatePed(1, GetHashKey(model), corrdsnpc, corrdsheading, true, true)
            FreezeEntityPosition(FuelOrderNPC, true)
            SetEntityInvincible(FuelOrderNPC, true)
            SetBlockingOfNonTemporaryEvents(FuelOrderNPC, true)
            SetModelAsNoLongerNeeded(GetHashKey(model))
            targetBlipreturn = AddBlipForCoord(corrdsnpc)
                SetBlipColour(targetBlip, 3)
                SetBlipHiddenOnLegend(targetBlip, true)
                SetBlipRoute(targetBlip, true)
                SetBlipDisplay(targetBlip, 8)
                SetBlipRouteColour(targetBlip, 3)

            if TrailerFuel == false then 
                local FuelTrailerDropOffOptions = {{
                    name = 'FuelTruckDropOff:option1',
                    icon = 'fa-solid fa-truck-droplet',
                    label = 'Return Truck',
                    onSelect = function()
                        DeleteEntity(FuelTruck)
                        DeleteEntity(FuelTrailer)
                        DeleteEntity(FuelOrderNPC)
                        RemoveBlip(targetBlipreturn)
                        FuelOrderBoxZone:remove()
                        inJob = false
                        GotFuelJob = false
                        lib.notify({description = 'You have completed the order', type = 'success'})
                    end 
                }}
                Target:addLocalEntity(FuelTrailer, FuelTrailerDropOffOptions)
            end 

            local FuelOrderNPCOptions = {{
                name = 'FuelOrderNPC:option1',
                icon = 'fa-solid fa-truck-droplet',
                label = 'Take out fuel truck',
                onSelect = function()
                    if inJob == false then 
                        inJob = true
                        TrailerFuel = true

                        model = Config.FuelOrder.FuelTruck
                        GetModel(model)
                        if station == "3008" or station == "4023" or station == "3051" then 
                            corrdstruck = Config.FuelOrderSandy.FuelTruckLocation
                            coordstrail = Config.FuelOrderSandy.FuelTrailerLocation
                        else 
                            corrdstruck = Config.FuelOrder.FuelTruckLocation
                            coordstrail = Config.FuelOrder.FuelTrailerLocation
                        end
                        RemoveBlip(targetBlip)
                        Fuelbunk = AddBlipForCoord(dropoff)
                        SetBlipColour(targetBlip, 3)
                        SetBlipHiddenOnLegend(targetBlip, true)
                        SetBlipRoute(targetBlip, true)
                        SetBlipDisplay(targetBlip, 8)
                        SetBlipRouteColour(targetBlip, 3)
                        FuelTruck = CreateVehicle(GetHashKey(model), corrdstruck, true, false)
                        model = Config.FuelOrder.FuelTrailer
                        GetModel(model)
                        FuelTrailer = CreateVehicle(GetHashKey(model), coordstrail, true, false)
                        AttachVehicleToTrailer(FuelTruck, FuelTrailer, 1.1)

                        lib.notify({description = 'Take the truck to your gas station', type = 'inform'})

                        local function FuelOrderDropOffBoxOnEnter()
                            local FuelTrailerOptions = {{
                                name = 'FuelTrailer:option1',
                                icon = 'fa-solid fa-droplet',
                                label = 'Deliver Fuel',
                                onSelect = function()
                                        Target:disableTargeting(true)
                                        if lib.progressCircle({
                                            duration = duration,
                                            label = 'Unloading Fuel',
                                            position = 'bottom',
                                            useWhileDead = false,
                                            canCancel = false,
                                            disable = {move = true, combat = true},
                                            anim = {
                                                dict = 'timetable@gardener@filling_can',
                                                clip = 'gar_ig_5_filling_can',
                                            },
                                            prop = {},
                                        }) then 
                                            TrailerFuel = false
                                            Target:removeLocalEntity(FuelTrailer, FuelTrailerOptions)
                                            Target:disableTargeting(false)
                                            FuelOrderDropOffBoxZone:remove()
                                            RemoveBlip(Fuelbunk)
                                            TriggerServerEvent('dom_fuel:UpdateFuel', fuel, station)
                                            lib.notify({description = 'Return the truck', type = 'inform'})

                                        else 
                                            print('Failed Progress Bar')
                                        end 
                                end 
                            }}

                            Target:addLocalEntity(FuelTrailer, FuelTrailerOptions)
                        end 

                        FuelOrderDropOffBoxZone = Zone.box({
                            coords = dropoff,
                            size = Config.FuelOrder.DropOffSize,
                            debug = Config.Debug,
                            onEnter = FuelOrderDropOffBoxOnEnter
                        })
                    else 
                        lib.notify({description = 'You already took out a truck', type = 'error'})
                    end 
                end
            }}
            Target:addLocalEntity(FuelOrderNPC, FuelOrderNPCOptions)
        end 

        local function FuelOrderBoxOnExit()
            DeleteEntity(FuelOrderNPC)
        end 
        if station == "3008" or station == "4023" or station == "3051" then 
            corrds = Config.FuelOrderSandy.NPCLocation
        else 
            corrds = Config.FuelOrder.NPCLocation
        end
        FuelOrderBoxZone = Zone.box({
            coords = corrds,
            size = Config.FuelOrder.NPCZoneSize,
            rotation = Config.FuelOrder.NPCZoneRotation,
            debug = Config.Debug,
            onEnter = FuelOrderBoxOnEnter,
            onExit = FuelOrderBoxOnExit
        })
    end 
end 

local function setFuel(state, vehicle, fuel, replicate)
	if DoesEntityExist(vehicle) then
		SetVehicleFuelLevel(vehicle, fuel)

		if not state.fuel then
			TriggerServerEvent('dom_fuel:createStatebag', NetworkGetNetworkIdFromEntity(vehicle), fuel)
		else
			state:set('fuel', fuel, replicate)
		end
	end
end

lib.onCache('seat', function(seat)
	if cache.vehicle then
		lastVehicle = cache.vehicle
	end

	if not NetworkGetEntityIsNetworked(lastVehicle) then return end

	if seat == -1 then
		SetTimeout(0, function()
			local vehicle = cache.vehicle
			local multiplier = Config.FuelUsage.classUsage[GetVehicleClass(vehicle)] or 1.0

			-- Vehicle doesn't use fuel
			if multiplier == 0.0 then return end

			local state = Entity(vehicle).state

			if not state.fuel then
				TriggerServerEvent('dom_fuel:createStatebag', NetworkGetNetworkIdFromEntity(vehicle), GetVehicleFuelLevel(vehicle))
				while not state.fuel do Wait(0) end
			end

			SetVehicleFuelLevel(vehicle, state.fuel)

			local fuelTick = 0

			while cache.seat == -1 do
				if GetIsVehicleEngineRunning(vehicle) then
					local usage = Config.FuelUsage.rpmUsage[math.floor(GetVehicleCurrentRpm(vehicle) * 10) / 10]
					local fuel = state.fuel
					local newFuel = fuel - usage * multiplier

					if newFuel < 0 or newFuel > 100 then
						newFuel = fuel
					end

					if fuel ~= newFuel then
						if fuelTick == 15 then
							fuelTick = 0
						end

						setFuel(state, vehicle, newFuel, fuelTick == 0)
						fuelTick += 1
					end
				end

				Wait(1000)
			end

			setFuel(state, vehicle, state.fuel, true)
		end)
	end
end)
