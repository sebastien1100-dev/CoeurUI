-- Sauvegarde et réglages : valeurs par défaut et migration de version.
--
-- CoeurUIDB (compte) :
--   version = n°
--   modules = { [clé] = { enabled = bool, settings = {...}, cvars = { [nom] = valeur d'origine } } }
--   ui      = { positions = {...} }
-- CoeurUICharDB (personnage) :
--   version = n°
--   modules = { [clé] = {...réglages par perso...} }
local _, CUI = ...

local DB_VERSION = 1
local CHAR_VERSION = 1

-- Une fonction par passage de version, par exemple [2] = function(db) ... end pour passer de 1 à 2.
local migrations = {}
local charMigrations = {}

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

    fillDefaults(db, { modules = {}, ui = { positions = {} } })
    fillDefaults(char, { modules = {} })

    _G.CoeurUIDB = db
    _G.CoeurUICharDB = char
    self.db = db
    self.charDb = char
end

-- Efface toute la sauvegarde. Le jeu n'écrira rien au prochain /reload : tout repart des
-- valeurs par défaut.
function CUI:WipeSettings()
    _G.CoeurUIDB = nil
    _G.CoeurUICharDB = nil
    self.resetPending = true
end
