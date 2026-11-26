-- Registre des modules : déclaration, activation, désactivation.
--
-- Un module se déclare ainsi :
--   local M = CoeurUI:RegisterModule({
--       key = "Exemple", name = "Exemple", description = "...",
--       defaultEnabled = false, needsReload = false,
--       defaults = { ... },      -- réglages du compte  » M.db
--       charDefaults = { ... },  -- réglages du perso   » M.charDb
--   })
--   function M:OnEnable() end
--   function M:OnDisable() end
--
-- Réglages affichés dans la fenêtre principale, facultatif. Soit une seule page :
--       settings = {
--           { type = "section", text = "AFFICHAGE" },
--           { type = "toggle", key = "x", label = "...", description = "..." },
--           { type = "slider", key = "y", label = "...", min = 1, max = 10, step = 1, format = "%d s" },
--           { type = "dropdown", key = "z", label = "...", options = { { value = "a", text = "..." } } },
--       },
--   Chaque key est lue dans M.db (ou M.charDb avec char = true) ; sa valeur par défaut vient de
--   defaults (ou charDefaults).
-- Soit des sous-modules (un tiroir dans la fenêtre, une page chacun) :
--       subs = {
--           { key = "joueur", name = "Joueur", description = "...", settings = { ... } },
--       },
--   Les réglages d'un sous-module sont rangés dans M.db[sous.key] (défauts : defaults[sous.key]).
-- Un changement s'applique tout de suite :
--   function M:OnSettingChanged(key, value, subKey) end  -- seulement quand le module est actif
--
-- Tant qu'il n'est pas activé, un module ne fait rien. Ses évènements (M:On), minuteries
-- (M:After, M:Every) et réglages du jeu (M:SetCVar) sont retirés ou rendus automatiquement
-- quand on le coupe.
local _, CUI = ...
local L = CUI.L

local modules = {} -- clé -> module
local order = {}   -- modules dans l'ordre de déclaration

local Module = {}
Module.__index = Module

function CUI:RegisterModule(def)
    assert(type(def) == "table" and type(def.key) == "string", "RegisterModule : clé manquante")
    assert(not modules[def.key], "RegisterModule : module déjà déclaré : " .. def.key)
    local m = setmetatable({
        key = def.key,
        name = def.name or def.key,
        description = def.description or "",
        defaultEnabled = def.defaultEnabled and true or false,
        needsReload = def.needsReload and true or false,
        defaults = def.defaults or {},
        charDefaults = def.charDefaults or {},
        settings = def.settings,
        subs = def.subs,
        enabled = false,       -- en marche en ce moment
        pendingReload = false, -- coupé, mais encore en marche jusqu'au prochain /reload
        failed = false,        -- erreur au dernier démarrage
    }, Module)
    modules[def.key] = m
    order[#order + 1] = m
    return m
end

function CUI:GetModule(key)
    return modules[key]
end

-- Recherche sans tenir compte des majuscules (pour la commande /cui).
function CUI:FindModule(text)
    text = text:lower()
    for _, m in ipairs(order) do
        if m.key:lower() == text or m.name:lower() == text then
            return m
        end
    end
end

-- Liste des modules, dans l'ordre de déclaration. Ne pas modifier.
function CUI:GetModules()
    return order
end

-- Sauvegarde ------------------------------------------------------------------------------

local function attachSettings(m)
    local all = CUI.db.modules
    local entry = all[m.key]
    if type(entry) ~= "table" then
        entry = {}
        all[m.key] = entry
    end
    if entry.enabled == nil then
        entry.enabled = m.defaultEnabled
    end
    if type(entry.settings) ~= "table" then entry.settings = {} end
    if type(entry.cvars) ~= "table" then entry.cvars = {} end
    CUI.FillDefaults(entry.settings, m.defaults)

    local charAll = CUI.charDb.modules
    if type(charAll[m.key]) ~= "table" then
        charAll[m.key] = {}
    end
    CUI.FillDefaults(charAll[m.key], m.charDefaults)

    m.entry = entry
    m.db = entry.settings
    m.charDb = charAll[m.key]
end

function Module:IsWanted()
    return self.entry and self.entry.enabled or false
end

-- Outils du module (seulement quand il est actif) -----------------------------------------

function Module:On(event, fn)
    assert(self.enabled, "module coupé : " .. self.key)
    CUI:On(event, self, fn)
end

function Module:Off(event)
    CUI:Off(event, self)
end

function Module:After(sec, fn)
    assert(self.enabled, "module coupé : " .. self.key)
    return CUI:After(sec, fn, self)
end

function Module:Every(sec, fn)
    assert(self.enabled, "module coupé : " .. self.key)
    return CUI:Every(sec, fn, self)
end

-- Change un réglage du jeu. La valeur d'origine est notée dans la sauvegarde et rendue quand
-- le module est coupé, même après une déconnexion entre-temps.
function Module:SetCVar(name, value)
    value = tostring(value)
    CUI:AfterCombat(function()
        local cvars = self.entry.cvars
        if cvars[name] == nil then
            local original = _G.C_CVar.GetCVar(name)
            if original == nil then
                CUI:Print(L.CVAR_INCONNUE:format(name))
                return
            end
            cvars[name] = original
        end
        _G.C_CVar.SetCVar(name, value)
    end)
end

local function restoreCVars(m)
    local cvars = m.entry and m.entry.cvars
    if not cvars or not next(cvars) then return end
    CUI:AfterCombat(function()
        for name, original in pairs(cvars) do
            _G.C_CVar.SetCVar(name, original)
            cvars[name] = nil
        end
    end)
end

-- Marche / arrêt ---------------------------------------------------------------------------

local function cleanup(m)
    CUI:OffAll(m)
    CUI:CancelTimers(m)
    restoreCVars(m)
end

local function stop(m)
    if not m.enabled then return end
    CUI:SafeCall(m.name, m.OnDisable, m)
    cleanup(m)
    m.enabled = false
    m.pendingReload = false
end

local function start(m)
    if m.enabled then return true end
    m.enabled = true
    m.failed = false
    if not CUI:SafeCall(m.name, m.OnEnable, m) then
        -- Démarrage raté : on rend au jeu ce qui a déjà été fait.
        stop(m)
        m.failed = true
        return false
    end
    return true
end

-- Prévient l'écran « Modules » (s'il est ouvert) qu'un état a changé.
local function changed()
    if CUI.OnModulesChanged then
        CUI:SafeCall("écran Modules", CUI.OnModulesChanged, CUI)
    end
