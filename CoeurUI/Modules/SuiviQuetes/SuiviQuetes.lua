-- Module « Suivi des quêtes » (maquette validée le 28/11/2026, « CœurUI · Maquette Suivi des quêtes (le
-- nôtre) »). Étape 1 : notre propre liste des quêtes suivies (le suivi du jeu impose son ordre et ne sait
-- pas défiler) :
--   - rangées par zone, dans l'ordre du journal, la zone où l'on se trouve en premier (« ici ») ; titres
--     de zone repliables (gardés d'une session à l'autre, réglage) ; quêtes à rendre en premier (réglage) ;
--   - titre [niveau] à la couleur de la difficulté, étiquette (Donjon, Élite...) en gris, pastille « ! »
--     ou « ? » ; objectifs avec l'avancée en début de ligne (réglage), rouge » jaune » vert, faits en vert
--     avec une coche ; « À rendre » quand tout est fait ;
--   - clic : la quête dans le journal ; Maj-clic : son lien dans la discussion ; clic droit : menu (ne plus
--     suivre, partager, lien dans la discussion, demande de groupe, lien Wowhead, abandonner) ;
--   - placée au cadenas, grandit vers le bas jusqu'à la hauteur maximale, puis défile à la molette (titre
--     de la zone en cours fixé en haut) ; repli automatique en combat, en donjon ou raid ; fond léger.
-- Le suivi du jeu garde le reste (campagne, objectifs bonus, scénarios...), sous notre liste et habillé
-- au même style, sans ses quêtes ; ou caché (réglage).
-- Étape 2 : les objets de quête, à droite de leur quête, utilisables d'un clic (bouton protégé posé
-- par-dessus, hors combat ; il reste en combat à sa dernière place).
-- Couper le module demande un /reload.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local M = CUI:RegisterModule({
    key = "SuiviQuetes",
    name = "SQ_NOM",
    description = "SQ_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = {
        largeur = 280, hauteur = 500, tailleTitres = 13, tailleObjectifs = 12,
        replierCombat = false, replierDonjon = true, fond = true, opaciteFond = 55,
        defilement = true, avanceeDebut = true,
        parZone = true, rendreEnPremier = true, garderReplis = true, reste = true, seuleMaZone = true,
        zonesRepliees = {}, -- zone -> true : repliée par le joueur
    },
    settings = {
        { type = "section", text = "SQ_PLACE" },
        { type = "slider", key = "largeur", label = "SQ_LARGEUR", min = 200, max = 420, step = 10, format = "%d" },
        { type = "slider", key = "hauteur", label = "SQ_HAUTEUR", min = 200, max = 900, step = 20, format = "%d",
          description = "SQ_HAUTEUR_NOTE" },
        { type = "toggle", key = "defilement", label = "SQ_DEFILEMENT", description = "SQ_DEFILEMENT_NOTE" },
        { type = "section", text = "SQ_RANGEMENT" },
        { type = "toggle", key = "parZone", label = "SQ_PAR_ZONE" },
        { type = "toggle", key = "rendreEnPremier", label = "SQ_RENDRE_PREMIER" },
        { type = "toggle", key = "seuleMaZone", label = "SQ_SEULE_MA_ZONE", description = "SQ_SEULE_MA_ZONE_NOTE",
          enabledIf = function(read) return read("parZone") end },
        { type = "toggle", key = "garderReplis", label = "SQ_GARDER_REPLIS",
          enabledIf = function(read) return read("parZone") and not read("seuleMaZone") end },
        { type = "section", text = "SQ_TEXTES" },
        { type = "slider", key = "tailleTitres", label = "SQ_TAILLE_TITRES", min = 10, max = 18, step = 1, format = "%d pt" },
        { type = "slider", key = "tailleObjectifs", label = "SQ_TAILLE_OBJECTIFS", min = 9, max = 16, step = 1, format = "%d pt" },
        { type = "toggle", key = "avanceeDebut", label = "SQ_AVANCEE_DEBUT", description = "SQ_AVANCEE_DEBUT_NOTE" },
        { type = "column" },
        { type = "section", text = "SQ_REPLI" },
        { type = "toggle", key = "replierCombat", label = "SQ_REPLI_COMBAT" },
        { type = "toggle", key = "replierDonjon", label = "SQ_REPLI_DONJON", description = "SQ_REPLI_NOTE" },
        { type = "section", text = "SQ_FOND" },
        { type = "toggle", key = "fond", label = "SQ_FOND_AFFICHER" },
        { type = "slider", key = "opaciteFond", label = "SQ_OPACITE", min = 0, max = 100, step = 5, format = "%d %%",
          enabledIf = function(read) return read("fond") end },
        { type = "section", text = "SQ_RESTE" },
        { type = "toggle", key = "reste", label = "SQ_RESTE_AFFICHER", description = "SQ_RESTE_NOTE" },
    },
})

