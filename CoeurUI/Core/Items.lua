-- Petites fonctions d'accès aux sacs et aux objets (CLAUDE.md : passer par les espaces C_Container,
-- C_Item... et garder ces accès dans le noyau). Chaque fonction rend nil si le client ne la connaît pas.
local _, CUI = ...

local function container() return _G.C_Container end
local function item() return _G.C_Item end

-- Nombre de cases d'un sac (0 : sac à dos ; 1 à 4 : sacs équipés).
function CUI:BagSlots(bag)
    local CC = container()
    return CC and CC.GetContainerNumSlots and CC.GetContainerNumSlots(bag) or 0
end

-- Contenu d'une case : table du jeu (iconFileID, stackCount, isLocked, quality, hyperlink, itemID...) ou nil.
function CUI:BagItem(bag, slot)
    local CC = container()
    return CC and CC.GetContainerItemInfo and CC.GetContainerItemInfo(bag, slot) or nil
end

-- Places libres d'un sac et sa famille (0 : sac ordinaire ; sinon sac de composants, carquois...).
function CUI:BagFree(bag)
    local CC = container()
    if not (CC and CC.GetContainerNumFreeSlots) then return 0, 0 end
    local free, family = CC.GetContainerNumFreeSlots(bag)
    return free or 0, family or 0
end

function CUI:BagName(bag)
    local CC = container()
    return CC and CC.GetBagName and CC.GetBagName(bag) or nil
end

-- Recharge d'un objet dans un sac : début, durée, actif.
function CUI:BagCooldown(bag, slot)
    local CC = container()
    if not (CC and CC.GetContainerItemCooldown) then return 0, 0, 0 end
    return CC.GetContainerItemCooldown(bag, slot)
end

-- Emplacement d'équipement d'un sac (pour son icône, le prendre ou en poser un).
function CUI:BagInventorySlot(bag)
    local CC = container()
    return CC and CC.ContainerIDToInventoryID and CC.ContainerIDToInventoryID(bag) or nil
end

-- Infos immédiates d'un objet : classe (Enum.ItemClass), emplacement d'équipement.
function CUI:ItemInstant(linkOrID)
    local CI = item()
    if not (CI and CI.GetItemInfoInstant) or linkOrID == nil then return nil end
    local itemID, _, _, equipLoc, _, classID, subclassID = CI.GetItemInfoInstant(linkOrID)
    return itemID, classID, subclassID, equipLoc
end

-- Prix de vente d'un objet chez un marchand (une unité, en pièces de cuivre) ; nil si inconnu.
function CUI:ItemSellPrice(linkOrID)
    local CI = item()
    if not (CI and CI.GetItemInfo) or linkOrID == nil then return nil end
    local ok, price = pcall(function() return select(11, CI.GetItemInfo(linkOrID)) end)
    return ok and price or nil
end

-- Utiliser une case d'un sac (chez un marchand : la vendre).
function CUI:BagUse(bag, slot)
    local CC = container()
    if CC and CC.UseContainerItem then CC.UseContainerItem(bag, slot) end
end

-- Niveau d'objet (celui affiché par le jeu).
function CUI:ItemLevel(link)
    local CI = item()
    if not (CI and CI.GetDetailedItemLevelInfo) or link == nil then return nil end
    return CI.GetDetailedItemLevelInfo(link)
end

-- Couleur d'une qualité d'objet { r, g, b } (gris, blanc, vert, bleu, violet...).
function CUI:ItemQualityColor(quality)
    local CI = item()
    if CI and CI.GetItemQualityColor then
        local r, g, b = CI.GetItemQualityColor(quality)
        if r then return { r, g, b } end
    end
    local c = _G.ITEM_QUALITY_COLORS and _G.ITEM_QUALITY_COLORS[quality]
    if c then return { c.r, c.g, c.b } end
end

-- Infobulle du jeu (objets, sacs) : propriétaire posé, contenu rempli par fill(GameTooltip).
-- Son habillage est celui du module « Tooltips » quand il est actif.
function CUI:ShowGameTooltip(owner, fill, anchor)
    local tip = _G.GameTooltip
    tip:SetOwner(owner, anchor or "ANCHOR_RIGHT")
    fill(tip)
    tip:Show()
end

function CUI:HideGameTooltip(owner)
    local tip = _G.GameTooltip
    if tip:IsOwned(owner) then tip:Hide() end
end
