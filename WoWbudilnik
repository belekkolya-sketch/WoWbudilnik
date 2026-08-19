-- WoWbudilnik/core.lua - Версия 0.3 (ТЗ: Иконка + Лимиты + Настройки)

-- База данных для сохранения координат кнопки
if not WoWbudilnikDB then 
    WoWbudilnikDB = { x = 0, y = 0 } 
end

local ICON_PATH = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local MAX_MINUTES = 600 -- Лимит из ТЗ (10 часов)

-- Функция срабатывания таймера
local function AlarmTriggered()
    print("|cFFFFD100[WoWbudilnik] |cFFFFFF00Время вышло!|r")
    
    -- Проверка галочек из Options.lua (предварительная привязка)
    if WoWBudilnikChatCheck and WoWBudilnikChatCheck:GetChecked() then
        print("|cFFFFD100[WoWbudilnik] |cFF00FF00Сработал будильник!|r")
    end
    
    if WoWBudilnikScreenCheck and WoWBudilnikScreenCheck:GetChecked() then
        RaidNotice_AddMessage(RaidWarningFrame, "|cFFFF0000[WoWbudilnik] ВРЕМЯ ПРИШЛО!|r", ChatTypeInfo["RAID_WARNING"])
    end
    
    -- Звук (заглушка, пока не прикрутили выбор в опциях)
    PlaySound("RaidWarning") 
end

-- Создание основной кнопки-иконки
local btn = CreateFrame("Button", "WoWBudilnikButton", UIParent)
btn:SetSize(50, 50)
btn:SetNormalTexture(ICON_PATH)
btn:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Убираем края рамки вововской иконки
btn:SetPoint("CENTER", WoWbudilnikDB.x, WoWbudilnikDB.y)
btn:RegisterForDrag("LeftButton")
btn:SetMovable(true)
btn:EnableMouse(true)
btn:SetHighlightTexture(ICON_PATH) -- Эффект подсветки при наведении

-- Логика перетаскивания (сохранение координат)
btn:SetScript("OnDragStart", function(self) self:StartMoving() end)
btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, xOfs, yOfs = self:GetPoint()
    WoWbudilnikDB.x = math.floor(xOfs)
    WoWbudilnikDB.y = math.floor(yOfs)
end)

-- Открытие окна настроек по ПКМ или ЛКМ
btn:SetScript("OnClick", function(self, button)
    if button == "RightButton" or IsShiftKeyDown() then
        InterfaceOptionsFrame_OpenToCategory("WoWbudilnik")
        InterfaceOptionsFrame_OpenToCategory("WoWbudilnik") -- Двойной вызов для надежности
    else
        StaticPopup_Show("WOwbudilnik_SET_TIMER")
    end
end)

-- Всплывающее окно ввода времени (улучшенное под ТЗ)
StaticPopupDialogs["WOwbudilnik_SET_TIMER"] = {
    text = "Настройка будильника\n\nНасколько завести:",
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    
    OnShow = function(self)
        self.editBox:SetText("60")
    end,
    
    EditBoxOnEnterPressed = function(self)
        local input = tonumber(self:GetText())
        if input and input > 0 then
            -- Проверка лимита 10 часов (в секундах)
            if input > (MAX_MINUTES * 60) then
                print("|cFFFFD100[WoWbudilnik] |cFFFF0000Ошибка: Максимум 600 минут!|r")
                input = MAX_MINUTES * 60
                self:SetText(tostring(input))
            end
            C_Timer.After(input, AlarmTriggered)
            print(string.format("|cFFFFD100[WoWbudilnik] |cFF00FFFFТаймер установлен на %d секунд.|r", input))
        end
        self:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

print("|cFFFFD100[WoWbudilnik] |cFFAAAAAAЗагружен. Версия 0.3|r")
