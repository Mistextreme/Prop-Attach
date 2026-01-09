-- State variables
local currentProp = nil
local currentPropModel = nil
local currentBone = nil
local currentAnim = nil
local currentDict = nil
local currentFlags = nil
local isMoving = false
local moveSpeed = ConfigProps.DefaultMoveSpeed
local rotateSpeed = ConfigProps.DefaultRotateSpeed
local rotateMode = false
local propOffset = vector3(0.0, 0.0, 0.0)
local propRot = vector3(0.0, 0.0, 0.0)

-- Enhanced features
local propHistory = {}
local favorites = {}
local undoStack = {}
local redoStack = {}
local activeMirrorMode = false
local mirrorProp = nil
local showcaseMode = false
local snapToGrid = false
local gridSize = 0.01

-- Preload models on resource start
if ConfigProps.PreloadModels then
    CreateThread(function()
        for category, props in pairs(ConfigProps.Categories) do
            for _, prop in ipairs(props) do
                RequestModel(prop)
            end
        end
    end)
end

-- Permission check
local function HasPermission()
    if not ConfigProps.UsePermissions then return true end
    return IsPlayerAceAllowed(PlayerId(), ConfigProps.RequiredAce)
end

-- Add to history
local function AddToHistory(model)
    for i, item in ipairs(propHistory) do
        if item == model then
            table.remove(propHistory, i)
            break
        end
    end
    table.insert(propHistory, 1, model)
    if #propHistory > ConfigProps.MaxHistorySize then
        table.remove(propHistory, #propHistory)
    end
end

-- Save state for undo
local function SaveState()
    table.insert(undoStack, {
        offset = vector3(propOffset.x, propOffset.y, propOffset.z),
        rotation = vector3(propRot.x, propRot.y, propRot.z)
    })
    if #undoStack > 20 then
        table.remove(undoStack, 1)
    end
    redoStack = {} -- Clear redo stack on new action
end

-- Undo function
local function UndoLastChange()
    if #undoStack > 0 then
        table.insert(redoStack, {
            offset = vector3(propOffset.x, propOffset.y, propOffset.z),
            rotation = vector3(propRot.x, propRot.y, propRot.z)
        })
        local lastState = table.remove(undoStack)
        propOffset = lastState.offset
        propRot = lastState.rotation
        ApplyPropTransform()
        lib.notify({title = 'Undo', description = 'Reverted last change', type = 'success'})
    end
end

-- Redo function
local function RedoLastChange()
    if #redoStack > 0 then
        table.insert(undoStack, {
            offset = vector3(propOffset.x, propOffset.y, propOffset.z),
            rotation = vector3(propRot.x, propRot.y, propRot.z)
        })
        local nextState = table.remove(redoStack)
        propOffset = nextState.offset
        propRot = nextState.rotation
        ApplyPropTransform()
        lib.notify({title = 'Redo', description = 'Reapplied change', type = 'success'})
    end
end

-- Apply transform to prop
function ApplyPropTransform()
    if currentProp and currentBone then
        local ped = PlayerPedId()
        local boneIndex = GetPedBoneIndex(ped, currentBone)
        AttachEntityToEntity(currentProp, ped, boneIndex, propOffset.x, propOffset.y, propOffset.z, 
                           propRot.x, propRot.y, propRot.z, true, true, false, true, 1, true)
        
        if activeMirrorMode and mirrorProp then
            local mirrorBone = currentBone == 57005 and 18905 or (currentBone == 18905 and 57005 or currentBone)
            local mirrorBoneIndex = GetPedBoneIndex(ped, mirrorBone)
            AttachEntityToEntity(mirrorProp, ped, mirrorBoneIndex, -propOffset.x, propOffset.y, propOffset.z,
                               propRot.x, propRot.y, -propRot.z, true, true, false, true, 1, true)
        end
    end
end

-- Show control instructions with live coordinates
function ShowControls()
    local coordText = ConfigProps.ShowCoordinatesLive and 
        string.format('Position: X:%.3f Y:%.3f Z:%.3f\nRotation: X:%.1f Y:%.1f Z:%.1f\n', 
                     propOffset.x, propOffset.y, propOffset.z, propRot.x, propRot.y, propRot.z) or ''
    
    lib.showTextUI(
        '[Arrow Keys] Move FWD/Back, Up/Down | [LMB/RMB] Left/Right\n' ..
        '[H] Toggle Rotate/Move (' .. (rotateMode and 'ROTATE' or 'MOVE') .. ')\n' ..
        '[SHIFT] Hold for fine adjustment\n' ..
        '[Scroll] Speed (Move: ' .. string.format('%.3f', moveSpeed) .. ' | Rotate: ' .. string.format('%.2f', rotateSpeed) .. ')\n' ..
        '[F5] Undo | [F6] Redo | [G] Snap to Grid: ' .. (snapToGrid and 'ON' or 'OFF') .. '\n' ..
        coordText ..
        '[E] Finish | [ESC] Cancel',
        {position = 'right-center', style = {borderRadius = 1, backgroundColor = '#0d0d0d', color = 'orange'}}
    )
end

function HideControls()
    lib.hideTextUI()
end

-- Copy to clipboard
function CopyToClipboard(data)
    SendNUIMessage({string = data})
end

-- Export configuration for use in other scripts
local function ExportForResource()
    if not currentProp or not currentBone then return end
    
    local animCode = currentDict and string.format(
        "\n    -- Animation\n    RequestAnimDict('%s')\n    while not HasAnimDictLoaded('%s') do Wait(1) end\n    TaskPlayAnim(ped, '%s', '%s', 8.0, 8.0, -1, %d, 0, false, false, false)",
        currentDict, currentDict, currentDict, currentAnim, currentFlags
    ) or ""
    
    local exportCode = string.format([[
-- Prop Attachment Code
local prop = CreateObject(GetHashKey('%s'), 0, 0, 0, true, true, true)
local ped = PlayerPedId()
local boneIndex = GetPedBoneIndex(ped, %d)
AttachEntityToEntity(prop, ped, boneIndex, %.4f, %.4f, %.4f, %.2f, %.2f, %.2f, true, true, false, true, 1, true)%s
]], currentPropModel, currentBone, propOffset.x, propOffset.y, propOffset.z, propRot.x, propRot.y, propRot.z, animCode)
    
    CopyToClipboard(exportCode)
    lib.notify({title = 'Exported', description = 'Resource code copied to clipboard!', type = 'success'})
end

-- Load a preset
local function LoadPreset(preset)
    if currentProp then
        DeleteEntity(currentProp)
    end
    
    currentPropModel = preset.model
    currentProp = preset.model
    currentBone = preset.bone
    propOffset = preset.offset
    propRot = preset.rotation
    
    RequestModel(preset.model)
    while not HasModelLoaded(preset.model) do Wait(1) end
    
    local ped = PlayerPedId()
    local boneIndex = GetPedBoneIndex(ped, preset.bone)
    currentProp = CreateObject(GetHashKey(preset.model), 0, 0, 0, true, true, true)
    AttachEntityToEntity(currentProp, ped, boneIndex, propOffset.x, propOffset.y, propOffset.z,
                       propRot.x, propRot.y, propRot.z, true, true, false, true, 1, true)
    
    if preset.animation then
        currentDict = preset.animation.dict
        currentAnim = preset.animation.anim
        currentFlags = preset.animation.flags
        RequestAnimDict(currentDict)
        while not HasAnimDictLoaded(currentDict) do Wait(1) end
        TaskPlayAnim(ped, currentDict, currentAnim, 8.0, 8.0, -1, currentFlags, 0, false, false, false)
    end
    
    AddToHistory(preset.model)
    lib.notify({title = 'Preset Loaded', description = preset.name, type = 'success'})
end

-- Toggle mirror mode
local function ToggleMirrorMode()
    activeMirrorMode = not activeMirrorMode
    
    if activeMirrorMode and currentProp and (currentBone == 57005 or currentBone == 18905) then
        local ped = PlayerPedId()
        local mirrorBone = currentBone == 57005 and 18905 or 57005
        local mirrorBoneIndex = GetPedBoneIndex(ped, mirrorBone)
        
        mirrorProp = CreateObject(GetHashKey(currentPropModel), 0, 0, 0, true, true, true)
        AttachEntityToEntity(mirrorProp, ped, mirrorBoneIndex, -propOffset.x, propOffset.y, propOffset.z,
                           propRot.x, propRot.y, -propRot.z, true, true, false, true, 1, true)
        
        lib.notify({title = 'Mirror Mode', description = 'Enabled - Both hands synchronized', type = 'inform'})
    elseif not activeMirrorMode and mirrorProp then
        DeleteEntity(mirrorProp)
        mirrorProp = nil
        lib.notify({title = 'Mirror Mode', description = 'Disabled', type = 'inform'})
    end
end

-- Showcase rotation
local function ToggleShowcase()
    showcaseMode = not showcaseMode
    
    if showcaseMode then
        lib.notify({title = 'Showcase Mode', description = 'Auto-rotating character', type = 'inform'})
        CreateThread(function()
            local ped = PlayerPedId()
            while showcaseMode do
                local heading = GetEntityHeading(ped)
                SetEntityHeading(ped, heading + 0.5)
                Wait(10)
            end
        end)
    else
        lib.notify({title = 'Showcase Mode', description = 'Disabled', type = 'inform'})
    end
end

-- Main menu with all options
lib.registerContext({
    id = 'main_menu',
    title = '🎯 Advanced Prop Menu',
    options = {
        {title = '📦 Spawn Prop', description = 'Browse categories', icon = 'box', event = 'propMenu:categoryMenu'},
        {title = '✏️ Enter Prop Model', description = 'Manual model input', icon = 'keyboard', event = 'propMenu:enterPropModel'},
        {title = '⭐ Presets', description = 'Load saved configurations', icon = 'star', event = 'propMenu:presetsMenu'},
        {title = '🕐 History', description = 'Recently used props', icon = 'clock-rotate-left', event = 'propMenu:historyMenu'},
        {title = '🎬 Animations', description = 'Apply animations', icon = 'person-running', event = 'propMenu:animMenu'},
        {title = '🎮 Adjust Prop', description = 'Position and rotate', icon = 'arrows-up-down-left-right', event = 'propMenu:moveObject'},
        {title = '🪞 Mirror Mode', description = 'Toggle both hands', icon = 'clone', event = 'propMenu:toggleMirror'},
        {title = '🔄 Showcase Mode', description = 'Auto-rotate view', icon = 'rotate', event = 'propMenu:toggleShowcase'},
        {title = '💾 Save Data', description = 'Copy configuration', icon = 'floppy-disk', event = 'propMenu:saveData'},
        {title = '📤 Export Code', description = 'Generate script code', icon = 'code', event = 'propMenu:exportCode'},
        {title = '🔄 Reset', description = 'Reset all positions', icon = 'arrow-rotate-left', event = 'propMenu:resetMenu'},
        {title = '🗑️ Delete Prop', description = 'Remove current prop', icon = 'trash', event = 'propMenu:deleteProp'},
        {title = '❌ Cancel', description = 'Close and cleanup', icon = 'xmark', event = 'propMenu:cancelMenu'}
    }
})

-- Simple start menu
lib.registerContext({
    id = 'start_menu',
    title = '🎯 Prop Menu',
    options = {
        {title = '📦 Spawn Prop', icon = 'box', event = 'propMenu:categoryMenu'},
        {title = '✏️ Enter Prop Model', icon = 'keyboard', event = 'propMenu:enterPropModel'},
        {title = '⭐ Presets', icon = 'star', event = 'propMenu:presetsMenu'},
        {title = '🕐 History', icon = 'clock-rotate-left', event = 'propMenu:historyMenu'},
        {title = '🎬 Animations', icon = 'person-running', event = 'propMenu:animMenu'},
        {title = '❌ Cancel', icon = 'xmark', event = 'propMenu:cancelMenu'}
    }
})

-- Register command
RegisterCommand(ConfigProps.Hotkeys.openMenu, function()
    if not HasPermission() then
        lib.notify({title = 'No Permission', description = 'You do not have access to this feature', type = 'error'})
        return
    end
    HideControls()
    lib.showContext(currentProp and 'main_menu' or 'start_menu')
end)

-- Category menu
AddEventHandler('propMenu:categoryMenu', function()
    local options = {}
    for category, props in pairs(ConfigProps.Categories) do
        table.insert(options, {
            title = category,
            description = #props .. ' props available',
            icon = 'folder',
            event = 'propMenu:showCategory',
            args = {category = category}
        })
    end
    
    lib.registerContext({
        id = 'category_menu',
        title = '📁 Prop Categories',
        menu = currentProp and 'main_menu' or 'start_menu',
        options = options
    })
    lib.showContext('category_menu')
end)

-- Show props in category
AddEventHandler('propMenu:showCategory', function(data)
    local options = {}
    for _, prop in ipairs(ConfigProps.Categories[data.category]) do
        table.insert(options, {
            title = prop,
            icon = 'cube',
            event = 'propMenu:selectProp',
            args = {prop = prop}
        })
    end
    
    lib.registerContext({
        id = 'props_in_category',
        title = '📦 ' .. data.category,
        menu = 'category_menu',
        options = options
    })
    lib.showContext('props_in_category')
end)

-- History menu
AddEventHandler('propMenu:historyMenu', function()
    if #propHistory == 0 then
        lib.notify({title = 'History', description = 'No recent props', type = 'inform'})
        return
    end
    
    local options = {}
    for _, prop in ipairs(propHistory) do
        table.insert(options, {
            title = prop,
            icon = 'clock',
            event = 'propMenu:selectProp',
            args = {prop = prop}
        })
    end
    
    lib.registerContext({
        id = 'history_menu',
        title = '🕐 Recent Props',
        menu = currentProp and 'main_menu' or 'start_menu',
        options = options
    })
    lib.showContext('history_menu')
end)

-- Presets menu
AddEventHandler('propMenu:presetsMenu', function()
    local options = {}
    for _, preset in ipairs(ConfigProps.Presets) do
        table.insert(options, {
            title = preset.name,
            description = preset.model,
            icon = 'star',
            event = 'propMenu:loadPreset',
            args = {preset = preset}
        })
    end
    
    lib.registerContext({
        id = 'presets_menu',
        title = '⭐ Saved Presets',
        menu = currentProp and 'main_menu' or 'start_menu',
        options = options
    })
    lib.showContext('presets_menu')
end)

AddEventHandler('propMenu:loadPreset', function(data)
    LoadPreset(data.preset)
    lib.showContext('main_menu')
end)

-- Select prop
AddEventHandler('propMenu:selectProp', function(data)
    currentProp = data.prop
    currentPropModel = data.prop
    
    local options = {}
    for _, bone in ipairs(ConfigProps.Bones) do
        table.insert(options, {
            title = bone.name,
            icon = 'hand',
            event = 'propMenu:attachProp',
            args = {bone = bone.id}
        })
    end
    
    lib.registerContext({
        id = 'bone_menu',
        title = '🦴 Select Bone',
        menu = currentProp and 'main_menu' or 'start_menu',
        options = options
    })
    lib.showContext('bone_menu')
end)

-- Enter prop model
AddEventHandler('propMenu:enterPropModel', function()
    local input = lib.inputDialog('✏️ Enter Prop Model', {
        {type = 'input', label = 'Model Name', placeholder = 'prop_beer_pissh', required = true}
    })
    
    if input and input[1] then
        currentPropModel = input[1]
        currentProp = input[1]
        
        local options = {}
        for _, bone in ipairs(ConfigProps.Bones) do
            table.insert(options, {
                title = bone.name,
                icon = 'hand',
                event = 'propMenu:attachProp',
                args = {bone = bone.id}
            })
        end
        
        lib.registerContext({
            id = 'bone_menu',
            title = '🦴 Select Bone',
            menu = 'start_menu',
            options = options
        })
        lib.showContext('bone_menu')
    else
        lib.showContext('start_menu')
    end
end)

-- Attach prop
AddEventHandler('propMenu:attachProp', function(data)
    if currentProp then
        RequestModel(currentProp)
        while not HasModelLoaded(currentProp) do Wait(1) end
        
        local ped = PlayerPedId()
        local boneIndex = GetPedBoneIndex(ped, data.bone)
        currentBone = data.bone
        
        if DoesEntityExist(currentProp) and type(currentProp) == "number" then
            DeleteEntity(currentProp)
        end
        
        currentProp = CreateObject(GetHashKey(currentProp), 0, 0, 0, true, true, true)
        AttachEntityToEntity(currentProp, ped, boneIndex, 0, 0, 0, 0, 0, 0, true, true, false, true, 1, true)
        
        AddToHistory(currentPropModel)
    end
    lib.showContext('main_menu')
end)

-- Animation menu
AddEventHandler('propMenu:animMenu', function()
    local options = {}
    for _, anim in ipairs(ConfigProps.Animations) do
        table.insert(options, {
            title = anim.label,
            icon = 'person-running',
            event = 'propMenu:selectAnim',
            args = {anim = anim}
        })
    end
    
    lib.registerContext({
        id = 'anim_menu',
        title = '🎬 Animations',
        menu = currentProp and 'main_menu' or 'start_menu',
        options = options
    })
    lib.showContext('anim_menu')
end)

-- Select animation
AddEventHandler('propMenu:selectAnim', function(data)
    currentAnim = data.anim.anim
    currentDict = data.anim.dict
    currentFlags = data.anim.flags
    
    RequestAnimDict(currentDict)
    while not HasAnimDictLoaded(currentDict) do Wait(0) end
    
    TaskPlayAnim(PlayerPedId(), currentDict, currentAnim, 8.0, 8.0, -1, currentFlags, 0, false, false, false)
    
    lib.notify({title = 'Animation', description = data.anim.label .. ' applied', type = 'success'})
    lib.showContext('anim_menu')
end)

-- Move object with enhanced controls
AddEventHandler('propMenu:moveObject', function()
    if not currentProp then return end
    
    isMoving = true
    ShowControls()
    undoStack = {}
    redoStack = {}
    
    CreateThread(function()
        while isMoving do
            Wait(0)
            
            DisablePlayerFiring(PlayerId())
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            
            local speedMultiplier = IsControlPressed(0, ConfigProps.Hotkeys.shiftModifier) and ConfigProps.FineAdjustMultiplier or 1.0
            local currentMoveSpeed = moveSpeed * speedMultiplier
            local currentRotateSpeed = rotateSpeed * speedMultiplier
            
            -- Movement/Rotation
            if rotateMode then
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowRight) then
                    SaveState()
                    propRot = vector3(propRot.x, propRot.y, propRot.z + currentRotateSpeed)
                end
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowLeft) then
                    SaveState()
                    propRot = vector3(propRot.x, propRot.y, propRot.z - currentRotateSpeed)
                end
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowUp) then
                    SaveState()
                    propRot = vector3(propRot.x + currentRotateSpeed, propRot.y, propRot.z)
                end
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowDown) then
                    SaveState()
                    propRot = vector3(propRot.x - currentRotateSpeed, propRot.y, propRot.z)
                end
                if IsDisabledControlPressed(0, ConfigProps.Hotkeys.leftMouse) then
                    SaveState()
                    propRot = vector3(propRot.x, propRot.y + currentRotateSpeed, propRot.z)
                end
                if IsDisabledControlPressed(0, ConfigProps.Hotkeys.rightMouse) then
                    SaveState()
                    propRot = vector3(propRot.x, propRot.y - currentRotateSpeed, propRot.z)
                end
            else
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowRight) then
                    SaveState()
                    propOffset = vector3(propOffset.x + currentMoveSpeed, propOffset.y, propOffset.z)
                end
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowLeft) then
                    SaveState()
                    propOffset = vector3(propOffset.x - currentMoveSpeed, propOffset.y, propOffset.z)
                end
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowUp) then
                    SaveState()
                    propOffset = vector3(propOffset.x, propOffset.y + currentMoveSpeed, propOffset.z)
                end
                if IsControlPressed(0, ConfigProps.Hotkeys.arrowDown) then
                    SaveState()
                    propOffset = vector3(propOffset.x, propOffset.y - currentMoveSpeed, propOffset.z)
                end
                if IsDisabledControlPressed(0, ConfigProps.Hotkeys.leftMouse) then
                    SaveState()
                    propOffset = vector3(propOffset.x, propOffset.y, propOffset.z + currentMoveSpeed)
                end
                if IsDisabledControlPressed(0, ConfigProps.Hotkeys.rightMouse) then
                    SaveState()
                    propOffset = vector3(propOffset.x, propOffset.y, propOffset.z - currentMoveSpeed)
                end
                
                -- Snap to grid
                if snapToGrid then
                    propOffset = vector3(
                        math.floor(propOffset.x / gridSize + 0.5) * gridSize,
                        math.floor(propOffset.y / gridSize + 0.5) * gridSize,
                        math.floor(propOffset.z / gridSize + 0.5) * gridSize
                    )
                end
            end
            
            ApplyPropTransform()
            
            -- Toggle mode
            if IsControlJustPressed(0, ConfigProps.Hotkeys.toggleMode) then
                rotateMode = not rotateMode
                lib.notify({title = 'Mode', description = rotateMode and 'Rotate Mode' or 'Move Mode', type = 'inform'})
                ShowControls()
            end
            
            -- Snap to grid toggle (G key)
            if IsControlJustPressed(0, 47) then
                snapToGrid = not snapToGrid
                lib.notify({title = 'Snap to Grid', description = snapToGrid and 'Enabled' or 'Disabled', type = 'inform'})
                ShowControls()
            end
            
            -- Undo/Redo
            if IsControlJustPressed(0, ConfigProps.Hotkeys.undo) then
                UndoLastChange()
                ShowControls()
            end
            if IsControlJustPressed(0, ConfigProps.Hotkeys.redo) then
                RedoLastChange()
                ShowControls()
            end
            
            -- Speed adjustment
            if IsControlJustPressed(0, ConfigProps.Hotkeys.scrollUp) then
                if rotateMode then
                    rotateSpeed = math.min(1.0, rotateSpeed + 0.01)
                else
                    moveSpeed = math.min(0.1, moveSpeed + 0.001)
                end
                ShowControls()
            end
            if IsControlJustPressed(0, ConfigProps.Hotkeys.scrollDown) then
                if rotateMode then
                    rotateSpeed = math.max(0.01, rotateSpeed - 0.01)
                else
                    moveSpeed = math.max(0.0001, moveSpeed - 0.001)
                end
                ShowControls()
            end
            
            -- Finish
            if IsControlJustPressed(0, ConfigProps.Hotkeys.finishAdjust) then
                isMoving = false
                HideControls()
                lib.showContext('main_menu')
            end
        end
    end)
