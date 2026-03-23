local DuiHandle = nil
local MenuVisible = false
local MenuThread = nil

local function CreateKoriumMenu()
    local htmlPath = "https://difourthomas-droid.github.io/macho/windsurf-project-2/menu_korium.html"
    
    DuiHandle = MachoCreateDui(htmlPath)
    
    MachoHideDui(DuiHandle)
    
    print("[KORIUM MENU] Menu créé avec succès")
    print("[KORIUM MENU] Utilisez F5 pour ouvrir/fermer le menu")
end

local function ShowMenu()
    if DuiHandle then
        MachoShowDui(DuiHandle)
        MenuVisible = true
        
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "showUI",
            visible = true
        }))
        
        print("[KORIUM MENU] Menu affiché")
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
        
        print("[KORIUM MENU] Menu masqué")
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
        print("[KORIUM MENU] Menu détruit")
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
        print("[KORIUM MENU] Action: " .. message.action)
        
        if message.action == "gamemode" then
            print("[KORIUM MENU] Gamemode: " .. tostring(message.value))
            
        elseif message.action == "ipl" then
            print("[KORIUM MENU] Loading IPL...")
            
        elseif message.action == "chat" then
            print("[KORIUM MENU] Chat: " .. tostring(message.value))
            
        elseif message.action == "chattheme" then
            print("[KORIUM MENU] Changing chat theme...")
            
        elseif message.action == "escrow" then
            print("[KORIUM MENU] Escrow asset...")
            
        elseif message.action == "mapskater" then
            print("[KORIUM MENU] Loading map skater...")
            
        elseif message.action == "testserver" then
            print("[KORIUM MENU] Test server...")
            
        elseif message.action == "hardcap" then
            print("[KORIUM MENU] Hardcap: " .. tostring(message.value))
            
        elseif message.action == "weapondamage" then
            print("[KORIUM MENU] Weapon damage: " .. message.value)
            
        elseif message.action == "infiniteammo" then
            print("[KORIUM MENU] Infinite ammo: " .. tostring(message.value))
            
        elseif message.action == "norecoil" then
            print("[KORIUM MENU] No recoil: " .. tostring(message.value))
            
        elseif message.action == "vehiclespeed" then
            print("[KORIUM MENU] Vehicle speed: " .. message.value)
            
        elseif message.action == "vehiclegodmode" then
            print("[KORIUM MENU] Vehicle godmode: " .. tostring(message.value))
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
            end
        end
    end)
    
    print("[KORIUM MENU] Thread de contrôle démarré")
    print("[KORIUM MENU] Navigation: Flèches, Enter")
end

local function StopMenuThread()
    MenuThread = false
    print("[KORIUM MENU] Thread de contrôle arrêté")
end

CreateKoriumMenu()
StartMenuThread()

print("[KORIUM MENU] ========================================")
print("[KORIUM MENU] Menu Korium DUI chargé avec succès!")
print("[KORIUM MENU] Appuyez sur F5 pour ouvrir/fermer")
print("[KORIUM MENU] ========================================")
