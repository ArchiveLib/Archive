local Library = {}

--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

--// Theme
Library.Theme = {
    Name = "Archive",
    Background = Color3.fromRGB(17, 18, 21),
    Border = Color3.fromRGB(38, 40, 46),
    Text = Color3.fromRGB(235, 235, 238),
    SubText = Color3.fromRGB(145, 148, 155),
    Accent = Color3.fromRGB(145, 95, 255),
}
-- wsp
--// Settings
Library.Name = "Archive"
Library.Connections = {}
Library.Version = "v1.0"

--//Print

print("["..Library.Name.."]" .. " Loading UI.")

--// Saving

--==================================================
--// CONFIG COMPONENTS
--==================================================

local ConfigComponents = {}

local function RegisterConfigComponent(Identifier, Get, Set)
    if not Identifier then
        return
    end

    ConfigComponents[Identifier] = {
        Get = Get,
        Set = Set,
    }
end

--// Utilities
local function Create(Class, Properties)
    local Success, Object = pcall(function()
        local Object = Instance.new(Class)

        for Property, Value in pairs(Properties or {}) do
            Object[Property] = Value
        end

        return Object
    end)

    if not Success then
        warn("["..Library.Name.."] " .. "Failed to create " .. tostring(Class) .. ": " .. tostring(Object))
        return nil
    end

    return Object
end

local function Connect(Signal, Callback)
    local Success, Connection = pcall(function()
        return Signal:Connect(Callback)
    end)

    if not Success then
        warn(
            "[" .. Library.Name .. "] Failed to connect signal: " ..
            tostring(Connection)
        )

        return nil
    end

    table.insert(Library.Connections, Connection)

    return Connection
end

local function DisconnectAll()
    for Index, Connection in ipairs(Library.Connections) do
        if Connection then
            pcall(function()
                Connection:Disconnect()
            end)
        end

        Library.Connections[Index] = nil
    end
end

local function MakeDraggable(Frame, DragArea)
    local Dragging = false
    local DragStart
    local StartPosition

    Connect(DragArea.InputBegan, function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        Dragging = true
        DragStart = Input.Position
        StartPosition = Frame.Position
    end)

    Connect(DragArea.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if not Dragging then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local Delta = Input.Position - DragStart

        local NewX = StartPosition.X.Offset + Delta.X
        local NewY = StartPosition.Y.Offset + Delta.Y

        local Camera = workspace.CurrentCamera

        if Camera then
            local Viewport = Camera.ViewportSize

            local WindowAbsoluteSize = Frame.AbsoluteSize

            local HalfWidth = WindowAbsoluteSize.X / 2
            local HalfHeight = WindowAbsoluteSize.Y / 2

            local MinX = -Viewport.X / 2 + HalfWidth
            local MaxX = Viewport.X / 2 - HalfWidth

            local MinY = -Viewport.Y / 2 + HalfHeight
            local MaxY = Viewport.Y / 2 - HalfHeight

            NewX = math.clamp(NewX, MinX, MaxX)
            NewY = math.clamp(NewY, MinY, MaxY)
        end

        Frame.Position = UDim2.new(
            StartPosition.X.Scale,
            NewX,
            StartPosition.Y.Scale,
            NewY
        )
    end)
end

local function Tween(Object, Properties, Duration, EasingStyle, EasingDirection)
    local Success, Result = pcall(function()
        local Info = TweenInfo.new(
            Duration or 0.25,
            EasingStyle or Enum.EasingStyle.Quart,
            EasingDirection or Enum.EasingDirection.Out
        )

        local Tween = TweenService:Create(Object, Info, Properties)
        Tween:Play()

        return Tween
    end)

    if not Success then
        warn("["..Library.Name.."] Failed to create tween: " .. tostring(Result))
        return nil
    end

    return Result
end

local function FadeObject(Object, Transparency, Duration)
    local Success, Error = pcall(function()
        local Properties = {}

        if Object:IsA("Frame") then
            Properties.BackgroundTransparency = Transparency

        elseif Object:IsA("TextLabel") or Object:IsA("TextButton") then
            Properties.TextTransparency = Transparency

        elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
            Properties.ImageTransparency = Transparency

        elseif Object:IsA("UIStroke") then
            Properties.Transparency = Transparency
        end

        if next(Properties) then
            Tween(Object, Properties, Duration)
        end
    end)

    if not Success then
        warn("["..Library.Name.."] Failed to fade object: " .. tostring(Error))
    end
end

local function ProtectGui(ScreenGui)
    pcall(function()
        if type(syn) == "table" and syn.protect_gui then
            syn.protect_gui(ScreenGui)
        elseif type(protectgui) == "function" then
            protectgui(ScreenGui)
        end
    end)
end

--// Get a suitable GUI parent
local function GetGuiParent()
    if type(gethui) == "function" then
        local Success, Result = pcall(gethui)

        if Success and Result then
            return Result
        end
    end

    local Success, CoreGui = pcall(game.GetService, game, "CoreGui")

    if Success and CoreGui then
        return CoreGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

--// Create Window
function Library:CreateWindow(Options)
    Options = Options or {}
    local Theme = Library.Theme

    --// Remove previous instance
    local Parent = GetGuiParent()
    for _, Object in ipairs(Parent:GetChildren()) do
        if Object:GetAttribute("ArchiveHubUI") == true then
            pcall(function()
                Object:Destroy()
            end)
        end
    end

    local WindowSize = Options.Size or UDim2.fromOffset(680, 430)

    --// ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = self.Name,
        ResetOnSpawn = false,
        DisplayOrder = 2147483647,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Parent,
    })

    ScreenGui:SetAttribute("ArchiveHubUI", true)
    ProtectGui(ScreenGui)

    --==================================================
    --// MAIN WINDOW
    --==================================================

    local Window = Create("Frame", {
        Name = "Window",
        Parent = ScreenGui,

        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,

        Size = UDim2.fromOffset(340, 170),

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        ClipsDescendants = true,

        ZIndex = 1,
    })

    Create("UICorner", {
        Parent = Window,
        CornerRadius = UDim.new(0, 7),
    })

    local WindowStroke = Create("UIStroke", {
        Parent = Window,
        Color = Theme.Border,
        Thickness = 1,
    })

    local WindowScale = Create("UIScale", {
        Parent = Window,
        Scale = 1,
    })

--==================================================
--// NOTIFICATION SYSTEM
--==================================================

    local NotificationContainers = {}

    local NotificationPositions = {
        TopLeft = {
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.fromOffset(15, 15),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        },

        TopRight = {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -15, 0, 15),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        },

        BottomLeft = {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 15, 1, -15),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
        },

        BottomRight = {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -15, 1, -15),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
        },
    }

    for Name, Info in pairs(NotificationPositions) do
        local Container = Create("Frame", {
            Name = Name,
            Parent = ScreenGui,

            AnchorPoint = Info.AnchorPoint,
            Position = Info.Position,

            Size = UDim2.fromOffset(320, 0),

            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            AutomaticSize = Enum.AutomaticSize.Y,

            ZIndex = 100,
        })

        Create("UIListLayout", {
            Parent = Container,

            FillDirection = Enum.FillDirection.Vertical,

            HorizontalAlignment = Info.HorizontalAlignment,
            VerticalAlignment = Info.VerticalAlignment,

            SortOrder = Enum.SortOrder.LayoutOrder,

            Padding = UDim.new(0, 8),
        })

        NotificationContainers[Name] = Container
    end

    --==================================================
    --// LOADING
    --==================================================

    local Loading = Create("Frame", {
        Name = "Loading",
        Parent = Window,

        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,

        Size = UDim2.fromScale(1, 1),

        ZIndex = 100,
    })

    Create("UICorner", {
        Parent = Loading,
        CornerRadius = UDim.new(0, 7),
    })

    local LoadingTitle = Create("TextLabel", {
        Name = "Title",
        Parent = Loading,

        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.40),

        Size = UDim2.fromOffset(300, 30),

        Font = Enum.Font.GothamMedium,
        Text = Library.Name or "Archive",
        TextColor3 = Theme.Text,
        TextSize = 19,

        TextTransparency = 1,

        ZIndex = 101,
    })

    local LoadingStatus = Create("TextLabel", {
        Name = "Status",
        Parent = Loading,

        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.53),

        Size = UDim2.fromOffset(280, 20),

        Font = Enum.Font.Gotham,
        Text = "Preparing...",
        TextColor3 = Theme.SubText,
        TextSize = 9,

        TextTransparency = 1,

        ZIndex = 101,
    })

    local ProgressBackground = Create("Frame", {
        Name = "ProgressBackground",
        Parent = Loading,

        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.64),

        Size = UDim2.fromOffset(150, 3),

        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,

        ZIndex = 101,
    })

    Create("UICorner", {
        Parent = ProgressBackground,
        CornerRadius = UDim.new(1, 0),
    })

    local Progress = Create("Frame", {
        Name = "Progress",
        Parent = ProgressBackground,

        Size = UDim2.new(0, 0, 1, 0),

        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,

        ZIndex = 102,
    })

    Create("UICorner", {
        Parent = Progress,
        CornerRadius = UDim.new(1, 0),
    })

    --==================================================
    --// MAIN CONTENT
    --==================================================

    local Content = Create("Frame", {
        Name = "Content",
        Parent = Window,

        BackgroundTransparency = 1,

        Size = UDim2.fromScale(1, 1),

        Visible = false,

        ZIndex = 2,
    })

    --==================================================
    --// SIDEBAR
    --==================================================

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Content,

        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.15,

        BorderSizePixel = 0,

        Size = UDim2.new(0, 150, 1, 0),

        ZIndex = 3,
    })

    Create("UICorner", {
        Parent = Sidebar,
        CornerRadius = UDim.new(0, 7),
    })

    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Parent = Sidebar,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Position = UDim2.fromOffset(10, 55),
        Size = UDim2.new(1, -20, 1, -65),

        ScrollBarThickness = 0,

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        ZIndex = 4,
    })

    local TabLayout = Create("UIListLayout", {
        Parent = TabList,

        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    --==================================================
    --// TOP BAR
    --==================================================

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = Content,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 45),

        ZIndex = 10,
    })

    -- Only this area can drag the window
    MakeDraggable(Window, TopBar)

    --==================================================
    --// TITLE
    --==================================================
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -36, 1, 0),

        Font = Enum.Font.GothamMedium,
        Text = Options.Title or "Archive",
        TextColor3 = Theme.Text,
        TextSize = 14,

        TextTransparency = 1,

        TextXAlignment = Enum.TextXAlignment.Left,

        ZIndex = 11,
    })

    local Version = Create("TextLabel", {
        Name = "Version",
        Parent = TopBar,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(64, 0),
        Size = UDim2.new(1, -36, 1, 0),

        Font = Enum.Font.GothamMedium,
        Text = Options.Version or Library.Version or "v1.0",
        TextColor3 = Color3.fromRGB(67, 72, 80),
        TextSize = 11,

        TextTransparency = 1,

        TextXAlignment = Enum.TextXAlignment.Left,

        ZIndex = 11,
    })

