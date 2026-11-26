-- Répartiteur d'évènements, minuteries et file d'attente « après le combat ».
-- Tout passe par un seul cadre caché. Chaque inscription a un propriétaire (un module, ou un
-- texte pour le noyau) : on peut ainsi tout retirer d'un coup quand un module est coupé.
local _, CUI = ...

local frame = _G.CreateFrame("Frame")
local handlers = {} -- évènement -> { [propriétaire] = fonction }

frame:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list then return end
    -- Copie : un appel peut ajouter ou retirer des inscriptions pendant la distribution.
    local owners, fns, n = {}, {}, 0
    for owner, fn in pairs(list) do
        n = n + 1
        owners[n], fns[n] = owner, fn
    end
    for i = 1, n do
        if list[owners[i]] == fns[i] then -- pas retiré ni remplacé entre-temps
            CUI:SafeCall(event, fns[i], event, ...)
        end
    end
end)

-- fn est appelée ainsi : fn(event, ...arguments de l'évènement)
function CUI:On(event, owner, fn)
    assert(type(event) == "string" and owner ~= nil and type(fn) == "function", "CoeurUI:On : arguments invalides")
    local list = handlers[event]
    if not list then
        list = {}
        handlers[event] = list
    end
    if not next(list) then
        frame:RegisterEvent(event)
    end
    list[owner] = fn
end

function CUI:Off(event, owner)
    local list = handlers[event]
    if not list or list[owner] == nil then return end
    list[owner] = nil
    if not next(list) then
        frame:UnregisterEvent(event)
    end
end

function CUI:OffAll(owner)
    for event, list in pairs(handlers) do
        if list[owner] ~= nil then
            self:Off(event, owner)
        end
    end
end

-- Minuteries -------------------------------------------------------------------------------

local timers = {} -- propriétaire -> { [minuterie] = true }

local function track(owner, handle)
    if owner == nil then return end
    local set = timers[owner]
    if not set then
        set = {}
        timers[owner] = set
    end
    set[handle] = true
end

-- Lance fn une fois après sec secondes.
function CUI:After(sec, fn, owner)
    local handle
    handle = _G.C_Timer.NewTimer(sec, function()
        if owner ~= nil and timers[owner] then
            timers[owner][handle] = nil
        end
        CUI:SafeCall("minuterie", fn)
    end)
    track(owner, handle)
    return handle
end

-- Lance fn toutes les sec secondes, jusqu'à :Cancel() ou CancelTimers(owner).
function CUI:Every(sec, fn, owner)
    local handle = _G.C_Timer.NewTicker(sec, function()
        CUI:SafeCall("minuterie", fn)
    end)
    track(owner, handle)
    return handle
end

function CUI:CancelTimers(owner)
    local set = timers[owner]
    if not set then return end
    for handle in pairs(set) do
        handle:Cancel()
    end
    timers[owner] = nil
end

-- Combat -----------------------------------------------------------------------------------

local combatQueue = {}

function CUI:InCombat()
    return _G.InCombatLockdown() and true or false
end

-- Lance fn tout de suite hors combat, sinon à la sortie du combat.
-- Renvoie true si fn a été lancée tout de suite.
function CUI:AfterCombat(fn)
    if not _G.InCombatLockdown() then
        self:SafeCall("après combat", fn)
        return true
    end
    combatQueue[#combatQueue + 1] = fn
    return false
end

CUI:On("PLAYER_REGEN_ENABLED", "core:combat", function()
    local queue = combatQueue
    combatQueue = {}
    for i = 1, #queue do
        CUI:SafeCall("après combat", queue[i])
    end
end)
