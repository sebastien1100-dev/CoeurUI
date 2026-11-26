-- Bouton « Recharger l'interface ».
--
-- ReloadUI() est bloqué pour les addons. On pose donc, par-dessus notre bouton visible, un bouton
-- protégé invisible (SecureActionButtonTemplate, macro /reload) : c'est lui qui reçoit le clic.
-- Règles du jeu respectées :
--   - le bouton protégé est créé, déplacé, montré et caché seulement hors combat ;
--   - il est posé sur UIParent par coordonnées, jamais ancré à notre fenêtre (qui peut être
--     montrée ou cachée en combat) ;
--   - en combat, il est caché (à l'entrée en combat) et le bouton visible est désactivé.
--
--   local b = CUI:CreateReloadButton(parent)  -- un seul dans tout CœurUI
local _, CUI = ...
local L = CUI.L

local secure, visual
local placed = {} -- dernière position donnée au bouton protégé

local function createSecure()
    secure = _G.CreateFrame("Button", "CoeurUIBoutonReload", _G.UIParent, "SecureActionButtonTemplate")
    secure:SetAttribute("type", "macro")
    secure:SetAttribute("macrotext", "/reload")
    -- Haut et bas : le jeu ne déclenche qu'une fois, selon le réglage « action à l'appui ».
    secure:RegisterForClicks("AnyUp", "AnyDown")
    secure:SetFrameStrata("FULLSCREEN_DIALOG")
    secure:Hide()

    -- La souris arrive sur le bouton protégé : on fait réagir le bouton visible dessous.
    secure:HookScript("OnEnter", function(self)
        visual:SetVisualState(true, false)
        CUI:ShowTooltip(self, L.INFOBULLE_BOUTON_RELOAD_TITRE, L.INFOBULLE_BOUTON_RELOAD)
    end)
    secure:HookScript("OnLeave", function(self)
        visual:SetVisualState(false, false)
        CUI:HideTooltip(self)
    end)
    secure:HookScript("OnMouseDown", function() visual:SetVisualState(true, true) end)
    secure:HookScript("OnMouseUp", function() visual:SetVisualState(true, false) end)
end

-- Met le bouton protégé exactement sur le bouton visible, ou le cache. Hors combat seulement.
local function sync()
    if _G.InCombatLockdown() then return end
    local wanted = visual and visual:IsVisible() and visual:IsEnabled()
    if not wanted then
        if secure and secure:IsShown() then
            secure:Hide()
            placed = {}
        end
        return
    end
    local left, bottom = visual:GetLeft(), visual:GetBottom()
    if not left then return end
    if not secure then createSecure() end

    local scale = visual:GetEffectiveScale() / _G.UIParent:GetEffectiveScale()
    local x, y = left * scale, bottom * scale
    local w, h = visual:GetWidth() * scale, visual:GetHeight() * scale
    if placed.x ~= x or placed.y ~= y or placed.w ~= w or placed.h ~= h then
        secure:ClearAllPoints()
        secure:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", x, y)
        secure:SetSize(w, h)
        placed = { x = x, y = y, w = w, h = h }
    end
    if not secure:IsShown() then
        secure:Show()
    end
end

function CUI:CreateReloadButton(parent)
    assert(not visual, "CreateReloadButton : un seul bouton /reload")
    visual = self:CreateButton(parent, L.RECHARGER, true)
    if self:InCombat() then
        visual:Disable()
    end

    -- Survol quand le bouton protégé n'est pas posé dessus (en combat) : on explique pourquoi.
    self:AttachTooltip(visual, function()
        if CUI:InCombat() then
            return L.INFOBULLE_BOUTON_RELOAD_TITRE, L.INFOBULLE_BOUTON_RELOAD_COMBAT
        end
        return L.INFOBULLE_BOUTON_RELOAD_TITRE, L.INFOBULLE_BOUTON_RELOAD
    end)

    -- Suit le bouton visible tant qu'il est à l'écran (fenêtre déplacée, mise en page changée).
    visual:SetScript("OnUpdate", sync)
    visual:HookScript("OnShow", sync)
    visual:HookScript("OnHide", sync)
    return visual
end

-- Entrée en combat : dernier moment où l'on peut encore cacher un bouton protégé.
CUI:On("PLAYER_REGEN_DISABLED", "core:reload", function()
    if secure then
        secure:Hide()
        placed = {}
    end
    if visual then
        visual:Disable()
    end
end)

CUI:On("PLAYER_REGEN_ENABLED", "core:reload", function()
    if visual then
        visual:Enable()
        visual:SetVisualState(false, false)
    end
    sync()
end)
