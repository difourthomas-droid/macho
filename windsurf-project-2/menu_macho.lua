local DuiHandle = nil
local MenuVisible = false
local MenuThread = nil

local function CreateFodoMenu()
    local htmlPath = "https://difourthomas-droid.github.io/macho/windsurf-project-2/menu_dui.html"
    
    DuiHandle = MachoCreateDui(htmlPath)
    
    MachoHideDui(DuiHandle)
    
    print("[FODO MENU] Menu FODO créé avec succès")
    print("[FODO MENU] Utilisez F5 pour ouvrir/fermer le menu")
end

local function ShowMenu()
    if DuiHandle then
        MachoShowDui(DuiHandle)
        MenuVisible = true
        
        MachoSendDuiMessage(DuiHandle, json.encode({
            action = "showUI",
            visible = true
        }))
        
        print("[FODO MENU] Menu affiché")
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
        
        print("[FODO MENU] Menu masqué")
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
        print("[FODO MENU] Menu détruit")
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
    
    print("[FODO MENU] Thread de contrôle démarré")
end

local function StopMenuThread()
    MenuThread = false
    print("[FODO MENU] Thread de contrôle arrêté")
end

CreateFodoMenu()
StartMenuThread()

print("[FODO MENU] ========================================")
print("[FODO MENU] Menu FODO DUI chargé avec succès!")
print("[FODO MENU] Appuyez sur F5 pour ouvrir/fermer")
print("[FODO MENU] ========================================")
