-- Module « Discussion » (maquette validée le 27/11/2026) : la discussion du jeu (ChatFrame1..N),
-- habillée au style sobre de CœurUI. Le jeu garde tout (canaux, onglets, saisie, historique) ;
-- CœurUI change l'apparence et ajoute :
--   - style « Givre » (planche « Discussion » de la direction artistique) : panneau du thème sous les
--     messages (opacité réglable : fond et ombre s'éclaircissent, liseré net), saisie dans une case du
--     thème ; décor du jeu invisible ;
--   - onglets en petites capitales grises (l'ouvert en blanc souligné), pastille rouge cœur sur un
--     onglet qui reçoit un message ;
--   - canaux raccourcis ([G], [Gr], [R], [1. Général] sans la zone), heure en gris discret, noms en couleur de classe ;
--   - liens web soulignés : un clic ouvre la fenêtre « à copier » du noyau ;
--   - boutons du jeu (amis, canaux, menu, défilement) retirés ; toujours visibles, deux pictos au trait :
--     copier la discussion, descendre en bas ;
--   - vieux messages effacés au bout d'un temps réglable, de retour au survol.
-- La fenêtre se place avec le cadenas. Couper le module demande un /reload.
--
-- Rien n'est envoyé par l'addon (canaux publics protégés). Messages « secrets » (le jeu cache certains
-- textes en combat) : jamais lus ni modifiés, passés tels quels.
-- Fonctions du jeu jamais remplacées : filtres de messages (API du jeu), crochets et EventRegistry.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local issecret = _G.issecretvalue or function() return false end
local function known(v) return v ~= nil and not issecret(v) end

local HEURES = {
    { value = "aucune", text = "DI_HEURE_AUCUNE" },
    { value = "hm", text = "DI_HEURE_HM" },
    { value = "hms", text = "DI_HEURE_HMS" },
}

local M = CUI:RegisterModule({
    key = "Discussion",
    name = "DI_NOM",
    description = "DI_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = {
        largeur = 500, hauteur = 230, tailleTexte = 13, opaciteFond = 60,
        effacer = true, effacerApres = 60,
        canauxCourts = true, couleurClasse = true, liens = true, pastille = true, heure = "hm",
    },
    settings = {
        { type = "section", text = "DI_FENETRE" },
        { type = "slider", key = "largeur", label = "DI_LARGEUR", min = 300, max = 900, step = 10, format = "%d" },
        { type = "slider", key = "hauteur", label = "DI_HAUTEUR", min = 120, max = 600, step = 10, format = "%d",
          description = "DI_PLACE_NOTE" },
        { type = "slider", key = "tailleTexte", label = "DI_TAILLE", min = 9, max = 20, step = 1, format = "%d pt" },
        { type = "slider", key = "opaciteFond", label = "DI_OPACITE", min = 0, max = 100, step = 5, format = "%d %%" },
        { type = "section", text = "DI_EFFACEMENT" },
        { type = "toggle", key = "effacer", label = "DI_EFFACER", description = "DI_EFFACER_NOTE" },
        { type = "slider", key = "effacerApres", label = "DI_APRES", min = 10, max = 300, step = 10, format = "%d s",
          enabledIf = function(read) return read("effacer") end },
        { type = "column" },
        { type = "section", text = "DI_MESSAGES" },
        { type = "toggle", key = "canauxCourts", label = "DI_COURTS" },
        { type = "toggle", key = "couleurClasse", label = "DI_CLASSE" },
        { type = "toggle", key = "liens", label = "DI_LIENS" },
        { type = "toggle", key = "pastille", label = "DI_PASTILLE" },
        { type = "dropdown", key = "heure", label = "DI_HEURE", options = HEURES },
    },
})

local ICONES = CUI.MEDIA .. "Icones\\"
local GRIS_HEURE = "|cff6e727b"
local LIEN_COULEUR = "|cff8fb4e8"

local built = false
local hiddenParent
local holder, tools
local backs = {} -- panneau du thème de chaque fenêtre de discussion (Général, Journal de combat...)
local placing = false

local function hidden()
    if not hiddenParent then
        hiddenParent = _G.CreateFrame("Frame")
        hiddenParent:Hide()
    end
    return hiddenParent
end

-- Range un cadre du jeu dans le cadre invisible (il peut se montrer, on ne le voit plus).
local function stash(frame)
    if frame and frame.SetParent and not (frame.IsForbidden and frame:IsForbidden()) then
        frame:SetParent(hidden())
    end
end

-- Texture du jeu rendue invisible pour de bon (le jeu change son opacité au survol : sans image,
-- elle reste invisible).
local function clear(t)
    if t and t.SetTexture then
        t:SetTexture(nil)
        t:SetAlpha(0)
    end
end

local function eachChatFrame(fn)
    for i = 1, (_G.NUM_CHAT_WINDOWS or 10) do
        local cf = _G["ChatFrame" .. i]
        if cf then fn(cf, i) end
    end
end

-- Majuscules, accents compris (les onglets en petites capitales).
local ACCENTS = { ["é"] = "É", ["è"] = "È", ["ê"] = "Ê", ["ë"] = "Ë", ["à"] = "À", ["â"] = "Â", ["ä"] = "Ä",
                  ["î"] = "Î", ["ï"] = "Ï", ["ô"] = "Ô", ["ö"] = "Ö", ["ù"] = "Ù", ["û"] = "Û", ["ü"] = "Ü",
                  ["ç"] = "Ç", ["œ"] = "Œ" }
local function upper(s)
    s = s:upper()
    for low, up in pairs(ACCENTS) do s = s:gsub(low, up) end
    return s
end

-- Place et taille -------------------------------------------------------------------------------

local function place()
    local cf = _G.ChatFrame1
    if not cf or not holder then return end
    placing = true
    holder:SetSize(M.db.largeur, M.db.hauteur)
    -- Le jeu tient sa discussion à distance du bord de l'écran (marges de ses anciens boutons) : elle
    -- était poussée à côté de notre cadre. Sans ces marges, elle est exactement sur notre cadre.
    if cf.SetClampRectInsets then cf:SetClampRectInsets(0, 0, 0, 0) end
    cf:ClearAllPoints()
    cf:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    cf:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, 0)
    placing = false
