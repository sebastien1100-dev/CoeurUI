-- Fenêtres du jeu · Menu de jeu (maquette « 6 · Menu de jeu », 28/11/2026) : la fenêtre d'Échap (GameMenuFrame),
-- même liste et mêmes groupes :
--   - cadre ardoise de CœurUI sans le métal ni l'étiquette du titre ; « Menu de jeu » en gras, blanc, au centre ;
--   - boutons plats graphite, texte gris clair ; survol : fond plus clair, texte blanc, liseré gris clair (pas
--     d'or) ; bouton inactif : texte gris sombre. Les boutons ajoutés par d'autres addons (Polestar...) aussi.
-- Le jeu refait ses boutons à chaque ouverture (réserve de boutons) : ils sont repassés à chaque fois ; on ne
-- touche ni à leur clic ni à leur place.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local function tr() return CUI:Tr("FJ_MENU") end

-- Bouton rouge du jeu (Left, Right, Center, lueur de survol ; texte) : bouton plat de CœurUI.
local function skinMenuButton(b)
    if not b or b.cuiMenu then
        if b and b.cuiPaint then b.cuiPaint() end
        return
    end
    if not (b.Left and b.Center) then return end
    b.cuiMenu = true
    CUI:SkinHideTextures(b)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then CUI:SkinHide(t) end
    end
    local panel = CUI:CreatePanel(b, { radius = 4, fill = C.graphite, shadow = false, inset = { 0, 2 } })
    local busy = false
    local function paint()
        if busy then return end
        busy = true
        local enabled = not b.IsEnabled or b:IsEnabled()
        local over = enabled and b:IsMouseOver()
        panel:SetFillColor(over and C.graphiteClair or C.graphite)
        panel.border:SetColor(over and C.texteDiscret or C.lisereSombre)
        local fs = b.GetFontString and b:GetFontString()
        if fs then
            local c = (not enabled) and C.texteDesactive or (over and C.texte or C.texteSecondaire)
            fs:SetTextColor(c[1], c[2], c[3])
            fs:SetShadowOffset(0, 0)
        end
        busy = false
    end
    b:HookScript("OnEnter", paint)
    b:HookScript("OnLeave", paint)
    b:HookScript("OnShow", paint)
    for _, method in ipairs({ "Enable", "Disable", "SetEnabled" }) do
        if b[method] then _G.hooksecurefunc(b, method, paint) end
    end
    local fs = b.GetFontString and b:GetFontString()
    if fs then _G.hooksecurefunc(fs, "SetTextColor", paint) end
    b.cuiPaint = paint
    paint()
end

-- Raccourci « CœurUI » (demandé le 28/11/2026) : un bouton du menu, ajouté par la fonction du jeu (AddButton)
-- à chaque fois que le jeu refait ses boutons, rangé juste sous celui de Polestar (sinon à la fin) ; un clic
-- ferme le menu et ouvre la fenêtre de CœurUI.
local function addShortcut(f)
    if type(f.AddButton) ~= "function" then return end
    local b = f:AddButton(CUI.L.FJ_MENU_COEURUI, function()
        _G.HideUIPanel(f)
        CUI:ToggleModulesScreen()
    end)
    f.cuiShortcut = b
end

-- Place du raccourci sous Polestar ; refaite à l'image suivante (Polestar peut ajouter son bouton après nous).
local function placeShortcut(f)
    local b, polestar = f.cuiShortcut, _G.PolestarGameMenuButton
    local index = polestar and polestar:IsShown() and polestar.layoutIndex
    if not b or type(index) ~= "number" or b.layoutIndex == index + 0.01 then return end
    b.layoutIndex = index + 0.01
    if f.MarkDirty then f:MarkDirty() elseif f.Layout then f:Layout() end
end

local function skinButtons(f)
    for _, child in ipairs({ f:GetChildren() }) do
        if child:GetObjectType() == "Button" then skinMenuButton(child) end
    end
end

local function skinFrame(f)
    if not f or f.cuiMenuJeu or (f.IsForbidden and f:IsForbidden()) then return end
    f.cuiMenuJeu = true
    if f.Border then CUI:SkinHideTextures(f.Border) end
    if f.FrameGlow then CUI:SkinHide(f.FrameGlow) end
    CUI:SkinWindow(f)
    local header = f.Header
    if header then
        CUI:SkinHideTextures(header)
        local text = header.Text
        if text then
            text:ClearAllPoints()
            text:SetPoint("TOP", f, "TOP", 0, -14)
            text:SetFont(CUI:GetFont(), 14, "")
            text:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
            text:SetShadowOffset(0, 0)
        end
    end
    local function refresh()
        CUI:SafeCall(tr(), skinButtons, f)
    end
    f:HookScript("OnShow", function()
        refresh()
        _G.C_Timer.After(0, function()
            refresh() -- boutons d'addons ajoutés à l'ouverture
            CUI:SafeCall(tr(), placeShortcut, f)
        end)
    end)
    if f.InitButtons then
        _G.hooksecurefunc(f, "InitButtons", function()
            CUI:SafeCall(tr(), addShortcut, f)
            CUI:SafeCall(tr(), placeShortcut, f)
            refresh()
        end)
    end
    refresh()
end

local function setup()
    local function go() if _G.GameMenuFrame then CUI:SafeCall(tr(), skinFrame, _G.GameMenuFrame) end end
    if _G.GameMenuFrame then go() return end
    M:WhenLoaded("Blizzard_GameMenu", go)
end

M.windows.menu = { setup = setup }
