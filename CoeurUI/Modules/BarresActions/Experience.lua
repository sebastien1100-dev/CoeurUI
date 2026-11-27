-- Module « Barres d'actions », page « Expérience et réputation » (maquette validée le 27/11/2026,
-- « CœurUI · Maquette Barres d'expérience et de réputation ») :
--   - deux barres fines CœurUI (fond sombre, liseré gris fin, pas d'or) à la place de celles du jeu ;
--   - expérience en violet doux, puis l'expérience des quêtes terminées à rendre (jaune), puis le bonus
--     de repos (bleu) ; « +1 niveau » à droite quand les quêtes à rendre font passer un niveau ;
--   - réputation suivie dans la couleur de son rang (couleurs du jeu) ;
--   - texte au-dessus des barres (au survol, toujours ou jamais), infobulle au survol, clic sur la
--     réputation : page des réputations du jeu ;
--   - niveau maximum : barre d'expérience cachée ; aucune réputation suivie : sa barre cachée.
-- Chaque barre a son propre cadre au cadenas. Rien de protégé : tout se met à jour en combat aussi.
-- Les deux barres coupées : celles du jeu reviennent.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local M = CUI:GetModule("BarresActions")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local function num(v) return type(v) == "number" and not issecret(v) and v or nil end

local WHITE = "Interface\\Buttons\\WHITE8x8"
local COULEUR_XP = { 0.541, 0.435, 0.820 }      -- #8A6FD1
local COULEUR_QUETES = { 0.890, 0.773, 0.290 }  -- #E3C54A
local COULEUR_REPOS = { 0.235, 0.408, 0.882 }   -- #3C68E1
local COULEUR_RENOM = { 0.000, 0.749, 0.953 }
local POSITION_XP = { "BOTTOM", "BOTTOM", 0, 140 }
local POSITION_REP = { "BOTTOM", "BOTTOM", 0, 156 }

-- Réglages : M.db.xp (sous-module « xp »).
M.defaults.xp = {
    xp = true, rep = true, largeurXP = 512, hauteurXP = 8, largeurRep = 512, hauteurRep = 6,
    texte = "survol", tailleTexte = 11, quetes = true, repos = true, infobulle = true,
}

local TEXTE = {
    { value = "survol", text = "BA_XP_AU_SURVOL" }, { value = "toujours", text = "BA_TOUJOURS" },
    { value = "jamais", text = "BA_XP_JAMAIS" },
}
local function texteOn(read) return read("texte") ~= "jamais" end
local function xpOn(read) return read("xp") end
local function repOn(read) return read("rep") end

M.subs[#M.subs + 1] = {
    key = "xp", name = "BA_XP", intro = false,
    settings = {
        { type = "section", text = "BA_XP_AFFICHAGE" },
        { type = "toggle", key = "xp", label = "BA_XP_AFFICHER_XP" },
        { type = "toggle", key = "rep", label = "BA_XP_AFFICHER_REP", description = "BA_XP_PLACE_NOTE" },
        { type = "section", text = "BA_XP_SECTION_XP" },
        { type = "slider", key = "largeurXP", label = "BA_XP_LARGEUR", min = 100, max = 1200, step = 4, format = "%d",
          enabledIf = xpOn },
        { type = "slider", key = "hauteurXP", label = "BA_XP_HAUTEUR", min = 4, max = 24, step = 1, format = "%d",
          enabledIf = xpOn },
        { type = "section", text = "BA_XP_SECTION_REP" },
        { type = "slider", key = "largeurRep", label = "BA_XP_LARGEUR", min = 100, max = 1200, step = 4, format = "%d",
          enabledIf = repOn },
        { type = "slider", key = "hauteurRep", label = "BA_XP_HAUTEUR", min = 4, max = 24, step = 1, format = "%d",
          enabledIf = repOn },
        { type = "column" },
        { type = "section", text = "BA_XP_TEXTE_SECTION" },
        { type = "dropdown", key = "texte", label = "BA_XP_TEXTE", options = TEXTE },
        { type = "slider", key = "tailleTexte", label = "BA_XP_TAILLE_TEXTE", min = 8, max = 16, step = 1, format = "%d pt",
          enabledIf = texteOn },
        { type = "section", text = "BA_XP_DETAILS" },
        { type = "toggle", key = "quetes", label = "BA_XP_QUETES", enabledIf = xpOn },
        { type = "toggle", key = "repos", label = "BA_XP_REPOS", enabledIf = xpOn },
        { type = "toggle", key = "infobulle", label = "BA_XP_INFOBULLE" },
    },
}

-- Données du jeu --------------------------------------------------------------------------------

local function nombre(v)
    if _G.BreakUpLargeNumbers then return _G.BreakUpLargeNumbers(v) end
    return tostring(v)
end

local function atMaxLevel()
    if _G.IsXPUserDisabled and _G.IsXPUserDisabled() then return true end
    if _G.IsPlayerAtEffectiveMaxLevel then return _G.IsPlayerAtEffectiveMaxLevel() and true or false end
    local maxLevel = _G.GetMaxLevelForPlayerExpansion and _G.GetMaxLevelForPlayerExpansion()
    return maxLevel and _G.UnitLevel("player") >= maxLevel or false
end

-- Expérience des quêtes terminées (prêtes à rendre) du journal : total et nombre de quêtes.
-- nil si ce client n'a pas les fonctions nécessaires.
local function questXP()
    local QL = _G.C_QuestLog
    local rewardXP = _G.GetQuestLogRewardXP
    if not (QL and QL.GetNumQuestLogEntries and QL.GetInfo and rewardXP) then return nil end
    local ready = QL.ReadyForTurnIn or QL.IsComplete
    if not ready then return nil end
    local total, count = 0, 0
    for i = 1, QL.GetNumQuestLogEntries() or 0 do
        local info = QL.GetInfo(i)
        local id = info and not info.isHeader and num(info.questID)
        if id and id > 0 and ready(id) then
            local ok, xp = pcall(rewardXP, id)
            xp = ok and num(xp)
            if xp and xp > 0 then
                total, count = total + xp, count + 1
            end
        end
    end
    return total, count
end

local function standingLabel(reaction)
    local label = _G["FACTION_STANDING_LABEL" .. reaction]
    if _G.GetText then
        local ok, text = pcall(_G.GetText, "FACTION_STANDING_LABEL" .. reaction, _G.UnitSex("player"))
        if ok and type(text) == "string" then label = text end
    end
    return label or ""
end

local function reactionColor(reaction)
    local c = _G.FACTION_BAR_COLORS and _G.FACTION_BAR_COLORS[reaction]
    if c then return { c.r, c.g, c.b } end
    return { 0.31, 0.60, 0.31 }
end

-- Réputation suivie : { name, rank, color, value, max (dans le rang), nextRank } ou nil.
local function watchedFaction()
    local name, reaction, low, high, value, id
    local R = _G.C_Reputation
    if R and R.GetWatchedFactionData then
        local d = R.GetWatchedFactionData()
        if not d or not num(d.factionID) or d.factionID == 0 then return nil end
        name, reaction, low, high, value, id = d.name, d.reaction, d.currentReactionThreshold,
            d.nextReactionThreshold, d.currentStanding, d.factionID
    elseif _G.GetWatchedFactionInfo then
        name, reaction, low, high, value, id = _G.GetWatchedFactionInfo()
        if not name then return nil end
    else
        return nil
    end
    if issecret(name) or not num(reaction) or not num(low) or not num(high) or not num(value) then return nil end
    local f = {
        name = name, rank = standingLabel(reaction), color = reactionColor(reaction),
        value = value - low, max = high - low,
        nextRank = reaction < 8 and standingLabel(reaction + 1) or nil,
    }
    -- Factions à renom : niveau de renom et progression vers le suivant.
    if id and R and R.IsMajorFaction and _G.C_MajorFactions then
        local ok, major = pcall(R.IsMajorFaction, id)
        local data = ok and major and _G.C_MajorFactions.GetMajorFactionData(id)
        if data and num(data.renownLevel) then
            f.rank = L.BA_XP_RENOM:format(data.renownLevel)
            f.color = COULEUR_RENOM
            f.value, f.max = num(data.renownReputationEarned) or 0, num(data.renownLevelThreshold) or 0
            f.nextRank = L.BA_XP_RENOM:format(data.renownLevel + 1)
        end
    end
    -- Amitiés (rangs propres à la faction).
    if id and _G.C_GossipInfo and _G.C_GossipInfo.GetFriendshipReputation then
        local ok, info = pcall(_G.C_GossipInfo.GetFriendshipReputation, id)
        if ok and info and num(info.friendshipFactionID) and info.friendshipFactionID > 0 then
            f.rank = type(info.reaction) == "string" and info.reaction or f.rank
            local lo, hi, st = num(info.reactionThreshold), num(info.nextThreshold), num(info.standing)
            if lo and st then
                f.value, f.max = st - lo, hi and (hi - lo) or 0
            end
            f.nextRank = nil
        end
    end
    -- Parangon : au rang le plus haut, la progression vers la prochaine récompense.
    if id and R and R.IsFactionParagon and _G.C_Reputation.GetFactionParagonInfo then
        local ok, paragon = pcall(R.IsFactionParagon, id)
        if ok and paragon then
            local cur, threshold = R.GetFactionParagonInfo(id)
            cur, threshold = num(cur), num(threshold)
            if cur and threshold and threshold > 0 then
                f.rank = L.BA_XP_PARANGON
                f.value, f.max = cur % threshold, threshold
                f.nextRank = nil
            end
        end
    end
    return f
end

-- Cadres -----------------------------------------------------------------------------------------

local barXP, barRep -- une barre chacune, chacune son cadre au cadenas
local data = {}     -- dernière lecture (pour les infobulles)

local function texture(parent, layer, sub, color)
    local t = parent:CreateTexture(nil, layer, nil, sub)
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return t
end

local function colored(color, text)
    return CUI:ColorCode(color) .. text .. "|r"
end

local function pct(v, max)
    if not max or max <= 0 then return 0 end
    return math.floor(v / max * 100 + 0.5)
end

-- Infobulle d'une barre : le détail de l'expérience, ou celui de la réputation.
local function showTooltip(bar)
    if not M.db.xp.infobulle then return end
    local lines = {}
    if bar == barXP then
        local x = data.xp
        if not x then return end
        lines[#lines + 1] = L.BA_XP_EXPERIENCE:format(nombre(x.cur), nombre(x.max), pct(x.cur, x.max))
        lines[#lines + 1] = L.BA_XP_RESTE:format(nombre(x.max - x.cur))
        if x.quests > 0 then
            local n = x.questCount == 1 and L.BA_XP_QUETE_1 or L.BA_XP_QUETES_N:format(x.questCount)
            lines[#lines + 1] = colored(COULEUR_QUETES, L.BA_XP_QUETES_RENDRE:format(nombre(x.quests), n))
            if x.levels > 0 then
                lines[#lines + 1] = colored(COULEUR_QUETES, L.BA_XP_EN_RENDANT:format(x.level + x.levels, x.levelsText))
            end
        end
        if x.rested and x.rested > 0 then
            lines[#lines + 1] = colored(COULEUR_REPOS, L.BA_XP_REPOS_LIGNE:format(nombre(x.rested), pct(x.rested, x.max)))
        end
        CUI:ShowTooltip(bar, L.BA_XP_NIVEAU:format(x.level), table.concat(lines, "\n"))
    else
        local f = data.rep
        if not f then return end
        lines[#lines + 1] = colored(f.color, f.rank)
        if f.max > 0 then
            lines[#lines + 1] = L.BA_XP_REP_VALEURS:format(nombre(f.value), nombre(f.max))
            if f.nextRank then
                lines[#lines + 1] = L.BA_XP_REP_SUIVANT:format(f.nextRank, nombre(f.max - f.value))
            end
        end
        CUI:ShowTooltip(bar, f.name, table.concat(lines, "\n"), L.BA_XP_CLIC_REP)
    end
end

local function paintText(bar)
    local mode = M.db.xp.texte
    bar.text:SetShown(mode == "toujours" or (mode == "survol" and bar.hover))
end

-- Barre : fond sombre, liseré gris fin (4 traits), segments posés de gauche à droite, texte
-- au-dessus. Un bouton : survol (texte, infobulle) et clic.
local function createBar(name, segments)
    local bar = _G.CreateFrame("Button", name, _G.UIParent)
    bar:SetSize(100, 8)
    bar:RegisterForClicks("LeftButtonUp")
    texture(bar, "BACKGROUND", -8, C.fond):SetAllPoints()
    local b = C.bordureDiscrete
    local top, bottom = texture(bar, "OVERLAY", 6, b), texture(bar, "OVERLAY", 6, b)
    local left, right = texture(bar, "OVERLAY", 6, b), texture(bar, "OVERLAY", 6, b)
    top:SetPoint("TOPLEFT"); top:SetPoint("TOPRIGHT"); top:SetHeight(1)
    bottom:SetPoint("BOTTOMLEFT"); bottom:SetPoint("BOTTOMRIGHT"); bottom:SetHeight(1)
    left:SetPoint("TOPLEFT"); left:SetPoint("BOTTOMLEFT"); left:SetWidth(1)
    right:SetPoint("TOPRIGHT"); right:SetPoint("BOTTOMRIGHT"); right:SetWidth(1)
    bar.segs = {}
    for i, color in ipairs(segments) do
        bar.segs[i] = texture(bar, "ARTWORK", i, color)
    end
    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 3)
    bar.text:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
    bar.text:SetFont(CUI:GetFont(), M.db.xp.tailleTexte, "OUTLINE")
    bar.text:SetWordWrap(false)
    bar:SetScript("OnEnter", function(self)
        self.hover = true
        paintText(self)
        showTooltip(self)
    end)
    bar:SetScript("OnLeave", function(self)
        self.hover = false
        paintText(self)
        CUI:HideTooltip(self)
    end)
    return bar
end

-- Segment i de la barre : de from à to (fractions de 0 à 1).
local function setSegment(bar, i, from, to, color)
    local seg = bar.segs[i]
    from, to = math.max(0, math.min(1, from)), math.max(0, math.min(1, to))
    local inner = bar:GetWidth() - 2
    if to <= from or inner <= 0 then
        seg:Hide()
        return
    end
    if color then seg:SetVertexColor(color[1], color[2], color[3], 1) end
    seg:ClearAllPoints()
    seg:SetPoint("TOPLEFT", bar, "TOPLEFT", 1 + from * inner, -1)
    seg:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 1 + from * inner, 1)
    seg:SetWidth(math.max(1, (to - from) * inner))
    seg:Show()
end

-- Lit le jeu et met tout à jour (barres, textes, « +1 niveau »).
local function update()
    if not barXP then return end
    local s = M.db.xp
    data.xp, data.rep = nil, nil
    if s.xp and not atMaxLevel() then
        local cur, max = num(_G.UnitXP("player")), num(_G.UnitXPMax("player"))
        if cur and max and max > 0 then
            local x = { level = _G.UnitLevel("player"), cur = cur, max = max, quests = 0, questCount = 0, levels = 0 }
            if s.quetes then
                local total, count = questXP()
                x.quests, x.questCount = total or 0, count or 0
            end
            if s.repos then x.rested = num(_G.GetXPExhaustion and _G.GetXPExhaustion()) or 0 end
            if cur + x.quests >= max then
                -- Niveaux suivants estimés avec l'expérience du niveau actuel.
                x.levels = 1 + math.floor((cur + x.quests - max) / max)
                x.levelsText = x.levels == 1 and L.BA_XP_PLUS_1 or L.BA_XP_PLUS_N:format(x.levels)
            end
            data.xp = x
        end
    end
    if s.rep then data.rep = watchedFaction() end
    local x, f = data.xp, data.rep

    local font = CUI:GetFont()
    for _, fs in ipairs({ barXP.text, barRep.text, barXP.levelUp }) do fs:SetFont(font, s.tailleTexte, "OUTLINE") end

    barXP:SetSize(s.largeurXP, s.hauteurXP)
    barXP:SetShown(x ~= nil)
    if x then
        local a = x.cur / x.max
        local b = (x.cur + x.quests) / x.max
        local c = b + (x.rested or 0) / x.max
        setSegment(barXP, 1, 0, a)
        setSegment(barXP, 2, a, b)
        setSegment(barXP, 3, b, c)
        local parts = { L.BA_XP_LIGNE:format(x.level, pct(x.cur, x.max)) }
        if x.quests > 0 then parts[#parts + 1] = L.BA_XP_LIGNE_QUETES:format(pct(x.quests, x.max)) end
        if x.rested and x.rested > 0 then parts[#parts + 1] = L.BA_XP_LIGNE_REPOS:format(pct(x.rested, x.max)) end
        barXP.text:SetText(table.concat(parts, " · "))
    end
    barXP.levelUp:SetShown(x ~= nil and x.levels > 0)
    if x and x.levels > 0 then barXP.levelUp:SetText(x.levelsText) end

    barRep:SetSize(s.largeurRep, s.hauteurRep)
    barRep:SetShown(f ~= nil)
    if f then
        setSegment(barRep, 1, 0, f.max > 0 and f.value / f.max or 1, f.color)
        barRep.text:SetText(f.max > 0 and L.BA_XP_REP_LIGNE:format(f.name, f.rank, pct(f.value, f.max))
            or L.BA_XP_REP_LIGNE_MAX:format(f.name, f.rank))
    end

    for _, bar in ipairs({ barXP, barRep }) do
        paintText(bar)
        if bar.hover then showTooltip(bar) end
    end
end

-- Plusieurs évènements à la suite (journal des quêtes...) : une seule lecture, à l'image suivante.
local pending = false
local function requestUpdate()
    if pending then return end
    pending = true
    M:After(0, function()
        pending = false
        update()
    end)
end

-- Barres du jeu : cachées tant qu'une des nôtres est demandée. Elles restent dans leur cadre
-- d'origine (le jeu se sert de ce cadre en les mettant à jour) : cachées, et recachées chaque fois
-- que le jeu les remontre.
local GAME_BARS = { "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer", "StatusTrackingBarManager" }
local hooked = {}
local hiddenByUs = {} -- cachées par CœurUI (seules celles-là sont rendues)

local function wantGameHidden()
    return M.enabled and (M.db.xp.xp or M.db.xp.rep)
end

local function placeGameBars()
    for _, name in ipairs(GAME_BARS) do
        local frame = _G[name]
        if frame and not (frame.IsForbidden and frame:IsForbidden()) and not (frame.IsProtected and frame:IsProtected()) then
            if not hooked[frame] then
                hooked[frame] = true
                frame:HookScript("OnShow", function(self)
                    if wantGameHidden() then self:Hide() end
                end)
            end
            if wantGameHidden() then
                hiddenByUs[frame] = true
                frame:Hide()
            elseif hiddenByUs[frame] then
                hiddenByUs[frame] = nil
                -- Rendues au jeu : il les remontre et les remet à jour lui-même.
                frame:Show()
                if type(frame.UpdateBarsShown) == "function" then pcall(frame.UpdateBarsShown, frame) end
            end
        end
    end
end

local function build()
    if barXP then return end
    barXP = createBar("CoeurUIBarreXP", { COULEUR_XP, COULEUR_QUETES, COULEUR_REPOS })
    barXP.levelUp = barXP:CreateFontString(nil, "OVERLAY")
    barXP.levelUp:SetPoint("LEFT", barXP, "RIGHT", 6, 0)
    barXP.levelUp:SetTextColor(COULEUR_QUETES[1], COULEUR_QUETES[2], COULEUR_QUETES[3])
    barXP.levelUp:SetFont(CUI:GetFont(), M.db.xp.tailleTexte, "OUTLINE")
    barRep = createBar("CoeurUIBarreReputation", { { 0.31, 0.60, 0.31 } })
    barRep:SetScript("OnClick", function()
        if _G.ToggleCharacter then pcall(_G.ToggleCharacter, "ReputationFrame") end
    end)
    CUI:RegisterMover({ key = "barre_xp", frame = barXP, label = "BA_XP_CADRE_XP", default = POSITION_XP })
    CUI:RegisterMover({ key = "barre_rep", frame = barRep, label = "BA_XP_CADRE_REP", default = POSITION_REP })
end

-- Appelés par BarresActions.lua ------------------------------------------------------------------

M.xp = {}

function M.xp.Enable()
    build()
    placeGameBars()
    update()
    for _, event in ipairs({ "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP", "UPDATE_EXHAUSTION", "PLAYER_UPDATE_RESTING",
                             "UPDATE_FACTION", "QUEST_LOG_UPDATE", "QUEST_TURNED_IN", "PLAYER_ENTERING_WORLD",
                             "ENABLE_XP_GAIN", "DISABLE_XP_GAIN", "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" }) do
        pcall(M.On, M, event, requestUpdate)
    end
end

function M.xp.Apply()
    if not barXP then return end
    placeGameBars()
    update()
end

function M.xp.Font()
    if barXP then update() end
end
