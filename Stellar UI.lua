--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║  S T E L L A R   U I   ·   "Ethereal Edition"                        ║
    ║                                                                      ║
    ║  A ground-up visual redesign of the Stellar UI library. It adopts    ║
    ║  the Ethereal design language — soft layered panels, hairline        ║
    ║  borders, considered typography, fluid spring motion — while        ║
    ║  keeping the entire Stellar component API intact:                    ║
    ║                                                                      ║
    ║      library:create_tab(name, icon)                                  ║
    ║      tab:create_module{ ... }        module:create_slider{ ... }     ║
    ║      module:create_toggle{ ... }     module:create_dropdown{ ... }   ║
    ║      module:create_keybind{ ... }    module:create_textbox{ ... }    ║
    ║      module:create_button{ ... }     module:create_colorpicker{ ... }║
    ║                                                                      ║
    ║  Everything is themeable, animated and mobile aware.                 ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

--=====================================================================
--  Services
--=====================================================================
local cloneref = cloneref or function(service) return service end

local CoreGui          = cloneref(game:GetService('CoreGui'))
local Lighting         = cloneref(game:GetService('Lighting'))
local Debris           = cloneref(game:GetService('Debris'))
local TweenService     = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local TextService      = cloneref(game:GetService('TextService'))
local HttpService      = cloneref(game:GetService('HttpService'))
local ContentProvider  = cloneref(game:GetService('ContentProvider'))
local Players          = cloneref(game:GetService('Players'))
local RunService       = cloneref(game:GetService('RunService'))
local Workspace        = cloneref(game:GetService('Workspace'))

local LocalPlayer = Players.LocalPlayer

local FONT_HEAD = 'rbxasset://fonts/families/GothamSSm.json'
local FONT_BODY = 'rbxasset://fonts/families/SourceSansPro.json'

--=====================================================================
--  Localisation  (kept 1:1 with the original Stellar "GG" contract)
--=====================================================================
getgenv().GG = getgenv().GG or {
    SelectedLanguage = 'en',
    Language = {
        CheckboxEnabled  = 'Enabled',
        CheckboxDisabled = 'Disabled',
        SliderValue      = 'Value',
        DropdownSelect   = 'Select',
        DropdownNone     = 'None',
        DropdownSelected = 'Selected',
        ButtonClick      = 'Click',
        TextboxEnter     = 'Enter',
        ModuleEnabled    = 'Enabled',
        ModuleDisabled   = 'Disabled',
        TabGeneral       = 'General',
        TabSettings      = 'Settings',
        Loading          = 'Loading...',
        Error            = 'Error',
        Success          = 'Success'
    }
}

local GG = getgenv().GG
local LANG = GG.Language
local function tr(key, fallback)
    local value = LANG and LANG[key]
    if value == nil then return fallback or key end
    return value
end

--=====================================================================
--  Theme engine
--  Every colour in the interface flows through this table. Objects are
--  registered through `bind()` so `library:set_theme()` can live-swap
--  the entire palette without rebuilding the window.
--=====================================================================
local Theme_Presets = {
    -- Default: the cool indigo/sapphire palette from the reference shot.
    Stellar = {
        Accent      = Color3.fromRGB(88, 132, 255),
        Accent_2    = Color3.fromRGB(138, 104, 255),
        Accent_Soft = Color3.fromRGB(30, 44, 92),
        Panel       = Color3.fromRGB(11, 12, 21),
        Panel_2     = Color3.fromRGB(16, 18, 30),
        Panel_3     = Color3.fromRGB(23, 26, 41),
        Panel_4     = Color3.fromRGB(31, 35, 54),
        Border      = Color3.fromRGB(38, 43, 64),
        Text        = Color3.fromRGB(232, 234, 244),
        Muted       = Color3.fromRGB(140, 146, 170),
        Dim         = Color3.fromRGB(92, 98, 124),
        NotEnabled  = Color3.fromRGB(26, 29, 44),
        Success     = Color3.fromRGB(86, 214, 154),
        Warning     = Color3.fromRGB(230, 188, 100),
        Danger      = Color3.fromRGB(240, 100, 122)
    },
    -- Faithful to Ethereal.lua's own rose / graphite palette.
    Ethereal = {
        Accent      = Color3.fromRGB(203, 104, 118),
        Accent_2    = Color3.fromRGB(232, 138, 118),
        Accent_Soft = Color3.fromRGB(48, 24, 30),
        Panel       = Color3.fromRGB(12, 12, 14),
        Panel_2     = Color3.fromRGB(17, 17, 20),
        Panel_3     = Color3.fromRGB(23, 23, 28),
        Panel_4     = Color3.fromRGB(30, 30, 36),
        Border      = Color3.fromRGB(45, 45, 52),
        Text        = Color3.fromRGB(232, 232, 240),
        Muted       = Color3.fromRGB(144, 144, 160),
        Dim         = Color3.fromRGB(96, 96, 112),
        NotEnabled  = Color3.fromRGB(26, 26, 30),
        Success     = Color3.fromRGB(96, 212, 160),
        Warning     = Color3.fromRGB(230, 188, 64),
        Danger      = Color3.fromRGB(220, 96, 110)
    },
    Emerald = {
        Accent      = Color3.fromRGB(72, 199, 142),
        Accent_2    = Color3.fromRGB(120, 220, 170),
        Accent_Soft = Color3.fromRGB(18, 52, 40),
        Panel       = Color3.fromRGB(10, 15, 14),
        Panel_2     = Color3.fromRGB(15, 22, 20),
        Panel_3     = Color3.fromRGB(21, 31, 28),
        Panel_4     = Color3.fromRGB(28, 42, 37),
        Border      = Color3.fromRGB(38, 55, 48),
        Text        = Color3.fromRGB(230, 240, 236),
        Muted       = Color3.fromRGB(136, 156, 148),
        Dim         = Color3.fromRGB(88, 108, 100),
        NotEnabled  = Color3.fromRGB(23, 34, 30),
        Success     = Color3.fromRGB(120, 226, 168),
        Warning     = Color3.fromRGB(230, 188, 100),
        Danger      = Color3.fromRGB(232, 104, 122)
    },
    Amethyst = {
        Accent      = Color3.fromRGB(163, 116, 255),
        Accent_2    = Color3.fromRGB(214, 120, 255),
        Accent_Soft = Color3.fromRGB(42, 28, 74),
        Panel       = Color3.fromRGB(13, 11, 20),
        Panel_2     = Color3.fromRGB(19, 16, 29),
        Panel_3     = Color3.fromRGB(27, 22, 40),
        Panel_4     = Color3.fromRGB(36, 30, 53),
        Border      = Color3.fromRGB(50, 42, 72),
        Text        = Color3.fromRGB(236, 232, 246),
        Muted       = Color3.fromRGB(150, 142, 176),
        Dim         = Color3.fromRGB(102, 94, 128),
        NotEnabled  = Color3.fromRGB(29, 24, 44),
        Success     = Color3.fromRGB(110, 214, 168),
        Warning     = Color3.fromRGB(232, 190, 108),
        Danger      = Color3.fromRGB(240, 104, 140)
    }
}

local Theme = {}
for key, value in pairs(Theme_Presets.Stellar) do
    Theme[key] = value
end

local Theme_Name = 'Stellar'

local Theme_Bindings = {}
local Theme_Functions = {}

-- Register a colour property so it follows live theme changes.
local function bind(object, property, key)
    if not object then return object end
    table.insert(Theme_Bindings, { object = object, property = property, key = key })
    if Theme[key] ~= nil then
        object[property] = Theme[key]
    end
    return object
end

-- Register an arbitrary callback for things gradients / composite colours.
local function bind_fn(fn)
    table.insert(Theme_Functions, fn)
    fn()
end

local function apply_theme()
    for _, entry in ipairs(Theme_Bindings) do
        local object = entry.object
        if object and object.Parent and Theme[entry.key] ~= nil then
            object[entry.property] = Theme[entry.key]
        end
    end
    for _, fn in ipairs(Theme_Functions) do
        pcall(fn)
    end
end

--=====================================================================
--  Tiny instance / tween helpers
--=====================================================================
local function create(class, properties, parent)
    local object = Instance.new(class)
    if properties then
        for property, value in pairs(properties) do
            object[property] = value
        end
    end
    if parent then object.Parent = parent end
    return object
end

local function tween(object, duration, properties, style, direction)
    if not object then return end
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

local function corner(parent, radius, aspect)
    return create('UICorner', {
        CornerRadius = aspect and UDim.new(aspect, radius) or UDim.new(0, radius)
    }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return create('UIStroke', {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
end

local function padding(parent, top, right, bottom, left)
    return create('UIPadding', {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or right or top or 0)
    }, parent)
end

local function list_layout(parent, properties)
    local props = properties or {}
    props.SortOrder = props.SortOrder or Enum.SortOrder.LayoutOrder
    return create('UIListLayout', props, parent)
end

local function gradient(parent, color_sequence, rotation, transparency)
    local grad = create('UIGradient', {
        Color = color_sequence,
        Rotation = rotation or 0
    }, parent)
    if transparency then grad.Transparency = transparency end
    return grad
end

local function accent_gradient(parent, rotation)
    local grad = gradient(parent, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent_2)
    }), rotation or 0)
    bind_fn(function()
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.Accent_2)
        })
    end)
    return grad
end

local function font(weight)
    return Font.new(FONT_HEAD, weight or Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
end

local function body_font(weight)
    return Font.new(FONT_BODY, weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end

local function sound(parent, id, volume)
    return create('Sound', {
        Name = 'StellarSound',
        SoundId = 'rbxassetid://' .. tostring(id),
        Volume = volume or 0.4
    }, parent)
end

local function hex(color)
    return string.format('#%02X%02X%02X',
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5))
end

local function measure_text(text, width, text_size, weight)
    text = tostring(text or '')
    local ok, bounds = pcall(function()
        local params = Instance.new('GetTextBoundsParams')
        params.Text = text
        params.Font = Font.new(FONT_HEAD, weight or Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        params.Size = text_size
        params.Width = width
        return TextService:GetTextBoundsAsync(params)
    end)
    if ok and bounds then
        return math.max(text_size * 1.35, bounds.Y)
    end
    local per_line = math.max(1, math.floor(width / (text_size * 0.56)))
    local lines = math.max(1, math.ceil(#text / per_line))
    return text_size * 1.35 * lines
end

--=====================================================================
--  Connection bookkeeping
--=====================================================================
local Connections = {}

function Connections:disconnect(key)
    local connection = self[key]
    if connection and typeof(connection) == 'RBXScriptConnection' then
        pcall(function() connection:Disconnect() end)
    end
    self[key] = nil
end

function Connections:disconnect_all()
    local keys = {}
    for key in pairs(self) do
        if typeof(self[key]) == 'RBXScriptConnection' then
            table.insert(keys, key)
        end
    end
    for _, key in ipairs(keys) do
        pcall(function() self[key]:Disconnect() end)
        self[key] = nil
    end
end

--=====================================================================
--  Config persistence (same Stellar/<gameId>.json format as before)
--=====================================================================
local Config = {}

function Config:ensure_folder()
    pcall(function()
        if isfolder and not isfolder('Stellar') then
            makefolder('Stellar')
        end
    end)
end

function Config:save(file_name, config)
    self:ensure_folder()
    local ok, result = pcall(function()
        if not writefile then return false end
        writefile('Stellar/' .. file_name .. '.json', HttpService:JSONEncode(config))
        return true
    end)
    if not ok then
        warn('[Stellar] failed to save config:', result)
    end
end

function Config:load(file_name)
    local ok, result = pcall(function()
        if not (isfile and readfile) then return nil end
        if not isfile('Stellar/' .. file_name .. '.json') then
            return nil
        end
        local raw = readfile('Stellar/' .. file_name .. '.json')
        if not raw or raw == '' then return nil end
        return HttpService:JSONDecode(raw)
    end)

    if not ok then
        warn('[Stellar] failed to load config:', result)
    end

    if type(result) ~= 'table' then
        result = { _flags = {}, _keybinds = {}, _library = {} }
    end
    result._flags = result._flags or {}
    result._keybinds = result._keybinds or {}
    result._library = result._library or {}
    return result
end

--=====================================================================
--  Asset resolution (accepts raw ids, rbxassetid://, marketplace urls)
--=====================================================================
local Util = {}

function Util:map(value, in_min, in_max, out_min, out_max)
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function Util:resolve_asset_id(id)
    if id == nil then return nil end
    id = tostring(id)
    if id == '' then return nil end
    if id:match('^rbxassetid://') or id:match('^rbxthumb://') or id:match('^http') or id:match('^rbxasset://') then
        return id
    end
    local digits = id:match('(%d+)')
    if not digits then return nil end
    return 'rbxassetid://' .. digits
end

--=====================================================================
--  Animated logo (sprite sheets)
--=====================================================================
-- The original Stellar library shipped a little animated cat sprite and
-- Ethereal ships its own animated mark. Both are plain sprite sheets, so
-- we can play either one by stepping ImageRectOffset on an ImageLabel.
--
-- Each entry: image + the sheet's pixel size + its grid + frame count/fps.
local Logo_Animations = {
    Stellar = {
        image   = 'rbxassetid://74080484918102', -- Stellar cat (5 frames)
        width   = 60,  height = 40,
        columns = 3,   rows   = 2,
        frames  = 5,   fps    = 10
    },
    Ethereal = {
        image   = 'rbxassetid://133009150415671', -- Ethereal mark (8 frames)
        width   = 150, height = 120,
        columns = 3,   rows   = 3,
        frames  = 8,   fps    = 12
    }
}

-- Plays a sprite sheet on an ImageLabel. Returns a stop() function. The
-- loop self-terminates as soon as the label leaves the DataModel, so it
-- is safe to fire-and-forget.
function Util:animate_sprite(image_label, sheet)
    local noop = function() end
    if not image_label or type(sheet) ~= 'table' then return noop end

    local columns = math.max(1, tonumber(sheet.columns) or 1)
    local rows    = math.max(1, tonumber(sheet.rows) or 1)
    local frames  = math.max(1, tonumber(sheet.frames) or (columns * rows))
    local fps     = math.max(1, tonumber(sheet.fps) or 10)

    if sheet.image then
        image_label.Image = Util:resolve_asset_id(sheet.image) or sheet.image
    end

    local sheet_width  = tonumber(sheet.width) or 0
    local sheet_height = tonumber(sheet.height) or 0
    if sheet_width > 0 and sheet_height > 0 then
        image_label.ImageRectSize = Vector2.new(
            math.floor(sheet_width / columns),
            math.floor(sheet_height / rows)
        )
    end

    local frame_size = image_label.ImageRectSize
    if not frame_size or frame_size.X <= 0 or frame_size.Y <= 0 then
        return noop
    end

    local offsets = {}
    for index = 0, frames - 1 do
        local column = index % columns
        local row = math.floor(index / columns)
        offsets[index + 1] = Vector2.new(column * frame_size.X, row * frame_size.Y)
    end

    image_label.ImageRectOffset = offsets[1]

    local stopped = false
    local index = 1
    task.spawn(function()
        while not stopped and image_label and image_label.Parent do
            task.wait(1 / fps)
            if stopped or not image_label or not image_label.Parent then break end
            index = (index % frames) + 1
            image_label.ImageRectOffset = offsets[index]
        end
    end)

    return function() stopped = true end
end

-- Applies either an animated sprite sheet or a plain static image to a
-- logo ImageLabel and returns a stop() function.
--
-- options = {
--     animation = 'Stellar' | 'Ethereal' | <sheet table> | false,
--     image     = <asset id>   -- when given, shown statically
-- }
function Util:apply_logo(image_label, options)
    local noop = function() end
    if not image_label then return noop end
    options = options or {}

    local choice = options.animation
    local sheet

    if type(choice) == 'table' then
        sheet = choice
    elseif options.image == nil or options.image == false then
        if choice ~= false then
            sheet = Logo_Animations[choice or 'Stellar'] or Logo_Animations.Stellar
        end
    end

    if sheet then
        return Util:animate_sprite(image_label, sheet)
    end

    image_label.Image = Util:resolve_asset_id(options.image) or ''
    image_label.ImageRectSize = Vector2.new(0, 0)
    image_label.ImageRectOffset = Vector2.new(0, 0)
    return noop
end

--=====================================================================
--  Acrylic backdrop blur (ported from Stellar — quality gated)
--=====================================================================
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object)
    local self = setmetatable({
        _object = object,
        _folder = nil,
        _frame = nil,
        _root = nil
    }, AcrylicBlur)
    self:setup()
    return self
end

function AcrylicBlur:create_folder()
    local old = Workspace.CurrentCamera:FindFirstChild('StellarAcrylic')
    if old then
        Debris:AddItem(old, 0)
    end
    local folder = create('Folder', { Name = 'StellarAcrylic' }, Workspace.CurrentCamera)
    self._folder = folder
end

function AcrylicBlur:create_depth_of_fields()
    local dof = Lighting:FindFirstChild('StellarAcrylic') or create('DepthOfFieldEffect', {}, Lighting)
    dof.FarIntensity = 0
    dof.FocusDistance = 0.05
    dof.InFocusRadius = 0.1
    dof.NearIntensity = 1
    dof.Name = 'StellarAcrylic'
    dof.Parent = Lighting
end

function AcrylicBlur:create_frame()
    local frame = create('Frame', {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    }, self._object)
    self._frame = frame
end

function AcrylicBlur:create_root()
    local part = create('Part', {
        Name = 'Root',
        Color = Color3.new(0, 0, 0),
        Material = Enum.Material.Glass,
        Size = Vector3.new(1, 1, 0),
        Anchored = true,
        CanCollide = false,
        CanQuery = false,
        Locked = true,
        CastShadow = false,
        Transparency = 0.98
    }, self._folder)

    create('SpecialMesh', {
        Name = 'Mesh',
        MeshType = Enum.MeshType.Brick,
        Offset = Vector3.new(0, 0, -0.000001)
    }, part)

    self._root = part
end

function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()
    self:create_frame()
    self:render(0.001)
    self:check_quality_level()
end

function AcrylicBlur:render(distance)
    local positions = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new()
    }

    local function update_positions(size, position)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end

    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right

        local ray1 = Workspace.CurrentCamera:ScreenPointToRay(top_left.X, top_left.Y)
        local ray2 = Workspace.CurrentCamera:ScreenPointToRay(top_right.X, top_right.Y)
        local ray3 = Workspace.CurrentCamera:ScreenPointToRay(bottom_right.X, bottom_right.Y)

        local p1 = ray1.Origin + ray1.Direction * distance
        local p2 = ray2.Origin + ray2.Direction * distance
        local p3 = ray3.Origin + ray3.Direction * distance

        if not self._root or not self._root.Parent then return end

        local width = (p2 - p1).Magnitude
        local height = (p2 - p3).Magnitude

        self._root.CFrame = CFrame.fromMatrix(
            (p1 + p3) / 2,
            Workspace.CurrentCamera.CFrame.XVector,
            Workspace.CurrentCamera.CFrame.YVector,
            Workspace.CurrentCamera.CFrame.ZVector
        )

        local mesh = self._root:FindFirstChild('Mesh')
        if mesh then
            mesh.Scale = Vector3.new(math.max(width, 0.01), math.max(height, 0.01), 0)
        end
    end

    local function on_change()
        if not self._frame or not self._frame.Parent then return end
        local offset = Util:map(Workspace.CurrentCamera.ViewportSize.Y, 0, 2560, 8, 56)
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        update_positions(size, position)
        task.spawn(update)
    end

    Connections['acrylic_cframe'] = Workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections['acrylic_viewport'] = Workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update)
    Connections['acrylic_fov'] = Workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update)
    Connections['acrylic_pos'] = self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change)
    Connections['acrylic_size'] = self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change)

    task.spawn(update)