end)

-- Toggle mirror mode
AddEventHandler('propMenu:toggleMirror', function()
    ToggleMirrorMode()
    lib.showContext('main_menu')
end)

-- Toggle showcase
AddEventHandler('propMenu:toggleShowcase', function()
    ToggleShowcase()
    lib.showContext('main_menu')
end)

-- Save data
AddEventHandler('propMenu:saveData', function()
    if currentProp and currentBone then
        local animData = currentDict and string.format(",\nAnim = {dict = '%s', anim = '%s', flags = %d}", 
            currentDict, currentAnim, currentFlags) or ""
        
        local data = string.format("Model = '%s',\nBoneID = %d,\nOffset = vector3(%.4f, %.4f, %.4f),\nRot = vector3(%.2f, %.2f, %.2f)%s", 
            currentPropModel, currentBone, propOffset.x, propOffset.y, propOffset.z, 
            propRot.x, propRot.y, propRot.z, animData)
        
        CopyToClipboard(data)
        lib.notify({title = 'Data Saved', description = 'Configuration copied to clipboard!', type = 'success'})
        lib.showContext('main_menu')
    end
end)

-- Export code
AddEventHandler('propMenu:exportCode', function()
    ExportForResource()
    lib.showContext('main_menu')
end)

-- Reset
AddEventHandler('propMenu:resetMenu', function()
    if currentProp then
        propOffset = vector3(0.0, 0.0, 0.0)
        propRot = vector3(0.0, 0.0, 0.0)
        ApplyPropTransform()
        lib.notify({title = 'Reset', description = 'Position and rotation reset', type = 'success'})
        lib.showContext('main_menu')
    end
end)

