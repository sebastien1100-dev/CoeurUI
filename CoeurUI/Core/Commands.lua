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
    frame = "cadre",
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

-- Inspection d'un cadre (outil pour habiller les fenêtres du jeu) : l'arbre de ses pièces (nom, type,
-- taille, texture, texte) dans la fenêtre « à copier ». Sans nom : le cadre sous la souris.
local issecret = _G.issecretvalue or function() return false end
local MAX_LINES, MAX_DEPTH = 3000, 6
-- Pièces sans intérêt pour l'habillage (manette, Azérite, châsses) : sautées, avec leurs enfants.
local SKIPPED = { "JumpHint", "TabIndicators", "AvailableTraitFrame", "RankFrame", "SocketDisplay",
                  "GearEnchantAnimation", "GamepadFocusIndicator" }
-- Comparé au dernier morceau du nom seulement (« PVPRankFrame.DetailFrame » n'est pas un « RankFrame »).
local function skipped(name)
    local last = name:match("([^%.]+)$") or name
    for _, part in ipairs(SKIPPED) do
        if last == part then return true end
    end
end

local function safe(fn, ...)
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return a, b, c, d end
end

-- Toutes les valeurs rendues (régions, enfants), dans une table ; rien si l'appel échoue.
local function all(fn, obj)
    local t = { pcall(fn, obj) }
    if not t[1] then return {} end
    table.remove(t, 1)
    return t
end

local function label(o)
    local name = safe(o.GetDebugName, o) or safe(o.GetName, o) or "?"
    if issecret(name) then name = "?" end
    return tostring(name)
end

local function describeRegion(r)
    local kind = safe(r.GetObjectType, r) or "?"
    local parts = { kind, label(r) }
    local layer, sub = safe(r.GetDrawLayer, r)
    if layer then parts[#parts + 1] = layer .. (sub and (" " .. sub) or "") end
    parts[#parts + 1] = safe(r.IsShown, r) and "visible" or "caché"
    if kind == "Texture" then
        local atlas = safe(r.GetAtlas, r)
        local tex = safe(r.GetTexture, r)
        if atlas and not issecret(atlas) then parts[#parts + 1] = "atlas=" .. tostring(atlas)
        elseif tex and not issecret(tex) then parts[#parts + 1] = "tex=" .. tostring(tex) end
    elseif kind == "FontString" then
        local text = safe(r.GetText, r)
        if text and not issecret(text) then parts[#parts + 1] = "« " .. tostring(text):sub(1, 40) .. " »" end
    end
    return table.concat(parts, " · ")
end

local function inspectFrame(root)
    local lines = {}
    local function add(depth, text)
        if #lines < MAX_LINES then lines[#lines + 1] = string.rep("  ", depth) .. text end
    end
    local function walk(f, depth)
        if safe(f.IsForbidden, f) then add(depth, label(f) .. " (interdit)") return end
        if depth > 0 and skipped(label(f)) then return end
        local w, h = safe(f.GetSize, f)
        add(depth, (safe(f.GetObjectType, f) or "?") .. " · " .. label(f) .. " · "
            .. (safe(f.IsShown, f) and "visible" or "caché")
            .. (w and (" · " .. math.floor(w) .. "x" .. math.floor(h or 0)) or "")
            .. " · niveau " .. tostring(safe(f.GetFrameLevel, f) or "?"))
        for _, r in ipairs(all(f.GetRegions, f)) do add(depth + 1, describeRegion(r)) end
        if depth < MAX_DEPTH then
            for _, child in ipairs(all(f.GetChildren, f)) do walk(child, depth + 1) end
        end
    end
    walk(root, 0)
    return table.concat(lines, "\n")
end

local function inspect(arg)
    -- « /cui cadre 5 » : le cadre sous la souris dans 5 secondes (le temps d'ouvrir un menu qui se ferme
    -- quand on tape dans la discussion).
    local delay = tonumber(arg)
    if delay then
        delay = math.max(1, math.min(30, delay))
        CUI:Print(L.CADRE_ATTENTE:format(delay))
        _G.C_Timer.After(delay, function() inspect("") end)
        return
    end
    local frame
    if arg ~= "" then
        -- Nom global, ou chemin « Cadre.Partie.SousPartie » (pièces sans nom global).
        frame = _G[arg]
        if not frame and arg:find(".", 1, true) then
            for part in arg:gmatch("[^%.]+") do
                if frame == nil then frame = _G[part] elseif type(frame) == "table" then frame = frame[part] end
                if frame == nil then break end
            end
        end
    else
        local foci = _G.GetMouseFoci and _G.GetMouseFoci()
        frame = (type(foci) == "table" and foci[1]) or (_G.GetMouseFocus and _G.GetMouseFocus())
    end
    if type(frame) ~= "table" or not frame.GetObjectType then
        CUI:Print(L.CADRE_INCONNU:format(arg))
        return
    end
    local text = inspectFrame(frame)
    -- Gardé aussi dans la sauvegarde (écrite au /reload) : trop long à coller, il se lit dans le fichier.
    if type(_G.CoeurUIDB) == "table" then _G.CoeurUIDB.inspection = text end
    CUI:ShowCopyWindow({ title = L.CADRE_TITRE, label = label(frame), multiline = true,
                         text = text, hint = L.CADRE_AIDE })
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
    elseif command == "cadre" then
        inspect(arg)
    else
        CUI:Print(L.COMMANDE_INCONNUE:format(typed))
        showHelp()
    end
end