--==================================================
--// WINDOW CONTROLS
--==================================================

    local MinimizeButton = Create("TextButton", {
        Name = "Minimize",
        Parent = TopBar,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Position = UDim2.new(1, -68, 0, 0),
        Size = UDim2.fromOffset(34, 45),

        AutoButtonColor = false,

        Font = Enum.Font.GothamMedium,
        Text = "−",
        TextColor3 = Theme.SubText,
        TextSize = 17,

        ZIndex = 12,
    })

    local CloseButton = Create("TextButton", {
        Name = "Close",
        Parent = TopBar,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Position = UDim2.new(1, -34, 0, 0),
        Size = UDim2.fromOffset(34, 45),

        AutoButtonColor = false,

        Font = Enum.Font.GothamMedium,
        Text = "×",
        TextColor3 = Theme.SubText,
        TextSize = 18,

        ZIndex = 12,
    })

--==================================================
--// WINDOW CONTROL HOVER
--==================================================

    Connect(MinimizeButton.MouseEnter, function()
        Tween(MinimizeButton, {
            TextColor3 = Theme.Text,
        }, 0.12)
    end)

    Connect(MinimizeButton.MouseLeave, function()
        Tween(MinimizeButton, {
            TextColor3 = Theme.SubText,
        }, 0.12)
    end)

    Connect(CloseButton.MouseEnter, function()
        Tween(CloseButton, {
            TextColor3 = Theme.Text,
        }, 0.12)
    end)

    Connect(CloseButton.MouseLeave, function()
        Tween(CloseButton, {
            TextColor3 = Theme.SubText,
        }, 0.12)
    end)

--==================================================
--// WINDOW CONTROL INPUT
--==================================================

    local WindowObject = {}
    local ConfirmClose = Options.ConfirmClose ~= false
    local Minimized = false

    Connect(CloseButton.MouseButton1Click, function()
        if ConfirmClose then
            WindowObject:ShowCloseConfirmation()
        else
            WindowObject:Destroy()
        end
    end)

    Connect(MinimizeButton.MouseButton1Click, function()
        Minimized = not Minimized

        if Minimized then
            Tween(Window, {
                Size = UDim2.new(
                    WindowSize.X.Scale,
                    WindowSize.X.Offset,
                    0,
                    45
                ),
            }, 0.25)

            MinimizeButton.Text = "+"
        else
            Tween(Window, {
                Size = WindowSize,
            }, 0.25)

            MinimizeButton.Text = "−"
        end
    end)

    --==================================================