local WHITE = "Interface\\Buttons\\WHITE8x8"
local issecret = _G.issecretvalue or function() return false end
local function known(v) return v ~= nil and not issecret(v) end

local GREY = C.texteDiscret
local LIGHT = C.texteSecondaire
local DONE = C.actif
local PAD = 10      -- marge intérieure du cadre
local INDENT = 22   -- retrait des quêtes (place de la pastille)
local ITEM = 24     -- bouton d'objet de quête

-- Couleurs ---------------------------------------------------------------------------------------

local ROUGE = { 0.88, 0.36, 0.36 }
local JAUNE = { 0.92, 0.78, 0.36 }
local function mix(a, b, t)
    return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t }
end
local function progressColor(ratio)
    ratio = math.max(0, math.min(1, ratio))
    if ratio < 0.5 then return mix(ROUGE, JAUNE, ratio * 2) end
    return mix(JAUNE, DONE, (ratio - 0.5) * 2)
end

local function levelColor(level)
    if known(level) and type(_G.GetQuestDifficultyColor) == "function" then
        local c = _G.GetQuestDifficultyColor(level)
        if c then return { c.r, c.g, c.b } end
    end
    return LIGHT
end

-- Avancée en début de ligne (réglage) : « Glande à venin : 0/12 » devient « 0/12 Glande à venin » ;
-- « Malandrin : 0/10 personnages tués » devient « 0/10 Malandrin » ; une autre précision reste entre
-- parenthèses.
-- « personnages tués » retiré où qu'il soit dans la ligne (le nombre et le nom suffisent), quelle que
-- soit la façon dont le jeu l'écrit.
local function withoutKills(s)
    local suffix = L.SQ_SUFFIXE_TUES
    local first, last = s:lower():find(suffix:lower(), 1, true)
    if not first then return s end
    s = s:sub(1, first - 1) .. s:sub(last + 1)
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+:", " :")
    return s
end

local function countFirst(s)
    if type(s) ~= "string" or issecret(s) then return s end
    s = withoutKills(s)
    if not M.db.avanceeDebut then return s end
    local name, count, rest = s:match("^(.-)%s*:%s*(%d+%s*/%s*%d+)%s*(.-)$")
    if not name or name == "" then return s end
    return count .. " " .. name .. (rest ~= "" and (" (" .. rest .. ")") or "")
end

-- Données : les quêtes suivies, rangées ----------------------------------------------------------

local function zoneHere()
    local z = _G.GetRealZoneText and _G.GetRealZoneText() or _G.GetZoneText()
    return known(z) and z or nil
end

