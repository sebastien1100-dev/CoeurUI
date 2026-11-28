-- Module « Skin Blizzard » (demandé le 27/11/2026, roadmap 18 ; clé interne « FenetresJeu ») : les fenêtres du jeu habillées au style
-- de CœurUI (« Givre »), une à une. Une seule page, un interrupteur par fenêtre. Les pièces
-- d'habillage communes sont dans le noyau (Core/UI/Skin.lua) ; chaque fenêtre a son fichier, qui se
-- déclare ici :
--   M.windows[clé] = { setup = function() ... end }   -- appelée une fois, quand la fenêtre est activée
-- Couper une fenêtre (ou le module) demande un /reload : le jeu ne sait pas reprendre son décor seul.
local _, CUI = ...

local M = CUI:RegisterModule({
    key = "FenetresJeu",
    name = "FJ_NOM",
    description = "FJ_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = {
        fiche = true,
        grimoire = true,
        talents = true,
    },
    settings = {
        { type = "section", text = "FJ_FENETRES" },
        { type = "toggle", key = "fiche", label = "FJ_FICHE", description = "FJ_ACTIF_NOTE" },
        { type = "toggle", key = "grimoire", label = "FJ_GRIMOIRE", description = "FJ_ACTIF_NOTE" },
        { type = "toggle", key = "talents", label = "FJ_TALENTS", description = "FJ_ACTIF_NOTE" },
    },
})

M.windows = {}
local done = {}

-- Fenêtres que le jeu ne charge qu'à leur première ouverture (grimoire, talents...) : fn est appelée quand
-- l'addon du jeu est chargé (tout de suite s'il l'est déjà). Un seul écouteur pour toutes les fenêtres.
local waiting = {}
function M:WhenLoaded(addon, fn)
    local loaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded and _G.C_AddOns.IsAddOnLoaded(addon)
    if loaded then
        CUI:SafeCall(CUI:Tr("FJ_NOM"), fn)
        return
    end
    waiting[addon] = waiting[addon] or {}
    table.insert(waiting[addon], fn)
    self:On("ADDON_LOADED", function(_, name)
        local list = waiting[name]
        if not list then return end
        waiting[name] = nil
        for _, f in ipairs(list) do CUI:SafeCall(CUI:Tr("FJ_NOM"), f) end
    end)
end

local function setupAll()
    -- Ancienne sauvegarde (0.54.0 en test : une page par fenêtre, { actif = ... }) : remise à plat.
    for key in pairs(M.windows) do
        if type(M.db[key]) == "table" then M.db[key] = M.db[key].actif ~= false end
    end
    for key, w in pairs(M.windows) do
        if not done[key] and M.db[key] == true then
            done[key] = true
            CUI:SafeCall(CUI:Tr("FJ_NOM"), w.setup)
        end
    end
end

function M:OnEnable()
    setupAll()
end

-- Coupé : l'habillage reste jusqu'au /reload (needsReload).
function M:OnDisable()
end

-- Une fenêtre activée : habillée tout de suite ; coupée : au prochain /reload (signalé dans sa note).
function M:OnSettingChanged()
    setupAll()
end
