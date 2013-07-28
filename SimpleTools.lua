--[[
	SimpleTools

	author: scottcreynolds

  simple set of tools to make the UI function nicer
--]]

SLASH_SIMPLERELOAD1, SLASH_SIMPLERELOAD2 = "/rl", "/srl"
SLASH_SIMPLEGRID1, SLASH_SIMPLEGRID2 = "/ag", "/alignment"

local f = CreateFrame("frame")
local sgrid
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("MERCHANT_SHOW")

function f:ADDON_LOADED(event, addon)
	if addon:lower() ~= "simpletools" then return end
	SetBasics()
end

function f:MERCHANT_SHOW(event, addon)
  repairCost, canRepair = GetRepairAllCost()
  if (canRepair==1) then
    RepairAllItems(1)
    secondaryRepairCost, x = GetRepairAllCost()
    if (secondaryRepairCost <= GetMoney()) then
      RepairAllItems(0)
    end
    ChatMessage("Your items have been repaired for "..GetCoinTextureString(repairCost).." ("..GetCoinTextureString(secondaryRepairCost).." personal).")
  end

  SellGrays()
end

SlashCmdList["SIMPLERELOAD"] = function()
  ReloadUI()
end

SlashCmdList["SIMPLEGRID"] = function()
  if sgrid then
    sgrid:Hide()
    sgrid = nil
  else
    sgrid = CreateFrame("frame", nil, UIParent)
    sgrid:SetAllPoints(UIParent)
    w = GetScreenWidth() / 64
    h = GetScreenHeight() / 36
    for i = 0, 64 do
      t = sgrid:CreateTexture(nil, 'BACKGROUND')
      if i == 32 then
        t:SetTexture(1,0,0,0.5)
      else
        t:SetTexture(0,0,0,0.5)
      end
			t:SetPoint('TOPLEFT', sgrid, 'TOPLEFT', i * w - 1, 0)
			t:SetPoint('BOTTOMRIGHT', sgrid, 'BOTTOMLEFT', i * w + 1, 0)
    end
    for i = 0, 32 do
      t = sgrid:CreateTexture(nil, 'BACKGROUND')
      if i == 18 then
        t:SetTexture(1,0,0,0.5)
      else
        t:SetTexture(0,0,0,0.5)
      end
			t:SetPoint('TOPLEFT', sgrid, 'TOPLEFT', 0, -i * h + 1)
			t:SetPoint('BOTTOMRIGHT', sgrid, 'TOPRIGHT', 0, -i * h - 1)
    end
  end
end

function SellGrays()
  gain = 0
  solditems = false
  for bag = 0, 4, 1 do
    for slot = 1, GetContainerNumSlots(bag), 1 do
      item = GetContainerItemLink(bag, slot)
      if item and string.find(item, "ff9d9d9d") then
        itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
        itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item)
        gain = gain + itemSellPrice
        UseContainerItem(bag, slot)
        solditems = true
      end
    end
  end
  if solditems then
    ChatMessage("Sold grays for "..GetCoinTextureString(gain))
  end
end
function SetBasics()
  ChatMessage("SimpleTools!");
end

function ChatMessage(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg);
end