end

local function paintOne(back)
    local a = M.db.opaciteFond / 100
    back:SetShown(a > 0)
    back:SetOpacity(a) -- fond et ombre selon le réglage, liseré net
end

-- Saisie : au repos, exactement le fond de la discussion (même panneau, même opacité) ; quand on
-- tape, une case sombre du thème pleine, pour bien lire.
local editBoxes = {}
local function paintEdit(eb)
    local p = eb.cuiPanel
    if not p then return end
    local typing = eb:HasFocus()
    local a = typing and 1 or M.db.opaciteFond / 100
    p:SetFillColor(typing and C.case or C.panneau)
    p:SetShown(typing or a > 0)
    p:SetOpacity(a)
end

local function paintBack()
    for _, back in ipairs(backs) do paintOne(back) end
    for _, eb in ipairs(editBoxes) do paintEdit(eb) end
end

-- Barre de filtres du Journal de combat (« Mes actions »...) : son fond noir du jeu devient invisible,
-- les filtres restent posés au-dessus des messages comme les onglets.
local function skinCombatBar()
    local bar = _G.CombatLogQuickButtonFrame_Custom
    if not bar or bar.cuiSkinned or (bar.IsForbidden and bar:IsForbidden()) then return end
    bar.cuiSkinned = true
    for _, region in ipairs({ bar:GetRegions() }) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then region:SetAlpha(0) end
    end
    local tex = _G.CombatLogQuickButtonFrame_CustomTexture
    if tex and tex.SetAlpha then tex:SetAlpha(0) end
end

-- Onglets ---------------------------------------------------------------------------------------

local function tabOf(cf)
    return cf and _G[cf:GetName() .. "Tab"]
end

local function tabText(tab)
    return tab.Text or _G[tab:GetName() .. "Text"]
end

local function paintTab(tab, selected)
    if not tab.cuiLine then return end
    local fs = tabText(tab)
    local c = selected and C.texte or C.texteSecondaire
    if fs then fs:SetTextColor(c[1], c[2], c[3]) end
    tab.cuiLine:SetShown(selected and true or false)
end

local function selectedFrame()
    return _G.SELECTED_CHAT_FRAME or _G.DEFAULT_CHAT_FRAME or _G.ChatFrame1
