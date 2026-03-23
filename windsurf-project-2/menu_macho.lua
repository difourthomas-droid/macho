local DuiHandle = nil
local MenuVisible = false

local function CreateMachoMenu()
    local htmlPath = "http://localhost/menu_dui.html"
    
    DuiHandle = MachoCreateDui(htmlPath)
    
    MachoHideDui(DuiHandle)
    
    print("Macho DUI Menu créé avec succès")
end

local function ShowMenu()
    if DuiHandle then
        MachoShowDui(DuiHandle)
        MenuVisible = true
        
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "show"
        }))
        
        print("Menu affiché")
    end
end

local function HideMenu()
    if DuiHandle then
        MachoHideDui(DuiHandle)
        MenuVisible = false
        
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "hide"
        }))
        
        print("Menu masqué")
    end
end

local function ToggleMenu()
    if MenuVisible then
        HideMenu()
    else
        ShowMenu()
    end
end

local function DestroyMenu()
    if DuiHandle then
        MachoDestroyDui(DuiHandle)
        DuiHandle = nil
        MenuVisible = false
        print("Menu détruit")
    end
end

local function HandleDuiMessage(data)
    local message = json.decode(data)
    
    if message.type == "close" then
        HideMenu()
        
    elseif message.type == "action" then
        print("Action reçue: " .. message.action)
        
        if message.action == "action1" then
            print("Exécution de l'action 1")
        elseif message.action == "action2" then
            print("Exécution de l'action 2")
        elseif message.action == "action3" then
            print("Exécution de l'action 3")
        end
        
    elseif message.type == "checkbox" then
        print("Checkbox " .. message.id .. " changée: " .. tostring(message.checked))
        
    elseif message.type == "slider" then
        print("Slider " .. message.id .. " mis à jour: " .. message.value .. "%")
        
    elseif message.type == "input" then
        print("Input " .. message.id .. " mis à jour: " .. message.value)
        
    elseif message.type == "dropdown" then
        print("Dropdown " .. message.id .. " sélectionné: " .. message.value)
    end
end

local function UpdateDuiValue(element, value)
    if DuiHandle then
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "updateValue",
            element = element,
            value = value
        }))
    end
end

local function ExecuteDuiScript(script)
    if DuiHandle then
        MachoExecuteDuiScript(DuiHandle, script)
    end
end

CreateMachoMenu()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if IsControlJustPressed(0, 166) then
            ToggleMenu()
        end
    end
end)

RegisterCommand("machomenu", function()
    ToggleMenu()
end, false)

RegisterCommand("destroymenu", function()
    DestroyMenu()
end, false)

RegisterCommand("recreatemenu", function()
    DestroyMenu()
    Citizen.Wait(100)
    CreateMachoMenu()
end, false)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DestroyMenu()
    end
end)
