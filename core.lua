-- WoWbudilnik/core.lua - Версия с поддержкой звуков из ТЗ

if not WoWbudilnikDB then 
    WoWbudilnikDB = { x = 0, y = 0 } 
end

local ICON_PATH = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local MAX_MINUTES = 600 -- Лимит из ТЗ (10 часов)

-- Функция срабатывания таймера
local function AlarmTriggered()
    -- Читаем галочки из окна настроек (Options.lua)
    local chatChecked = false
    local screenChecked = false
    
    if WoWBudilnikChatCheck then chatChecked = WoWBudilnikChatCheck:GetChecked() end
    if WoWBudilnikScreenCheck then screenChecked = WoWBudilnikScreenCheck:GetChecked() end

    -- Читаем выбранный звук из выпадающего списка
    local soundChoice = 1
    if WoWBudilnikSoundBox then 
        soundChoice = UIDropDownMenu_GetSelectedID(WoWBudilnikSoundBox) 
    end

    -- === ОПОВЕЩЕНИЯ ===
    if chatChecked then
        print("|cFFFFD100[WoWbudilnik] |cFFFFFF00Время вышло!|r")
    end
    
    if screenChecked then
        RaidNotice_AddMessage(RaidWarningFrame, "|cFFFF0000[WoWbudilnik] ВРЕМЯ ПРИШЛО!|r", ChatTypeInfo["RAID_WARNING"])
    end

    -- === ЗВУК (согласно ТЗ) ===
    if soundChoice == 1 then
        PlaySoundFile("Interface\\AddOns\\WoWbudilnik\\alarm.mp3") 
    elseif soundChoice == 2 then
        PlaySoundFile("Interface\\AddOns\\WoWbudilnik\\battle.mp3")
    else
        PlaySound("RaidWarning") 
    end
end

-- Создание кнопки-иконки
local btn = CreateFrame("Button", "WoWBudilnikButton", UIParent)
btn:SetSize(50, 50)
btn:SetNormalTexture(ICON_PATH)
btn:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
btn:SetPoint("CENTER", WoWbudilnikDB.x, WoWbudilnikDB.y)
btn:RegisterForDrag("LeftButton")
btn:SetMovable(true)
btn:EnableMouse(true)
btn:SetHighlightTexture(ICON_PATH)

-- Логика перетаскивания
btn:SetScript("OnDragStart", function(self) self:StartMoving() end)
btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, xOfs, yOfs = self:GetPoint()
    WoWbudilnikDB.x = math.floor(xOfs)
    WoWbudilnikDB.y = math.floor(yOfs)
end)

-- Клик по кнопке: ПКМ открывает настройки, ЛКМ ставит таймер
btn:SetScript("OnClick", function(self, button)
    if button == "RightButton" or IsShiftKeyDown() then
        InterfaceOptionsFrame_OpenToCategory("WoWbudilnik")
        InterfaceOptionsFrame_OpenToCategory("WoWbudilnik") 
    else
        StaticPopup_Show("WOwbudilnik_SET_TIMER")
    end
end)

-- Окно ввода времени
StaticPopupDialogs["WOwbudilnik_SET_TIMER"] = {
    text = "Настройка будильника\n\nНасколько завести:",
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnShow = function(self) self.editBox:SetText("60") end,
    EditBoxOnEnterPressed = function(self)
        local input = tonumber(self:GetText())
        if input and input > 0 then
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

print("|cFFFFD100[WoWbudilnik] |cFFAAAAAAЗагружен. Версия со звуками|r")
