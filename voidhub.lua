print("========================================")
print("🌌 VOID HUB KEY SYSTEM")
print("========================================")

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ========================================
-- DEVICE DETECTION
-- ========================================

local function IsMobile()
    return Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled
end

local function GetScaleFactor()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local minDimension = math.min(viewportSize.X, viewportSize.Y)
    
    if IsMobile() then
        if minDimension < 400 then return 0.7
        elseif minDimension < 600 then return 0.85
        else return 0.95 end
    end
    return 1
end

local isMobile = IsMobile()

-- ========================================
-- CONFIGURATION
-- ========================================


local scaleFactor = GetScaleFactor()

local Config = {
    MaxKeyLength = 50,
    AnimationSpeed = 0.5,
    ParticleCount = IsMobile() and 40 or 80,
    ParticleSpeed = IsMobile() and 40 or 70,
    ContainerWidth = math.floor(440 * scaleFactor),
    ContainerHeight = math.floor(580 * scaleFactor),
    IsMobile = IsMobile()
}

-- ========================================
-- MODERN COLOR SCHEME (Glassmorphism)
-- ========================================

local Colors = {
    -- Base colors with transparency for glass effect
    Background = Color3.fromRGB(10, 10, 15),
    GlassBackground = Color3.fromRGB(20, 20, 28),
    GlassStroke = Color3.fromRGB(60, 60, 80),
    
    -- Accent colors (Purple/Blue gradient)
    Primary = Color3.fromRGB(120, 100, 255),
    PrimaryDark = Color3.fromRGB(80, 60, 200),
    PrimaryLight = Color3.fromRGB(160, 140, 255),
    
    Secondary = Color3.fromRGB(80, 200, 255),
    SecondaryDark = Color3.fromRGB(50, 150, 220),
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextTertiary = Color3.fromRGB(120, 120, 140),
    
    -- Status colors
    Success = Color3.fromRGB(100, 220, 150),
    Error = Color3.fromRGB(255, 100, 120),
    Warning = Color3.fromRGB(255, 180, 80),
    
    -- Button colors
    ButtonPrimary = Color3.fromRGB(120, 100, 255),
    ButtonSecondary = Color3.fromRGB(88, 101, 242),
    ButtonHover = Color3.fromRGB(140, 120, 255),
    
    -- Special effects
    GlowPrimary = Color3.fromRGB(120, 100, 255),
    GlowSecondary = Color3.fromRGB(80, 200, 255),
}

-- ========================================
-- STATE MANAGEMENT
-- ========================================

local State = {
    IsLoading = false,
    Particles = {},
    Animations = {},
    IsDestroyed = false,
    MousePosition = {X = 0, Y = 0},
    TouchPosition = {X = 0, Y = 0},
    FocusStates = {
        InputFocused = false,
        ButtonHovered = {},
        AnimationsActive = true
    }
}

local UI = {}

-- ========================================
-- UI CREATION FUNCTIONS
-- ========================================

local function CreateMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VoidHubKeySystem"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 100
    screenGui.Parent = PlayerGui
    
    UI.ScreenGui = screenGui
    return screenGui
end

local function CreateBackdrop(parent)
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.3
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 100
    backdrop.Parent = parent
    
    -- Blur effect simulation with darker gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 5, 10)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    gradient.Rotation = 45
    gradient.Parent = backdrop
    
    UI.Backdrop = backdrop
    return backdrop
end

local function CreateContainer(parent)
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0, Config.ContainerWidth, 0, Config.ContainerHeight)
    container.Position = UDim2.new(0.5, -Config.ContainerWidth/2, 0.5, -Config.ContainerHeight/2)
    container.BackgroundColor3 = Colors.GlassBackground
    container.BackgroundTransparency = 0.2  -- Glass effect
    container.BorderSizePixel = 0
    container.ZIndex = 110
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, math.floor(24 * scaleFactor))
    corner.Parent = container
    
    -- Modern glass stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.GlassStroke
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container
    
    -- Inner glow effect
    local innerGlow = Instance.new("Frame")
    innerGlow.Size = UDim2.new(1, -4, 1, -4)
    innerGlow.Position = UDim2.new(0, 2, 0, 2)
    innerGlow.BackgroundTransparency = 1
    innerGlow.ZIndex = container.ZIndex + 1
    innerGlow.Parent = container
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, math.floor(22 * scaleFactor))
    innerCorner.Parent = innerGlow
    
    local innerStroke = Instance.new("UIStroke")
    innerStroke.Color = Color3.fromRGB(255, 255, 255)
    innerStroke.Thickness = 1
    innerStroke.Transparency = 0.9
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerStroke.Parent = innerGlow
    
    if Config.IsMobile then
        local constraint = Instance.new("UISizeConstraint")
        constraint.MaxSize = Vector2.new(500, 700)
        constraint.MinSize = Vector2.new(280, 400)
        constraint.Parent = container
    end
    
    UI.Container = container
    return container
