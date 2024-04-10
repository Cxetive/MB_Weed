RegisterNetEvent('MF_DopePlant:SyncPlant')
RegisterNetEvent('MF_DopePlant:RemovePlant')

local MFD = MF_DopePlant



function MFD:Awake(...)
  while not ESX do Citizen.Wait(0); end
	  self:DSP(true)
      self.dS = true
      print("MF_DopePlant: Started")
	  self:Start()
end

function MFD:DoLogin(src)  
  local conString = GetConvar('mf_connection_string', 'Empty')
  local eP = GetPlayerEndpoint(source)
  if eP ~= conString or (eP == "127.0.0.1" or tostring(eP) == "127.0.0.1") then self:DSP(false); end
end

function MFD:DSP(val) self.cS = val; end
function MFD:Start(...)
  if self.dS and self.cS then self:Update(); end
end

function MFD:Update(...)
  -- while self.dS and self.cS do
  --   Citizen.Wait(0)
  -- end
end

function MFD:SyncPlant(plant,delete)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  local identifier = xPlayer.getIdentifier()
  plant["Owner"] = identifier
  if delete then 
    if xPlayer.job.label ~= self.PoliceJobLabel then
      self:RewardPlayer(source, plant)
    end
  end
  self:PlantCheck(identifier,plant,delete) 
  TriggerClientEvent('MF_DopePlant:SyncPlant',-1,plant,delete)
end

function MFD:RewardPlayer(source,plant)
  print(plant)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if not source or not plant then return; end
  if plant.Gender == "Male" then
    math.random();math.random();math.random();
    local r = math.random(1000,5000)
    if r < 3000 then
      if plant.Quality > 95 then
        xPlayer.addInventoryItem('highgradeogkushseedmale', math.floor( math.random( math.floor(plant.Quality/2), math.floor(plant.Quality*1.5))/10))
      elseif plant.Quality > 80 then
        xPlayer.addInventoryItem('highgradeogkushseedmale', math.floor( math.random( math.floor(plant.Quality/2), math.floor(plant.Quality*1.5))/20)) 
      else
        xPlayer.addInventoryItem('lowgradeogkushseedmale', math.floor( math.random( math.floor(plant.Quality/2), math.floor(plant.Quality))/20))
      end
  else
    if plant and plant.Quality and plant.Quality > 80 then
      xPlayer.addInventoryItem('trimmedweed', math.floor( math.random( math.floor(plant.Quality), math.floor(plant.Quality*2) ) ) )
    elseif plant.Quality then
      xPlayer.addInventoryItem('trimmedweed', math.floor( math.random( math.floor(plant.Quality/2), math.floor(plant.Quality) ) ) )
    end
  end
end
end

function MFD:PlantCheck(identifier, plant, delete)
  if not plant or not identifier then return; end
  local data = MySQL.Sync.fetchAll('SELECT * FROM dopeplants WHERE plantid=@plantid',{['@plantid'] = plant.PlantID})
  if not delete then
    if not data or not data[1] then  
      MySQL.Async.execute('INSERT INTO dopeplants (owner, plantid, plant) VALUES (@owner, @id, @plant)',{['@owner'] = identifier,['@id'] = plant.PlantID, ['@plant'] = json.encode(plant)})
    else
      MySQL.Sync.execute('UPDATE dopeplants SET plant=@plant WHERE plantid=@plantid',{['@plant'] = json.encode(plant),['@plantid'] = plant.PlantID})
    end
  else
    if data and data[1] then
      MySQL.Async.execute('DELETE FROM dopeplants WHERE plantid=@plantid', {['@plantid'] = plant.PlantID})
    end
  end
end

