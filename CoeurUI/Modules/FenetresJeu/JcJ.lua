-- Fenêtres du jeu · Fiche du personnage · page JcJ (maquette « 1 ter » validée le 28/11/2026, quatre cas :
-- sans rang, rang en cours, rang maximum, Horde) :
--   - gauche : « SAISON 1 » en petites capitales grises, nom du rang en gras ; le blason de faction du jeu
--     gardé, posé dans un médaillon rond du thème (sans l'anneau doré ni le cercle de progression) ; rang
--     chiffré en petite case ; « Points de rang » en barre striée de la couleur de la faction, chiffres
--     au-dessus, ce qui manque pour le rang suivant dessous ;
--   - droite : titre en gras, trait sombre, textes gris, intertitre « RÉCOMPENSES AU RANG 1 » en petites
--     capitales sur un trait, récompense en case d'objet du thème.
-- Écart avec la maquette : le jeu n'a pas de flèches pour changer de rang de récompenses ; l'intertitre
-- reste un intertitre.
local _, CUI = ...
local C = CUI.Colors
local L = CUI.L

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local function tr() return CUI:Tr("FJ_FICHE") end

local FACTION = { Alliance = { 0.235, 0.416, 0.690 }, Horde = { 0.690, 0.251, 0.227 } } -- #3C6AB0, #B0403A
local MAX_RANK = 14
local MEDAL = 138

local function plain(text)
    if type(text) ~= "string" or issecret(text) then return nil end
    return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", ""))
end

local function number(s)
    local digits = s and s:gsub("[^%d]", "")
    return digits and digits ~= "" and tonumber(digits) or nil
end

local function factionColor()
    local group = _G.UnitFactionGroup("player")
    return FACTION[group] or FACTION.Alliance
end

-- Médaillon rond : trois disques (liseré extérieur, liseré intérieur, fond de case), une ombre douce.
local function medal(parent, anchor)
    local holder = _G.CreateFrame("Frame", nil, parent)
    holder:SetSize(MEDAL, MEDAL)
    holder:SetPoint("CENTER", anchor, "CENTER")
    holder:SetFrameLevel(math.max(0, parent:GetFrameLevel()))
    local function disc(size, color, alpha, sub)
        local t = holder:CreateTexture(nil, "BACKGROUND", nil, sub)
        t:SetTexture(CUI.MEDIA .. "Cercle")
        t:SetSize(size, size)
        t:SetPoint("CENTER")
        t:SetVertexColor(color[1], color[2], color[3], alpha or 1)
        return t
    end
    disc(MEDAL + 16, { 0, 0, 0 }, 0.35, -8)
    disc(MEDAL, C.lisereSombre, 1, -7)
    disc(MEDAL - 2, { 0.145, 0.161, 0.188 }, 1, -6) -- le fond éclairci (liseré intérieur)
    disc(MEDAL - 4, C.case, 1, -5)
    return holder
end

-- Points de rang : notre ligne (libellé, chiffres), notre barre striée, ce qui manque dessous.
local function progress(main)
    local field = main.CurrentRankProgressField
    if not field then return end
    CUI:SkinHide(field)
    local block = _G.CreateFrame("Frame", nil, main)
    block:SetSize(240, 52)
    block:SetPoint("TOP", field, "TOP", 0, 4)
    local label = block:CreateFontString(nil, "OVERLAY")
    label:SetFont(CUI:GetFont(), 12, "")
    label:SetPoint("TOPLEFT")
    label:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
    local value = block:CreateFontString(nil, "OVERLAY")
    value:SetFont(CUI:GetFont(), 12, "")
    value:SetPoint("TOPRIGHT")
    value:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    local barBox = _G.CreateFrame("Frame", nil, block)
    barBox:SetPoint("TOPLEFT", 0, -18)
    barBox:SetPoint("TOPRIGHT", 0, -18)
    barBox:SetHeight(16)
    CUI:CreatePanel(barBox, { radius = 3, fill = C.case, shadow = false })
    local fill = barBox:CreateTexture(nil, "ARTWORK")
    fill:SetTexture("Interface\\Buttons\\WHITE8x8")
    fill:SetPoint("TOPLEFT", 2, -2)
    fill:SetPoint("BOTTOMLEFT", 2, 2)
    CUI:CreateStripes(barBox, fill, 2)
    local next = block:CreateFontString(nil, "OVERLAY")
    next:SetFont(CUI:GetFont(), 11, "")
    next:SetPoint("TOP", barBox, "BOTTOM", 0, -5)
    next:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
    local rankLabel = main.RankProgressBarDisplay and main.RankProgressBarDisplay.NextRewardLevel
        and main.RankProgressBarDisplay.NextRewardLevel.LevelLabel
    local function update()
        local text = plain(field:GetText()) or ""
        local before, a, b = text:match("^(.-)%s*:%s*([%d%s%.,\194\160]+)%s*/%s*([%d%s%.,\194\160]+)")
        label:SetText(before ~= "" and before or L.FJ_JCJ_POINTS)
        local cur, max = number(a), number(b)
        if not cur or not max or max <= 0 then
            value:SetText("")
            fill:Hide()
            next:SetText("")
            return
        end
        value:SetText(a:gsub("^%s+", ""):gsub("%s+$", "") .. " / " .. b:gsub("^%s+", ""):gsub("%s+$", ""))
        local c = factionColor()
        fill:SetVertexColor(c[1], c[2], c[3], 1)
        local pct = math.min(1, cur / max)
        fill:SetWidth(math.max(1, (barBox:GetWidth() - 4) * pct))
        fill:SetShown(pct > 0)
        local rank = rankLabel and number(plain(rankLabel:GetText())) or nil
        if (rank and rank >= MAX_RANK) or cur >= max and rank == nil then
            next:SetText(L.FJ_JCJ_MAX)
        elseif rank then
            next:SetText(L.FJ_JCJ_RESTE:format(tostring(max - cur), rank + 1))
        else
            next:SetText("")
        end
    end
    _G.hooksecurefunc(field, "SetText", update)
    if field.SetFormattedText then _G.hooksecurefunc(field, "SetFormattedText", update) end
    main:HookScript("OnShow", function() CUI:SafeCall(tr(), update) end)
    barBox:SetScript("OnSizeChanged", function() CUI:SafeCall(tr(), update) end)
    update()
end

local function skinMain(main)
    if not main then return end
    if main.CurrentSeasonField then
        local fs = main.CurrentSeasonField
        fs:SetFont(CUI:GetFont(), 10, "")
        local busy = false
        local function restyle(self, text)
            if busy or type(text) ~= "string" then return end
            busy = true
            self:SetText(CUI:Upper((text:gsub("%s+", " "))))
            self:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
            busy = false
        end
        _G.hooksecurefunc(fs, "SetText", restyle)
        restyle(fs, fs:GetText())
    end
    if main.CurrentRankField then
        main.CurrentRankField:SetFont(CUI:GetFont(), 17, "")
        main.CurrentRankField:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    end
    if main.Line then CUI:SkinSeparator(main.Line) end
    local disp = main.RankProgressBarDisplay
    if disp then
        -- Cercle de progression du jeu : invisible (la barre le remplace) ; le blason reste.
        for _, r in ipairs({ disp:GetRegions() }) do
            if r:GetObjectType() == "Texture" and r ~= disp.FactionBadge then CUI:SkinHide(r) end
        end
        if disp.SetDrawSwipe then
            local busy = false
            local function noSwipe()
                if busy then return end
                busy = true
                disp:SetDrawSwipe(false)
                if disp.SetDrawEdge then disp:SetDrawEdge(false) end
                if disp.SetDrawBling then disp:SetDrawBling(false) end
                busy = false
            end
            noSwipe()
            _G.hooksecurefunc(disp, "SetDrawSwipe", noSwipe)
            if disp.SetCooldown then _G.hooksecurefunc(disp, "SetCooldown", noSwipe) end
        end
        if disp.FactionBadge then medal(main, disp.FactionBadge) end
        -- Rang chiffré : petite case du thème, chiffre blanc en gras.
        local reward = disp.NextRewardLevel
        if reward then
            for _, key in ipairs({ "RingBorder", "IconCover", "RewardIcon" }) do
                if reward[key] then CUI:SkinHide(reward[key]) end
            end
            local box = _G.CreateFrame("Frame", nil, reward)
            box:SetSize(32, 24)
            box:SetPoint("CENTER")
            box:SetFrameLevel(math.max(0, reward:GetFrameLevel() - 1))
            CUI:CreatePanel(box, { radius = 4, fill = C.fenetre, shadow = false })
            if reward.LevelLabel then
                reward.LevelLabel:SetFont(CUI:GetFont(), 13, "")
                reward.LevelLabel:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
            end
        end
    end
    progress(main)
end

-- Contenu du détail (recréé à chaque mise à jour) : intertitres en petites capitales grises sur un trait,
-- récompense en case d'objet, textes en gris clair.
local function skinContent(content)
    if not content then return end
    for _, block in ipairs({ content:GetChildren() }) do
        local bg, label = block.Background, block.Label
        local atlas = bg and bg.GetAtlas and bg:GetAtlas()
        if type(atlas) == "string" and atlas:find("Info%-Title") then
            if not block.cuiTitle then
                block.cuiTitle = true
                CUI:SkinHide(bg)
                local line = block:CreateTexture(nil, "ARTWORK")
                line:SetColorTexture(C.lisereSombre[1], C.lisereSombre[2], C.lisereSombre[3], 1)
                line:SetHeight(1)
                line:SetPoint("BOTTOMLEFT", 2, 8)
                line:SetPoint("BOTTOMRIGHT", -2, 8)
                if label then
                    label:SetFont(CUI:GetFont(), 10, "")
                    local busy = false
                    local function restyle(fs, text)
                        if busy or type(text) ~= "string" then return end
                        busy = true
                        fs:SetText(CUI:Upper(plain(text) or text))
                        fs:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
                        busy = false
                    end
                    _G.hooksecurefunc(label, "SetText", restyle)
                    restyle(label, label:GetText())
                end
            end
        elseif block.IconSlot and block.Icon then
            if not block.cuiReward then
                block.cuiReward = true
                CUI:SkinHide(block.IconSlot)
                local icon = block.Icon
                local box = _G.CreateFrame("Frame", nil, block)
                box:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
                box:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
                box:SetFrameLevel(math.max(0, block:GetFrameLevel() - 1))
                CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                _G.hooksecurefunc(icon, "SetTexture", function(t) t:SetTexCoord(0.08, 0.92, 0.08, 0.92) end)
            end
            if label then label:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
        elseif label and not block.cuiTitle then
            local c = C.texteSecondaire
            label:SetTextColor(c[1], c[2], c[3])
        end
    end
end

local function paintDescription(box)
    local target = box and box.ScrollTarget
    if not target then return end
    for _, child in ipairs({ target:GetChildren() }) do
        for _, r in ipairs({ child:GetRegions() }) do
            if r:GetObjectType() == "FontString" then
                local c = C.texteSecondaire
                r:SetTextColor(c[1], c[2], c[3])
            end
        end
    end
end

local function skinDetail(detail)
    if not detail then return end
    if detail.Title then
        detail.Title:SetFont(CUI:GetFont(), 14, "")
        detail.Title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    end
    if detail.Subtitle then
        local c = C.texteDiscret
        detail.Subtitle:SetTextColor(c[1], c[2], c[3])
    end
    if detail.Divider then CUI:SkinSeparator(detail.Divider) end
    CUI:SkinScrollBar(detail.DescriptionScrollBar)
    local desc = detail.Description and detail.Description.ScrollBox
    local function refresh()
        _G.C_Timer.After(0, function()
            CUI:SafeCall(tr(), skinContent, detail.Content)
            CUI:SafeCall(tr(), paintDescription, desc)
        end)
    end
    if desc then
        if desc.Shadows then CUI:SkinHideTextures(desc.Shadows) end
        if desc.Update then _G.hooksecurefunc(desc, "Update", refresh) end
    end
    if detail.Title then _G.hooksecurefunc(detail.Title, "SetText", refresh) end
    detail:HookScript("OnShow", refresh)
    refresh()
end

local function skinPvp()
    local pf = _G.PVPRankFrame
    if not pf or (pf.IsForbidden and pf:IsForbidden()) then return end
    CUI:SkinHideTextures(pf)
    skinMain(pf.MainInfoFrame)
    skinDetail(pf.DetailFrame)
end

M.fichePages = M.fichePages or {}
M.fichePages[#M.fichePages + 1] = skinPvp