end

local function CreateAnimatedBorder(parent)
    local border = Instance.new("Frame")
    border.Name = "AnimatedBorder"
    border.Size = UDim2.new(1, 6, 1, 6)
    border.Position = UDim2.new(0, -3, 0, -3)
    border.BackgroundTransparency = 1
    border.ZIndex = 109
    border.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, math.floor(27 * scaleFactor))
    corner.Parent = border
    
    local stroke = Instance.new("UIStroke")  
    stroke.Color = Colors.Primary
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = border
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Colors.Primary)
    }
    gradient.Parent = stroke
    
    UI.AnimatedBorder = {Frame = border, Gradient = gradient, Stroke = stroke}
    return border
end

-- ========================================
-- HEADER SECTION (Modern Avatar Display)
-- ========================================

local function CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, math.floor(110 * scaleFactor))
    header.BackgroundTransparency = 1
    header.ZIndex = 11
    header.Parent = parent
    
    local avatarSize = math.floor(72 * scaleFactor)
    
    -- Avatar container with modern shadow
    local avatarContainer = Instance.new("Frame")
    avatarContainer.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatarContainer.Position = UDim2.new(0.5, -avatarSize/2, 0, math.floor(20 * scaleFactor))
    avatarContainer.BackgroundColor3 = Colors.GlassBackground
    avatarContainer.BackgroundTransparency = 0.3
    avatarContainer.BorderSizePixel = 0
    avatarContainer.ZIndex = 12
    avatarContainer.Parent = header
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatarContainer
    
    -- Modern gradient stroke
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Thickness = 2.5
    avatarStroke.Transparency = 0.4
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatarContainer
    
    local strokeGradient = Instance.new("UIGradient")
    strokeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Colors.Primary)
    }
    strokeGradient.Parent = avatarStroke
    
    -- Animated glow ring
    local glowRing = Instance.new("Frame")
    glowRing.Size = UDim2.new(1, 16, 1, 16)
    glowRing.Position = UDim2.new(0, -8, 0, -8)
    glowRing.BackgroundTransparency = 1
    glowRing.ZIndex = 11
    glowRing.Parent = avatarContainer
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glowRing
    
    local glowStroke = Instance.new("UIStroke")
    glowStroke.Thickness = 3
    glowStroke.Transparency = 0.6
    glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glowStroke.Parent = glowRing
    
    local glowGradient = Instance.new("UIGradient")
    glowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Colors.Primary)
    }
    glowGradient.Parent = glowStroke
    
    -- Player avatar
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
    avatarImage.ScaleType = Enum.ScaleType.Fit
    avatarImage.ZIndex = 13
    avatarImage.Parent = avatarContainer
    
    local avatarImgCorner = Instance.new("UICorner")
    avatarImgCorner.CornerRadius = UDim.new(1, 0)
    avatarImgCorner.Parent = avatarImage
    
    UI.Header = {
        Container = header, 
        AvatarGlow = glowGradient, 
        AvatarStroke = strokeGradient,
        GlowStroke = glowStroke
    }
    return header
end

-- ========================================
-- CONTENT SECTION
-- ========================================

local function CreateContent(parent)
    local headerHeight = math.floor(110 * scaleFactor)
    local contentHeight = Config.ContainerHeight - headerHeight - math.floor(30 * scaleFactor)
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, math.floor(-60 * scaleFactor), 0, contentHeight)
    content.Position = UDim2.new(0, math.floor(30 * scaleFactor), 0, headerHeight)
    content.BackgroundTransparency = 1
    content.ZIndex = 11
    content.Parent = parent
    
    -- Modern title with gradient
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, math.floor(32 * scaleFactor))
    title.BackgroundTransparency = 1
    title.Text = "Access Key Required"
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = math.floor(24 * scaleFactor)
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextScaled = Config.IsMobile
    title.ZIndex = 12
    title.Parent = content
    
    -- Subtle subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, math.floor(20 * scaleFactor))
    subtitle.Position = UDim2.new(0, 0, 0, math.floor(36 * scaleFactor))
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enter your key to unlock full access"
    subtitle.TextColor3 = Colors.TextSecondary
    subtitle.TextSize = math.floor(13 * scaleFactor)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.TextWrapped = true
    subtitle.TextScaled = Config.IsMobile
    subtitle.ZIndex = 12
    subtitle.Parent = content
    
    UI.Content = content
    return content