--// CLOSE CONFIRMATION
--==================================================

    local CloseConfirmation = nil
    local CloseConfirmationOpen = false

    function WindowObject:ShowCloseConfirmation()
        if CloseConfirmationOpen then
            return
        end

        CloseConfirmationOpen = true

        --==================================================
        --// OVERLAY
        --==================================================

        local Overlay = Create("TextButton", {
            Name = "CloseConfirmationOverlay",
            Parent = ScreenGui,

            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            Size = UDim2.fromScale(1,1),

            AutoButtonColor = false,
            Text = "",

            ZIndex = 200,
        })

        --==================================================
        --// MODAL
        --==================================================

        local Modal = Create("Frame", {
            Name = "CloseConfirmation",
            Parent = Overlay,

            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),

            Size = UDim2.fromOffset(300, 145),

            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 0.05,

            BorderSizePixel = 0,

            ZIndex = 201,
        })

        Create("UICorner", {
            Parent = Modal,
            CornerRadius = UDim.new(0, 8),
        })

        Create("UIStroke", {
            Parent = Modal,

            Color = Theme.Border,
            Transparency = 0.25,

            Thickness = 1,
        })

        --==================================================
        --// TITLE
        --==================================================

        local Title = Create("TextLabel", {
            Name = "Title",
            Parent = Modal,

            BackgroundTransparency = 1,

            Position = UDim2.fromOffset(16, 14),
            Size = UDim2.new(1, -32, 0, 22),

            Font = Enum.Font.GothamMedium,

            Text = "Close Menu?",
            TextColor3 = Theme.Text,
            TextSize = 13,

            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,

            ZIndex = 202,
        })

        --==================================================
        --// DESCRIPTION
        --==================================================

        local Description = Create("TextLabel", {
            Name = "Description",
            Parent = Modal,

            BackgroundTransparency = 1,

            Position = UDim2.fromOffset(16, 42),
            Size = UDim2.new(1, -32, 0, 42),

            Font = Enum.Font.Gotham,

            Text = "Are you sure you want to close this menu?",
            TextColor3 = Theme.SubText,
            TextSize = 10,

            TextWrapped = true,

            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,

            ZIndex = 202,
        })

        --==================================================
        --// CANCEL
        --==================================================

        local CancelButton = Create("TextButton", {
            Name = "Cancel",
            Parent = Modal,

            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -88, 1, -14),

            Size = UDim2.fromOffset(70, 28),

            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0.25,

            BorderSizePixel = 0,

            AutoButtonColor = false,

            Font = Enum.Font.GothamMedium,

            Text = "Cancel",
            TextColor3 = Theme.Text,
            TextSize = 10,

            ZIndex = 202,
        })

        Create("UICorner", {
            Parent = CancelButton,
            CornerRadius = UDim.new(0, 5),
        })

        --==================================================
        --// CLOSE
        --==================================================

        local ConfirmButton = Create("TextButton", {
            Name = "Confirm",
            Parent = Modal,

            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -14, 1, -14),

            Size = UDim2.fromOffset(65, 28),

            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0,

            BorderSizePixel = 0,

            AutoButtonColor = false,

            Font = Enum.Font.GothamMedium,

            Text = "Close",
            TextColor3 = Theme.Text,
            TextSize = 10,

            ZIndex = 202,
        })

        Create("UICorner", {
            Parent = ConfirmButton,
            CornerRadius = UDim.new(0, 5),
        })

        --==================================================
        --// OPEN ANIMATION
        --==================================================

        Modal.Size = UDim2.fromOffset(285, 135)

        Tween(Overlay, {
            BackgroundTransparency = 0.45,
        }, 0.15)

        Tween(Modal, {
            Size = UDim2.fromOffset(300, 145),
        }, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        --==================================================
        --// CLOSE CONFIRMATION
        --==================================================

        local Closing = false

        local function DismissConfirmation()
            if Closing then
                return
            end

            Closing = true

            Tween(Overlay, {
                BackgroundTransparency = 1,
            }, 0.12)

            local TweenObject = Tween(
                Modal,
                {
                    Size = UDim2.fromOffset(285, 135),
                },
                0.12,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.In
            )

            TweenObject.Completed:Connect(function()
                pcall(function()
                    Overlay:Destroy()
                end)

                CloseConfirmation = nil
                CloseConfirmationOpen = false
            end)
        end

        --==================================================
        --// BUTTON HOVER
        --==================================================

        Connect(CancelButton.MouseEnter, function()
            Tween(CancelButton, {
                BackgroundTransparency = 0.10,
            }, 0.10)
        end)

        Connect(CancelButton.MouseLeave, function()
            Tween(CancelButton, {
                BackgroundTransparency = 0.25,
            }, 0.10)
        end)

        Connect(ConfirmButton.MouseEnter, function()
            Tween(ConfirmButton, {
                BackgroundTransparency = 0.10,
            }, 0.10)
        end)

        Connect(ConfirmButton.MouseLeave, function()
            Tween(ConfirmButton, {
                BackgroundTransparency = 0,
            }, 0.10)
        end)

        --==================================================
        --// INPUT
        --==================================================

        Connect(CancelButton.MouseButton1Click, function()
            DismissConfirmation()
        end)

        Connect(Overlay.MouseButton1Click, function()
            DismissConfirmation()
        end)

        Connect(ConfirmButton.MouseButton1Click, function()
            if Closing then
                return
            end

            CloseConfirmationOpen = false

            pcall(function()
                Overlay:Destroy()
            end)

            CloseConfirmation = nil

            WindowObject:Destroy()
        end)

        CloseConfirmation = {
            Instance = Overlay,
            Modal = Modal,
        }

        return CloseConfirmation
    end

    --==================================================
    --// TAB STATE
    --==================================================

    local Tabs = {}
    local TabIndex = 0
    local SelectedTab = nil

    --==================================================
    --// WINDOW OBJECT
    --==================================================

    function WindowObject:Destroy()
        DisconnectAll()

        pcall(function()
            ScreenGui:Destroy()
        end)
    end

--==================================================
--// UI VISIBILITY
--==================================================

local UIKeybind = Options.Keybind or Enum.KeyCode.P
local UIVisible = true
local UIAnimating = false
local UILoaded = false
local UIInputListening = false

function WindowObject:SetVisible(Visible)
    if type(Visible) ~= "boolean" then
        warn(
            "[" .. Library.Name .. "] Failed to set UI visibility: " ..
            "Expected boolean, got " .. tostring(Visible)
        )

        return
    end

    if not UILoaded then
        return
    end

    if UIAnimating then
        return
    end

    if UIVisible == Visible then
        return
    end

    UIAnimating = true

    if Visible then
        --==================================================
        --// OPEN
        --==================================================

        Window.Visible = true
        Content.Visible = true

        WindowScale.Scale = 0.92


        local ScaleTween = Tween(
            WindowScale,
            {
                Scale = 1,
            },
            0.22,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        )

        ScaleTween.Completed:Wait()

        UIVisible = true

    else
        --==================================================
        --// CLOSE
        --==================================================

        local ScaleTween = Tween(
            WindowScale,
            {
                Scale = 0.92,
            },
            0.16,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.In
        )

        ScaleTween.Completed:Wait()

        Content.Visible = false
        Window.Visible = false

        WindowScale.Scale = 1

        UIVisible = false
    end

    UIAnimating = false
end

function WindowObject:IsVisible()
    return UIVisible
end

--==================================================
--// CLOSE CONFIRMATION
--==================================================

function WindowObject:SetConfirmClose(Value)
    if type(Value) ~= "boolean" then
        warn(
            "[" .. Library.Name .. "] Failed to set close confirmation: " ..
            "Expected boolean, got " .. tostring(Value)
        )

        return
    end

    ConfirmClose = Value
end

function WindowObject:GetConfirmClose()
    return ConfirmClose
end

--==================================================
--// UI KEYBIND
--==================================================

function WindowObject:SetKeybind(Key)
    if typeof(Key) ~= "EnumItem" or Key.EnumType ~= Enum.KeyCode then
        warn(
            "[" .. Library.Name .. "] Failed to set UI keybind: " ..
            "Expected Enum.KeyCode, got " .. tostring(Key)
        )

        return
    end

    UIKeybind = Key
end

function WindowObject:GetKeybind()
    return UIKeybind
end

--==================================================
--// UI KEYBIND INPUT
--==================================================

Connect(UserInputService.InputBegan, function(Input, GameProcessed)
    if GameProcessed then
        return
    end

    if not UILoaded then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if UIInputListening then
        return
    end

    if Input.KeyCode ~= UIKeybind then
        return
    end

    WindowObject:SetVisible(not UIVisible)
end)

function WindowObject:CreateTab(Options)
    Options = Options or {}

    local TabName = Options.Name or "Tab"
    local IsSettings = Options.IsSettings == true

    TabIndex += 1

    --// Tab Object
    local Tab = {
        Name = TabName,
        Index = TabIndex,
        IsSettings = IsSettings,
    }

    --==================================================
    --// TAB CONTENT
    --==================================================

    local TabContent = Create("ScrollingFrame", {
        Name = TabName .. "Content",
        Parent = Content,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Position = UDim2.fromOffset(150, 45),
        Size = UDim2.new(1, -150, 1, -45),

        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,

        Visible = false,

        ZIndex = 3,
    })

    Create("UIPadding", {
        Parent = TabContent,

        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
    })

    local TabLayout = Create("UIListLayout", {
        Parent = TabContent,

        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })

--==================================================
--// COMPONENT ROW SYSTEM
--==================================================

local CurrentRow = nil
local ComponentsInRow = 0

local function GetComponentRow()
    if not CurrentRow or ComponentsInRow >= 2 then
        ComponentsInRow = 0

        CurrentRow = Create("Frame", {
            Name = "ComponentRow",
            Parent = TabContent,

            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            Size = UDim2.new(1, 0, 0, 40),

            ZIndex = 5,
        })

        Create("UIListLayout", {
            Parent = CurrentRow,

            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,

            SortOrder = Enum.SortOrder.LayoutOrder,

            Padding = UDim.new(0, 8),
        })
    end

    ComponentsInRow += 1

    return CurrentRow
end

--==================================================
--// TAB BUTTON
--==================================================

local TabButton = Create("TextButton", {
    Name = TabName,
    Parent = TabList,

    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    Size = UDim2.new(1, 0, 0, 34),

    AutoButtonColor = false,

    Font = Enum.Font.GothamMedium,
    Text = TabName,
    TextColor3 = Theme.SubText,
    TextSize = 11,

    TextXAlignment = Enum.TextXAlignment.Left,

    LayoutOrder = IsSettings and 999999 or TabIndex,

    ZIndex = 5,
})

Create("UICorner", {
    Parent = TabButton,
    CornerRadius = UDim.new(0, 5),
})

Create("UIPadding", {
    Parent = TabButton,
    PaddingLeft = UDim.new(0, 12),
})

function Tab:CreateButton(Options)
    Options = Options or {}

    local ButtonName = Options.Name or "Button"
    local ButtonText = Options.Text or "Run"
    local ClickedText = Options.ClickedText or "Clicked!"
    local Cooldown = Options.Cooldown or 0
    local Callback = Options.Callback

    local OnCooldown = false

    --==================================================
    --// GET COMPONENT ROW
    --==================================================

    local Row = GetComponentRow()

    --==================================================
    --// COMPONENT
    --==================================================

    local Component = Create("Frame", {
        Name = ButtonName,

        Parent = Row,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.5, -4, 1, 0),

        ZIndex = 5,
    })

    --==================================================
    --// LABEL
    --==================================================

    local Label = Create("TextLabel", {
        Name = "Label",

        Parent = Component,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -85, 1, 0),

        Font = Enum.Font.GothamMedium,
        Text = ButtonName,
        TextColor3 = Theme.Text,
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 6,
    })

    --==================================================
    --// BUTTON
    --==================================================

    local Button = Create("TextButton", {
        Name = "Button",

        Parent = Component,

        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.fromOffset(70, 27),

        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.25,

        BorderSizePixel = 0,

        AutoButtonColor = false,

        Font = Enum.Font.GothamMedium,
        Text = ButtonText,
        TextColor3 = Theme.Text,
        TextSize = 10,

        ZIndex = 6,
    })

    Create("UICorner", {
        Parent = Button,
        CornerRadius = UDim.new(0, 5),
    })

    --==================================================
    --// HOVER
    --==================================================

    Connect(Button.MouseEnter, function()
        Tween(Button, {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0,
        }, 0.12)
    end)

    Connect(Button.MouseLeave, function()
        Tween(Button, {
            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0.25,
        }, 0.12)
    end)

    --==================================================
    --// CLICK
    --==================================================

--==================================================
--// BUTTON ANIMATION / CLICK
--==================================================

local ButtonScale = Create("UIScale", {
    Parent = Button,
    Scale = 1,
})

    Connect(Button.MouseButton1Click, function()
        if OnCooldown then
            return
        end

        if type(Callback) ~= "function" then
            warn(
                "[" .. Library.Name .. "] Button callback failed: " ..
                "Callback is not a function"
            )

            return
        end

        OnCooldown = true

        --// Click animation
        Tween(ButtonScale, {
            Scale = 0.92,
        }, 0.07).Completed:Wait()

        Tween(ButtonScale, {
            Scale = 1,
        }, 0.12)

        --// Show clicked state
        Button.Text = ClickedText

        --// Run callback safely
        local Success, Error = pcall(Callback)

        if not Success then
            warn(
                "[" .. Library.Name .. "] Button callback failed: " ..
                tostring(Error)
            )
        end

        --// Keep clicked text visible briefly
        task.delay(0.55, function()
            if Button and Button.Parent then
                Button.Text = ButtonText
            end
        end)

        --// Cooldown
        task.delay(Cooldown, function()
            OnCooldown = false
        end)
    end)

    --==================================================
    --// BUTTON OBJECT
    --==================================================

    local ButtonObject = {}

    function ButtonObject:Destroy()
        pcall(function()
            Component:Destroy()
        end)
    end

    function ButtonObject:SetText(Text)
        pcall(function()
            Button.Text = tostring(Text)
        end)
    end

    ButtonObject.Instance = Component
    ButtonObject.Button = Button

    return ButtonObject
end

--==================================================
--// CREATE TOGGLE
--==================================================

