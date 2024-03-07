SharedLocales = {
    ['sv'] = {
        ['Currency'] = "SEK",
        ["LangCode"] = "sv-SE"
    },
    ['en'] = {
        ['Currency'] = "USD",
        ["LangCode"] = "en-US"
    },
    ['es'] = {
        ['Currency'] = "EUR",
        ["LangCode"] = "es-ES"
    },
    ['hi'] = {
        ['Currency'] = "INR",
        ["LangCode"] = "hi-IN"
    },
    ['zh'] = {
        ['Currency'] = "CNY",
        ["LangCode"] = "zh-CN"
    },
    ['ar'] = {
        ['Currency'] = "SAR",
        ["LangCode"] = "ar-SA"
    },
    ['pt'] = {
        ['Currency'] = "BRL",
        ["LangCode"] = "pt-BR"
    },
    ['bn'] = {
        ['Currency'] = "BDT",
        ["LangCode"] = "bn-BD"
    },
    ['ru'] = {
        ['Currency'] = "RUB",
        ["LangCode"] = "ru-RU"
    },
    ['ja'] = {
        ['Currency'] = "JPY",
        ["LangCode"] = "ja-JP"
    },
    ['de'] = {
        ['Currency'] = "EUR",
        ["LangCode"] = "de-DE"
    }
};

exports("SharedLocale", function()
    return SharedLocales[Config.DefaultLocale or "en"]
end)

LocaleHandler = {};

function LocaleHandler:CreateLocale(locale, data)
    local lang = Config.DefaultLocale or locale
    local localee = data[lang]

    for _,_ in pairs(data) do
        for k,v in pairs(SharedLocales[lang]) do
            if not localee[k] then
                localee[k] = v
            end
        end
    end

    return localee
end