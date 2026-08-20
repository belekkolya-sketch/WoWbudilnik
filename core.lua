-- WoWbudilnik/core.lua — полный, по ТЗ

if not WoWbudilnikDB then
    WoWbudilnikDB = { x = 0, y = 0, sound = 1, mode = 1 }
end

local ICON_PATH = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local MAX_MINUTES = 600 -- максимум 600 минут или 10 часов

-- =======================================================
-- ПРОСТОЙ ТАЙМЕР ДЛЯ 3.3.5
-- =======================================================
local function DelayedCall(delay, func)
    local elapsed = 0
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(self, el)
        elapsed = elapsed + el
        if elapsed >= delay then
            self:Hide()
            func()
        end
    end)
end

-- =======================================================
-- СРАБАТЫВАНИЕ
-- =======================================================
local function AlarmTriggered()
    if WoWbudilnikDB.mode == 1 then
        print("|cFFFFD100[Будильник]|r |cFFFFFF00ВРЕМЯ ВЫШЛО!|r")
    else
        RaidNotice_AddMessage(RaidWarningFrame, "|cFFFF0000[Будильник] ВРЕМЯ ПРИШЛО!|r", { r = 1, g = 0, b = 0 })
    end

    if WoWbudilnikDB.sound == 1 then
        PlaySoundFile("Interface\\AddOns\\WoWbudilnik\\alarm.mp3")
    else
        PlaySoundFile("Interface\\AddOns\\WoWbudilnik\\battle.mp3")
    end
end

-- =======================================================
-- ОКНО БУДИЛЬНИКА
-- =======================================================
local frame = CreateFrame("Frame", "WoWBudilnikFrame", UIParent)
frame:SetSize(280, 250)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
frame:Hide()

frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)
frame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
end)

-- Заголовок
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("Будильник")

-- Текст про выбор времени
local timeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
timeLabel:SetPoint("TOPLEFT", 16, -46)
timeLabel:SetText("Выберите единицу времени:")

-- Дропдаун единиц
local unitBox = CreateFrame("Button", "WoWBudilnikUnitBox", frame, "UIDropDownMenuTemplate")
unitBox:SetPoint("TOPLEFT", timeLabel, "BOTTOMLEFT", 0, -5)
UIDropDownMenu_Initialize(unitBox, function(self)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Минуты"
    info.func = function() WoWbudilnikDB.unit = 1; UIDropDownMenu_SetText(unitBox, "Минуты") end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Часы"
    info.func = function() WoWbudilnikDB.unit = 2; UIDropDownMenu_SetText(unitBox, "Часы") end
    UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetWidth(unitBox, 100)
UIDropDownMenu_SetText(unitBox, "Минуты")
WoWbudilnikDB.unit = 1

-- Поле ввода
local inputBox = CreateFrame("EditBox", "WoWBudilnikInput", frame, "InputBoxTemplate")
inputBox:SetSize(80, 24)
inputBox:SetPoint("TOPLEFT", unitBox, "TOPRIGHT", 12, -2)
inputBox:SetAutoFocus(false)
inputBox:SetText("60")

_G[inputBox:GetName() .. "Text"]:SetText("Время:")

-- Подсказка
local limitText = frame:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
limitText:SetPoint("TOPLEFT", unitBox, "BOTTOMLEFT", 0, -8)
limitText:SetText("(Максимум 600 минут или 10 часов)")

-- Тип оповещения
local modeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
modeLabel:SetPoint("TOPLEFT", limitText, "BOTTOMLEFT", 0, -8)
modeLabel:SetText("Тип оповещения:")

local modeBox = CreateFrame("Button", "WoWBudilnikModeBox", frame, "UIDropDownMenuTemplate")
modeBox:SetPoint("TOPLEFT", modeLabel, "BOTTOMLEFT", 0, -5)

UIDropDownMenu_Initialize(modeBox, function(self)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "В чат"
    info.func = function() WoWbudilnikDB.mode = 1; UIDropDownMenu_SetText(modeBox, "В чат") end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Объявление рейду"
    info.func = function() WoWbudilnikDB.mode = 2; UIDropDownMenu_SetText(modeBox, "Объявление рейду") end
    UIDropDownMenu_AddButton(info)
end)

UIDropDownMenu_SetWidth(modeBox, 150)
UIDropDownMenu_SetText(modeBox, "В чат")
WoWbudilnikDB.mode = 1

-- Звук
local soundLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
soundLabel:SetPoint("TOPLEFT", modeBox, "BOTTOMLEFT", 0, -8)
soundLabel:SetText("Звук оповещения:")

local soundBox = CreateFrame("Button", "WoWBudilnikSoundBox", frame, "UIDropDownMenuTemplate")
soundBox:SetPoint("TOPLEFT", soundLabel, "BOTTOMLEFT", 0, -5)

UIDropDownMenu_Initialize(soundBox, function(self)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Стандартный звук"
    info.func = function() WoWbudilnikDB.sound = 1; UIDropDownMenu_SetText(soundBox, "Стандартный звук") end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Звук битвы"
    info.func = function() WoWbudilnikDB.sound = 2; UIDropDownMenu_SetText(soundBox, "Звук битвы") end
    UIDropDownMenu_AddButton(info)
end)

UIDropDownMenu_SetWidth(soundBox, 150)
UIDropDownMenu_SetText(soundBox, "Стандартный звук")
WoWbudilnikDB.sound = 1

-- Кнопка "Завести"
local startBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
startBtn:SetSize(120, 24)
startBtn:SetPoint("BOTTOM", 0, 14)
startBtn:SetText("Завести")

startBtn:SetScript("OnClick", function()
    local value = tonumber(inputBox:GetText())

    if not value or value <= 0 then
        print("|cFFFF0000[Будильник] Введите число больше нуля!|r")
        return
    end

    local seconds
    if WoWbudilnikDB.unit == 1 then
        seconds = value * 60
        if value > 600 then
            print("|cFFFF0000[Будильник] Максимум 600 минут!|r")
            return
        end
    else
        seconds = value * 3600
        if value > 10 then
            print("|cFFFF0000[Будильник] Максимум 10 часов!|r")
            return
        end
    end

    print(string.format("|cFF00FF00[Будильник] Заведён на %d %s.|r", value, WoWbudilnikDB.unit == 1 and "мин." or "ч."))
    frame:Hide()
    DelayedCall(seconds, AlarmTriggered)
end)

-- =======================================================
-- КНОПКА-ИКОНКА
-- =======================================================
local btn = CreateFrame("Button", "WoWBudilnikButton", UIParent)
btn:SetSize(50, 50)
btn:SetNormalTexture(ICON_PATH)
btn:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
btn:SetPoint("CENTER", UIParent, "CENTER", WoWbudilnikDB.x, WoWbudilnikDB.y)
btn:RegisterForDrag("LeftButton")
btn:SetMovable(true)
btn:EnableMouse(true)
btn:SetHighlightTexture(ICON_PATH)
btn:SetFrameStrata("MEDIUM")

btn:SetScript("OnDragStart", function(self) self:StartMoving() end)
btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local _, _, _, x, y = self:GetPoint()
    WoWbudilnikDB.x = math.floor(x)
    WoWbudilnikDB.y = math.floor(y)
end)

btn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    elseif button == "RightButton" then
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end)

print("|cFFFFD100[Будильник]|r |cFFAAAAAAЗагружен. Версия 2.0|r")