end

-- ========================================
-- INPUT SECTION (Modern Glass Design)
-- ========================================

local function CreateInputSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, math.floor(70 * scaleFactor))
    section.Position = UDim2.new(0, 0, 0, math.floor(70 * scaleFactor))
    section.BackgroundTransparency = 1
    section.ZIndex = 12
    section.Parent = parent
    
    local inputHeight = math.floor(52 * scaleFactor)
    
    -- Glass input container
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, inputHeight)
    inputContainer.BackgroundColor3 = Colors.GlassBackground
    inputContainer.BackgroundTransparency = 0.4
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 13
    inputContainer.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, math.floor(14 * scaleFactor))
    corner.Parent = inputContainer
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.GlassStroke
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = inputContainer
    
    -- Animated focus glow
    local inputGlow = Instance.new("Frame")
    inputGlow.Size = UDim2.new(1, 8, 1, 8)
    inputGlow.Position = UDim2.new(0, -4, 0, -4)
    inputGlow.BackgroundTransparency = 1
    inputGlow.ZIndex = inputContainer.ZIndex - 1
    inputGlow.Visible = false
    inputGlow.Parent = inputContainer
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, math.floor(18 * scaleFactor))
    glowCorner.Parent = inputGlow
    
    local glowStroke = Instance.new("UIStroke")
    glowStroke.Thickness = 2.5
    glowStroke.Transparency = 0.3
    glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glowStroke.Parent = inputGlow
    
    local glowGradient = Instance.new("UIGradient")
    glowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Colors.Primary)
    }
    glowGradient.Parent = glowStroke
    
    -- Text input
    local textInput = Instance.new("TextBox")
    textInput.Size = UDim2.new(1, math.floor(-32 * scaleFactor), 1, 0)
    textInput.Position = UDim2.new(0, math.floor(16 * scaleFactor), 0, 0)
    textInput.BackgroundTransparency = 1
    textInput.Text = ""
    textInput.PlaceholderText = "Enter your access key..."
    textInput.TextColor3 = Colors.TextPrimary
    textInput.PlaceholderColor3 = Colors.TextTertiary
    textInput.TextSize = math.floor(15 * scaleFactor)
    textInput.Font = Enum.Font.GothamMedium
    textInput.TextXAlignment = Enum.TextXAlignment.Left
    textInput.ClearTextOnFocus = false
    textInput.TextScaled = Config.IsMobile
    textInput.ZIndex = 14
    textInput.Parent = inputContainer
    
    -- Character counter
    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(0, math.floor(60 * scaleFactor), 0, math.floor(16 * scaleFactor))
    charCounter.Position = UDim2.new(1, math.floor(-64 * scaleFactor), 0, inputHeight + math.floor(6 * scaleFactor))
    charCounter.BackgroundTransparency = 1
    charCounter.Text = "0/" .. Config.MaxKeyLength
    charCounter.TextColor3 = Colors.TextTertiary
    charCounter.TextSize = math.floor(11 * scaleFactor)
    charCounter.Font = Enum.Font.Gotham
    charCounter.TextXAlignment = Enum.TextXAlignment.Right
    charCounter.TextScaled = Config.IsMobile
    charCounter.ZIndex = 13
    charCounter.Parent = section
    
    UI.Input = {
        Container = inputContainer,
        TextBox = textInput,
        Counter = charCounter,
        Stroke = stroke,
        Glow = {Frame = inputGlow, Stroke = glowStroke, Gradient = glowGradient}
    }
    
    return section
end

-- ========================================
-- BUTTON SECTION (Modern Design)
-- ========================================