-- Delete prop
AddEventHandler('propMenu:deleteProp', function()
    if currentProp then
        DeleteEntity(currentProp)
        if mirrorProp then
            DeleteEntity(mirrorProp)
            mirrorProp = nil
            activeMirrorMode = false
        end
        currentProp = nil
        lib.notify({title = 'Deleted', description = 'Prop removed', type = 'success'})
        lib.showContext('main_menu')
    end
end)

-- Cancel/cleanup
AddEventHandler('propMenu:cancelMenu', function()
    local ped = PlayerPedId()
    if currentProp then
        DeleteEntity(currentProp)
        ClearPedTasks(ped)
        ClearPedTasksImmediately(ped)
        currentProp = nil
        currentBone = nil
        currentAnim = nil
        currentDict = nil
        currentFlags = nil
        propOffset = vector3(0.0, 0.0, 0.0)
        propRot = vector3(0.0, 0.0, 0.0)
    end
    if mirrorProp then
        DeleteEntity(mirrorProp)
        mirrorProp = nil
        activeMirrorMode = false
    end
    ClearPedTasksImmediately(ped)
    showcaseMode = false
    lib.showContext('start_menu')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if currentProp then DeleteEntity(currentProp) end
        if mirrorProp then DeleteEntity(mirrorProp) end
        HideControls()
        
        -- Cleanup animation dicts
        if ConfigProps.CleanupAnimDicts and currentDict then
            RemoveAnimDict(currentDict)
        end
    end
end)