end

local function paintTabs()
    local current = selectedFrame()
    eachChatFrame(function(cf)
        local tab = tabOf(cf)
        if tab then paintTab(tab, cf == current) end
    end)
end

local function skinTab(tab)
    if not tab or tab.cuiLine then return end
    for _, region in ipairs({ tab:GetRegions() }) do
        if region:GetObjectType() == "Texture" then clear(region) end
    end
    for _, key in ipairs({ "glow", "Glow" }) do clear(tab[key]) end
    local fs = tabText(tab)
    if fs then
        fs:SetFont(CUI:GetFont(), 11, "")
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 0.9)
        local busy = false
        local function toUpper(self, text)
            if busy or type(text) ~= "string" or issecret(text) then return end
            busy = true
            self:SetText(upper(text))
            busy = false
        end
        _G.hooksecurefunc(fs, "SetText", toUpper)
        toUpper(fs, fs:GetText())
    end
    -- Onglet ouvert : trait blanc dessous.
    tab.cuiLine = tab:CreateTexture(nil, "OVERLAY")
    tab.cuiLine:SetColorTexture(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3], 1)
    tab.cuiLine:SetHeight(1)
    if fs then
        tab.cuiLine:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
        tab.cuiLine:SetPoint("TOPRIGHT", fs, "BOTTOMRIGHT", 0, -2)
    end
    tab.cuiLine:Hide()
    -- Pastille : un message est arrivé dans cet onglet.
    tab.cuiDot = tab:CreateTexture(nil, "OVERLAY")
    tab.cuiDot:SetTexture(CUI.MEDIA .. "Cercle")
    tab.cuiDot:SetVertexColor(C.coeur[1], C.coeur[2], C.coeur[3])
    tab.cuiDot:SetSize(6, 6)
    if fs then tab.cuiDot:SetPoint("LEFT", fs, "RIGHT", 4, 0) end
    tab.cuiDot:Hide()
    -- Le jeu rend les onglets à moitié transparents (ou invisibles) quand la souris n'est pas sur la
    -- discussion : ils restent bien lisibles (crochet seulement).
    local settingAlpha = false
    _G.hooksecurefunc(tab, "SetAlpha", function(self, alpha)
        if settingAlpha or not M.enabled or alpha == 1 then return end
        settingAlpha = true
        self:SetAlpha(1)
        settingAlpha = false
    end)
    tab:SetAlpha(1)
end

-- Fenêtres --------------------------------------------------------------------------------------

local FRAME_TEXTURES = { "Background", "TopLeftTexture", "BottomLeftTexture", "TopRightTexture", "BottomRightTexture",
                         "LeftTexture", "RightTexture", "BottomTexture", "TopTexture" }
local EDIT_TEXTURES = { "Left", "Mid", "Right", "FocusLeft", "FocusMid", "FocusRight" }

local function applyFont(cf)
    local _, _, flags = cf:GetFont()
    cf:SetFont(CUI:GetFont(), M.db.tailleTexte, flags or "")
    local eb = _G[cf:GetName() .. "EditBox"]
    if eb then
        eb:SetFont(CUI:GetFont(), M.db.tailleTexte, "")
        local header = eb.header or _G[eb:GetName() .. "Header"]
        if header then header:SetFont(CUI:GetFont(), M.db.tailleTexte, "") end
    end
end

local function applyFade(cf)
    if cf.SetFading then cf:SetFading(M.db.effacer) end
    if cf.SetTimeVisible then cf:SetTimeVisible(M.db.effacerApres) end
end

local placingEdit = false
local function placeEditBox(eb)
    if not holder then return end
    placingEdit = true
    eb:ClearAllPoints()
    -- Accrochée à la discussion elle-même (là où elle est vraiment), à la largeur de son fond.
    local cf = _G.ChatFrame1
    eb:SetPoint("TOPLEFT", cf, "BOTTOMLEFT", -6, -10)
    eb:SetPoint("TOPRIGHT", cf, "BOTTOMRIGHT", 6, -10)
    placingEdit = false
end