function Tab:CreateToggle(Options)
    Options = Options or {}

    local ToggleName = Options.Name or "Toggle"
    local Default = Options.Default == true
    local Callback = Options.Callback

    local Value = Default

    --==================================================
    --// GET COMPONENT ROW
    --==================================================

    local Row = GetComponentRow()

    --==================================================
    --// COMPONENT
    --==================================================

    local Component = Create("Frame", {
        Name = ToggleName,

        Parent = Row,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.5, -4, 1, 0),

        ZIndex = 5,
    })

    --==================================================
    --// LABEL
    --==================================================

    local Label = Create("TextLabel", {
        Name = "Label",

        Parent = Component,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -65, 1, 0),

        Font = Enum.Font.GothamMedium,
        Text = ToggleName,
        RichText = true,
        TextColor3 = Theme.Text,
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 6,
    })

    --==================================================
    --// SWITCH
    --==================================================

    local Switch = Create("TextButton", {
        Name = "Switch",

        Parent = Component,

        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.fromOffset(38, 20),

        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.15,

        BorderSizePixel = 0,

        AutoButtonColor = false,

        Text = "",

        ZIndex = 6,
    })

    Create("UICorner", {
        Parent = Switch,
        CornerRadius = UDim.new(1, 0),
    })

    --==================================================
    --// KNOB
    --==================================================

    local Knob = Create("Frame", {
        Name = "Knob",

        Parent = Switch,

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),

        Size = UDim2.fromOffset(14, 14),

        BackgroundColor3 = Theme.SubText,

        BorderSizePixel = 0,

        ZIndex = 7,
    })

    Create("UICorner", {
        Parent = Knob,
        CornerRadius = UDim.new(1, 0),
    })

    --==================================================
    --// UPDATE VISUAL
    --==================================================

    local function UpdateToggle(Instant)
        local SwitchColor = Value and Theme.Accent or Theme.Border
        local KnobColor = Value and Theme.Text or Theme.SubText
        local KnobPosition = Value
            and UDim2.new(1, -10, 0.5, 0)
            or UDim2.new(0, 10, 0.5, 0)

        if Instant then
            Switch.BackgroundColor3 = SwitchColor
            Knob.BackgroundColor3 = KnobColor
            Knob.Position = KnobPosition

            return
        end

        Tween(Switch, {
            BackgroundColor3 = SwitchColor,
        }, 0.15)

        Tween(Knob, {
            BackgroundColor3 = KnobColor,
            Position = KnobPosition,
        }, 0.18)
    end

    local ToggleObject = {}

    --==================================================
    --// HOVER
    --==================================================

    Connect(Switch.MouseEnter, function()
        Tween(Switch, {
            BackgroundTransparency = 0,
        }, 0.12)
    end)

    Connect(Switch.MouseLeave, function()
        Tween(Switch, {
            BackgroundTransparency = 0.15,
        }, 0.12)
    end)

    --==================================================
    --// CLICK
    --==================================================

    Connect(Switch.MouseButton1Click, function()
        Value = not Value

        UpdateToggle(false)

        if type(Callback) ~= "function" then
            warn(
                "[" .. Library.Name .. "] Toggle callback failed: " ..
                "Callback is not a function"
            )

            return
        end

        local Success, Error = pcall(Callback, Value)

        if not Success then
            warn(
                "[" .. Library.Name .. "] Toggle callback failed: " ..
                tostring(Error)
            )
        end
    end)

    --==================================================
    --// INITIAL STATE
    --==================================================

    UpdateToggle(true)

    --==================================================
    --// TOGGLE OBJECT
    --==================================================

    local ToggleObject = {}

    function ToggleObject:SetValue(NewValue)
        if type(NewValue) ~= "boolean" then
            warn(
                "[" .. Library.Name .. "] Toggle:SetValue failed: " ..
                "Expected boolean, got " .. tostring(NewValue)
            )

            return
        end

        Value = NewValue

        UpdateToggle(false)

        if type(Callback) ~= "function" then
            return
        end

        local Success, Error = pcall(Callback, Value)

        if not Success then
            warn(
                "[" .. Library.Name .. "] Toggle callback failed: " ..
                tostring(Error)
            )
        end
    end

    function ToggleObject:GetValue()
        return Value
    end

    function ToggleObject:Destroy()
        pcall(function()
            Component:Destroy()
        end)
    end

    --==================================================
    --// CONFIG REGISTRATION
    --==================================================

    if Options.Identifier then
        RegisterConfigComponent(
            Options.Identifier,

            function()
                return ToggleObject:GetValue()
            end,

            function(NewValue)
                ToggleObject:SetValue(NewValue)
            end
        )
    end

    ToggleObject.Instance = Component
    ToggleObject.Switch = Switch

    return ToggleObject
end

function Tab:CreateTextbox(Options)
    Options = Options or {}

    local TextboxName = Options.Name or "Textbox"
    local Default = tostring(Options.Default or "")
    local Placeholder = tostring(Options.Placeholder or "Type here...")
    local ClearOnFocus = Options.ClearOnFocus == true
    local Callback = Options.Callback

    local CurrentText = Default

    --==================================================
    --// GET COMPONENT ROW
    --==================================================

    local Row = GetComponentRow()

    --==================================================
    --// COMPONENT
    --==================================================

    local Component = Create("Frame", {
        Name = TextboxName,
        Parent = Row,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.5, -4, 0, 32),

        ZIndex = 5,
    })

    --==================================================
    --// LABEL
    --==================================================

    local Label = Create("TextLabel", {
        Name = "Label",
        Parent = Component,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -115, 1, 0),

        Font = Enum.Font.GothamMedium,
        Text = TextboxName,
        TextColor3 = Theme.Text,
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 6,
    })

    --==================================================
    --// TEXTBOX INPUT
    --==================================================

    local InputBox = Create("TextBox", {
        Name = "Input",
        Parent = Component,

        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.fromOffset(105, 27),

        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.25,

        BorderSizePixel = 0,

        Font = Enum.Font.Gotham,
        Text = Default,
        PlaceholderText = Placeholder,
        PlaceholderColor3 = Theme.SubText,
        TextColor3 = Theme.Text,
        TextSize = 10,

        ClearTextOnFocus = ClearOnFocus,
        ClipsDescendants = true,

        ZIndex = 6,
    })

    Create("UICorner", {
        Parent = InputBox,
        CornerRadius = UDim.new(0, 5),
    })

    Create("UIPadding", {
        Parent = InputBox,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })

    --==================================================
    --// FOCUS ANIMATIONS & CALLBACK
    --==================================================

    Connect(InputBox.Focused, function()
        Tween(InputBox, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Theme.Accent,
        }, 0.12)
    end)

    Connect(InputBox.FocusLost, function(EnterPressed)
        Tween(InputBox, {
            BackgroundTransparency = 0.25,
            BackgroundColor3 = Theme.Border,
        }, 0.12)

        CurrentText = InputBox.Text

        if type(Callback) == "function" then
            local Success, Error = pcall(Callback, CurrentText, EnterPressed)

            if not Success then
                warn(
                    "[" .. Library.Name .. "] Textbox callback failed: " ..
                    tostring(Error)
                )
            end
        end
    end)

    --==================================================
    --// HOVER
    --==================================================

    Connect(InputBox.MouseEnter, function()
        if not InputBox:IsFocused() then
            Tween(InputBox, {
                BackgroundTransparency = 0.10,
            }, 0.10)
        end
    end)

    Connect(InputBox.MouseLeave, function()
        if not InputBox:IsFocused() then
            Tween(InputBox, {
                BackgroundTransparency = 0.25,
            }, 0.10)
        end
    end)

    --==================================================
    --// TEXTBOX OBJECT
    --==================================================

    local TextboxObject = {}

    function TextboxObject:Set(Text)
        CurrentText = tostring(Text or "")
        InputBox.Text = CurrentText

        if type(Callback) == "function" then
            pcall(Callback, CurrentText, false)
        end
    end

    function TextboxObject:Get()
        return InputBox.Text
    end

    function TextboxObject:Clear()
        CurrentText = ""
        InputBox.Text = ""

        if type(Callback) == "function" then
            pcall(Callback, "", false)
        end
    end

    function TextboxObject:Destroy()
        pcall(function()
            Component:Destroy()
        end)
    end

    --==================================================
    --// OPTIONAL CONFIG REGISTRATION
    --==================================================

    if Options.Identifier then
        RegisterConfigComponent(
            Options.Identifier,

            function()
                return TextboxObject:Get()
            end,

            function(NewValue)
                TextboxObject:Set(NewValue)
            end
        )
    end

    TextboxObject.Instance = Component
    TextboxObject.Input = InputBox

    return TextboxObject
end