local function CreateButtons(parent)
    local buttonHeight = math.floor(48 * scaleFactor)
    local buttonSpacing = math.floor(10 * scaleFactor)
    
    -- Primary submit button
    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(1, 0, 0, buttonHeight)
    submitButton.Position = UDim2.new(0, 0, 0, math.floor(150 * scaleFactor))
    submitButton.BackgroundColor3 = Colors.ButtonPrimary
    submitButton.BackgroundTransparency = 0.1
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Verify Key"
    submitButton.TextColor3 = Colors.TextPrimary
    submitButton.TextSize = math.floor(15 * scaleFactor)
    submitButton.Font = Enum.Font.GothamBold
    submitButton.AutoButtonColor = false
    submitButton.TextScaled = Config.IsMobile
    submitButton.ZIndex = 13
    submitButton.Parent = parent
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, math.floor(12 * scaleFactor))
    submitCorner.Parent = submitButton
    
    local submitStroke = Instance.new("UIStroke")
    submitStroke.Color = Colors.Primary
    submitStroke.Thickness = 1.5
    submitStroke.Transparency = 0.5
    submitStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    submitStroke.Parent = submitButton
    
    -- Button gradient
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(1, Colors.PrimaryDark)
    }
    buttonGradient.Rotation = 45
    buttonGradient.Parent = submitButton
    
    -- Loading spinner
    local loadingContainer = Instance.new("Frame")
    loadingContainer.Size = UDim2.new(0, math.floor(24 * scaleFactor), 0, math.floor(24 * scaleFactor))
    loadingContainer.Position = UDim2.new(0.5, math.floor(-12 * scaleFactor), 0.5, math.floor(-12 * scaleFactor))
    loadingContainer.BackgroundTransparency = 1
    loadingContainer.Visible = false
    loadingContainer.ZIndex = 14
    loadingContainer.Parent = submitButton
    
    local spinner = Instance.new("ImageLabel")
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://4965945816"
    spinner.ImageColor3 = Colors.TextPrimary
    spinner.ZIndex = 15
    spinner.Parent = loadingContainer
    
    -- Secondary buttons container
    local buttonsContainer = Instance.new("Frame")
    buttonsContainer.Size = UDim2.new(1, 0, 0, buttonHeight)
    buttonsContainer.Position = UDim2.new(0, 0, 0, math.floor(210 * scaleFactor))
    buttonsContainer.BackgroundTransparency = 1
    buttonsContainer.ZIndex = 12
    buttonsContainer.Parent = parent
    
    local buttonWidth = (1 - buttonSpacing / (Config.ContainerWidth - 60)) / 2
    
    -- Get Key button
    local getKeyButton = Instance.new("TextButton")
    getKeyButton.Size = UDim2.new(buttonWidth, 0, 1, 0)
    getKeyButton.BackgroundColor3 = Colors.GlassBackground
    getKeyButton.BackgroundTransparency = 0.3
    getKeyButton.BorderSizePixel = 0
    getKeyButton.Text = "🔑  Get Key"
    getKeyButton.TextColor3 = Colors.TextPrimary
    getKeyButton.TextSize = math.floor(14 * scaleFactor)
    getKeyButton.Font = Enum.Font.GothamMedium
    getKeyButton.AutoButtonColor = false
    getKeyButton.TextScaled = Config.IsMobile
    getKeyButton.ZIndex = 13
    getKeyButton.Parent = buttonsContainer
    
    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, math.floor(12 * scaleFactor))
    getKeyCorner.Parent = getKeyButton
    
    local getKeyStroke = Instance.new("UIStroke")
    getKeyStroke.Color = Colors.GlassStroke
    getKeyStroke.Thickness = 1.5
    getKeyStroke.Transparency = 0.5
    getKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    getKeyStroke.Parent = getKeyButton
    
    -- Discord button
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(buttonWidth, 0, 1, 0)
    discordButton.Position = UDim2.new(buttonWidth, buttonSpacing, 0, 0)
    discordButton.BackgroundColor3 = Colors.ButtonSecondary
    discordButton.BackgroundTransparency = 0.2
    discordButton.BorderSizePixel = 0
    discordButton.Text = "💬  Discord"
    discordButton.TextColor3 = Colors.TextPrimary
    discordButton.TextSize = math.floor(14 * scaleFactor)
    discordButton.Font = Enum.Font.GothamMedium
    discordButton.AutoButtonColor = false
    discordButton.TextScaled = Config.IsMobile
    discordButton.ZIndex = 13
    discordButton.Parent = buttonsContainer
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, math.floor(12 * scaleFactor))
    discordCorner.Parent = discordButton
    
    local discordStroke = Instance.new("UIStroke")
    discordStroke.Color = Colors.ButtonSecondary
    discordStroke.Thickness = 1.5
    discordStroke.Transparency = 0.5
    discordStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    discordStroke.Parent = discordButton
    
    UI.Buttons = {
        Submit = submitButton,
        GetKey = getKeyButton,
        Discord = discordButton,
        Loading = {Container = loadingContainer, Spinner = spinner}
    }
    
    return {submitButton, getKeyButton, discordButton}
end

-- ========================================
-- STATUS SECTION
-- ========================================

local function CreateStatus(parent)
    local statusContainer = Instance.new("Frame")
    statusContainer.Size = UDim2.new(1, 0, 0, math.floor(40 * scaleFactor))
    statusContainer.Position = UDim2.new(0, 0, 0, math.floor(270 * scaleFactor))
    statusContainer.BackgroundTransparency = 1
    statusContainer.ZIndex = 12
    statusContainer.Parent = parent
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Colors.Error
    statusLabel.TextSize = math.floor(13 * scaleFactor)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextWrapped = true
    statusLabel.TextScaled = Config.IsMobile
    statusLabel.ZIndex = 13
    statusLabel.Parent = statusContainer
    
    UI.Status = statusLabel
    return statusLabel
