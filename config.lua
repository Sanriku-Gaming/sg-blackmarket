print('^5Blackmarket^7 - A Simple, Configurable Blackmarket Script by Nicky of ^4SG Scripts^7')
Config = Config or {}

Config.Debug = false                            -- Enable/disable debug mode
Config.SqlAutoInstall = true                    -- Automatically install SQL if it doesn't exist (disable after first run)

Config.Commands = {                             -- Commands to move the blackmarket ped
    cooldown = 60,                              -- Cooldown in seconds between command uses
    movehere = {
        cmd = 'bm_movehere',                    -- Move the blackmarket ped to your location
        desc = 'Move the blackmarket ped to your current location', -- Description for the command
        perm = 'admin',                         -- Permission required to use the command
    },
    random = {
        cmd = 'bm_random',                      -- Move the blackmarket ped to a random location
        desc = 'Move the blackmarket ped to a random Config location', -- Description for the command
        perm = 'admin',                         -- Permission required to use the command
    },
    reset = {
        cmd = 'bm_reset',                       -- Reset the blackmarket ped and location
        desc = 'Reset the blackmarket ped and location', -- Description for the command
        perm = 'god',                           -- Permission required to use the command
    },
}

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

Config.RequiredItem = {                         -- Required item to access the blackmarket shop
    enable = false,                             -- Enable/disable required item
    item = 'bm_access',                         -- Item name from Shared > Items.lua
    removeItem = true,                          -- Remove item after use
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
    },
    locations = {                               -- Ped locations (chosen at random after reset days or arrest timeout)
        vector4(267.26, -760.04, 30.82, 163.15),
        vector4(267.14, -762.08, 30.82, 76.43),
        vector4(266.65, -758.7, 30.82, 74.36),
        vector4(268.0, -758.21, 30.82, 345.31),
    }
}

Config.WeaponSerialNumbers = {                  -- Weapon serial number settings
    enable = true,                              -- Enable/disable weapon serial numbers
    length = 15,                                -- Length of the serial number
    prefix = 'BM',                              -- Prefix for the serial number
    scratch = {
        enable = true,                          -- Enable/disable weapon serial number scratching
        character = '*',                        -- Character to replace the serial number with
        min = 4,                                -- Minimum scratched characters
        max = 8                                 -- Maximum scratched characters
    }
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