function MFD:GetLoginData(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  local data = MySQL.Sync.fetchAll('SELECT * FROM dopeplants WHERE owner=@owner',{['@owner'] = xPlayer.identifier})
  if not data or not data[1] then return false; end
  local aTab = {}
  for k = 1,#data,1 do
    local v = data[k]
    if v and v.plant then
      local data = json.decode(v.plant)
      table.insert(aTab,data)
    end
  end
  return aTab
end

function MFD:ItemTemplate()
  return {
       ["Type"] = "Water",
    ["Quality"] = 0.0,
  }
end

function MFD:PlantTemplate()
  return {
   ["Gender"] = "Female",
  ["Quality"] = 0.0,
   ["Growth"] = 0.0,
    ["Water"] = 20.0,
     ["Food"] = 20.0,
    ["Stage"] = 1,
  ["PlantID"] = math.random(math.random(999999,9999999),math.random(99999999,999999999))
  }
end

ESX.RegisterServerCallback('MF_DopePlant:GetLoginData', function(source,cb) cb(MFD:GetLoginData(source)); end)
ESX.RegisterServerCallback('MF_DopePlant:GetStartData', function(source,cb) while not MFD.dS do Citizen.Wait(0); end; cb(MFD.cS); end)
AddEventHandler('MF_DopePlant:SyncPlant', function(plant,delete) MFD:SyncPlant(plant,delete); end)
AddEventHandler('playerConnected', function(...) MFD:DoLogin(source); end)
Citizen.CreateThread(function(...) MFD:Awake(...); end)

-- Maintenance Items
ESX.RegisterUsableItem('wateringcan', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('wateringcan').count > 0 then 
    xPlayer.removeInventoryItem('wateringcan', 1)

    local template = MFD:ItemTemplate()
    template.Type = "Water"
    template.Quality = 0.1

    TriggerClientEvent('MF_DopePlant:UseItem',source,template)
  end
end)

ESX.RegisterUsableItem('purifiedwater', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('purifiedwater').count > 0 then 
    xPlayer.removeInventoryItem('purifiedwater', 1)

    local template = MFD:ItemTemplate()
    template.Type = "Water"
    template.Quality = 0.2

    TriggerClientEvent('MF_DopePlant:UseItem',source,template)
  end
end)

ESX.RegisterUsableItem('lowgradefert', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('lowgradefert').count > 0 then 
    xPlayer.removeInventoryItem('lowgradefert', 1)

    local template = MFD:ItemTemplate()
    template.Type = "Food"
    template.Quality = 0.1

    TriggerClientEvent('MF_DopePlant:UseItem',source,template)
  end
end)

ESX.RegisterUsableItem('highgradefert', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('highgradefert').count > 0 then 
    xPlayer.removeInventoryItem('highgradefert', 1)

    local template = MFD:ItemTemplate()
    template.Type = "Food"
    template.Quality = 0.2

    TriggerClientEvent('MF_DopePlant:UseItem',source,template)
  end
end)

-- og kush male
ESX.RegisterUsableItem('slechteogkushman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechteogkushman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechteogkushman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goedeogkushman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goedeogkushman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goedeogkushman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)


ESX.RegisterUsableItem('slechteogkushvrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechteogkushvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechteogkushvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goedeogkushvrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goedeogkushvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goedeogkushvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)
-- purple haze

ESX.RegisterUsableItem('slechtepurplehazeman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechteogkushman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechteogkushman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goedepurplehazehman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goedepurplehazehman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goedepurplehazehman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)


ESX.RegisterUsableItem('slechtepurplehazevrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechtepurplehazvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechtepurplehazvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goedepurplehazevrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goedepurplehazvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goedepurplehazvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

-- super7

ESX.RegisterUsableItem('slechtesuper7man', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechtesuper7man').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechtesuper7man', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goedesuper7man', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goedesuper7man').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goedesuper7man', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)


ESX.RegisterUsableItem('slechtesuper7vrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechtesuper7vrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechtesuper7vrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goedesuper7vrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goedepurplehazvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goedepurplehazvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)
-- bananakush

ESX.RegisterUsableItem('slechtebananakushman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechtebananakushman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechtebananakushman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goeiebananakushman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goeiebananakushman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goeiebananakushman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)


ESX.RegisterUsableItem('slechtebananakushvrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechtebananakushvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechtebananakushvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goedebananakushvrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goedepurplehazvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goedepurplehazvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

-- bluedream
ESX.RegisterUsableItem('slechtebluedreamman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechtebluedreamman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechtebluedreamman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goeiebluedreamman', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goeiebluedreamman').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goeiebluedreamman', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)


ESX.RegisterUsableItem('slechtebluedreamvrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('slechtebluedreamvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('slechtebluedreamvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.1
    template.Quality = math.random(1,100)/10
    template.Food =  math.random(100,200)/10
    template.Water = math.random(100,200)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)

ESX.RegisterUsableItem('goeiebluedreamvrouw', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); ESX.GetPlayerFromId(source); end
  if xPlayer.getInventoryItem('goeiebluedreamvrouw').count > 0 and xPlayer.getInventoryItem('plantpot').count > 0 then
    xPlayer.removeInventoryItem('goeiebluedreamvrouw', 1)
    xPlayer.removeInventoryItem('plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
  end
end)