function Tab:CreateDropdown(Options)
    Options = Options or {}

    local DropdownName = Options.Name or "Dropdown"
    local DropdownOptions = Options.Options or {}
    local Default = Options.Default
    local Callback = Options.Callback

    local Selected = Default or DropdownOptions[1]
    local Open = false
    local Selecting = false

    --==================================================
    --// GET COMPONENT ROW
    --==================================================

    local Row = GetComponentRow()

    --==================================================
    --// COMPONENT
    --==================================================

    local Component = Create("Frame", {
        Name = DropdownName,
        Parent = Row,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.5, -4, 0, 32),

        ZIndex = 10,
    })

    --==================================================
    --// LABEL
    --==================================================

    local Label = Create("TextLabel", {
        Name = "Label",
        Parent = Component,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -105, 0, 32),

        Font = Enum.Font.GothamMedium,
        Text = DropdownName,
        TextColor3 = Theme.Text,
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 11,
    })

    --==================================================
    --// DROPDOWN BUTTON
    --==================================================

    local DropdownButton = Create("TextButton", {
        Name = "Button",
        Parent = Component,

        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 2),

        Size = UDim2.fromOffset(95, 28),

        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.25,

        BorderSizePixel = 0,

        AutoButtonColor = false,

        Font = Enum.Font.GothamMedium,
        Text = tostring(Selected or "Select"),
        TextColor3 = Theme.Text,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left,

        ZIndex = 12,
    })

    Create("UICorner", {
        Parent = DropdownButton,
        CornerRadius = UDim.new(0, 5),
    })

    Create("UIPadding", {
        Parent = DropdownButton,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 22),
    })

    --==================================================
    --// ARROW
    --==================================================

    local Arrow = Create("TextLabel", {
        Name = "Arrow",
        Parent = DropdownButton,

        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -7, 0.5, 0),

        Size = UDim2.fromOffset(12, 12),

        Font = Enum.Font.GothamMedium,
        Text = "v",
        TextColor3 = Theme.SubText,
        TextSize = 12,

        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 13,
    })

    --==================================================
    --// OPTIONS
    --==================================================

    local OptionsFrame = Create("Frame", {
        Name = "Options",
        Parent = Component,

        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 0),

        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.02,

        BorderSizePixel = 0,

        ClipsDescendants = true,
        Visible = false,

        ZIndex = 999999,
    })

    Create("UICorner", {
        Parent = OptionsFrame,
        CornerRadius = UDim.new(0, 5),
    })

    Create("UIStroke", {
        Parent = OptionsFrame,
        Color = Theme.Border,
        Thickness = 1,
    })

    local OptionsPadding = Create("UIPadding", {
        Parent = OptionsFrame,

        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    })

    local OptionsLayout = Create("UIListLayout", {
        Parent = OptionsFrame,

        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    --==================================================
    --// CREATE OPTION
    --==================================================

    local function CreateOption(Value, Index)
        local OptionButton = Create("TextButton", {
            Name = tostring(Value),
            Parent = OptionsFrame,

            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            Size = UDim2.new(1, 0, 0, 27),

            AutoButtonColor = false,

            Font = Enum.Font.Gotham,
            Text = tostring(Value),
            TextColor3 = Theme.SubText,
            TextSize = 10,

            TextXAlignment = Enum.TextXAlignment.Left,

            LayoutOrder = Index,

            ZIndex = 21,
        })

        Create("UICorner", {
            Parent = OptionButton,
            CornerRadius = UDim.new(0, 4),
        })

        Create("UIPadding", {
            Parent = OptionButton,
            PaddingLeft = UDim.new(0, 8),
        })

        Connect(OptionButton.MouseEnter, function()
            Tween(OptionButton, {
                BackgroundTransparency = 0.85,
                TextColor3 = Theme.Text,
            }, 0.10)
        end)

        Connect(OptionButton.MouseLeave, function()
            Tween(OptionButton, {
                BackgroundTransparency = 1,
                TextColor3 = Theme.SubText,
            }, 0.10)
        end)

        Connect(OptionButton.MouseButton1Click, function()
            Selected = Value

            DropdownButton.Text = tostring(Value)

            if type(Callback) == "function" then
                local Success, Error = pcall(Callback, Value)

                if not Success then
                    warn(
                        "[" .. Library.Name .. "] Dropdown callback failed: " ..
                        tostring(Error)
                    )
                end
            end

            Open = false

            OptionsFrame.Visible = false

            Tween(Arrow, {
                Rotation = 0,
            }, 0.15)

            Tween(DropdownButton, {
                BackgroundTransparency = 0.25,
            }, 0.12)
        end)

        return OptionButton
    end

    for Index, Value in ipairs(DropdownOptions) do
        CreateOption(Value, Index)
    end

    --==================================================
    --// DROPDOWN TOGGLE
    --==================================================

    Connect(DropdownButton.MouseEnter, function()
        Tween(DropdownButton, {
            BackgroundTransparency = 0.10,
        }, 0.10)
    end)

    Connect(DropdownButton.MouseLeave, function()
        if not Open then
            Tween(DropdownButton, {
                BackgroundTransparency = 0.25,
            }, 0.10)
        end
    end)

    Connect(DropdownButton.MouseButton1Click, function()
        if Selecting then
            return
        end

        Selecting = true

        Open = not Open

        if Open then
            OptionsFrame.Visible = true

            local Height = OptionsLayout.AbsoluteContentSize.Y +
                OptionsPadding.PaddingTop.Offset +
                OptionsPadding.PaddingBottom.Offset

            Tween(OptionsFrame, {
                Size = UDim2.new(1, 0, 0, Height),
            }, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            Tween(Arrow, {
                Rotation = 180,
            }, 0.15)

            Tween(DropdownButton, {
                BackgroundTransparency = 0.10,
            }, 0.12)

        else
            local CloseTween = Tween(OptionsFrame, {
                Size = UDim2.new(1, 0, 0, 0),
            }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

            Tween(Arrow, {
                Rotation = 0,
            }, 0.15)

            Tween(DropdownButton, {
                BackgroundTransparency = 0.25,
            }, 0.12)

            CloseTween.Completed:Wait()

            OptionsFrame.Visible = false
        end

        Selecting = false
    end)

    --==================================================
    --// DROPDOWN OBJECT
    --==================================================

    local DropdownObject = {}

    function DropdownObject:Set(Value)
        for _, OptionButton in ipairs(OptionsFrame:GetChildren()) do
            if OptionButton:IsA("TextButton") and OptionButton.Text == tostring(Value) then
                Selected = Value
                DropdownButton.Text = tostring(Value)

                if type(Callback) == "function" then
                    local Success, Error = pcall(Callback, Value)

                    if not Success then
                        warn(
                            "[" .. Library.Name .. "] Dropdown callback failed: " ..
                            tostring(Error)
                        )
                    end
                end

                return
            end
        end

        warn(
            "[" .. Library.Name .. "] Failed to set dropdown: " ..
            "Option does not exist: " .. tostring(Value)
        )
    end

    function DropdownObject:Get()
        return Selected
    end

    function DropdownObject:Destroy()
        pcall(function()
            Component:Destroy()
        end)
    end

    function DropdownObject:Refresh(NewOptions)
        -- Clear existing options
        for _, Child in ipairs(OptionsFrame:GetChildren()) do
            if Child:IsA("TextButton") then
                Child:Destroy()
            end
        end

        -- Add new options
        DropdownOptions = NewOptions or {}
        
        for Index, Value in ipairs(DropdownOptions) do
            CreateOption(Value, Index)
        end

        -- Update selected if options changed
        if #DropdownOptions > 0 then
            if not table.find(DropdownOptions, Selected) then
                Selected = DropdownOptions[1]
                DropdownButton.Text = tostring(Selected)
            end
        else
            Selected = nil
            DropdownButton.Text = "Select"
        end
    end

--==================================================
--// CONFIG REGISTRATION
--==================================================

    if Options.Identifier then
        RegisterConfigComponent(
            Options.Identifier,

            function()
                return DropdownObject:Get()
            end,

            function(NewValue)
                DropdownObject:Set(NewValue)
            end
        )
    end

    DropdownObject.Instance = Component
    DropdownObject.Button = DropdownButton
    DropdownObject.Options = OptionsFrame

    return DropdownObject
end

function Tab:CreateSlider(Options)
    Options = Options or {}

    local SliderName = Options.Name or "Slider"

    local Minimum = tonumber(Options.Min) or 0
    local Maximum = tonumber(Options.Max) or 100
    local Default = tonumber(Options.Default) or Minimum
    local Decimals = math.clamp(
        tonumber(Options.Decimals) or 0,
        0,
        6
    )

    local Increment = tonumber(Options.Increment)

    if not Increment or Increment <= 0 then
        Increment = 10 ^ -Decimals
    end

    local Suffix = Options.Suffix or ""
    local Callback = Options.Callback

    if Maximum <= Minimum then
        warn(
            "[" .. Library.Name .. "] Failed to create slider: " ..
            "Max must be greater than Min"
        )

        return nil
    end

    Default = math.clamp(Default, Minimum, Maximum)

    local Value = Default
    local Dragging = false

    --==================================================
    --// GET COMPONENT ROW
    --==================================================

    local Row = GetComponentRow()

    --==================================================
    --// COMPONENT
    --==================================================

    local Component = Create("Frame", {
        Name = SliderName,
        Parent = Row,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.5, -4, 0, 40),

        ZIndex = 5,
    })

    --==================================================
    --// LABEL
    --==================================================

    local Label = Create("TextLabel", {
        Name = "Label",
        Parent = Component,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -70, 0, 18),

        Font = Enum.Font.GothamMedium,
        Text = SliderName,
        TextColor3 = Theme.Text,
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 6,
    })

    --==================================================
    --// VALUE
    --==================================================

    local ValueLabel = Create("TextLabel", {
        Name = "Value",
        Parent = Component,

        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(65, 18),

        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 6,
    })

    --==================================================
    --// SLIDER BAR
    --==================================================

    local SliderBar = Create("TextButton", {
        Name = "Bar",
        Parent = Component,

        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.25,

        BorderSizePixel = 0,

        Position = UDim2.fromOffset(2, 23),
        Size = UDim2.new(1, -2, 0, 6),

        AutoButtonColor = false,

        Text = "",

        ZIndex = 6,
    })

    Create("UICorner", {
        Parent = SliderBar,
        CornerRadius = UDim.new(1, 0),
    })

    --==================================================
    --// FILL
    --==================================================

    local Fill = Create("Frame", {
        Name = "Fill",
        Parent = SliderBar,

        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0,

        BorderSizePixel = 0,

        Size = UDim2.new(0, 0, 1, 0),

        ZIndex = 7,
    })

    Create("UICorner", {
        Parent = Fill,
        CornerRadius = UDim.new(1, 0),
    })

    --==================================================
    --// KNOB
    --==================================================

    local Knob = Create("Frame", {
        Name = "Knob",
        Parent = SliderBar,

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),

        Size = UDim2.fromOffset(10, 10),

        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,

        ZIndex = 8,
    })

    Create("UICorner", {
        Parent = Knob,
        CornerRadius = UDim.new(1, 0),
    })

    --==================================================
    --// FORMAT VALUE
    --==================================================

    local function FormatValue(Number)
        local Text

        if Decimals > 0 then
            Text = string.format(
                "%." .. Decimals .. "f",
                Number
            )
        else
            Text = tostring(math.floor(Number + 0.5))
        end

        if Suffix ~= "" then
            Text = Text .. " " .. tostring(Suffix)
        end

        return Text
    end

    --==================================================
    --// UPDATE
    --==================================================

    local function UpdateSlider(NewValue, FireCallback)
        NewValue = math.clamp(
            tonumber(NewValue) or Minimum,
            Minimum,
            Maximum
        )

        NewValue = math.floor(
            ((NewValue - Minimum) / Increment) + 0.5
        ) * Increment + Minimum

        NewValue = math.clamp(
            NewValue,
            Minimum,
            Maximum
        )

        Value = NewValue

        local Alpha = (Value - Minimum) / (Maximum - Minimum)

        ValueLabel.Text = FormatValue(Value)

        Tween(Fill, {
            Size = UDim2.new(Alpha, 0, 1, 0),
        }, 0.08)

        Tween(Knob, {
            Position = UDim2.new(Alpha, 0, 0.5, 0),
        }, 0.08)

        if FireCallback and type(Callback) == "function" then
            local Success, Error = pcall(Callback, Value)

            if not Success then
                warn(
                    "[" .. Library.Name .. "] Slider callback failed: " ..
                    tostring(Error)
                )
            end
        end
    end

    --==================================================
    --// INPUT
    --==================================================

    local function UpdateFromInput(InputPosition)
        local AbsolutePosition = SliderBar.AbsolutePosition.X
        local AbsoluteSize = SliderBar.AbsoluteSize.X

        if AbsoluteSize <= 0 then
            return
        end

        local Alpha = math.clamp(
            (InputPosition - AbsolutePosition) / AbsoluteSize,
            0,
            1
        )

        local NewValue = Minimum +
            ((Maximum - Minimum) * Alpha)

        UpdateSlider(NewValue, true)
    end

    Connect(SliderBar.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true

            UpdateFromInput(Input.Position.X)
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if not Dragging then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        UpdateFromInput(Input.Position.X)
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    --==================================================
    --// HOVER
    --==================================================

    Connect(SliderBar.MouseEnter, function()
        Tween(SliderBar, {
            BackgroundTransparency = 0.15,
        }, 0.10)

        Tween(Knob, {
            Size = UDim2.fromOffset(12, 12),
        }, 0.10)
    end)

    Connect(SliderBar.MouseLeave, function()
        if not Dragging then
            Tween(SliderBar, {
                BackgroundTransparency = 0.25,
            }, 0.10)

            Tween(Knob, {
                Size = UDim2.fromOffset(10, 10),
            }, 0.10)
        end
    end)

    --==================================================
    --// SLIDER OBJECT
    --==================================================

    local SliderObject = {}

    function SliderObject:Set(NewValue)
        UpdateSlider(NewValue, true)
    end

    function SliderObject:Get()
        return Value
    end

    function SliderObject:SetCallback(NewCallback)
        if type(NewCallback) ~= "function" then
            warn(
                "[" .. Library.Name .. "] Failed to set slider callback: " ..
                "Expected function, got " .. tostring(NewCallback)
            )

            return
        end

        Callback = NewCallback
    end

    function SliderObject:Destroy()
        pcall(function()
            Component:Destroy()
        end)
    end

    --==================================================
    --// CONFIG REGISTRATION
    --==================================================

    if Options.Identifier then
        RegisterConfigComponent(
            Options.Identifier,

            function()
                return SliderObject:Get()
            end,

            function(NewValue)
                SliderObject:Set(NewValue)
            end
        )
    end

    SliderObject.Instance = Component
    SliderObject.Bar = SliderBar
    SliderObject.Fill = Fill
    SliderObject.Knob = Knob

    --==================================================
    --// INITIAL VALUE
    --==================================================

    UpdateSlider(Value, false)

    return SliderObject
end

function Tab:CreateInput(Options)
    Options = Options or {}

    local InputName = Options.Name or "Input"
    local Default = Options.Default
    local Callback = Options.Callback

    local CurrentInput = Default
    local Listening = false

    --==================================================
    --// GET COMPONENT ROW
    --==================================================

    local Row = GetComponentRow()

    --==================================================
    --// COMPONENT
    --==================================================

    local Component = Create("Frame", {
        Name = InputName,
        Parent = Row,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.5, -4, 0, 32),

        ZIndex = 5,
    })

    --==================================================
    --// LABEL
    --==================================================

    local Label = Create("TextLabel", {
        Name = "Label",
        Parent = Component,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -85, 1, 0),

        Font = Enum.Font.GothamMedium,
        Text = InputName,
        TextColor3 = Theme.Text,
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 6,
    })

    --==================================================
    --// INPUT BUTTON
    --==================================================

    local InputButton = Create("TextButton", {
        Name = "Input",
        Parent = Component,

        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.fromOffset(75, 27),

        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.25,

        BorderSizePixel = 0,

        AutoButtonColor = false,

        Font = Enum.Font.GothamMedium,
        Text = tostring(CurrentInput or "None"),
        TextColor3 = Theme.Text,
        TextSize = 10,

        ZIndex = 6,
    })

    Create("UICorner", {
        Parent = InputButton,
        CornerRadius = UDim.new(0, 5),
    })

    --==================================================
    --// FORMAT INPUT
    --==================================================

    local function FormatInput(Input)
        if typeof(Input) ~= "EnumItem" then
            return tostring(Input or "None")
        end

        return Input.Name
    end

    InputButton.Text = FormatInput(CurrentInput)

    --==================================================
    --// SET INPUT
    --==================================================

    local function SetInput(Input)
        CurrentInput = Input

        InputButton.Text = FormatInput(Input)

        if type(Callback) == "function" then
            local Success, Error = pcall(Callback, Input)

            if not Success then
                warn(
                    "[" .. Library.Name .. "] Input callback failed: " ..
                    tostring(Error)
                )
            end
        end
    end

    --==================================================
    --// HOVER
    --==================================================

    Connect(InputButton.MouseEnter, function()
        Tween(InputButton, {
            BackgroundTransparency = 0.10,
        }, 0.10)
    end)

    Connect(InputButton.MouseLeave, function()
        if not Listening then
            Tween(InputButton, {
                BackgroundTransparency = 0.25,
            }, 0.10)
        end
    end)

    --==================================================
    --// START LISTENING
    --==================================================

    Connect(InputButton.MouseButton1Click, function()
        if Listening then
            return
        end

        Listening = true
        UIInputListening = true

        InputButton.Text = "Press a key..."

        Tween(InputButton, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Theme.Accent,
        }, 0.12)
    end)

    --==================================================
    --// KEYBOARD INPUT
    --==================================================

    Connect(UserInputService.InputBegan, function(Input, GameProcessed)
        if not Listening then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        Listening = false

        SetInput(Input.KeyCode)

        InputButton.Text = FormatInput(Input.KeyCode)

        Tween(InputButton, {
            BackgroundTransparency = 0.25,
            BackgroundColor3 = Theme.Border,
        }, 0.12)

        task.defer(function()
            UIInputListening = false
        end)
    end)

    --==================================================
    --// INPUT OBJECT
    --==================================================

    local InputObject = {}

    function InputObject:Set(Input)
        if typeof(Input) ~= "EnumItem" or Input.EnumType ~= Enum.KeyCode then
            warn(
                "[" .. Library.Name .. "] Failed to set input: " ..
                "Expected Enum.KeyCode, got " .. tostring(Input)
            )

            return
        end

        SetInput(Input)
    end

    function InputObject:Get()
        return CurrentInput
    end

    function InputObject:Capture()
        if Listening then
            return
        end
        UIInputListening = true
        Listening = true
        InputButton.Text = "Press a key..."

        Tween(InputButton, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Theme.Accent,
        }, 0.12)
    end

    function InputObject:Destroy()
        pcall(function()
            Component:Destroy()
        end)
    end


    --==================================================
    --// CONFIG REGISTRATION
    --==================================================

    if Options.Identifier then
        RegisterConfigComponent(
            Options.Identifier,

            function()
                return InputObject:Get()
            end,

            function(NewValue)
                InputObject:Set(NewValue)
            end
        )
    end

    InputObject.Instance = Component
    InputObject.Button = InputButton

    return InputObject
