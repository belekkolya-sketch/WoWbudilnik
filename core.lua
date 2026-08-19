-- WoWbudilnik/core.lua - Версия для 3.3.5 (Сирус)

if not WoWbudilnikDB then
    WoWbudilnikDB = { x = 0, y = 0 }
end

local ICON_PATH = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local MAX_MINUTES = 600 -- Лимит (10 часов)

-- =======================
-- ПРОСТОЙ ТАЙМЕР ДЛЯ 3.3.5
-- =======================
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

-- =======================
-- ФУНКЦИЯ СРАБАТЫВАНИЯ
-- =======================
local function AlarmTriggered()
    local chatChecked = false
    local screenChecked = false

    if WoWBudilnikChatCheck then
        chatChecked = WoWBudilnikChatCheck:GetChecked()
    end

    if WoWBudilnikScreenCheck then
        screenChecked = WoWBudilnikScreenCheck:GetChecked()
    end

    local soundChoice = 1
    if WoWBudilnikSoundBox then
        soundChoice = UIDropDownMenu_GetSelectedID(WoWBudilnikSoundBox) or 1
    end

    -- === ЧАТ ===
    if chatChecked then
        print("|cFFFFD100[WoWbudilnik]|r |cFFFFFF00Время вышло!|r")
    end

    -- === ЭКРАН ===
    if screenChecked then
        RaidNotice_AddMessage(RaidWarningFrame, "|cFFFF0000[WoWbudilnik] ВРЕМЯ ПРИШЛО!|r", { r = 1, g = 0, b = 0 })
    end

    -- === ЗВУК ===
    if soundChoice == 1 then
        PlaySoundFile("Interface\\AddOns\\WoWbudilnik\\alarm.mp3")
    elseif soundChoice == 2 then
        PlaySoundFile("Interface\\AddOns\\WoWbudilnik\\battle.mp3")
    else
        PlaySound("RaidWarning")
    end
end

-- =======================
-- КНОПКА НА ЭКРАНЕ
-- =======================
local btn = CreateFrame("Button", "WoWBudilnikButton", UIParent)
btn:SetSize(50, 50)
btn:SetNormalTexture(ICON_PATH)
btn:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
btn:SetPoint("CENTER", UIParent, "CENTER", WoWbudilnikDB.x, WoWbudilnikDB.y)
btn:RegisterForDrag("LeftButton")
btn:SetMovable(true)
btn:EnableMouse(true)
btn:SetHighlightTexture(ICON_PATH)

-- === Перетаскивание ===
btn:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, xOfs, yOfs = self:GetPoint()
    WoWbudilnikDB.x = math.floor(xOfs)
    WoWbudilnikDB.y = math.floor(yOfs)
end)

-- === Клики ===
btn:SetScript("OnClick", function(self, button)
    if button == "RightButton" or IsShiftKeyDown() then
        InterfaceOptionsFrame_OpenToCategory("WoWbudilnik")
    else
        StaticPopup_Show("WOwbudilnik_SET_TIMER")
    end
end)

-- =======================
-- ОКНО ВВОДА ВРЕМЕНИ
-- =======================
StaticPopupDialogs["WOwbudilnik_SET_TIMER"] = {
    text = "Настройка будильника\n\nНа сколько секунд завести:",
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,

    OnShow = function(self)
        self.editBox:SetText("60")
        self.editBox:SetFocus()
    end,

    EditBoxOnEnterPressed = function(self)
        local input = tonumber(self:GetText())

        if input and input > 0 then
            if input > (MAX_MINUTES * 60) then
                print("|cFFFFD100[WoWbudilnik]|r |cFFFF0000Ошибка: максимум 600 минут!|r")
                input = MAX_MINUTES * 60
                self:SetText(tostring(input))
            end

            DelayedCall(input, AlarmTriggered)
            print(string.format("|cFFFFD100[WoWbudilnik]|r |cFF00FFFFТаймер установлен на %d секунд.|r", input))
        end

        self:GetParent():Hide()
    end,

    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
}

print("|cFFFFD100[WoWbudilnik]|r |cFFAAAAAAЗагружен. Версия 3.3.5|r")