end

function AcrylicBlur:check_quality_level()
    local ok, settings = pcall(function()
        return UserSettings().GameSettings
    end)
    if not ok or not settings then return end

    local quality = settings.SavedQualityLevel.Value
    self:set_visible(quality >= 8)

    Connections['acrylic_quality'] = settings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        self:set_visible(settings.SavedQualityLevel.Value >= 8)
    end)
end

function AcrylicBlur:set_visible(state)
    if self._root and self._root.Parent then
        self._root.Transparency = state and 0.98 or 1
    end
end

--=====================================================================
--  Small vector glyphs drawn with frames (no asset dependencies)
--=====================================================================
local function draw_chevron(parent, size, color, thickness)
    size = size or 8
    thickness = thickness or 1.6
    local holder = create('Frame', {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5)
    }, parent)

    create('Frame', {
        Size = UDim2.new(0, size * 0.62, 0, thickness),
        Position = UDim2.new(0, size * 0.02, 0, size * 0.34),
        AnchorPoint = Vector2.new(0, 0.5),
        Rotation = 40,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    create('Frame', {
        Size = UDim2.new(0, size * 0.62, 0, thickness),
        Position = UDim2.new(1, -size * 0.02, 0, size * 0.34),
        AnchorPoint = Vector2.new(1, 0.5),
        Rotation = -40,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    return holder
end

local function draw_check(parent, color, thickness)
    thickness = thickness or 1.8
    local holder = create('Frame', {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    }, parent)

    create('Frame', {
        Size = UDim2.new(0, 5, 0, thickness),
        Position = UDim2.new(0.5, -2, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Rotation = 45,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    create('Frame', {
        Size = UDim2.new(0, 9, 0, thickness),
        Position = UDim2.new(0.5, 1, 0.5, -1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Rotation = -45,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    return holder
end

local function draw_magnifier(parent, color, size)
    size = size or 12
    local holder = create('Frame', {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1
    }, parent)

    local ring = create('Frame', {
        Size = UDim2.fromOffset(size * 0.62, size * 0.62),
        Position = UDim2.fromOffset(size * 0.05, size * 0.05),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, holder)
    corner(ring, 1, 1)
    create('UIStroke', {
        Color = color,
        Thickness = 1.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, ring)

    create('Frame', {
        Size = UDim2.fromOffset(size * 0.34, 1.4),
        Position = UDim2.fromOffset(size * 0.6, size * 0.66),
        Rotation = 45,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    return holder
end

--=====================================================================
--  Global tooltip
--=====================================================================
local Tooltip = { _gui = nil, _frame = nil, _label = nil, _token = 0 }

function Tooltip.ensure()
    if Tooltip._gui and Tooltip._gui.Parent then return end

    local gui = create('ScreenGui', {
        Name = 'StellarTooltip',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 2000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    local frame = create('Frame', {
        Name = 'Tip',
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false,
        ZIndex = 2
    }, gui)
    corner(frame, 6)
    stroke(frame, Theme.Border, 1, 0.2)
    padding(frame, 5, 9, 5, 9)

    local label = create('TextLabel', {
        Name = 'Text',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Medium),
        TextColor3 = Theme.Text,
        TextSize = 11,
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = '',
        ZIndex = 3
    }, frame)

    Tooltip._gui = gui
    Tooltip._frame = frame
    Tooltip._label = label
    bind(frame, 'BackgroundColor3', 'Panel_3')
    bind(label, 'TextColor3', 'Text')
end

function Tooltip.show(text)
    Tooltip.ensure()
    Tooltip._token = Tooltip._token + 1
    local token = Tooltip._token
    Tooltip._label.Text = text
    Tooltip._frame.Visible = true
    Tooltip._frame.BackgroundTransparency = 1
    Tooltip._label.TextTransparency = 1
    tween(Tooltip._frame, 0.16, { BackgroundTransparency = 0.05 })
    tween(Tooltip._label, 0.16, { TextTransparency = 0 })

    task.spawn(function()
        while Tooltip._token == token and Tooltip._frame.Visible do
            local mouse = UserInputService:GetMouseLocation()
            Tooltip._frame.Position = UDim2.fromOffset(mouse.X + 16, mouse.Y + 18)
            task.wait()
        end
    end)
end

function Tooltip.hide()
    if not Tooltip._frame then return end
    Tooltip._token = Tooltip._token + 1
    tween(Tooltip._frame, 0.12, { BackgroundTransparency = 1 })
    tween(Tooltip._label, 0.12, { TextTransparency = 1 })
    task.delay(0.13, function()
        if Tooltip._frame then Tooltip._frame.Visible = false end
    end)
end

function Tooltip.attach(object, text)
    if not object or not text then return end
    local pending = nil
    object.MouseEnter:Connect(function()
        if pending then task.cancel(pending) end
        pending = task.delay(0.4, function()
            Tooltip.show(text)
        end)
    end)
    object.MouseLeave:Connect(function()
        if pending then task.cancel(pending) pending = nil end
        Tooltip.hide()
    end)
end

--=====================================================================
--  Toast notifications
--=====================================================================
local Notifications = { _gui = nil, _container = nil }

local NOTIFY_COLORS = {
    info    = 'Accent',
    success = 'Success',
    warning = 'Warning',
    error   = 'Danger'
}

local NOTIFY_GLYPHS = {
    info = 'i',
    success = '✓',
    warning = '!',
    error = '×'
}

function Notifications.ensure()
    if Notifications._gui and Notifications._gui.Parent then return end

    local gui = create('ScreenGui', {
        Name = 'StellarNotifications',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1500,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    local container = create('Frame', {
        Name = 'Stack',
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.new(0, 306, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, gui)

    list_layout(container, { Padding = UDim.new(0, 10) })

    Notifications._gui = gui
    Notifications._container = container
end

function Notifications.push(settings)
    settings = settings or {}
    Notifications.ensure()

    local kind = settings.type or 'info'
    local color_key = NOTIFY_COLORS[kind] or 'Accent'
    local title_text = settings.title or tr('Success', 'Notification')
    local body_text = tostring(settings.text or '')

    -- Compute the toast height up front. Relying on AutomaticSize here made
    -- the card jump around because its children are absolutely positioned.
    local width = 306
    local text_width = width - 72
    local body_height = body_text ~= '' and math.max(14, measure_text(body_text, text_width, 10)) or 0
    local height = math.max(62, 31 + body_height + (body_text ~= '' and 9 or 0) + 16)

    local toast = create('CanvasGroup', {
        Name = 'Toast',
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Panel_2,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ClipsDescendants = false
    }, Notifications._container)
    corner(toast, 10)
    local toast_stroke = stroke(toast, Theme.Border, 1, 0.25)
    bind(toast, 'BackgroundColor3', 'Panel_2')

    local accent_bar = create('Frame', {
        Name = 'Accent',
        Size = UDim2.new(0, 3, 0, math.max(16, height - 16)),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundColor3 = Theme[color_key],
        BorderSizePixel = 0
    }, toast)
    corner(accent_bar, 1, 1)
    bind(accent_bar, 'BackgroundColor3', color_key)

    local icon_holder = create('Frame', {
        Name = 'Icon',
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(15, 14),
        BackgroundColor3 = Theme[color_key],
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0
    }, toast)
    corner(icon_holder, 1, 1)
    bind(icon_holder, 'BackgroundColor3', color_key)

    -- The glyph label must fill its holder: without an explicit Size a
    -- TextLabel defaults to 0x0 and the icon is invisible.
    local icon_label = create('TextLabel', {
        Name = 'Glyph',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme[color_key],
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Text = NOTIFY_GLYPHS[kind] or 'i'
    }, icon_holder)
    bind(icon_label, 'TextColor3', color_key)

    local title = create('TextLabel', {
        Name = 'Title',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = title_text,
        Size = UDim2.new(1, -92, 0, 15),
        Position = UDim2.fromOffset(56, 15)
    }, toast)
    bind(title, 'TextColor3', 'Text')

    local body
    if body_text ~= '' then
        body = create('TextLabel', {
            Name = 'Body',
            BackgroundTransparency = 1,
            FontFace = body_font(Enum.FontWeight.Regular),
            TextColor3 = Theme.Muted,
            TextSize = 10,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = body_text,
            Size = UDim2.new(1, -72, 0, body_height),
            Position = UDim2.fromOffset(56, 33)
        }, toast)
        bind(body, 'TextColor3', 'Muted')
    end

    local close = create('TextButton', {
        Name = 'Close',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Dim,
        TextSize = 15,
        Text = '×',
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -30, 0, 9),
        AutoButtonColor = false
    }, toast)
    bind(close, 'TextColor3', 'Dim')

    local progress_track = create('Frame', {
        Name = 'ProgressTrack',
        Size = UDim2.new(1, -30, 0, 3),
        Position = UDim2.new(0, 15, 1, -11),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0
    }, toast)
    corner(progress_track, 1, 1)
    bind(progress_track, 'BackgroundColor3', 'Panel_4')

    local progress_fill = create('Frame', {
        Name = 'ProgressFill',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme[color_key],
        BorderSizePixel = 0
    }, progress_track)
    corner(progress_fill, 1, 1)
    bind(progress_fill, 'BackgroundColor3', color_key)

    local duration = tonumber(settings.duration) or 5
    local dismissed = false

    local function dismiss()
        if dismissed then return end
        dismissed = true
        -- Fade the whole group at once: a UIListLayout owns child Position,
        -- so sliding is not possible, and per-child fades can leave text
        -- floating over a transparent card.
        tween(toast, 0.28, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(toast_stroke, 0.2, { Transparency = 1 })
        task.delay(0.32, function()
            if toast then toast:Destroy() end
        end)
    end

    close.MouseButton1Click:Connect(dismiss)

    -- entrance: fade the group in so the border, icon and text arrive together
    tween(toast, 0.4, { GroupTransparency = 0 })
    if duration > 0 then
        tween(progress_fill, duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)
        task.delay(duration, dismiss)
    else
        progress_track.Visible = false
    end
end

--=====================================================================
--  Loader
--=====================================================================
local Library = {}

function Library.create_loader(self, settings)
    settings = settings or {}

    local old = CoreGui:FindFirstChild('StellarLoader')
    if old then old:Destroy() end

    local accent = settings.accent_color or Theme.Accent
    local stages = settings.stages or { settings.title or 'Loading' }
    if #stages == 0 then stages = { settings.title or 'Loading' } end
    local rng = Random.new()
    local particles_alive = true
    local closed = false
    local auto_running = false

    local gui = create('ScreenGui', {
        Name = 'StellarLoader',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    local backdrop = create('Frame', {
        Name = 'Backdrop',
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = settings.backdrop_color or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0
    }, gui)

    if settings.dim_background ~= false then
        tween(backdrop, 0.4, { BackgroundTransparency = settings.backdrop_transparency or 0.15 })
    end

    -- Ambient sparkles drifting slowly behind the logo. Each one fades in,
    -- drifts upward, fades out, then respawns elsewhere.
    local particle_layer = create('Frame', {
        Name = 'ParticleLayer',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 1
    }, gui)

    local function spawn_particle()
        local dot = create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(rng:NextNumber(2, 4), rng:NextNumber(2, 4)),
            Position = UDim2.new(rng:NextNumber(0.35, 0.65), 0, rng:NextNumber(0.4, 0.7), 0),
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 1
        }, particle_layer)
        corner(dot, 0, 1)

        task.spawn(function()
            while particles_alive and dot and dot.Parent do
                local target_y = dot.Position.Y.Scale - rng:NextNumber(0.05, 0.12)
                tween(dot, rng:NextNumber(2, 3.2), {
                    BackgroundTransparency = rng:NextNumber(0.3, 0.6),
                    Position = UDim2.new(dot.Position.X.Scale, 0, target_y, 0)
                }, Enum.EasingStyle.Sine)
                task.wait(rng:NextNumber(2, 3.2))
                if not (particles_alive and dot and dot.Parent) then break end
                tween(dot, 0.8, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
                task.wait(0.8)
                if dot and dot.Parent then
                    dot.Position = UDim2.new(rng:NextNumber(0.3, 0.7), 0, rng:NextNumber(0.55, 0.75), 0)
                end
            end
        end)
    end

    for _ = 1, 12 do spawn_particle() end

    local container = create('Frame', {
        Name = 'LoaderContainer',
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(300, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 2
    }, gui)

    list_layout(container, {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 16)
    })

    -- Responsive scaling so the loader never looks oversized on a phone or
    -- tiny on a large display.
    local scale = create('UIScale', {}, container)
    local function update_scale()
        local camera = Workspace.CurrentCamera
        if camera then
            scale.Scale = math.clamp(camera.ViewportSize.X / 1280, 0.7, 1.5)
        end
    end
    update_scale()
    local scale_connection
    local camera = Workspace.CurrentCamera
    if camera then
        scale_connection = camera:GetPropertyChangedSignal('ViewportSize'):Connect(update_scale)
    end

    -- Logo tile: a rounded accent chip holding the animated sprite, with a
    -- soft glow that gently pulses behind it.
    local logo_holder = create('Frame', {
        LayoutOrder = 1,
        Size = UDim2.fromOffset(76, 76),
        BackgroundTransparency = 1,
        ZIndex = 2
    }, container)

    local glow = create('Frame', {
        Name = 'Glow',
        Size = UDim2.fromOffset(78, 78),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        ZIndex = 1
    }, logo_holder)
    corner(glow, 0, 1)

    local logo_bg = create('Frame', {
        Name = 'LogoMark',
        Size = UDim2.fromOffset(62, 62),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 2
    }, logo_holder)
    corner(logo_bg, 18)
    accent_gradient(logo_bg, 135)
    local logo_scale = create('UIScale', { Scale = 0.4 }, logo_bg)

    -- Thin accent arc that orbits the mark. A transparent gradient on the
    -- stroke makes it read as a spinner rather than a static ring.
    local ring = create('Frame', {
        Name = 'Ring',
        Size = UDim2.fromOffset(72, 72),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Rotation = 0,
        ZIndex = 3
    }, logo_holder)
    corner(ring, 0, 1)
    local ring_stroke = create('UIStroke', {
        Color = accent,
        Thickness = 2,
        Transparency = 0.3,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, ring)
    gradient(ring_stroke, ColorSequence.new({
        ColorSequenceKeypoint.new(0, accent),
        ColorSequenceKeypoint.new(1, accent)
    }), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.9),
        NumberSequenceKeypoint.new(1, 0)
    }))

    local ring_angle = 0
    task.spawn(function()
        while not closed and ring and ring.Parent do
            ring_angle = ring_angle + 360
            tween(ring, 1.8, { Rotation = ring_angle }, Enum.EasingStyle.Linear)
            task.wait(1.8)
        end
    end)

    local logo_image = create('ImageLabel', {
        Name = 'Logo',
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 3
    }, logo_bg)
    local stop_logo = Util:apply_logo(logo_image, {
        animation = settings.animation or Library.Logo_Animation,
        image = settings.logo
    })

    -- Pop the mark in with a little overshoot.
    tween(logo_image, 0.6, { ImageTransparency = 0 }, Enum.EasingStyle.Back)
    tween(logo_scale, 0.6, { Scale = 1 }, Enum.EasingStyle.Back)

    -- Keep the glow breathing while the loader is alive.
    task.spawn(function()
        while not closed and glow and glow.Parent do
            tween(glow, 1.5, { BackgroundTransparency = 0.74, Size = UDim2.fromOffset(90, 90) }, Enum.EasingStyle.Sine)
            task.wait(1.5)
            if closed or not (glow and glow.Parent) then break end
            tween(glow, 1.5, { BackgroundTransparency = 0.9, Size = UDim2.fromOffset(78, 78) }, Enum.EasingStyle.Sine)
            task.wait(1.5)
        end
    end)

    local title = create('TextLabel', {
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 13,
        Text = settings.title or 'Preparing interface',
        Size = UDim2.fromOffset(300, 16),
        ZIndex = 2
    }, container)
    bind(title, 'TextColor3', 'Text')

    local bar = create('Frame', {
        LayoutOrder = 3,
        Size = UDim2.fromOffset(240, 4),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2
    }, container)
    corner(bar, 2)
    bind(bar, 'BackgroundColor3', 'Panel_3')

    local fill = create('Frame', {
        Name = 'Fill',
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 3
    }, bar)
    corner(fill, 2)
    accent_gradient(fill, 0)

    -- Highlight that sweeps across the fill as it grows.
    local shimmer = create('Frame', {
        Name = 'Shimmer',
        Size = UDim2.fromScale(0.5, 1),
        Position = UDim2.fromScale(-0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 4
    }, fill)
    gradient(shimmer, ColorSequence.new(Color3.fromRGB(255, 255, 255)), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.25),
        NumberSequenceKeypoint.new(1, 1)
    }))

    task.spawn(function()
        while not closed and shimmer and shimmer.Parent do
            shimmer.Position = UDim2.fromScale(-0.5, 0)
            tween(shimmer, 1.1, { Position = UDim2.fromScale(1, 0) }, Enum.EasingStyle.Sine)
            task.wait(1.4)
        end
    end)

    local stage_label = create('TextLabel', {
        LayoutOrder = 4,
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Muted,
        TextSize = 11,
        Text = stages[1] or 'Loading...',
        Size = UDim2.fromOffset(300, 14),
        ZIndex = 2
    }, container)
    bind(stage_label, 'TextColor3', 'Muted')

    -- Stage text crossfade. The token guards against stacked delays when
    -- progress updates arrive faster than the fade completes.
    local current_stage = 1
    local stage_token = 0
    local function set_stage_text(text)
        if not stage_label or not stage_label.Parent then return end
        stage_token = stage_token + 1
        local token = stage_token
        tween(stage_label, 0.12, { TextTransparency = 1 })
        task.delay(0.12, function()
            if closed or token ~= stage_token then return end
            if not (stage_label and stage_label.Parent) then return end
            stage_label.Text = text
            tween(stage_label, 0.22, { TextTransparency = 0 })
        end)
    end

    -- Bloom: the tile opens a little further with every stage it clears.
    local bloom_base = 1
    local bloom_peak = tonumber(settings.bloom_scale) or 1.35
    local bloom_duration = tonumber(settings.bloom_duration) or 0.5
    local function bloom_to_stage(index)
        if not (logo_scale and logo_scale.Parent) then return end
        local alpha = math.clamp(index / math.max(#stages, 1), 0, 1)
        local target = bloom_base + (bloom_peak - bloom_base) * alpha
        tween(logo_scale, bloom_duration, { Scale = target }, Enum.EasingStyle.Back)
    end

    -- Completion burst radiating from the mark.
    local bursted = false
    local function burst()
        if bursted then return end
        bursted = true
        for _ = 1, 16 do
            local dot = create('Frame', {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.fromOffset(rng:NextNumber(3, 6), rng:NextNumber(3, 6)),
                Position = UDim2.fromScale(0.5, 0.5),
                BackgroundColor3 = accent,
                BorderSizePixel = 0,
                ZIndex = 4
            }, logo_holder)
            corner(dot, 0, 1)

            local angle = rng:NextNumber(0, math.pi * 2)
            local distance = rng:NextNumber(26, 52)
            tween(dot, rng:NextNumber(0.5, 0.85), {
                Position = UDim2.new(0.5, math.cos(angle) * distance, 0.5, math.sin(angle) * distance),
                BackgroundTransparency = 1
            }, Enum.EasingStyle.Quad)
            Debris:AddItem(dot, 1.2)
        end
        if logo_scale and logo_scale.Parent then
            tween(logo_scale, 0.3, { Scale = bloom_peak * 1.12 }, Enum.EasingStyle.Back)
        end
    end

    local loader = { _gui = gui }

    function loader:set_stage(text)
        if closed then return end
        set_stage_text(text)
    end

    function loader:set_progress(alpha, instant)
        if closed then return end
        alpha = math.clamp(alpha or 0, 0, 1)
        -- `instant` is used by the auto-progress driver: it updates the bar
        -- every frame, so tweening each step would stack dozens of tweens
        -- and make the bar stutter. Manual calls still animate smoothly.
        if instant then
            fill.Size = UDim2.new(alpha, 0, 1, 0)
        else
            tween(fill, 0.25, { Size = UDim2.new(alpha, 0, 1, 0) }, Enum.EasingStyle.Quint)
        end
        local index = math.min(#stages, math.floor(alpha * #stages) + 1)
        if index ~= current_stage then
            current_stage = index
            set_stage_text(stages[index])
            bloom_to_stage(index)
        end
        if alpha >= 1 then burst() end
    end

    -- Idempotent close: teardown happens once, and an explicit override
    -- callback still fires even if the loader already closed itself.
    function loader:close(override_callback)
        if closed then
            if override_callback then override_callback() end
            return
        end
        closed = true
        auto_running = false
        particles_alive = false
        if scale_connection then scale_connection:Disconnect() end
        if stop_logo then stop_logo() end

        tween(backdrop, 0.4, { BackgroundTransparency = 1 })
        tween(container, 0.35, { Position = UDim2.fromScale(0.5, 0.54) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        for _, descendant in ipairs(container:GetDescendants()) do
            if descendant:IsA('GuiObject') then
                tween(descendant, 0.3, { BackgroundTransparency = 1 })
            end
            if descendant:IsA('TextLabel') then
                tween(descendant, 0.3, { TextTransparency = 1 })
            end
            if descendant:IsA('ImageLabel') then
                tween(descendant, 0.3, { ImageTransparency = 1 })
            end
        end

        task.wait(0.4)
        gui:Destroy()

        local callback = override_callback or settings.callback
        if callback then callback() end
    end

    set_stage_text(stages[1])

    if settings.auto_progress then
        auto_running = true
        task.spawn(function()
            local duration = math.max(0.1, tonumber(settings.duration) or 2.6)
            local start = os.clock()
            while auto_running and not closed do
                local elapsed = os.clock() - start
                loader:set_progress(math.min(elapsed / duration, 1), true)
                if elapsed >= duration then break end
                task.wait(0.03)
            end
            if not closed then
                loader:set_progress(1, true)
                task.wait(0.45)
                if not closed then loader:close() end
            end
        end)
    end

    return loader
end

--=====================================================================
--  Library core
--=====================================================================
Library._config = Config:load(game.GameId)

-- Look & feel knobs. Set these before calling `Library.new()`.
--
-- The drop shadow is OFF by default: the panel already has a crisp 1px
-- hairline border, and a soft halo read as a distracting blur. Turn it on
-- (with a hairline spread) only if you want a little lift.
Library.Shadow = false            -- draw a subtle drop shadow behind the window
Library.Shadow_Spread = 4         -- total extra pixels (2px each side)
Library.Shadow_Drop = 1           -- downward offset of the shadow
Library.Shadow_Transparency = 0.6

-- Acrylic backdrop blur is opt-in. It renders a glass plane + depth of
-- field behind the window, which some GPUs/executors draw as a large
-- smear. Enable with `library.Acrylic = true` before `library:load()`.
Library.Acrylic = false

Library.Logo_Animation = 'Stellar' -- 'Stellar' | 'Ethereal' | sheet table | false
Library.Logo = nil                 -- set to an asset id to use a static image

Library._choosing_keybind = false
Library._device = nil

Library._ui_open = true
Library._ui_scale = 1
Library._ui_loaded = false
Library._ui = nil

Library._dragging = false
Library._drag_start = nil
Library._container_position = nil

Library._refs = {}
Library._tabs = {}
Library._search_items = {}
Library._active_tab = nil
Library._search_text = ''

Library.Theme = Theme
Library.Theme_Presets = Theme_Presets

Library.__index = Library

function Library.new()
    -- Every mutable field lives on the instance so multiple windows can
    -- coexist without sharing tabs, search results or visibility state.
    local self = setmetatable({
        _loaded = false,
        _tab = 0,
        _ui = nil,
        _ui_open = true,
        _ui_loaded = false,
        _ui_scale = 1,
        _refs = {},
        _tabs = {},
        _search_items = {},
        _active_tab = nil,
        _search_text = '',
        _dragging = false,
        _drag_start = nil,
        _container_position = nil,
        _choosing_keybind = false
    }, Library)

    self:create_ui()

    return self
end

function Library:flag_type(flag, flag_type)
    if not self._config._flags[flag] then return false end
    return typeof(self._config._flags[flag]) == flag_type
end

function Library:remove_table_value(tbl, value)
    for index = #tbl, 1, -1 do
        if tbl[index] == value then
            table.remove(tbl, index)
        end
    end
end

function Library:get_screen_scale()
    local viewport = Workspace.CurrentCamera.ViewportSize.X
    self._ui_scale = math.clamp(viewport / 1400, 0.62, 1.35)
end

function Library:get_device()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        self._device = 'Mobile'
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        self._device = 'Console'
    else
        self._device = 'PC'
    end
end

function Library:removed(action)
    if self._ui then
        self._ui.AncestryChanged:Once(action)
    end
end

-- Public notification entry point. Supports both the dot form
-- (`Library.SendNotification{...}`) and the colon form used by most
-- scripts (`library:SendNotification{...}`). When called with a colon the
-- library instance arrives as the first argument, so unwrap it here.
function Library.SendNotification(first, second)
    local settings = second
    if settings == nil then
        local is_instance = type(first) == 'table'
            and (first == Library or getmetatable(first) == Library)
        settings = is_instance and nil or first
    end
    Notifications.push(settings)
end
Library.notify = Library.SendNotification

--=====================================================================
--  Theme API
--=====================================================================
function Library:get_theme()
    return Theme_Name
end

function Library:get_themes()
    local names = {}
    for name in pairs(Theme_Presets) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function Library:set_theme(name_or_table)
    local preset
    if type(name_or_table) == 'string' then
        preset = Theme_Presets[name_or_table]
        if not preset then
            warn('[Stellar] unknown theme "' .. tostring(name_or_table) .. '"')
            return false
        end
        Theme_Name = name_or_table
    elseif type(name_or_table) == 'table' then
        preset = name_or_table
        Theme_Name = 'Custom'
    else
        return false
    end

    for key, value in pairs(preset) do
        Theme[key] = value
    end
    apply_theme()
    return true
end

function Library:set_accent(color)
    if typeof(color) ~= 'Color3' then return false end
    Theme.Accent = color
    Theme.Accent_2 = Color3.new(
        math.min(color.R * 1.18, 1),
        math.min(color.G * 1.18, 1),
        math.min(color.B * 1.18, 1)
    )
    Theme.Accent_Soft = Color3.new(color.R * 0.24, color.G * 0.24, color.B * 0.3)
    Theme_Name = 'Custom'
    apply_theme()
    return true
end

--=====================================================================
--  Window construction
--=====================================================================
function Library:create_ui()
    local old = CoreGui:FindFirstChild('Stellar')
    if old then old:Destroy() end

    local Stellar = create('ScreenGui', {
        Name = 'Stellar',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    -- Optional hairline drop shadow (off by default). When enabled it adds
    -- only a couple of pixels of depth — never a big blurred halo.
    local shadow
    local shadow_spread = tonumber(Library.Shadow_Spread) or 4
    local shadow_drop = tonumber(Library.Shadow_Drop) or 1
    if Library.Shadow == true then
        shadow = create('Frame', {
            Name = 'Shadow',
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = tonumber(Library.Shadow_Transparency) or 0.6,
            BorderSizePixel = 0,
            ZIndex = 1
        }, Stellar)
        corner(shadow, 18)
    end

    local Container = create('CanvasGroup', {
        Name = 'Container',
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        GroupTransparency = 1,
        ZIndex = 2
    }, Stellar)
    corner(Container, 16)
    local container_stroke = stroke(Container, Theme.Border, 1, 0.25)
    bind(Container, 'BackgroundColor3', 'Panel')
    bind(container_stroke, 'Color', 'Border')

    local WIN_W, WIN_H = 720, 470
    local TOPBAR_H = 50
    local SIDEBAR_W = 170
    local BODY_H = WIN_H - TOPBAR_H

    local function sync_shadow()
        if not shadow then return end
        shadow.Position = UDim2.new(
            Container.Position.X.Scale, Container.Position.X.Offset,
            Container.Position.Y.Scale, Container.Position.Y.Offset + shadow_drop
        )
        shadow.Size = UDim2.fromOffset(
            Container.Size.X.Offset + shadow_spread,
            Container.Size.Y.Offset + shadow_spread
        )
    end
    Container:GetPropertyChangedSignal('Size'):Connect(sync_shadow)
    Container:GetPropertyChangedSignal('Position'):Connect(sync_shadow)
    sync_shadow()

    -- top accent hairline
    local accent_line = create('Frame', {
        Name = 'AccentLine',
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 5
    }, Container)
    gradient(accent_line, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.Accent_2),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    }), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }))
    bind_fn(function()
        accent_line.BackgroundColor3 = Theme.Accent
    end)

    --=================================================================
    --  Top bar
    --=================================================================
    local TopBar = create('Frame', {
        Name = 'TopBar',
        Size = UDim2.new(1, 0, 0, TOPBAR_H),
        BackgroundTransparency = 1,
        ZIndex = 4
    }, Container)

    local Drag = create('TextButton', {
        Name = 'Drag',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 1
    }, TopBar)

    -- Top-left animated logo. Doubles as the open/minimize toggle.
    local LogoMark = create('TextButton', {
        Name = 'LogoMark',
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(16, 10),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 3
    }, TopBar)
    corner(LogoMark, 9)
    accent_gradient(LogoMark, 135)
    local logo_stroke = stroke(LogoMark, Theme.Accent_2, 1, 0.5)
    bind(logo_stroke, 'Color', 'Accent_2')

    local LogoImage = create('ImageLabel', {
        Name = 'Logo',
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 4
    }, LogoMark)
    local logo_scale = create('UIScale', { Scale = 1 }, LogoImage)
    Util:apply_logo(LogoImage, {
        animation = Library.Logo_Animation,
        image = Library.Logo
    })

    LogoMark.MouseEnter:Connect(function()
        tween(logo_stroke, 0.18, { Transparency = 0 })
        tween(logo_scale, 0.18, { Scale = 1.12 })
    end)
    LogoMark.MouseLeave:Connect(function()
        tween(logo_stroke, 0.18, { Transparency = 0.5 })
        tween(logo_scale, 0.18, { Scale = 1 })
    end)

    local Product = create('TextLabel', {
        Name = 'Product',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Stellar',
        Size = UDim2.fromOffset(120, 16),
        Position = UDim2.fromOffset(56, 10),
        ZIndex = 3
    }, TopBar)
    bind(Product, 'TextColor3', 'Text')

    local Edition = create('Frame', {
        Name = 'Edition',
        Size = UDim2.fromOffset(58, 15),
        Position = UDim2.fromOffset(56, 27),
        BackgroundColor3 = Theme.Accent_Soft,
        BorderSizePixel = 0,
        ZIndex = 3
    }, TopBar)
    corner(Edition, 4)
    bind(Edition, 'BackgroundColor3', 'Accent_Soft')

    local EditionLabel = create('TextLabel', {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Accent,
        TextSize = 8,
        Text = 'ETHEREAL',
        ZIndex = 4
    }, Edition)
    bind(EditionLabel, 'TextColor3', 'Accent')

    -- window controls (the top-left logo handles open/minimize now)
    local Controls = create('Frame', {
        Name = 'Controls',
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, TopBar)

    local function make_control(glyph, order)
        local button = create('TextButton', {
            Name = glyph,
            Size = UDim2.fromOffset(26, 26),
            Position = UDim2.fromOffset(order * 32, 0),
            BackgroundColor3 = Theme.Panel_3,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Muted,
            TextSize = 15,
            Text = glyph,
            AutoButtonColor = false,
            ZIndex = 3
        }, Controls)
        corner(button, 8)
        bind(button, 'BackgroundColor3', 'Panel_3')
        bind(button, 'TextColor3', 'Muted')
        button.MouseEnter:Connect(function()
            tween(button, 0.18, { BackgroundTransparency = 0, TextColor3 = Theme.Text })
        end)
        button.MouseLeave:Connect(function()
            tween(button, 0.18, { BackgroundTransparency = 0.35, TextColor3 = Theme.Muted })
        end)
        return button
    end

    local Close = make_control('×', 0)
    Tooltip.attach(Close, 'Close interface')
    Tooltip.attach(LogoMark, 'Minimize / open')

    -- search
    local SearchBox = create('Frame', {
        Name = 'Search',
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -52, 0.5, 0),
        Size = UDim2.fromOffset(180, 28),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        ZIndex = 3
    }, TopBar)
    corner(SearchBox, 8)
    local search_stroke = stroke(SearchBox, Theme.Border, 1, 0.4)
    bind(SearchBox, 'BackgroundColor3', 'Panel_2')
    bind(search_stroke, 'Color', 'Border')

    local search_icon_holder = create('Frame', {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromOffset(9, 7),
        BackgroundTransparency = 1,
        ZIndex = 4
    }, SearchBox)
    local search_icon = draw_magnifier(search_icon_holder, Theme.Dim, 14)
    bind_fn(function()
        for _, child in ipairs(search_icon:GetDescendants()) do
            if child:IsA('Frame') and child.BackgroundTransparency == 0 then
                child.BackgroundColor3 = Theme.Dim
            end
            if child:IsA('UIStroke') then
                child.Color = Theme.Dim
            end
        end
    end)

    local SearchInput = create('TextBox', {
        Name = 'Input',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Dim,
        PlaceholderText = 'Search features...',
        TextSize = 11,
        Text = '',
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Size = UDim2.new(1, -34, 1, 0),
        Position = UDim2.fromOffset(28, 0),
        ZIndex = 4
    }, SearchBox)
    bind(SearchInput, 'TextColor3', 'Text')
    bind(SearchInput, 'PlaceholderColor3', 'Dim')

    SearchInput.Focused:Connect(function()
        tween(search_stroke, 0.2, { Color = Theme.Accent, Transparency = 0.1 })
    end)
    SearchInput.FocusLost:Connect(function()
        tween(search_stroke, 0.2, { Color = Theme.Border, Transparency = 0.4 })
    end)

    --=================================================================
    --  Body
    --=================================================================
    local Body = create('Frame', {
        Name = 'Body',
        Size = UDim2.new(1, 0, 1, -TOPBAR_H),
        Position = UDim2.fromOffset(0, TOPBAR_H),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, Container)

    -- sidebar ------------------------------------------------------
    local Sidebar = create('Frame', {
        Name = 'Sidebar',
        Size = UDim2.fromOffset(SIDEBAR_W, BODY_H),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Body)
    bind(Sidebar, 'BackgroundColor3', 'Panel')

    local sidebar_line = create('Frame', {
        Size = UDim2.new(0, 1, 1, -24),
        Position = UDim2.new(1, -1, 0, 12),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0
    }, Sidebar)
    bind(sidebar_line, 'BackgroundColor3', 'Border')

    -- user card
    local UserCard = create('Frame', {
        Name = 'UserCard',
        Size = UDim2.new(1, -24, 0, 54),
        Position = UDim2.fromOffset(12, 14),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Sidebar)
    corner(UserCard, 10)
    local user_stroke = stroke(UserCard, Theme.Border, 1, 0.5)
    bind(UserCard, 'BackgroundColor3', 'Panel_2')
    bind(user_stroke, 'Color', 'Border')

    local Avatar = create('Frame', {
        Name = 'Avatar',
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0,
        ZIndex = 4
    }, UserCard)
    corner(Avatar, 1, 1)
    bind(Avatar, 'BackgroundColor3', 'Panel_4')

    local AvatarImage = create('ImageLabel', {
        Name = 'Image',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = '',
        ZIndex = 5
    }, Avatar)
    corner(AvatarImage, 1, 1)

    task.spawn(function()
        if LocalPlayer then
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and thumb then AvatarImage.Image = thumb end
        end
    end)

    local UserName = create('TextLabel', {
        Name = 'Name',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = LocalPlayer and LocalPlayer.DisplayName or 'Stellar User',
        Size = UDim2.new(1, -58, 0, 14),
        Position = UDim2.fromOffset(52, 12),
        ZIndex = 4
    }, UserCard)
    bind(UserName, 'TextColor3', 'Text')

    local UserSub = create('TextLabel', {
        Name = 'Sub',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = '@' .. (LocalPlayer and LocalPlayer.Name or 'guest'),
        Size = UDim2.new(1, -58, 0, 12),
        Position = UDim2.fromOffset(52, 27),
        ZIndex = 4
    }, UserCard)
    bind(UserSub, 'TextColor3', 'Dim')

    local OnlineDot = create('Frame', {
        Name = 'Dot',
        Size = UDim2.fromOffset(7, 7),
        Position = UDim2.new(1, -12, 1, -12),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        ZIndex = 5
    }, UserCard)
    corner(OnlineDot, 1, 1)
    bind(OnlineDot, 'BackgroundColor3', 'Success')

    local NavLabel = create('TextLabel', {
        Name = 'NavLabel',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Dim,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'NAVIGATION',
        Size = UDim2.new(1, -24, 0, 10),
        Position = UDim2.fromOffset(14, 80),
        ZIndex = 3
    }, Sidebar)
    bind(NavLabel, 'TextColor3', 'Dim')

    local Tabs = create('ScrollingFrame', {
        Name = 'Tabs',
        Size = UDim2.new(1, -16, 1, -142),
        Position = UDim2.fromOffset(8, 94),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollBarImageTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Selectable = false,
        ZIndex = 3
    }, Sidebar)
    list_layout(Tabs, { Padding = UDim.new(0, 4) })

    local SidebarFooter = create('Frame', {
        Name = 'Footer',
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 1, -42),
        BackgroundColor3 = Theme.Panel_2,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Sidebar)
    corner(SidebarFooter, 8)
    bind(SidebarFooter, 'BackgroundColor3', 'Panel_2')

    local FooterDot = create('Frame', {
        Size = UDim2.fromOffset(6, 6),
        Position = UDim2.fromOffset(10, 12),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        ZIndex = 4
    }, SidebarFooter)
    corner(FooterDot, 1, 1)
    bind(FooterDot, 'BackgroundColor3', 'Success')

    create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Medium),
        TextColor3 = Theme.Muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'System ready',
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(22, 0),
        ZIndex = 4
    }, SidebarFooter)
    bind(SidebarFooter:FindFirstChildWhichIsA('TextLabel'), 'TextColor3', 'Muted')

    local HintKey = create('TextLabel', {
        Name = 'Hint',
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(38, 14),
        BackgroundColor3 = Theme.Panel_4,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Dim,
        TextSize = 8,
        Text = 'CTRL',
        ZIndex = 4
    }, SidebarFooter)
    corner(HintKey, 4)
    bind(HintKey, 'BackgroundColor3', 'Panel_4')
    bind(HintKey, 'TextColor3', 'Dim')
    Tooltip.attach(HintKey, 'Toggle interface')

    -- content ------------------------------------------------------
    local Content = create('Frame', {
        Name = 'Content',
        Size = UDim2.new(1, -SIDEBAR_W, 1, 0),
        Position = UDim2.fromOffset(SIDEBAR_W, 0),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, Body)

    local TabTitle = create('TextLabel', {
        Name = 'TabTitle',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Text,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Welcome',
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.fromOffset(20, 16),
        ZIndex = 3
    }, Content)
    bind(TabTitle, 'TextColor3', 'Text')

    local TabSubtitle = create('TextLabel', {
        Name = 'TabSubtitle',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Stellar • Ethereal Edition',
        Size = UDim2.new(1, -40, 0, 14),
        Position = UDim2.fromOffset(20, 36),
        ZIndex = 3
    }, Content)
    bind(TabSubtitle, 'TextColor3', 'Dim')

    local header_line = create('Frame', {
        Name = 'HeaderLine',
        Size = UDim2.new(1, -40, 0, 1),
        Position = UDim2.fromOffset(20, 58),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Content)
    bind(header_line, 'BackgroundColor3', 'Border')

    local Columns = create('Frame', {
        Name = 'Columns',
        Size = UDim2.new(1, -40, 1, -74),
        Position = UDim2.fromOffset(20, 72),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, Content)

    local COL_W = 248

    -- Each tab builds its own pair of scrolling columns inside `Columns`,
    -- so the base container only hosts the empty state until a tab exists.

    -- empty state
    local EmptyState = create('Frame', {
        Name = 'EmptyState',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = true,
        ZIndex = 3
    }, Columns)
    local empty_label = create('TextLabel', {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.42),
        Size = UDim2.fromOffset(320, 40),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 11,
        TextWrapped = true,
        Text = 'No tabs yet.\nCreate one with library:create_tab("Main", "rbxassetid://...")'
    }, EmptyState)
    bind(empty_label, 'TextColor3', 'Dim')
    --=================================================================
    --  Store refs
    --=================================================================
    self._ui = Stellar
    self._refs = {
        Stellar = Stellar,
        Container = Container,
        TopBar = TopBar,
        Drag = Drag,
        Controls = Controls,
        SearchBox = SearchBox,
        SearchInput = SearchInput,
        Body = Body,
        Sidebar = Sidebar,
        Tabs = Tabs,
        Content = Content,
        TabTitle = TabTitle,
        TabSubtitle = TabSubtitle,
        Columns = Columns,
        EmptyState = EmptyState,
        EmptyLabel = empty_label,
        LogoMark = LogoMark,
        LogoImage = LogoImage,
        Close = Close,
        WIN_W = WIN_W,
        WIN_H = WIN_H
    }

    --=================================================================
    --  Search behaviour
    --=================================================================
    SearchInput:GetPropertyChangedSignal('Text'):Connect(function()
        self:set_search(SearchInput.Text)
    end)

    --=================================================================
    --  Dragging
    --=================================================================
    local function on_drag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position

            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                Connections:disconnect('container_input_ended')
                self._dragging = false
            end)
        end
    end

    local function drag(input)
        if not self._dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - self._drag_start
            local position = UDim2.new(
                self._container_position.X.Scale,
                self._container_position.X.Offset + delta.X,
                self._container_position.Y.Scale,
                self._container_position.Y.Offset + delta.Y
            )
            tween(Container, 0.18, { Position = position }, Enum.EasingStyle.Linear)
        end
    end

    Connections['container_input_began'] = Drag.InputBegan:Connect(on_drag)
    Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)

    --=================================================================
    --  Window controls
    --=================================================================
    -- The animated logo in the top-left opens/minimizes the window.
    LogoMark.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    Close.MouseButton1Click:Connect(function()
        -- The × fully tears the interface down. Use the top-left logo (or
        -- Left CTRL) when you only want to minimize.
        self:destroy()
    end)

    Connections['library_visibility'] = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode ~= Enum.KeyCode.LeftControl then return end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    --=================================================================
    --  Lifecycle helpers
    --=================================================================
    function self:Update1Run(alpha)
        if alpha == 'nil' or alpha == nil then
            Container.BackgroundTransparency = 0.05
        else
            pcall(function()
                Container.BackgroundTransparency = tonumber(alpha)
            end)
        end
    end

    function self:UIVisiblity()
        Stellar.Enabled = not Stellar.Enabled
    end

    function self:change_visiblity(state)
        if state then
            Body.Visible = true
            TopBar.Search.Visible = true
            TopBar.Controls.Visible = true
            tween(Container, 0.45, { Size = UDim2.fromOffset(WIN_W, WIN_H) })
            tween(Container, 0.4, { GroupTransparency = 0 })
        else
            tween(Container, 0.4, { Size = UDim2.fromOffset(148, TOPBAR_H) })
            task.delay(0.18, function()
                if not self._ui_open then
                    Body.Visible = false
                    TopBar.Search.Visible = false
                    TopBar.Controls.Visible = false
                end
            end)
        end
    end

    function self:load()
        local images = {}
        for _, object in ipairs(Stellar:GetDescendants()) do
            if object:IsA('ImageLabel') and object.Image ~= '' then
                table.insert(images, object)
            end
        end
        pcall(function() ContentProvider:PreloadAsync(images) end)

        self:get_device()
        local ui_scale = create('UIScale', {}, Container)

        if self._device == 'Mobile' then
            self:get_screen_scale()
            ui_scale.Scale = self._ui_scale
            Connections['ui_scale'] = Workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
                self:get_screen_scale()
                ui_scale.Scale = self._ui_scale
            end)
        end

        tween(Container, 0.5, { Size = UDim2.fromOffset(WIN_W, WIN_H), GroupTransparency = 0 })
        if self.Acrylic == true then
            pcall(function() AcrylicBlur.new(Container) end)
        end
        self._ui_loaded = true
    end

    return self
end

--=====================================================================
--  Search / filtering
--=====================================================================
function Library:set_search(text)
    self._search_text = tostring(text or ''):lower()
    local query = self._search_text
    local active = self._active_tab
    local matches_active = false

    for _, item in ipairs(self._search_items) do
        local frame = item.frame
        if frame and frame.Parent then
            if query == '' then
                frame.Visible = true
            else
                local haystack = (tostring(item.title or '') .. ' ' .. tostring(item.description or '') .. ' ' .. tostring(item.keywords or '')):lower()
                frame.Visible = string.find(haystack, query, 1, true) ~= nil
            end
            if frame.Visible and item.tab == active then
                matches_active = true
            end
        end
    end

    if active then
        if query ~= '' and not matches_active then
            self._refs.EmptyLabel.Text = 'No results for "' .. tostring(text) .. '"'
            self._refs.EmptyState.Visible = true
        else
            self._refs.EmptyState.Visible = false
        end
    end
end

--=====================================================================
--  Card geometry
--=====================================================================
local CARD_W = 248
local CARD_PAD_X = 12
local CARD_GAP = 8

--=====================================================================
--  Tab manager
--=====================================================================
local TabManager = {}
TabManager.__index = TabManager

--=====================================================================
--  Module manager
--=====================================================================
local ModuleManager = {}
ModuleManager.__index = ModuleManager

-- Keybind chip helper -------------------------------------------------
local function make_keybind_chip(parent, flag, library, on_change, tooltip_text)
    local chip = create('TextButton', {
        Name = 'Keybind',
        Size = UDim2.fromOffset(40, 18),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 6
    }, parent)
    corner(chip, 5)
    local chip_stroke = stroke(chip, Theme.Border, 1, 0.35)
    bind(chip, 'BackgroundColor3', 'Panel_3')
    bind(chip_stroke, 'Color', 'Border')

    local label = create('TextLabel', {
        Name = 'Label',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Dim,
        TextSize = 9,
        Text = '—',
        ZIndex = 7
    }, chip)
    bind(label, 'TextColor3', 'Dim')

    local function set_text(key)
        if key == nil or key == 'Unknown' or key == '' then
            label.Text = '—'
            label.TextColor3 = Theme.Dim
        else
            label.Text = tostring(key):gsub('Enum.KeyCode.', '')
            label.TextColor3 = Theme.Accent
        end
    end

    set_text(library._config._keybinds[flag])

    local function finish(key)
        library._config._keybinds[flag] = key
        Config:save(game.GameId, library._config)
        set_text(key)
        if on_change then on_change(key) end
    end

    chip.MouseButton1Click:Connect(function()
        if library._choosing_keybind then return end
        library._choosing_keybind = true
        label.Text = '...'
        label.TextColor3 = Theme.Accent
        tween(chip_stroke, 0.2, { Color = Theme.Accent, Transparency = 0 })
        tween(chip, 0.2, { BackgroundTransparency = 0 })

        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end

            if connection then connection:Disconnect() end
            library._choosing_keybind = false
            tween(chip_stroke, 0.2, { Color = Theme.Border, Transparency = 0.35 })
            tween(chip, 0.2, { BackgroundTransparency = 0.15 })

            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                finish(nil)
            else
                finish(tostring(input.KeyCode))
            end
        end)
    end)

    chip.MouseButton2Click:Connect(function()
        finish(nil)
    end)

    if tooltip_text ~= false then
        Tooltip.attach(chip, tooltip_text or 'Click to bind · Right-click to clear')
    end

    return { chip = chip, label = label, set_text = set_text }
end

-- Module construction -------------------------------------------------
local function build_module(parent, settings, library, tab, opts)
    opts = opts or {}
    local has_toggle = not opts.paragraph
    local has_description = settings.description ~= nil and settings.description ~= ''
    local header_h = has_description and 58 or 48

    local instance = setmetatable({
        _settings = settings,
        _library = library,
        _tab = tab,
        _state = false,
        _has_toggle = has_toggle,
        _header_h = header_h,
        _body_height = 0,
        _paragraph = opts.paragraph == true
    }, ModuleManager)

    local Module = create('Frame', {
        Name = 'Module',
        Size = UDim2.new(0, CARD_W, 0, header_h),
        BackgroundColor3 = Theme.Panel_2,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4
    }, parent)
    corner(Module, 11)
    local module_stroke = stroke(Module, Theme.Border, 1, 0.35)
    bind(Module, 'BackgroundColor3', 'Panel_2')
    bind(module_stroke, 'Color', 'Border')

    local Header = create('TextButton', {
        Name = 'Header',
        Size = UDim2.new(1, 0, 0, header_h),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 5
    }, Module)

    -- accent rail (lights up while the module is enabled)
    local AccentRail = create('Frame', {
        Name = 'AccentRail',
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 6
    }, Module)
    corner(AccentRail, 1, 1)
    accent_gradient(AccentRail, 90)

    local IconBox = create('Frame', {
        Name = 'Icon',
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(14, math.floor((header_h - 30) / 2)),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        ZIndex = 6
    }, Header)
    corner(IconBox, 8)
    local icon_stroke = stroke(IconBox, Theme.Border, 1, 0.4)
    bind(IconBox, 'BackgroundColor3', 'Panel_3')
    bind(icon_stroke, 'Color', 'Border')

    local icon_id = Util:resolve_asset_id(settings.icon)
    if icon_id then
        local image = create('ImageLabel', {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = icon_id,
            ImageColor3 = Theme.Muted,
            ZIndex = 7
        }, IconBox)
        bind(image, 'ImageColor3', 'Muted')
    else
        local diamond = create('Frame', {
            Size = UDim2.fromOffset(11, 11),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Rotation = 45,
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 7
        }, IconBox)
        corner(diamond, 2)
        bind(diamond, 'BackgroundColor3', 'Accent')
    end

    local Title = create('TextLabel', {
        Name = 'Title',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = settings.title or 'Module',
        Size = UDim2.new(1, -156, 0, 16),
        Position = UDim2.fromOffset(54, has_description and 12 or math.floor((header_h - 16) / 2)),
        ZIndex = 6
    }, Header)
    bind(Title, 'TextColor3', 'Text')

    local Description
    if has_description then
        Description = create('TextLabel', {
            Name = 'Description',
            BackgroundTransparency = 1,
            FontFace = body_font(Enum.FontWeight.Regular),
            TextColor3 = Theme.Dim,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = settings.description,
            Size = UDim2.new(1, -156, 0, 12),
            Position = UDim2.fromOffset(54, 30),
            ZIndex = 6
        }, Header)
        bind(Description, 'TextColor3', 'Dim')
    end

    -- keybind + toggle
    local keybind
    if has_toggle and settings.flag then
        keybind = make_keybind_chip(Header, settings.flag, library, function()
            instance:connect_keybind()
        end)
        keybind.chip.Position = UDim2.new(1, -12 - 38 - 8 - 40, 0.5, 0)
        keybind.chip.AnchorPoint = Vector2.new(0, 0.5)
    end

    local Toggle, Knob
    if has_toggle then
        Toggle = create('Frame', {
            Name = 'Toggle',
            Size = UDim2.fromOffset(38, 20),
            Position = UDim2.new(1, -12 - 38, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.NotEnabled,
            BorderSizePixel = 0,
            ZIndex = 6
        }, Header)
        corner(Toggle, 1, 1)
        local toggle_stroke = stroke(Toggle, Theme.Border, 1, 0.5)
        bind(Toggle, 'BackgroundColor3', 'NotEnabled')
        bind(toggle_stroke, 'Color', 'Border')

        Knob = create('Frame', {
            Name = 'Knob',
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.Dim,
            BorderSizePixel = 0,
            ZIndex = 7
        }, Toggle)
        corner(Knob, 1, 1)
        bind(Knob, 'BackgroundColor3', 'Dim')
    end

    local Divider = create('Frame', {
        Name = 'Divider',
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.fromOffset(12, header_h - 1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 6
    }, Module)
    bind(Divider, 'BackgroundColor3', 'Border')

    local Body = create('Frame', {
        Name = 'Body',
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, header_h),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 5
    }, Module)
    list_layout(Body, { Padding = UDim.new(0, CARD_GAP) })
    padding(Body, 2, CARD_PAD_X, 12, CARD_PAD_X)

    instance._module = Module
    instance._header = Header
    instance._body = Body
    instance._title = Title
    instance._description = Description
    instance._toggle = Toggle
    instance._knob = Knob
    instance._keybind = keybind
    instance._accent_rail = AccentRail
    instance._divider = Divider
    instance._module_stroke = module_stroke

    -- keep the on/off look correct when the palette changes at runtime
    bind_fn(function()
        if not Module.Parent then return end
        if instance._state then
            Module.BackgroundColor3 = Theme.Panel_3
            module_stroke.Color = Theme.Accent
            module_stroke.Transparency = 0.7
            if Toggle then Toggle.BackgroundColor3 = Theme.Accent end
            if Knob then Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end
        else
            Module.BackgroundColor3 = Theme.Panel_2
            module_stroke.Color = Theme.Border
            module_stroke.Transparency = 0.35
            if Toggle then Toggle.BackgroundColor3 = Theme.NotEnabled end
            if Knob then Knob.BackgroundColor3 = Theme.Dim end
        end
    end)

    -- The whole header is the hit target: clicking anywhere on the card's
    -- top row (including the switch) flips the module on or off. The keybind
    -- chip is a child button, so its clicks never reach the header.
    if has_toggle then
        Header.MouseButton1Click:Connect(function()
            instance:change_state(not instance._state)
        end)

        Header.MouseEnter:Connect(function()
            if not instance._state then
                tween(Module, 0.2, { BackgroundColor3 = Theme.Panel_3 })
            end
        end)
        Header.MouseLeave:Connect(function()
            if not instance._state then
                tween(Module, 0.2, { BackgroundColor3 = Theme.Panel_2 })
            end
        end)
    end

    return instance
end

-- Recompute the body height from its children and resize the card.
function ModuleManager:refresh(instant)
    local total = 14 -- top + bottom padding
    local count = 0
    for _, child in ipairs(self._body:GetChildren()) do
        if child:IsA('GuiObject') and child.Visible then
            total = total + child.Size.Y.Offset
            count = count + 1
        end
    end
    total = total + math.max(0, count - 1) * CARD_GAP
    self._body_height = total
    self._body.Size = UDim2.new(1, 0, 0, total)

    if self._state then
        local target = UDim2.new(0, CARD_W, 0, self._header_h + total)
        if instant then
            self._module.Size = target
        else
            tween(self._module, 0.38, { Size = target })
        end
    end
end

function ModuleManager:change_state(state, initial, silent)
    if not self._has_toggle then return end
    self._state = state

    if self._toggle then
        if state then
            tween(self._module, 0.4, { Size = UDim2.new(0, CARD_W, 0, self._header_h + self._body_height) })
            tween(self._toggle, 0.28, { BackgroundColor3 = Theme.Accent })
            tween(self._knob, 0.34, {
                Position = UDim2.fromOffset(21, 3),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }, Enum.EasingStyle.Back)
            tween(self._module, 0.3, { BackgroundColor3 = Theme.Panel_3 })
            tween(self._module_stroke, 0.3, { Color = Theme.Accent, Transparency = 0.7 })
            self._accent_rail.Visible = true
            self._accent_rail.Size = UDim2.new(0, 3, 0, 0)
            tween(self._accent_rail, 0.4, { Size = UDim2.new(0, 3, 0, self._header_h - 16) }, Enum.EasingStyle.Back)
        else
            tween(self._module, 0.4, { Size = UDim2.new(0, CARD_W, 0, self._header_h) })
            tween(self._toggle, 0.28, { BackgroundColor3 = Theme.NotEnabled })
            tween(self._knob, 0.34, {
                Position = UDim2.fromOffset(3, 3),
                BackgroundColor3 = Theme.Dim
            }, Enum.EasingStyle.Back)
            tween(self._module, 0.3, { BackgroundColor3 = Theme.Panel_2 })
            tween(self._module_stroke, 0.3, { Color = Theme.Border, Transparency = 0.35 })
            tween(self._accent_rail, 0.25, { Size = UDim2.new(0, 3, 0, 0) })
            task.delay(0.25, function()
                if not self._state then
                    self._accent_rail.Visible = false
                end
            end)
        end
    end

    self._divider.Visible = state

    local flag = self._settings.flag
    if flag then
        self._library._config._flags[flag] = state
        if not initial then
            Config:save(game.GameId, self._library._config)
        end
    end

    if self._settings.callback and not silent then
        self._settings.callback(state)
    end
end

function ModuleManager:get_state()
    return self._state
end

function ModuleManager:connect_keybind()
    local flag = self._settings.flag
    if not flag then return end

    if Connections['keybind_press_' .. flag] then
        Connections:disconnect('keybind_press_' .. flag)
    end

    local stored = self._library._config._keybinds[flag]
    if not stored then return end

    Connections['keybind_press_' .. flag] = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if tostring(input.KeyCode) == stored then
            self:change_state(not self._state)
        end
    end)
end

function ModuleManager:scale_keybind(empty)
    if not self._keybind then return end
    local chip = self._keybind.chip
    local target = empty and UDim2.fromOffset(40, 18) or UDim2.fromOffset(44, 18)
    tween(chip, 0.16, { Size = target }, Enum.EasingStyle.Back)
    task.delay(0.18, function()
        tween(chip, 0.16, { Size = UDim2.fromOffset(40, 18) })
    end)
end

--=====================================================================
--  Tab construction
--=====================================================================
function Library:create_tab(title, icon)
    local refs = self._refs
    local Tabs = refs.Tabs
    local Columns = refs.Columns

    local tab = setmetatable({
        _library = self,
        _title = title,
        _icon = icon,
        _modules = {}
    }, TabManager)

    local TabButton = create('TextButton', {
        Name = 'Tab',
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 4
    }, Tabs)
    corner(TabButton, 8)

    local active_pill = create('Frame', {
        Name = 'Pill',
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    }, TabButton)
    corner(active_pill, 1, 1)
    accent_gradient(active_pill, 90)

    local icon_id = Util:resolve_asset_id(icon)
    local icon_holder = create('Frame', {
        Name = 'Icon',
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(14, 9),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, TabButton)

    local icon_image
    if icon_id then
        icon_image = create('ImageLabel', {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = icon_id,
            ImageColor3 = Theme.Dim,
            ZIndex = 6
        }, icon_holder)
        bind(icon_image, 'ImageColor3', 'Dim')
    else
        icon_image = create('Frame', {
            Size = UDim2.fromOffset(9, 9),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Rotation = 45,
            BackgroundColor3 = Theme.Dim,
            BorderSizePixel = 0,
            ZIndex = 6
        }, icon_holder)
        corner(icon_image, 2)
        bind(icon_image, 'BackgroundColor3', 'Dim')
    end

    local TabLabel = create('TextLabel', {
        Name = 'Label',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Dim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = title or 'Tab',
        Size = UDim2.new(1, -52, 1, 0),
        Position = UDim2.fromOffset(38, 0),
        ZIndex = 5
    }, TabButton)
    bind(TabLabel, 'TextColor3', 'Dim')

    -- per-tab content sections
    local Sections = create('Frame', {
        Name = 'Sections',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 3
    }, Columns)

    local function make_column(name, x)
        local section = create('ScrollingFrame', {
            Name = name,
            Size = UDim2.new(0, CARD_W, 1, 0),
            Position = UDim2.fromOffset(x, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Selectable = false,
            ZIndex = 3
        }, Sections)
        list_layout(section, { Padding = UDim.new(0, 10) })
        return section
    end

    local LeftSection = make_column('LeftSection', 0)
    local RightSection = make_column('RightSection', CARD_W + 14)

    tab._button = TabButton
    tab._pill = active_pill
    tab._label = TabLabel
    tab._icon = icon_image
    tab._sections = Sections
    tab._left = LeftSection
    tab._right = RightSection

    table.insert(self._tabs, tab)

    local function activate()
        for _, other in ipairs(self._tabs) do
            local is_active = other == tab
            other._sections.Visible = is_active
            if is_active then
                tween(other._button, 0.28, { BackgroundTransparency = 0.25, BackgroundColor3 = Theme.Panel_3 })
                tween(other._label, 0.28, { TextColor3 = Theme.Text })
                tween(other._pill, 0.34, { Size = UDim2.new(0, 3, 0, 18) }, Enum.EasingStyle.Back)
                if other._icon and other._icon:IsA('ImageLabel') then
                    tween(other._icon, 0.28, { ImageColor3 = Theme.Accent })
                elseif other._icon then
                    tween(other._icon, 0.28, { BackgroundColor3 = Theme.Accent })
                end
            else
                tween(other._button, 0.28, { BackgroundTransparency = 1 })
                tween(other._label, 0.28, { TextColor3 = Theme.Dim })
                tween(other._pill, 0.25, { Size = UDim2.new(0, 3, 0, 0) })
                if other._icon and other._icon:IsA('ImageLabel') then
                    tween(other._icon, 0.28, { ImageColor3 = Theme.Dim })
                elseif other._icon then
                    tween(other._icon, 0.28, { BackgroundColor3 = Theme.Dim })
                end
            end
        end

        self._active_tab = tab
        refs.TabTitle.Text = title or 'Tab'
        refs.TabSubtitle.Text = tostring(#tab._modules) .. ' feature' .. (#tab._modules == 1 and '' or 's') .. ' available'
        refs.EmptyState.Visible = false
    end

    tab._activate = activate
    TabButton.MouseButton1Click:Connect(activate)

    TabButton.MouseEnter:Connect(function()
        if self._active_tab ~= tab then
            tween(TabButton, 0.2, { BackgroundTransparency = 0.65, BackgroundColor3 = Theme.Panel_3 })
            tween(TabLabel, 0.2, { TextColor3 = Theme.Muted })
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if self._active_tab ~= tab then
            tween(TabButton, 0.2, { BackgroundTransparency = 1 })
            tween(TabLabel, 0.2, { TextColor3 = Theme.Dim })
        end
    end)

    if self._active_tab == nil then
        activate()
    end

    -- keep tab tinting correct through palette swaps
    bind_fn(function()
        if not TabButton.Parent then return end
        local is_active = self._active_tab == tab
        if is_active then
            TabButton.BackgroundColor3 = Theme.Panel_3
            TabLabel.TextColor3 = Theme.Text
            if icon_image:IsA('ImageLabel') then
                icon_image.ImageColor3 = Theme.Accent
            else
                icon_image.BackgroundColor3 = Theme.Accent
            end
        else
            TabButton.BackgroundColor3 = Theme.Panel_3
            TabLabel.TextColor3 = Theme.Dim
            if icon_image:IsA('ImageLabel') then
                icon_image.ImageColor3 = Theme.Dim
            else
                icon_image.BackgroundColor3 = Theme.Dim
            end
        end
    end)

    return tab
end

--=====================================================================
--  Tab component factories
--=====================================================================
function TabManager:create_module(settings)
    settings = settings or {}
    local parent = settings.section == 'right' and self._right or self._left
    local module = build_module(parent, settings, self._library, self, {})

    table.insert(self._modules, module)
    if self._library._active_tab == self then
        self._library._refs.TabSubtitle.Text = tostring(#self._modules) .. ' feature' .. (#self._modules == 1 and '' or 's') .. ' available'
    end

    table.insert(self._library._search_items, {
        frame = module._module,
        title = settings.title,
        description = settings.description,
        tab = self
    })

    if settings.flag or settings.default ~= nil then
        if settings.flag and self._library:flag_type(settings.flag, 'boolean') then
            module:change_state(self._library._config._flags[settings.flag], true, true)
        elseif settings.default ~= nil then
            module:change_state(settings.default, true, true)
        else
            module:change_state(false, true, true)
        end
    end
    if settings.flag then
        module:connect_keybind()
    end

    return module
end

function TabManager:moduleparagraph(settings)
    settings = settings or {}
    settings.section = settings.section or 'left'
    local parent = settings.section == 'right' and self._right or self._left
    local module = build_module(parent, settings, self._library, self, { paragraph = true })
    table.insert(self._modules, module)
    table.insert(self._library._search_items, {
        frame = module._module,
        title = settings.title,
        description = settings.description,
        tab = self
    })
    return module
end

function TabManager:create_image(settings)
    settings = settings or {}
    local parent = settings.section == 'right' and self._right or self._left
    local height = tonumber(settings.height) or 150

    local card = create('Frame', {
        Name = 'ImageModule',
        Size = UDim2.new(0, CARD_W, 0, height),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4
    }, parent)
    corner(card, 11)
    local card_stroke = stroke(card, Theme.Border, 1, 0.35)
    bind(card, 'BackgroundColor3', 'Panel_2')
    bind(card_stroke, 'Color', 'Border')

    local image_id = Util:resolve_asset_id(settings.image)
    local image = create('ImageLabel', {
        Name = 'Image',
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        Image = image_id or '',
        ImageTransparency = image_id and (settings.transparency or 0) or 1,
        ScaleType = settings.scale_type or Enum.ScaleType.Crop,
        ZIndex = 5
    }, card)
    corner(image, 8)

    -- Graceful placeholder while there is no image (or if the asset fails).
    local placeholder = create('Frame', {
        Name = 'Placeholder',
        Size = image.Size,
        Position = image.Position,
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        Visible = image_id == nil,
        ZIndex = 5
    }, card)
    corner(placeholder, 8)
    bind(placeholder, 'BackgroundColor3', 'Panel_3')

    local placeholder_label = create('TextLabel', {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 10,
        Text = settings.placeholder or 'No image',
        ZIndex = 6
    }, placeholder)
    bind(placeholder_label, 'TextColor3', 'Dim')

    if image_id then
        pcall(function()
            ContentProvider:PreloadAsync({ image }, function(_, status)
                if status ~= Enum.AssetFetchStatus.Success then
                    placeholder.Visible = true
                end
            end)
        end)
    end

    if settings.title then
        local caption = create('Frame', {
            Name = 'Caption',
            Size = UDim2.new(1, -16, 0, 26),
            Position = UDim2.new(0, 8, 1, -34),
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            ZIndex = 6
        }, card)
        corner(caption, 7)
        bind(caption, 'BackgroundColor3', 'Panel')

        local caption_label = create('TextLabel', {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = settings.title,
            ZIndex = 7
        }, caption)
        bind(caption_label, 'TextColor3', 'Text')
    end

    table.insert(self._library._search_items, {
        frame = card,
        title = settings.title or 'Image',
        description = settings.description,
        tab = self
    })
    return card
end

--=====================================================================
--  Field helpers
--=====================================================================
local BODY_W = CARD_W - CARD_PAD_X * 2

local _uid = 0
local function uid()
    _uid = _uid + 1
    return _uid
end

local function field_label(parent, text, size)
    local label = create('TextLabel', {
        Name = 'Label',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Muted,
        TextSize = size or 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = text or '',
        Size = UDim2.new(1, -60, 0, 13),
        ZIndex = 6
    }, parent)
    bind(label, 'TextColor3', 'Muted')
    return label
end

--=====================================================================
--  Paragraph / text
--=====================================================================
function ModuleManager:create_paragraph(settings)
    settings = settings or {}
    local title_text = settings.title
    local body_text = settings.text or settings.richtext or ''
    local rich = settings.rich == true

    local title_h = title_text and 15 or 0
    local body_h = math.max(14, measure_text(body_text, BODY_W - 18, 10))
    local height = 10 + title_h + (title_text and 5 or 0) + body_h + 10

    local frame = create('Frame', {
        Name = 'Paragraph',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 5
    }, self._body)
    corner(frame, 8)
    local frame_stroke = stroke(frame, Theme.Border, 1, 0.5)
    bind(frame, 'BackgroundColor3', 'Panel_3')
    bind(frame_stroke, 'Color', 'Border')

    if title_text then
        local title = create('TextLabel', {
            BackgroundTransparency = 1,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = title_text,
            Size = UDim2.new(1, -18, 0, 15),
            Position = UDim2.fromOffset(9, 9),
            ZIndex = 6
        }, frame)
        bind(title, 'TextColor3', 'Text')
    end

    local body = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = rich,
        Text = body_text,
        Size = UDim2.new(1, -18, 0, body_h),
        Position = UDim2.fromOffset(9, 9 + title_h + (title_text and 5 or 0)),
        ZIndex = 6
    }, frame)
    bind(body, 'TextColor3', 'Muted')

    self:refresh()
    return { _frame = frame }
end

function ModuleManager:create_text(settings)
    settings = settings or {}
    local rich = settings.rich == true
    local text_value = settings.text or settings.richtext or ''
    local height = math.max(28, measure_text(text_value, BODY_W - 18, 10) + 18)

    local frame = create('Frame', {
        Name = 'Text',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 5
    }, self._body)
    corner(frame, 8)
    local frame_stroke = stroke(frame, Theme.Border, 1, 0.5)
    bind(frame, 'BackgroundColor3', 'Panel_3')
    bind(frame_stroke, 'Color', 'Border')

    local body = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = rich,
        Text = text_value,
        Size = UDim2.new(1, -18, 0, height - 18),
        Position = UDim2.fromOffset(9, 9),
        ZIndex = 6
    }, frame)
    bind(body, 'TextColor3', 'Muted')

    local manager = { _frame = frame }
    local module = self

    function manager:Set(new_settings)
        new_settings = new_settings or {}
        local new_rich = new_settings.rich == true
        local new_text = new_settings.text or new_settings.richtext or ''
        body.RichText = new_rich
        body.Text = new_text
        local new_height = math.max(28, measure_text(new_text, BODY_W - 18, 10) + 18)
        frame.Size = UDim2.new(0, BODY_W, 0, new_height)
        body.Size = UDim2.new(1, -18, 0, new_height - 18)
        module:refresh()
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Textbox
--=====================================================================
function ModuleManager:create_textbox(settings)
    settings = settings or {}
    local manager = { _text = '', _library = self._library }
    local height = 47

    local frame = create('Frame', {
        Name = 'TextboxRow',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Input', 10).Position = UDim2.fromOffset(0, 0)

    local box = create('TextBox', {
        Name = 'Textbox',
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.fromOffset(0, 17),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Dim,
        PlaceholderText = settings.placeholder or 'Enter text...',
        TextSize = 10,
        Text = self._library._config._flags[settings.flag] or settings.text or '',
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 6
    }, frame)
    corner(box, 7)
    padding(box, 0, 9, 0, 9)
    local box_stroke = stroke(box, Theme.Border, 1, 0.4)
    bind(box, 'BackgroundColor3', 'Panel_3')
    bind(box, 'TextColor3', 'Text')
    bind(box, 'PlaceholderColor3', 'Dim')
    bind(box_stroke, 'Color', 'Border')

    box.Focused:Connect(function()
        tween(box_stroke, 0.2, { Color = Theme.Accent, Transparency = 0.1 })
        tween(box, 0.2, { BackgroundColor3 = Theme.Panel_4 })
    end)
    box.FocusLost:Connect(function()
        tween(box_stroke, 0.2, { Color = Theme.Border, Transparency = 0.4 })
        tween(box, 0.2, { BackgroundColor3 = Theme.Panel_3 })
        manager:update_text(box.Text)
    end)

    function manager:update_text(text)
        self._text = text
        if settings.flag then
            self._library._config._flags[settings.flag] = text
            Config:save(game.GameId, self._library._config)
        end
        if settings.callback then settings.callback(text) end
    end

    function manager:get_text()
        return manager._text
    end

    if settings.flag and self._library:flag_type(settings.flag, 'string') then
        box.Text = self._library._config._flags[settings.flag]
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Checkbox / toggle row
--=====================================================================
function ModuleManager:create_checkbox(settings)
    settings = settings or {}
    local manager = { _state = false, _library = self._library }
    local height = 24

    local row = create('TextButton', {
        Name = 'CheckboxRow',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 5
    }, self._body)

    local title = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = settings.title or 'Toggle',
        Size = UDim2.new(1, -60, 1, 0),
        ZIndex = 6
    }, row)
    bind(title, 'TextColor3', 'Text')

    local box = create('Frame', {
        Name = 'Box',
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(1, -18, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        ZIndex = 6
    }, row)
    corner(box, 5)
    local box_stroke = stroke(box, Theme.Border, 1, 0.3)
    bind(box, 'BackgroundColor3', 'Panel_3')
    bind(box_stroke, 'Color', 'Border')

    local check_holder = create('Frame', {
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, box)
    local check = draw_check(check_holder, Color3.fromRGB(255, 255, 255), 1.7)

    local keybind_chip
    if settings.flag and settings.keybind ~= false then
        keybind_chip = make_keybind_chip(row, settings.flag, self._library, function(key)
            if settings.keybind_callback then settings.keybind_callback(key) end
        end)
        keybind_chip.chip.Position = UDim2.new(1, -26 - 8 - 40, 0.5, 0)
        keybind_chip.chip.AnchorPoint = Vector2.new(0, 0.5)
        title.Size = UDim2.new(1, -132, 1, 0)
    end

    function manager:change_state(state, silent)
        self._state = state
        if state then
            tween(box, 0.22, { BackgroundColor3 = Theme.Accent })
            tween(box_stroke, 0.22, { Color = Theme.Accent, Transparency = 0 })
            check_holder.Size = UDim2.fromOffset(12, 12)
            check.Visible = true
        else
            tween(box, 0.22, { BackgroundColor3 = Theme.Panel_3 })
            tween(box_stroke, 0.22, { Color = Theme.Border, Transparency = 0.3 })
            check_holder.Size = UDim2.fromOffset(0, 0)
            check.Visible = false
        end

        if settings.flag then
            self._library._config._flags[settings.flag] = state
            Config:save(game.GameId, self._library._config)
        end
        if not silent and settings.callback then
            settings.callback(state)
        end
    end

    function manager:get_state()
        return self._state
    end

    row.MouseButton1Click:Connect(function()
        manager:change_state(not manager._state)
    end)

    if settings.flag then
        local flag = settings.flag
        Connections['checkbox_key_' .. flag] = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local stored = self._library._config._keybinds[flag]
            if stored and tostring(input.KeyCode) == stored then
                manager:change_state(not manager._state)
            end
        end)

        if self._library:flag_type(flag, 'boolean') then
            manager:change_state(self._library._config._flags[flag], true)
        elseif settings.default ~= nil then
            manager:change_state(settings.default, true)
        end
    end

    bind_fn(function()
        if not box.Parent then return end
        if manager._state then
            box.BackgroundColor3 = Theme.Accent
            box_stroke.Color = Theme.Accent
        else
            box.BackgroundColor3 = Theme.Panel_3
            box_stroke.Color = Theme.Border
        end
    end)

    self:refresh()
    return manager
end

ModuleManager.create_toggle = ModuleManager.create_checkbox

--=====================================================================
--  Button
--=====================================================================
function ModuleManager:create_button(settings)
    settings = settings or {}
    local height = 30

    local button = create('TextButton', {
        Name = 'Button',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        Text = settings.title or 'Button',
        AutoButtonColor = false,
        ZIndex = 5
    }, self._body)
    corner(button, 8)
    local variant = settings.variant
    if variant == 'ghost' then
        button.BackgroundColor3 = Theme.Panel_3
        button.TextColor3 = Theme.Text
        local s = stroke(button, Theme.Border, 1, 0.3)
        bind(button, 'BackgroundColor3', 'Panel_3')
        bind(button, 'TextColor3', 'Text')
        bind(s, 'Color', 'Border')
    elseif variant == 'danger' then
        button.BackgroundColor3 = Theme.Danger
        bind(button, 'BackgroundColor3', 'Danger')
    else
        accent_gradient(button, 0)
    end

    local base = button.BackgroundColor3
    local function base_color()
        if variant == 'ghost' then return Theme.Panel_3 end
        if variant == 'danger' then return Theme.Danger end
        return Theme.Accent
    end
    button.MouseEnter:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = base_color():Lerp(Color3.new(1, 1, 1), 0.14) })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = base_color() })
    end)
    button.MouseButton1Down:Connect(function()
        tween(button, 0.08, { BackgroundColor3 = base_color():Lerp(Color3.new(0, 0, 0), 0.12) })
    end)
    button.MouseButton1Up:Connect(function()
        tween(button, 0.14, { BackgroundColor3 = base_color():Lerp(Color3.new(1, 1, 1), 0.14) })
    end)

    button.MouseButton1Click:Connect(function()
        if settings.callback then settings.callback() end
    end)

    self:refresh()
    return button
end

--=====================================================================
--  Divider / section header
--=====================================================================
function ModuleManager:create_divider(settings)
    settings = settings or {}
    local height = 20

    local frame = create('Frame', {
        Name = 'Divider',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local line = create('Frame', {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 5
    }, frame)
    gradient(line, ColorSequence.new(Color3.fromRGB(255, 255, 255)), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }))
    bind(line, 'BackgroundColor3', 'Border')

    if settings.showtopic and settings.title then
        local label = create('TextLabel', {
            BackgroundColor3 = Theme.Panel_2,
            BackgroundTransparency = 0,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Muted,
            TextSize = 10,
            Text = settings.title,
            Size = UDim2.new(0, 140, 0, 14),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 6
        }, frame)
        bind(label, 'TextColor3', 'Muted')
        bind(label, 'BackgroundColor3', 'Panel_2')
    end

    self:refresh()
    return frame
end

function ModuleManager:create_section(settings)
    settings = settings or {}
    local height = 24

    local frame = create('Frame', {
        Name = 'Section',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local label = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Dim,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = string.upper(settings.title or 'Section'),
        Size = UDim2.new(1, -60, 0, 12),
        Position = UDim2.fromOffset(0, 6),
        ZIndex = 6
    }, frame)
    bind(label, 'TextColor3', 'Dim')

    create('Frame', {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 5
    }, frame)

    self:refresh()
    return frame
end

--=====================================================================
--  Slider
--=====================================================================
function ModuleManager:create_slider(settings)
    settings = settings or {}
    local manager = {}
    local minimum = settings.minimum_value or 0
    local maximum = settings.maximum_value or 100
    local height = 42

    local frame = create('Frame', {
        Name = 'Slider',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Slider', 10).Position = UDim2.fromOffset(0, 0)

    local value_label = create('TextLabel', {
        Name = 'Value',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = '0',
        Size = UDim2.new(0, 70, 0, 13),
        Position = UDim2.new(1, -70, 0, 0),
        ZIndex = 6
    }, frame)
    bind(value_label, 'TextColor3', 'Text')

    local track = create('Frame', {
        Name = 'Track',
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.fromOffset(0, 30),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0,
        ZIndex = 5
    }, frame)
    corner(track, 1, 1)
    bind(track, 'BackgroundColor3', 'Panel_4')

    local fill = create('Frame', {
        Name = 'Fill',
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    }, track)
    corner(fill, 1, 1)
    accent_gradient(fill, 0)

    local knob = create('Frame', {
        Name = 'Knob',
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 7
    }, track)
    corner(knob, 1, 1)
    local knob_stroke = stroke(knob, Theme.Accent, 2, 0)
    bind(knob_stroke, 'Color', 'Accent')

    local dragging = false

    local function format(value)
        if settings.round_number then
            return tostring(math.floor(value + 0.5))
        end
        return tostring(math.floor(value * 10 + 0.5) / 10)
    end

    local function apply(value, save, fire)
        value = math.clamp(value, minimum, maximum)
        local percentage = 0
        if maximum ~= minimum then
            percentage = (value - minimum) / (maximum - minimum)
        end
        tween(fill, 0.1, { Size = UDim2.new(percentage, 0, 1, 0) }, Enum.EasingStyle.Linear)
        knob.Position = UDim2.new(percentage, 0, 0.5, 0)
        value_label.Text = format(value) .. (settings.suffix or '')

        if settings.flag then
            self._library._config._flags[settings.flag] = value
            if save then Config:save(game.GameId, self._library._config) end
        end
        if fire and settings.callback then settings.callback(value) end
        manager._value = value
    end

    function manager:set_percentage(value)
        apply(value, true, true)
    end

    function manager:get_value()
        return manager._value
    end

    local function update_from_mouse()
        local mouse = UserInputService:GetMouseLocation()
        local track_x = track.AbsolutePosition.X
        local track_width = math.max(1, track.AbsoluteSize.X)
        local alpha = math.clamp((mouse.X - track_x) / track_width, 0, 1)
        apply(minimum + (maximum - minimum) * alpha, false, true)
    end

    local slider_id = 'slider_' .. tostring(uid())
    local function cleanup_slider()
        Connections:disconnect(slider_id .. '_move')
        Connections:disconnect(slider_id .. '_end')
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging = true
        tween(knob, 0.15, { Size = UDim2.fromOffset(15, 15) }, Enum.EasingStyle.Back)
        update_from_mouse()

        cleanup_slider()
        Connections[slider_id .. '_move'] = UserInputService.InputChanged:Connect(function(move_input)
            if move_input.UserInputType == Enum.UserInputType.MouseMovement or move_input.UserInputType == Enum.UserInputType.Touch then
                update_from_mouse()
            end
        end)

        Connections[slider_id .. '_end'] = UserInputService.InputEnded:Connect(function(end_input)
            if end_input.UserInputType ~= Enum.UserInputType.MouseButton1 and end_input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            dragging = false
            tween(knob, 0.15, { Size = UDim2.fromOffset(12, 12) })
            cleanup_slider()
            if not settings.ignoresaved and settings.flag then
                Config:save(game.GameId, self._library._config)
            end
        end)
    end)

    track.MouseEnter:Connect(function()
        if not dragging then tween(knob, 0.15, { Size = UDim2.fromOffset(14, 14) }) end
    end)
    track.MouseLeave:Connect(function()
        if not dragging then tween(knob, 0.15, { Size = UDim2.fromOffset(12, 12) }) end
    end)

    local initial = settings.value or minimum
    if settings.flag and self._library:flag_type(settings.flag, 'number') and not settings.ignoresaved then
        initial = self._library._config._flags[settings.flag]
    end
    apply(initial, false, false)

    self:refresh()
    return manager
end

--=====================================================================
--  Dropdown
--=====================================================================
function ModuleManager:create_dropdown(settings)
    settings = settings or {}
    local manager = { _state = false, _module = self }
    local options = {}
    for _, option in ipairs(settings.options or {}) do
        table.insert(options, option)
    end

    local height_closed = 44
    local option_height = 24
    local max_visible = settings.maximum_options or 7
    local options_height = math.min(#options, max_visible) * option_height + 8

    local frame = create('Frame', {
        Name = 'Dropdown',
        Size = UDim2.new(0, BODY_W, 0, height_closed),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Dropdown', 10).Position = UDim2.fromOffset(0, 0)

    local box = create('TextButton', {
        Name = 'Box',
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.fromOffset(0, 16),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 6
    }, frame)
    corner(box, 8)
    local box_stroke = stroke(box, Theme.Border, 1, 0.4)
    bind(box, 'BackgroundColor3', 'Panel_3')
    bind(box_stroke, 'Color', 'Border')

    local current_label = create('TextLabel', {
        Name = 'Current',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = tr('DropdownNone', 'None'),
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        ZIndex = 7
    }, box)
    bind(current_label, 'TextColor3', 'Muted')

    local chevron_holder = create('Frame', {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.new(1, -20, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, box)
    local chevron = draw_chevron(chevron_holder, 10, Theme.Dim, 1.6)
    bind_fn(function()
        for _, child in ipairs(chevron:GetDescendants()) do
            if child:IsA('Frame') then child.BackgroundColor3 = Theme.Dim end
        end
    end)

    local options_frame = create('ScrollingFrame', {
        Name = 'Options',
        Size = UDim2.new(1, 0, 0, options_height),
        Position = UDim2.fromOffset(0, height_closed),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 6
    }, frame)
    corner(options_frame, 8)
    list_layout(options_frame, { Padding = UDim.new(0, 2) })
    padding(options_frame, 4, 4, 4, 4)

    local option_buttons = {}

    local function display(value)
        if settings.multi_dropdown then
            local list = value or {}
            if type(list) ~= 'table' then list = { list } end
            if #list == 0 then return tr('DropdownNone', 'None') end
            local names = {}
            for _, item in ipairs(list) do
                table.insert(names, typeof(item) == 'string' and item or item.Name)
            end
            return table.concat(names, ', ')
        end
        if value == nil then return tr('DropdownNone', 'None') end
        return typeof(value) == 'string' and value or value.Name
    end

    local function refresh_selection(value)
        if settings.multi_dropdown then
            local list = value or {}
            if type(list) ~= 'table' then list = { list } end
            for option_value, entry in pairs(option_buttons) do
                local selected = false
                for _, item in ipairs(list) do
                    if item == option_value then selected = true break end
                end
                entry.mark.Visible = selected
                entry.label.TextColor3 = selected and Theme.Accent or Theme.Muted
            end
        else
            for option_value, entry in pairs(option_buttons) do
                local selected = option_value == value
                entry.mark.Visible = selected
                entry.label.TextColor3 = selected and Theme.Accent or Theme.Muted
            end
        end
    end

    function manager:update(value)
        current_label.Text = display(value)
        refresh_selection(value)

        if settings.flag then
            self._module._library._config._flags[settings.flag] = value
            Config:save(game.GameId, self._module._library._config)
        end
        if settings.callback then settings.callback(value) end
    end

    function manager:unfold_settings()
        self._state = not self._state
        if self._state then
            frame.Size = UDim2.new(0, BODY_W, 0, height_closed + options_height)
            options_frame.BackgroundTransparency = 0.35
            tween(chevron_holder, 0.3, { Rotation = 180 })
            tween(box_stroke, 0.25, { Color = Theme.Accent, Transparency = 0.2 })
        else
            frame.Size = UDim2.new(0, BODY_W, 0, height_closed)
            tween(chevron_holder, 0.3, { Rotation = 0 })
            tween(box_stroke, 0.25, { Color = Theme.Border, Transparency = 0.4 })
        end
        self._module:refresh()
    end

    local function rebuild(new_options)
        options = new_options or {}
        options_height = math.min(#options, max_visible) * option_height + 8
        options_frame.Size = UDim2.new(1, 0, 0, options_height)
        options_frame.CanvasSize = UDim2.new(0, 0, 0, 0)

        for _, child in ipairs(options_frame:GetChildren()) do
            if child:IsA('TextButton') then child:Destroy() end
        end
        option_buttons = {}

        for _, option_value in ipairs(options) do
            local text = typeof(option_value) == 'string' and option_value or option_value.Name
            local option = create('TextButton', {
                Name = 'Option',
                Size = UDim2.new(1, 0, 0, option_height),
                BackgroundColor3 = Theme.Panel_4,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                FontFace = body_font(Enum.FontWeight.Regular),
                TextColor3 = Theme.Muted,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                AutoButtonColor = false,
                ZIndex = 7
            }, options_frame)
            corner(option, 6)
            padding(option, 0, 8, 0, 8)

            local mark = create('Frame', {
                Name = 'Mark',
                Size = UDim2.fromOffset(10, 10),
                Position = UDim2.new(1, -10, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Visible = false,
                ZIndex = 8
            }, option)
            draw_check(mark, Theme.Accent, 1.6)

            local label = create('TextLabel', {
                BackgroundTransparency = 1,
                FontFace = body_font(Enum.FontWeight.Regular),
                TextColor3 = Theme.Muted,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Size = UDim2.new(1, -16, 1, 0),
                ZIndex = 8
            }, option)
            bind(label, 'TextColor3', 'Muted')
            option.Text = ''

            option.MouseEnter:Connect(function()
                tween(option, 0.15, { BackgroundTransparency = 0.5 })
            end)
            option.MouseLeave:Connect(function()
                tween(option, 0.15, { BackgroundTransparency = 1 })
            end)
            option.MouseButton1Click:Connect(function()
                if settings.multi_dropdown then
                    local list = self._module._library._config._flags[settings.flag]
                    if type(list) ~= 'table' then list = {} end
                    local found = false
                    for index, item in ipairs(list) do
                        if item == option_value then
                            table.remove(list, index)
                            found = true
                            break
                        end
                    end
                    if not found then table.insert(list, option_value) end
                    self:update(list)
                else
                    self:update(option_value)
                    if manager._state then manager:unfold_settings() end
                end
            end)

            option_buttons[option_value] = { mark = mark, label = label, button = option }
        end
    end

    function manager:set_options(new_options)
        rebuild(new_options)
        self._module:refresh()
    end

    function manager:New(value)
        if value and value.options then
            manager:set_options(value.options)
        end
        return manager
    end

    box.MouseButton1Click:Connect(function()
        manager:unfold_settings()
    end)

    rebuild(options)

    local initial
    if settings.flag and self._library._config._flags[settings.flag] ~= nil then
        initial = self._library._config._flags[settings.flag]
    elseif settings.multi_dropdown then
        initial = {}
    else
        initial = settings.value or options[1]
    end
    current_label.Text = display(initial)
    refresh_selection(initial)
    if settings.flag and self._library._config._flags[settings.flag] == nil then
        self._library._config._flags[settings.flag] = initial
    end

    bind_fn(function()
        if not frame.Parent then return end
        local value = initial
        if settings.flag then
            value = self._library._config._flags[settings.flag]
        end
        refresh_selection(value)
    end)

    self:refresh()
    return manager
end

--=====================================================================
--  Feature row (compact toggle + keybind)
--=====================================================================
function ModuleManager:create_feature(settings)
    settings = settings or {}
    local height = 26
    local manager = { _state = false, _library = self._library }

    local row = create('Frame', {
        Name = 'Feature',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local title = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = settings.title or 'Feature',
        Size = UDim2.new(1, -100, 1, 0),
        ZIndex = 6
    }, row)
    bind(title, 'TextColor3', 'Text')

    local box
    local check
    if not settings.disablecheck then
        box = create('TextButton', {
            Name = 'Box',
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(1, -18, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Panel_3,
            BorderSizePixel = 0,
            Text = '',
            AutoButtonColor = false,
            ZIndex = 6
        }, row)
        corner(box, 5)
        local box_stroke = stroke(box, Theme.Border, 1, 0.3)
        bind(box, 'BackgroundColor3', 'Panel_3')
        bind(box_stroke, 'Color', 'Border')

        local holder = create('Frame', {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ZIndex = 7
        }, box)
        check = draw_check(holder, Color3.fromRGB(255, 255, 255), 1.7)
        check.Visible = false

        function manager:change_state(state, silent)
            self._state = state
            if state then
                tween(box, 0.2, { BackgroundColor3 = Theme.Accent })
                tween(box_stroke, 0.2, { Color = Theme.Accent, Transparency = 0 })
                holder.Size = UDim2.fromOffset(12, 12)
                check.Visible = true
            else
                tween(box, 0.2, { BackgroundColor3 = Theme.Panel_3 })
                tween(box_stroke, 0.2, { Color = Theme.Border, Transparency = 0.3 })
                holder.Size = UDim2.fromOffset(0, 0)
                check.Visible = false
            end
            if settings.flag then
                self._library._config._flags[settings.flag] = state
                Config:save(game.GameId, self._library._config)
            end
            if not silent and settings.callback then settings.callback(state) end
        end

        bind_fn(function()
            if not box.Parent then return end
            if manager._state then
                box.BackgroundColor3 = Theme.Accent
                box_stroke.Color = Theme.Accent
            else
                box.BackgroundColor3 = Theme.Panel_3
                box_stroke.Color = Theme.Border
            end
        end)
    else
        local action = create('TextButton', {
            Name = 'Action',
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            AutoButtonColor = false,
            ZIndex = 6
        }, row)
        action.MouseButton1Click:Connect(function()
            if settings.button_callback then settings.button_callback() end
        end)
    end

    if settings.flag then
        local chip = make_keybind_chip(row, settings.flag, self._library, function(key)
            if settings.keybind_callback then settings.keybind_callback(key) end
        end)
        chip.chip.Position = UDim2.new(1, -26 - 8 - 40, 0.5, 0)
        chip.chip.AnchorPoint = Vector2.new(0, 0.5)
        title.Size = UDim2.new(1, -132, 1, 0)
    end

    if box then
        box.MouseButton1Click:Connect(function()
            manager:change_state(not manager._state)
        end)
    end

    if settings.flag then
        local flag = settings.flag
        Connections['feature_key_' .. flag] = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local stored = self._library._config._keybinds[flag]
            if stored and tostring(input.KeyCode) == stored then
                if manager.change_state then manager:change_state(not manager._state) end
            end
        end)
    end

    if manager.change_state then
        local flag = settings.flag
        if flag and self._library:flag_type(flag, 'boolean') then
            manager:change_state(self._library._config._flags[flag], true)
        elseif settings.default ~= nil then
            manager:change_state(settings.default, true)
        end
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Standalone keybind row
--=====================================================================
function ModuleManager:create_keybind(settings)
    settings = settings or {}
    local height = 26

    local row = create('Frame', {
        Name = 'KeybindRow',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local title = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = settings.title or 'Keybind',
        Size = UDim2.new(1, -60, 1, 0),
        ZIndex = 6
    }, row)
    bind(title, 'TextColor3', 'Text')

    local manager = {}
    if settings.flag then
        local chip = make_keybind_chip(row, settings.flag, self._library, function(key)
            if settings.callback then settings.callback(key) end
        end)
        chip.chip.Position = UDim2.new(1, -40, 0.5, 0)
        chip.chip.AnchorPoint = Vector2.new(0, 0.5)
        manager.set = chip.set_text
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Color picker
--=====================================================================
function ModuleManager:create_colorpicker(settings)
    settings = settings or {}
    local manager = { _state = false, _module = self }
    local height_closed = 30
    local picker_height = 132

    local frame = create('Frame', {
        Name = 'ColorPicker',
        Size = UDim2.new(0, BODY_W, 0, height_closed),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Color', 10).Position = UDim2.fromOffset(0, 3)

    local swatch = create('TextButton', {
        Name = 'Swatch',
        Size = UDim2.fromOffset(60, 22),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 6
    }, frame)
    corner(swatch, 6)
    local swatch_stroke = stroke(swatch, Theme.Border, 1, 0.2)
    bind(swatch_stroke, 'Color', 'Border')

    local swatch_hex = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 9,
        Text = '#FFFFFF',
        ZIndex = 7
    }, swatch)

    local panel = create('Frame', {
        Name = 'Panel',
        Size = UDim2.new(1, 0, 0, picker_height),
        Position = UDim2.fromOffset(0, height_closed),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 6
    }, frame)
    corner(panel, 8)
    local panel_stroke = stroke(panel, Theme.Border, 1, 0.5)
    bind(panel, 'BackgroundColor3', 'Panel_3')
    bind(panel_stroke, 'Color', 'Border')

    local sv = create('Frame', {
        Name = 'SV',
        Size = UDim2.fromOffset(120, 84),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 7
    }, panel)
    corner(sv, 6)

    local sv_white = create('Frame', {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 8
    }, sv)
    corner(sv_white, 6)
    gradient(sv_white, ColorSequence.new(Color3.fromRGB(255, 255, 255)), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }))

    local sv_black = create('Frame', {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 9
    }, sv)
    corner(sv_black, 6)
    gradient(sv_black, ColorSequence.new(Color3.fromRGB(0, 0, 0)), 90, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }))

    local sv_marker = create('Frame', {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromScale(1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 10
    }, sv)
    corner(sv_marker, 1, 1)
    create('UIStroke', {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, sv_marker)

    local hue_bar = create('Frame', {
        Name = 'Hue',
        Size = UDim2.fromOffset(120, 12),
        Position = UDim2.fromOffset(10, 104),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 7
    }, panel)
    corner(hue_bar, 1, 1)
    gradient(hue_bar, ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
    }), 0)

    local hue_marker = create('Frame', {
        Size = UDim2.fromOffset(4, 16),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 8
    }, hue_bar)
    corner(hue_marker, 2)

    local hex_box = create('TextBox', {
        Name = 'Hex',
        Size = UDim2.fromOffset(84, 26),
        Position = UDim2.fromOffset(140, 10),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Text,
        TextSize = 10,
        Text = '#FFFFFF',
        ClearTextOnFocus = false,
        ZIndex = 7
    }, panel)
    corner(hex_box, 6)
    padding(hex_box, 0, 8, 0, 8)
    bind(hex_box, 'BackgroundColor3', 'Panel_4')
    bind(hex_box, 'TextColor3', 'Text')

    local preview = create('Frame', {
        Size = UDim2.fromOffset(84, 40),
        Position = UDim2.fromOffset(140, 44),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 7
    }, panel)
    corner(preview, 6)

    local presets = {
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 170, 80),
        Color3.fromRGB(255, 230, 90), Color3.fromRGB(110, 220, 140), Color3.fromRGB(80, 200, 230),
        Color3.fromRGB(110, 140, 255), Color3.fromRGB(180, 120, 255), Color3.fromRGB(255, 120, 200),
        Color3.fromRGB(150, 150, 165), Color3.fromRGB(90, 90, 105), Color3.fromRGB(30, 30, 40)
    }
    local preset_row = create('Frame', {
        Size = UDim2.new(0, 84, 0, 24),
        Position = UDim2.fromOffset(140, 92),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, panel)
    create('UIGridLayout', {
        CellSize = UDim2.fromOffset(12, 11),
        CellPadding = UDim2.fromOffset(2, 2),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, preset_row)

    local function parse_hex(text)
        text = tostring(text):gsub('#', '')
        if #text ~= 6 then return nil end
        local r = tonumber(text:sub(1, 2), 16)
        local g = tonumber(text:sub(3, 4), 16)
        local b = tonumber(text:sub(5, 6), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
        return nil
    end

    local hue, sat, val = 0.6, 0.7, 1

    local function paint(color, save, fire)
        local h, s, v = color:ToHSV()
        hue, sat, val = h, s, v
        sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        sv_marker.Position = UDim2.fromScale(sat, 1 - val)
        hue_marker.Position = UDim2.new(hue, 0, 0.5, 0)
        swatch.BackgroundColor3 = color
        preview.BackgroundColor3 = color
        hex_box.Text = hex(color)
        swatch_hex.Text = hex(color)

        local luminance = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
        swatch_hex.TextColor3 = luminance > 0.6 and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(255, 255, 255)

        if settings.flag then
            self._library._config._flags[settings.flag] = hex(color)
            if save then Config:save(game.GameId, self._library._config) end
        end
        if fire ~= false and settings.callback then settings.callback(color) end
    end

    function manager:set_color(color)
        paint(color, true, true)
    end

    function manager:get_color()
        return Color3.fromHSV(hue, sat, val)
    end

    local function update_sv(mouse_x, mouse_y)
        local position = sv.AbsolutePosition
        local size = sv.AbsoluteSize
        sat = math.clamp((mouse_x - position.X) / math.max(1, size.X), 0, 1)
        val = 1 - math.clamp((mouse_y - position.Y) / math.max(1, size.Y), 0, 1)
        paint(Color3.fromHSV(hue, sat, val), false)
    end

    local function update_hue(mouse_x)
        local position = hue_bar.AbsolutePosition
        local size = math.max(1, hue_bar.AbsoluteSize.X)
        hue = math.clamp((mouse_x - position.X) / size, 0, 1)
        paint(Color3.fromHSV(hue, sat, val), false)
    end

    sv.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local mouse = UserInputService:GetMouseLocation()
        update_sv(mouse.X, mouse.Y)
        Connections['picker_sv'] = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                local m = UserInputService:GetMouseLocation()
                update_sv(m.X, m.Y)
            end
        end)
        Connections['picker_sv_end'] = UserInputService.InputEnded:Connect(function()
            Connections:disconnect('picker_sv')
            Connections:disconnect('picker_sv_end')
            paint(Color3.fromHSV(hue, sat, val), true)
        end)
    end)

    hue_bar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local mouse = UserInputService:GetMouseLocation()
        update_hue(mouse.X)
        Connections['picker_hue'] = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                local m = UserInputService:GetMouseLocation()
                update_hue(m.X)
            end
        end)
        Connections['picker_hue_end'] = UserInputService.InputEnded:Connect(function()
            Connections:disconnect('picker_hue')
            Connections:disconnect('picker_hue_end')
            paint(Color3.fromHSV(hue, sat, val), true)
        end)
    end)

    hex_box.FocusLost:Connect(function()
        local color = parse_hex(hex_box.Text)
        if color then
            paint(color, true)
        else
            hex_box.Text = hex(Color3.fromHSV(hue, sat, val))
        end
    end)

    for _, preset_color in ipairs(presets) do
        local button = create('TextButton', {
            Size = UDim2.fromOffset(10, 20),
            BackgroundColor3 = preset_color,
            BorderSizePixel = 0,
            Text = '',
            AutoButtonColor = false,
            ZIndex = 8
        }, preset_row)
        corner(button, 3)
        button.MouseButton1Click:Connect(function()
            paint(preset_color, true)
        end)
    end

    function manager:unfold_settings()
        self._state = not self._state
        if self._state then
            frame.Size = UDim2.new(0, BODY_W, 0, height_closed + picker_height)
        else
            frame.Size = UDim2.new(0, BODY_W, 0, height_closed)
        end
        self._module:refresh()
    end

    swatch.MouseButton1Click:Connect(function()
        manager:unfold_settings()
    end)

    local initial = Theme.Accent
    if settings.flag then
        local stored = self._library._config._flags[settings.flag]
        if type(stored) == 'string' then
            local parsed = parse_hex(stored)
            if parsed then initial = parsed end
        end
    elseif settings.color then
        initial = settings.color
    end
    paint(initial, false, false)

    self:refresh()
    return manager
end

--=====================================================================
--  Aliases for convenience
--=====================================================================
ModuleManager.create_input = ModuleManager.create_textbox
ModuleManager.create_label = ModuleManager.create_text

--=====================================================================
--  Custom window background
--=====================================================================
-- settings = {
--     image = 100228876632788,      -- id, table of ids, or a Folder of ImageLabels/Decals/StringValues
--     transparency = 0.2,           -- 0 visible → 1 invisible
--     scale_type = Enum.ScaleType.Crop
-- }
function Library:set_background(settings)
    settings = settings or {}
    local Stellar = CoreGui:FindFirstChild('Stellar')
    local Container = Stellar and Stellar:FindFirstChild('Container')
    if not Container then
        warn('[Stellar] set_background called before load()')
        return nil
    end

    local background = Container:FindFirstChild('CustomBackground')
    if not background then
        background = create('ImageLabel', {
            Name = 'CustomBackground',
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScaleType = Enum.ScaleType.Crop,
            Image = '',
            ImageTransparency = 1,
            ZIndex = 0
        }, Container)
        corner(background, 16)
    end

    local source = settings.image
    local resolved

    if typeof(source) == 'Instance' and source:IsA('Folder') then
        local options = source:GetChildren()
        if #options > 0 then
            local pick = options[math.random(1, #options)]
            if pick:IsA('ImageLabel') then
                resolved = pick.Image
            elseif pick:IsA('Decal') then
                resolved = pick.Texture
            elseif pick:IsA('StringValue') then
                resolved = pick.Value
            end
        end
    elseif type(source) == 'table' then
        if #source > 0 then
            resolved = source[math.random(1, #source)]
        end
    elseif source ~= nil then
        resolved = source
    end

    resolved = Util:resolve_asset_id(resolved)
    if not resolved then
        background.Image = ''
        background.ImageTransparency = 1
        return background
    end

    background.Image = resolved
    background.ScaleType = settings.scale_type or Enum.ScaleType.Crop
    background.ImageTransparency = settings.transparency or 0
    return background
end

function Library:clear_background()
    local Stellar = CoreGui:FindFirstChild('Stellar')
    local Container = Stellar and Stellar:FindFirstChild('Container')
    local background = Container and Container:FindFirstChild('CustomBackground')
    if background then
        background.Image = ''
        background.ImageTransparency = 1
    end
end

--=====================================================================
--  Teardown
--=====================================================================
function Library:destroy()
    Connections:disconnect_all()

    -- Tear down this instance's own window (not whichever ScreenGui happens
    -- to share the name, so multiple windows can coexist).
    if self._ui then
        pcall(function() self._ui:Destroy() end)
    end

    local loader = CoreGui:FindFirstChild('StellarLoader')
    if loader then loader:Destroy() end
    local notifications = CoreGui:FindFirstChild('StellarNotifications')
    if notifications then notifications:Destroy() end
    local tooltip = CoreGui:FindFirstChild('StellarTooltip')
    if tooltip then tooltip:Destroy() end

    self._ui = nil
    self._refs = {}
    self._tabs = {}
    self._search_items = {}
    self._active_tab = nil
    self._search_text = ''
    self._ui_open = false
end

return Library