end

-- ========================================
-- ENHANCED PARTICLE SYSTEM
-- ========================================

local function CreateParticleContainer(parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ZIndex = 105
    container.Parent = parent
    
    UI.ParticleContainer = container
    return container
end

local function CreateParticle()
    if not UI.ParticleContainer or not UI.ParticleContainer.Parent or State.IsDestroyed then
        return nil
    end
    
    local minSize = Config.IsMobile and 4 or 6
    local maxSize = Config.IsMobile and 12 or 18
    local size = math.random(minSize, maxSize)
    
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random() * 1.4 - 0.2, 0, 1.2, 0)
    particle.BackgroundColor3 = Colors.Primary
    particle.BackgroundTransparency = math.random(70, 90) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 106
    particle.Parent = UI.ParticleContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    -- Gradient for particles
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Colors.PrimaryLight)
    }
    gradient.Rotation = math.random(0, 360)
    gradient.Parent = particle
    
    -- Soft glow
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(2, 0, 2, 0)
    glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    glow.BackgroundColor3 = Colors.GlowPrimary
    glow.BackgroundTransparency = 0.95
    glow.BorderSizePixel = 0
    glow.ZIndex = particle.ZIndex - 1
    glow.Parent = particle
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    
    local particleData = {
        frame = particle,
        vx = (math.random() - 0.5) * 0.004,
        vy = -math.random(20, 50) / 10000,
        created = tick(),
        rotation = 0,
        rotationSpeed = (math.random() - 0.5) * 2,
        pulsePhase = math.random() * math.pi * 2,
        originalTransparency = particle.BackgroundTransparency,
        glow = glow,
        lifetime = math.random(30, 60),
        originalSize = size,
        mass = size / 12
    }
    
    table.insert(State.Particles, particleData)
    return particle
end

local function UpdateParticles()
    if State.IsDestroyed or not UI.ParticleContainer then return end
    
    local screenSize = UI.ScreenGui.AbsoluteSize
    local inputPos = Config.IsMobile and State.TouchPosition or State.MousePosition
    local mouseX = inputPos.X / screenSize.X
    local mouseY = inputPos.Y / screenSize.Y
    
    for i = #State.Particles, 1, -1 do
        local p = State.Particles[i]
        
        if not p or not p.frame or not p.frame.Parent then
            table.remove(State.Particles, i)
        else
            local pos = p.frame.Position
            local age = tick() - p.created
            
            if pos.Y.Scale < -0.3 or age > p.lifetime then
                p.frame:Destroy()
                table.remove(State.Particles, i)
            else
                local dist = math.sqrt((pos.X.Scale - mouseX)^2 + (pos.Y.Scale - mouseY)^2)
                local repelRadius = Config.IsMobile and 0.1 or 0.12
                
                local repelX, repelY = 0, 0
                if dist < repelRadius and dist > 0 then
                    local power = (repelRadius - dist) / repelRadius * 0.06 / p.mass
                    repelX = (pos.X.Scale - mouseX) / dist * power
                    repelY = (pos.Y.Scale - mouseY) / dist * power
                end
                
                local newX = pos.X.Scale + p.vx + repelX
                local newY = pos.Y.Scale + p.vy + repelY
                
                if newX <= -0.2 then newX = 1.2
                elseif newX >= 1.2 then newX = -0.2 end
                
                p.rotation = p.rotation + p.rotationSpeed
                p.frame.Rotation = p.rotation
                
                local scale = 1 + math.sin(tick() * 3 + p.pulsePhase) * 0.15
                p.frame.Size = UDim2.new(0, p.originalSize * scale, 0, p.originalSize * scale)
                
                local trans = p.originalTransparency + math.sin(tick() * 2 + p.pulsePhase) * 0.1
                p.frame.BackgroundTransparency = math.clamp(trans, 0.65, 0.95)
                
                p.frame.Position = UDim2.new(newX, 0, newY, 0)
            end
        end
    end
end

-- ========================================
-- BUTTON HOVER EFFECTS
-- ========================================

local function CreateButtonHover(button, hoverColor)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        Services.TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {BackgroundColor3 = hoverColor, BackgroundTransparency = 0}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        Services.TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {BackgroundColor3 = originalColor, BackgroundTransparency = button == UI.Buttons.Submit and 0.1 or 0.3}):Play()
    end)
end

-- ========================================
-- STATUS FUNCTIONS
-- ========================================

