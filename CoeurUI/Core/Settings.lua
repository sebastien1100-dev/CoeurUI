-- Sauvegarde et réglages : valeurs par défaut et migration de version.
--
-- CoeurUIDB (compte) :
--   version = n°
--   modules = { [clé] = { enabled = bool, settings = {...}, cvars = { [nom] = valeur d'origine } } }
--   ui      = { positions = {...} }
--   general = { langue = "auto" | code, boutonMinicarte = bool, angleMinicarte = degrés }
-- CoeurUICharDB (personnage) :
--   version = n°
--   modules = { [clé] = {...réglages par perso...} }
local _, CUI = ...

local DB_VERSION = 2
local CHAR_VERSION = 1

-- Une fonction par passage de version, par exemple [2] = function(db) ... end pour passer de 1 à 2.
local migrations = {}
local charMigrations = {}

-- 2 (0.7.0) : le bouton de minicarte n'est plus un module mais un paramètre général.
migrations[2] = function(db)
    local old = type(db.modules) == "table" and db.modules.Minicarte
    if type(old) ~= "table" then return end
    if type(db.general) ~= "table" then db.general = {} end
    db.general.boutonMinicarte = old.enabled ~= false
    if type(old.settings) == "table" and type(old.settings.angle) == "number" then
        db.general.angleMinicarte = old.settings.angle
    end
    db.modules.Minicarte = nil
end

-- Paramètres généraux (page « Paramètres »).
local GENERAL_DEFAULTS = { langue = "auto", boutonMinicarte = true, angleMinicarte = 200 }

-- Ajoute dans target les valeurs de defaults qui manquent, sans toucher à ce qui existe.
local function fillDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            fillDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
    return target
end
CUI.FillDefaults = fillDefaults

local function migrate(db, current, steps)
    if type(db.version) ~= "number" then
        db.version = current -- nouvelle installation
        return
    end
    for v = db.version + 1, current do
        if steps[v] then
            steps[v](db)
        end
        db.version = v
    end
end

-- Appelée une fois, à l'ADDON_LOADED de CœurUI.
function CUI:LoadSettings()
    local db = type(_G.CoeurUIDB) == "table" and _G.CoeurUIDB or {}
    local char = type(_G.CoeurUICharDB) == "table" and _G.CoeurUICharDB or {}

    migrate(db, DB_VERSION, migrations)
    migrate(char, CHAR_VERSION, charMigrations)

    fillDefaults(db, { modules = {}, ui = { positions = {} }, general = GENERAL_DEFAULTS })
    fillDefaults(char, { modules = {} })

    _G.CoeurUIDB = db
    _G.CoeurUICharDB = char
    self.db = db
    self.charDb = char
    self:SetLanguage(db.general.langue)
end

-- Paramètres généraux -----------------------------------------------------------------------

function CUI:GetGeneral(key)
    return self.db.general[key]
end

-- Change un paramètre général et prévient la partie du noyau concernée.
function CUI:SetGeneral(key, value)
    if self.db.general[key] == value then return end
    self.db.general[key] = value
    if key == "boutonMinicarte" and self.UpdateMinimapButton then
        self:UpdateMinimapButton()
    end
end

function CUI:ResetGeneral()
    for key, value in pairs(GENERAL_DEFAULTS) do
        if key ~= "angleMinicarte" then -- la place du bouton n'est pas un réglage de la page
            self:SetGeneral(key, value)
        end
    end
end

-- La langue choisie diffère-t-elle de celle chargée (un /reload l'appliquera) ?
function CUI:LanguagePending()
    return self.db ~= nil and self:ResolveLanguage(self.db.general.langue) ~= self.language
end

-- Efface toute la sauvegarde. Le jeu n'écrira rien au prochain /reload : tout repart des
-- valeurs par défaut.
function CUI:WipeSettings()
    _G.CoeurUIDB = nil
    _G.CoeurUICharDB = nil
    self.resetPending = true
end