end

-- Met le module dans l'état demandé par la sauvegarde.
local function apply(m)
    if m.entry.enabled then
        m.pendingReload = false
        start(m)
    elseif m.enabled then
        if m.needsReload then
            m.pendingReload = true
        else
            stop(m)
        end
    end
    changed()
end

-- Active ou coupe un module. Renvoie false s'il a fallu attendre la fin du combat.
function CUI:SetModuleEnabled(m, wanted)
    m.entry.enabled = wanted and true or false
    return self:AfterCombat(function() apply(m) end)
end

-- "actif", "coupe", "reload" ou "erreur"
function CUI:ModuleState(m)
    if m.pendingReload then return "reload" end
    if m.enabled then return "actif" end
    if m.failed then return "erreur" end
    return "coupe"
end

-- Réglages d'un module ----------------------------------------------------------------------

-- Sous-modules déclarés (liste, éventuellement vide).
function CUI:GetModuleSubs(m)
    return type(m.subs) == "table" and m.subs or {}
end

-- Le module a-t-il une page de réglages (ou des sous-modules) ?
function CUI:HasModuleSettings(m)
    return #self:GetModuleSubs(m) > 0 or (type(m.settings) == "table" and #m.settings > 0)
end

-- Réglages d'une page : ceux du sous-module sub, ou ceux du module.
function CUI:GetPageSettings(m, sub)
    local list = sub and sub.settings or m.settings
    return type(list) == "table" and list or {}
end

-- Table où est rangé un réglage (créée si besoin), et ses valeurs par défaut.
local function storeOf(m, item, sub)
    local store = item.char and m.charDb or m.db
    local defaults = item.char and m.charDefaults or m.defaults
    if sub then
        if type(store[sub.key]) ~= "table" then
            store[sub.key] = {}
        end
        store = store[sub.key]
        defaults = type(defaults[sub.key]) == "table" and defaults[sub.key] or {}
    end
    return store, defaults
end

function CUI:GetModuleSetting(m, item, sub)
    local store = storeOf(m, item, sub)
    return store[item.key]
end

-- Change un réglage et prévient le module s'il est actif.
function CUI:SetModuleSetting(m, item, value, sub)
    local store = storeOf(m, item, sub)
    if store[item.key] == value then return end
    store[item.key] = value
    if m.enabled and m.OnSettingChanged then
        self:SafeCall(m.name, m.OnSettingChanged, m, item.key, value, sub and sub.key)
    end
end

-- Remet les réglages d'une page (module ou sous-module) à leur valeur par défaut.
function CUI:ResetModuleSettings(m, sub)
    for _, item in ipairs(self:GetPageSettings(m, sub)) do
        if item.key then
            local _, defaults = storeOf(m, item, sub)
            self:SetModuleSetting(m, item, defaults[item.key], sub)
        end
    end
end

-- Arrête tout (utilisé par /cui reset).
function CUI:StopAllModules()
    for _, m in ipairs(order) do
        stop(m)
    end
    changed()
end

-- Démarrage --------------------------------------------------------------------------------

CUI:On("ADDON_LOADED", "core:boot", function(_, name)
    if name ~= CUI.name then return end
    CUI:Off("ADDON_LOADED", "core:boot")
    CUI:LoadSettings()
    for _, m in ipairs(order) do
        attachSettings(m)
    end
end)

CUI:On("PLAYER_LOGIN", "core:boot", function()
    CUI:Off("PLAYER_LOGIN", "core:boot")
    for _, m in ipairs(order) do
        if m.entry.enabled then
            start(m)
        else
            -- Module coupé pendant qu'il avait changé un réglage du jeu (coupé avec /reload,
            -- jeu fermé...) : on rend la valeur d'origine.
            restoreCVars(m)
        end
    end
end)