local function ShowStatus(message, isError, isSuccess)
    if not UI.Status then return end
    
    UI.Status.Text = message
    if isSuccess then
        UI.Status.TextColor3 = Colors.Success
    elseif isError then
        UI.Status.TextColor3 = Colors.Error
    else
        UI.Status.TextColor3 = Colors.Warning
    end
    
    UI.Status.TextTransparency = 1
    Services.TweenService:Create(UI.Status, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
        {TextTransparency = 0}):Play()
end

local function ClearStatus()
    if UI.Status then
        Services.TweenService:Create(UI.Status, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {TextTransparency = 1}):Play()
    end
end

local function SetLoading(isLoading)
    State.IsLoading = isLoading
    if not UI.Buttons then return end
    
    UI.Buttons.Loading.Container.Visible = isLoading
    UI.Buttons.Submit.Text = isLoading and "" or "Verify Key"
    
    if isLoading then
        local tween = Services.TweenService:Create(UI.Buttons.Loading.Spinner, 
            TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), 
            {Rotation = 360})
        tween:Play()
        State.Animations.SpinTween = tween
    else
        if State.Animations.SpinTween then
            State.Animations.SpinTween:Cancel()
            UI.Buttons.Loading.Spinner.Rotation = 0
        end
    end
end

-- ========================================
-- KEY VALIDATION
-- ========================================

local savedKeyFile = "voidhub/voidhub_key.txt"

local function DestroyKeySystem()
    if State.IsDestroyed then return end
    State.IsDestroyed = true

    for _, anim in pairs(State.Animations) do
        pcall(function()
            if anim then anim:Cancel() end
        end)
    end
    State.Animations = {}

    for _, p in pairs(State.Particles) do
        pcall(function()
            if p.frame then p.frame:Destroy() end
        end)
    end
    State.Particles = {}

    if UI.ScreenGui then
        pcall(function()
            UI.ScreenGui:Destroy()
        end)
    end

    table.clear(UI)
end

local function ValidateKey(keyInput)
    
    if not keyInput or keyInput == "" then
        ShowStatus("Please enter an access key", true)
        if UI.Input and UI.Input.TextBox then
            UI.Input.TextBox:CaptureFocus()
        end
        return
    end

    if State.IsLoading or State.IsDestroyed then 
        return 
    end
    
    SetLoading(true)
    ShowStatus("Validating key...", false, false)

    task.spawn(function()
        local success, result = pcall(function()
            print("🌐 Connecting to Luarmor API...")
            local LuarmorAPI = loadstring(
                game:HttpGet("https://sdkapi-public.luarmor.net/library.lua")
            )()
            LuarmorAPI.script_id = "7d4d44567b1899503a60c87a69f0448f"
            print("✅ API connection established")
            print("🔍 Checking key validity...")
            return LuarmorAPI.check_key(keyInput)
        end)

        SetLoading(false)

        if not success or not result then
            print("❌ Connection error during validation")
            ShowStatus("Connection error. Please try again.", true)
            return
        end

        local status = result
        print("📊 Status code: " .. tostring(status.code))

        if status.code == "KEY_VALID" then
            print("========================================")
            print("✅ KEY VALIDATED SUCCESSFULLY")
            print("========================================")
            writefile(savedKeyFile, tostring(keyInput))
            print("✅ Key saved successfully")
            
            ShowStatus("✅ Access granted! Loading...", false, true)
            task.wait(0.3)

            DestroyKeySystem()

            task.spawn(function()
                script_key = keyInput
                print("========================================")
                print("🚀 LOADING MAIN SCRIPT")
                print("========================================")
                print("🎮 Game PlaceId: " .. tostring(game.PlaceId))
                
                pcall(function()
                    if game.PlaceId == 108533757090220 or game.PlaceId == 12351694619883 or game.PlaceId == 123516946198836 then
                        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/7d4d44567b1899503a60c87a69f0448f.lua"))()
                    elseif game.PlaceId == 93059809719140 then
                        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/6bf0942a399cd32ab5a8031dcad77a46.lua"))()
                    elseif game.PlaceId == 114291906728616 then
                        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/ec6b4acabea984253ca21ca2baf9ed48.lua"))()
                    elseif game.PlaceId == 123638582555543 then
                        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/7793cf6f1f5d4519e94ec4991b7b24f2.lua"))()
                    else
                        LocalPlayer.Kick("🚫 This game is not supported by voidhub. Join a supported game to use the script.")
                    end
                end)
                print("========================================")
                print("🎉 VOID HUB LOADED SUCCESSFULLY")
                print("========================================")
            end)
            return
        end

        if status.code == "KEY_HWID_LOCKED" then
            print("❌ Validation failed: HWID mismatch")
            ShowStatus("⚠️ HWID Mismatch - Use /resethwid in Discord", true)
            return
        end

        if status.code == "KEY_EXPIRED" then
            print("❌ Validation failed: Key expired")
            ShowStatus("❌ Key Expired - Get a new key", true)
            return
        end

        print("❌ Validation failed: Invalid key")
        print("📄 Error message: " .. tostring(status.message or "Unknown error"))
        ShowStatus("❌ Invalid Key: " .. tostring(status.message or "Unknown error"), true)
    end)
