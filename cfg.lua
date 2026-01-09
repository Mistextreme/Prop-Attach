ConfigProps = {}

-- Permission system (set to false to disable, or use ace permissions)
ConfigProps.UsePermissions = false
ConfigProps.RequiredAce = "props.use" -- Ace permission required if UsePermissions = true

-- Performance settings
ConfigProps.PreloadModels = true -- Preload frequently used models
ConfigProps.CleanupAnimDicts = true -- Remove anim dicts after use to save memory

-- UI Settings
ConfigProps.ShowCoordinatesLive = true -- Show coordinates in real-time during adjustment
ConfigProps.EnableSounds = true -- UI interaction sounds
ConfigProps.DefaultMoveSpeed = 0.001
ConfigProps.DefaultRotateSpeed = 0.15
ConfigProps.FineAdjustMultiplier = 0.1 -- When holding SHIFT

-- History settings
ConfigProps.MaxHistorySize = 10 -- Maximum props in history

-- Categories for props
ConfigProps.Categories = {
    ["Food & Drinks"] = {
        'prop_beer_pissh',
        'prop_cs_burger_01',
        'prop_food_cb_chips',
        'prop_food_bs_coffee',
        'prop_food_chips',
        'prop_food_cb_donuts',
    },
    ["Tools"] = {
        'prop_tool_hammer',
        'prop_tool_screwdvr01',
        'prop_tool_wrench',
    },
    ["Weapons"] = {
        'w_me_bat',
        'w_me_knife_01',
    },
    ["Electronics"] = {
        'prop_phone_ing',
        'prop_laptop_01a',
        'prop_tablet_01',
    },
    ["Misc"] = {
        'prop_ld_flow_bottle',
        'prop_amb_beer_bottle',
    }
}

-- Preset configurations (example presets)
ConfigProps.Presets = {
    {
        name = "Beer - Right Hand",
        model = "prop_beer_pissh",
        bone = 57005,
        offset = vector3(0.0, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        animation = {
            dict = 'mp_player_intdrink',
            anim = 'loop_bottle',
            flags = 49
        }
    },
    {
        name = "Burger - Right Hand",
        model = "prop_cs_burger_01",
        bone = 57005,
        offset = vector3(0.0, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        animation = {
            dict = 'mp_player_inteat@burger',
            anim = 'mp_player_int_eat_burger',
            flags = 49
        }
    }
}

-- Animation library
ConfigProps.Animations = {
    {
        label = 'Eat Burger',
        dict = 'mp_player_inteat@burger',
        anim = 'mp_player_int_eat_burger',
        flags = 49
    },
    {
        label = 'Drink Cup',
        dict = 'mp_player_intdrink',
        anim = 'loop_bottle',
        flags = 49
    },
    {
        label = 'Phone Call',
        dict = 'cellphone@',
        anim = 'cellphone_call_listen_base',
        flags = 49
    },
    {
        label = 'Smoking',
        dict = 'amb@world_human_smoking@male@male_a@enter',
        anim = 'enter',
        flags = 49
    },
    {
        label = 'Clipboard',
        dict = 'missfam4',
        anim = 'base',
        flags = 49
    },
    {
        label = 'Hammer Work',
        dict = 'amb@world_human_hammering@male@base',
        anim = 'base',
        flags = 49
    }
}

-- Bone definitions with friendly names
ConfigProps.Bones = {
    {name = "Left Hand", id = 18905},
    {name = "Right Hand", id = 57005},
    {name = "Left Foot", id = 14201},
    {name = "Right Foot", id = 52301},
    {name = "Head", id = 31086},
    {name = "Neck", id = 39317},
    {name = "Pelvis", id = 11816},
    {name = "Left Shoulder", id = 45509},
    {name = "Right Shoulder", id = 40269},
    {name = "Spine", id = 24816},
    {name = "Left Knee", id = 63931},
    {name = "Right Knee", id = 36864}
}

-- Hotkeys (customizable)
ConfigProps.Hotkeys = {
    openMenu = 'props',
    toggleMode = 74, -- H
    finishAdjust = 38, -- E
    scrollUp = 15,
    scrollDown = 14,
    arrowUp = 172,
    arrowDown = 173,
    arrowLeft = 174,
    arrowRight = 175,
    leftMouse = 24,
    rightMouse = 25,
    undo = 166, -- F5
    redo = 167, -- F6
    duplicate = 168, -- F7
    delete = 178, -- DELETE
    shiftModifier = 21 -- LEFT SHIFT for fine adjustment
}