end

function Tab:CreateLabel(Options)
    Options = Options or {}

    local LabelText = tostring(Options.Text or "Label")

    --==================================================
    --// GET COMPONENT ROW
    --==================================================

    local Row = GetComponentRow()

    --==================================================
    --// COMPONENT
    --==================================================

    local Component = Create("Frame", {
        Name = "Label",

        Parent = Row,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.5, -4, 0, 30),

        ZIndex = 5,
    })

    --==================================================
    --// LABEL
    --==================================================

    local Label = Create("TextLabel", {
        Name = "Text",

        Parent = Component,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        Font = Enum.Font.GothamMedium,
        Text = LabelText,
        TextColor3 = Theme.SubText,
        TextSize = 11,

        TextWrapped = true,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 6,
    })

    --==================================================
    --// LABEL OBJECT
    --==================================================

    local LabelObject = {}

    function LabelObject:SetText(Text)
        pcall(function()
            Label.Text = tostring(Text)
        end)
    end

    function LabelObject:GetText()
        return Label.Text
    end

    function LabelObject:Destroy()
        pcall(function()
            Component:Destroy()
        end)
    end

    LabelObject.Instance = Component
    LabelObject.Label = Label

    return LabelObject
end

function Tab:CreateDivider()
    --==================================================
    --// DIVIDER
    --==================================================

    local Divider = Create("Frame", {
        Name = "Divider",
        Parent = TabContent,

        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.25,

        BorderSizePixel = 0,

        Size = UDim2.new(1, 0, 0, 1),

        ZIndex = 5,
    })

    --==================================================
    --// DIVIDER OBJECT
    --==================================================

    local DividerObject = {}

    function DividerObject:Destroy()
        pcall(function()
            Divider:Destroy()
        end)
    end

    DividerObject.Instance = Divider

    return DividerObject
end

--==================================================
--// NOTIFICATION
--==================================================

