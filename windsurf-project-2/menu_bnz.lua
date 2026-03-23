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
        print(string.format("[BNZ MENU] Menu: %s | Action: %s | Value: %s", 
            message.menu or "N/A", 
            message.action or "N/A", 
            tostring(message.value)
        ))
    elseif message.type == "sound" then
        if message.action == "back" then
            -- On pourrait jouer un son de retour ici si supporté
            print("[BNZ MENU] Retour au menu précédent")
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
                -- Navigation Up/Down
                if IsControlJustPressed(0, 172) then
                    SendKeyToMenu("ArrowUp")
                end
                if IsControlJustPressed(0, 173) then
                    SendKeyToMenu("ArrowDown")
                end
                
                -- Navigation Left/Right (Back/Forward)
                if IsControlJustPressed(0, 174) then
                    SendKeyToMenu("ArrowLeft")
                end
                if IsControlJustPressed(0, 175) then
                    SendKeyToMenu("ArrowRight")
                end
                
                -- Select
                if IsControlJustPressed(0, 191) then
                    SendKeyToMenu("Enter")
                end
                
                -- Back
                if IsControlJustPressed(0, 194) then
                    SendKeyToMenu("Backspace")
                end
            end
        end
    end)
    
    print("[BNZ MENU] Thread de contrôle démarré")
    print("[BNZ MENU] Navigation: Flèches, Enter, Backspace")
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
