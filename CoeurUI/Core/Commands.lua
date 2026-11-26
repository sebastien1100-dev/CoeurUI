-- Commande /cui. Chaque sous-commande a son nom français et son nom anglais (les deux marchent,
-- quelle que soit la langue choisie).
local _, CUI = ...
local L = CUI.L

-- Textes lus au moment de l'affichage (la langue n'est connue qu'au chargement de la sauvegarde).
local STATES = {
    actif = "ETAT_ACTIF",
    coupe = "ETAT_COUPE",
    reload = "ETAT_RELOAD",
    erreur = "ETAT_ERREUR",
}

local ALIASES = {
    help = "aide",
    enable = "activer",
    disable = "couper",
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
        local state = L[STATES[CUI:ModuleState(m)]]
        _G.DEFAULT_CHAT_FRAME:AddMessage("   " .. L.MODULE_LIGNE:format(CUI:Tr(m.name), m.key:lower(), state))
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
        CUI:Print(L.MODULE_DEJA_ACTIF:format(CUI:Tr(m.name)))
        return
    end
    if not wanted and not m:IsWanted() then
        CUI:Print(L.MODULE_DEJA_COUPE:format(CUI:Tr(m.name)))
        return
    end
    if not CUI:SetModuleEnabled(m, wanted) then
        CUI:Print(L.EN_COMBAT)
        return
    end
    if wanted then
        CUI:Print(L.MODULE_ACTIVE:format(CUI:Tr(m.name)))
    elseif m.pendingReload then
        CUI:Print(L.MODULE_RELOAD:format(CUI:Tr(m.name)))
    else
        CUI:Print(L.MODULE_COUPE:format(CUI:Tr(m.name)))
    end
end

local function reset(arg)
    local answer = arg:lower()
    if answer ~= "oui" and answer ~= "yes" then
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
    local typed = command
    command = ALIASES[command] or command

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
        toggle(typed, arg, true)
    elseif command == "couper" then
        toggle(typed, arg, false)
    elseif command == "reset" then
        reset(arg)
    else
        CUI:Print(L.COMMANDE_INCONNUE:format(typed))
        showHelp()
    end
end
