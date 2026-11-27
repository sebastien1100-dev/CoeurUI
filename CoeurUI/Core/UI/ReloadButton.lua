-- Boutons « Recharger l'interface ».
--
-- ReloadUI() est bloqué pour les addons. On pose donc, par-dessus chaque bouton visible, un bouton
-- protégé invisible (SecureActionButtonTemplate, macro /reload) : c'est lui qui reçoit le clic.
-- Règles du jeu respectées :
--   - un bouton protégé est créé, déplacé, montré et caché seulement hors combat ;
--   - il est posé sur UIParent par coordonnées, jamais ancré à notre fenêtre (qui peut être
--     montrée ou cachée en combat) ;
--   - en combat, il est caché (à l'entrée en combat) et le bouton visible est désactivé.
--
--   local b = CUI:CreateReloadButton(parent)  -- bouton texte « Recharger l'interface »
--   CUI:AttachReload(bouton)                  -- tout autre bouton (une icône...) : il doit avoir
--                                             -- :SetVisualState(survol, appuyé)
--   CUI:AttachSecureClick(bouton, cible, infobulle, quand)
--                                             -- même chose pour cliquer un bouton protégé du jeu
--                                             -- (cible) ; infobulle() rend titre, texte ; quand()
--                                             -- dit si le bouton protégé doit être posé.
local _, CUI = ...
local L = CUI.L

local bindings = {} -- { visual = bouton visible, secure = bouton protégé, placed = {...} }

local function createSecure(bind)
    local secure = _G.CreateFrame("Button", "CoeurUIBoutonReload" .. bind.index, _G.UIParent,
        "SecureActionButtonTemplate")
    for k, v in pairs(bind.attrs) do
        if type(v) == "function" then v = v() end -- cible trouvée au dernier moment
        secure:SetAttribute(k, v)
    end
    -- Haut et bas : le jeu ne déclenche qu'une fois, selon le réglage « action à l'appui ».
    secure:RegisterForClicks("AnyUp", "AnyDown")
    secure:SetFrameStrata("FULLSCREEN_DIALOG")
    secure:Hide()

    -- La souris arrive sur le bouton protégé : on fait réagir le bouton visible dessous.
    local visual = bind.visual
    secure:HookScript("OnEnter", function(self)
        visual:SetVisualState(true, false)
        CUI:ShowTooltip(self, bind.tooltip())
    end)
    secure:HookScript("OnLeave", function(self)
        visual:SetVisualState(false, false)
        CUI:HideTooltip(self)
    end)
    secure:HookScript("OnMouseDown", function() visual:SetVisualState(true, true) end)
    secure:HookScript("OnMouseUp", function() visual:SetVisualState(true, false) end)
    bind.secure = secure
end

-- Met le bouton protégé exactement sur le bouton visible, ou le cache. Hors combat seulement.
local function sync(bind)
    if _G.InCombatLockdown() then return end
    local visual, secure = bind.visual, bind.secure
    local wanted = visual:IsVisible() and visual:IsEnabled() and (not bind.when or bind.when())
    if not wanted then
        if secure and secure:IsShown() then
            secure:Hide()
            bind.placed = {}
        end
        return
    end
    local left, bottom = visual:GetLeft(), visual:GetBottom()
    if not left then return end
    if not secure then
        createSecure(bind)
        secure = bind.secure
    end

    local scale = visual:GetEffectiveScale() / _G.UIParent:GetEffectiveScale()
    local x, y = left * scale, bottom * scale
    local w, h = visual:GetWidth() * scale, visual:GetHeight() * scale
    local placed = bind.placed
    if placed.x ~= x or placed.y ~= y or placed.w ~= w or placed.h ~= h then
        secure:ClearAllPoints()
        secure:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", x, y)
        secure:SetSize(w, h)
        bind.placed = { x = x, y = y, w = w, h = h }
    end
    if not secure:IsShown() then
        secure:Show()
    end
end

local function attach(visual, attrs, tooltip, when)
    local bind = { visual = visual, placed = {}, index = #bindings + 1, attrs = attrs, tooltip = tooltip,
                   when = when }
    bindings[#bindings + 1] = bind
    if CUI:InCombat() then
        visual:Disable()
    end
    -- Suit le bouton visible tant qu'il est à l'écran (fenêtre déplacée, mise en page changée).
    local function follow() sync(bind) end
    visual:SetScript("OnUpdate", follow)
    visual:HookScript("OnShow", follow)
    visual:HookScript("OnHide", follow)
    return visual
end

-- Rend un bouton visible capable de cliquer un bouton protégé du jeu (target) : acheter un
-- emplacement de banque... Hors combat seulement (en combat, le bouton visible est désactivé).
function CUI:AttachSecureClick(visual, target, tooltip, when)
    return attach(visual, { type = "click", clickbutton = target }, tooltip, when)
end

-- Rend un bouton visible capable de recharger l'interface.
function CUI:AttachReload(visual)
    local function tooltip() return L.INFOBULLE_BOUTON_RELOAD_TITRE, L.INFOBULLE_BOUTON_RELOAD end
    attach(visual, { type = "macro", macrotext = "/reload" }, tooltip)

    -- Survol quand le bouton protégé n'est pas posé dessus (en combat) : on explique pourquoi.
    self:AttachTooltip(visual, function()
        if CUI:InCombat() then
            return L.INFOBULLE_BOUTON_RELOAD_TITRE, L.INFOBULLE_BOUTON_RELOAD_COMBAT
        end
        return L.INFOBULLE_BOUTON_RELOAD_TITRE, L.INFOBULLE_BOUTON_RELOAD
    end)
    return visual
end

function CUI:CreateReloadButton(parent)
    return self:AttachReload(self:CreateButton(parent, L.RECHARGER, true))
end

-- Entrée en combat : dernier moment où l'on peut encore cacher un bouton protégé.
CUI:On("PLAYER_REGEN_DISABLED", "core:reload", function()
    for _, bind in ipairs(bindings) do
        if bind.secure then
            bind.secure:Hide()
            bind.placed = {}
        end
        bind.visual:Disable()
    end
end)

CUI:On("PLAYER_REGEN_ENABLED", "core:reload", function()
    for _, bind in ipairs(bindings) do
        bind.visual:Enable()
        bind.visual:SetVisualState(false, false)
        sync(bind)
    end
end)
