print('^5Blackmarket^7 - A Simple, Configurable Blackmarket Script by Nicky of ^4SG Scripts^7')
Config = Config or {}

Config.Debug = false                            -- Enable/disable debug mode
Config.SqlAutoInstall = true                    -- Automatically install SQL if it doesn't exist (disable after first run)

Config.Account = 'cash'                         -- Account to use for transactions

Config.ResetDays = {                            -- Days to reset the blackmarket ped location
    min = 21,                                   -- Minimum days to reset
    max = 30                                    -- Maximum days to reset
}

Config.Police = {                               -- Police Settings for ped
    enableArrest = true,                        -- Enable arresting (will remove the ped for a set time)
    jobs = {                                    -- Job name and grade to arrest
        ['police'] = 3,
        ['sheriff'] = 3,
        ['sasp'] = 3,
    },
    timeout = 240,                              -- How long the ped is "arrested" for in minutes
}

Config.Ped = {                                  -- Ped Settings
    models = {                                  -- Ped Models
        'g_m_m_maragrande_01',
        'ig_ahronward',
        'ig_jamalamir',
        'ig_yusufamir',
        'ig_jaywalker',
    },
    scenarios = {                               -- Ped Scenario (standing, sitting, smoking, etc.)
        'WORLD_HUMAN_LEANING',
        'WORLD_HUMAN_SMOKING',
        'WORLD_HUMAN_DRUG_DEALER',
        'WORLD_HUMAN_STAND_IMPATIENT',
        'WORLD_HUMAN_STAND_MOBILE_UPRIGHT',
    }
}

Config.Locations = {                            -- Ped locations (chosen at random after reset days or arrest timeout)
    {vector4(267.26, -760.04, 30.82, 163.15)},
    {vector4(267.14, -762.08, 30.82, 76.43)},
    {vector4(266.65, -758.7, 30.82, 74.36)},
    {vector4(268.0, -758.21, 30.82, 345.31)},
}

Config.Items = {
    ['weapon'] = {                              -- Category name
        label = 'Weapons',                      -- Category label
        icon = 'fa-solid fa-gun',               -- Category icon (https://fontawesome.com/ or inventory item name)
        items = {                               -- Items in the category
        -- item name from Shared > items.lua |    price selected on server start    |   stock set on server start
            { item = 'weapon_pistol',           price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'weapon_combatpistol',     price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'weapon_pistol50',         price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'weapon_microsmg',         price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'weapon_smg',              price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
        }
    },
    ['ammo'] = {
        label = 'Ammunition',
        icon = 'pistol_ammo',
        items = {
            { item = 'pistol_ammo',             price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'smg_ammo',                price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'rifle_ammo',              price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'shotgun_ammo',            price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'sniper_ammo',             price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
        }
    },
    ['armor'] = {
        label = 'Armor',
        icon = 'fa-solid fa-shield',
        items = {
            { item = 'armor',                   price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'heavyarmor',              price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
        }
    },
    ['misc'] = {
        label = 'Miscellaneous',
        icon = 'fa-solid fa-box-open',
        items = {
            { item = 'bandage',                 price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'lockpick',                price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
            { item = 'advancedlockpick',        price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },
        }
    },
}

-------------------
--   Examples    --
-------------------
--[[
Without item info:
{ item = 'advancedlockpick',        price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20} },

With item info:
{ item = 'advancedlockpick',        price = {min = 1000, max = 2000 },      stock = {min = 10, max = 20},       info = {'uses' = 20} },
]]