-- Liste à afficher : { { zone = nom ou nil, here = bool, quests = { { id, title, level, tag, complete,
-- objectives = { { text, have, need, done } } } } } }.
local function collect()
    local QL = _G.C_QuestLog
    if not (QL and QL.GetNumQuestWatches and QL.GetInfo) then return {} end
    local watched, order = {}, {}
    for i = 1, QL.GetNumQuestWatches() do
        local id = QL.GetQuestIDForQuestWatchIndex(i)
        if known(id) then
            watched[id] = true
            order[id] = i
        end
    end
    local here = zoneHere()
    local zones, byName = {}, {}
    local header
    for i = 1, QL.GetNumQuestLogEntries() do
        local info = QL.GetInfo(i)
        if info then
            if info.isHeader then
                header = known(info.title) and info.title or header
            elseif known(info.questID) and watched[info.questID] and not info.isHidden then
                local id = info.questID
                local zoneName = M.db.parZone and header or nil
                local zone = byName[zoneName or ""]
                if not zone then
                    zone = { zone = zoneName, here = zoneName ~= nil and zoneName == here, quests = {} }
                    byName[zoneName or ""] = zone
                    zones[#zones + 1] = zone
                end
                local complete = QL.IsComplete and QL.IsComplete(id)
                local tag
                if QL.GetQuestTagInfo then
                    local ok, t = pcall(QL.GetQuestTagInfo, id)
                    if ok and t and known(t.tagName) then tag = t.tagName end
                end
                local q = {
                    id = id, title = info.title, level = info.level, tag = tag, logIndex = i,
                    complete = known(complete) and complete or false, watchIndex = order[id] or 999,
                    objectives = {},
                }
                local objectives = QL.GetQuestObjectives and QL.GetQuestObjectives(id)
                if type(objectives) == "table" then
                    for _, o in ipairs(objectives) do
                        if known(o.text) and o.text ~= "" then
                            q.objectives[#q.objectives + 1] = {
                                text = o.text, have = known(o.numFulfilled) and o.numFulfilled or nil,
                                need = known(o.numRequired) and o.numRequired or nil,
                                done = known(o.finished) and o.finished or false,
                            }
                        end
                    end
                end
                zone.quests[#zone.quests + 1] = q
            end
        end
    end
    -- Zone actuelle en premier, les autres dans l'ordre du journal.
    for i, zone in ipairs(zones) do
        if zone.here and i > 1 then
            table.remove(zones, i)
            table.insert(zones, 1, zone)
            break
        end
    end
    for _, zone in ipairs(zones) do
        local list = zone.quests
        local function before(a, b)
            if M.db.rendreEnPremier and a.complete ~= b.complete then return a.complete end
            if M.db.parZone then return a.logIndex < b.logIndex end
            return a.watchIndex < b.watchIndex
        end
        table.sort(list, before)
    end
    return zones
end

-- Liens et menu -----------------------------------------------------------------------------------

local function questLink(id)
    local link = _G.GetQuestLink and _G.GetQuestLink(id)
    if known(link) then return link end
end

local function questTitle(id)
    local t = _G.C_QuestLog.GetTitleForQuestID and _G.C_QuestLog.GetTitleForQuestID(id)
    return known(t) and t or ""
end

-- Texte préparé dans la boîte de discussion (jamais envoyé par l'addon : le joueur appuie sur Entrée).
local function prepareChat(text)
    if not text then return end
    if _G.ChatEdit_InsertLink and _G.ChatEdit_GetActiveWindow and _G.ChatEdit_GetActiveWindow() then
        _G.ChatEdit_InsertLink(text)
    elseif _G.ChatFrame_OpenChat then
        _G.ChatFrame_OpenChat(text)
    end
end

local function openQuest(id)
    if _G.QuestMapFrame_OpenToQuestDetails then
        pcall(_G.QuestMapFrame_OpenToQuestDetails, id)
    elseif _G.ToggleQuestLog then
        _G.ToggleQuestLog()
    end
end

local function showWowhead(id)
    CUI:ShowCopyWindow({
        title = L.SQ_LIEN_TITRE:format(questTitle(id)),
        label = L.SQ_LIEN_ADRESSE,
        text = L.SQ_WOWHEAD_URL:format(id),
        hint = L.SQ_LIEN_AIDE,
    })
end

local function abandon(id)
    local QL = _G.C_QuestLog
    if not (QL.SetSelectedQuest and QL.SetAbandonQuest and _G.StaticPopup_Show) then return end
    QL.SetSelectedQuest(id)
    QL.SetAbandonQuest()
    _G.StaticPopup_Show("ABANDON_QUEST", questTitle(id))
end

local function openMenu(owner, id)
    local MU = _G.MenuUtil
    if not (MU and MU.CreateContextMenu) then return end
    MU.CreateContextMenu(owner, function(_, root)
        root:CreateTitle(questTitle(id))
        root:CreateButton(L.SQ_MENU_OUVRIR, function() openQuest(id) end)
        root:CreateButton(L.SQ_MENU_NE_PLUS_SUIVRE, function() _G.C_QuestLog.RemoveQuestWatch(id) end)
        local QL = _G.C_QuestLog
        local pushable = QL.IsPushableQuest and QL.IsPushableQuest(id)
        if known(pushable) and pushable and _G.IsInGroup and _G.IsInGroup() then
            root:CreateButton(L.SQ_MENU_PARTAGER, function()
                QL.SetSelectedQuest(id)
                if _G.QuestLogPushQuest then _G.QuestLogPushQuest() end
            end)
        end
        if root.CreateDivider then root:CreateDivider() end
        root:CreateButton(L.SQ_MENU_LIEN, function() prepareChat(questLink(id)) end)
        root:CreateButton(L.SQ_MENU_GROUPE, function()
            local link = questLink(id)
            if link then prepareChat(L.SQ_GROUPE_TEXTE:format(link)) end
        end)
        root:CreateButton(L.SQ_WOWHEAD, function() showWowhead(id) end)
        if root.CreateDivider then root:CreateDivider() end
        root:CreateButton(L.SQ_MENU_ABANDONNER, function() abandon(id) end)
    end)
end

-- Notre liste -------------------------------------------------------------------------------------

local holder, scroll, content, back, sticky
local zoneRows, questRows, lineRows = {}, {}, {} -- cadres réutilisés
local sessionClosed = {}   -- zones repliées sans les garder d'une session à l'autre
local autoCollapsed = false -- replié par le repli automatique (combat, donjon)
local placedZones = {}      -- { zone, open, top } des titres de zone affichés (titre fixé)
local placedItems = {}      -- { a, b, top } : ce qui est dessiné dans la liste (caché sous le titre fixé)

local function closedSet()
    return M.db.garderReplis and M.db.zonesRepliees or sessionClosed
end

local function newText(parent, size)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(CUI:GetFont(), size, "")
    fs:SetShadowColor(0, 0, 0, 0.9)
    fs:SetShadowOffset(1, -1)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    return fs
end

local requestRefresh -- plus bas

-- « Ne déplier que ma zone » (réglage) : ma zone dépliée, les autres repliées ; un clic les ouvre ou les
-- ferme quand même, jusqu'au prochain changement de zone.
local zoneOverride = {} -- zone -> true (ouverte) / false (fermée), remis à zéro en changeant de zone
local lastHere

local function isOpen(zone)
    if M.db.seuleMaZone then
        local o = zoneOverride[zone.zone]
        if o ~= nil then return o end
        return zone.here
    end
    return not closedSet()[zone.zone]
end

local function toggleZone(name, wasOpen)
    if M.db.seuleMaZone then
        zoneOverride[name] = not wasOpen
    else
        local set = closedSet()
        set[name] = not set[name] or nil
    end
    requestRefresh()
end

-- Titre de zone : chevron, nom (blanc pour la zone actuelle, gris sinon), « ici », nombre de quêtes.
local function setupZoneRow(row)
    row:RegisterForClicks("LeftButtonUp")
    row.chevron = row:CreateTexture(nil, "OVERLAY")
    row.chevron:SetTexture(CUI.MEDIA .. "Icones\\Chevron")
    row.chevron:SetSize(10, 10)
    row.chevron:SetPoint("LEFT", 0, 0)
    row.name = newText(row, 11)
    row.name:SetPoint("LEFT", row.chevron, "RIGHT", 5, 0)
    row.name:SetJustifyV("MIDDLE")
    row.here = newText(row, 10)
    row.here:SetPoint("LEFT", row.name, "RIGHT", 6, 0)
    row.here:SetJustifyV("MIDDLE")
    row.here:SetText(L.SQ_ICI)
    row.here:SetTextColor(C.coeur[1], C.coeur[2], C.coeur[3])
    row.count = newText(row, 11)
    row.count:SetPoint("RIGHT", -2, 0)
    row.count:SetJustifyV("MIDDLE")
    -- Trait léger sous une zone dépliée, centré, aux 80 % de la largeur du fond.
    row.line = row:CreateTexture(nil, "ARTWORK")
    row.line:SetTexture(WHITE)
    row.line:SetHeight(1)
    row.line:SetPoint("TOP", row, "BOTTOM", 0, 1)
    row.line:SetVertexColor(C.bordureDiscrete[1], C.bordureDiscrete[2], C.bordureDiscrete[3], 0.7)
    row:SetScript("OnClick", function(self) if self.zoneName then toggleZone(self.zoneName, self.isOpen) end end)
end

local function zoneRow(i, parent)
    local row = zoneRows[i]
    if not row then
        row = _G.CreateFrame("Button", nil, parent)
        setupZoneRow(row)
        zoneRows[i] = row
    end
    return row
end

local function paintZoneRow(row, zone, open)
    row.zoneName, row.isOpen = zone.zone, open
    local c = zone.here and C.texte or GREY
    row.name:SetFont(CUI:GetFont(), math.max(9, M.db.tailleTitres - 2), "")
    row.name:SetText(string.upper(zone.zone))
    row.name:SetTextColor(c[1], c[2], c[3])
    row.here:SetShown(zone.here)
    row.count:SetFont(CUI:GetFont(), math.max(9, M.db.tailleTitres - 2), "")
    row.count:SetText(#zone.quests)
    row.count:SetTextColor(0.44, 0.45, 0.49)
    row.chevron:SetVertexColor(GREY[1], GREY[2], GREY[3])
    row.chevron:SetRotation(open and 0 or (math.pi / 2))
    row.line:SetWidth(math.floor(M.db.largeur * 0.8 + 0.5))
    row.line:SetShown(open)
end

-- Bloc d'une quête : pastille, titre, lignes d'objectifs ; clic, Maj-clic, clic droit, survol.
local function questRow(i)
    local row = questRows[i]
    if row then return row end
    row = _G.CreateFrame("Button", nil, content)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row.badge = row:CreateTexture(nil, "ARTWORK")
    row.badge:SetSize(14, 14)
    row.badge:SetPoint("TOPLEFT", 0, 0)
    row.title = newText(row, 13)
    row.title:SetPoint("TOPLEFT", INDENT, 0)
    row.title:SetWordWrap(true)
    row.hover = row:CreateTexture(nil, "BACKGROUND")
    row.hover:SetTexture(WHITE)
    row.hover:SetAllPoints()
    row.hover:SetVertexColor(1, 1, 1, 0.04)
    row.hover:Hide()
    row:SetScript("OnClick", function(self, button)
        if not self.questID then return end
        if button == "RightButton" then
            openMenu(self, self.questID)
        elseif _G.IsShiftKeyDown() then
            prepareChat(questLink(self.questID))
        else
            openQuest(self.questID)
        end
    end)
    row:SetScript("OnEnter", function(self) self.hover:Show() end)
    row:SetScript("OnLeave", function(self) self.hover:Hide() end)
    questRows[i] = row
    return row
end

-- Objet de quête (étape 2) : l'icône dans notre liste ; le clic passe par un bouton protégé posé
-- par-dessus (noyau, AttachSecureAction), seulement quand l'icône est entière dans la partie visible.
local function inView(frame)
    local top, bottom = frame:GetTop(), frame:GetBottom()
    local vt, vb = scroll:GetTop(), scroll:GetBottom()
    if not (top and bottom and vt and vb) then return false end
    if sticky and sticky:IsShown() then vt = sticky:GetBottom() or vt end
    return top <= vt + 0.5 and bottom >= vb - 0.5
end

local function createItemButton(row)
    local b = _G.CreateFrame("Button", nil, row)
    b:SetSize(ITEM, ITEM)
    b:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    b.border, b.fill = CUI:CreateBorderedRect(b, 3, C.graphite, C.fond)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 1, -1)
    b.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b.cd = _G.CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
    b.cd:SetAllPoints(b.icon)
    b.count = b:CreateFontString(nil, "OVERLAY")
    b.count:SetFont(CUI:GetFont(), 10, "OUTLINE")
    b.count:SetPoint("BOTTOMRIGHT", -1, 1)
    function b:SetVisualState(hover, pressed)
        local c = pressed and C.or_ or (hover and C.texte or C.graphite)
        self.border:SetColor(c)
    end
    CUI:AttachSecureAction(b, { type = "item", item = function() return b.link end }, {
        when = function() return b.link ~= nil and inView(b) end,
        gameTooltip = function(tip)
            if b.logIndex and tip.SetQuestLogSpecialItem then tip:SetQuestLogSpecialItem(b.logIndex) end
        end,
        keepInCombat = true,
    })
    b:Hide()
    row.item = b
end

-- L'objet d'une quête (lien, icône, charges, recharge), ou caché.
local function setQuestItem(row, q)
    if not row.item then createItemButton(row) end
    local b = row.item
    local link, texture, charges, showComplete
    if _G.GetQuestLogSpecialItemInfo and q.logIndex then
        link, texture, charges, showComplete = _G.GetQuestLogSpecialItemInfo(q.logIndex)
    end
    if not known(link) or (q.complete and not showComplete) then
        b.link, b.logIndex = nil, nil
        b:Hide()
        return false
    end
    b.link, b.logIndex = link, q.logIndex
    b.icon:SetTexture(texture)
    b.count:SetText((known(charges) and charges > 1) and charges or "")
    if _G.GetQuestLogSpecialItemCooldown then
        local start, duration, enable = _G.GetQuestLogSpecialItemCooldown(q.logIndex)
        if known(start) and known(duration) and start and duration and duration > 0 then
            _G.CooldownFrame_Set(b.cd, start, duration, enable)
        else
            b.cd:Clear()
        end
    end
    b:Show()
    return true
end

-- Ligne d'objectif (tiret ou coche, texte).
local function lineRow(i)
    local line = lineRows[i]
    if line then return line end
    line = { mark = newText(content, 12), text = newText(content, 12) }
    line.text:SetWordWrap(true)
    lineRows[i] = line
    return line
end

local function hideFrom(list, first)
    for i = first, #list do
        local r = list[i]
        if r.Hide then r:Hide() else r.mark:Hide(); r.text:Hide() end
    end
end

-- Hauteur visible du cadre et défilement le plus grand possible.
local contentHeight = 0
local function maxScroll()
    if not scroll then return 0 end
    return math.max(0, contentHeight - scroll:GetHeight())
end

-- Titre de zone fixé en haut pendant le défilement : celui de la zone en cours de lecture. Sans fond à
-- lui (même fond léger que le reste) : ce qui passe sous lui est caché, ligne par ligne.
local function updateSticky()
    if not sticky then return end
    local offset = scroll:GetVerticalScroll()
    local current
    for _, placed in ipairs(placedZones) do
        if placed.top <= offset + 1 then current = placed end
    end
    local shown = M.db.parZone and offset > 0 and current ~= nil
    local limit = shown and (offset + sticky:GetHeight() + 2) or -1
    for _, item in ipairs(placedItems) do
        local alpha = (item.top < limit) and 0 or 1
        item.a:SetAlpha(alpha)
        if item.b then item.b:SetAlpha(alpha) end
    end
    if not shown then
        sticky:Hide()
        return
    end
    paintZoneRow(sticky, current.zone, current.open)
    sticky:Show()
end

-- Dessine toute la liste.
local function layout()
    if not content then return end
    local s = M.db
    local width = s.largeur - 2 * PAD
    content:SetWidth(width)
    local zones = collect()
    local here = zoneHere()
    if here ~= lastHere then -- nouvelle zone : on oublie les zones ouvertes ou fermées à la main
        lastHere = here
        _G.wipe(zoneOverride)
    end
    local y = 0
    local zi, qi, li = 0, 0, 0
    _G.wipe(placedZones)
    _G.wipe(placedItems)
    local titleSize, lineSize = s.tailleTitres, s.tailleObjectifs
    for _, zone in ipairs(zones) do
        local open = not autoCollapsed and (zone.zone == nil or isOpen(zone))
        if zone.zone then
            zi = zi + 1
            local row = zoneRow(zi, content)
            row:SetSize(width, math.max(16, titleSize + 4))
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            paintZoneRow(row, zone, open)
            row:Show()
            placedZones[#placedZones + 1] = { zone = zone, open = open, top = y }
            placedItems[#placedItems + 1] = { a = row, top = y }
            y = y + row:GetHeight() + 4
        end
        if open then
            for _, q in ipairs(zone.quests) do
                qi = qi + 1
                local row = questRow(qi)
                row.questID = q.id
                row.badge:SetTexture(q.complete and "Interface\\GossipFrame\\ActiveQuestIcon"
                    or "Interface\\GossipFrame\\AvailableQuestIcon")
                row.title:SetFont(CUI:GetFont(), titleSize, "")
                -- Objet de quête à droite : le texte lui laisse la place.
                local itemRoom = setQuestItem(row, q) and (ITEM + 4) or 0
                row.title:SetWidth(width - INDENT - itemRoom)
                local level = known(q.level) and q.level > 0 and ("[" .. q.level .. "] ") or ""
                local tag = q.tag and (" |cff9a9da5(" .. q.tag .. ")|r") or ""
                row.title:SetText(level .. (q.title or "") .. tag)
                local c = levelColor(q.level)
                row.title:SetTextColor(c[1], c[2], c[3])
                local top = y
                y = y + row.title:GetStringHeight() + 2
                -- Objectifs (ou « À rendre »).
                local lines = q.objectives
                if q.complete then lines = { { text = L.SQ_A_RENDRE, done = false, turnIn = true } } end
                for _, o in ipairs(lines) do
                    li = li + 1
                    local line = lineRow(li)
                    line.mark:SetFont(CUI:GetFont(), lineSize, "")
                    line.text:SetFont(CUI:GetFont(), lineSize, "")
                    line.mark:ClearAllPoints()
                    line.mark:SetPoint("TOPLEFT", content, "TOPLEFT", INDENT, -y)
                    line.text:ClearAllPoints()
                    line.text:SetPoint("TOPLEFT", content, "TOPLEFT", INDENT + lineSize, -y)
                    line.text:SetWidth(width - INDENT - lineSize - itemRoom)
                    local color
                    if o.turnIn then
                        line.mark:SetText("")
                        color = LIGHT
                    elseif o.done then
                        line.mark:SetText("|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t")
                        color = DONE
                    else
                        line.mark:SetText("-")
                        line.mark:SetTextColor(GREY[1], GREY[2], GREY[3])
                        color = (o.have and o.need and o.need > 0) and progressColor(o.have / o.need) or LIGHT
                    end
                    line.text:SetText(countFirst(o.text))
                    line.text:SetTextColor(color[1], color[2], color[3])
                    line.mark:Show()
                    line.text:Show()
                    placedItems[#placedItems + 1] = { a = line.mark, b = line.text, top = y }
                    y = y + line.text:GetStringHeight() + 1
                end
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -top)
                row:SetSize(width, math.max(y - top, itemRoom > 0 and ITEM or 0))
                y = math.max(y, top + (itemRoom > 0 and ITEM or 0))
                row:Show()
                placedItems[#placedItems + 1] = { a = row, top = top }
                y = y + 6
            end
        end
        y = y + 2
    end
    hideFrom(zoneRows, zi + 1)
    hideFrom(questRows, qi + 1)
    hideFrom(lineRows, li + 1)
    contentHeight = math.max(1, y)
    content:SetHeight(contentHeight)

    -- Le cadre suit sa liste jusqu'à la hauteur maximale (il grandit vers le bas), puis défile.
    local maxH = s.defilement and s.hauteur or math.huge
    local visible = math.min(contentHeight, maxH)
    holder:SetSize(s.largeur, visible + 2 * PAD)
    if scroll:GetVerticalScroll() > maxScroll() then scroll:SetVerticalScroll(maxScroll()) end
    back:SetShown(s.fond and #zones > 0)
    back:SetVertexColor(C.fond[1], C.fond[2], C.fond[3], s.opaciteFond / 100)
    holder:SetShown(#zones > 0)
    updateSticky()
end

local pending = false
requestRefresh = function()
    if pending then return end
    pending = true
    M:After(0.1, function()
        pending = false
        CUI:SafeCall(CUI:Tr("SQ_NOM"), layout)
    end)
end

-- Le suivi du jeu : le reste (campagne, objectifs bonus...), sans ses quêtes -----------------------

local hiddenParent
local placingGame = false

local function gameTracker()
    local t = _G.ObjectiveTrackerFrame
    if t and not (t.IsForbidden and t:IsForbidden()) then return t end
end

-- Ses quêtes (les nôtres les remplacent) : module retiré du suivi du jeu s'il le permet, sinon invisible.
local function hideGameQuests()
    local t, module = gameTracker(), _G.QuestObjectiveTracker
    if not (t and module) then return end
    if not module.cuiHidden then
        module.cuiHidden = true
        if t.RemoveModule and pcall(t.RemoveModule, t, module) then return end
        _G.hooksecurefunc(module, "Show", function(self) if M.enabled then self:SetAlpha(0) end end)
    end
    module:SetAlpha(0)
end

-- Sous notre liste (réglage) ou caché. Il contient des boutons protégés : hors combat seulement.
local function placeGame()
    local t = gameTracker()
    if not t or not holder or _G.InCombatLockdown() then return end
    placingGame = true
    if M.db.reste then
        if t:GetParent() == hiddenParent then t:SetParent(_G.UIParent) end
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", holder, "BOTTOMLEFT", 0, -6)
        t:SetWidth(M.db.largeur)
        t:SetHeight(400)
    else
        hiddenParent = hiddenParent or _G.CreateFrame("Frame")
        hiddenParent:Hide()
        t:SetParent(hiddenParent)
    end
    placingGame = false
end

local function applyGameFonts()
    local file = CUI:GetFont()
    for name, size in pairs({ ObjectiveTrackerHeaderFont = M.db.tailleTitres,
                              ObjectiveTrackerLineFont = M.db.tailleObjectifs }) do
        local font = _G[name]
        if font and font.SetFont then
            local _, _, flags = font:GetFont()
            font:SetFont(file, size, flags or "")
        end
    end
end

-- Habillage du reste du suivi du jeu : titres gris, décor invisible, lignes à l'avancée en couleur.
local function skinGameFrame(frame, depth)
    if depth > 7 or not frame or (frame.IsForbidden and frame:IsForbidden()) or not frame:IsShown() then return end
    local header = rawget(frame, "Header")
    if type(header) == "table" and header.GetObjectType then
        local bg = rawget(header, "Background")
        if bg and bg.SetAlpha then bg:SetAlpha(0) end
        local text = rawget(header, "Text")
        if text and text.SetTextColor then text:SetTextColor(GREY[1], GREY[2], GREY[3]) end
    end
    local text = rawget(frame, "Text")
    if text and text.SetTextColor and rawget(frame, "Dash") ~= nil and text.GetText then
        local s = text:GetText()
        local turned = countFirst(s)
        if turned ~= s then text:SetText(turned) end
        local have, need
        if type(turned) == "string" and not issecret(turned) then
            have, need = turned:match("(%d+)%s*/%s*(%d+)")
        end
        have, need = tonumber(have), tonumber(need)
        local icon = rawget(frame, "Icon")
        local c = (icon and icon.IsShown and icon:IsShown()) and DONE
            or ((have and need and need > 0) and progressColor(have / need) or LIGHT)
        text:SetTextColor(c[1], c[2], c[3])
    end
    for _, child in ipairs({ frame:GetChildren() }) do skinGameFrame(child, depth + 1) end
end

local function skinGame()
    local t = gameTracker()
    if not t or not M.db.reste then return end
    local header = rawget(t, "Header") -- « Tous les objectifs » : invisible et sans souris
    if type(header) == "table" and header.SetAlpha then
        header:SetAlpha(0)
        if header.EnableMouse then header:EnableMouse(false) end
    end
    hideGameQuests()
    skinGameFrame(t, 0)
end

-- Repli automatique -----------------------------------------------------------------------------

local function inGroupInstance()
    local inside, kind = _G.IsInInstance()
    return inside and (kind == "party" or kind == "raid")
end

local function updateAutoCollapse(inCombat)
    local want = (M.db.replierCombat and inCombat) or (M.db.replierDonjon and inGroupInstance())
    want = want and true or false
    if want ~= autoCollapsed then
        autoCollapsed = want
        requestRefresh()
    end
end

-- Construction ----------------------------------------------------------------------------------

local function build()
    if holder then return end
    holder = _G.CreateFrame("Frame", "CoeurUISuiviQuetes", _G.UIParent)
    holder:SetSize(M.db.largeur, 100)
    holder:SetFrameStrata("LOW")
    back = holder:CreateTexture(nil, "BACKGROUND")
    back:SetTexture(WHITE)
    back:SetAllPoints()

    scroll = _G.CreateFrame("ScrollFrame", nil, holder)
    scroll:SetPoint("TOPLEFT", PAD, -PAD)
    scroll:SetPoint("BOTTOMRIGHT", -PAD, PAD)
    content = _G.CreateFrame("Frame", nil, scroll)
    content:SetSize(M.db.largeur - 2 * PAD, 10)
    scroll:SetScrollChild(content)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        if not M.db.defilement then return end
        local offset = math.min(maxScroll(), math.max(0, self:GetVerticalScroll() - delta * 40))
        self:SetVerticalScroll(offset)
        updateSticky()
    end)

    -- Titre de zone fixé en haut pendant le défilement (même fond que le cadre, par-dessus la liste).
    sticky = _G.CreateFrame("Button", nil, holder)
    sticky:SetPoint("TOPLEFT", holder, "TOPLEFT", PAD, -PAD)
    sticky:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -PAD, -PAD)
    sticky:SetHeight(math.max(16, M.db.tailleTitres + 4))
    sticky:SetFrameLevel(scroll:GetFrameLevel() + 10)
    sticky.fill = sticky:CreateTexture(nil, "BACKGROUND")
    sticky.fill:SetTexture(WHITE)
    sticky.fill:SetPoint("TOPLEFT", -PAD, PAD)
    sticky.fill:SetPoint("BOTTOMRIGHT", PAD, -2)
    sticky.fill:SetVertexColor(C.fond[1], C.fond[2], C.fond[3], 0) -- pas de fond à lui
    setupZoneRow(sticky)
    sticky:Hide()

    -- Gardé par son coin haut droit : il grandit vers le bas.
    CUI:RegisterMover({ key = "suivi_quetes", frame = holder, label = "SQ_NOM", point = "TOPRIGHT",
                        default = { "TOPRIGHT", "TOPRIGHT", -30, -290 } })
    CUI:SetMoverPoint("suivi_quetes", "TOPRIGHT")

    -- Le suivi du jeu : il garde le reste, sous notre liste (ou caché).
    local t = gameTracker()
    if t then
        _G.hooksecurefunc(t, "SetPoint", function()
            if not placingGame and M.enabled then CUI:AfterCombat(placeGame) end
        end)
        if t.Update then
            _G.hooksecurefunc(t, "Update", function()
                if M.enabled then CUI:SafeCall(CUI:Tr("SQ_NOM"), skinGame) end
            end)
        end
        applyGameFonts()
        placeGame()
        skinGame()
    end
    layout()
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    CUI:AfterCombat(build)
    for _, event in ipairs({ "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED", "QUEST_ACCEPTED", "QUEST_REMOVED",
                             "QUEST_TURNED_IN", "ZONE_CHANGED_NEW_AREA", "UNIT_QUEST_LOG_CHANGED",
                             "BAG_UPDATE_COOLDOWN" }) do
        pcall(self.On, self, event, requestRefresh)
    end
    self:On("PLAYER_ENTERING_WORLD", function()
        requestRefresh()
        self:After(1, function() updateAutoCollapse(false) end)
    end)
    self:On("PLAYER_REGEN_DISABLED", function() updateAutoCollapse(true) end)
    self:On("PLAYER_REGEN_ENABLED", function() updateAutoCollapse(false) end)
    -- Le reste du suivi du jeu se met à jour souvent : habillage repassé régulièrement (léger).
    self:Every(0.5, function() if holder then skinGame() end end)
end

-- Coupé : tout reste en place jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged(key)
    if key == "largeur" or key == "reste" then CUI:AfterCombat(placeGame) end
    if key == "tailleTitres" or key == "tailleObjectifs" then applyGameFonts() end
    if key == "replierCombat" or key == "replierDonjon" then
        updateAutoCollapse(_G.InCombatLockdown())
    end
    if sticky then sticky:SetHeight(math.max(16, M.db.tailleTitres + 4)) end
    requestRefresh()
end

function M:OnFontChanged()
    applyGameFonts()
    requestRefresh()
end