function Library:Notify(Options)
    Options = Options or {}

    local Title = tostring(Options.Title or "Notification")
    local Content = tostring(Options.Content or "")
    local Duration = tonumber(Options.Duration) or 5

    local Position = Options.Position or "TopRight"

    local Icon = Options.Icon
    local Sound = Options.Sound

    Duration = math.max(Duration, 0.1)

    if not NotificationContainers[Position] then
        warn(
            "[" .. Library.Name .. "] Failed to create notification: " ..
            "Invalid position " .. tostring(Position)
        )

        Position = "TopRight"
    end

    local Container = NotificationContainers[Position]

    local PositionInfo = NotificationPositions[Position]

    local FromLeft =
        Position == "TopLeft" or
        Position == "BottomLeft"

    --==================================================
    --// NOTIFICATION
    --==================================================

    local Notification = Create("Frame", {
        Name = "Notification",
        Parent = Container,

        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.05,

        BorderSizePixel = 0,

        Size = UDim2.fromOffset(320, 72),

        LayoutOrder = os.clock() * 1000,

        ZIndex = 101,
    })

    Create("UICorner", {
        Parent = Notification,

        CornerRadius = UDim.new(0, 7),
    })

    Create("UIStroke", {
        Parent = Notification,

        Color = Theme.Border,
        Transparency = 0.35,

        Thickness = 1,
    })

    --==================================================
    --// ICON
    --==================================================

    local IconLabel

    if Icon then
        IconLabel = Create("ImageLabel", {
            Name = "Icon",
            Parent = Notification,

            BackgroundTransparency = 1,

            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 14, 0.5, 0),

            Size = UDim2.fromOffset(25, 25),

            Image = tostring(Icon),
            ImageColor3 = Theme.Text,

            ZIndex = 103,
        })
    end

    --==================================================
    --// CONTENT FRAME
    --==================================================

    local ContentFrame = Create("Frame", {
        Name = "Content",
        Parent = Notification,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            Icon and 48 or 14,
            9
        ),

        Size = UDim2.new(
            1,
            Icon and -92 or -58,
            1,
            -18
        ),

        ZIndex = 102,
    })

    --==================================================
    --// TITLE
    --==================================================

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = ContentFrame,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 0, 20),

        Font = Enum.Font.GothamMedium,

        Text = Title,
        TextColor3 = Theme.Text,
        TextSize = 12,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        ZIndex = 103,
    })

    --==================================================
    --// CONTENT
    --==================================================

    local ContentLabel = Create("TextLabel", {
        Name = "Content",
        Parent = ContentFrame,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(0, 20),

        Size = UDim2.new(1, 0, 1, -20),

        Font = Enum.Font.Gotham,

        Text = Content,
        TextColor3 = Theme.SubText,
        TextSize = 10,

        TextWrapped = true,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,

        ZIndex = 103,
    })

    --==================================================
    --// CLOSE BUTTON
    --==================================================

    local CloseButton = Create("TextButton", {
        Name = "Close",
        Parent = Notification,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -7, 0, 7),

        Size = UDim2.fromOffset(24, 24),

        AutoButtonColor = false,

        Font = Enum.Font.GothamMedium,
        Text = "×",

        TextColor3 = Theme.SubText,
        TextSize = 15,

        ZIndex = 104,
    })

    Create("UICorner", {
        Parent = CloseButton,
        CornerRadius = UDim.new(0, 5),
    })

    Connect(CloseButton.MouseEnter, function()
        Tween(CloseButton, {
            TextColor3 = Theme.Text,
        }, 0.10)
    end)

    Connect(CloseButton.MouseLeave, function()
        Tween(CloseButton, {
            TextColor3 = Theme.SubText,
        }, 0.10)
    end)

    --==================================================
    --// DURATION BAR
    --==================================================

    local DurationBar = Create("Frame", {
        Name = "DurationBar",
        Parent = Notification,

        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),

        Size = UDim2.new(1, 0, 0, 2),

        BackgroundColor3 = Theme.Text,
        BackgroundTransparency = 0.15,

        BorderSizePixel = 0,

        ZIndex = 104,
    })

    Create("UICorner", {
        Parent = DurationBar,

        CornerRadius = UDim.new(1, 0),
    })

    --==================================================
    --// SOUND
    --==================================================

    if Sound then
        local SoundObject = Create("Sound", {
            Name = "NotificationSound",
            Parent = Notification,

            SoundId = tostring(Sound),

            Volume = 0.5,
        })

        pcall(function()
            SoundObject:Play()
        end)
    end

    --==================================================
    --// ANIMATION
    --==================================================

    local StartPosition

    if FromLeft then
        StartPosition = UDim2.new(
            0,
            -340,
            0,
            0
        )
    else
        StartPosition = UDim2.new(
            0,
            340,
            0,
            0
        )
    end

    Notification.Position = StartPosition

    Tween(
        Notification,
        {
            Position = UDim2.new(0, 0, 0, 0),
        },
        0.35,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    --==================================================
    --// DESTROY
    --==================================================

    local Destroyed = false

    local function DestroyNotification()
        if Destroyed then
            return
        end

        Destroyed = true

        local ExitPosition

        if FromLeft then
            ExitPosition = UDim2.new(
                0,
                -340,
                0,
                0
            )
        else
            ExitPosition = UDim2.new(
                0,
                340,
                0,
                0
            )
        end

        local ExitTween = Tween(
            Notification,
            {
                Position = ExitPosition,
            },
            0.25,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.In
        )

        ExitTween.Completed:Connect(function()
            pcall(function()
                Notification:Destroy()
            end)
        end)
    end

    --==================================================
    --// CLOSE BUTTON INPUT
    --==================================================

    Connect(CloseButton.MouseButton1Click, function()
        DestroyNotification()
    end)

    --==================================================
    --// DURATION
    --==================================================

    Tween(
        DurationBar,
        {
            Size = UDim2.new(0, 0, 0, 2),
        },
        Duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    task.delay(Duration, function()
        DestroyNotification()
    end)

    --==================================================
    --// NOTIFICATION OBJECT
    --==================================================

    local NotificationObject = {}

    function NotificationObject:Close()
        DestroyNotification()
    end

    function NotificationObject:Destroy()
        DestroyNotification()
    end

    function NotificationObject:SetTitle(NewTitle)
        pcall(function()
            TitleLabel.Text = tostring(NewTitle)
        end)
    end

    function NotificationObject:SetContent(NewContent)
        pcall(function()
            ContentLabel.Text = tostring(NewContent)
        end)
    end

    NotificationObject.Instance = Notification
    NotificationObject.Title = TitleLabel
    NotificationObject.Content = ContentLabel
    NotificationObject.DurationBar = DurationBar

    if IconLabel then
        NotificationObject.Icon = IconLabel
    end

    return NotificationObject
end

    --====================================================
    --// TAB SELECTION // AKA THE END, PUT FEATURES ABOVE
    --====================================================

    function Tab:Select()
        if SelectedTab == self then
            return
        end

        -- Deselect previous tab
        if SelectedTab then
            SelectedTab.Content.Visible = false

            Tween(SelectedTab.Button, {
                BackgroundTransparency = 1,
                TextColor3 = Theme.SubText,
            }, 0.15)
        end

        SelectedTab = self

        -- Select this tab
        self.Content.Visible = true

        Tween(self.Button, {
            BackgroundTransparency = 0.85,
            TextColor3 = Theme.Text,
        }, 0.15)
    end

    --==================================================
    --// TAB BUTTON INPUT
    --==================================================

    Connect(TabButton.MouseButton1Click, function()
        Tab:Select()
    end)

    --==================================================
    --// TAB DESTROY
    --==================================================

    function Tab:Destroy()
        if SelectedTab == self then
            SelectedTab = nil
        end

        Tabs[self.Index] = nil

        pcall(function()
            TabContent:Destroy()
        end)

        pcall(function()
            TabButton:Destroy()
        end)
    end

    -- Store references
    Tab.Button = TabButton
    Tab.Content = TabContent
    Tab.Layout = TabLayout

    Tabs[TabIndex] = Tab

    -- First tab automatically selected
    if not SelectedTab then
        Tab:Select()
    end

    return Tab
end

    --==================================================
    --// CREATE SETTINGS
    --==================================================

    local UISettings = WindowObject:CreateTab({
        Name = "UI",
        IsSettings = true,
    })

    UISettings:CreateToggle({
        Name = "Confirm Close",
        Identifier = "confirm_close",
        Default = true,

        Callback = function(Value)
            WindowObject:SetConfirmClose(Value)
        end,
    })

    UISettings:CreateLabel({
        Text = "Prompts a confirmation screen when you try to exit the menu."
    })

    local UIKeybind = UISettings:CreateInput({
        Name = "UI Keybind",
        Identifier = "ui_keybind",
        Default = UIKeybind,

        Callback = function(Key)
            WindowObject:SetKeybind(Key)
        end,
    })

    UISettings:CreateLabel({
        Text = "Keybind to quickly open the menu. [Default = P]"
    })

    Library:Notify({
        Title = "love from kameel",
        Content = "baby...",
        Duration = 3,
        Position = "TopRight",
    })

    --==================================================
    --// LOADING
    --==================================================

    task.spawn(function()

        local StartTime = os.clock()

        --// Stage 1
        Tween(LoadingTitle, {
            TextTransparency = 0
        }, 0.3)

        Tween(LoadingStatus, {
            TextTransparency = 0
        }, 0.3)

        Tween(Progress, {
            Size = UDim2.fromScale(0.20, 1)
        }, 0.25)

        task.wait()

        --// Stage 2
        LoadingStatus.Text = "Preparing interface..."

        Tween(Progress, {
            Size = UDim2.fromScale(0.45, 1)
        }, 0.25)

        task.wait()

        --// Stage 3
        LoadingStatus.Text = "Building interface..."

        Tween(Progress, {
            Size = UDim2.fromScale(0.70, 1)
        }, 0.25)

        task.wait()

        --// Stage 4
        LoadingStatus.Text = "Finishing..."

        Tween(Progress, {
            Size = UDim2.fromScale(0.90, 1)
        }, 0.20)

        task.wait()

        --// Minimum loading time
        local MinimumLoadTime = 0.75
        local Elapsed = os.clock() - StartTime

        if Elapsed < MinimumLoadTime then
            task.wait(MinimumLoadTime - Elapsed)
        end

        --// Complete
        LoadingStatus.Text = "Ready"

        Tween(Progress, {
            Size = UDim2.fromScale(1, 1)
        }, 0.18).Completed:Wait()

        task.wait(0.12)

        --==================================================
        --// MORPH INTO FULL WINDOW
        --==================================================

        local SizeTween = Tween(Window, {
            Size = WindowSize
        }, 0.45)

        task.wait(0.12)

        -- Fade loading elements
        Tween(LoadingTitle, {
            TextTransparency = 1
        }, 0.20)

        Tween(LoadingStatus, {
            TextTransparency = 1
        }, 0.20)

        Tween(ProgressBackground, {
            BackgroundTransparency = 1
        }, 0.20)

        Tween(Progress, {
            BackgroundTransparency = 1
        }, 0.20)

        SizeTween.Completed:Wait()

        -- Remove loading layer
        Loading:Destroy()

        --==================================================
        --// REVEAL UI
        --==================================================

        Content.Visible = true

        UILoaded = true

        Tween(Title, {
            TextTransparency = 0
        }, 0.3)

        Tween(Version, {
            TextTransparency = 0
        }, 0.3)

    end)

    --==================================================
    --// CONFIG SERIALIZATION
    --==================================================

    local function SerializeValue(Value)
        local ValueType = typeof(Value)

        if ValueType == "EnumItem" then
            return {
                __Type = "EnumItem",
                EnumType = tostring(Value.EnumType),
                Value = Value.Name,
            }
        end

        if ValueType == "Color3" then
            return {
                __Type = "Color3",
                R = Value.R,
                G = Value.G,
                B = Value.B,
            }
        end

        if ValueType == "Vector2" then
            return {
                __Type = "Vector2",
                X = Value.X,
                Y = Value.Y,
            }
        end

        if ValueType == "Vector3" then
            return {
                __Type = "Vector3",
                X = Value.X,
                Y = Value.Y,
                Z = Value.Z,
            }
        end

        if ValueType == "UDim" then
            return {
                __Type = "UDim",
                Scale = Value.Scale,
                Offset = Value.Offset,
            }
        end

        if ValueType == "UDim2" then
            return {
                __Type = "UDim2",

                XScale = Value.X.Scale,
                XOffset = Value.X.Offset,

                YScale = Value.Y.Scale,
                YOffset = Value.Y.Offset,
            }
        end

        if ValueType == "CFrame" then
            local Components = {Value:GetComponents()}

            return {
                __Type = "CFrame",
                Components = Components,
            }
        end

        if type(Value) == "table" then
            local Result = {}

            for Key, Item in pairs(Value) do
                Result[Key] = SerializeValue(Item)
            end

            return Result
        end

        return Value
    end

--==================================================
--// CONFIG DESERIALIZATION
--==================================================

    local function DeserializeValue(Value)
        if type(Value) ~= "table" then
            return Value
        end

        if Value.__Type == "EnumItem" then
            local EnumType = Enum[Value.EnumType]

            if not EnumType then
                warn(
                    "[" .. Library.Name .. "] Failed to deserialize enum: " ..
                    tostring(Value.EnumType)
                )

                return nil
            end

            local EnumValue = EnumType[Value.Value]

            if not EnumValue then
                warn(
                    "[" .. Library.Name .. "] Failed to deserialize enum value: " ..
                    tostring(Value.Value)
                )

                return nil
            end

            return EnumValue
        end

        if Value.__Type == "Color3" then
            return Color3.new(
                Value.R,
                Value.G,
                Value.B
            )
        end

        if Value.__Type == "Vector2" then
            return Vector2.new(
                Value.X,
                Value.Y
            )
        end

        if Value.__Type == "Vector3" then
            return Vector3.new(
                Value.X,
                Value.Y,
                Value.Z
            )
        end

        if Value.__Type == "UDim" then
            return UDim.new(
                Value.Scale,
                Value.Offset
            )
        end

        if Value.__Type == "UDim2" then
            return UDim2.new(
                Value.XScale,
                Value.XOffset,
                Value.YScale,
                Value.YOffset
            )
        end

        if Value.__Type == "CFrame" then
            return CFrame.new(
                table.unpack(Value.Components)
            )
        end

        local Result = {}

        for Key, Item in pairs(Value) do
            Result[Key] = DeserializeValue(Item)
        end

        return Result
    end

--==================================================
--// CONFIG DATA
--==================================================

    local function GetConfigData()
        local Data = {}

        for Identifier, Component in pairs(ConfigComponents) do
            local Success, Value = pcall(Component.Get)

            if Success then
                Data[Identifier] = SerializeValue(Value)
            else
                warn(
                    "[" .. Library.Name .. "] Failed to get config value: " ..
                    tostring(Identifier) .. " | " .. tostring(Value)
                )
            end
        end

        return Data
    end

    local Data = GetConfigData()

    for Identifier, Value in pairs(Data) do
        print(
            "[" .. Library.Name .. "] Saved value:",
            Identifier,
            Value
        )
    end

--==================================================
--// CONFIG ENCODE
--==================================================

    local function EncodeConfig()
        local Data = GetConfigData()

        local Success, Result = pcall(function()
            return HttpService:JSONEncode(Data)
        end)

        if not Success then
            warn(
                "[" .. Library.Name .. "] Failed to encode config: " ..
                tostring(Result)
            )

            return nil
        end

        return Result
    end

    local JSON = EncodeConfig()

--==================================================
--// CONFIG FILE SYSTEM
--==================================================

    local ConfigFolder = Library.Name .. "/Configs"

    local function EnsureConfigFolder()
        if not isfolder(Library.Name) then
            makefolder(Library.Name)
        end

        if not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end

    local function SaveConfig(self, Name)
        if type(Name) ~= "string" or Name == "" then
            warn(
                "[" .. Library.Name .. "] Failed to save config: " ..
                "Invalid config name"
            )

            return false
        end

        EnsureConfigFolder()

        local Data = GetConfigData()

        print("========== SAVE DEBUG ==========")

        for Identifier, Value in pairs(Data) do
            print(
                "[" .. Library.Name .. "]",
                Identifier,
                Value
            )
        end

        local Success, JSON = pcall(function()
            return HttpService:JSONEncode(Data)
        end)

        if not Success then
            warn(
                "[" .. Library.Name .. "] JSON encode failed: " ..
                tostring(JSON)
            )

            return false
        end

        print("JSON BEING SAVED:")
        print(JSON)

        local FilePath = ConfigFolder .. "/" .. Name .. ".json"

        local WriteSuccess, WriteError = pcall(function()
            writefile(FilePath, JSON)
        end)

        if not WriteSuccess then
            warn(
                "[" .. Library.Name .. "] Failed to write config: " ..
                tostring(WriteError)
            )

            return false
        end

        print(
            "[" .. Library.Name .. "] Config saved:",
            FilePath
        )

        return true
    end


    local function LoadConfig(self, Name)
        if type(Name) ~= "string" or Name == "" then
            warn(
                "[" .. Library.Name .. "] Failed to load config: " ..
                "Invalid config name"
            )

            return false
        end

        local FilePath = ConfigFolder .. "/" .. Name .. ".json"

        print("========== LOAD DEBUG ==========")
        print("Loading:", FilePath)

        if not isfile(FilePath) then
            warn(
                "[" .. Library.Name .. "] Config does not exist: " ..
                FilePath
            )

            return false
        end

        local ReadSuccess, JSON = pcall(function()
            return readfile(FilePath)
        end)

        if not ReadSuccess then
            warn(
                "[" .. Library.Name .. "] Failed to read config: " ..
                tostring(JSON)
            )

            return false
        end

        print("RAW JSON:")
        print(JSON)

        local DecodeSuccess, Data = pcall(function()
            return HttpService:JSONDecode(JSON)
        end)

        if not DecodeSuccess then
            warn(
                "[" .. Library.Name .. "] Failed to decode config: " ..
                tostring(Data)
            )

            return false
        end

        print("JSON DECODED SUCCESSFULLY")

        for Identifier, Value in pairs(Data) do
            print(
                "Loading component:",
                Identifier,
                "Raw value:",
                Value
            )

            local Component = ConfigComponents[Identifier]

            if not Component then
                warn(
                    "[" .. Library.Name .. "] Config component not found: " ..
                    tostring(Identifier)
                )

                continue
            end

            local DeserializedValue = DeserializeValue(Value)

            print(
                "Deserialized:",
                Identifier,
                DeserializedValue
            )

            if DeserializedValue == nil then
                warn(
                    "[" .. Library.Name .. "] Deserialization returned nil: " ..
                    tostring(Identifier)
                )

                continue
            end

            local SetSuccess, SetError = pcall(
                Component.Set,
                DeserializedValue
            )

            if not SetSuccess then
                warn(
                    "[" .. Library.Name .. "] Failed to set component: " ..
                    tostring(Identifier) .. " | " ..
                    tostring(SetError)
                )
            else
                print(
                    "Successfully applied:",
                    Identifier
                )
            end
        end

        print("========== LOAD COMPLETE ==========")

        return true
    end

    WindowObject.SaveConfig = SaveConfig
    WindowObject.LoadConfig = LoadConfig

    return WindowObject
end

print("["..Library.Name.."]" .. " Loaded.")

return Library
--test