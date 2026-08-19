-- WoWbudilnik/options.lua - Окно настроек

local panel = CreateFrame("Frame", "WoWBudilnikOptionsPanel", UIParent)
panel.name = "WoWbudilnik"
InterfaceOptions_AddCategory(panel)

-- Заголовок
local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Будильник")

-- Функция сохранения (заглушка)
local function SaveDB()
end

-- Поле ввода времени
local timeBox = CreateFrame("EditBox", "WoWBudilnikTimeBox", panel, "InputBoxTemplate")
timeBox:SetSize(50, 20)
timeBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -40)
timeBox:SetAutoFocus(false)

_G[timeBox:GetName() .. "Text"]:SetText("Насколько завести:")

-- Выпадающий список (Секунды/Минуты/Часы)
local unitBox = CreateFrame("Button", "WoWBudilnikUnitBox", panel, "UIDropDownMenuTemplate")
unitBox:SetPoint("TOPLEFT", timeBox, "TOPRIGHT", 10, -5)

UIDropDownMenu_Initialize(unitBox, function(self)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Секунды"
    info.func = function() UIDropDownMenu_SetSelectedID(unitBox, 1) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Минуты"
    info.func = function() UIDropDownMenu_SetSelectedID(unitBox, 2) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Часы"
    info.func = function() UIDropDownMenu_SetSelectedID(unitBox, 3) end
    UIDropDownMenu_AddButton(info)
end)

UIDropDownMenu_SetWidth(unitBox, 80)
UIDropDownMenu_SetSelectedID(unitBox, 1)

-- Подсказка
local limitText = panel:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
limitText:SetPoint("TOPLEFT", timeBox, "BOTTOMLEFT", 0, -5)
limitText:SetText("(Максимум 600 минут или 10 часов)")

-- Чекбокс "В чате"
local chatCheck = CreateFrame("CheckButton", "WoWBudilnikChatCheck", panel, "OptionsCheckButtonTemplate")
chatCheck:SetPoint("TOPLEFT", limitText, "BOTTOMLEFT", 0, -15)
_G[chatCheck:GetName() .. "Text"]:SetText("Оповещение в чат")

-- Чекбокс "На экран"
local screenCheck = CreateFrame("CheckButton", "WoWBudilnikScreenCheck", panel, "OptionsCheckButtonTemplate")
screenCheck:SetPoint("TOPLEFT", chatCheck, "BOTTOMLEFT", 0, -5)
_G[screenCheck:GetName() .. "Text"]:SetText("Объявление на экране")

-- Выпадающий список звуков
local soundBox = CreateFrame("Button", "WoWBudilnikSoundBox", panel, "UIDropDownMenuTemplate")
soundBox:SetPoint("TOPLEFT", screenCheck, "BOTTOMLEFT", 0, -15)

UIDropDownMenu_Initialize(soundBox, function(self)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Стандартный звук"
    info.func = function() UIDropDownMenu_SetSelectedID(soundBox, 1) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Звук битвы"
    info.func = function() UIDropDownMenu_SetSelectedID(soundBox, 2) end
    UIDropDownMenu_AddButton(info)
end)

UIDropDownMenu_SetWidth(soundBox, 150)
UIDropDownMenu_SetSelectedID(soundBox, 1)

print("|cFFFFD100[WoWbudilnik]|r |cFF00FF00Окно настроек загружено.|r")
