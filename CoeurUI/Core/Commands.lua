-- Commande /cui.
local _, CUI = ...
local L = CUI.L

local STATES = {
    actif = L.ETAT_ACTIF,
    coupe = L.ETAT_COUPE,
    reload = L.ETAT_RELOAD,
    erreur = L.ETAT_ERREUR,
}

local function showHelp()
    CUI:Print(L.AIDE_TITRE)
    for _, line in ipairs(L.AIDE) do
        _G.DEFAULT_CHAT_FRAME:AddMessage("   " .. line)
    end
end

local function listModules()
    local list = CUI:GetModules()
    if #list == 0 then
        CUI:Print(L.MODULES_AUCUN)
        return
    end
    CUI:Print(L.MODULES_TITRE)
    for _, m in ipairs(list) do
        _G.DEFAULT_CHAT_FRAME:AddMessage("   " .. L.MODULE_LIGNE:format(m.name, m.key:lower(), STATES[CUI:ModuleState(m)]))
    end
end

local function toggle(command, arg, wanted)
    if arg == "" then
        CUI:Print(L.MODULE_MANQUANT:format(command))
        return
    end
    local m = CUI:FindModule(arg)
    if not m then
        CUI:Print(L.MODULE_INCONNU:format(arg))
        return
    end
    if wanted and m.enabled and not m.pendingReload then
        CUI:Print(L.MODULE_DEJA_ACTIF:format(m.name))
        return
    end
    if not wanted and not m:IsWanted() then
        CUI:Print(L.MODULE_DEJA_COUPE:format(m.name))
        return
    end
    if not CUI:SetModuleEnabled(m, wanted) then
        CUI:Print(L.EN_COMBAT)
        return
    end
    if wanted then
        CUI:Print(L.MODULE_ACTIVE:format(m.name))
    elseif m.pendingReload then
        CUI:Print(L.MODULE_RELOAD:format(m.name))
    else
        CUI:Print(L.MODULE_COUPE:format(m.name))
    end
end

local function reset(arg)
    if arg:lower() ~= "oui" then
        CUI:Print(L.RESET_CONFIRMER)
        return
    end
    CUI:StopAllModules()
    CUI:WipeSettings()
    CUI:Print(L.RESET_FAIT)
end

_G.SLASH_COEURUI1 = "/cui"
_G.SlashCmdList.COEURUI = function(msg)
    local command, arg = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = command:lower()

    if CUI.resetPending and command ~= "aide" and command ~= "version" then
        CUI:Print(L.RESET_ATTENTE)
        return
    end

    if command == "" then
        CUI:ToggleModulesScreen()
    elseif command == "aide" then
        showHelp()
    elseif command == "version" then
        CUI:Print(L.VERSION:format(CUI.version))
    elseif command == "modules" then
        listModules()
    elseif command == "activer" then
        toggle(command, arg, true)
    elseif command == "couper" then
        toggle(command, arg, false)
    elseif command == "reset" then
        reset(arg)
    else
        CUI:Print(L.COMMANDE_INCONNUE:format(command))
        showHelp()
    end
end
