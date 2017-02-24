--
-- BetterFuelUsage
--
-- @author  TyKonKet
-- @date 24/02/2017
DynamicText = {};
DynamicText.ALIGNS = {};
DynamicText.ALIGNS.LEFT = 0;
DynamicText.ALIGNS.TOP = 0;
DynamicText.ALIGNS.CENTER = 1;
DynamicText.ALIGNS.RIGHT = 2;
DynamicText.ALIGNS.BOTTOM = 2;
local DynamicText_mt = Class(DynamicText);

function DynamicText:new(settings)
    if DynamicText_mt == nil then
        DynamicText_mt = Class(DynamicText);
    end
    local self = {};
    setmetatable(self, DynamicText_mt);
    local defaultSettings = {
        color = {
            r = 1,
            g = 1,
            b = 1,
            a = 1
        },
        position = {
            x = 0.5,
            y = 0.5
        },
        align = {
            x = DynamicText.ALIGNS.LEFT,
            y = DynamicText.ALIGNS.BOTTOM
        },
        bold = false,
        size = 0.025,
        text = "Fade Effect",
        shadow = {
            show = false,
            color = {
                r = 0,
                g = 0,
                b = 0,
                a = 1
            },
            position = {
                x = 0.0025,
                y = 0.0035
            }
        }
    };
    self.settings = defaultSettings;
    self:overwriteSettings(self.settings, settings);
    self:alignText();
    self.settings.size = self.settings.size * g_gameSettings:getValue("uiScale") * (g_screenAspectRatio / 1.7777777777777);
    return self;
end

function DynamicText:overwriteSettings(dSettings, nSettings)
    for k, v in pairs(nSettings) do
        if (type(v) ~= "table") then
            dSettings[k] = v;
        else
            self:overwriteSettings(dSettings[k], v);
        end
    end
end

function DynamicText:alignText()
    self.settings.position.alignedX = self.settings.position.x;
    self.settings.position.alignedY = self.settings.position.y;
    if self.settings.align.x == DynamicText.ALIGNS.CENTER then
        self.settings.position.alignedX = self.settings.position.x - (getTextWidth(self.settings.size, self.settings.text) / 2);
    end
    if self.settings.align.x == DynamicText.ALIGNS.RIGHT then
        self.settings.position.alignedX = self.settings.position.x - getTextWidth(self.settings.size, self.settings.text);
    end
    if self.settings.align.y == DynamicText.ALIGNS.CENTER then
        self.settings.position.alignedY = self.settings.position.y - (getTextHeight(self.settings.size, self.settings.text) / 2.85);
    end
    if self.settings.align.y == DynamicText.ALIGNS.TOP then
        self.settings.position.alignedY = self.settings.position.y - getTextHeight(self.settings.size, self.settings.text);
    end
end

function DynamicText:setText(text)
    self.settings.text = text
    self:alignText();
end

function DynamicText:draw()
    setTextBold(self.settings.bold);
    if self.settings.shadow.show then
        setTextColor(self.settings.shadow.color.r, self.settings.shadow.color.g, self.settings.shadow.color.b, self.settings.shadow.color.a);
        renderText(self.settings.position.alignedX + self.settings.shadow.position.x, self.settings.position.alignedY - self.settings.shadow.position.y, self.settings.size, self.settings.text);
    end
    setTextColor(self.settings.color.r, self.settings.color.g, self.settings.color.b, self.settings.color.a);
    renderText(self.settings.position.alignedX, self.settings.position.alignedY, self.settings.size, self.settings.text);
    setTextBold(false);
    setTextColor(1, 1, 1, 1);
end
