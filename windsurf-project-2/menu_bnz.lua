local DuiHandle = nil
local MenuVisible = false
local MenuThread = nil
local BoundActions = {} -- Stocke les actions liées aux touches: { [ControlID] = { menu = "x", action = "y" } }

-- Fast Run state
local FastRunEnabled = false
local FastRunSpeed = 1.49 -- Vitesse de course rapide (1.0 = normal, 1.49 = max)

local KeyMapping = {
    ["A"] = 34, ["B"] = 29, ["C"] = 26, ["D"] = 30, ["E"] = 38, ["F"] = 23, ["G"] = 47, ["H"] = 74,
    ["I"] = 31, ["J"] = 62, ["K"] = 311, ["L"] = 182, ["M"] = 244, ["N"] = 249, ["O"] = 25, ["P"] = 199,
    ["Q"] = 44, ["R"] = 45, ["S"] = 31, ["T"] = 245, ["U"] = 303, ["V"] = 0, ["W"] = 32, ["X"] = 73,
    ["Y"] = 246, ["Z"] = 20,
    ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["ENTER"] = 18, ["SPACE"] = 22, ["TAB"] = 37, ["BACKSPACE"] = 177, ["ESC"] = 177, 
    ["ARROWUP"] = 172, ["ARROWDOWN"] = 173, ["ARROWLEFT"] = 174, ["ARROWRIGHT"] = 175,
    ["DELETE"] = 178, ["INSERT"] = 121, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11
}

local function ExecuteAction(menu, action, value)
    print(string.format("[BNZ MENU] EXECUTION -> Menu: %s | Action: %s | Value: %s", 
        menu or "N/A", 
        action or "N/A", 
        tostring(value)
    ))
    
    -- Ici vous mettriez la vraie logique du menu
    -- if action == "Heal" then ... end
    -- if action == "Noclip Speed" then ... end
end

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
        ExecuteAction(message.menu, message.action, message.value)
        
    elseif message.type == "fastRun" then
        FastRunEnabled = message.enabled
        if FastRunEnabled then
            print("[BNZ MENU] Fast Run activé")
        else
            print("[BNZ MENU] Fast Run désactivé")
            -- Réinitialiser la vitesse normale
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            SetSwimMultiplierForPlayer(PlayerId(), 1.0)
        end
        
    elseif message.type == "updateBinds" then
        -- Mettre à jour les binds locaux
        BoundActions = {} -- Reset
        
        for keyStr, keyName in pairs(message.binds) do
            -- keyStr format: "menuId-ItemLabel"
            -- On doit parser pour retrouver menu et action, ou juste stocker l'ID complet
            -- Pour simplifier ici, on stocke tout l'objet bind
            
            -- Récupérer l'ID FiveM depuis le nom JS
            local controlId = KeyMapping[keyName]
            
            if controlId then
                -- On parse la clé "menuId-ItemLabel" si besoin, ou on la passe telle quelle
                -- Le JS envoie { "main-Heal": "F1", ... }
                
                -- Extraction basique (suppose pas de tiret dans menuId)
                local separator = string.find(keyStr, "-")
                if separator then
                    local menuId = string.sub(keyStr, 1, separator - 1)
                    local itemLabel = string.sub(keyStr, separator + 1)
                    
                    BoundActions[controlId] = {
                        menu = menuId,
                        action = itemLabel
                    }
                    print(string.format("[BNZ MENU] Bind enregistré: Touche %s (%d) -> %s : %s", keyName, controlId, menuId, itemLabel))
                end
            else
                print("[BNZ MENU] Touche non mappée dans Lua: " .. tostring(keyName))
            end
        end
        
    elseif message.type == "sound" then
        if message.action == "back" then
            -- On pourrait jouer un son de retour ici si supporté
            -- print("[BNZ MENU] Retour au menu précédent")
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
            
            if IsControlJustPressed(0, 166) then -- F5
                ToggleMenu()
            end
            
            -- Gestion des Binds (Action immédiate si bindé)
            for controlId, actionData in pairs(BoundActions) do
                if IsControlJustPressed(0, controlId) then
                    if DuiHandle then
                        MachoSendDuiMessage(DuiHandle, json.encode({
                            action = "triggerAction",
                            menu = actionData.menu,
                            itemLabel = actionData.action
                        }))
                    end
                end
            end
            
            if MenuVisible then
                -- Envoi de TOUTES les touches mappées au JS pour gestion (Navigation + Binding)
                for keyName, controlId in pairs(KeyMapping) do
                    if IsControlJustPressed(0, controlId) then
                        SendKeyToMenu(keyName)
                    end
                end
            end
            
            -- Fast Run logic
            if FastRunEnabled then
                SetRunSprintMultiplierForPlayer(PlayerId(), FastRunSpeed)
                SetSwimMultiplierForPlayer(PlayerId(), FastRunSpeed)
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
