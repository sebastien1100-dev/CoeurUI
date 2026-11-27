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
-- Étape 3 (finitions, réglables) : nombre de quêtes en tête (« Quêtes · 19 / 25 », « – » replie tout) ;
-- distance à droite du titre ; quête suivie sur la carte (clic sur la pastille) en évidence ; quêtes à
-- rendre au-delà d'un nombre regroupées sous une ligne qui se déplie.
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
        afficherNombre = true, distance = true, superSuivi = true, regrouper = 2,
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
        { type = "section", text = "SQ_AFFICHAGE" },
        { type = "toggle", key = "afficherNombre", label = "SQ_AFFICHER_NOMBRE" },
        { type = "toggle", key = "distance", label = "SQ_AFFICHER_DISTANCE" },
        { type = "toggle", key = "superSuivi", label = "SQ_SUPER_SUIVI", description = "SQ_SUPER_SUIVI_NOTE" },
        { type = "slider", key = "regrouper", label = "SQ_REGROUPER", min = 0, max = 10, step = 1, format = "%d",
          description = "SQ_REGROUPER_NOTE" },
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
local HEAD = 24     -- barre du nombre de quêtes
local DIST = 46     -- place de la distance
local MARGIN = 5    -- marge gauche de la liste (le surlignage de la quête suivie et son anneau y débordent)

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
    -- Parenthèses restées vides (« Vermine kobold () ») : retirées aussi.
    s = s:gsub("%(%s*%)", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+:", " :")
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

-- Sorte de quête en petit picto au trait (élite, donjon, raid, groupe) à la place de « (Élite) »... ;
-- les autres sortes gardent leur nom entre parenthèses.
local TAG_DUNGEON = { [81] = true }               -- Enum.QuestTag.Dungeon
local TAG_RAID = { [62] = true, [88] = true, [89] = true }
local TAG_GROUP = { [1] = true }
local function tagIconOf(t)
    local id, name = t.tagID, t.tagName
    -- Élite d'abord : sur certains clients, une quête élite porte le numéro de « groupe ».
    if (known(t.isElite) and t.isElite) or (known(name) and _G.ELITE and name == _G.ELITE) then
        return "TagElite"
    end
    if known(id) then
        if TAG_DUNGEON[id] then return "TagDonjon" end
        if TAG_RAID[id] then return "TagRaid" end
        if TAG_GROUP[id] then return "TagGroupe" end
    end
end

-- Picto dans un texte : 12 points, gris clair.
local function inlineIcon(icon, size)
    local c = LIGHT
    return ("|T%sIcones\\%s:%d:%d:0:0:64:64:0:64:0:64:%d:%d:%d|t"):format(CUI.MEDIA, icon, size, size,
        math.floor(c[1] * 255), math.floor(c[2] * 255), math.floor(c[3] * 255))
end

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
                local tag, tagIcon
                if QL.GetQuestTagInfo then
                    local ok, t = pcall(QL.GetQuestTagInfo, id)
                    if ok and t then
                        tagIcon = tagIconOf(t)
                        if not tagIcon and known(t.tagName) then tag = t.tagName end
                    end
                end
                -- Quête de groupe : le nombre conseillé après son picto.
                local groupSize = known(info.suggestedGroup) and info.suggestedGroup or 0
                local q = {
                    id = id, title = info.title, level = info.level, tag = tag, tagIcon = tagIcon,
                    groupSize = groupSize, logIndex = i,
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

-- Quête suivie sur la carte (super-suivi) et distance ------------------------------------------------

local function superTracked()
    local ST = _G.C_SuperTrack
    local id = ST and ST.GetSuperTrackedQuestID and ST.GetSuperTrackedQuestID()
    return known(id) and id or nil
end

-- Clic sur la pastille : cette quête suivie sur la carte ; déjà suivie : plus aucune.
local function toggleSuperTrack(id)
    local ST = _G.C_SuperTrack
    if not (ST and ST.SetSuperTrackedQuestID) then return end
    ST.SetSuperTrackedQuestID(superTracked() == id and 0 or id)
end

-- « 120 m » (le jeu compte en mètres sur Forever) ; vide quand il ne sait pas.
local function distanceText(id)
    local QL = _G.C_QuestLog
    if not (QL and QL.GetDistanceSqToQuest) then return "" end
    local ok, sq, onContinent = pcall(QL.GetDistanceSqToQuest, id)
    if not ok or not known(sq) or not sq or sq <= 0 or (known(onContinent) and onContinent == false) then return "" end
    return L.SQ_DISTANCE:format(math.floor(math.sqrt(sq) + 0.5))
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

local holder, scroll, content, back, sticky, head
local allCollapsed = false -- « – » de la barre du haut : tout replié
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
    -- Fond plus clair et anneau blanc autour de la pastille : la quête suivie sur la carte.
    row.trackBg = row:CreateTexture(nil, "BACKGROUND", nil, -1)
    row.trackBg:SetTexture(WHITE)
    row.trackBg:SetPoint("TOPLEFT", -4, 2)
    row.trackBg:SetPoint("BOTTOMRIGHT", 4, -2)
    row.trackBg:SetVertexColor(1, 1, 1, 0.07)
    row.trackBg:Hide()
    row.ring = row:CreateTexture(nil, "ARTWORK", nil, 1)
    row.ring:SetTexture(CUI.MEDIA .. "Cercle")
    row.ring:SetSize(18, 18)
    row.ring:SetPoint("TOPLEFT", -2, 2)
    row.ring:SetVertexColor(C.texte[1], C.texte[2], C.texte[3], 1)
    row.ring:Hide()
    row.badge = row:CreateTexture(nil, "ARTWORK", nil, 2)
    row.badge:SetSize(14, 14)
    row.badge:SetPoint("TOPLEFT", 0, 0)
    -- Clic sur la pastille : quête suivie sur la carte (réglage).
    row.badgeButton = _G.CreateFrame("Button", nil, row)
    row.badgeButton:SetSize(16, 16)
    row.badgeButton:SetPoint("TOPLEFT", -1, 1)
    row.badgeButton:SetScript("OnClick", function()
        if row.questID and M.db.superSuivi then toggleSuperTrack(row.questID) end
    end)
    row.badgeButton:SetScript("OnEnter", function(self)
        if M.db.superSuivi then CUI:ShowTooltip(self, L.SQ_SUPER_SUIVI_AIDE) end
    end)
    row.badgeButton:SetScript("OnLeave", function(self) CUI:HideTooltip(self) end)
    row.dist = newText(row, 11)
    row.dist:SetJustifyH("RIGHT")
    row.dist:SetTextColor(0.54, 0.55, 0.58)
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

-- Ligne « N autres quêtes à rendre » (regroupement, réglage) : se déplie d'un clic.
local foldRows = {}
local foldOpen = {} -- zone -> true : dépliée (le temps de la session)

local function foldRow(i)
    local row = foldRows[i]
    if row then return row end
    row = _G.CreateFrame("Button", nil, content)
    row.chevron = row:CreateTexture(nil, "OVERLAY")
    row.chevron:SetTexture(CUI.MEDIA .. "Icones\\Chevron")
    row.chevron:SetSize(9, 9)
    row.chevron:SetPoint("LEFT", INDENT, 0)
    row.chevron:SetVertexColor(LIGHT[1], LIGHT[2], LIGHT[3])
    row.text = newText(row, 11)
    row.text:SetPoint("LEFT", row.chevron, "RIGHT", 5, 0)
    row.text:SetJustifyV("MIDDLE")
    row.text:SetTextColor(LIGHT[1], LIGHT[2], LIGHT[3])
    row:SetScript("OnClick", function(self)
        foldOpen[self.key] = not foldOpen[self.key] or nil
        requestRefresh()
    end)
    foldRows[i] = row
    return row
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
    content:SetWidth(width + MARGIN)
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
    local fi = 0
    local tracked = s.superSuivi and superTracked() or nil
    local function drawQuest(q)
        qi = qi + 1
        local row = questRow(qi)
        row.questID = q.id
        row.badge:SetTexture(q.complete and "Interface\\GossipFrame\\ActiveQuestIcon"
            or "Interface\\GossipFrame\\AvailableQuestIcon")
        row.title:SetFont(CUI:GetFont(), titleSize, "")
        -- Objet de quête à droite : le texte lui laisse la place.
        local itemRoom = setQuestItem(row, q) and (ITEM + 4) or 0
        -- Distance à droite du titre (avant l'objet de quête).
        local distRoom = s.distance and DIST or 0
        row.dist:SetFont(CUI:GetFont(), math.max(9, lineSize - 1), "")
        row.dist:ClearAllPoints()
        row.dist:SetPoint("TOPRIGHT", row, "TOPRIGHT", -itemRoom, -1)
        row.dist:SetText(s.distance and distanceText(q.id) or "")
        row.dist:SetShown(s.distance)
        -- Quête suivie sur la carte : fond plus clair, anneau blanc.
        local isTracked = tracked ~= nil and tracked == q.id
        row.trackBg:SetShown(isTracked)
        row.ring:SetShown(isTracked)
        row.title:SetWidth(width - INDENT - itemRoom - distRoom)
        local level = known(q.level) and q.level > 0 and ("[" .. q.level .. "] ") or ""
        local tag = q.tag and (" |cff9a9da5(" .. q.tag .. ")|r") or ""
        if q.tagIcon then
            tag = " " .. inlineIcon(q.tagIcon, titleSize)
            if q.tagIcon == "TagGroupe" and q.groupSize > 1 then tag = tag .. "|cff9a9da5" .. q.groupSize .. "|r" end
        end
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
            line.mark:SetPoint("TOPLEFT", content, "TOPLEFT", MARGIN + INDENT, -y)
            line.text:ClearAllPoints()
            line.text:SetPoint("TOPLEFT", content, "TOPLEFT", MARGIN + INDENT + lineSize, -y)
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
        row:SetPoint("TOPLEFT", content, "TOPLEFT", MARGIN, -top)
        row:SetSize(width, math.max(y - top, itemRoom > 0 and ITEM or 0))
        y = math.max(y, top + (itemRoom > 0 and ITEM or 0))
        row:Show()
        placedItems[#placedItems + 1] = { a = row, top = top }
        y = y + 6
    end
    for _, zone in ipairs(zones) do
        local open = not autoCollapsed and not allCollapsed and (zone.zone == nil or isOpen(zone))
        if zone.zone then
            zi = zi + 1
            local row = zoneRow(zi, content)
            row:SetSize(width, math.max(16, titleSize + 4))
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", MARGIN, -y)
            paintZoneRow(row, zone, open)
            row:Show()
            placedZones[#placedZones + 1] = { zone = zone, open = open, top = y }
            placedItems[#placedItems + 1] = { a = row, top = y }
            y = y + row:GetHeight() + 4
        end
        if open then
            -- Quêtes à rendre au-delà du nombre réglé : sous une ligne repliable, en fin de zone.
            local shownDone, hidden = 0, {}
            for _, q in ipairs(zone.quests) do
                if q.complete and s.regrouper > 0 and shownDone >= s.regrouper then
                    hidden[#hidden + 1] = q
                else
                    if q.complete then shownDone = shownDone + 1 end
                    drawQuest(q)
                end
            end
            if #hidden > 0 then
                fi = fi + 1
                local key = zone.zone or ""
                local row = foldRow(fi)
                row.key = key
                row:SetSize(width, math.max(14, lineSize + 4))
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", content, "TOPLEFT", MARGIN, -y)
                row.text:SetFont(CUI:GetFont(), lineSize, "")
                row.text:SetText(L.SQ_AUTRES_A_RENDRE:format(#hidden))
                row.chevron:SetRotation(foldOpen[key] and 0 or (math.pi / 2))
                row:Show()
                placedItems[#placedItems + 1] = { a = row, top = y }
                y = y + row:GetHeight() + 4
                if foldOpen[key] then
                    for _, q in ipairs(hidden) do drawQuest(q) end
                end
            end
        end
        y = y + 2
    end
    hideFrom(zoneRows, zi + 1)
    hideFrom(questRows, qi + 1)
    hideFrom(lineRows, li + 1)
    hideFrom(foldRows, fi + 1)
    contentHeight = math.max(1, y)
    content:SetHeight(contentHeight)

    -- Barre du haut : « Quêtes · suivies / dans le journal » et « – » (réglage).
    local headH = s.afficherNombre and HEAD or 0
    head:SetShown(s.afficherNombre)
    if s.afficherNombre then
        local QL = _G.C_QuestLog
        local watchedCount = QL.GetNumQuestWatches and QL.GetNumQuestWatches() or 0
        local _, inLog = QL.GetNumQuestLogEntries()
        local maxQuests = QL.GetMaxNumQuestsCanAccept and QL.GetMaxNumQuestsCanAccept() or 25
        head.text:SetFont(CUI:GetFont(), math.max(9, s.tailleTitres), "")
        -- « Quêtes · 19/40 » (journal sur le maximum) ; « · 17 suivies » seulement si toutes ne le sont pas.
        inLog = known(inLog) and inLog or 0
        local text = L.SQ_NOMBRE:format(inLog, known(maxQuests) and maxQuests or 25)
        if known(watchedCount) and watchedCount < inLog then
            text = text .. L.SQ_NOMBRE_SUIVIES:format(watchedCount)
        end
        head.text:SetText(text)
        head.toggle:SetText(allCollapsed and "+" or "–")
    end
    scroll:SetPoint("TOPLEFT", PAD - MARGIN, -(PAD + headH))
    sticky:SetPoint("TOPLEFT", holder, "TOPLEFT", PAD, -(PAD + headH))
    sticky:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -PAD, -(PAD + headH))

    -- Le cadre suit sa liste jusqu'à la hauteur maximale (il grandit vers le bas), puis défile.
    local maxH = s.defilement and s.hauteur or math.huge
    local visible = math.min(contentHeight, maxH)
    holder:SetSize(s.largeur, visible + 2 * PAD + headH)
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
    scroll:SetPoint("TOPLEFT", PAD - MARGIN, -PAD)
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

    -- Barre du haut : nombre de quêtes, « – » qui replie tout (ou « + » qui déplie).
    head = _G.CreateFrame("Frame", nil, holder)
    head:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    head:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
    head:SetHeight(HEAD + PAD - 4)
    head.text = newText(head, 13)
    head.text:SetPoint("LEFT", PAD + 2, -2)
    head.text:SetJustifyV("MIDDLE")
    head.text:SetTextColor(GREY[1], GREY[2], GREY[3])
    head.line = head:CreateTexture(nil, "ARTWORK")
    head.line:SetTexture(WHITE)
    head.line:SetHeight(1)
    head.line:SetPoint("BOTTOMLEFT", 1, 0)
    head.line:SetPoint("BOTTOMRIGHT", -1, 0)
    head.line:SetVertexColor(C.bordureDiscrete[1], C.bordureDiscrete[2], C.bordureDiscrete[3], 0.6)
    local toggle = _G.CreateFrame("Button", nil, head)
    toggle:SetSize(20, 20)
    toggle:SetPoint("RIGHT", -PAD + 2, -2)
    head.toggle = toggle:CreateFontString(nil, "OVERLAY")
    head.toggle:SetFont(CUI:GetFont(), 15, "")
    head.toggle:SetPoint("CENTER")
    head.toggle:SetTextColor(C.or_[1], C.or_[2], C.or_[3])
    toggle:SetScript("OnClick", function()
        allCollapsed = not allCollapsed
        requestRefresh()
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
    pcall(self.On, self, "SUPER_TRACKING_CHANGED", requestRefresh)
    -- Distance : relue chaque seconde, sans redessiner la liste.
    self:Every(1, function()
        if not (holder and M.db.distance and holder:IsShown()) then return end
        for _, row in ipairs(questRows) do
            if row:IsShown() and row.questID then row.dist:SetText(distanceText(row.questID)) end
        end
    end)
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
