local DuiHandle = nil
local MenuVisible = false
local MenuThread = nil

local function CreateCustomMenu()
    local htmlPath = "https://difourthomas-droid.github.io/macho/windsurf-project-2/menu_custom.html"
    
    DuiHandle = MachoCreateDui(htmlPath)
    
    MachoHideDui(DuiHandle)
    
    print("[CUSTOM MENU] Menu créé avec succès")
    print("[CUSTOM MENU] Utilisez F5 pour ouvrir/fermer le menu")
end

local function ShowMenu()
    if DuiHandle then
        MachoShowDui(DuiHandle)
        MenuVisible = true
        
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "showUI",
            visible = true
        }))
        
        print("[CUSTOM MENU] Menu affiché")
    end
end

local function HideMenu()
    if DuiHandle then
        MachoHideDui(DuiHandle)
        MenuVisible = false
        
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "showUI",
            visible = false
        }))
        
        print("[CUSTOM MENU] Menu masqué")
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
        print("[CUSTOM MENU] Menu détruit")
    end
end

local function SendKeyToMenu(key)
    if DuiHandle and MenuVisible then
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "keydown",
            key = key
        }))
    end
end

local function HandleMenuAction(data)
    local message = json.decode(data)
    
    if message.type == "action" then
        print("[CUSTOM MENU] Action: " .. message.action)
        
        if message.action == "heal" then
            print("[CUSTOM MENU] Healing player...")
            
        elseif message.action == "godmode" then
            print("[CUSTOM MENU] Godmode: " .. tostring(message.value))
            
        elseif message.action == "speed" then
            print("[CUSTOM MENU] Speed set to: " .. message.value)
            
        elseif message.action == "noclip" then
            print("[CUSTOM MENU] Noclip: " .. tostring(message.value))
            
        elseif message.action == "jump" then
            print("[CUSTOM MENU] Jump height: " .. message.value)
            
        elseif message.action == "giveweapons" then
            print("[CUSTOM MENU] Giving all weapons...")
            
        elseif message.action == "infiniteammo" then
            print("[CUSTOM MENU] Infinite ammo: " .. tostring(message.value))
            
        elseif message.action == "weapontype" then
            print("[CUSTOM MENU] Weapon type: " .. message.value)
            
        elseif message.action == "spawnvehicle" then
            print("[CUSTOM MENU] Spawning vehicle...")
            
        elseif message.action == "vehiclegodmode" then
            print("[CUSTOM MENU] Vehicle godmode: " .. tostring(message.value))
            
        elseif message.action == "vehiclespeed" then
            print("[CUSTOM MENU] Vehicle speed: " .. message.value)
            
        elseif message.action == "esp" then
            print("[CUSTOM MENU] ESP: " .. tostring(message.value))
            
        elseif message.action == "crosshair" then
            print("[CUSTOM MENU] Crosshair: " .. tostring(message.value))
            
        elseif message.action == "fov" then
            print("[CUSTOM MENU] FOV: " .. message.value)
            
        elseif message.action == "theme" then
            print("[CUSTOM MENU] Theme: " .. message.value)
            
        elseif message.action == "reset" then
            print("[CUSTOM MENU] Resetting settings...")
        end
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
            
            if MenuVisible then
                if IsControlJustPressed(0, 172) then
                    SendKeyToMenu("ArrowUp")
                end
                
                if IsControlJustPressed(0, 173) then
                    SendKeyToMenu("ArrowDown")
                end
                
                if IsControlJustPressed(0, 174) then
                    SendKeyToMenu("ArrowLeft")
                end
                
                if IsControlJustPressed(0, 175) then
                    SendKeyToMenu("ArrowRight")
                end
                
                if IsControlJustPressed(0, 191) then
                    SendKeyToMenu("Enter")
                end
                
                if IsControlJustPressed(0, 194) then
                    SendKeyToMenu("Backspace")
                end
                
                if IsControlJustPressed(0, 44) then
                    SendKeyToMenu("q")
                end
                
                if IsControlJustPressed(0, 38) then
                    SendKeyToMenu("e")
                end
            end
        end
    end)
    
    print("[CUSTOM MENU] Thread de contrôle démarré")
    print("[CUSTOM MENU] Navigation: Flèches, Enter, Backspace, Q/E")
end

local function StopMenuThread()
    MenuThread = false
    print("[CUSTOM MENU] Thread de contrôle arrêté")
end

CreateCustomMenu()
StartMenuThread()

print("[CUSTOM MENU] ========================================")
print("[CUSTOM MENU] Menu Custom DUI chargé avec succès!")
print("[CUSTOM MENU] Appuyez sur F5 pour ouvrir/fermer")
print("[CUSTOM MENU] ========================================")
