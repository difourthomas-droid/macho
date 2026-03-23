local DuiHandle = nil
local MenuVisible = false
local MenuThread = nil

local function CreateBnzMenu()
    -- Utilisation du nouveau menu Bnz
    local htmlPath = "https://difourthomas-droid.github.io/macho/windsurf-project-2/menu_bnz.html"
    
    DuiHandle = MachoCreateDui(htmlPath)
    
    MachoHideDui(DuiHandle)
    
    print("[BNZ MENU] Menu créé avec succès")
    print("[BNZ MENU] Utilisez F5 pour ouvrir/fermer le menu")
end

local function ShowMenu()
    if DuiHandle then
        MachoShowDui(DuiHandle)
        MenuVisible = true
        
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "showUI",
            visible = true
        }))
        
        print("[BNZ MENU] Menu affiché")
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
        
        print("[BNZ MENU] Menu masqué")
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
        print("[BNZ MENU] Menu détruit")
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
        print(string.format("[BNZ MENU] Tab: %s | Action: %s | Value: %s", 
            message.tab or "N/A", 
            message.action or "N/A", 
            tostring(message.value)
        ))
        
        -- Player List Tab
        if message.tab == "Player List" then
            if message.action == "Refresh Players" then
                print("[BNZ MENU] Refreshing player list...")
            end
            
        -- Troll Tab
        elseif message.tab == "Troll" then
            if message.action == "Rain Vehicle" then
                print("[BNZ MENU] Raining vehicles!")
            elseif message.action == "Cage Player" then
                print("[BNZ MENU] Caging player...")
            elseif message.action == "Attach Car" then
                print("[BNZ MENU] Attaching car...")
            elseif message.action == "twerk" then
                print("[BNZ MENU] Twerk animation: " .. tostring(message.value))
            elseif message.action == "baise le" then
                print("[BNZ MENU] Animation 1: " .. tostring(message.value))
            elseif message.action == "branlette" then
                print("[BNZ MENU] Animation 2: " .. tostring(message.value))
            elseif message.action == "piggyback" then
                print("[BNZ MENU] Piggyback: " .. tostring(message.value))
            end
            
        -- Vehicle Tab
        elseif message.tab == "Vehicle" then
            if message.action == "Spawn Custom" then
                print("[BNZ MENU] Spawning custom vehicle...")
            elseif message.action == "Godmode" then
                print("[BNZ MENU] Vehicle godmode: " .. tostring(message.value))
            end
            
        -- All Tab
        elseif message.tab == "all" then
            if message.action == "Kick All" then
                print("[BNZ MENU] Kicking all players...")
            end
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
    
    print("[BNZ MENU] Thread de contrôle démarré")
    print("[BNZ MENU] Navigation: Flèches, Enter")
end

local function StopMenuThread()
    MenuThread = false
    print("[BNZ MENU] Thread de contrôle arrêté")
end

CreateBnzMenu()
StartMenuThread()

print("[BNZ MENU] ========================================")
print("[BNZ MENU] Menu Bnz DUI chargé avec succès!")
print("[BNZ MENU] Appuyez sur F5 pour ouvrir/fermer")
print("[BNZ MENU] ========================================")