local function skinFrame(cf)
    if cf.cuiSkinned then return end
    cf.cuiSkinned = true
    -- Fond dessiné sur la fenêtre de discussion elle-même, tout au fond : toujours sous les messages
    -- (un cadre à part pouvait passer par-dessus). Panneau du thème, 6 points de marge autour du texte.
    -- Chaque fenêtre a le sien (le Journal de combat est une autre fenêtre que Général).
    local back = CUI:CreatePanel(cf, { inset = -6 })
    backs[#backs + 1] = back
    paintOne(back)
    local name = cf:GetName()
    for _, key in ipairs(_G.CHAT_FRAME_TEXTURES or FRAME_TEXTURES) do clear(_G[name .. key]) end
    clear(cf.Background)
    -- Boutons du jeu sur le côté (haut, bas, défilement) : retirés (nos pictos les remplacent).
    stash(_G[name .. "ButtonFrame"])
    stash(cf.buttonFrame)
    stash(cf.ScrollBar)
    stash(cf.ScrollToBottomButton)
    -- Zone de saisie.
    local eb = _G[name .. "EditBox"]
    if eb then
        for _, key in ipairs(EDIT_TEXTURES) do
            clear(_G[eb:GetName() .. key])
            clear(eb[key])
        end
        for _, key in ipairs({ "focusLeft", "focusMid", "focusRight" }) do clear(eb[key]) end
        eb.cuiPanel = CUI:CreatePanel(eb, { fill = C.panneau })
        editBoxes[#editBoxes + 1] = eb
        -- Tout autre décor du jeu sur la saisie (fonds en plusieurs morceaux, contour de la saisie
        -- active...) : retiré, aussi quand le jeu le remet en prenant la saisie.
        local own = {}
        for _, rect in ipairs({ eb.cuiPanel.border, eb.cuiPanel.ring, eb.cuiPanel.fill }) do
            for _, t in ipairs(rect.parts) do own[t] = true end
        end
        local function clearEdit(self)
            for _, region in ipairs({ self:GetRegions() }) do
                if not own[region] and region.GetObjectType and region:GetObjectType() == "Texture" then
                    clear(region)
                end
            end
            local nine = rawget(self, "NineSlice")
            if nine and nine.SetAlpha then nine:SetAlpha(0) end
        end
        clearEdit(eb)
        paintEdit(eb)
        eb:HookScript("OnEditFocusGained", function(self) clearEdit(self) paintEdit(self) end)
        eb:HookScript("OnEditFocusLost", paintEdit)
        eb:HookScript("OnShow", function(self) clearEdit(self) paintEdit(self) end)
        -- Juste sous la fenêtre, à la largeur de son fond (le jeu la décalait et l'élargissait).
        placeEditBox(eb)
        _G.hooksecurefunc(eb, "SetPoint", function(self)
            if not placingEdit and M.enabled then placeEditBox(self) end
        end)
    end
    skinTab(tabOf(cf))
    applyFont(cf)
    applyFade(cf)
end

local function skinAll()
    eachChatFrame(skinFrame)
    skinCombatBar()
    paintTabs()
end

-- Boutons du jeu hors des fenêtres (amis, canaux, voix, menu) : retirés.
local GAME_BUTTONS = { "ChatFrameMenuButton", "ChatFrameChannelButton", "ChatFrameToggleVoiceDeafenButton",
                       "ChatFrameToggleVoiceMuteButton", "QuickJoinToastButton", "TextToSpeechButtonFrame" }
local function stashButtons()
    for _, key in ipairs(GAME_BUTTONS) do stash(_G[key]) end
end

-- Canaux raccourcis -----------------------------------------------------------------------------

-- Textes du jeu « [Guilde] %s : » : le nom entre crochets remplacé par le court ; rendus quand
-- l'option est coupée.
local SHORT = {
    CHAT_GUILD_GET = "DI_C_GUILDE", CHAT_OFFICER_GET = "DI_C_OFFICIER",
    CHAT_PARTY_GET = "DI_C_GROUPE", CHAT_PARTY_LEADER_GET = "DI_C_GROUPE", CHAT_PARTY_GUIDE_GET = "DI_C_GROUPE",
    CHAT_RAID_GET = "DI_C_RAID", CHAT_RAID_LEADER_GET = "DI_C_RAID", CHAT_RAID_WARNING_GET = "DI_C_ALERTE",
    CHAT_INSTANCE_CHAT_GET = "DI_C_INSTANCE", CHAT_INSTANCE_CHAT_LEADER_GET = "DI_C_INSTANCE",
}
local originals = {}

local function applyShortNames()
    for global, key in pairs(SHORT) do
        local current = _G[global]
        if type(current) == "string" then
            if originals[global] == nil then originals[global] = current end
            if M.db.canauxCourts then
                _G[global] = originals[global]:gsub("%[.-%]", "[" .. L[key] .. "]", 1)
            else
                _G[global] = originals[global]
            end
        end
    end
end

-- Heure et couleurs de classe : réglages du jeu ------------------------------------------------

-- L'heure entre crochets, suivie d'un tiret : « [21:05] - ».
local FORMATS = { hm = "[%H:%M]", hms = "[%H:%M:%S]" }

-- Le format lu par la discussion : l'heure et ses crochets en gris, quelle que soit la couleur de la ligne.
-- Le jeu le réécrit sans couleur (réglage changé, chargement d'une zone...) : on repasse derrière lui,
-- et une vérification régulière le remet s'il a été perdu.
local function wantedFormat()
    local fmt = FORMATS[M.db.heure]
    return fmt and (GRIS_HEURE .. fmt .. " -|r ") or nil
end

local function setTimestampFormat()
    _G.CHAT_TIMESTAMP_FORMAT = wantedFormat()
end

-- Forever relit le réglage du jeu « showTimestamps » à chaque message (et non CHAT_TIMESTAMP_FORMAT) :
-- le format complet, couleur et tiret compris, y est écrit (rendu tel quel quand le module est coupé).
local function applyTimestamps()
    M:SetCVar("showTimestamps", wantedFormat() or "none")
    setTimestampFormat()
    _G.C_Timer.After(0.5, function() if M.enabled then setTimestampFormat() end end)
end

local function applyClassColors()
    if not (_G.C_CVar and _G.C_CVar.GetCVar("chatClassColorOverride") ~= nil) then return end
    if M.db.couleurClasse then
        M:SetCVar("chatClassColorOverride", "0")
    else
        M:RestoreCVar("chatClassColorOverride")
    end
end

-- Liens web -------------------------------------------------------------------------------------

local urls, nextUrl = {}, 0
local MAX_URLS = 300

local function keepUrl(url)
    nextUrl = nextUrl % MAX_URLS + 1
    urls[nextUrl] = url
    return LIEN_COULEUR .. "|Haddon:CoeurUI:url:" .. nextUrl .. "|h" .. url .. "|h|r"
end

local PATTERNS = {
    "https?://[%w%-%._~:/%?#%[%]@!%$&'%(%)%*%+,;=%%]+",
    "www%.[%w%-]+%.[%w%-%./%?=&_~#%%]+",
}

local function linkify(msg)
    -- Pas dans un lien déjà présent (objet, joueur...) : on ne touche qu'aux messages sans lien web.
    if msg:find("|Haddon:CoeurUI", 1, true) then return msg end
    for _, pattern in ipairs(PATTERNS) do
        if msg:find(pattern) then
            return (msg:gsub(pattern, keepUrl))
        end
    end
    return msg
end

local function showUrl(index)
    local url = urls[index]
    if not url then return end
    CUI:ShowCopyWindow({ title = L.DI_LIEN_TITRE, label = L.DI_LIEN_ADRESSE, text = url, hint = L.DI_LIEN_AIDE })
end

local lastClick = 0
local function onLinkClicked(link)
    if type(link) ~= "string" then return end
    local index = link:match("^addon:CoeurUI:url:(%d+)")
    if not index then return end
    local now = _G.GetTime()
    if now - lastClick < 0.2 then return end -- crochet et évènement pour le même clic
    lastClick = now
    showUrl(tonumber(index))
end

-- Filtres de messages (API du jeu) : liens web, canaux sans leur zone (« 1. Général - Elwynn » » « 1. Général »).
local function messageFilter(_, _, msg, ...)
    if not (M.enabled and M.db.liens and known(msg) and type(msg) == "string") then return false end
    local new = linkify(msg)
    if new == msg then return false end
    return false, new, ...
end

local function channelFilter(_, _, msg, author, a3, channel, ...)
    if not M.enabled then return false end
    local changed = false
    if M.db.liens and known(msg) and type(msg) == "string" then
        local new = linkify(msg)
        if new ~= msg then msg, changed = new, true end
    end
    if M.db.canauxCourts and known(channel) and type(channel) == "string" then
        -- « 1. Général - Forêt d'Elwynn » » « 1. Général ». Le jeu exige la forme « numéro. nom » (il
        -- la découpe pour l'afficher) et un nom plus long que celui du canal (sinon le message est
        -- jeté) : on garde les deux, on retire seulement la zone. Canaux de communauté : intouchés.
        local number, base = channel:match("^(%d+)%. (.-) %- ")
        if number and base ~= "" and not channel:find("Community:", 1, true) then
            channel, changed = number .. ". " .. base, true
        end
    end
    if not changed then return false end
    return false, msg, author, a3, channel, ...
end

local LINK_EVENTS = { "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
                      "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
                      "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
                      "CHAT_MSG_RAID_WARNING", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER" }

local function addFilters()
    local add = _G.ChatFrame_AddMessageEventFilter
        or (_G.ChatFrameUtil and _G.ChatFrameUtil.AddMessageEventFilter)
    if not add then return end
    for _, event in ipairs(LINK_EVENTS) do add(event, messageFilter) end
    add("CHAT_MSG_CHANNEL", channelFilter)
end

local function hookLinks()
    if _G.EventRegistry and _G.EventRegistry.RegisterCallback then
        _G.EventRegistry:RegisterCallback("SetItemRef", function(_, link) onLinkClicked(link) end, M)
    end
    if type(_G.SetItemRef) == "function" then
        _G.hooksecurefunc("SetItemRef", function(link) onLinkClicked(link) end)
    end
end

-- Copier la discussion --------------------------------------------------------------------------

local function plain(text)
    text = text:gsub("|T.-|t", "")
    text = text:gsub("|A.-|a", "")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text
end

local function copyChat()
    local cf = selectedFrame()
    if not (cf and cf.GetNumMessages and cf.GetMessageInfo) then return end
    local lines = {}
    local n = cf:GetNumMessages()
    for i = math.max(1, n - 199), n do
        local text = cf:GetMessageInfo(i)
        if known(text) and type(text) == "string" then lines[#lines + 1] = plain(text) end
    end
    if #lines == 0 then lines[1] = L.DI_COPIE_VIDE end
    local tab = tabOf(cf)
    local fs = tab and tabText(tab)
    local title = fs and fs:GetText()
    CUI:ShowCopyWindow({
        title = L.DI_COPIE_TITRE:format(known(title) and title or ""),
        label = L.DI_COPIE_ADRESSE, text = table.concat(lines, "\n"), hint = L.DI_COPIE_AIDE,
        multiline = true,
    })
end

local function createTool(icon, title, onClick)
    local b = _G.CreateFrame("Button", nil, tools)
    b:SetSize(18, 18)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    b.icon:SetTexture(ICONES .. icon)
    local function tint(c) b.icon:SetVertexColor(c[1], c[2], c[3]) end
    tint(C.texteSecondaire)
    b:SetScript("OnEnter", function(self)
        tint(C.texte)
        CUI:ShowTooltip(self, CUI:Tr(title))
    end)
    b:SetScript("OnLeave", function(self)
        tint(C.texteSecondaire)
        CUI:HideTooltip(self)
    end)
    b:SetScript("OnClick", onClick)
    return b
end

-- Survol : messages effacés de retour (les pictos, eux, restent toujours visibles).
local wasOver = false
local function onHoverTick()
    if not holder then return end
    -- La fenêtre et la bande au-dessus (onglets, pictos) : on peut aller de l'une aux autres.
    -- (IsMouseOver du cadre : la fonction globale MouseIsOver n'existe pas sur ce client.)
    local over = holder:IsMouseOver(34, 0, 0, 0)
    local entering = over and not wasOver
    wasOver = over
    -- Messages effacés : de retour une seule fois, quand la souris arrive. Les faire revenir en
    -- continu redessinait les lignes sans cesse : un clic sur un nom (appui puis relâche sur le même
    -- lien) n'aboutissait jamais.
    if entering and M.db.effacer then
        eachChatFrame(function(cf)
            if cf:IsVisible() and cf.ResetAllFadeTimes then cf:ResetAllFadeTimes() end
        end)
    end
end

-- Construction ----------------------------------------------------------------------------------

local function build()
    if built or not _G.ChatFrame1 then return end
    built = true
    holder = _G.CreateFrame("Frame", "CoeurUIDiscussion", _G.UIParent)
    holder:SetSize(M.db.largeur, M.db.hauteur)

    tools = _G.CreateFrame("Frame", nil, holder)
    tools:SetSize(46, 18)
    tools:SetPoint("BOTTOMRIGHT", holder, "TOPRIGHT", 0, 8)
    tools:SetFrameStrata("MEDIUM")
    local copy = createTool("Copier", "DI_COPIER", copyChat)
    copy:SetPoint("LEFT")
    local bottom = createTool("Bas", "DI_BAS", function()
        local cf = selectedFrame()
        if cf and cf.ScrollToBottom then cf:ScrollToBottom() end
    end)
    bottom:SetPoint("LEFT", copy, "RIGHT", 10, 0)

    -- Le jeu replace sa discussion (mode Édition, glisser...) : on la remet sur notre cadre.
    _G.hooksecurefunc(_G.ChatFrame1, "SetPoint", function()
        if not placing and M.enabled then place() end
    end)
    if type(_G.FCFTab_UpdateColors) == "function" then
        _G.hooksecurefunc("FCFTab_UpdateColors", function() if M.enabled then paintTabs() end end)
    end
    if type(_G.FCF_StartAlertFlash) == "function" then
        _G.hooksecurefunc("FCF_StartAlertFlash", function(cf)
            local tab = tabOf(cf)
            if M.enabled and M.db.pastille and tab and tab.cuiDot then tab.cuiDot:Show() end
        end)
    end
    if type(_G.FCF_StopAlertFlash) == "function" then
        _G.hooksecurefunc("FCF_StopAlertFlash", function(cf)
            local tab = tabOf(cf)
            if tab and tab.cuiDot then tab.cuiDot:Hide() end
        end)
    end

    CUI:RegisterMover({ key = "discussion", frame = holder, label = "DI_NOM",
                        default = { "BOTTOMLEFT", "BOTTOMLEFT", 24, 60 } })
    place()
    paintBack()
    stashButtons()
    skinAll()
    addFilters()
    hookLinks()
    applyShortNames()
    applyTimestamps()
    applyClassColors()
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    CUI:AfterCombat(build)
    -- Fenêtres ouvertes plus tard (nouvel onglet, murmure) : habillées au passage.
    self:Every(2, function()
        if not built then return end
        skinAll()
        local wanted = wantedFormat()
        if wanted and _G.CHAT_TIMESTAMP_FORMAT ~= wanted then setTimestampFormat() end
        local cvar = _G.C_CVar.GetCVar("showTimestamps")
        if (wanted or "none") ~= cvar and not _G.InCombatLockdown() then applyTimestamps() end
    end)
    self:Every(0.2, onHoverTick)
    self:On("CVAR_UPDATE", function()
        if built then _G.C_Timer.After(0, function() if M.enabled then setTimestampFormat() end end) end
    end)
end

-- Coupé : l'habillage reste jusqu'au /reload (needsReload) ; les réglages du jeu sont rendus.
function M:OnDisable()
end

function M:OnSettingChanged(key)
    if not built then return end
    if key == "largeur" or key == "hauteur" then
        place()
    elseif key == "tailleTexte" then
        eachChatFrame(applyFont)
    elseif key == "opaciteFond" then
        paintBack()
    elseif key == "effacer" or key == "effacerApres" then
        eachChatFrame(applyFade)
    elseif key == "canauxCourts" then
        applyShortNames()
    elseif key == "heure" then
        applyTimestamps()
    elseif key == "couleurClasse" then
        applyClassColors()
    elseif key == "pastille" and not M.db.pastille then
        eachChatFrame(function(cf)
            local tab = tabOf(cf)
            if tab and tab.cuiDot then tab.cuiDot:Hide() end
        end)
    end
end

function M:OnFontChanged()
    if not built then return end
    eachChatFrame(applyFont)
    eachChatFrame(function(cf)
        local tab = tabOf(cf)
        local fs = tab and tabText(tab)
        if fs then fs:SetFont(CUI:GetFont(), 11, "") end
    end)
end