end

local function CheckSavedKey()
    print("🔍 Checking for saved key...")
    if isfile and readfile and isfile(savedKeyFile) then
        local savedKey = readfile(savedKeyFile)
        if savedKey and savedKey ~= "" then
            print("✅ Saved key found!")
            print("🔑 Key length: " .. string.len(savedKey) .. " characters")
            ShowStatus("Checking saved key...", false, false)
            task.wait(0.5)
            ValidateKey(savedKey)
        else
            print("ℹ️ No valid saved key found")
        end
    else
        print("ℹ️ No saved key file exists")
    end
end

-- ========================================
-- INPUT HANDLING
-- ========================================

local function UpdateCharCounter()
    if not UI.Input then return end
    
    local currentLength = string.len(UI.Input.TextBox.Text)
    UI.Input.Counter.Text = currentLength .. "/" .. Config.MaxKeyLength
    
    if currentLength >= Config.MaxKeyLength then
        UI.Input.Counter.TextColor3 = Colors.Error
    elseif currentLength >= Config.MaxKeyLength * 0.8 then
        UI.Input.Counter.TextColor3 = Colors.Warning
    else
        UI.Input.Counter.TextColor3 = Colors.TextTertiary
    end
end

local function CopyToClipboard(text, successMessage)
    pcall(function()
        if setclipboard then
            setclipboard(text)
            ShowStatus(successMessage, false, true)
        else
            ShowStatus("Link: " .. text, false, false)
        end
    end)
end

-- ========================================
-- EVENT CONNECTIONS
-- ========================================

local function ConnectEvents()
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            State.MousePosition.X = input.Position.X
            State.MousePosition.Y = input.Position.Y
        elseif input.UserInputType == Enum.UserInputType.Touch then
            State.TouchPosition.X = input.Position.X
            State.TouchPosition.Y = input.Position.Y
        end
    end)
    
    UI.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local currentText = UI.Input.TextBox.Text
        if string.len(currentText) > Config.MaxKeyLength then
            UI.Input.TextBox.Text = string.sub(currentText, 1, Config.MaxKeyLength)
            ShowStatus("Maximum character limit reached", true)
        end
        UpdateCharCounter()
        ClearStatus()
    end)
    
    UI.Input.TextBox.Focused:Connect(function()
        State.FocusStates.InputFocused = true
        UI.Input.Glow.Frame.Visible = true
        
        Services.TweenService:Create(UI.Input.Stroke, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {Color = Colors.Primary, Transparency = 0.2}):Play()
        
        local tween = Services.TweenService:Create(UI.Input.Glow.Gradient, 
            TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), 
            {Rotation = 360})
        tween:Play()
        State.Animations.InputGlowTween = tween
        ClearStatus()
    end)
    
    UI.Input.TextBox.FocusLost:Connect(function()
        State.FocusStates.InputFocused = false
        
        Services.TweenService:Create(UI.Input.Stroke, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {Color = Colors.GlassStroke, Transparency = 0.5}):Play()
        
        if State.Animations.InputGlowTween then
            State.Animations.InputGlowTween:Cancel()
            UI.Input.Glow.Gradient.Rotation = 0
            State.Animations.InputGlowTween = nil
        end
        
        task.wait(0.3)
        if UI.Input.Glow.Frame then
            UI.Input.Glow.Frame.Visible = false
        end
    end)
    
    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or State.IsDestroyed then return end
        if input.KeyCode == Enum.KeyCode.Return and UI.Input.TextBox:IsFocused() then
            ValidateKey(UI.Input.TextBox.Text)
        end
    end)
    
    UI.Buttons.Submit.MouseButton1Click:Connect(function()
        if State.IsLoading then return end
        ValidateKey(UI.Input.TextBox.Text)
    end)
    
    UI.Buttons.GetKey.MouseButton1Click:Connect(function()
        CopyToClipboard("https://ads.luarmor.net/get_key?for=voidhub_Keysystem-UYYNpTHupRUK", "🔑 Key link copied!")
    end)
    
    UI.Buttons.Discord.MouseButton1Click:Connect(function()
        CopyToClipboard("https://discord.gg/wkQdEMwqjd", "💬 Discord invite copied!")
    end)
