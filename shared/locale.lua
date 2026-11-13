-- Minimal stand-in for qb-core's shared/locale.lua so this resource doesn't need qb-core.
-- Same usage: Lang = Locale:new({ phrases = Translations }) ... Lang:t('error.canceled', { value = 1 })
Locale = {}
Locale.__index = Locale

function Locale:new(opts)
    return setmetatable({ phrases = opts and opts.phrases or {}, warnOnMissing = opts and opts.warnOnMissing }, Locale)
end

function Locale:t(key, subs)
    local value = self.phrases
    for part in tostring(key):gmatch('[^%.]+') do
        value = type(value) == 'table' and value[part] or nil
    end
    if type(value) ~= 'string' then
        if self.warnOnMissing then print(('^3[locale]^0 missing phrase "%s"'):format(key)) end
        return key
    end
    if subs then
        value = value:gsub('%%{(.-)}', function(name)
            return subs[name] ~= nil and tostring(subs[name]) or ('%{' .. name .. '}')
        end)
    end
    return value
end
