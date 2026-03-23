local DuiHandle = nil
local MenuVisible = false
local MenuThread = nil

local function CreateMachoMenu()
    local htmlPath = "https://difourthomas-droid.github.io/macho/windsurf-project-2/menu_dui.html"
    
    DuiHandle = MachoCreateDui(htmlPath)
    
    MachoHideDui(DuiHandle)
    
    print("[MACHO MENU] Menu créé avec succès")
    print("[MACHO MENU] Utilisez F5 pour ouvrir/fermer le menu")
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

local function StartMenuThread()
    if MenuThread then
        return
    end
    
    MenuThread = true
    
    Citizen.CreateThread(function()
        while MenuThread do
            Citizen.Wait(0)
            
            if IsControlJustPressed(0, 166) then
                ToggleMenu()
            end
        end
    end)
    
    print("[MACHO MENU] Thread de contrôle démarré")
end

local function StopMenuThread()
    MenuThread = false
    print("[MACHO MENU] Thread de contrôle arrêté")
end

CreateMachoMenu()
StartMenuThread()

print("[MACHO MENU] ========================================")
print("[MACHO MENU] Menu Macho DUI chargé avec succès!")
print("[MACHO MENU] Appuyez sur F5 pour ouvrir/fermer")
print("[MACHO MENU] ========================================")