end

-- ========================================
-- ANIMATION LOOPS
-- ========================================

local function StartAnimationLoops()
    -- Particle spawner
    task.spawn(function()
        local initialCount = Config.IsMobile and 20 or 35
        for i = 1, initialCount do
            if State.IsDestroyed then break end
            CreateParticle()
            task.wait(math.random(15, 60) / 1000)
        end
        
        while not State.IsDestroyed and UI.ScreenGui.Parent do
            if #State.Particles < Config.ParticleCount then
                CreateParticle()
            end
            task.wait(math.random(400, 1200) / 1000)
        end
    end)
    
    -- Particle updater
    task.spawn(function()
        while not State.IsDestroyed and UI.ScreenGui.Parent do
            pcall(UpdateParticles)
            task.wait(1/Config.ParticleSpeed)
        end
    end)
    
    -- Border animation
    task.spawn(function()
        while not State.IsDestroyed and UI.AnimatedBorder and UI.AnimatedBorder.Frame.Parent do
            local tween = Services.TweenService:Create(UI.AnimatedBorder.Gradient, 
                TweenInfo.new(5, Enum.EasingStyle.Linear), 
                {Rotation = UI.AnimatedBorder.Gradient.Rotation + 360})
            State.Animations.BorderTween = tween
            tween:Play()
            tween.Completed:Wait()
            if UI.AnimatedBorder and UI.AnimatedBorder.Gradient then
                UI.AnimatedBorder.Gradient.Rotation = UI.AnimatedBorder.Gradient.Rotation % 360
            end
            task.wait(0.1)
        end
    end)
    
    -- Avatar glow animation
    task.spawn(function()
        while not State.IsDestroyed and UI.Header and UI.Header.AvatarGlow do
            local tween = Services.TweenService:Create(UI.Header.AvatarGlow, 
                TweenInfo.new(4, Enum.EasingStyle.Linear), 
                {Rotation = UI.Header.AvatarGlow.Rotation + 360})
            State.Animations.AvatarTween = tween
            tween:Play()
            tween.Completed:Wait()
            if UI.Header and UI.Header.AvatarGlow then
                UI.Header.AvatarGlow.Rotation = UI.Header.AvatarGlow.Rotation % 360
            end
            task.wait(0.1)
        end
    end)
end

-- ========================================
-- ENTRANCE ANIMATION
-- ========================================

local function PlayEntranceAnimation()
    UI.Container.Size = UDim2.new(0, 0, 0, 0)
    UI.Container.BackgroundTransparency = 1
    UI.Backdrop.BackgroundTransparency = 1
    
    Services.TweenService:Create(UI.Backdrop, 
        TweenInfo.new(0.4, Enum.EasingStyle.Quad), 
        {BackgroundTransparency = 0.3}):Play()
    
    task.wait(0.15)
    
    Services.TweenService:Create(UI.Container, 
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Size = UDim2.new(0, Config.ContainerWidth, 0, Config.ContainerHeight), BackgroundTransparency = 0.2}):Play()
    
    task.wait(0.7)
    UI.Input.TextBox:CaptureFocus()
end

-- ========================================
-- MAIN INITIALIZATION
-- ========================================

local function Initialize()
    print("========================================")
    print("🚀 INITIALIZING VOID HUB")
    print("========================================")
    
    local screenGui = CreateMainGUI()
    local backdrop = CreateBackdrop(screenGui)
    CreateParticleContainer(backdrop)
    local container = CreateContainer(screenGui)
    CreateAnimatedBorder(container)
    CreateHeader(container)
    local content = CreateContent(container)
    CreateInputSection(content)
    CreateButtons(content)
    CreateStatus(content)
    
    CreateButtonHover(UI.Buttons.Submit, Colors.ButtonHover)
    CreateButtonHover(UI.Buttons.GetKey, Colors.GlassBackground)
    CreateButtonHover(UI.Buttons.Discord, Color3.fromRGB(108, 121, 255))
    
    UpdateCharCounter()
    ConnectEvents()
    StartAnimationLoops()
    
    PlayEntranceAnimation()
    
    task.wait(1)
    CheckSavedKey()
end

-- ========================================
-- START THE GUI
-- ========================================

print("")
print("▄▀█ █▀▀ ▀█▀ █ █ █ ▄▀█ ▀█▀ █ █▄ █ █▀▀")
print("█▀█ █▄▄  █  █ ▀▄▀ █▀█  █  █ █ ▀█ █▄█")
print("")
Initialize()
