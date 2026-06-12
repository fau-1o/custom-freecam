-- CUSTOM FREECAM SCRIPT
--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

--// CONFIG
local CONFIG = {
    toggleKey = Enum.KeyCode.F,
    toggleRequiresShift = true,
    rollLeftKey = Enum.KeyCode.Z,
    rollRightKey = Enum.KeyCode.C,
    rollResetKey = Enum.KeyCode.X,
    uiToggleKey = Enum.KeyCode.U,
    panelToggleKey = Enum.KeyCode.P,
    cursorToggleKey = Enum.KeyCode.M,
    controlsToggleKey = Enum.KeyCode.K,
    stickOverlayToggleKey = Enum.KeyCode.I,
    gamepadToggleKey = Enum.KeyCode.ButtonSelect,
    gamepadFlightModeKey = Enum.KeyCode.ButtonY,
    orbitToggleKey = Enum.KeyCode.O,
    orbitPickKey = Enum.KeyCode.T,
    orbitSelectorKey = Enum.KeyCode.B,
    orbitClearKey = Enum.KeyCode.Y,
    orbitSelfKey = Enum.KeyCode.G,
    rotate90Key = Enum.KeyCode.R,
    speedIncreaseKey = Enum.KeyCode.PageUp,
    speedDecreaseKey = Enum.KeyCode.PageDown,
    speedIncreaseFallbackKey = Enum.KeyCode.Equals,
    speedDecreaseFallbackKey = Enum.KeyCode.Minus,
    speedResetKey = Enum.KeyCode.Zero,
    rollSpeedIncreaseKey = Enum.KeyCode.RightBracket,
    rollSpeedDecreaseKey = Enum.KeyCode.LeftBracket,
    boostKey = Enum.KeyCode.LeftShift,
    slowKey = Enum.KeyCode.LeftControl,

    baseSpeed = 15,
    minSpeed = 0.5,
    maxSpeed = 300,
    speedStep = 5,
    boostMultiplier = 3,
    slowMultiplier = 0.25,
    sensitivity = 0.15,
    rollSpeed = math.rad(80),
    rollSpeedStep = math.rad(10),
    minRollSpeed = math.rad(10),
    maxRollSpeed = math.rad(180),
    pitchClamp = math.rad(85),

    posSmooth = 10,
    rotSmooth = 12,
    fovSmooth = 12,

    defaultFov = 70,
    minFov = 1,
    maxFov = 120,
    zoomStep = 3,

    orbitDefaultDistance = 16,
    orbitMinDistance = 2,
    orbitMaxDistance = 500,
    orbitPickDistance = 10000,
    orbitPickHoldDelay = 0.18,
    orbitSelectorDefault = "Object",

    panelDefaultWidth = 500,
    panelDefaultHeight = 580,
    panelMinWidth = 420,
    panelMinHeight = 400,
    panelMaxWidth = 1000,
    panelMaxHeight = 900,

    dofEnabled = false,
    dofFocusMode = "Manual",
    -- Roblox does not expose aperture directly, so these defaults approximate a shallow f/2.8 look.
    dofNearIntensity = 0.55,
    dofFarIntensity = 0.60,
    dofFocusDistance = 28,
    dofInFocusRadius = 8,
    dofAutoFocusSpeed = 8,
    dofMinDistance = 0,
    dofMaxDistance = 500,

    gyroUrl = "http://192.168.1.8:8080/get",
    gyroSensitivity = 5,
    gyroSmoothness = 0.9,
    gyroDeadzone = 0.002,
    gyroPollRate = 44,
    gyroMoveGain = 18,
    gyroTiltGain = 0.85,
    gyroMoveDamping = 5.5,
    gyroMoveDeadzone = 0.18,
    gyroVerticalAssist = 0.65,
}

function makeDefaultDroneModeSettings()
    return {
        speed                 = 4.5,
        sensitivity           = 0.15,
        posSmooth             = 8,
        rotSmooth             = 10,
        fovSmooth             = 12,
        zoomStep              = 3,
        pitchClamp            = math.rad(89),
        boostMultiplier       = 3,
        slowMultiplier        = 0.25,
        verticalSpeedMult     = 1.0,
        droneDeadzone         = 0.05,
        droneRollRate         = 360,
        dronePitchRate        = 360,
        droneYawRate          = 240,
        droneRollExpo         = 0.30,
        dronePitchExpo        = 0.30,
        droneYawExpo          = 0.25,
        droneRollSuper        = 0.50,
        dronePitchSuper       = 0.50,
        droneYawSuper         = 0.40,
        droneRateType         = "Betaflight",
        droneActualCenter     = 200,
        droneActualMaxRate    = 670,
        droneActualExpo       = 0.0,
        droneRateResponse     = 16,
        droneAngularDamping   = 0.08,
        droneThrottleMid      = 0.50,
        droneThrottleExpo     = 0.30,
        droneThrustResponse   = 18,
        droneThrottlePower    = 1.35,
        droneCameraTilt       = 20,
        droneFullRotation     = true,
        droneGravity          = 196.2,
        droneHoverThrottle    = 0.35,
        droneDrag             = 0.22,
        droneQuadDrag         = 0.05,
        droneInertia          = 0.40,
        droneMass             = 0.85,
        droneFlightMode       = "Acro",
        droneAngleMaxTilt     = 45,
        droneAngleLevelStrength = 8,
        droneAngleYawCoord    = 0.18,
        droneMoiPitch         = 0.85,
        droneMoiRoll          = 0.70,
        droneMoiYaw           = 0.95,
        droneDragForward      = 0.20,
        droneDragSideways     = 0.35,
        droneDragVertical     = 0.30,
        droneMotorSpinUp      = 28,
        droneMotorSpinDown    = 22,
        dronePropwashStrength = 0.18,
        dronePropwashZone     = 0.45,
        droneGroundEffectHeight = 3.0,
        droneGroundEffectStrength = 0.08,
    }
end

--// PER-MODE SETTINGS
local modeSettings = {
    Normal = {
        speed           = 15,
        sensitivity     = 0.15,
        posSmooth       = 10,
        rotSmooth       = 12,
        fovSmooth       = 12,
        zoomStep        = 3,
        pitchClamp      = math.rad(85),
        rollSpeed       = math.rad(80),
        boostMultiplier = 3,
        slowMultiplier  = 0.25,
        orbitSpinSpeed  = math.rad(90),
        orbitRadius     = CONFIG.orbitDefaultDistance,
    },
    Drone = makeDefaultDroneModeSettings(),
    Gyroscope = {
        speed           = 12,
        sensitivity     = 0.15,
        posSmooth       = 12,
        rotSmooth       = 14,
        fovSmooth       = 12,
        zoomStep        = 3,
        pitchClamp      = math.rad(85),
        rollSpeed       = math.rad(80),
        boostMultiplier = 3,
        slowMultiplier  = 0.25,
        gyroUrl         = CONFIG.gyroUrl,
        gyroSensitivity = CONFIG.gyroSensitivity,
        gyroSmoothness  = CONFIG.gyroSmoothness,
        gyroDeadzone    = CONFIG.gyroDeadzone,
        gyroPollRate    = CONFIG.gyroPollRate,
        gyroMoveGain    = CONFIG.gyroMoveGain,
        gyroTiltGain    = CONFIG.gyroTiltGain,
        gyroMoveDamping = CONFIG.gyroMoveDamping,
        gyroMoveDeadzone = CONFIG.gyroMoveDeadzone,
        gyroVerticalAssist = CONFIG.gyroVerticalAssist,
    },
}

--// VARS
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local freecam = false
local currentMode = "Normal"
local TWO_PI = math.pi * 2
local BODY_UP = Vector3.new(0, 1, 0)
local BODY_RIGHT = Vector3.new(1, 0, 0)
local BODY_FORWARD = Vector3.new(0, 0, -1)
local DRONE_ARM_LENGTH = 0.32
local DRONE_YAW_TORQUE = 0.12
local DRONE_BATTERY_SAG_MAX = 0.14
local DRONE_MOTOR_THRUST_EXPONENT = 2.0
local DRONE_COLLISION_RADIUS = 0.35
local DRONE_COLLISION_BOUNCE = 0.08
local DRONE_COLLISION_TANGENTIAL_KEEP = 0.55

local speed = CONFIG.baseSpeed
local targetFov = CONFIG.defaultFov
local rollSpeed = CONFIG.rollSpeed
local boostMultiplier = CONFIG.boostMultiplier
local slowMultiplier = CONFIG.slowMultiplier
local sensitivity = CONFIG.sensitivity
local posSmooth = CONFIG.posSmooth
local rotSmooth = CONFIG.rotSmooth
local fovSmooth = CONFIG.fovSmooth
local zoomStep = CONFIG.zoomStep
local pitchClamp = CONFIG.pitchClamp
local dofEnabled = CONFIG.dofEnabled
local dofFocusMode = CONFIG.dofFocusMode
local dofNearIntensity = CONFIG.dofNearIntensity
local dofFarIntensity = CONFIG.dofFarIntensity
local dofFocusDistance = CONFIG.dofFocusDistance
local dofInFocusRadius = CONFIG.dofInFocusRadius
local dofAutoFocusSpeed = CONFIG.dofAutoFocusSpeed
local dofCurrentFocusDistance = dofFocusDistance
local dofEffect
local dofAutoFocusRayParams = RaycastParams.new()
dofAutoFocusRayParams.FilterType = Enum.RaycastFilterType.Exclude
dofAutoFocusRayParams.IgnoreWater = true
local dofAutoFocusRayFilter = {}
local dofAutoFocusCharacter = nil
local orbitEnabled = false
local orbitTarget = nil
local orbitTargetLabel = "None"
local orbitRadius = CONFIG.orbitDefaultDistance
local orbitSpinSpeed = math.rad(90)
local ORBIT_SELECTOR_MODES = {"Object", "Player", "Model", "Part", "Mesh", "Tool-Accessory"}
local ORBIT_SELECTOR_MODE_SET = {Object = true, Player = true, Model = true, Part = true, Mesh = true, ["Tool-Accessory"] = true}
local ORBIT_SELECTOR_MODE_ALIASES = {
    object = "Object",
    objects = "Object",
    player = "Player",
    players = "Player",
    model = "Model",
    models = "Model",
    part = "Part",
    parts = "Part",
    mesh = "Mesh",
    meshes = "Mesh",
    tool = "Tool-Accessory",
    tools = "Tool-Accessory",
    accessory = "Tool-Accessory",
    accessories = "Tool-Accessory",
    ["tool-accessory"] = "Tool-Accessory",
    ["tool-accessories"] = "Tool-Accessory",
    ["tool accessory"] = "Tool-Accessory",
    ["tool accessories"] = "Tool-Accessory",
    ["tool/accessory"] = "Tool-Accessory",
    ["tool/accessories"] = "Tool-Accessory",
    ["tool_accessory"] = "Tool-Accessory",
    ["tool_accessories"] = "Tool-Accessory",
    toolaccessory = "Tool-Accessory",
    toolaccessories = "Tool-Accessory",
}
local orbitSelectorMode = CONFIG.orbitSelectorDefault
local orbitPickHolding = false
local orbitPickStartedAt = 0
local orbitPickPreviewVisible = false
local orbitPreviewTarget = nil
local orbitPreviewHighlight = nil
local ORBIT_PREVIEW_HIGHLIGHT_NAME = "FreecamOrbitSelectorHighlight_" .. tostring(player.UserId)

-- Mode-specific vars
local gyroUrl = CONFIG.gyroUrl
local gyroSensitivity = CONFIG.gyroSensitivity
local gyroSmoothness = CONFIG.gyroSmoothness
local gyroDeadzone = CONFIG.gyroDeadzone
local gyroPollRate = CONFIG.gyroPollRate
local gyroRawX, gyroRawY, gyroRawZ = 0, 0, 0
local gyroSmoothX, gyroSmoothY, gyroSmoothZ = 0, 0, 0
local gyroFetchInFlight = false
local gyroPollAccum = 0
local gyroLastStatus = "Idle"
local gyroLastSampleAt = 0
local GYRO_SENSOR_TO_CAMERA_SCALE = 1.0
local GYRO_MAX_RATE_DPS = 720
local GYRO_ROLL_FACTOR = 0.75
local gyroRateToRadScale = math.rad(1)
local gyroResolvedUrl = nil
local gyroResolvedLabel = nil
local gyroResolvedFromInputUrl = nil
local gyroHttpProxyRemote = nil
local PHYPHOX_GYRO_BUFFER_FALLBACKS = {
    {x = "x", y = "y", z = "z", label = "Phyphox x/y/z"},
    {x = "gyrX", y = "gyrY", z = "gyrZ", label = "Phyphox gyrX/Y/Z"},
    {x = "gyroX", y = "gyroY", z = "gyroZ", label = "Phyphox gyroX/Y/Z"},
    {x = "gx", y = "gy", z = "gz", label = "Phyphox gx/gy/gz"},
    {x = "wx", y = "wy", z = "wz", label = "Phyphox wx/wy/wz"},
}
local GYRO_HTTP_PROXY_NAME = "FreecamGyroHttpProxy"
local GYRO_PROXY_SAFE_POLL_RATE = 44
local gyro6dof = {
    moveGain = CONFIG.gyroMoveGain,
    tiltGain = CONFIG.gyroTiltGain,
    moveDamping = CONFIG.gyroMoveDamping,
    moveDeadzone = CONFIG.gyroMoveDeadzone,
    verticalAssist = CONFIG.gyroVerticalAssist,
    tiltDeadzoneRad = math.rad(4),
    maxTiltRad = math.rad(35),
    earthGravityMs2 = 9.80665,
    worldVelocity = Vector3.zero,
    basePhone = nil,
    baseCamera = nil,
    currentRot = nil,
    resolvedPlan = nil,
    sample = {
        attitudeCFrame = nil,
        accel = Vector3.zero,
        linearAccel = Vector3.zero,
        gravity = Vector3.zero,
        eulerDeg = Vector3.zero,
        hasAttitude = false,
        hasAccel = false,
        hasLinearAccel = false,
        hasGravity = false,
        hasEuler = false,
    },
}
local droneVertMult = 1.0
local droneDeadzone = 0.05
local droneRollRate = 360
local dronePitchRate = 360
local droneYawRate = 240
local droneRollExpo = 0.30
local dronePitchExpo = 0.30
local droneYawExpo = 0.25
local droneRollSuper = 0.50
local dronePitchSuper = 0.50
local droneYawSuper = 0.40
local droneRateResponse = 16
local droneAngularDamping = 0.08
local droneThrottleMid = 0.50
local droneThrottleExpo = 0.30
local droneThrustResponse = 18
local droneThrottlePower = 1.35
local droneCameraTilt = 20
local droneFullRotation = true
local droneGravity = 196.2
local droneHoverThrottle = 0.35
local droneDrag = 0.22
local droneQuadDrag = 0.05
local droneInertia = 0.40
local droneMass = 0.85
local droneVelocity = Vector3.zero
local droneThrottleState = 0
local droneOrient = nil
local droneAngVel = Vector3.zero
local droneMotorOutputs = {0, 0, 0, 0}
local droneBatterySag = 0
local droneGroundRayParams = RaycastParams.new()
droneGroundRayParams.FilterType = Enum.RaycastFilterType.Exclude
droneGroundRayParams.IgnoreWater = true
local droneGroundRayFilter = {}
local droneRaycastCharacter = nil
local dronePropwashPhase = 0

-- Drone flight mode: "Acro", "Angle", "3D"
local droneFlightMode = "Acro"
local droneAngleMaxTilt = 45
local droneAngleLevelStrength = 8
local droneAngleYawCoord = 0.18

-- Advanced physics
local droneRateType = "Betaflight"
local droneActualCenter = 200
local droneActualMaxRate = 670
local droneActualExpo = 0.0
local droneMoiPitch = 0.85
local droneMoiRoll = 0.70
local droneMoiYaw = 0.95
local droneDragForward = 0.20
local droneDragSideways = 0.35
local droneDragVertical = 0.30
local droneMotorSpinUp = 28
local droneMotorSpinDown = 22
local dronePropwashStrength = 0.18
local dronePropwashZone = 0.45
local droneGroundEffectHeight = 3.0
local droneGroundEffectStrength = 0.08
local droneMotorOutput = 0
local droneMotorCommand = 0
local resetDronePhysicsState

-- Rotation state
local yaw, pitch, roll = 0, 0, 0
local yawTarget, pitchTarget, rollTarget = 0, 0, 0

local currentCFrame
local targetCFrame

local humanoid
local saved = {}
local pendingRestore = false
local uiHidden = false
local playerGui = player:WaitForChild("PlayerGui")
local cursorUnlocked = false
local controlsEnabled = true
local panelVisible = true
local stickOverlayVisible = false
local uiRefs = {}
local panelWidth = CONFIG.panelDefaultWidth
local panelHeight = CONFIG.panelDefaultHeight
local scriptKilled = false
local connections = {}
local restoreToken = 0
local topbarRequestId = 0
local sharedEnv = _G
if type(getgenv) == "function" then
    local ok, env = pcall(getgenv)
    if ok and type(env) == "table" then
        sharedEnv = env
    end
end
local RUN_CLEANUP_KEY = "__UltimateFreecamCleanup_" .. tostring(player.UserId)

do
    local previousCleanup = sharedEnv and sharedEnv[RUN_CLEANUP_KEY]
    if type(previousCleanup) == "function" then
        pcall(previousCleanup, "rerun")
    end
end

--// HUMANOID
function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
end
getHumanoid()

function refreshCameraReference()
    local current = workspace.CurrentCamera
    if current and current ~= cam then
        cam = current
        if freecam then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.FieldOfView = targetFov
            if currentCFrame then
                cam.CFrame = currentCFrame
                targetCFrame = currentCFrame
            else
                currentCFrame = cam.CFrame
                targetCFrame = cam.CFrame
            end
        end
    end
    return cam
end

function syncDroneRaycastFilter()
    local character = player.Character
    if character == droneRaycastCharacter then
        return
    end
    droneRaycastCharacter = character
    droneGroundRayFilter[1] = character
    droneGroundRayFilter[2] = nil
    droneGroundRayParams.FilterDescendantsInstances = droneGroundRayFilter
end

syncDroneRaycastFilter()

function syncDofAutoFocusFilter()
    local character = player.Character
    if character == dofAutoFocusCharacter then
        return
    end
    dofAutoFocusCharacter = character
    dofAutoFocusRayFilter[1] = character
    dofAutoFocusRayFilter[2] = nil
    dofAutoFocusRayParams.FilterDescendantsInstances = dofAutoFocusRayFilter
end

syncDofAutoFocusFilter()

function extractRotationCFrame(cf)
    if not cf then
        return CFrame.new()
    end
    return CFrame.fromMatrix(Vector3.zero, cf.RightVector, cf.UpVector, -cf.LookVector)
end

function resetGyroSpatialState()
    gyroSmoothX = 0
    gyroSmoothY = 0
    gyroSmoothZ = 0
    gyroPollAccum = 0
    gyroResolvedUrl = nil
    gyroResolvedLabel = nil
    gyroResolvedFromInputUrl = nil
    gyro6dof.worldVelocity = Vector3.zero
    gyro6dof.basePhone = nil
    gyro6dof.baseCamera = nil
    gyro6dof.currentRot = nil
    gyro6dof.resolvedPlan = nil
    gyro6dof.sample.attitudeCFrame = nil
    gyro6dof.sample.accel = Vector3.zero
    gyro6dof.sample.linearAccel = Vector3.zero
    gyro6dof.sample.gravity = Vector3.zero
    gyro6dof.sample.eulerDeg = Vector3.zero
    gyro6dof.sample.hasAttitude = false
    gyro6dof.sample.hasAccel = false
    gyro6dof.sample.hasLinearAccel = false
    gyro6dof.sample.hasGravity = false
    gyro6dof.sample.hasEuler = false
end

function recenterGyroPose(referenceRot)
    local baseRot = referenceRot or extractRotationCFrame(targetCFrame or currentCFrame or (cam and cam.CFrame))
    local sample = gyro6dof.sample

    gyroSmoothX = 0
    gyroSmoothY = 0
    gyroSmoothZ = 0
    gyro6dof.worldVelocity = Vector3.zero
    gyro6dof.baseCamera = baseRot
    gyro6dof.currentRot = baseRot
    if sample.hasAttitude and sample.attitudeCFrame then
        gyro6dof.basePhone = sample.attitudeCFrame
    else
        gyro6dof.basePhone = nil
    end

    local rx, ry, rz = baseRot:ToOrientation()
    pitch, yaw, roll = rx, ry, rz
    pitchTarget, yawTarget, rollTarget = rx, ry, rz
    return gyro6dof.basePhone ~= nil
end

table.insert(connections, player.CharacterAdded:Connect(function()
    if scriptKilled then
        return
    end
    getHumanoid()
    syncDroneRaycastFilter()
    syncDofAutoFocusFilter()
    if freecam then
        local h = humanoid
        if h then
            saved.Humanoid = {
                WalkSpeed = h.WalkSpeed,
                JumpPower = h.JumpPower,
                JumpHeight = h.JumpHeight,
                UseJumpPower = h.UseJumpPower,
                AutoRotate = h.AutoRotate,
            }
            h.WalkSpeed = 0
            if h.UseJumpPower then
                h.JumpPower = 0
            else
                h.JumpHeight = 0
            end
            h.AutoRotate = false
        end
    elseif pendingRestore then
        local h = humanoid
        local restore = saved.Humanoid
        if h and restore then
            h.WalkSpeed = restore.WalkSpeed
            h.AutoRotate = restore.AutoRotate
            h.UseJumpPower = restore.UseJumpPower
            if restore.UseJumpPower then
                h.JumpPower = restore.JumpPower
            else
                h.JumpHeight = restore.JumpHeight
            end
            pendingRestore = false
        end
    end
end))

--// INPUT STATE
local moveState = {
    [Enum.KeyCode.W] = false,
    [Enum.KeyCode.A] = false,
    [Enum.KeyCode.S] = false,
    [Enum.KeyCode.D] = false,
    [Enum.KeyCode.Q] = false,
    [Enum.KeyCode.E] = false,
}
local rollState = {
    [CONFIG.rollLeftKey] = false,
    [CONFIG.rollRightKey] = false,
}

function bindInputs()
    ContextActionService:BindAction("FC_Move", function(_, state, input)
        if not controlsEnabled then
            return Enum.ContextActionResult.Sink
        end
        local key = input.KeyCode
        if moveState[key] ~= nil then
            if state == Enum.UserInputState.Begin or state == Enum.UserInputState.Change then
                moveState[key] = true
            else
                moveState[key] = false
            end
        end
        return Enum.ContextActionResult.Sink
    end, false,
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S,
        Enum.KeyCode.D, Enum.KeyCode.Q, Enum.KeyCode.E
    )

    ContextActionService:BindAction("FC_Roll", function(_, state, input)
        if not controlsEnabled then
            return Enum.ContextActionResult.Sink
        end
        local key = input.KeyCode
        if rollState[key] ~= nil then
            if state == Enum.UserInputState.Begin or state == Enum.UserInputState.Change then
                rollState[key] = true
            else
                rollState[key] = false
            end
        end
        return Enum.ContextActionResult.Sink
    end, false, CONFIG.rollLeftKey, CONFIG.rollRightKey)
end

function bindExtraControls()
    ContextActionService:BindActionAtPriority("FC_Extra", function(_, state, input)
        if state ~= Enum.UserInputState.Begin then
            return Enum.ContextActionResult.Sink
        end
        if not controlsEnabled then
            return Enum.ContextActionResult.Sink
        end

        local step = CONFIG.speedStep
        if currentMode == "Drone" then
            step = 0.25
        end
        local key = input.KeyCode
        if key == CONFIG.speedIncreaseKey or key == CONFIG.speedIncreaseFallbackKey then
            speed = math.min(CONFIG.maxSpeed, speed + step)
        elseif key == CONFIG.speedDecreaseKey or key == CONFIG.speedDecreaseFallbackKey then
            speed = math.max(CONFIG.minSpeed, speed - step)
        elseif key == CONFIG.speedResetKey then
            speed = CONFIG.baseSpeed
        end

        if key == CONFIG.rollResetKey then
            roll = 0
            rollTarget = 0
            if currentMode == "Gyroscope" and freecam then
                recenterGyroPose(extractRotationCFrame(targetCFrame or currentCFrame or cam.CFrame))
            end
        end

        if key == CONFIG.rollSpeedIncreaseKey then
            rollSpeed = math.min(CONFIG.maxRollSpeed, rollSpeed + CONFIG.rollSpeedStep)
        elseif key == CONFIG.rollSpeedDecreaseKey then
            rollSpeed = math.max(CONFIG.minRollSpeed, rollSpeed - CONFIG.rollSpeedStep)
        end

        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value,
        CONFIG.speedIncreaseKey,
        CONFIG.speedDecreaseKey,
        CONFIG.speedIncreaseFallbackKey,
        CONFIG.speedDecreaseFallbackKey,
        CONFIG.speedResetKey,
        CONFIG.rollResetKey,
        CONFIG.rollSpeedIncreaseKey,
        CONFIG.rollSpeedDecreaseKey
    )
end


function unbindInputs()
    ContextActionService:UnbindAction("FC_Move")
    ContextActionService:UnbindAction("FC_Roll")
    ContextActionService:UnbindAction("FC_Extra")
    for k in pairs(moveState) do
        moveState[k] = false
    end
    for k in pairs(rollState) do
        rollState[k] = false
    end
end

function captureCoreGuiState()
    local state = {}
    for _, guiType in ipairs(Enum.CoreGuiType:GetEnumItems()) do
        local ok, enabled = pcall(function()
            return StarterGui:GetCoreGuiEnabled(guiType)
        end)
        if ok then
            state[guiType] = enabled
        end
    end
    return state
end

function applyCoreGuiState(state, enabledOverride)
    for _, guiType in ipairs(Enum.CoreGuiType:GetEnumItems()) do
        local target
        if enabledOverride ~= nil then
            target = enabledOverride
        else
            target = state and state[guiType]
        end
        if target ~= nil then
            pcall(function()
                StarterGui:SetCoreGuiEnabled(guiType, target)
            end)
        end
    end
end

function captureTopbarState()
    local ok, enabled = pcall(function()
        return StarterGui:GetCore("TopbarEnabled")
    end)
    if ok and type(enabled) == "boolean" then
        return enabled
    end
    return true
end

function setTopbarEnabled(enabled)
    topbarRequestId = topbarRequestId + 1
    local requestId = topbarRequestId
    task.spawn(function()
        for _ = 1, 5 do
            if requestId ~= topbarRequestId then
                return
            end
            local ok = pcall(function()
                StarterGui:SetCore("TopbarEnabled", enabled and true or false)
            end)
            if ok or requestId ~= topbarRequestId then
                return
            end
            task.wait(0.1)
        end
    end)
end

function capturePlayerGuiState()
    local state = {}
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("ScreenGui") then
            state[gui] = gui.Enabled
        end
    end
    return state
end

function applyPlayerGuiState(state, enabledOverride)
    for gui, enabled in pairs(state or {}) do
        if gui and gui.Parent and gui:IsA("ScreenGui") then
            if enabledOverride ~= nil then
                gui.Enabled = enabledOverride
            else
                gui.Enabled = enabled
            end
        end
    end
    if enabledOverride ~= nil then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("ScreenGui") then
                gui.Enabled = enabledOverride
            end
        end
    end
end

function setControlsEnabled(value)
    controlsEnabled = value
    if not controlsEnabled then
        for k in pairs(moveState) do
            moveState[k] = false
        end
        for k in pairs(rollState) do
            rollState[k] = false
        end
    end
end

function setCursorUnlocked(value)
    cursorUnlocked = value
    if not freecam then return end
    if cursorUnlocked then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    end
end

function setUiHidden(value)
    if not freecam then return end
    uiHidden = value
    task.defer(function()
        if uiHidden then
            applyCoreGuiState(nil, false)
            applyPlayerGuiState(nil, false)
            setTopbarEnabled(false)
        else
            applyCoreGuiState(saved.CoreGui, nil)
            applyPlayerGuiState(saved.PlayerGui, nil)
            setTopbarEnabled(saved.TopbarEnabled)
        end
    end)
end

function setPanelVisible(value)
    panelVisible = value
    if uiRefs.panel then
        uiRefs.panel.Visible = panelVisible
        if panelVisible and uiRefs.clampPanel then
            uiRefs.clampPanel()
        end
    end
end

function setStickOverlayVisible(value)
    stickOverlayVisible = value
    if uiRefs.stickOverlay then
        uiRefs.stickOverlay.Visible = stickOverlayVisible
    end
end

function shortenLabel(text, maxLen)
    if not text then
        return "None"
    end
    if #text <= maxLen then
        return text
    end
    return text:sub(1, maxLen - 3) .. "..."
end

function normalizeOrbitSelectorMode(mode)
    mode = tostring(mode or CONFIG.orbitSelectorDefault):match("^%s*(.-)%s*$")
    local alias = ORBIT_SELECTOR_MODE_ALIASES[mode:lower()]
    if alias then
        return alias
    end
    local first = mode:sub(1, 1):upper()
    local rest = mode:sub(2):lower()
    mode = first .. rest
    if ORBIT_SELECTOR_MODE_SET[mode] then
        return mode
    end
    return CONFIG.orbitSelectorDefault
end

function isMeshOrbitPart(part)
    if not part or not part:IsA("BasePart") then
        return false
    end
    if part:IsA("MeshPart") then
        return true
    end
    return part:FindFirstChildWhichIsA("SpecialMesh") ~= nil
end

function isToolAccessoryTarget(inst)
    return inst and (inst:IsA("Tool") or inst:IsA("Accessory") or inst:IsA("Accoutrement"))
end

function getToolAccessoryHandle(target)
    if not target then
        return nil
    end
    local handle = target:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle
    end
    return target:FindFirstChildWhichIsA("BasePart", true)
end

function getToolAccessoryAncestor(inst)
    if not inst then
        return nil
    end
    if isToolAccessoryTarget(inst) then
        return inst
    end
    return inst:FindFirstAncestorWhichIsA("Tool")
        or inst:FindFirstAncestorWhichIsA("Accessory")
        or inst:FindFirstAncestorWhichIsA("Accoutrement")
end

function getOrbitTargetLabel(target)
    if not target then
        return "None"
    end
    if target:IsA("Player") then
        if target.DisplayName and target.DisplayName ~= target.Name then
            return target.DisplayName
        end
        return target.Name
    end
    if target:IsA("BasePart") and isMeshOrbitPart(target) then
        return target.Name .. " [Mesh]"
    end
    if isToolAccessoryTarget(target) then
        return target.Name .. " [" .. target.ClassName .. "]"
    end
    return target.Name
end

function getOrbitTargetPosition(target)
    if not target then
        return nil
    end
    if not target.Parent then
        return nil
    end
    if target:IsA("Player") then
        local char = target.Character
        if not char then
            return nil
        end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if hrp and hrp:IsA("BasePart") then
            return hrp.Position
        end
        return char:GetPivot().Position
    elseif target:IsA("Model") then
        return target:GetPivot().Position
    elseif target:IsA("BasePart") then
        return target.Position
    elseif isToolAccessoryTarget(target) then
        local handle = getToolAccessoryHandle(target)
        if handle then
            return handle.Position
        end
    elseif target:IsA("Attachment") then
        return target.WorldPosition
    end
    return nil
end

function resolveOrbitTarget(inst, selectorMode)
    if not inst then
        return nil
    end
    selectorMode = normalizeOrbitSelectorMode(selectorMode or orbitSelectorMode)

    if selectorMode == "Player" then
        if inst:IsA("Player") then
            return inst
        end
        local model = inst:IsA("Model") and inst or inst:FindFirstAncestorWhichIsA("Model")
        if model then
            return Players:GetPlayerFromCharacter(model)
        end
        return nil
    end

    if selectorMode == "Model" then
        if inst:IsA("Model") then
            return inst
        end
        if inst:IsA("Humanoid") and inst.Parent and inst.Parent:IsA("Model") then
            return inst.Parent
        end
        return inst:FindFirstAncestorWhichIsA("Model")
    end

    if selectorMode == "Part" then
        if inst:IsA("BasePart") then
            return inst
        end
        return inst:FindFirstAncestorWhichIsA("BasePart")
    end

    if selectorMode == "Mesh" then
        local part = inst:IsA("BasePart") and inst or inst:FindFirstAncestorWhichIsA("BasePart")
        if isMeshOrbitPart(part) then
            return part
        end
        return nil
    end

    if selectorMode == "Tool-Accessory" then
        return getToolAccessoryAncestor(inst)
    end

    if inst:IsA("Player") then
        return inst
    end
    if inst:IsA("Model") then
        local plr = Players:GetPlayerFromCharacter(inst)
        return plr or inst
    end
    if inst:IsA("Humanoid") then
        local model = inst.Parent
        if model and model:IsA("Model") then
            local plr = Players:GetPlayerFromCharacter(model)
            return plr or model
        end
    end
    if inst:IsA("BasePart") then
        local model = inst:FindFirstAncestorWhichIsA("Model")
        if model then
            local plr = Players:GetPlayerFromCharacter(model)
            return plr or model
        end
        return inst
    end
    return nil
end

function getOrbitTargetAdornee(target)
    if not target then
        return nil
    end
    if target:IsA("Player") then
        return target.Character
    end
    if target:IsA("Model") or target:IsA("BasePart") then
        return target
    end
    if isToolAccessoryTarget(target) then
        return getToolAccessoryHandle(target)
    end
    if target:IsA("Attachment") and target.Parent and target.Parent:IsA("BasePart") then
        return target.Parent
    end
    return nil
end

function ensureOrbitPreviewHighlight()
    if orbitPreviewHighlight and orbitPreviewHighlight.Parent then
        return orbitPreviewHighlight
    end

    local old = workspace:FindFirstChild(ORBIT_PREVIEW_HIGHLIGHT_NAME)
    if old then
        old:Destroy()
    end

    local h = Instance.new("Highlight")
    h.Name = ORBIT_PREVIEW_HIGHLIGHT_NAME
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Color3.fromRGB(80, 190, 255)
    h.FillTransparency = 1
    h.OutlineColor = Color3.fromRGB(120, 220, 255)
    h.OutlineTransparency = 0
    h.Enabled = false
    h.Parent = workspace
    orbitPreviewHighlight = h
    return h
end

function setOrbitPreviewTarget(target)
    orbitPreviewTarget = target
    local highlight = ensureOrbitPreviewHighlight()
    local adornee = getOrbitTargetAdornee(target)
    highlight.Adornee = adornee
    highlight.Enabled = adornee ~= nil
end

function clearOrbitPreview()
    orbitPreviewTarget = nil
    orbitPickPreviewVisible = false
    if orbitPreviewHighlight then
        orbitPreviewHighlight.Enabled = false
        orbitPreviewHighlight.Adornee = nil
    end
end

function destroyOrbitPreview()
    orbitPickHolding = false
    orbitPickStartedAt = 0
    clearOrbitPreview()
    if orbitPreviewHighlight then
        orbitPreviewHighlight:Destroy()
        orbitPreviewHighlight = nil
    end
end

function getOrbitPickRaycastResult()
    local camNow = refreshCameraReference()
    if not camNow then
        return nil
    end
    local viewportSize = camNow.ViewportSize
    local x = viewportSize.X * 0.5
    local y = viewportSize.Y * 0.5
    if cursorUnlocked then
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        x = mousePos.X - inset.X
        y = mousePos.Y - inset.Y
    end
    x = math.clamp(x, 0, viewportSize.X)
    y = math.clamp(y, 0, viewportSize.Y)
    local ray = camNow:ViewportPointToRay(x, y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local exclude = {}
    if player.Character then
        table.insert(exclude, player.Character)
    end
    params.FilterDescendantsInstances = exclude
    return workspace:Raycast(ray.Origin, ray.Direction * CONFIG.orbitPickDistance, params)
end

function getOrbitTargetUnderCursor()
    local result = getOrbitPickRaycastResult()
    if result and result.Instance then
        return resolveOrbitTarget(result.Instance, orbitSelectorMode)
    end
    return nil
end

function setOrbitSelectorMode(mode)
    orbitSelectorMode = normalizeOrbitSelectorMode(mode)
    clearOrbitPreview()
end

function cycleOrbitSelectorMode(dir)
    local idx = 1
    for i, mode in ipairs(ORBIT_SELECTOR_MODES) do
        if mode == orbitSelectorMode then
            idx = i
            break
        end
    end
    local newIndex = ((idx - 1 + (dir or 1)) % #ORBIT_SELECTOR_MODES) + 1
    setOrbitSelectorMode(ORBIT_SELECTOR_MODES[newIndex])
end

function beginOrbitPickTarget()
    if not freecam then
        return
    end
    orbitPickHolding = true
    orbitPickStartedAt = os.clock()
    clearOrbitPreview()
end

function updateOrbitPickPreview()
    if not orbitPickHolding then
        return
    end
    if not freecam then
        destroyOrbitPreview()
        return
    end
    if os.clock() - orbitPickStartedAt < CONFIG.orbitPickHoldDelay then
        return
    end

    orbitPickPreviewVisible = true
    setOrbitPreviewTarget(getOrbitTargetUnderCursor())
end

function finishOrbitPickTarget()
    if not orbitPickHolding then
        return false
    end

    local target = nil
    if freecam then
        target = getOrbitTargetUnderCursor()
        if not target and orbitPickPreviewVisible then
            target = orbitPreviewTarget
        end
    end

    orbitPickHolding = false
    orbitPickStartedAt = 0
    clearOrbitPreview()

    if target then
        setOrbitTarget(target, true)
        return true
    end
    return false
end

function setOrbitTarget(target, enableOrbit)
    orbitTarget = target
    orbitTargetLabel = getOrbitTargetLabel(target)

    if not target then
        orbitEnabled = false
        return
    end

    if enableOrbit then
        orbitEnabled = true
    end

    local pos = getOrbitTargetPosition(target)
    if not pos then
        return
    end

    local camPos = cam.CFrame.Position
    local offset = camPos - pos
    local dist = offset.Magnitude
    if dist < 0.01 then
        dist = CONFIG.orbitDefaultDistance
        offset = Vector3.new(0, 0, dist)
    end
    orbitRadius = math.clamp(dist, CONFIG.orbitMinDistance, CONFIG.orbitMaxDistance)
    modeSettings.Normal.orbitRadius = orbitRadius

    if offset.Magnitude > 0.01 then
        local dir = offset.Unit
        local newYaw = math.atan2(dir.X, dir.Z)
        local newPitch = math.asin(-dir.Y)
        newPitch = math.clamp(newPitch, -pitchClamp, pitchClamp)
        yaw, yawTarget = newYaw, newYaw
        pitch, pitchTarget = newPitch, newPitch
    end
end

function syncOrbitExitState()
    yaw = wrapAngle(yaw)
    pitch = wrapAngle(pitch)
    roll = wrapAngle(roll)
    yawTarget = yaw
    pitchTarget = pitch
    rollTarget = roll
    if cam then
        currentCFrame = cam.CFrame
        targetCFrame = cam.CFrame
    end
end

function clearOrbitTarget()
    orbitTarget = nil
    orbitTargetLabel = "None"
    orbitEnabled = false
    syncOrbitExitState()
end

function setOrbitEnabled(value)
    if value then
        if orbitTarget then
            setOrbitTarget(orbitTarget, true)
        else
            orbitEnabled = false
        end
    else
        orbitEnabled = false
        syncOrbitExitState()
    end
end

function pickOrbitTarget()
    if not freecam then
        return
    end
    local target = getOrbitTargetUnderCursor()
    if target then
        setOrbitTarget(target, true)
    end
end

function setOrbitTargetSelf()
    setOrbitTarget(player, true)
end

local applyDofSettings

function toggleFreecam()
    freecam = not freecam
    restoreToken = restoreToken + 1

    local activeCam = refreshCameraReference()
    if not activeCam then
        freecam = false
        return
    end

    if freecam then
        syncDroneRaycastFilter()
        dronePropwashPhase = 0
        resetGyroSpatialState()
        saved = {
            Camera = {
                CFrame = activeCam.CFrame,
                Type = activeCam.CameraType,
                Fov = activeCam.FieldOfView,
                Subject = activeCam.CameraSubject,
            },
            Humanoid = humanoid and {
                WalkSpeed = humanoid.WalkSpeed,
                JumpPower = humanoid.JumpPower,
                JumpHeight = humanoid.JumpHeight,
                UseJumpPower = humanoid.UseJumpPower,
                AutoRotate = humanoid.AutoRotate,
            } or nil,
            Mouse = {
                Behavior = UserInputService.MouseBehavior,
                Icon = UserInputService.MouseIconEnabled,
            },
            TopbarEnabled = captureTopbarState(),
            CoreGui = captureCoreGuiState(),
            PlayerGui = capturePlayerGuiState(),
        }

        local x, y = activeCam.CFrame:ToOrientation()
        pitch, yaw, roll = x, y, 0
        pitchTarget, yawTarget, rollTarget = pitch, yaw, 0
        droneOrient = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll)
        gyro6dof.currentRot = extractRotationCFrame(activeCam.CFrame)
        currentCFrame = activeCam.CFrame
        targetCFrame = activeCam.CFrame
        droneVelocity = Vector3.zero
        droneThrottleState = 0
        droneAngVel = Vector3.zero
        resetDronePhysicsState()

        if humanoid then
            humanoid.WalkSpeed = 0
            if humanoid.UseJumpPower then
                humanoid.JumpPower = 0
            else
                humanoid.JumpHeight = 0
            end
            humanoid.AutoRotate = false
        end

        activeCam.CameraType = Enum.CameraType.Scriptable
        targetFov = activeCam.FieldOfView
        activeCam.FieldOfView = targetFov

        setCursorUnlocked(false)
        setControlsEnabled(true)
        bindExtraControls()
        bindInputs()
        applyDofSettings()
    else
        unbindInputs()
        resetGyroSpatialState()

        if saved.Camera then
            activeCam.CameraType = saved.Camera.Type
            activeCam.CFrame = saved.Camera.CFrame
            activeCam.FieldOfView = saved.Camera.Fov
            activeCam.CameraSubject = saved.Camera.Subject
        end

        if humanoid and saved.Humanoid then
            humanoid.WalkSpeed = saved.Humanoid.WalkSpeed
            humanoid.AutoRotate = saved.Humanoid.AutoRotate
            humanoid.UseJumpPower = saved.Humanoid.UseJumpPower
            if saved.Humanoid.UseJumpPower then
                humanoid.JumpPower = saved.Humanoid.JumpPower
            else
                humanoid.JumpHeight = saved.Humanoid.JumpHeight
            end
        elseif saved.Humanoid and not humanoid then
            pendingRestore = true
        end

        local token = restoreToken
        task.defer(function()
            if token ~= restoreToken then
                return
            end
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true

            task.wait()
            if token ~= restoreToken then
                return
            end
            UserInputService.MouseBehavior = (saved.Mouse and saved.Mouse.Behavior) or Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = not (saved.Mouse and saved.Mouse.Icon == false)
        end)

        if uiHidden then
            uiHidden = false
            applyCoreGuiState(saved.CoreGui, nil)
            applyPlayerGuiState(saved.PlayerGui, nil)
        end
        setTopbarEnabled(saved.TopbarEnabled)
        cursorUnlocked = false
        controlsEnabled = true
        if dofEffect then
            dofEffect.Enabled = false
        end
        destroyOrbitPreview()
        orbitEnabled = false
        droneVelocity = Vector3.zero
        droneThrottleState = 0
        droneOrient = nil
        droneAngVel = Vector3.zero
        resetDronePhysicsState()
        dronePropwashPhase = 0
    end
end

function rotatePortrait90()
    roll = roll + math.rad(90)
    rollTarget = roll
end

local activeSliderRow = nil
local dragging = false
local dragStart
local panelStart
local resizing = false
local resizeStart
local resizeStartSize

function clearUiInteractionState()
    activeSliderRow = nil
    dragging = false
    dragStart = nil
    panelStart = nil
    resizing = false
    resizeStart = nil
    resizeStartSize = nil
end

function disconnectAllConnections()
    for _, c in ipairs(connections) do
        if c and c.Disconnect then
            pcall(function()
                c:Disconnect()
            end)
        end
    end
    connections = {}
end

function shutdownFreecamScript(reason)
    if scriptKilled then
        return
    end

    scriptKilled = true
    clearUiInteractionState()

    if freecam then
        toggleFreecam()
    else
        unbindInputs()
    end

    if dofEffect then
        dofEffect.Enabled = false
    end
    destroyOrbitPreview()

    local gui = uiRefs.gui or playerGui:FindFirstChild("FreecamControlUI")
    if gui then
        gui:Destroy()
    end

    disconnectAllConnections()

    if sharedEnv and sharedEnv[RUN_CLEANUP_KEY] == shutdownFreecamScript then
        sharedEnv[RUN_CLEANUP_KEY] = nil
    end

    if reason ~= "rerun" then
        print("Freecam script cleaned up")
    end
end

if sharedEnv then
    sharedEnv[RUN_CLEANUP_KEY] = shutdownFreecamScript
end

--// SETTERS
function setSpeedValue(v)
    speed = math.clamp(v, CONFIG.minSpeed, CONFIG.maxSpeed)
end

function setDroneTwr(v)
    local val = math.clamp(v, 1, 20)
    modeSettings.Drone.speed = val
    if currentMode == "Drone" then
        speed = val
    end
end

function setRollSpeedDeg(v)
    local minDeg = math.deg(CONFIG.minRollSpeed)
    local maxDeg = math.deg(CONFIG.maxRollSpeed)
    rollSpeed = math.rad(math.clamp(v, minDeg, maxDeg))
end

function setFovValue(v)
    targetFov = math.clamp(v, CONFIG.minFov, CONFIG.maxFov)
end

function setSensitivityValue(v)
    sensitivity = math.clamp(v, 0.02, 1.5)
end

function setPosSmoothValue(v)
    posSmooth = math.clamp(v, 1, 40)
end

function setRotSmoothValue(v)
    rotSmooth = math.clamp(v, 1, 40)
end

function setFovSmoothValue(v)
    fovSmooth = math.clamp(v, 1, 40)
end

function setZoomStepValue(v)
    zoomStep = math.clamp(v, 0.2, 20)
end

function setOrbitSpinSpeedDeg(v)
    local deg = math.clamp(v, 1, 360)
    local rad = math.rad(deg)
    modeSettings.Normal.orbitSpinSpeed = rad
    if currentMode == "Normal" then
        orbitSpinSpeed = rad
    end
end

function setOrbitRadiusValue(v)
    local dist = math.clamp(v, CONFIG.orbitMinDistance, CONFIG.orbitMaxDistance)
    modeSettings.Normal.orbitRadius = dist
    if currentMode == "Normal" then
        orbitRadius = dist
    end
end

function setBoostMultiplierValue(v)
    boostMultiplier = math.clamp(v, 1, 8)
end

function setSlowMultiplierValue(v)
    slowMultiplier = math.clamp(v, 0.05, 1)
end

function setPitchClampDeg(v)
    pitchClamp = math.rad(math.clamp(v, 30, 89))
end

function setGyroSensitivity(v)
    gyroSensitivity = math.clamp(v, 0.1, 50)
    modeSettings.Gyroscope.gyroSensitivity = gyroSensitivity
end

function setGyroSmoothness(v)
    gyroSmoothness = math.clamp(v, 0.01, 1)
    modeSettings.Gyroscope.gyroSmoothness = gyroSmoothness
end

function setGyroDeadzone(v)
    gyroDeadzone = math.clamp(v, 0, 0.1)
    modeSettings.Gyroscope.gyroDeadzone = gyroDeadzone
end

function setGyroPollRate(v)
    local maxPollRate = 60
    local proxyRemote = ReplicatedStorage:FindFirstChild(GYRO_HTTP_PROXY_NAME)
    if proxyRemote and proxyRemote:IsA("RemoteFunction") then
        maxPollRate = GYRO_PROXY_SAFE_POLL_RATE
    end
    gyroPollRate = math.clamp(v, 1, maxPollRate)
    modeSettings.Gyroscope.gyroPollRate = gyroPollRate
end

function setGyroMoveGain(v)
    gyro6dof.moveGain = math.clamp(v, 0, 80)
    modeSettings.Gyroscope.gyroMoveGain = gyro6dof.moveGain
end

function setGyroTiltGain(v)
    gyro6dof.tiltGain = math.clamp(v, 0, 4)
    modeSettings.Gyroscope.gyroTiltGain = gyro6dof.tiltGain
end

function setGyroMoveDamping(v)
    gyro6dof.moveDamping = math.clamp(v, 0.1, 30)
    modeSettings.Gyroscope.gyroMoveDamping = gyro6dof.moveDamping
end

function setGyroMoveDeadzone(v)
    gyro6dof.moveDeadzone = math.clamp(v, 0, 3)
    modeSettings.Gyroscope.gyroMoveDeadzone = gyro6dof.moveDeadzone
end

function setGyroVerticalAssist(v)
    gyro6dof.verticalAssist = math.clamp(v, 0, 2)
    modeSettings.Gyroscope.gyroVerticalAssist = gyro6dof.verticalAssist
end

function setDroneVertMult(v)
    droneVertMult = math.clamp(v, 0.1, 3)
    modeSettings.Drone.verticalSpeedMult = droneVertMult
end

function setDroneDeadzone(v)
    droneDeadzone = math.clamp(v, 0, 0.3)
    modeSettings.Drone.droneDeadzone = droneDeadzone
end

function setDroneRollRate(v)
    droneRollRate = math.clamp(v, 50, 1200)
    modeSettings.Drone.droneRollRate = droneRollRate
end

function setDronePitchRate(v)
    dronePitchRate = math.clamp(v, 50, 1200)
    modeSettings.Drone.dronePitchRate = dronePitchRate
end

function setDroneYawRate(v)
    droneYawRate = math.clamp(v, 50, 1200)
    modeSettings.Drone.droneYawRate = droneYawRate
end

function setDroneRollExpo(v)
    droneRollExpo = math.clamp(v, 0, 1)
    modeSettings.Drone.droneRollExpo = droneRollExpo
end

function setDronePitchExpo(v)
    dronePitchExpo = math.clamp(v, 0, 1)
    modeSettings.Drone.dronePitchExpo = dronePitchExpo
end

function setDroneYawExpo(v)
    droneYawExpo = math.clamp(v, 0, 1)
    modeSettings.Drone.droneYawExpo = droneYawExpo
end

function setDroneRollSuper(v)
    droneRollSuper = math.clamp(v, 0, 1)
    modeSettings.Drone.droneRollSuper = droneRollSuper
end

function setDronePitchSuper(v)
    dronePitchSuper = math.clamp(v, 0, 1)
    modeSettings.Drone.dronePitchSuper = dronePitchSuper
end

function setDroneRateType(v)
    droneRateType = (type(v) == "number" and (v >= 0.5 and "Betaflight" or "Acro")) or v
    modeSettings.Drone.droneRateType = droneRateType
end

function setDroneActualCenter(v)
    droneActualCenter = math.clamp(v, 10, 1000)
    modeSettings.Drone.droneActualCenter = droneActualCenter
end

function setDroneActualMaxRate(v)
    droneActualMaxRate = math.clamp(v, 10, 2000)
    modeSettings.Drone.droneActualMaxRate = droneActualMaxRate
end

function setDroneActualExpo(v)
    droneActualExpo = math.clamp(v, 0, 1)
    modeSettings.Drone.droneActualExpo = droneActualExpo
end

function setDroneAngleYawCoord(v)
    droneAngleYawCoord = math.clamp(v, 0, 1)
    modeSettings.Drone.droneAngleYawCoord = droneAngleYawCoord
end

function setDroneMoiPitch(v)
    droneMoiPitch = math.clamp(v, 0.2, 5)
    modeSettings.Drone.droneMoiPitch = droneMoiPitch
end

function setDroneMoiRoll(v)
    droneMoiRoll = math.clamp(v, 0.2, 5)
    modeSettings.Drone.droneMoiRoll = droneMoiRoll
end

function setDroneMoiYaw(v)
    droneMoiYaw = math.clamp(v, 0.2, 5)
    modeSettings.Drone.droneMoiYaw = droneMoiYaw
end

function setDroneDragForward(v)
    droneDragForward = math.clamp(v, 0, 3)
    modeSettings.Drone.droneDragForward = droneDragForward
end

function setDroneDragSideways(v)
    droneDragSideways = math.clamp(v, 0, 3)
    modeSettings.Drone.droneDragSideways = droneDragSideways
end

function setDroneDragVertical(v)
    droneDragVertical = math.clamp(v, 0, 3)
    modeSettings.Drone.droneDragVertical = droneDragVertical
end

function setDroneMotorSpinUp(v)
    droneMotorSpinUp = math.clamp(v, 1, 30)
    modeSettings.Drone.droneMotorSpinUp = droneMotorSpinUp
end

function setDroneMotorSpinDown(v)
    droneMotorSpinDown = math.clamp(v, 1, 30)
    modeSettings.Drone.droneMotorSpinDown = droneMotorSpinDown
end

function setDronePropwashStrength(v)
    dronePropwashStrength = math.clamp(v, 0, 1)
    modeSettings.Drone.dronePropwashStrength = dronePropwashStrength
end

function setDronePropwashZone(v)
    dronePropwashZone = math.clamp(v, 0, 1)
    modeSettings.Drone.dronePropwashZone = dronePropwashZone
end

function setDroneGroundEffectHeight(v)
    droneGroundEffectHeight = math.clamp(v, 0, 20)
    modeSettings.Drone.droneGroundEffectHeight = droneGroundEffectHeight
end

function setDroneGroundEffectStrength(v)
    droneGroundEffectStrength = math.clamp(v, 0, 0.5)
    modeSettings.Drone.droneGroundEffectStrength = droneGroundEffectStrength
end

function setDroneYawSuper(v)
    droneYawSuper = math.clamp(v, 0, 1)
    modeSettings.Drone.droneYawSuper = droneYawSuper
end

function setDroneRateResponse(v)
    droneRateResponse = math.clamp(v, 1, 25)
    modeSettings.Drone.droneRateResponse = droneRateResponse
end

function setDroneAngularDamping(v)
    droneAngularDamping = math.clamp(v, 0, 5)
    modeSettings.Drone.droneAngularDamping = droneAngularDamping
end

function setDroneThrottleMid(v)
    droneThrottleMid = math.clamp(v, 0.05, 0.95)
    modeSettings.Drone.droneThrottleMid = droneThrottleMid
end

function setDroneThrottleExpo(v)
    droneThrottleExpo = math.clamp(v, 0, 1)
    modeSettings.Drone.droneThrottleExpo = droneThrottleExpo
end

function setDroneThrustResponse(v)
    droneThrustResponse = math.clamp(v, 1, 25)
    modeSettings.Drone.droneThrustResponse = droneThrustResponse
end

function setDroneThrottlePower(v)
    droneThrottlePower = math.clamp(v, 1, 3)
    modeSettings.Drone.droneThrottlePower = droneThrottlePower
end

function setDroneCameraTilt(v)
    droneCameraTilt = math.clamp(v, 0, 60)
    modeSettings.Drone.droneCameraTilt = droneCameraTilt
end

function setDroneGravity(v)
    droneGravity = math.clamp(v, 0, 400)
    modeSettings.Drone.droneGravity = droneGravity
end

function setDroneHoverThrottle(v)
    droneHoverThrottle = math.clamp(v, 0.05, 0.95)
    modeSettings.Drone.droneHoverThrottle = droneHoverThrottle
end

function setDroneDrag(v)
    droneDrag = math.clamp(v, 0, 3)
    modeSettings.Drone.droneDrag = droneDrag
end

function setDroneQuadDrag(v)
    droneQuadDrag = math.clamp(v, 0, 0.2)
    modeSettings.Drone.droneQuadDrag = droneQuadDrag
end

function setDroneInertia(v)
    droneInertia = math.clamp(v, 0, 1)
    modeSettings.Drone.droneInertia = droneInertia
end

function setDroneMass(v)
    droneMass = math.clamp(v, 0.2, 8)
    modeSettings.Drone.droneMass = droneMass
end

local updateDroneFlightModeUI

function setDroneFlightMode(mode)
    droneFlightMode = mode
    modeSettings.Drone.droneFlightMode = mode
    -- Reset orientation state on mode switch
    droneVelocity = Vector3.zero
    droneThrottleState = 0
    droneAngVel = Vector3.zero
    resetDronePhysicsState()
    dronePropwashPhase = 0
    if updateDroneFlightModeUI then
        updateDroneFlightModeUI()
    end
end

local droneFlightModeOrder = { "Acro", "Angle", "3D" }

updateDroneFlightModeUI = function()
    local dt = uiRefs.droneTabRows
    if dt and dt._flightModeBtns and dt._flightModes then
        if dt._updateFlightModeBtns then
            dt._updateFlightModeBtns()
        end
        for _, fm in ipairs(dt._flightModes) do
            local btn = dt._flightModeBtns[fm.name]
            if btn then
                if droneFlightMode == fm.name then
                    btn.BackgroundColor3 = fm.color
                    btn.TextColor3 = Color3.fromRGB(15, 15, 15)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(28, 36, 32)
                    btn.TextColor3 = Color3.fromRGB(170, 190, 180)
                end
            end
        end
    end
    if uiRefs.droneAngleSection then
        uiRefs.droneAngleSection.Visible = (droneFlightMode == "Angle")
    end
end

function cycleDroneFlightMode(dir)
    local idx = 1
    for i, name in ipairs(droneFlightModeOrder) do
        if name == droneFlightMode then
            idx = i
            break
        end
    end
    local newIndex = ((idx - 1 + dir) % #droneFlightModeOrder) + 1
    setDroneFlightMode(droneFlightModeOrder[newIndex])
    updateDroneFlightModeUI()
end

function setDroneAngleMaxTilt(v)
    droneAngleMaxTilt = math.clamp(v, 5, 85)
    modeSettings.Drone.droneAngleMaxTilt = droneAngleMaxTilt
end

function setDroneAngleLevelStrength(v)
    droneAngleLevelStrength = math.clamp(v, 0.5, 20)
    modeSettings.Drone.droneAngleLevelStrength = droneAngleLevelStrength
end
--// SETTINGS IMPORT / EXPORT
function encodeSettingValue(value)
    value = tostring(value or "")
    value = value:gsub("%%", "%%25")
    value = value:gsub("|", "%%7C")
    value = value:gsub("=", "%%3D")
    return value
end

function decodeSettingValue(value)
    value = tostring(value or "")
    value = value:gsub("%%7C", "|"):gsub("%%7c", "|")
    value = value:gsub("%%3D", "="):gsub("%%3d", "=")
    value = value:gsub("%%25", "%%")
    return value
end

function serializeSettings()
    local parts = {
        "FCv1",
        "mode="      .. currentMode,
        "speed="     .. tostring(speed),
        "sens="      .. tostring(sensitivity),
        "posSmooth=" .. tostring(posSmooth),
        "rotSmooth=" .. tostring(rotSmooth),
        "fovSmooth=" .. tostring(fovSmooth),
        "zoomStep="  .. tostring(zoomStep),
        "pitchClamp=" .. tostring(math.deg(pitchClamp)),
        "rollSpeed=" .. tostring(math.deg(rollSpeed)),
        "boost="     .. tostring(boostMultiplier),
        "slow="      .. tostring(slowMultiplier),
        "oSpin="     .. tostring(math.deg(modeSettings.Normal.orbitSpinSpeed or orbitSpinSpeed)),
        "oRad="      .. tostring(modeSettings.Normal.orbitRadius or orbitRadius),
        "oSel="      .. tostring(orbitSelectorMode),
        "fov="       .. tostring(targetFov),
        "dofOn="     .. (dofEnabled and "1" or "0"),
        "dofMode="   .. tostring(dofFocusMode),
        "dofNear="   .. tostring(dofNearIntensity),
        "dofFar="    .. tostring(dofFarIntensity),
        "dofFocus="  .. tostring(dofFocusDistance),
        "dofRadius=" .. tostring(dofInFocusRadius),
        "dofAutoSpd=" .. tostring(dofAutoFocusSpeed),
        "gyroUrl="   .. tostring(gyroUrl),
        "gyroSens="  .. tostring(gyroSensitivity),
        "gyroSmooth=" .. tostring(gyroSmoothness),
        "gyroDead="  .. tostring(gyroDeadzone),
        "gyroPoll="  .. tostring(gyroPollRate),
        "gyroMoveG=" .. tostring(gyro6dof.moveGain),
        "gyroTiltG=" .. tostring(gyro6dof.tiltGain),
        "gyroMoveD=" .. tostring(gyro6dof.moveDamping),
        "gyroMoveZ=" .. tostring(gyro6dof.moveDeadzone),
        "gyroVertA=" .. tostring(gyro6dof.verticalAssist),
        "dfm="       .. droneFlightMode,
        "dRollR="    .. tostring(droneRollRate),
        "dPitchR="   .. tostring(dronePitchRate),
        "dYawR="     .. tostring(droneYawRate),
        "dRollE="    .. tostring(droneRollExpo),
        "dPitchE="   .. tostring(dronePitchExpo),
        "dYawE="     .. tostring(droneYawExpo),
        "dRollS="    .. tostring(droneRollSuper),
        "dPitchS="   .. tostring(dronePitchSuper),
        "dYawS="     .. tostring(droneYawSuper),
        "dRateT="    .. tostring(droneRateType),
        "dActCe="    .. tostring(droneActualCenter),
        "dActMa="    .. tostring(droneActualMaxRate),
        "dActEx="    .. tostring(droneActualExpo),
        "dRateRsp="  .. tostring(droneRateResponse),
        "dAngDamp="  .. tostring(droneAngularDamping),
        "dThrMid="   .. tostring(droneThrottleMid),
        "dThrExp="   .. tostring(droneThrottleExpo),
        "dThrResp="  .. tostring(droneThrustResponse),
        "dThrPow="   .. tostring(droneThrottlePower),
        "dCamTilt="  .. tostring(droneCameraTilt),
        "dFullRot="  .. (droneFullRotation and "1" or "0"),
        "dGrav="     .. tostring(droneGravity),
        "dHover="    .. tostring(droneHoverThrottle),
        "dDrag="     .. tostring(droneDrag),
        "dQDrag="    .. tostring(droneQuadDrag),
        "dInertia="  .. tostring(droneInertia),
        "dMass="     .. tostring(droneMass),
        "dDeadz="    .. tostring(droneDeadzone),
        "dVertM="    .. tostring(droneVertMult),
        "dAngTilt="  .. tostring(droneAngleMaxTilt),
        "dAngStr="   .. tostring(droneAngleLevelStrength),
        "dAngYawC="  .. tostring(droneAngleYawCoord),
        "dMoiP="     .. tostring(droneMoiPitch),
        "dMoiR="     .. tostring(droneMoiRoll),
        "dMoiY="     .. tostring(droneMoiYaw),
        "dDrgFwd="   .. tostring(droneDragForward),
        "dDrgSide="  .. tostring(droneDragSideways),
        "dDrgVert="  .. tostring(droneDragVertical),
        "dMotUp="    .. tostring(droneMotorSpinUp),
        "dMotDn="    .. tostring(droneMotorSpinDown),
        "dPwStr="    .. tostring(dronePropwashStrength),
        "dPwZone="   .. tostring(dronePropwashZone),
        "dGeHt="     .. tostring(droneGroundEffectHeight),
        "dGeStr="    .. tostring(droneGroundEffectStrength),
    }
    for i = 2, #parts do
        local k, v = parts[i]:match("^([^=]+)=(.*)$")
        if k and v then
            parts[i] = k .. "=" .. encodeSettingValue(v)
        end
    end
    return table.concat(parts, "|")
end

function applySettingsString(str)
    str = tostring(str):match("^%s*(.-)%s*$")
    if not str:match("^FCv1|") then
        return false, "Format tidak valid. Pastikan dimulai dengan 'FCv1|'."
    end
    local data = {}
    for pair in str:gmatch("[^|]+") do
        local k, v = pair:match("^([^=]+)=(.*)$")
        if k and v then data[k] = decodeSettingValue(v) end
    end
    local function num(k, default)
        return tonumber(data[k]) or default
    end
    local function str(k, default)
        return data[k] or default
    end
    -- Mode switch (tanpa reset state)
    if data.mode == "Gyro" or data.mode == "Aerial" then data.mode = "Gyroscope" end
    if data.mode and modeSettings[data.mode] and data.mode ~= currentMode then
        saveModeSettings(currentMode)
        currentMode = data.mode
        applyModeSettings(currentMode)
    end
    -- General
    setSpeedValue(num("speed", speed))
    setSensitivityValue(num("sens", sensitivity))
    setPosSmoothValue(num("posSmooth", posSmooth))
    setRotSmoothValue(num("rotSmooth", rotSmooth))
    setFovSmoothValue(num("fovSmooth", fovSmooth))
    setZoomStepValue(num("zoomStep", zoomStep))
    setPitchClampDeg(num("pitchClamp", math.deg(pitchClamp)))
    setRollSpeedDeg(num("rollSpeed", math.deg(rollSpeed)))
    setBoostMultiplierValue(num("boost", boostMultiplier))
    setSlowMultiplierValue(num("slow", slowMultiplier))
    setOrbitSpinSpeedDeg(num("oSpin", math.deg(modeSettings.Normal.orbitSpinSpeed or orbitSpinSpeed)))
    setOrbitRadiusValue(num("oRad", modeSettings.Normal.orbitRadius or orbitRadius))
    setOrbitSelectorMode(str("oSel", orbitSelectorMode))
    setFovValue(num("fov", targetFov))
    -- DoF
    dofEnabled      = (num("dofOn", dofEnabled and 1 or 0) == 1)
    dofFocusMode    = ((str("dofMode", CONFIG.dofFocusMode) or "Manual"):lower() == "auto") and "Auto" or "Manual"
    dofNearIntensity = math.clamp(num("dofNear",   dofNearIntensity),   0, 1)
    dofFarIntensity  = math.clamp(num("dofFar",    dofFarIntensity),    0, 1)
    dofFocusDistance = math.clamp(num("dofFocus",  dofFocusDistance),   0, 500)
    dofInFocusRadius = math.clamp(num("dofRadius", dofInFocusRadius),   0, 500)
    dofAutoFocusSpeed = math.clamp(num("dofAutoSpd", dofAutoFocusSpeed), 0.5, 100)
    dofCurrentFocusDistance = dofFocusDistance
    applyDofSettings()
    -- Gyroscope
    gyroUrl = str("gyroUrl", gyroUrl)
    modeSettings.Gyroscope.gyroUrl = gyroUrl
    setGyroSensitivity(num("gyroSens", num("gyroStr", gyroSensitivity)))
    setGyroSmoothness(num("gyroSmooth", gyroSmoothness))
    setGyroDeadzone(num("gyroDead", gyroDeadzone))
    setGyroPollRate(num("gyroPoll", gyroPollRate))
    setGyroMoveGain(num("gyroMoveG", gyro6dof.moveGain))
    setGyroTiltGain(num("gyroTiltG", gyro6dof.tiltGain))
    setGyroMoveDamping(num("gyroMoveD", gyro6dof.moveDamping))
    setGyroMoveDeadzone(num("gyroMoveZ", gyro6dof.moveDeadzone))
    setGyroVerticalAssist(num("gyroVertA", gyro6dof.verticalAssist))
    -- Drone flight mode
    if data.dfm and (data.dfm == "Acro" or data.dfm == "Angle" or data.dfm == "3D") then
        setDroneFlightMode(data.dfm)
    end
    -- Drone params
    setDroneRollRate(num("dRollR", droneRollRate))
    setDronePitchRate(num("dPitchR", dronePitchRate))
    setDroneYawRate(num("dYawR", droneYawRate))
    setDroneRollExpo(num("dRollE", droneRollExpo))
    setDronePitchExpo(num("dPitchE", dronePitchExpo))
    setDroneYawExpo(num("dYawE", droneYawExpo))
    setDroneRollSuper(num("dRollS", droneRollSuper))
    setDronePitchSuper(num("dPitchS", dronePitchSuper))
    setDroneYawSuper(num("dYawS", droneYawSuper))
    setDroneRateType(str("dRateT", droneRateType))
    setDroneActualCenter(num("dActCe", droneActualCenter))
    setDroneActualMaxRate(num("dActMa", droneActualMaxRate))
    setDroneActualExpo(num("dActEx", droneActualExpo))
    setDroneRateResponse(num("dRateRsp", droneRateResponse))
    setDroneAngularDamping(num("dAngDamp", droneAngularDamping))
    setDroneThrottleMid(num("dThrMid", droneThrottleMid))
    setDroneThrottleExpo(num("dThrExp", droneThrottleExpo))
    setDroneThrustResponse(num("dThrResp", droneThrustResponse))
    setDroneThrottlePower(num("dThrPow", droneThrottlePower))
    setDroneCameraTilt(num("dCamTilt", droneCameraTilt))
    droneFullRotation = (num("dFullRot", droneFullRotation and 1 or 0) == 1)
    modeSettings.Drone.droneFullRotation = droneFullRotation
    setDroneGravity(num("dGrav", droneGravity))
    setDroneHoverThrottle(num("dHover", droneHoverThrottle))
    setDroneDrag(num("dDrag", droneDrag))
    setDroneQuadDrag(num("dQDrag", droneQuadDrag))
    setDroneInertia(num("dInertia", droneInertia))
    setDroneMass(num("dMass", droneMass))
    setDroneDeadzone(num("dDeadz", droneDeadzone))
    setDroneVertMult(num("dVertM", droneVertMult))
    setDroneAngleMaxTilt(num("dAngTilt", droneAngleMaxTilt))
    setDroneAngleLevelStrength(num("dAngStr", droneAngleLevelStrength))
    setDroneAngleYawCoord(num("dAngYawC", droneAngleYawCoord))
    setDroneMoiPitch(num("dMoiP", droneMoiPitch))
    setDroneMoiRoll(num("dMoiR", droneMoiRoll))
    setDroneMoiYaw(num("dMoiY", droneMoiYaw))
    setDroneDragForward(num("dDrgFwd", droneDragForward))
    setDroneDragSideways(num("dDrgSide", droneDragSideways))
    setDroneDragVertical(num("dDrgVert", droneDragVertical))
    setDroneMotorSpinUp(num("dMotUp", droneMotorSpinUp))
    setDroneMotorSpinDown(num("dMotDn", droneMotorSpinDown))
    setDronePropwashStrength(num("dPwStr", dronePropwashStrength))
    setDronePropwashZone(num("dPwZone", dronePropwashZone))
    setDroneGroundEffectHeight(num("dGeHt", droneGroundEffectHeight))
    setDroneGroundEffectStrength(num("dGeStr", droneGroundEffectStrength))
    saveModeSettings(currentMode)
    refreshUiText()
    return true, "OK Settingan berhasil diterapkan!"
end

function ensureDofEffect()
    if dofEffect and dofEffect.Parent then
        return dofEffect
    end
    local existing = Lighting:FindFirstChild("FreecamDOFEffect")
    if existing and existing:IsA("DepthOfFieldEffect") then
        dofEffect = existing
    else
        dofEffect = Instance.new("DepthOfFieldEffect")
        dofEffect.Name = "FreecamDOFEffect"
        dofEffect.Parent = Lighting
    end
    return dofEffect
end

function resolveDofFocusDistance()
    if dofFocusMode ~= "Auto" or not dofEnabled or not freecam then
        return dofFocusDistance
    end
    syncDofAutoFocusFilter()
    local activeCam = cam or workspace.CurrentCamera
    local sourceCFrame = currentCFrame or targetCFrame or (activeCam and activeCam.CFrame)
    if not sourceCFrame then
        return dofFocusDistance
    end
    local result = workspace:Raycast(
        sourceCFrame.Position,
        sourceCFrame.LookVector * CONFIG.dofMaxDistance,
        dofAutoFocusRayParams
    )
    if result then
        return math.clamp(result.Distance, 1, CONFIG.dofMaxDistance)
    end
    return dofFocusDistance
end

function updateDofAutoFocus(dt)
    if dofFocusMode ~= "Auto" or not dofEnabled or not freecam then
        return
    end
    local fx = ensureDofEffect()
    local targetDistance = resolveDofFocusDistance()
    local step = math.max(0, dofAutoFocusSpeed) * dt
    dofCurrentFocusDistance = dofCurrentFocusDistance + math.clamp(targetDistance - dofCurrentFocusDistance, -step, step)
    fx.FocusDistance = dofCurrentFocusDistance
end

applyDofSettings = function()
    local fx = ensureDofEffect()
    fx.NearIntensity = dofNearIntensity
    fx.FarIntensity = dofFarIntensity
    if dofFocusMode == "Manual" then
        dofCurrentFocusDistance = dofFocusDistance
    end
    fx.FocusDistance = dofCurrentFocusDistance
    fx.InFocusRadius = dofInFocusRadius
    fx.Enabled = dofEnabled and freecam
end

function setDofEnabled(v)
    dofEnabled = v
    applyDofSettings()
end

function setDofNearIntensity(v)
    dofNearIntensity = math.clamp(v, 0, 1)
    applyDofSettings()
end

function setDofFarIntensity(v)
    dofFarIntensity = math.clamp(v, 0, 1)
    applyDofSettings()
end

function setDofFocusDistance(v)
    dofFocusDistance = math.clamp(v, CONFIG.dofMinDistance, CONFIG.dofMaxDistance)
    applyDofSettings()
end

function setDofInFocusRadius(v)
    dofInFocusRadius = math.clamp(v, 0, CONFIG.dofMaxDistance)
    applyDofSettings()
end

function setDofAutoFocusSpeed(v)
    dofAutoFocusSpeed = math.clamp(v, 0.5, 100)
end

function setDofFocusMode(v)
    if v ~= "Auto" and v ~= "Manual" then
        return
    end
    dofFocusMode = v
    if dofFocusMode == "Manual" then
        dofCurrentFocusDistance = dofFocusDistance
    end
    applyDofSettings()
end

function toggleDofFocusMode()
    setDofFocusMode(dofFocusMode == "Auto" and "Manual" or "Auto")
end

function resetDofSettings()
    dofEnabled = CONFIG.dofEnabled
    dofFocusMode = CONFIG.dofFocusMode
    dofNearIntensity = CONFIG.dofNearIntensity
    dofFarIntensity = CONFIG.dofFarIntensity
    dofFocusDistance = CONFIG.dofFocusDistance
    dofInFocusRadius = CONFIG.dofInFocusRadius
    dofAutoFocusSpeed = CONFIG.dofAutoFocusSpeed
    dofCurrentFocusDistance = dofFocusDistance
    applyDofSettings()
end

--// MODE SYSTEM
function applyModeSettings(mode)
    local s = modeSettings[mode]
    if not s then return end
    speed           = s.speed
    sensitivity     = s.sensitivity
    posSmooth       = s.posSmooth
    rotSmooth       = s.rotSmooth
    fovSmooth       = s.fovSmooth
    zoomStep        = s.zoomStep
    pitchClamp      = s.pitchClamp
    boostMultiplier = s.boostMultiplier
    slowMultiplier  = s.slowMultiplier
    if s.rollSpeed    then rollSpeed    = s.rollSpeed    end
    if mode == "Normal" then
        if s.orbitSpinSpeed ~= nil then orbitSpinSpeed = s.orbitSpinSpeed end
        if s.orbitRadius ~= nil then orbitRadius = s.orbitRadius end
    end
    if s.gyroUrl ~= nil then gyroUrl = s.gyroUrl end
    if s.gyroSensitivity ~= nil then gyroSensitivity = s.gyroSensitivity end
    if s.gyroSmoothness ~= nil then gyroSmoothness = s.gyroSmoothness end
    if s.gyroDeadzone ~= nil then gyroDeadzone = s.gyroDeadzone end
    if s.gyroPollRate ~= nil then setGyroPollRate(s.gyroPollRate) end
    if s.gyroMoveGain ~= nil then gyro6dof.moveGain = s.gyroMoveGain end
    if s.gyroTiltGain ~= nil then gyro6dof.tiltGain = s.gyroTiltGain end
    if s.gyroMoveDamping ~= nil then gyro6dof.moveDamping = s.gyroMoveDamping end
    if s.gyroMoveDeadzone ~= nil then gyro6dof.moveDeadzone = s.gyroMoveDeadzone end
    if s.gyroVerticalAssist ~= nil then gyro6dof.verticalAssist = s.gyroVerticalAssist end
    if s.gyroStrength ~= nil then gyroSensitivity = s.gyroStrength end
    if s.verticalSpeedMult ~= nil then droneVertMult = s.verticalSpeedMult end
    if s.droneDeadzone ~= nil then droneDeadzone = s.droneDeadzone end
    if s.droneRollRate ~= nil then droneRollRate = s.droneRollRate end
    if s.dronePitchRate ~= nil then dronePitchRate = s.dronePitchRate end
    if s.droneYawRate ~= nil then droneYawRate = s.droneYawRate end
    if s.droneRollExpo ~= nil then droneRollExpo = s.droneRollExpo end
    if s.dronePitchExpo ~= nil then dronePitchExpo = s.dronePitchExpo end
    if s.droneYawExpo ~= nil then droneYawExpo = s.droneYawExpo end
    if s.droneRollSuper ~= nil then droneRollSuper = s.droneRollSuper end
    if s.dronePitchSuper ~= nil then dronePitchSuper = s.dronePitchSuper end
    if s.droneYawSuper ~= nil then droneYawSuper = s.droneYawSuper end
    if s.droneRateType ~= nil then droneRateType = s.droneRateType end
    if s.droneActualCenter ~= nil then droneActualCenter = s.droneActualCenter end
    if s.droneActualMaxRate ~= nil then droneActualMaxRate = s.droneActualMaxRate end
    if s.droneActualExpo ~= nil then droneActualExpo = s.droneActualExpo end
    if s.droneAngleYawCoord ~= nil then droneAngleYawCoord = s.droneAngleYawCoord end
    if s.droneMoiPitch ~= nil then droneMoiPitch = s.droneMoiPitch end
    if s.droneMoiRoll ~= nil then droneMoiRoll = s.droneMoiRoll end
    if s.droneMoiYaw ~= nil then droneMoiYaw = s.droneMoiYaw end
    if s.droneDragForward ~= nil then droneDragForward = s.droneDragForward end
    if s.droneDragSideways ~= nil then droneDragSideways = s.droneDragSideways end
    if s.droneDragVertical ~= nil then droneDragVertical = s.droneDragVertical end
    if s.droneMotorSpinUp ~= nil then droneMotorSpinUp = s.droneMotorSpinUp end
    if s.droneMotorSpinDown ~= nil then droneMotorSpinDown = s.droneMotorSpinDown end
    if s.dronePropwashStrength ~= nil then dronePropwashStrength = s.dronePropwashStrength end
    if s.dronePropwashZone ~= nil then dronePropwashZone = s.dronePropwashZone end
    if s.droneGroundEffectHeight ~= nil then droneGroundEffectHeight = s.droneGroundEffectHeight end
    if s.droneGroundEffectStrength ~= nil then droneGroundEffectStrength = s.droneGroundEffectStrength end
    if s.droneRateResponse ~= nil then droneRateResponse = s.droneRateResponse end
    if s.droneAngularDamping ~= nil then droneAngularDamping = s.droneAngularDamping end
    if s.droneThrottleMid ~= nil then droneThrottleMid = s.droneThrottleMid end
    if s.droneThrottleExpo ~= nil then droneThrottleExpo = s.droneThrottleExpo end
    if s.droneThrustResponse ~= nil then droneThrustResponse = s.droneThrustResponse end
    if s.droneThrottlePower ~= nil then droneThrottlePower = s.droneThrottlePower end
    if s.droneCameraTilt ~= nil then droneCameraTilt = s.droneCameraTilt end
    if s.droneFullRotation ~= nil then droneFullRotation = s.droneFullRotation end
    if s.droneGravity ~= nil then droneGravity = s.droneGravity end
    if s.droneHoverThrottle ~= nil then droneHoverThrottle = s.droneHoverThrottle end
    if s.droneDrag ~= nil then droneDrag = s.droneDrag end
    if s.droneQuadDrag ~= nil then droneQuadDrag = s.droneQuadDrag end
    if s.droneInertia ~= nil then droneInertia = s.droneInertia end
    if s.droneMass ~= nil then droneMass = s.droneMass end
    if s.droneFlightMode ~= nil then droneFlightMode = s.droneFlightMode end
    if s.droneAngleMaxTilt ~= nil then droneAngleMaxTilt = s.droneAngleMaxTilt end
    if s.droneAngleLevelStrength ~= nil then droneAngleLevelStrength = s.droneAngleLevelStrength end
end

function saveModeSettings(mode)
    local s = modeSettings[mode]
    s.speed           = speed
    s.sensitivity     = sensitivity
    s.posSmooth       = posSmooth
    s.rotSmooth       = rotSmooth
    s.fovSmooth       = fovSmooth
    s.zoomStep        = zoomStep
    s.pitchClamp      = pitchClamp
    s.boostMultiplier = boostMultiplier
    s.slowMultiplier  = slowMultiplier
    if mode ~= "Drone" then s.rollSpeed = rollSpeed end
    if mode == "Gyroscope" then
        s.gyroUrl = gyroUrl
        s.gyroSensitivity = gyroSensitivity
        s.gyroSmoothness = gyroSmoothness
        s.gyroDeadzone = gyroDeadzone
        s.gyroPollRate = gyroPollRate
        s.gyroMoveGain = gyro6dof.moveGain
        s.gyroTiltGain = gyro6dof.tiltGain
        s.gyroMoveDamping = gyro6dof.moveDamping
        s.gyroMoveDeadzone = gyro6dof.moveDeadzone
        s.gyroVerticalAssist = gyro6dof.verticalAssist
    end
    if mode == "Normal" then
        s.orbitSpinSpeed = orbitSpinSpeed
        s.orbitRadius = orbitRadius
    end
    if mode == "Drone" then
        s.verticalSpeedMult = droneVertMult
        s.droneDeadzone = droneDeadzone
        s.droneRollRate = droneRollRate
        s.dronePitchRate = dronePitchRate
        s.droneYawRate = droneYawRate
        s.droneRollExpo = droneRollExpo
        s.dronePitchExpo = dronePitchExpo
        s.droneYawExpo = droneYawExpo
        s.droneRollSuper = droneRollSuper
        s.dronePitchSuper = dronePitchSuper
        s.droneYawSuper = droneYawSuper
        s.droneRateType = droneRateType
        s.droneActualCenter = droneActualCenter
        s.droneActualMaxRate = droneActualMaxRate
        s.droneActualExpo = droneActualExpo
        s.droneAngleYawCoord = droneAngleYawCoord
        s.droneMoiPitch = droneMoiPitch
        s.droneMoiRoll = droneMoiRoll
        s.droneMoiYaw = droneMoiYaw
        s.droneDragForward = droneDragForward
        s.droneDragSideways = droneDragSideways
        s.droneDragVertical = droneDragVertical
        s.droneMotorSpinUp = droneMotorSpinUp
        s.droneMotorSpinDown = droneMotorSpinDown
        s.dronePropwashStrength = dronePropwashStrength
        s.dronePropwashZone = dronePropwashZone
        s.droneGroundEffectHeight = droneGroundEffectHeight
        s.droneGroundEffectStrength = droneGroundEffectStrength
        s.droneRateResponse = droneRateResponse
        s.droneAngularDamping = droneAngularDamping
        s.droneThrottleMid = droneThrottleMid
        s.droneThrottleExpo = droneThrottleExpo
        s.droneThrustResponse = droneThrustResponse
        s.droneThrottlePower = droneThrottlePower
        s.droneCameraTilt = droneCameraTilt
        s.droneFullRotation = droneFullRotation
        s.droneGravity = droneGravity
        s.droneHoverThrottle = droneHoverThrottle
        s.droneDrag = droneDrag
        s.droneQuadDrag = droneQuadDrag
        s.droneInertia = droneInertia
        s.droneMass = droneMass
        s.droneFlightMode = droneFlightMode
        s.droneAngleMaxTilt = droneAngleMaxTilt
        s.droneAngleLevelStrength = droneAngleLevelStrength
        s.droneAngleYawCoord = droneAngleYawCoord
    end
end

function setMode(mode)
    if mode == currentMode then return end
    saveModeSettings(currentMode)
    if currentMode == "Gyroscope" or mode == "Gyroscope" then
        resetGyroSpatialState()
    end
    currentMode = mode
    if mode == "Drone" then
        roll = 0
    elseif mode == "Gyroscope" then
        rollTarget = roll
    end
    droneVelocity = Vector3.zero
    droneThrottleState = 0
    droneOrient = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll)
    droneAngVel = Vector3.zero
    resetDronePhysicsState()
    dronePropwashPhase = 0
    applyModeSettings(mode)
end

function resetAllSettings()
    -- Reset to mode defaults
    modeSettings.Normal = {
        speed=15, sensitivity=0.15, posSmooth=10, rotSmooth=12, fovSmooth=12,
        zoomStep=3, pitchClamp=math.rad(85), rollSpeed=math.rad(80),
        boostMultiplier=3, slowMultiplier=0.25,
        orbitSpinSpeed = math.rad(90),
        orbitRadius = CONFIG.orbitDefaultDistance,
    }
    modeSettings.Drone = makeDefaultDroneModeSettings()
    modeSettings.Gyroscope = {
        speed=12, sensitivity=0.15, posSmooth=12, rotSmooth=14, fovSmooth=12,
        zoomStep=3, pitchClamp=math.rad(85), rollSpeed=math.rad(80),
        boostMultiplier=3, slowMultiplier=0.25,
        gyroUrl=CONFIG.gyroUrl,
        gyroSensitivity=CONFIG.gyroSensitivity,
        gyroSmoothness=CONFIG.gyroSmoothness,
        gyroDeadzone=CONFIG.gyroDeadzone,
        gyroPollRate=CONFIG.gyroPollRate,
        gyroMoveGain=CONFIG.gyroMoveGain,
        gyroTiltGain=CONFIG.gyroTiltGain,
        gyroMoveDamping=CONFIG.gyroMoveDamping,
        gyroMoveDeadzone=CONFIG.gyroMoveDeadzone,
        gyroVerticalAssist=CONFIG.gyroVerticalAssist,
    }
    applyModeSettings(currentMode)
    setFovValue(CONFIG.defaultFov)
    resetDofSettings()
    orbitSpinSpeed = math.rad(90)
    orbitRadius = CONFIG.orbitDefaultDistance
    roll = 0
    rollTarget = 0
    droneVelocity = Vector3.zero
    droneThrottleState = 0
    droneOrient = nil
    droneAngVel = Vector3.zero
    resetDronePhysicsState()
    dronePropwashPhase = 0
    orbitEnabled = false
    orbitTarget = nil
    orbitTargetLabel = "None"
    setOrbitSelectorMode(CONFIG.orbitSelectorDefault)
    setControlsEnabled(true)
    if freecam then
        setCursorUnlocked(false)
        if uiHidden then
            setUiHidden(false)
        end
        if cam then
            cam.FieldOfView = CONFIG.defaultFov
        end
    end
    setPanelVisible(true)
    refreshUiText()
end

--// SLIDER VISUAL
function updateSliderVisual(row, rawValue)
    if not row then return end
    local t = 0
    if row.max > row.min then
        t = math.clamp((rawValue - row.min) / (row.max - row.min), 0, 1)
    end
    row.fill.Size = UDim2.new(t, 0, 1, 0)
    row.knob.Position = UDim2.new(t, -6, 0.5, -6)
    if not row.box:IsFocused() then
        row.box.Text = row.format(rawValue)
    end
end

function refreshUiText()
    if not uiRefs.status then return end
    local orbitState = orbitEnabled and "ON" or "OFF"
    local orbitTargetShort = shortenLabel(orbitTargetLabel, 18)
    local orbitSelectorLabel = orbitSelectorMode
    local dofState = dofEnabled and "ON" or "OFF"
    local dofModeLabel = dofFocusMode == "Auto"
        and string.format("AUTO %.1f/s", dofAutoFocusSpeed)
        or "MANUAL"
    uiRefs.status.Text = string.format(
        "FREECAM: %s | CURSOR: %s | UI: %s | CTRL: %s | DOF: %s/%s | ORBIT: %s | MODE: %s%s",
        freecam and "ON" or "OFF",
        cursorUnlocked and "UNLOCK" or "LOCK",
        uiHidden and "HIDDEN" or "VISIBLE",
        controlsEnabled and "ON" or "OFF",
        dofState,
        dofModeLabel,
        orbitState,
        currentMode:upper(),
        currentMode == "Drone" and (" ["..droneFlightMode:upper().."]") or ""
    )
    local speedLabel = "Speed"
    local speedValue = string.format("%d", math.floor(speed + 0.5))
    if currentMode == "Drone" then
        speedLabel = "TWR"
        speedValue = string.format("%.2f", speed)
    end
    local lookLabel = "Sens"
    local lookValue = string.format("%.2f", sensitivity)
    if currentMode == "Gyroscope" then
        lookLabel = "Gyro"
        lookValue = string.format("%s %.0fHz", shortenLabel(gyroLastStatus, 28), gyroPollRate)
    end
    uiRefs.stats.Text = string.format("%s: %s | FOV: %.1f | Roll: %.1f deg | %s: %s | Orbit: %s (%s) | Sel: %s",
        speedLabel,
        speedValue,
        cam.FieldOfView,
        math.deg(roll),
        lookLabel,
        lookValue,
        orbitState,
        orbitTargetShort,
        orbitSelectorLabel
    )
    uiRefs.freecamBtn.Text = freecam and "Disable Freecam" or "Enable Freecam"
    uiRefs.cursorBtn.Text = cursorUnlocked and "Lock Cursor" or "Unlock Cursor"
    uiRefs.uiBtn.Text = uiHidden and "Show UI" or "Hide UI"
    if uiRefs.orbitToggleBtn then
        uiRefs.orbitToggleBtn.Text = orbitEnabled and "Orbit Off" or "Orbit On"
    end
    if uiRefs.orbitSelectorBtn then
        uiRefs.orbitSelectorBtn.Text = "Selector " .. orbitSelectorLabel
    end
    if uiRefs.controlsBtn then
        uiRefs.controlsBtn.Text = controlsEnabled and "Controls Lock" or "Controls Unlock"
    end
    if uiRefs.dofToggleBtn then
        uiRefs.dofToggleBtn.Text = dofEnabled and "DOF Off" or "DOF On"
    end
    if uiRefs.dofFocusModeBtn then
        uiRefs.dofFocusModeBtn.Text = dofFocusMode == "Auto" and "Focus Manual" or "Focus Auto"
    end
    if uiRefs.stickOverlayBtn then
        uiRefs.stickOverlayBtn.Text = stickOverlayVisible and "Stick Overlay On" or "Stick Overlay Off"
    end
    if uiRefs.gyroInfoLabel then
        local gyroUrlShort = shortenLabel(gyroUrl, 54)
        local gyroSourceLabel = gyroResolvedLabel
            or (gyro6dof.resolvedPlan and gyro6dof.resolvedPlan.label)
            or "HTTP sensor"
        local moveLabel = gyro6dof.sample.hasLinearAccel and "linear accel + tilt"
            or (gyro6dof.sample.hasAccel and "accel-derived + tilt")
            or "tilt assist"
        uiRefs.gyroInfoLabel.Text = string.format(
            "  GYROSCOPE MODE - kamera ikut orientasi HP, gerak dari tilt + akselerasi.\n  Status: %s | Source: %s | Move: %s | URL: %s",
            gyroLastStatus,
            gyroSourceLabel,
            moveLabel,
            gyroUrlShort
        )
    end
    updateDroneFlightModeUI()
    -- Update mode buttons
    if uiRefs.modeBtns then
        for mName, btn in pairs(uiRefs.modeBtns) do
            if mName == currentMode then
                btn.BackgroundColor3 = uiRefs.modeColors[mName]
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(36, 41, 50)
                btn.TextColor3 = Color3.fromRGB(180, 190, 205)
            end
        end
    end
    -- Update settings tab buttons
    if uiRefs.settingTabBtns then
        for tName, btn in pairs(uiRefs.settingTabBtns) do
            if tName == uiRefs.activeSettingsTab then
                btn.BackgroundColor3 = uiRefs.modeColors[tName]
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 34, 43)
                btn.TextColor3 = Color3.fromRGB(160, 172, 190)
            end
        end
    end
    -- Normal tab sliders
    local nt = uiRefs.normalTabRows
    if nt then
        if nt.speed     then updateSliderVisual(nt.speed,     speed) end
        if nt.rollSpeed then updateSliderVisual(nt.rollSpeed, math.deg(rollSpeed)) end
        if nt.orbitSpeed then updateSliderVisual(nt.orbitSpeed, math.deg(modeSettings.Normal.orbitSpinSpeed or orbitSpinSpeed)) end
        if nt.orbitRadius then updateSliderVisual(nt.orbitRadius, modeSettings.Normal.orbitRadius or orbitRadius) end
        if nt.fov       then updateSliderVisual(nt.fov,       targetFov) end
        if nt.sens      then updateSliderVisual(nt.sens,      sensitivity) end
        if nt.posSmooth then updateSliderVisual(nt.posSmooth, posSmooth) end
        if nt.rotSmooth then updateSliderVisual(nt.rotSmooth, rotSmooth) end
        if nt.fovSmooth then updateSliderVisual(nt.fovSmooth, fovSmooth) end
        if nt.zoomStep  then updateSliderVisual(nt.zoomStep,  zoomStep) end
        if nt.pitchClamp then updateSliderVisual(nt.pitchClamp, math.deg(pitchClamp)) end
        if nt.boost     then updateSliderVisual(nt.boost,     boostMultiplier) end
        if nt.slow      then updateSliderVisual(nt.slow,      slowMultiplier) end
        if nt.dofNear   then updateSliderVisual(nt.dofNear,   dofNearIntensity) end
        if nt.dofFar    then updateSliderVisual(nt.dofFar,    dofFarIntensity) end
        if nt.dofFocus  then updateSliderVisual(nt.dofFocus,  dofFocusDistance) end
        if nt.dofRadius then updateSliderVisual(nt.dofRadius, dofInFocusRadius) end
        if nt.dofAutoSpeed then updateSliderVisual(nt.dofAutoSpeed, dofAutoFocusSpeed) end
    end
    -- Drone tab sliders
    local dt = uiRefs.droneTabRows
    if dt then
        if dt.speed     then updateSliderVisual(dt.speed,     speed) end
        if dt.rollRate  then updateSliderVisual(dt.rollRate,  droneRollRate) end
        if dt.pitchRate then updateSliderVisual(dt.pitchRate, dronePitchRate) end
        if dt.yawRate   then updateSliderVisual(dt.yawRate,   droneYawRate) end
        if dt.rateType  then updateSliderVisual(dt.rateType,  droneRateType == "Betaflight" and 1 or 0) end
        if dt.bfCenter  then updateSliderVisual(dt.bfCenter,  droneActualCenter) end
        if dt.bfMax     then updateSliderVisual(dt.bfMax,     droneActualMaxRate) end
        if dt.bfExpo    then updateSliderVisual(dt.bfExpo,    droneActualExpo) end
        if dt.rollExpo  then updateSliderVisual(dt.rollExpo,  droneRollExpo) end
        if dt.pitchExpo then updateSliderVisual(dt.pitchExpo, dronePitchExpo) end
        if dt.yawExpo   then updateSliderVisual(dt.yawExpo,   droneYawExpo) end
        if dt.rollSuper then updateSliderVisual(dt.rollSuper, droneRollSuper) end
        if dt.pitchSuper then updateSliderVisual(dt.pitchSuper, dronePitchSuper) end
        if dt.yawSuper  then updateSliderVisual(dt.yawSuper,  droneYawSuper) end
        if dt.rateResp then updateSliderVisual(dt.rateResp, droneRateResponse) end
        if dt.angDamp then updateSliderVisual(dt.angDamp, droneAngularDamping) end
        if dt.deadzone  then updateSliderVisual(dt.deadzone,  droneDeadzone) end
        if dt.thrustMult then updateSliderVisual(dt.thrustMult, droneVertMult) end
        if dt.hoverThrottle then updateSliderVisual(dt.hoverThrottle, droneHoverThrottle) end
        if dt.throttleMid then updateSliderVisual(dt.throttleMid, droneThrottleMid) end
        if dt.throttleExpo then updateSliderVisual(dt.throttleExpo, droneThrottleExpo) end
        if dt.throttlePower then updateSliderVisual(dt.throttlePower, droneThrottlePower) end
        if dt.thrustResponse then updateSliderVisual(dt.thrustResponse, droneThrustResponse) end
        if dt.gravity  then updateSliderVisual(dt.gravity,  droneGravity) end
        if dt.drag     then updateSliderVisual(dt.drag,     droneDrag) end
        if dt.quadDrag then updateSliderVisual(dt.quadDrag, droneQuadDrag) end
        if dt.inertia  then updateSliderVisual(dt.inertia,  droneInertia) end
        if dt.mass     then updateSliderVisual(dt.mass,     droneMass) end
        if dt.fov       then updateSliderVisual(dt.fov,       targetFov) end
        if dt.fovSmooth then updateSliderVisual(dt.fovSmooth, fovSmooth) end
        if dt.zoomStep  then updateSliderVisual(dt.zoomStep,  zoomStep) end
        if dt.cameraTilt then updateSliderVisual(dt.cameraTilt, droneCameraTilt) end
        if dt.pitchClamp then updateSliderVisual(dt.pitchClamp, math.deg(pitchClamp)) end
        if dt.posSmooth then updateSliderVisual(dt.posSmooth, posSmooth) end
        if dt.rotSmooth then updateSliderVisual(dt.rotSmooth, rotSmooth) end
        if dt.moiPitch then updateSliderVisual(dt.moiPitch, droneMoiPitch) end
        if dt.moiRoll then updateSliderVisual(dt.moiRoll, droneMoiRoll) end
        if dt.moiYaw then updateSliderVisual(dt.moiYaw, droneMoiYaw) end
        if dt.dragForward then updateSliderVisual(dt.dragForward, droneDragForward) end
        if dt.dragSideways then updateSliderVisual(dt.dragSideways, droneDragSideways) end
        if dt.dragVertical then updateSliderVisual(dt.dragVertical, droneDragVertical) end
        if dt.motorSpinUp then updateSliderVisual(dt.motorSpinUp, droneMotorSpinUp) end
        if dt.motorSpinDown then updateSliderVisual(dt.motorSpinDown, droneMotorSpinDown) end
        if dt.propwashStrength then updateSliderVisual(dt.propwashStrength, dronePropwashStrength) end
        if dt.propwashZone then updateSliderVisual(dt.propwashZone, dronePropwashZone) end
        if dt.groundEffectHeight then updateSliderVisual(dt.groundEffectHeight, droneGroundEffectHeight) end
        if dt.groundEffectStrength then updateSliderVisual(dt.groundEffectStrength, droneGroundEffectStrength) end

        -- Angle mode sliders
        local at = dt._angleTabRows
        if at then
            if at.angleMaxTilt       then updateSliderVisual(at.angleMaxTilt,       droneAngleMaxTilt) end
            if at.angleLevelStrength then updateSliderVisual(at.angleLevelStrength, droneAngleLevelStrength) end
            if at.angleYawCoord      then updateSliderVisual(at.angleYawCoord,      droneAngleYawCoord) end
        end
        -- Flight mode buttons
        if uiRefs.updateFlightModeBtns then
            uiRefs.updateFlightModeBtns()
        end
        -- Show/hide angle section
        if uiRefs.droneAngleSection then
            uiRefs.droneAngleSection.Visible = (droneFlightMode == "Angle")
        end
    end
    -- Gyroscope tab sliders
    local at = uiRefs.gyroscopeTabRows
    if at then
        if at.speed        then updateSliderVisual(at.speed,        speed) end
        if at.fov          then updateSliderVisual(at.fov,          targetFov) end
        if at.sens         then updateSliderVisual(at.sens,         sensitivity) end
        if at.rotSmooth    then updateSliderVisual(at.rotSmooth,    rotSmooth) end
        if at.fovSmooth    then updateSliderVisual(at.fovSmooth,    fovSmooth) end
        if at.zoomStep     then updateSliderVisual(at.zoomStep,     zoomStep) end
        if at.rollSpeed    then updateSliderVisual(at.rollSpeed,    math.deg(rollSpeed)) end
        if at.boost        then updateSliderVisual(at.boost,        boostMultiplier) end
        if at.slow         then updateSliderVisual(at.slow,         slowMultiplier) end
        if at.gyroSensitivity then updateSliderVisual(at.gyroSensitivity, gyroSensitivity) end
        if at.gyroSmoothness then updateSliderVisual(at.gyroSmoothness, gyroSmoothness) end
        if at.gyroDeadzone then updateSliderVisual(at.gyroDeadzone, gyroDeadzone) end
        if at.gyroPollRate then updateSliderVisual(at.gyroPollRate, gyroPollRate) end
        if at.gyroMoveGain then updateSliderVisual(at.gyroMoveGain, gyro6dof.moveGain) end
        if at.gyroTiltGain then updateSliderVisual(at.gyroTiltGain, gyro6dof.tiltGain) end
        if at.gyroMoveDamping then updateSliderVisual(at.gyroMoveDamping, gyro6dof.moveDamping) end
        if at.gyroMoveDeadzone then updateSliderVisual(at.gyroMoveDeadzone, gyro6dof.moveDeadzone) end
        if at.gyroVerticalAssist then updateSliderVisual(at.gyroVerticalAssist, gyro6dof.verticalAssist) end
    end
end

--// UI
function createControlUI()
    local old = playerGui:FindFirstChild("FreecamControlUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FreecamControlUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.fromOffset(panelWidth, panelHeight)
    panel.Position = UDim2.fromOffset(18, 18)
    panel.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Draggable = false
    panel.Parent = gui
    panel.Visible = panelVisible

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    panelStroke.Thickness = 1
    panelStroke.Color = Color3.fromRGB(72, 80, 94)
    panelStroke.Transparency = 0.2
    panelStroke.Parent = panel

    local panelGradient = Instance.new("UIGradient")
    panelGradient.Rotation = 90
    panelGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 34, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 19, 24)),
    })
    panelGradient.Parent = panel

    -- Stick Input Overlay
    local stickOverlay = Instance.new("Frame")
    stickOverlay.Name = "StickOverlay"
    stickOverlay.Size = UDim2.fromOffset(168, 72)
    stickOverlay.AnchorPoint = Vector2.new(0.5, 1)
    stickOverlay.Position = UDim2.new(0.5, 0, 1, -12)
    stickOverlay.BackgroundTransparency = 1
    stickOverlay.Parent = gui
    stickOverlay.Visible = stickOverlayVisible

    local stickLayout = Instance.new("UIListLayout")
    stickLayout.FillDirection = Enum.FillDirection.Horizontal
    stickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    stickLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    stickLayout.Padding = UDim.new(0, 12)
    stickLayout.Parent = stickOverlay

    local function makeStickBox(name)
        local box = Instance.new("Frame")
        box.Name = name
        box.Size = UDim2.fromOffset(72, 72)
        box.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
        box.BackgroundTransparency = 0.25
        box.BorderSizePixel = 0
        box.Parent = stickOverlay
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(110, 120, 135)
        stroke.Transparency = 0.55
        stroke.Parent = box

        local vLine = Instance.new("Frame")
        vLine.Name = "CenterV"
        vLine.Size = UDim2.new(0, 1, 1, -10)
        vLine.Position = UDim2.new(0.5, 0, 0, 5)
        vLine.BackgroundColor3 = Color3.fromRGB(140, 150, 165)
        vLine.BackgroundTransparency = 0.55
        vLine.BorderSizePixel = 0
        vLine.Parent = box

        local hLine = Instance.new("Frame")
        hLine.Name = "CenterH"
        hLine.Size = UDim2.new(1, -10, 0, 1)
        hLine.Position = UDim2.new(0, 5, 0.5, 0)
        hLine.BackgroundColor3 = Color3.fromRGB(140, 150, 165)
        hLine.BackgroundTransparency = 0.55
        hLine.BorderSizePixel = 0
        hLine.Parent = box

        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.Size = UDim2.fromOffset(10, 10)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        dot.BackgroundTransparency = 0.1
        dot.BorderSizePixel = 0
        dot.Parent = box
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        return box, dot
    end

    local leftBox, leftDot = makeStickBox("LeftStick")
    local rightBox, rightDot = makeStickBox("RightStick")

    -- Header bar
    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, 0, 0, 36)
    headerBar.Position = UDim2.fromOffset(0, 0)
    headerBar.BackgroundColor3 = Color3.fromRGB(28, 32, 39)
    headerBar.BorderSizePixel = 0
    headerBar.Parent = panel

    local headerBarCorner = Instance.new("UICorner")
    headerBarCorner.CornerRadius = UDim.new(0, 12)
    headerBarCorner.Parent = headerBar

    local headerBarMask = Instance.new("Frame")
    headerBarMask.Size = UDim2.new(1, 0, 0, 18)
    headerBarMask.Position = UDim2.fromOffset(0, 18)
    headerBarMask.BackgroundColor3 = Color3.fromRGB(28, 32, 39)
    headerBarMask.BorderSizePixel = 0
    headerBarMask.Parent = headerBar

    local function clampPanelToViewport()
        local currentCam = workspace.CurrentCamera
        if not currentCam then return end
        local vp = currentCam.ViewportSize
        local panelSize = panel.AbsoluteSize
        local minVisibleX = 140
        local minVisibleY = 28
        local minX = -panelSize.X + minVisibleX
        local maxX = vp.X - minVisibleX
        local minY = 0
        local maxY = vp.Y - minVisibleY
        if maxX < minX then maxX = minX end
        if maxY < minY then maxY = minY end
        local x = math.clamp(panel.Position.X.Offset, minX, maxX)
        local y = math.clamp(panel.Position.Y.Offset, minY, maxY)
        panel.Position = UDim2.fromOffset(x, y)
    end

    do
        local currentCam = workspace.CurrentCamera
        if currentCam then
            local startX = currentCam.ViewportSize.X - panel.Size.X.Offset - 18
            panel.Position = UDim2.fromOffset(startX, 18)
            clampPanelToViewport()
            table.insert(connections, currentCam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                if scriptKilled then return end
                clampPanelToViewport()
            end))
        end
    end

    local headerDragZone = Instance.new("Frame")
    headerDragZone.Name = "HeaderDragZone"
    headerDragZone.Size = UDim2.new(1, -140, 0, 36)
    headerDragZone.Position = UDim2.fromOffset(0, 0)
    headerDragZone.BackgroundTransparency = 1
    headerDragZone.Active = true
    headerDragZone.Draggable = false
    headerDragZone.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -140, 0, 28)
    title.Position = UDim2.fromOffset(10, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(236, 238, 244)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Ultimate Freecam"
    title.Parent = panel

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.fromOffset(58, 24)
    minimizeBtn.Position = UDim2.new(1, -122, 0, 6)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(52, 61, 74)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 12
    minimizeBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
    minimizeBtn.Text = "Min"
    minimizeBtn.Parent = panel
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 7)

    local exitBtn = Instance.new("TextButton")
    exitBtn.Size = UDim2.fromOffset(58, 24)
    exitBtn.Position = UDim2.new(1, -60, 0, 6)
    exitBtn.BackgroundColor3 = Color3.fromRGB(150, 57, 57)
    exitBtn.BorderSizePixel = 0
    exitBtn.Font = Enum.Font.GothamBold
    exitBtn.TextSize = 12
    exitBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
    exitBtn.Text = "Exit"
    exitBtn.Parent = panel
    Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0, 7)

    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(18, 18)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.Position = UDim2.new(1, -4, 1, -4)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(56, 64, 76)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Active = true
    resizeHandle.ZIndex = 5
    resizeHandle.Parent = panel
    Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 6)

    local resizeGlyph = Instance.new("TextLabel")
    resizeGlyph.Size = UDim2.new(1, 0, 1, 0)
    resizeGlyph.BackgroundTransparency = 1
    resizeGlyph.Font = Enum.Font.Code
    resizeGlyph.TextSize = 14
    resizeGlyph.TextColor3 = Color3.fromRGB(220, 228, 238)
    resizeGlyph.Text = "+"
    resizeGlyph.Parent = resizeHandle

    -- Content ScrollingFrame
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 1, -46)
    content.Position = UDim2.fromOffset(8, 40)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.CanvasSize = UDim2.fromOffset(0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 7
    content.ScrollBarImageColor3 = Color3.fromRGB(120, 130, 145)
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.Parent = panel

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.Parent = content

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingLeft = UDim.new(0, 4)
    contentPad.PaddingRight = UDim.new(0, 4)
    contentPad.PaddingTop = UDim.new(0, 4)
    contentPad.PaddingBottom = UDim.new(0, 8)
    contentPad.Parent = content

    -- Status bar
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 26)
    status.LayoutOrder = 1
    status.BackgroundColor3 = Color3.fromRGB(28, 33, 41)
    status.BorderSizePixel = 0
    status.Font = Enum.Font.Code
    status.TextSize = 11
    status.TextColor3 = Color3.fromRGB(218, 224, 235)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTruncate = Enum.TextTruncate.AtEnd
    status.Parent = content
    Instance.new("UICorner", status).CornerRadius = UDim.new(0, 7)
    do
        local sp = Instance.new("UIPadding")
        sp.PaddingLeft = UDim.new(0, 8)
        sp.PaddingRight = UDim.new(0, 4)
        sp.Parent = status
    end

    local stats = Instance.new("TextLabel")
    stats.Size = UDim2.new(1, 0, 0, 26)
    stats.LayoutOrder = 2
    stats.BackgroundColor3 = Color3.fromRGB(28, 33, 41)
    stats.BorderSizePixel = 0
    stats.Font = Enum.Font.Code
    stats.TextSize = 11
    stats.TextColor3 = Color3.fromRGB(205, 212, 226)
    stats.TextXAlignment = Enum.TextXAlignment.Left
    stats.TextTruncate = Enum.TextTruncate.AtEnd
    stats.Parent = content
    Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 7)
    do
        local sp = Instance.new("UIPadding")
        sp.PaddingLeft = UDim.new(0, 8)
        sp.PaddingRight = UDim.new(0, 4)
        sp.Parent = stats
    end

    ---- MODE SELECTOR ----
    local modeColors = {
        Normal = Color3.fromRGB(58, 118, 210),
        Drone  = Color3.fromRGB(48, 150, 100),
        Gyroscope = Color3.fromRGB(148, 72, 190),
    }

    local modeSectionLabel = Instance.new("TextLabel")
    modeSectionLabel.Size = UDim2.new(1, 0, 0, 14)
    modeSectionLabel.LayoutOrder = 3
    modeSectionLabel.BackgroundTransparency = 1
    modeSectionLabel.Font = Enum.Font.GothamSemibold
    modeSectionLabel.TextSize = 10
    modeSectionLabel.TextColor3 = Color3.fromRGB(130, 145, 165)
    modeSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeSectionLabel.Text = "  CAMERA MODE"
    modeSectionLabel.Parent = content

    local modeSelectorRow = Instance.new("Frame")
    modeSelectorRow.Size = UDim2.new(1, 0, 0, 36)
    modeSelectorRow.LayoutOrder = 4
    modeSelectorRow.BackgroundColor3 = Color3.fromRGB(22, 26, 33)
    modeSelectorRow.BorderSizePixel = 0
    modeSelectorRow.Parent = content
    Instance.new("UICorner", modeSelectorRow).CornerRadius = UDim.new(0, 9)

    local modeRowLayout = Instance.new("UIListLayout")
    modeRowLayout.FillDirection = Enum.FillDirection.Horizontal
    modeRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    modeRowLayout.Padding = UDim.new(0, 4)
    modeRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    modeRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    modeRowLayout.Parent = modeSelectorRow

    local modeRowPad = Instance.new("UIPadding")
    modeRowPad.PaddingLeft = UDim.new(0, 4)
    modeRowPad.PaddingRight = UDim.new(0, 4)
    modeRowPad.PaddingTop = UDim.new(0, 4)
    modeRowPad.PaddingBottom = UDim.new(0, 4)
    modeRowPad.Parent = modeSelectorRow

    local modeBtns = {}
    local modeOrder = {"Normal", "Drone", "Gyroscope"}
    local modeIcons = {Normal = "●", Drone = "◈", Gyroscope = "⟳"}

    local function updateModeButtonsLocal()
        for mName, btn in pairs(modeBtns) do
            if mName == currentMode then
                btn.BackgroundColor3 = modeColors[mName]
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(36, 41, 50)
                btn.TextColor3 = Color3.fromRGB(180, 190, 205)
            end
        end
    end


    for _, mName in ipairs(modeOrder) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.333, -4, 1, -8)
        btn.AutoButtonColor = false
        btn.BackgroundColor3 = Color3.fromRGB(36, 41, 50)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(180, 190, 205)
        btn.Text = modeIcons[mName] .. " " .. mName
        btn.LayoutOrder = _ 
        btn.Parent = modeSelectorRow
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local bStroke = Instance.new("UIStroke")
        bStroke.Thickness = 1
        bStroke.Color = modeColors[mName]
        bStroke.Transparency = 0.7
        bStroke.Parent = btn

        modeBtns[mName] = btn

        table.insert(connections, btn.MouseButton1Click:Connect(function()
            if scriptKilled then return end
            setMode(mName)
            updateModeButtonsLocal()
            refreshUiText()
        end))
    end
    updateModeButtonsLocal()

    ---- ACTIONS GRID ----
    local actionsSectionLabel = Instance.new("TextLabel")
    actionsSectionLabel.Size = UDim2.new(1, 0, 0, 14)
    actionsSectionLabel.LayoutOrder = 5
    actionsSectionLabel.BackgroundTransparency = 1
    actionsSectionLabel.Font = Enum.Font.GothamSemibold
    actionsSectionLabel.TextSize = 10
    actionsSectionLabel.TextColor3 = Color3.fromRGB(130, 145, 165)
    actionsSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    actionsSectionLabel.Text = "  ACTIONS"
    actionsSectionLabel.Parent = content

    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, 0, 0, 0)
    grid.LayoutOrder = 6
    grid.AutomaticSize = Enum.AutomaticSize.Y
    grid.BackgroundColor3 = Color3.fromRGB(25, 29, 36)
    grid.BorderSizePixel = 0
    grid.Parent = content
    Instance.new("UICorner", grid).CornerRadius = UDim.new(0, 9)

    local layout = Instance.new("UIGridLayout")
    layout.CellPadding = UDim2.fromOffset(5, 5)
    layout.CellSize = UDim2.new(0.5, -8, 0, 30)
    layout.FillDirectionMaxCells = 2
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = grid

    local gridPad = Instance.new("UIPadding")
    gridPad.PaddingLeft = UDim.new(0, 6)
    gridPad.PaddingTop = UDim.new(0, 6)
    gridPad.PaddingRight = UDim.new(0, 6)
    gridPad.PaddingBottom = UDim.new(0, 6)
    gridPad.Parent = grid

    clearUiInteractionState()
    local minimized = false
    local normalSize = panel.Size

    local function setPanelSizeInternal(width, height)
        panelWidth = math.floor(math.clamp(width, CONFIG.panelMinWidth, CONFIG.panelMaxWidth))
        panelHeight = math.floor(math.clamp(height, CONFIG.panelMinHeight, CONFIG.panelMaxHeight))
        normalSize = UDim2.fromOffset(panelWidth, panelHeight)
        if minimized then
            panel.Size = UDim2.fromOffset(panelWidth, 34)
        else
            panel.Size = normalSize
        end
        clampPanelToViewport()
    end

    local function makeButton(text, callback, tone)
        local b = Instance.new("TextButton")
        b.AutoButtonColor = true
        b.BackgroundColor3 = tone or Color3.fromRGB(42, 49, 61)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(238, 241, 247)
        b.Text = text
        b.Parent = grid
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        local bStroke = Instance.new("UIStroke")
        bStroke.Thickness = 1
        bStroke.Color = Color3.fromRGB(73, 86, 104)
        bStroke.Transparency = 0.35
        bStroke.Parent = b
    table.insert(connections, b.MouseButton1Click:Connect(function()
        if scriptKilled then return end
        callback()
        if scriptKilled then return end
        refreshUiText()
    end))
        return b
    end

    local freecamBtn = makeButton("Enable Freecam", toggleFreecam, Color3.fromRGB(42, 79, 126))
    local cursorBtn = makeButton("Unlock Cursor", function()
        if freecam then setCursorUnlocked(not cursorUnlocked) end
    end, Color3.fromRGB(55, 64, 80))
    local uiBtn = makeButton("Hide UI", function()
        if freecam then setUiHidden(not uiHidden) end
    end, Color3.fromRGB(55, 64, 80))
    local stickOverlayBtn = makeButton("Stick Overlay", function()
        setStickOverlayVisible(not stickOverlayVisible)
    end, Color3.fromRGB(64, 70, 88))
    makeButton("Hide Panel", function() setPanelVisible(false) end, Color3.fromRGB(64, 60, 84))
    local controlsBtn = makeButton("Controls Lock", function()
        if freecam then setControlsEnabled(not controlsEnabled) end
    end, Color3.fromRGB(78, 63, 51))
    local orbitToggleBtn = makeButton("Orbit On", function()
        if freecam then setOrbitEnabled(not orbitEnabled) end
    end, Color3.fromRGB(60, 86, 92))
    makeButton("Orbit Pick",  function() if freecam then pickOrbitTarget() end end, Color3.fromRGB(60, 86, 92))
    local orbitSelectorBtn = makeButton("Selector Object", function()
        cycleOrbitSelectorMode(1)
    end, Color3.fromRGB(60, 78, 96))
    makeButton("Orbit Self",  function() if freecam then setOrbitTargetSelf() end end, Color3.fromRGB(60, 86, 92))
    makeButton("Orbit Clear", function() clearOrbitTarget() end, Color3.fromRGB(86, 62, 62))
    local dofToggleBtn = makeButton("DOF On", function() setDofEnabled(not dofEnabled) end, Color3.fromRGB(59, 76, 109))
    local dofFocusModeBtn = makeButton("Focus Auto", function() toggleDofFocusMode() end, Color3.fromRGB(59, 76, 109))
    makeButton("DOF Reset",     function() resetDofSettings() end, Color3.fromRGB(59, 76, 109))
    makeButton("Reset All",     function() resetAllSettings() end, Color3.fromRGB(120, 68, 52))
    makeButton("UI Size +",     function() setPanelSizeInternal(panelWidth + 40, panelHeight + 40) end, Color3.fromRGB(58, 74, 96))
    makeButton("UI Size -",     function() setPanelSizeInternal(panelWidth - 40, panelHeight - 40) end, Color3.fromRGB(58, 74, 96))
    makeButton("Portrait +90",  function() if freecam then rotatePortrait90() end end)
    makeButton("Roll Reset",    function() if freecam then roll = 0 end end)
    makeButton("FOV Reset",     function() if freecam then setFovValue(CONFIG.defaultFov) end end)
    makeButton("Speed Reset",   function() if freecam then setSpeedValue(modeSettings[currentMode].speed or CONFIG.baseSpeed) end end)

    --// SHARE POPUP -------------------------------------------------------
    -- Overlay gelap di atas seluruh panel
    local shareOverlay = Instance.new("Frame")
    shareOverlay.Name        = "ShareOverlay"
    shareOverlay.Size        = UDim2.new(1, 0, 1, 0)
    shareOverlay.Position    = UDim2.fromOffset(0, 0)
    shareOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shareOverlay.BackgroundTransparency = 0.35
    shareOverlay.BorderSizePixel = 0
    shareOverlay.ZIndex      = 20
    shareOverlay.Visible     = false
    shareOverlay.Active      = true
    shareOverlay.Parent      = gui

    -- Card di tengah overlay
    local shareCard = Instance.new("Frame")
    shareCard.Size          = UDim2.fromOffset(440, 272)
    shareCard.AnchorPoint   = Vector2.new(0.5, 0.5)
    shareCard.Position      = UDim2.new(0.5, 0, 0.5, 0)
    shareCard.BackgroundColor3 = Color3.fromRGB(20, 24, 31)
    shareCard.BorderSizePixel = 0
    shareCard.ZIndex        = 21
    shareCard.Parent        = shareOverlay
    Instance.new("UICorner", shareCard).CornerRadius = UDim.new(0, 14)
    do
        local s = Instance.new("UIStroke")
        s.Thickness  = 1.2
        s.Color      = Color3.fromRGB(75, 95, 120)
        s.Transparency = 0.15
        s.Parent     = shareCard
    end
    do
        local g = Instance.new("UIGradient")
        g.Rotation = 120
        g.Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 33, 44)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 19, 26)),
        })
        g.Parent = shareCard
    end

    -- Judul
    local shareTitle = Instance.new("TextLabel")
    shareTitle.Size            = UDim2.new(1, -16, 0, 28)
    shareTitle.Position        = UDim2.fromOffset(14, 12)
    shareTitle.BackgroundTransparency = 1
    shareTitle.Font            = Enum.Font.GothamBold
    shareTitle.TextSize        = 14
    shareTitle.TextColor3      = Color3.fromRGB(225, 232, 248)
    shareTitle.TextXAlignment  = Enum.TextXAlignment.Left
    shareTitle.Text            = "Share Settings"
    shareTitle.ZIndex          = 22
    shareTitle.Parent          = shareCard

    -- Keterangan
    local shareInfo = Instance.new("TextLabel")
    shareInfo.Size            = UDim2.new(1, -16, 0, 32)
    shareInfo.Position        = UDim2.fromOffset(14, 40)
    shareInfo.BackgroundTransparency = 1
    shareInfo.Font            = Enum.Font.Gotham
    shareInfo.TextSize        = 11
    shareInfo.TextColor3      = Color3.fromRGB(135, 152, 178)
    shareInfo.TextXAlignment  = Enum.TextXAlignment.Left
    shareInfo.TextWrapped     = true
    shareInfo.Text            = ""
    shareInfo.ZIndex          = 22
    shareInfo.Parent          = shareCard

    -- TextBox kode settingan
    local shareBox = Instance.new("TextBox")
    shareBox.Size             = UDim2.new(1, -28, 0, 88)
    shareBox.Position         = UDim2.fromOffset(14, 76)
    shareBox.BackgroundColor3 = Color3.fromRGB(12, 15, 20)
    shareBox.BorderSizePixel  = 0
    shareBox.Font             = Enum.Font.Code
    shareBox.TextSize         = 10
    shareBox.TextColor3       = Color3.fromRGB(165, 215, 140)
    shareBox.TextXAlignment   = Enum.TextXAlignment.Left
    shareBox.TextYAlignment   = Enum.TextYAlignment.Top
    shareBox.MultiLine        = true
    shareBox.ClearTextOnFocus = false
    shareBox.Text             = ""
    shareBox.ZIndex           = 22
    shareBox.Parent           = shareCard
    Instance.new("UICorner", shareBox).CornerRadius = UDim.new(0, 8)
    do
        local s = Instance.new("UIStroke")
        s.Thickness   = 1
        s.Color       = Color3.fromRGB(55, 80, 105)
        s.Transparency = 0.25
        s.Parent      = shareBox
    end
    do
        local p = Instance.new("UIPadding")
        p.PaddingLeft  = UDim.new(0, 7)
        p.PaddingTop   = UDim.new(0, 6)
        p.Parent       = shareBox
    end

    -- Status feedback
    local shareStatus = Instance.new("TextLabel")
    shareStatus.Size            = UDim2.new(1, -16, 0, 18)
    shareStatus.Position        = UDim2.fromOffset(14, 170)
    shareStatus.BackgroundTransparency = 1
    shareStatus.Font            = Enum.Font.Gotham
    shareStatus.TextSize        = 11
    shareStatus.TextColor3      = Color3.fromRGB(110, 200, 125)
    shareStatus.TextXAlignment  = Enum.TextXAlignment.Left
    shareStatus.Text            = ""
    shareStatus.ZIndex          = 22
    shareStatus.Parent          = shareCard

    -- Row tombol-tombol
    local shareBtnRow = Instance.new("Frame")
    shareBtnRow.Size              = UDim2.new(1, -28, 0, 34)
    shareBtnRow.Position          = UDim2.fromOffset(14, 194)
    shareBtnRow.BackgroundTransparency = 1
    shareBtnRow.ZIndex            = 22
    shareBtnRow.Parent            = shareCard
    do
        local l = Instance.new("UIListLayout")
        l.FillDirection   = Enum.FillDirection.Horizontal
        l.SortOrder       = Enum.SortOrder.LayoutOrder
        l.Padding         = UDim.new(0, 8)
        l.VerticalAlignment = Enum.VerticalAlignment.Center
        l.Parent          = shareBtnRow
    end

    local function makeShareBtn(text, color, order, cb)
        local b = Instance.new("TextButton")
        b.AutoButtonColor = true
        b.Size            = UDim2.fromOffset(130, 30)
        b.BackgroundColor3 = color
        b.BorderSizePixel = 0
        b.Font            = Enum.Font.GothamSemibold
        b.TextSize        = 11
        b.TextColor3      = Color3.fromRGB(238, 242, 250)
        b.Text            = text
        b.LayoutOrder     = order
        b.ZIndex          = 23
        b.Parent          = shareBtnRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        table.insert(connections, b.MouseButton1Click:Connect(function()
            if scriptKilled then return end
            cb()
        end))
        return b
    end

    local function setShareStatus(msg, isError)
        shareStatus.Text = msg
        shareStatus.TextColor3 = isError
            and Color3.fromRGB(225, 90, 80)
            or  Color3.fromRGB(100, 215, 128)
    end

    -- Tombol: Salin ke Clipboard
    makeShareBtn("Copy Clipboard", Color3.fromRGB(35, 88, 58), 1, function()
        local str = shareBox.Text
        if str == "" then
            setShareStatus("Tidak ada teks untuk disalin.", true)
            return
        end
        local clipOk = pcall(function() setclipboard(str) end)
        if clipOk then
            setShareStatus("Tersalin ke clipboard!", false)
        else
            -- Fallback: fokus & select agar user bisa Ctrl+C manual
            shareBox:CaptureFocus()
            setShareStatus("Pilih semua teks lalu tekan Ctrl+C untuk menyalin.", false)
        end
    end)

    -- Tombol: Terapkan settingan dari box
    makeShareBtn("Terapkan", Color3.fromRGB(45, 55, 105), 2, function()
        local ok, msg = applySettingsString(shareBox.Text)
        setShareStatus(msg, not ok)
    end)

    -- Tombol: Tutup popup
    makeShareBtn("Tutup", Color3.fromRGB(100, 38, 38), 3, function()
        shareOverlay.Visible = false
    end)

    -- Fungsi pembuka popup (dipanggil oleh kedua tombol di grid)
    local function showSharePopup(exportStr)
        setShareStatus("", false)
        if exportStr then
            shareTitle.Text = "Export Settings"
            shareInfo.Text  = "Salin teks ini dan bagikan ke orang lain. Mereka cukup klik 'Paste Settings' lalu tempel di sini."
            shareBox.Text   = exportStr
            -- Coba auto-copy ke clipboard
            task.defer(function()
                local clipOk = pcall(function() setclipboard(exportStr) end)
                shareBox:CaptureFocus()
                if clipOk then
                    setShareStatus("Otomatis tersalin ke clipboard!", false)
                end
            end)
        else
            shareTitle.Text = "Import Settings"
            shareInfo.Text  = "Tempel (Ctrl+V) kode settingan dari orang lain di sini, lalu klik Terapkan."
            shareBox.Text   = ""
            task.defer(function()
                shareBox:CaptureFocus()
            end)
        end
        shareOverlay.Visible = true
    end

    -- Dua tombol di action grid
    makeButton("Copy Settings", function()
        showSharePopup(serializeSettings())
    end, Color3.fromRGB(35, 82, 55))
    makeButton("Paste Settings", function()
        showSharePopup(nil)
    end, Color3.fromRGB(62, 50, 100))
    -- ----------------------------------------------------------------------

    ---- SETTINGS TABS ----
    local settingsSectionLabel = Instance.new("TextLabel")
    settingsSectionLabel.Size = UDim2.new(1, 0, 0, 14)
    settingsSectionLabel.LayoutOrder = 7
    settingsSectionLabel.BackgroundTransparency = 1
    settingsSectionLabel.Font = Enum.Font.GothamSemibold
    settingsSectionLabel.TextSize = 10
    settingsSectionLabel.TextColor3 = Color3.fromRGB(130, 145, 165)
    settingsSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    settingsSectionLabel.Text = "  SETTINGS"
    settingsSectionLabel.Parent = content

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 34)
    tabBar.LayoutOrder = 8
    tabBar.BackgroundColor3 = Color3.fromRGB(22, 26, 33)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = content
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 9)

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding = UDim.new(0, 4)
    tabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabBarLayout.Parent = tabBar

    local tabBarPad = Instance.new("UIPadding")
    tabBarPad.PaddingLeft = UDim.new(0, 4)
    tabBarPad.PaddingRight = UDim.new(0, 4)
    tabBarPad.PaddingTop = UDim.new(0, 4)
    tabBarPad.PaddingBottom = UDim.new(0, 4)
    tabBarPad.Parent = tabBar

    local activeSettingsTab = "Normal"
    local settingTabBtns = {}
    local settingTabFrames = {}

    local tabIcons = {Normal = "●", Drone = "◈", Gyroscope = "⟳"}

    for _, tName in ipairs(modeOrder) do
        local tbtn = Instance.new("TextButton")
        tbtn.Size = UDim2.new(0.333, -4, 1, -8)
        tbtn.AutoButtonColor = false
        tbtn.BackgroundColor3 = Color3.fromRGB(30, 34, 43)
        tbtn.BorderSizePixel = 0
        tbtn.Font = Enum.Font.GothamBold
        tbtn.TextSize = 11
        tbtn.TextColor3 = Color3.fromRGB(160, 172, 190)
        tbtn.Text = tabIcons[tName] .. " " .. tName
        tbtn.LayoutOrder = _
        tbtn.Parent = tabBar
        Instance.new("UICorner", tbtn).CornerRadius = UDim.new(0, 6)
        settingTabBtns[tName] = tbtn

        local tabFrame = Instance.new("Frame")
        tabFrame.Name = "Tab_" .. tName
        tabFrame.Size = UDim2.new(1, 0, 0, 0)
        tabFrame.LayoutOrder = 9
        tabFrame.BackgroundColor3 = Color3.fromRGB(25, 29, 36)
        tabFrame.BorderSizePixel = 0
        tabFrame.AutomaticSize = Enum.AutomaticSize.Y
        tabFrame.Visible = (tName == "Normal")
        tabFrame.Parent = content
        Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0, 9)
        settingTabFrames[tName] = tabFrame
    end


    local function updateSettingsTabButtonsLocal()
        for tName, btn in pairs(settingTabBtns) do
            if tName == activeSettingsTab then
                btn.BackgroundColor3 = modeColors[tName]
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 34, 43)
                btn.TextColor3 = Color3.fromRGB(160, 172, 190)
            end
        end
    end

    local function setSettingsTab(name)
        activeSettingsTab = name
        updateSettingsTabButtonsLocal()
        for n, f in pairs(settingTabFrames) do
            f.Visible = (n == name)
        end
        refreshUiText()
    end

    for _, tName in ipairs(modeOrder) do
        local tbtn = settingTabBtns[tName]
        table.insert(connections, tbtn.MouseButton1Click:Connect(function()
            if scriptKilled then return end
            setSettingsTab(tName)
        end))
    end

    ---- SLIDER HELPERS ----
    local function createSliderRow(parent, labelText, minVal, maxVal, getValue, setValue, formatValue, accentColor)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = Color3.fromRGB(32, 37, 46)
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromOffset(126, 20)
        label.Position = UDim2.fromOffset(8, 9)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 11
        label.TextColor3 = Color3.fromRGB(200, 208, 220)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = labelText
        label.Parent = row

        local box = Instance.new("TextBox")
        box.Size = UDim2.fromOffset(68, 24)
        box.Position = UDim2.new(1, -76, 0, 7)
        box.BackgroundColor3 = Color3.fromRGB(22, 26, 33)
        box.BorderSizePixel = 0
        box.Font = Enum.Font.Code
        box.TextSize = 12
        box.TextColor3 = Color3.fromRGB(235, 235, 235)
        box.ClearTextOnFocus = false
        box.Text = formatValue(getValue())
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1, -214, 0, 8)
        barBg.Position = UDim2.fromOffset(138, 15)
        barBg.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
        barBg.BorderSizePixel = 0
        barBg.Parent = row
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = accentColor or Color3.fromRGB(78, 155, 255)
        fill.BorderSizePixel = 0
        fill.Parent = barBg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(12, 12)
        knob.Position = UDim2.new(0, -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(230, 238, 248)
        knob.BorderSizePixel = 0
        knob.Parent = barBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local function setFromX(xPos)
            local left = barBg.AbsolutePosition.X
            local width = barBg.AbsoluteSize.X
            if width <= 0 then return end
            local t = math.clamp((xPos - left) / width, 0, 1)
            local raw = minVal + (maxVal - minVal) * t
            setValue(raw)
            refreshUiText()
        end

        table.insert(connections, barBg.InputBegan:Connect(function(input)
            if scriptKilled then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                activeSliderRow = { setFromX = setFromX }
                setFromX(input.Position.X)
            end
        end))

        table.insert(connections, box.FocusLost:Connect(function(enterPressed)
            if scriptKilled then return end
            local n = tonumber(box.Text)
            if n then setValue(n) end
            refreshUiText()
        end))

        local function update()
            local v = math.clamp(getValue(), minVal, maxVal)
            local t = 0
            if maxVal > minVal then
                t = (v - minVal) / (maxVal - minVal)
            end
            fill.Size = UDim2.new(t, 0, 1, 0)
            knob.Position = UDim2.new(t, -6, 0.5, -6)
            if not box:IsFocused() then box.Text = formatValue(v) end
        end

        return { min=minVal, max=maxVal, box=box, fill=fill, knob=knob, format=formatValue, update=update }
    end

    -- Helper to build a labeled slider section header inside a tab frame
    local function makeTabSection(parent, title, color)
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, -12, 0, 22)
        header.BackgroundColor3 = Color3.new(0,0,0)
        header.BackgroundTransparency = 0.6
        header.BorderSizePixel = 0
        header.Font = Enum.Font.GothamBold
        header.TextSize = 10
        header.TextColor3 = color or Color3.fromRGB(160, 200, 255)
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Text = "  " .. title
        header.Parent = parent
        Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)
        return header
    end

    local normalTabRowsRef = {}
    local droneTabRowsRef  = {}
    local gyroTabRowsRef   = {}
    local gyroInfoLabelRef = nil

    ---- NORMAL TAB ----
    do
        local tf = settingTabFrames.Normal
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = tf
        local lpad = Instance.new("UIPadding")
        lpad.PaddingLeft = UDim.new(0,6)
        lpad.PaddingRight = UDim.new(0,6)
        lpad.PaddingTop = UDim.new(0,6)
        lpad.PaddingBottom = UDim.new(0,6)
        lpad.Parent = tf

        local accent = Color3.fromRGB(78, 155, 255)
        makeTabSection(tf, "Movement", accent)
        local normalTabRows = {}

        normalTabRows.speed = createSliderRow(tf, "Speed", CONFIG.minSpeed, CONFIG.maxSpeed,
            function() return speed end, setSpeedValue,
            function(v) return string.format("%.0f", v) end, accent)
        normalTabRows.sens = createSliderRow(tf, "Sensitivity", 0.02, 1.5,
            function() return sensitivity end, setSensitivityValue,
            function(v) return string.format("%.2f", v) end, accent)
        normalTabRows.boost = createSliderRow(tf, "Boost ×", 1, 8,
            function() return boostMultiplier end, setBoostMultiplierValue,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 180, 60))
        normalTabRows.slow = createSliderRow(tf, "Slow ×", 0.05, 1,
            function() return slowMultiplier end, setSlowMultiplierValue,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(100, 200, 130))

        makeTabSection(tf, "Camera", Color3.fromRGB(160, 200, 255))
        normalTabRows.fov = createSliderRow(tf, "FOV", CONFIG.minFov, CONFIG.maxFov,
            function() return targetFov end, setFovValue,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(255, 140, 80))
        normalTabRows.fovSmooth = createSliderRow(tf, "FOV Smooth", 1, 40,
            function() return fovSmooth end, setFovSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)
        normalTabRows.zoomStep = createSliderRow(tf, "Zoom Step", 0.2, 20,
            function() return zoomStep end, setZoomStepValue,
            function(v) return string.format("%.2f", v) end, accent)
        normalTabRows.pitchClamp = createSliderRow(tf, "Pitch Clamp°", 30, 89,
            function() return math.deg(pitchClamp) end, setPitchClampDeg,
            function(v) return string.format("%.0f", v) end, accent)

        makeTabSection(tf, "Smoothing", Color3.fromRGB(160, 200, 255))
        normalTabRows.posSmooth = createSliderRow(tf, "Pos Smooth", 1, 40,
            function() return posSmooth end, setPosSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)
        normalTabRows.rotSmooth = createSliderRow(tf, "Rot Smooth", 1, 40,
            function() return rotSmooth end, setRotSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)

        makeTabSection(tf, "Roll", Color3.fromRGB(200, 160, 255))
        normalTabRows.rollSpeed = createSliderRow(tf, "Roll Speed°/s", math.deg(CONFIG.minRollSpeed), math.deg(CONFIG.maxRollSpeed),
            function() return math.deg(rollSpeed) end, setRollSpeedDeg,
            function(v) return string.format("%.0f", v) end, Color3.fromRGB(180, 100, 255))

        makeTabSection(tf, "Orbit", Color3.fromRGB(120, 210, 255))
        normalTabRows.orbitSpeed = createSliderRow(tf, "Orbit Speed deg/s", 1, 360,
            function() return math.deg(modeSettings.Normal.orbitSpinSpeed or orbitSpinSpeed) end, setOrbitSpinSpeedDeg,
            function(v) return string.format("%.0f", v) end, Color3.fromRGB(120, 210, 255))
        normalTabRows.orbitRadius = createSliderRow(tf, "Orbit Radius", CONFIG.orbitMinDistance, CONFIG.orbitMaxDistance,
            function() return modeSettings.Normal.orbitRadius or orbitRadius end, setOrbitRadiusValue,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(120, 210, 255))

        makeTabSection(tf, "Depth of Field", Color3.fromRGB(100, 200, 220))
        normalTabRows.dofNear = createSliderRow(tf, "DOF Near", 0, 1,
            function() return dofNearIntensity end, setDofNearIntensity,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(80, 200, 200))
        normalTabRows.dofFar = createSliderRow(tf, "DOF Far", 0, 1,
            function() return dofFarIntensity end, setDofFarIntensity,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(80, 200, 200))
        normalTabRows.dofFocus = createSliderRow(tf, "DOF Focus", CONFIG.dofMinDistance, CONFIG.dofMaxDistance,
            function() return dofFocusDistance end, setDofFocusDistance,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(80, 200, 200))
        normalTabRows.dofRadius = createSliderRow(tf, "DOF Radius", 0, CONFIG.dofMaxDistance,
            function() return dofInFocusRadius end, setDofInFocusRadius,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(80, 200, 200))
        normalTabRows.dofAutoSpeed = createSliderRow(tf, "DOF Auto Spd", 0.5, 100,
            function() return dofAutoFocusSpeed end, setDofAutoFocusSpeed,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(80, 200, 200))

        normalTabRowsRef = normalTabRows
    end

    ---- DRONE TAB ----
    do
        local tf = settingTabFrames.Drone
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = tf
        local lpad = Instance.new("UIPadding")
        lpad.PaddingLeft = UDim.new(0,6)
        lpad.PaddingRight = UDim.new(0,6)
        lpad.PaddingTop = UDim.new(0,6)
        lpad.PaddingBottom = UDim.new(0,6)
        lpad.Parent = tf

        local accent = Color3.fromRGB(60, 200, 130)

        local droneInfo = Instance.new("TextLabel")
        droneInfo.Size = UDim2.new(1, -12, 0, 32)
        droneInfo.BackgroundColor3 = Color3.fromRGB(30, 50, 40)
        droneInfo.BorderSizePixel = 0
        droneInfo.Font = Enum.Font.Code
        droneInfo.TextSize = 10
        droneInfo.TextColor3 = Color3.fromRGB(130, 220, 160)
        droneInfo.TextXAlignment = Enum.TextXAlignment.Left
        droneInfo.TextYAlignment = Enum.TextYAlignment.Center
        droneInfo.Text = "  DRONE FPV  -  LS = Roll/Throttle | RS = Pitch/Yaw\n  Full rotation + physics (TWR, gravity, drag, inertia)"
        droneInfo.Parent = tf
        Instance.new("UICorner", droneInfo).CornerRadius = UDim.new(0, 7)

        -- ---- DRONE FLIGHT MODE SELECTOR ----
        local flightModeLabel = Instance.new("TextLabel")
        flightModeLabel.Size = UDim2.new(1, -12, 0, 22)
        flightModeLabel.BackgroundColor3 = Color3.new(0,0,0)
        flightModeLabel.BackgroundTransparency = 0.6
        flightModeLabel.BorderSizePixel = 0
        flightModeLabel.Font = Enum.Font.GothamBold
        flightModeLabel.TextSize = 10
        flightModeLabel.TextColor3 = accent
        flightModeLabel.TextXAlignment = Enum.TextXAlignment.Left
        flightModeLabel.Text = "  FLIGHT MODE"
        flightModeLabel.Parent = tf
        Instance.new("UICorner", flightModeLabel).CornerRadius = UDim.new(0, 6)

        local flightModeRow = Instance.new("Frame")
        flightModeRow.Size = UDim2.new(1, -12, 0, 40)
        flightModeRow.BackgroundColor3 = Color3.fromRGB(22, 36, 30)
        flightModeRow.BorderSizePixel = 0
        flightModeRow.Parent = tf
        Instance.new("UICorner", flightModeRow).CornerRadius = UDim.new(0, 9)
        local fmStroke = Instance.new("UIStroke")
        fmStroke.Thickness = 1
        fmStroke.Color = accent
        fmStroke.Transparency = 0.6
        fmStroke.Parent = flightModeRow

        local fmRowLayout = Instance.new("UIListLayout")
        fmRowLayout.FillDirection = Enum.FillDirection.Horizontal
        fmRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        fmRowLayout.Padding = UDim.new(0, 4)
        fmRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        fmRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        fmRowLayout.Parent = flightModeRow

        local fmPad = Instance.new("UIPadding")
        fmPad.PaddingLeft  = UDim.new(0, 4)
        fmPad.PaddingRight = UDim.new(0, 4)
        fmPad.PaddingTop   = UDim.new(0, 5)
        fmPad.PaddingBottom = UDim.new(0, 5)
        fmPad.Parent = flightModeRow

        -- Flight mode definitions: name, description color, tooltip
        local flightModes = {
            { name = "Acro",  icon = "⚡", color = Color3.fromRGB(60, 200, 130),  desc = "Full manual, no auto-level" },
            { name = "Angle", icon = "⊿", color = Color3.fromRGB(255, 200, 60),   desc = "Auto-level, tilt limit" },
            { name = "3D",    icon = "∞", color = Color3.fromRGB(255, 100, 130),   desc = "Inverted flight, reverse thrust" },
        }
        local droneFlightModeBtns = {}

        local function updateFlightModeBtns()
            for _, fm in ipairs(flightModes) do
                local btn = droneFlightModeBtns[fm.name]
                if btn then
                    if droneFlightMode == fm.name then
                        btn.BackgroundColor3 = fm.color
                        btn.TextColor3 = Color3.fromRGB(15, 15, 15)
                    else
                        btn.BackgroundColor3 = Color3.fromRGB(28, 36, 32)
                        btn.TextColor3 = Color3.fromRGB(170, 190, 180)
                    end
                end
            end
        end

        for i, fm in ipairs(flightModes) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.333, -4, 1, 0)
            btn.AutoButtonColor = false
            btn.BackgroundColor3 = Color3.fromRGB(28, 36, 32)
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.TextColor3 = Color3.fromRGB(170, 190, 180)
            btn.Text = fm.icon .. " " .. fm.name
            btn.LayoutOrder = i
            btn.Parent = flightModeRow
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local bStroke2 = Instance.new("UIStroke")
            bStroke2.Thickness = 1
            bStroke2.Color = fm.color
            bStroke2.Transparency = 0.55
            bStroke2.Parent = btn
            droneFlightModeBtns[fm.name] = btn
            table.insert(connections, btn.MouseButton1Click:Connect(function()
                if scriptKilled then return end
                setDroneFlightMode(fm.name)
                updateFlightModeBtns()
                -- Show/hide angle-mode settings
                if uiRefs.droneAngleSection then
                    uiRefs.droneAngleSection.Visible = (droneFlightMode == "Angle")
                end
                refreshUiText()
            end))
        end

        -- Flight mode description label
        local fmDescLabel = Instance.new("TextLabel")
        fmDescLabel.Size = UDim2.new(1, -12, 0, 18)
        fmDescLabel.BackgroundTransparency = 1
        fmDescLabel.Font = Enum.Font.Code
        fmDescLabel.TextSize = 10
        fmDescLabel.TextColor3 = Color3.fromRGB(140, 200, 165)
        fmDescLabel.TextXAlignment = Enum.TextXAlignment.Center
        fmDescLabel.Text = "⚡ Acro: manual penuh  |  ⊿ Angle: auto-level  |  ∞ 3D: thrust terbalik"
        fmDescLabel.Parent = tf

        -- Angle mode specific settings (visible only when Angle is selected)
        local angleSectionFrame = Instance.new("Frame")
        angleSectionFrame.Size = UDim2.new(1, 0, 0, 0)
        angleSectionFrame.BackgroundTransparency = 1
        angleSectionFrame.AutomaticSize = Enum.AutomaticSize.Y
        angleSectionFrame.BorderSizePixel = 0
        angleSectionFrame.Visible = (droneFlightMode == "Angle")
        angleSectionFrame.Parent = tf

        local angleSectionLayout = Instance.new("UIListLayout")
        angleSectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        angleSectionLayout.Padding = UDim.new(0, 2)
        angleSectionLayout.Parent = angleSectionFrame

        local angleAccent = Color3.fromRGB(255, 200, 60)
        makeTabSection(angleSectionFrame, "Angle Mode Settings", angleAccent)
        local angleTabRows = {}
        angleTabRows.angleMaxTilt = createSliderRow(angleSectionFrame, "Max Tilt°", 5, 85,
            function() return droneAngleMaxTilt end, setDroneAngleMaxTilt,
            function(v) return string.format("%.0f", v) end, angleAccent)
        angleTabRows.angleLevelStrength = createSliderRow(angleSectionFrame, "Level Strength", 0.5, 20,
            function() return droneAngleLevelStrength end, setDroneAngleLevelStrength,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(255, 120, 100))
        angleTabRows.angleYawCoord = createSliderRow(angleSectionFrame, "Coord Turn", 0, 1,
            function() return droneAngleYawCoord end, setDroneAngleYawCoord,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 120, 100))

        local droneTabRows = {}

        makeTabSection(tf, "Rates (deg/s)", accent)
        droneTabRows.rollRate = createSliderRow(tf, "Roll Rate", 50, 1200,
            function() return droneRollRate end, setDroneRollRate,
            function(v) return string.format("%.0f", v) end, accent)
        droneTabRows.pitchRate = createSliderRow(tf, "Pitch Rate", 50, 1200,
            function() return dronePitchRate end, setDronePitchRate,
            function(v) return string.format("%.0f", v) end, accent)
        droneTabRows.yawRate = createSliderRow(tf, "Yaw Rate", 50, 1200,
            function() return droneYawRate end, setDroneYawRate,
            function(v) return string.format("%.0f", v) end, accent)

        makeTabSection(tf, "Betaflight Rates", Color3.fromRGB(255, 100, 100))
        droneTabRows.rateType = createSliderRow(tf, "Enable BF (1=Yes)", 0, 1,
            function() return droneRateType == "Betaflight" and 1 or 0 end, setDroneRateType,
            function(v) return (v >= 0.5) and "Yes" or "No" end, Color3.fromRGB(255, 100, 100))
        droneTabRows.bfCenter = createSliderRow(tf, "BF Center", 10, 1000,
            function() return droneActualCenter end, setDroneActualCenter,
            function(v) return string.format("%.0f", v) end, Color3.fromRGB(255, 100, 100))
        droneTabRows.bfMax = createSliderRow(tf, "BF Max", 10, 2000,
            function() return droneActualMaxRate end, setDroneActualMaxRate,
            function(v) return string.format("%.0f", v) end, Color3.fromRGB(255, 100, 100))
        droneTabRows.bfExpo = createSliderRow(tf, "BF Expo", 0, 1,
            function() return droneActualExpo end, setDroneActualExpo,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 100, 100))

        makeTabSection(tf, "Expo", accent)
        droneTabRows.rollExpo = createSliderRow(tf, "Roll Expo", 0, 1,
            function() return droneRollExpo end, setDroneRollExpo,
            function(v) return string.format("%.2f", v) end, accent)
        droneTabRows.pitchExpo = createSliderRow(tf, "Pitch Expo", 0, 1,
            function() return dronePitchExpo end, setDronePitchExpo,
            function(v) return string.format("%.2f", v) end, accent)
        droneTabRows.yawExpo = createSliderRow(tf, "Yaw Expo", 0, 1,
            function() return droneYawExpo end, setDroneYawExpo,
            function(v) return string.format("%.2f", v) end, accent)

        makeTabSection(tf, "Super Rate", accent)
        droneTabRows.rollSuper = createSliderRow(tf, "Roll Super", 0, 1,
            function() return droneRollSuper end, setDroneRollSuper,
            function(v) return string.format("%.2f", v) end, accent)
        droneTabRows.pitchSuper = createSliderRow(tf, "Pitch Super", 0, 1,
            function() return dronePitchSuper end, setDronePitchSuper,
            function(v) return string.format("%.2f", v) end, accent)
        droneTabRows.yawSuper = createSliderRow(tf, "Yaw Super", 0, 1,
            function() return droneYawSuper end, setDroneYawSuper,
            function(v) return string.format("%.2f", v) end, accent)

        makeTabSection(tf, "Dynamics", accent)
        droneTabRows.rateResp = createSliderRow(tf, "Rate Resp", 1, 25,
            function() return droneRateResponse end, setDroneRateResponse,
            function(v) return string.format("%.1f", v) end, accent)
        droneTabRows.angDamp = createSliderRow(tf, "Ang Damping", 0, 5,
            function() return droneAngularDamping end, setDroneAngularDamping,
            function(v) return string.format("%.2f", v) end, accent)

        makeTabSection(tf, "Moment of Inertia", Color3.fromRGB(180, 160, 255))
        droneTabRows.moiPitch = createSliderRow(tf, "MOI Pitch", 0.2, 5,
            function() return droneMoiPitch end, setDroneMoiPitch,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(180, 160, 255))
        droneTabRows.moiRoll = createSliderRow(tf, "MOI Roll", 0.2, 5,
            function() return droneMoiRoll end, setDroneMoiRoll,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(180, 160, 255))
        droneTabRows.moiYaw = createSliderRow(tf, "MOI Yaw", 0.2, 5,
            function() return droneMoiYaw end, setDroneMoiYaw,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(180, 160, 255))

        makeTabSection(tf, "Throttle", accent)
        droneTabRows.speed = createSliderRow(tf, "TWR (Max)", 1, 20,
            function() return speed end, setDroneTwr,
            function(v) return string.format("%.2f", v) end, accent)
        droneTabRows.thrustMult = createSliderRow(tf, "Thrust x", 0.1, 3,
            function() return droneVertMult end, setDroneVertMult,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(80, 220, 150))
        droneTabRows.hoverThrottle = createSliderRow(tf, "Hover Throttle", 0.05, 0.95,
            function() return droneHoverThrottle end, setDroneHoverThrottle,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(140, 220, 180))
        droneTabRows.throttleMid = createSliderRow(tf, "Throttle Mid", 0.05, 0.95,
            function() return droneThrottleMid end, setDroneThrottleMid,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 180, 60))
        droneTabRows.throttleExpo = createSliderRow(tf, "Throttle Expo", 0, 1,
            function() return droneThrottleExpo end, setDroneThrottleExpo,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 180, 60))
        droneTabRows.throttlePower = createSliderRow(tf, "Throttle Power", 1, 3,
            function() return droneThrottlePower end, setDroneThrottlePower,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 180, 60))
        droneTabRows.thrustResponse = createSliderRow(tf, "Motor Resp", 1, 25,
            function() return droneThrustResponse end, setDroneThrustResponse,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(120, 210, 160))
        droneTabRows.motorSpinUp = createSliderRow(tf, "Motor Spool Up", 1, 30,
            function() return droneMotorSpinUp end, setDroneMotorSpinUp,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(120, 210, 160))
        droneTabRows.motorSpinDown = createSliderRow(tf, "Motor Spool Dn", 1, 30,
            function() return droneMotorSpinDown end, setDroneMotorSpinDown,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(120, 210, 160))

        makeTabSection(tf, "Input", accent)
        droneTabRows.deadzone = createSliderRow(tf, "Stick Deadzone", 0, 0.3,
            function() return droneDeadzone end, setDroneDeadzone,
            function(v) return string.format("%.2f", v) end, accent)

        makeTabSection(tf, "Physics", accent)
        droneTabRows.gravity = createSliderRow(tf, "Gravity", 0, 400,
            function() return droneGravity end, setDroneGravity,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(160, 200, 255))
        droneTabRows.drag = createSliderRow(tf, "Air Drag", 0, 3,
            function() return droneDrag end, setDroneDrag,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(160, 200, 255))
        droneTabRows.quadDrag = createSliderRow(tf, "Quad Drag", 0, 0.2,
            function() return droneQuadDrag end, setDroneQuadDrag,
            function(v) return string.format("%.3f", v) end, Color3.fromRGB(160, 200, 255))
        droneTabRows.inertia = createSliderRow(tf, "Inertia", 0, 1,
            function() return droneInertia end, setDroneInertia,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(160, 200, 255))
        droneTabRows.mass = createSliderRow(tf, "Mass", 0.2, 8,
            function() return droneMass end, setDroneMass,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(160, 200, 255))

        makeTabSection(tf, "Airflow Dynamics", Color3.fromRGB(200, 230, 255))
        droneTabRows.dragForward = createSliderRow(tf, "Drag Fwd", 0, 3,
            function() return droneDragForward end, setDroneDragForward,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(200, 230, 255))
        droneTabRows.dragSideways = createSliderRow(tf, "Drag Side", 0, 3,
            function() return droneDragSideways end, setDroneDragSideways,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(200, 230, 255))
        droneTabRows.dragVertical = createSliderRow(tf, "Drag Vert", 0, 3,
            function() return droneDragVertical end, setDroneDragVertical,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(200, 230, 255))
        droneTabRows.propwashStrength = createSliderRow(tf, "Propwash", 0, 1,
            function() return dronePropwashStrength end, setDronePropwashStrength,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(200, 230, 255))
        droneTabRows.propwashZone = createSliderRow(tf, "PW Zone", 0, 1,
            function() return dronePropwashZone end, setDronePropwashZone,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(200, 230, 255))
        droneTabRows.groundEffectHeight = createSliderRow(tf, "G-Eff Ht", 0, 20,
            function() return droneGroundEffectHeight end, setDroneGroundEffectHeight,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(200, 230, 255))
        droneTabRows.groundEffectStrength = createSliderRow(tf, "G-Eff Str", 0, 0.5,
            function() return droneGroundEffectStrength end, setDroneGroundEffectStrength,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(200, 230, 255))

        makeTabSection(tf, "Camera", accent)
        droneTabRows.fov = createSliderRow(tf, "FOV", CONFIG.minFov, CONFIG.maxFov,
            function() return targetFov end, setFovValue,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(255, 140, 80))
        droneTabRows.fovSmooth = createSliderRow(tf, "FOV Smooth", 1, 40,
            function() return fovSmooth end, setFovSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)
        droneTabRows.zoomStep = createSliderRow(tf, "Zoom Step", 0.2, 20,
            function() return zoomStep end, setZoomStepValue,
            function(v) return string.format("%.2f", v) end, accent)
        droneTabRows.cameraTilt = createSliderRow(tf, "Camera Tilt°", 0, 60,
            function() return droneCameraTilt end, setDroneCameraTilt,
            function(v) return string.format("%.0f", v) end, accent)
        droneTabRows.pitchClamp = createSliderRow(tf, "Pitch Clamp", 30, 89,
            function() return math.deg(pitchClamp) end, setPitchClampDeg,
            function(v) return string.format("%.0f", v) end, accent)

        makeTabSection(tf, "Smoothing", accent)
        droneTabRows.posSmooth = createSliderRow(tf, "Pos Smooth", 1, 40,
            function() return posSmooth end, setPosSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)
        droneTabRows.rotSmooth = createSliderRow(tf, "Rot Smooth", 1, 40,
            function() return rotSmooth end, setRotSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)


        droneTabRowsRef = droneTabRows
        droneTabRowsRef._angleTabRows        = angleTabRows
        droneTabRowsRef._angleSectionFrame   = angleSectionFrame
        droneTabRowsRef._flightModeBtns      = droneFlightModeBtns
        droneTabRowsRef._flightModes         = flightModes
        droneTabRowsRef._updateFlightModeBtns = updateFlightModeBtns
    end

    ---- GYROSCOPE TAB ----
    do
        local tf = settingTabFrames.Gyroscope
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = tf
        local lpad = Instance.new("UIPadding")
        lpad.PaddingLeft = UDim.new(0,6)
        lpad.PaddingRight = UDim.new(0,6)
        lpad.PaddingTop = UDim.new(0,6)
        lpad.PaddingBottom = UDim.new(0,6)
        lpad.Parent = tf

        local accent = Color3.fromRGB(190, 110, 255)

        local gyroInfo = Instance.new("TextLabel")
        gyroInfo.Size = UDim2.new(1, -12, 0, 46)
        gyroInfo.BackgroundColor3 = Color3.fromRGB(40, 28, 55)
        gyroInfo.BorderSizePixel = 0
        gyroInfo.Font = Enum.Font.Code
        gyroInfo.TextSize = 10
        gyroInfo.TextColor3 = Color3.fromRGB(200, 150, 255)
        gyroInfo.TextXAlignment = Enum.TextXAlignment.Left
        gyroInfo.TextYAlignment = Enum.TextYAlignment.Center
        gyroInfo.Text = "  GYROSCOPE MODE - kamera ikut orientasi HP, gerak dari tilt + akselerasi.\n  X = recenter pose | Space/Ctrl = naik/turun | URL: " .. gyroUrl
        gyroInfo.Parent = tf
        Instance.new("UICorner", gyroInfo).CornerRadius = UDim.new(0, 7)

        local gyroTabRows = {}

        makeTabSection(tf, "Movement", accent)
        gyroTabRows.speed = createSliderRow(tf, "Speed", CONFIG.minSpeed, CONFIG.maxSpeed,
            function() return speed end, setSpeedValue,
            function(v) return string.format("%.0f", v) end, accent)
        gyroTabRows.boost = createSliderRow(tf, "Boost ×", 1, 8,
            function() return boostMultiplier end, setBoostMultiplierValue,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 180, 60))
        gyroTabRows.slow = createSliderRow(tf, "Slow ×", 0.05, 1,
            function() return slowMultiplier end, setSlowMultiplierValue,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(100, 200, 130))

        makeTabSection(tf, "Gyroscope Sensor", accent)
        gyroTabRows.gyroSensitivity = createSliderRow(tf, "Gyro Sens", 0.1, 50,
            function() return gyroSensitivity end, setGyroSensitivity,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(230, 130, 255))
        gyroTabRows.gyroSmoothness = createSliderRow(tf, "Smoothness", 0.01, 1,
            function() return gyroSmoothness end, setGyroSmoothness,
            function(v) return string.format("%.3f", v) end, accent)
        gyroTabRows.gyroDeadzone = createSliderRow(tf, "Deadzone", 0, 0.1,
            function() return gyroDeadzone end, setGyroDeadzone,
            function(v) return string.format("%.4f", v) end, accent)
        gyroTabRows.gyroPollRate = createSliderRow(tf, "Poll Hz", 1, 60,
            function() return gyroPollRate end, setGyroPollRate,
            function(v) return string.format("%.0f", v) end, accent)

        makeTabSection(tf, "6DoF Motion", accent)
        gyroTabRows.gyroMoveGain = createSliderRow(tf, "Linear Gain", 0, 80,
            function() return gyro6dof.moveGain end, setGyroMoveGain,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(110, 215, 255))
        gyroTabRows.gyroTiltGain = createSliderRow(tf, "Tilt Drive", 0, 4,
            function() return gyro6dof.tiltGain end, setGyroTiltGain,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(120, 235, 185))
        gyroTabRows.gyroMoveDamping = createSliderRow(tf, "Move Damping", 0.1, 30,
            function() return gyro6dof.moveDamping end, setGyroMoveDamping,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 175, 90))
        gyroTabRows.gyroMoveDeadzone = createSliderRow(tf, "Accel Deadzone", 0, 3,
            function() return gyro6dof.moveDeadzone end, setGyroMoveDeadzone,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(255, 205, 110))
        gyroTabRows.gyroVerticalAssist = createSliderRow(tf, "Vert Accel", 0, 2,
            function() return gyro6dof.verticalAssist end, setGyroVerticalAssist,
            function(v) return string.format("%.2f", v) end, Color3.fromRGB(190, 190, 255))

        makeTabSection(tf, "Camera", accent)
        gyroTabRows.fov = createSliderRow(tf, "FOV", CONFIG.minFov, CONFIG.maxFov,
            function() return targetFov end, setFovValue,
            function(v) return string.format("%.1f", v) end, Color3.fromRGB(255, 140, 80))
        gyroTabRows.fovSmooth = createSliderRow(tf, "FOV Smooth", 1, 40,
            function() return fovSmooth end, setFovSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)
        gyroTabRows.zoomStep = createSliderRow(tf, "Zoom Step", 0.2, 20,
            function() return zoomStep end, setZoomStepValue,
            function(v) return string.format("%.2f", v) end, accent)

        makeTabSection(tf, "Roll & Smoothing", accent)
        gyroTabRows.rollSpeed = createSliderRow(tf, "Roll Speed°/s", math.deg(CONFIG.minRollSpeed), math.deg(CONFIG.maxRollSpeed),
            function() return math.deg(rollSpeed) end, setRollSpeedDeg,
            function(v) return string.format("%.0f", v) end, accent)
        gyroTabRows.posSmooth = createSliderRow(tf, "Pos Smooth", 1, 40,
            function() return posSmooth end, setPosSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)
        gyroTabRows.rotSmooth = createSliderRow(tf, "Rot Smooth", 1, 40,
            function() return rotSmooth end, setRotSmoothValue,
            function(v) return string.format("%.1f", v) end, accent)

        gyroTabRowsRef = gyroTabRows
        gyroInfoLabelRef = gyroInfo
    end

    ---- KEYBINDS SECTION ----
    local keybindsSectionLabel = Instance.new("TextLabel")
    keybindsSectionLabel.Size = UDim2.new(1, 0, 0, 14)
    keybindsSectionLabel.LayoutOrder = 10
    keybindsSectionLabel.BackgroundTransparency = 1
    keybindsSectionLabel.Font = Enum.Font.GothamSemibold
    keybindsSectionLabel.TextSize = 10
    keybindsSectionLabel.TextColor3 = Color3.fromRGB(130, 145, 165)
    keybindsSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindsSectionLabel.Text = "  KEYBINDS"
    keybindsSectionLabel.Parent = content

    local keyList = Instance.new("TextLabel")
    keyList.Size = UDim2.new(1, 0, 0, 205)
    keyList.LayoutOrder = 11
    keyList.BackgroundColor3 = Color3.fromRGB(25, 29, 36)
    keyList.BorderSizePixel = 0
    keyList.Font = Enum.Font.Code
    keyList.TextSize = 11
    keyList.TextColor3 = Color3.fromRGB(167, 178, 195)
    keyList.TextXAlignment = Enum.TextXAlignment.Left
    keyList.TextYAlignment = Enum.TextYAlignment.Top
    keyList.Text = table.concat({
        "Toggle: Shift+F | Panel: P | Controls Lock: K",
        "Move: W/A/S/D + Q/E | Boost: LShift | Slow: LCtrl",
        "Roll: Z/C | Roll Reset: X | Portrait +90: R",
        "Cursor: M | Hide UI: U | Stick Overlay: I",
        "FOV Zoom: Mouse Wheel",
        "Orbit: A/D left-right | W/S up-down | Ctrl+Wheel distance",
        "Orbit: O toggle | T release-pick / hold outline | G self | Y clear",
        "Selector: B/button = Object / Player / Model / Part",
        "Selector: Mesh / Tool-Accessory",
        "Speed/TWR: PgUp/PgDn or -/= | Reset: 0",
        "Gamepad: Select = toggle | Y = flight mode",
        "Drone FPV: LS roll/throttle | RS pitch/yaw",
        "Gyroscope: HP attitude + tilt/accel | X recenter | Space/Ctrl up/down",
    }, "\n")
    keyList.Parent = content
    Instance.new("UICorner", keyList).CornerRadius = UDim.new(0, 9)
    do
        local kp = Instance.new("UIPadding")
        kp.PaddingLeft = UDim.new(0, 8)
        kp.PaddingTop = UDim.new(0, 7)
        kp.PaddingRight = UDim.new(0, 4)
        kp.Parent = keyList
    end

    ---- DRAG / RESIZE ----
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if scriptKilled then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement and activeSliderRow then
            activeSliderRow.setFromX(input.Position.X)
        end
    end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if scriptKilled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            clearUiInteractionState()
        end
    end))

    table.insert(connections, headerDragZone.InputBegan:Connect(function(input)
        if scriptKilled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            panelStart = panel.Position
        end
    end))

    table.insert(connections, headerDragZone.InputEnded:Connect(function(input)
        if scriptKilled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    table.insert(connections, resizeHandle.InputBegan:Connect(function(input)
        if scriptKilled then return end
        if minimized then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            resizeStartSize = Vector2.new(panelWidth, panelHeight)
        end
    end))

    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if scriptKilled then return end
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            panel.Position = UDim2.fromOffset(
                panelStart.X.Offset + delta.X,
                panelStart.Y.Offset + delta.Y
            )
            clampPanelToViewport()
        elseif resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            setPanelSizeInternal(
                resizeStartSize.X + delta.X,
                resizeStartSize.Y + delta.Y
            )
        end
    end))

    table.insert(connections, minimizeBtn.MouseButton1Click:Connect(function()
        if scriptKilled then return end
        minimized = not minimized
        if minimized then
            content.Visible = false
            panel.Size = UDim2.fromOffset(normalSize.X.Offset, 34)
            minimizeBtn.Text = "Max"
            resizeHandle.Visible = false
            resizing = false
        else
            content.Visible = true
            panel.Size = normalSize
            minimizeBtn.Text = "Min"
            resizeHandle.Visible = true
        end
        clampPanelToViewport()
    end))

    table.insert(connections, exitBtn.MouseButton1Click:Connect(function()
        shutdownFreecamScript("ui")
    end))

    uiRefs = {
        gui              = gui,
        panel            = panel,
        clampPanel       = clampPanelToViewport,
        status           = status,
        stats            = stats,
        freecamBtn       = freecamBtn,
        cursorBtn        = cursorBtn,
        uiBtn            = uiBtn,
        controlsBtn      = controlsBtn,
        orbitToggleBtn   = orbitToggleBtn,
        orbitSelectorBtn = orbitSelectorBtn,
        dofToggleBtn     = dofToggleBtn,
        dofFocusModeBtn  = dofFocusModeBtn,
        stickOverlayBtn  = stickOverlayBtn,
        modeBtns         = modeBtns,
        modeColors       = modeColors,
        settingTabBtns   = settingTabBtns,
        activeSettingsTab = activeSettingsTab,
        normalTabRows    = normalTabRowsRef,
        droneTabRows     = droneTabRowsRef,
        gyroscopeTabRows = gyroTabRowsRef,
        gyroInfoLabel    = gyroInfoLabelRef,
        droneAngleSection      = droneTabRowsRef._angleSectionFrame,
        updateFlightModeBtns   = droneTabRowsRef._updateFlightModeBtns,
        stickOverlay     = stickOverlay,
        leftStickDot     = leftDot,
        rightStickDot    = rightDot,
    }

    -- Patch activeSettingsTab reference for refreshUiText
    local origSetSettingsTab = setSettingsTab
    setSettingsTab = function(name)
        uiRefs.activeSettingsTab = name
        origSetSettingsTab(name)

    end

    refreshUiText()
end

createControlUI()

--// TOGGLE + SPEED + ROLL RESET
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
    if scriptKilled then return end
    if gp then return end

    if input.KeyCode == CONFIG.panelToggleKey then
        setPanelVisible(not panelVisible)
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.toggleKey then
        if CONFIG.toggleRequiresShift and not (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) then
            return
        end
        toggleFreecam()
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.stickOverlayToggleKey then
        setStickOverlayVisible(not stickOverlayVisible)
        refreshUiText()
        return
    end

    if not freecam then return end

    if input.KeyCode == CONFIG.orbitToggleKey then
        setOrbitEnabled(not orbitEnabled)
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.orbitPickKey then
        beginOrbitPickTarget()
        return
    end

    if input.KeyCode == CONFIG.orbitSelectorKey then
        cycleOrbitSelectorMode(1)
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.orbitSelfKey then
        setOrbitTargetSelf()
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.orbitClearKey then
        clearOrbitTarget()
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.rotate90Key then
        if not controlsEnabled then return end
        rotatePortrait90()
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.cursorToggleKey then
        setCursorUnlocked(not cursorUnlocked)
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.uiToggleKey then
        setUiHidden(not uiHidden)
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.controlsToggleKey then
        setControlsEnabled(not controlsEnabled)
        refreshUiText()
        return
    end

end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input, _)
    if scriptKilled then return end
    if input.KeyCode ~= CONFIG.orbitPickKey then return end

    finishOrbitPickTarget()
    refreshUiText()
end))

--// GAMEPAD SHORTCUTS
table.insert(connections, UserInputService.InputBegan:Connect(function(input)
    if scriptKilled then return end
    if input.UserInputType ~= Enum.UserInputType.Gamepad1 then return end

    if input.KeyCode == CONFIG.gamepadToggleKey then
        toggleFreecam()
        refreshUiText()
        return
    end

    if input.KeyCode == CONFIG.gamepadFlightModeKey then
        if currentMode == "Drone" then
            cycleDroneFlightMode(1)
            refreshUiText()
        end
        return
    end
end))

--// ZOOM
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if scriptKilled then return end
    if freecam and controlsEnabled and not cursorUnlocked and input.UserInputType == Enum.UserInputType.MouseWheel then
        local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if ctrlDown and currentMode == "Normal" and orbitEnabled and orbitTarget then
            setOrbitRadiusValue(orbitRadius - input.Position.Z * 2)
        else
            targetFov = math.clamp(
                targetFov - input.Position.Z * zoomStep,
                CONFIG.minFov, CONFIG.maxFov
            )
        end
        refreshUiText()
    end
end))

table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
    if scriptKilled then return end
    if not freecam then return end
    clearUiInteractionState()
    destroyOrbitPreview()
    for k in pairs(moveState) do
        moveState[k] = false
    end
    for k in pairs(rollState) do
        rollState[k] = false
    end
end))

function smooth(k, dt)
    return 1 - math.exp(-k * dt)
end

function pushUniqueText(list, seen, value)
    if type(value) == "string" and value ~= "" and not seen[value] then
        seen[value] = true
        table.insert(list, value)
    end
end

function applySignedDeadzone(value, deadzone)
    if math.abs(value) <= deadzone then
        return 0
    end
    return value
end

function normalizeQuaternion(w, x, y, z)
    local mag = math.sqrt(w * w + x * x + y * y + z * z)
    if mag <= 1e-6 then
        return 1, 0, 0, 0
    end
    return w / mag, x / mag, y / mag, z / mag
end

function rotateVectorByQuaternion(v, w, x, y, z)
    local qv = Vector3.new(x, y, z)
    local t = qv:Cross(v) * 2
    return v + t * w + qv:Cross(t)
end

function buildPhonePoseFromQuaternion(w, x, y, z)
    w, x, y, z = normalizeQuaternion(w, x, y, z)
    local right = rotateVectorByQuaternion(BODY_RIGHT, w, x, y, z)
    local up = rotateVectorByQuaternion(BODY_UP, w, x, y, z)
    local screenOut = rotateVectorByQuaternion(Vector3.new(0, 0, 1), w, x, y, z)
    return CFrame.fromMatrix(Vector3.zero, right, up, screenOut)
end

function buildPhonePoseFromEulerDegrees(yawDeg, pitchDeg, rollDeg)
    local yawRad = math.rad(-(tonumber(yawDeg) or 0))
    local pitchRad = math.rad(-(tonumber(pitchDeg) or 0))
    local rollRad = math.rad(tonumber(rollDeg) or 0)
    return CFrame.Angles(0, yawRad, 0)
        * CFrame.Angles(pitchRad, 0, 0)
        * CFrame.Angles(0, 0, rollRad)
end

function readPhyphoxSourceTriplet(inputs, sourceName, label)
    if type(inputs) ~= "table" then
        return nil
    end

    local sourceNameLower = string.lower(sourceName)
    for _, input in ipairs(inputs) do
        if type(input) == "table"
            and type(input.source) == "string"
            and string.lower(input.source) == sourceNameLower
            and type(input.outputs) == "table" then
            for _, output in ipairs(input.outputs) do
                if type(output) == "table"
                    and type(output.x) == "string"
                    and type(output.y) == "string"
                    and type(output.z) == "string" then
                    return {
                        x = output.x,
                        y = output.y,
                        z = output.z,
                        label = label,
                    }
                end
            end
        end
    end

    return nil
end

function readPhyphoxAttitudeOutput(inputs)
    if type(inputs) ~= "table" then
        return nil
    end

    for _, input in ipairs(inputs) do
        if type(input) == "table"
            and type(input.source) == "string"
            and string.lower(input.source) == "attitude"
            and type(input.outputs) == "table" then
            for _, output in ipairs(input.outputs) do
                if type(output) == "table"
                    and type(output.abs) == "string"
                    and type(output.x) == "string"
                    and type(output.y) == "string"
                    and type(output.z) == "string" then
                    return {
                        w = output.abs,
                        x = output.x,
                        y = output.y,
                        z = output.z,
                        label = "Phyphox attitude",
                    }
                end
            end
        end
    end

    return nil
end

function buildPhyphoxBufferSet(bufferNames)
    local bufferSet = {}
    if type(bufferNames) ~= "table" then
        return bufferSet
    end

    for _, name in ipairs(bufferNames) do
        if type(name) == "string" and name ~= "" then
            bufferSet[name] = true
        end
    end
    return bufferSet
end

function choosePhyphoxTriplet(bufferSet, candidates, label)
    if type(bufferSet) ~= "table" or type(candidates) ~= "table" then
        return nil
    end

    for _, candidate in ipairs(candidates) do
        if bufferSet[candidate.x] and bufferSet[candidate.y] and bufferSet[candidate.z] then
            return {
                x = candidate.x,
                y = candidate.y,
                z = candidate.z,
                label = candidate.label or label,
            }
        end
    end
    return nil
end

function choosePhyphoxQuaternion(bufferSet, candidates, label)
    if type(bufferSet) ~= "table" or type(candidates) ~= "table" then
        return nil
    end

    for _, candidate in ipairs(candidates) do
        if bufferSet[candidate.w] and bufferSet[candidate.x] and bufferSet[candidate.y] and bufferSet[candidate.z] then
            return {
                w = candidate.w,
                x = candidate.x,
                y = candidate.y,
                z = candidate.z,
                label = candidate.label or label,
            }
        end
    end
    return nil
end

function choosePhyphoxEuler(bufferSet)
    if type(bufferSet) ~= "table" then
        return nil
    end

    if bufferSet.yaw and bufferSet.pitch and bufferSet.roll then
        return {
            yaw = "yaw",
            pitch = "pitch",
            roll = "roll",
            label = "Phyphox yaw/pitch/roll",
        }
    end
    return nil
end

function getGyroHttpProxyRemote()
    local remote = gyroHttpProxyRemote
    if remote and remote.Parent then
        return remote
    end

    local found = ReplicatedStorage:FindFirstChild(GYRO_HTTP_PROXY_NAME)
    if found and found:IsA("RemoteFunction") then
        gyroHttpProxyRemote = found
        return found
    end
    return nil
end

function getGyroMaxPollRate()
    if getGyroHttpProxyRemote() then
        return GYRO_PROXY_SAFE_POLL_RATE
    end
    return 60
end

function getGyroRequestAdapter()
    if type(request) == "function" then
        return request, "request"
    elseif type(http_request) == "function" then
        return http_request, "http_request"
    elseif syn and type(syn.request) == "function" then
        return syn.request, "syn.request"
    elseif http and type(http.request) == "function" then
        return http.request, "http.request"
    end

    local proxyRemote = getGyroHttpProxyRemote()
    if proxyRemote then
        return function(options)
            return proxyRemote:InvokeServer(options)
        end, "ServerProxy"
    end

    return false, "Need FreecamGyroHttpProxy"
end

function performGyroHttpGet(requestFn, source, url)
    if requestFn == false then
        return false, nil, source
    end

    local ok, response
    if requestFn then
        ok, response = pcall(function()
            return requestFn({
                Url = url,
                Method = "GET",
                Headers = {
                    ["Accept"] = "application/json",
                },
            })
        end)
        if not ok then
            return false, nil, source .. " Error"
        end

        if type(response) == "table" then
            local success = response.Success
            local statusCode = tonumber(response.StatusCode or response.Status)
            if success == false or (statusCode and statusCode >= 400) then
                return false,
                    response.Body or response.body or response.Response or response.response,
                    response.Error or response.StatusMessage or (source .. " Error")
            end
            return true,
                response.Body or response.body or response.Response or response.response,
                nil
        end

        return true, response, nil
    end
    return false, nil, source .. " Error"
end

function setGyroRawRates(x, y, z, units)
    gyroRawX = tonumber(x) or 0
    gyroRawY = tonumber(y) or 0
    gyroRawZ = tonumber(z) or 0
    gyroRateToRadScale = units == "rad" and 1 or math.rad(1)
end

function getLastNumericValue(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "string" then
        return tonumber(value)
    end
    if type(value) ~= "table" then
        return nil
    end

    local list = value.buffer
    if type(list) ~= "table" then
        list = value
    end

    for i = #list, 1, -1 do
        local numeric = tonumber(list[i])
        if numeric ~= nil then
            return numeric
        end
    end
    return nil
end

function scorePhyphoxGyroPrefix(prefix)
    if prefix == "" then
        return 12
    end
    if prefix:find("gyr", 1, true) or prefix:find("gyro", 1, true) then
        return 120
    end
    if prefix:find("rotationrate", 1, true) or prefix:find("rotrate", 1, true) then
        return 110
    end
    if prefix:find("angularvelocity", 1, true) or prefix:find("angvel", 1, true) then
        return 100
    end
    if prefix:find("omega", 1, true) then
        return 90
    end
    if prefix == "w" then
        return 60
    end
    if prefix:find("acc", 1, true)
        or prefix:find("mag", 1, true)
        or prefix:find("quat", 1, true)
        or prefix:find("lin", 1, true)
        or prefix:find("grav", 1, true) then
        return -1
    end
    return 0
end

function inferPhyphoxGyroKeysFromNames(names)
    if type(names) ~= "table" or #names == 0 then
        return nil
    end

    local groups = {}
    for _, rawName in ipairs(names) do
        if type(rawName) == "string" and rawName ~= "" then
            local normalized = rawName:lower():gsub("[^%w]", "")
            local axis = normalized:match("([xyz])$")
            if axis then
                local prefix = normalized:sub(1, #normalized - 1)
                local score = scorePhyphoxGyroPrefix(prefix)
                if score >= 0 then
                    local group = groups[prefix]
                    if not group then
                        group = {score = score}
                        groups[prefix] = group
                    end
                    group[axis] = rawName
                    if score > group.score then
                        group.score = score
                    end
                end
            end
        end
    end

    local best
    local bestScore = -math.huge
    for prefix, group in pairs(groups) do
        if group.x and group.y and group.z then
            local score = group.score
            if prefix == "" and #names <= 6 then
                score = score + 25
            end
            if score > bestScore then
                bestScore = score
                best = {
                    x = group.x,
                    y = group.y,
                    z = group.z,
                    label = prefix == "" and "Phyphox x/y/z" or ("Phyphox " .. prefix .. "*"),
                }
            end
        end
    end

    return best
end

function buildPhyphoxBaseUrl(url)
    if type(url) ~= "string" or url == "" then
        return nil
    end
    local baseUrl = url:gsub("%?.*$", "")
    baseUrl = baseUrl:gsub("/+$", "")
    baseUrl = baseUrl:gsub("/get$", "")
    baseUrl = baseUrl:gsub("/config$", "")
    return baseUrl
end

function buildPhyphoxGetUrl(baseUrl, keys)
    if type(baseUrl) ~= "string" or baseUrl == "" then
        return nil
    end
    if type(keys) ~= "table" then
        return nil
    end

    local queryKeys = {}
    local seen = {}
    if keys.x and keys.y and keys.z then
        pushUniqueText(queryKeys, seen, keys.x)
        pushUniqueText(queryKeys, seen, keys.y)
        pushUniqueText(queryKeys, seen, keys.z)
        pushUniqueText(queryKeys, seen, keys.w)
        pushUniqueText(queryKeys, seen, keys.abs)
        pushUniqueText(queryKeys, seen, keys.yaw)
        pushUniqueText(queryKeys, seen, keys.pitch)
        pushUniqueText(queryKeys, seen, keys.roll)
    else
        for _, key in ipairs(keys) do
            pushUniqueText(queryKeys, seen, key)
        end
    end

    if #queryKeys == 0 then
        return nil
    end

    local encoded = {}
    for _, key in ipairs(queryKeys) do
        table.insert(encoded, HttpService:UrlEncode(key))
    end
    return baseUrl .. "/get?" .. table.concat(encoded, "&")
end

function collectPhyphoxSensorPlan(requestFn, source, inputUrl)
    local baseUrl = buildPhyphoxBaseUrl(inputUrl)
    if not baseUrl then
        return nil, nil
    end

    local ok, body = performGyroHttpGet(requestFn, source, baseUrl .. "/config")
    if not ok or type(body) ~= "string" then
        return baseUrl, nil
    end

    local decodeOk, configData = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not decodeOk or type(configData) ~= "table" then
        return baseUrl, nil
    end

    local bufferNames = {}
    if type(configData.buffers) == "table" then
        for _, entry in ipairs(configData.buffers) do
            if type(entry) == "table" and type(entry.name) == "string" then
                table.insert(bufferNames, entry.name)
            elseif type(entry) == "string" then
                table.insert(bufferNames, entry)
            end
        end
    end

    local bufferSet = buildPhyphoxBufferSet(bufferNames)
    local inputs = configData.inputs
    local plan = {
        queryKeys = {},
        label = "Phyphox",
    }
    local seen = {}

    plan.gyro = readPhyphoxSourceTriplet(inputs, "gyroscope", "Phyphox gyroscope input")
        or choosePhyphoxTriplet(bufferSet, PHYPHOX_GYRO_BUFFER_FALLBACKS, "Phyphox gyroscope")

    plan.linearAccel = readPhyphoxSourceTriplet(inputs, "linear_acceleration", "Phyphox linear acceleration")
        or choosePhyphoxTriplet(bufferSet, {
            {x = "linX", y = "linY", z = "linZ"},
            {x = "linearAccX", y = "linearAccY", z = "linearAccZ"},
            {x = "accNoGX", y = "accNoGY", z = "accNoGZ"},
        }, "Phyphox linear acceleration")

    plan.accel = readPhyphoxSourceTriplet(inputs, "accelerometer", "Phyphox accelerometer")
        or choosePhyphoxTriplet(bufferSet, {
            {x = "accX", y = "accY", z = "accZ"},
            {x = "accelerationX", y = "accelerationY", z = "accelerationZ"},
        }, "Phyphox accelerometer")

    plan.gravity = readPhyphoxSourceTriplet(inputs, "gravity", "Phyphox gravity")
        or choosePhyphoxTriplet(bufferSet, {
            {x = "gravX", y = "gravY", z = "gravZ"},
            {x = "gravityX", y = "gravityY", z = "gravityZ"},
        }, "Phyphox gravity")

    plan.attitude = choosePhyphoxQuaternion(bufferSet, {
            {w = "attW", x = "attX", y = "attY", z = "attZ"},
            {w = "quatW", x = "quatX", y = "quatY", z = "quatZ"},
            {w = "attWIn", x = "attXIn", y = "attYIn", z = "attZIn"},
        }, "Phyphox attitude")
        or readPhyphoxAttitudeOutput(inputs)

    plan.euler = choosePhyphoxEuler(bufferSet)

    local function appendTriplet(spec)
        if spec then
            pushUniqueText(plan.queryKeys, seen, spec.x)
            pushUniqueText(plan.queryKeys, seen, spec.y)
            pushUniqueText(plan.queryKeys, seen, spec.z)
        end
    end

    appendTriplet(plan.gyro)
    appendTriplet(plan.linearAccel)
    appendTriplet(plan.accel)
    appendTriplet(plan.gravity)
    if plan.attitude then
        pushUniqueText(plan.queryKeys, seen, plan.attitude.w)
        pushUniqueText(plan.queryKeys, seen, plan.attitude.x)
        pushUniqueText(plan.queryKeys, seen, plan.attitude.y)
        pushUniqueText(plan.queryKeys, seen, plan.attitude.z)
    end
    if plan.euler then
        pushUniqueText(plan.queryKeys, seen, plan.euler.yaw)
        pushUniqueText(plan.queryKeys, seen, plan.euler.pitch)
        pushUniqueText(plan.queryKeys, seen, plan.euler.roll)
    end

    if #plan.queryKeys == 0 then
        return baseUrl, nil
    end

    if plan.attitude and (plan.linearAccel or plan.accel) then
        plan.label = "Phyphox 6DoF"
    elseif plan.attitude then
        plan.label = "Phyphox attitude"
    elseif plan.gyro then
        plan.label = plan.gyro.label or "Phyphox gyroscope"
    end

    return baseUrl, plan
end

function readBufferTriplet(bufferData, spec)
    if type(bufferData) ~= "table" or type(spec) ~= "table" then
        return nil
    end

    local x = getLastNumericValue(bufferData[spec.x])
    local y = getLastNumericValue(bufferData[spec.y])
    local z = getLastNumericValue(bufferData[spec.z])
    if x == nil or y == nil or z == nil then
        return nil
    end
    return Vector3.new(x, y, z)
end

function readBufferQuaternion(bufferData, spec)
    if type(bufferData) ~= "table" or type(spec) ~= "table" then
        return nil
    end

    local w = getLastNumericValue(bufferData[spec.w])
    local x = getLastNumericValue(bufferData[spec.x])
    local y = getLastNumericValue(bufferData[spec.y])
    local z = getLastNumericValue(bufferData[spec.z])
    if w == nil or x == nil or y == nil or z == nil then
        return nil
    end

    return buildPhonePoseFromQuaternion(w, x, y, z)
end

function readBufferEuler(bufferData, spec)
    if type(bufferData) ~= "table" or type(spec) ~= "table" then
        return nil
    end

    local yawDeg = getLastNumericValue(bufferData[spec.yaw])
    local pitchDeg = getLastNumericValue(bufferData[spec.pitch])
    local rollDeg = getLastNumericValue(bufferData[spec.roll])
    if yawDeg == nil or pitchDeg == nil or rollDeg == nil then
        return nil
    end

    return Vector3.new(yawDeg, pitchDeg, rollDeg)
end

function collectPhyphoxGyroCandidates(requestFn, source, inputUrl)
    local baseUrl = buildPhyphoxBaseUrl(inputUrl)
    if not baseUrl then
        return nil, {}
    end

    local candidates = {}
    local seen = {}
    local function pushCandidate(keys)
        if type(keys) ~= "table" or not keys.x or not keys.y or not keys.z then
            return
        end
        local signature = string.lower(keys.x) .. "|" .. string.lower(keys.y) .. "|" .. string.lower(keys.z)
        if seen[signature] then
            return
        end
        seen[signature] = true
        table.insert(candidates, keys)
    end

    local ok, body = performGyroHttpGet(requestFn, source, baseUrl .. "/config")
    if ok and type(body) == "string" then
        local decodeOk, configData = pcall(function()
            return HttpService:JSONDecode(body)
        end)
        if decodeOk and type(configData) == "table" then
            if type(configData.inputs) == "table" then
                for _, input in ipairs(configData.inputs) do
                    if type(input) == "table"
                        and type(input.source) == "string"
                        and string.lower(input.source) == "gyroscope"
                        and type(input.outputs) == "table" then
                        for _, output in ipairs(input.outputs) do
                            if type(output) == "table" and output.x and output.y and output.z then
                                pushCandidate({
                                    x = output.x,
                                    y = output.y,
                                    z = output.z,
                                    label = "Phyphox gyroscope input",
                                })
                            end
                        end
                    end
                end
            end

            if type(configData.buffers) == "table" then
                local bufferNames = {}
                for _, entry in ipairs(configData.buffers) do
                    if type(entry) == "table" and type(entry.name) == "string" then
                        table.insert(bufferNames, entry.name)
                    elseif type(entry) == "string" then
                        table.insert(bufferNames, entry)
                    end
                end
                pushCandidate(inferPhyphoxGyroKeysFromNames(bufferNames))
            end
        end
    end

    for _, fallback in ipairs(PHYPHOX_GYRO_BUFFER_FALLBACKS) do
        pushCandidate(fallback)
    end

    return baseUrl, candidates
end

function tryApplyGyroPayload(data)
    if type(data) ~= "table" then
        return false, nil
    end

    local sample = gyro6dof.sample
    sample.hasAttitude = false
    sample.hasAccel = false
    sample.hasLinearAccel = false
    sample.hasGravity = false
    sample.hasEuler = false
    sample.attitudeCFrame = nil
    sample.accel = Vector3.zero
    sample.linearAccel = Vector3.zero
    sample.gravity = Vector3.zero
    sample.eulerDeg = Vector3.zero

    local hasGyroRates = false
    local hasAnySpatialSample = false

    if type(data.rotationRate) == "table" then
        local rr = data.rotationRate
        -- Browser DeviceMotion rotationRate usually reports deg/s.
        setGyroRawRates(
            rr.alpha or rr.Alpha or rr.z or rr.Z,
            rr.beta or rr.Beta or rr.x or rr.X,
            rr.gamma or rr.Gamma or rr.y or rr.Y,
            "deg"
        )
        hasGyroRates = true
        return true, "rotationRate"
    end

    if type(data.gyro) == "table" then
        setGyroRawRates(
            data.gyro.x or data.gyro.X or data.gyro.alpha or data.gyro.Alpha or data.gyro.z or data.gyro.Z,
            data.gyro.y or data.gyro.Y or data.gyro.beta or data.gyro.Beta or data.gyro.x or data.gyro.X,
            data.gyro.z or data.gyro.Z or data.gyro.gamma or data.gyro.Gamma or data.gyro.y or data.gyro.Y,
            "deg"
        )
        hasGyroRates = true
        return true, "gyro"
    end

    if type(data.attitude) == "table" then
        local att = data.attitude
        if tonumber(att.w or att.W or att.abs or att.Abs) ~= nil
            and tonumber(att.x or att.X) ~= nil
            and tonumber(att.y or att.Y) ~= nil
            and tonumber(att.z or att.Z) ~= nil then
            sample.attitudeCFrame = buildPhonePoseFromQuaternion(
                tonumber(att.w or att.W or att.abs or att.Abs) or 1,
                tonumber(att.x or att.X) or 0,
                tonumber(att.y or att.Y) or 0,
                tonumber(att.z or att.Z) or 0
            )
            sample.hasAttitude = true
            hasAnySpatialSample = true
        end
    elseif type(data.quaternion) == "table" then
        local quat = data.quaternion
        if tonumber(quat.w or quat.W or quat.abs or quat.Abs) ~= nil
            and tonumber(quat.x or quat.X) ~= nil
            and tonumber(quat.y or quat.Y) ~= nil
            and tonumber(quat.z or quat.Z) ~= nil then
            sample.attitudeCFrame = buildPhonePoseFromQuaternion(
                tonumber(quat.w or quat.W or quat.abs or quat.Abs) or 1,
                tonumber(quat.x or quat.X) or 0,
                tonumber(quat.y or quat.Y) or 0,
                tonumber(quat.z or quat.Z) or 0
            )
            sample.hasAttitude = true
            hasAnySpatialSample = true
        end
    end

    if not sample.hasAttitude then
        local topYawDeg = tonumber(data.yaw or data.Yaw)
        local topPitchDeg = tonumber(data.pitch or data.Pitch)
        local topRollDeg = tonumber(data.roll or data.Roll)
        if topYawDeg ~= nil and topPitchDeg ~= nil and topRollDeg ~= nil then
            sample.eulerDeg = Vector3.new(topYawDeg, topPitchDeg, topRollDeg)
            sample.hasEuler = true
            sample.attitudeCFrame = buildPhonePoseFromEulerDegrees(topYawDeg, topPitchDeg, topRollDeg)
            sample.hasAttitude = true
            hasAnySpatialSample = true
        end
    end

    local directX = tonumber(data.x or data.X or data.gx or data.GX or data.alpha or data.Alpha)
    local directY = tonumber(data.y or data.Y or data.gy or data.GY or data.beta or data.Beta)
    local directZ = tonumber(data.z or data.Z or data.gz or data.GZ or data.gamma or data.Gamma)
    if directX ~= nil and directY ~= nil and directZ ~= nil then
        setGyroRawRates(directX, directY, directZ, "deg")
        hasGyroRates = true
        return true, "xyz"
    end

    if type(data.buffer) == "table" then
        local bufferNames = {}
        for name in pairs(data.buffer) do
            table.insert(bufferNames, name)
        end

        local plan = gyro6dof.resolvedPlan or {}
        local gyroVec = readBufferTriplet(data.buffer, plan.gyro)
        if not gyroVec then
            local inferredGyro = inferPhyphoxGyroKeysFromNames(bufferNames)
            gyroVec = readBufferTriplet(data.buffer, inferredGyro)
            if not plan.gyro and inferredGyro then
                plan.gyro = inferredGyro
            end
        end
        if gyroVec then
            setGyroRawRates(gyroVec.X, gyroVec.Y, gyroVec.Z, "rad")
            hasGyroRates = true
            hasAnySpatialSample = true
        end

        local linearVec = readBufferTriplet(data.buffer, plan.linearAccel)
        if linearVec then
            sample.linearAccel = linearVec
            sample.hasLinearAccel = true
            hasAnySpatialSample = true
        end

        local accelVec = readBufferTriplet(data.buffer, plan.accel)
        if accelVec then
            sample.accel = accelVec
            sample.hasAccel = true
            hasAnySpatialSample = true
        end

        local gravityVec = readBufferTriplet(data.buffer, plan.gravity)
        if gravityVec then
            sample.gravity = gravityVec
            sample.hasGravity = true
            hasAnySpatialSample = true
        end

        local attitudeCFrame = readBufferQuaternion(data.buffer, plan.attitude)
        if attitudeCFrame then
            sample.attitudeCFrame = attitudeCFrame
            sample.hasAttitude = true
            hasAnySpatialSample = true
        end

        local eulerDeg = readBufferEuler(data.buffer, plan.euler)
        if eulerDeg then
            sample.eulerDeg = eulerDeg
            sample.hasEuler = true
            hasAnySpatialSample = true
            if not sample.hasAttitude then
                sample.attitudeCFrame = buildPhonePoseFromEulerDegrees(eulerDeg.X, eulerDeg.Y, eulerDeg.Z)
                sample.hasAttitude = true
            end
        end
    end

    if not hasGyroRates then
        setGyroRawRates(0, 0, 0, "rad")
    end

    if hasAnySpatialSample or hasGyroRates then
        local label = gyroResolvedLabel
            or (gyro6dof.resolvedPlan and gyro6dof.resolvedPlan.label)
            or (sample.hasAttitude and "attitude")
            or "sensor"
        return true, label
    end

    return false, nil
end

function requestGyroSample()
    if gyroFetchInFlight then return end
    if type(gyroUrl) ~= "string" or gyroUrl == "" then
        gyroLastStatus = "No URL"
        return
    end

    if gyroResolvedFromInputUrl ~= gyroUrl then
        gyroResolvedUrl = nil
        gyroResolvedLabel = nil
        gyroResolvedFromInputUrl = gyroUrl
        gyro6dof.resolvedPlan = nil
    end

    gyroFetchInFlight = true
    task.spawn(function()
        local requestFn, source = getGyroRequestAdapter()
        local function zeroGyro(statusText)
            gyroRawX = 0
            gyroRawY = 0
            gyroRawZ = 0
            gyroLastStatus = statusText
        end

        if requestFn == false then
            zeroGyro(source)
            gyroFetchInFlight = false
            return
        end

        local function decodeAndApply(body)
            if type(body) ~= "string" then
                return false, nil, "Bad Response"
            end
            local decodeOk, data = pcall(function()
                return HttpService:JSONDecode(body)
            end)
            if not decodeOk or type(data) ~= "table" then
                return false, nil, "Bad JSON"
            end

            local applied, label = tryApplyGyroPayload(data)
            if applied then
                gyroLastSampleAt = os.clock()
                return true, label, nil
            end

            return false, data, nil
        end

        local requestUrl = gyroResolvedUrl
        if not requestUrl then
            local baseUrl, plan = collectPhyphoxSensorPlan(requestFn, source, gyroUrl)
            if baseUrl and plan then
                local candidateUrl = buildPhyphoxGetUrl(baseUrl, plan.queryKeys)
                if candidateUrl then
                    gyroResolvedUrl = candidateUrl
                    gyroResolvedLabel = plan.label or "Phyphox"
                    gyro6dof.resolvedPlan = plan

                    local candidateOk, candidateBody = performGyroHttpGet(requestFn, source, candidateUrl)
                    if candidateOk then
                        local candidateApplied, candidateLabel = decodeAndApply(candidateBody)
                        if candidateApplied then
                            local label = candidateLabel or gyroResolvedLabel
                            gyroLastStatus = source .. " OK" .. (label and (" | " .. label) or "")
                            gyroFetchInFlight = false
                            return
                        end
                        requestUrl = candidateUrl
                    end
                end
            end
        end
        requestUrl = requestUrl or gyroUrl
        local ok, body, transportStatus = performGyroHttpGet(requestFn, source, requestUrl)
        if ok then
            local applied, payloadOrLabel, decodeStatus = decodeAndApply(body)
            if applied then
                local label = payloadOrLabel
                if requestUrl == gyroResolvedUrl and gyroResolvedLabel then
                    label = gyroResolvedLabel
                end
                gyroLastStatus = source .. " OK" .. (label and (" | " .. label) or "")
                gyroFetchInFlight = false
                return
            end

            local data = payloadOrLabel
            local looksLikePhyphox = type(data) == "table"
                and type(data.status) == "table"
                and type(data.buffer) == "table"

            if looksLikePhyphox then
                local baseUrl, plan = collectPhyphoxSensorPlan(requestFn, source, gyroUrl)
                if baseUrl and plan then
                    local candidateUrl = buildPhyphoxGetUrl(baseUrl, plan.queryKeys)
                    if candidateUrl and candidateUrl ~= requestUrl then
                        local candidateOk, candidateBody = performGyroHttpGet(requestFn, source, candidateUrl)
                        if candidateOk then
                            gyroResolvedUrl = candidateUrl
                            gyroResolvedLabel = plan.label or "Phyphox"
                            gyro6dof.resolvedPlan = plan
                            local candidateApplied = decodeAndApply(candidateBody)
                            if candidateApplied then
                                gyroLastStatus = source .. " OK | " .. gyroResolvedLabel
                                gyroFetchInFlight = false
                                return
                            end
                        end
                    end
                end

                if data.status.measuring == false then
                    zeroGyro("Phyphox paused")
                else
                    zeroGyro("Phyphox buffer kosong")
                end
            else
                zeroGyro(decodeStatus or (source .. " Error"))
            end
        else
            zeroGyro(transportStatus or (source .. " Error"))
        end

        gyroFetchInFlight = false
    end)
end

function updateGyroPolling(dt)
    gyroPollAccum = gyroPollAccum + dt
    local interval = 1 / math.max(1, gyroPollRate)
    if gyroPollAccum >= interval then
        gyroPollAccum = 0
        requestGyroSample()
    end
end

function readGyroDelta(steps, frameDt)
    local gx = gyroRawX
    local gy = -gyroRawY
    local gz = gyroRawZ
    local staleAfter = math.max(0.5, 3 / math.max(1, gyroPollRate))
    if gyroLastSampleAt > 0 and os.clock() - gyroLastSampleAt > staleAfter then
        gx = 0
        gy = 0
        gz = 0
    end

    if math.abs(gx) < gyroDeadzone then gx = 0 end
    if math.abs(gy) < gyroDeadzone then gy = 0 end
    if math.abs(gz) < gyroDeadzone then gz = 0 end
    gx = math.clamp(gx, -GYRO_MAX_RATE_DPS, GYRO_MAX_RATE_DPS)
    gy = math.clamp(gy, -GYRO_MAX_RATE_DPS, GYRO_MAX_RATE_DPS)
    gz = math.clamp(gz, -GYRO_MAX_RATE_DPS, GYRO_MAX_RATE_DPS)

    local alpha = math.clamp(gyroSmoothness, 0.01, 1)
    gyroSmoothX = gyroSmoothX + (gx - gyroSmoothX) * alpha
    gyroSmoothY = gyroSmoothY + (gy - gyroSmoothY) * alpha
    gyroSmoothZ = gyroSmoothZ + (gz - gyroSmoothZ) * alpha

    -- Normalize source units during parsing, then integrate the angular rate here.
    local dtStep = math.clamp((frameDt or 0) / math.max(steps, 1), 0, 0.05)
    local effectiveSensitivity = gyroSensitivity * GYRO_SENSOR_TO_CAMERA_SCALE
    return gyroSmoothX * effectiveSensitivity * gyroRateToRadScale * dtStep,
        gyroSmoothY * effectiveSensitivity * gyroRateToRadScale * dtStep,
        gyroSmoothZ * effectiveSensitivity * GYRO_ROLL_FACTOR * gyroRateToRadScale * dtStep
end

function getGyroLinearAccelerationDevice()
    local sample = gyro6dof.sample
    if sample.hasLinearAccel then
        return sample.linearAccel
    end

    if not sample.hasAccel then
        return nil
    end

    if sample.hasGravity then
        return sample.accel - sample.gravity
    end

    if sample.hasAttitude and sample.attitudeCFrame then
        local gravityDevice = sample.attitudeCFrame:VectorToObjectSpace(Vector3.new(0, -gyro6dof.earthGravityMs2, 0))
        return sample.accel - gravityDevice
    end

    return nil
end

function ensureGyroPoseCalibrated(referenceRot)
    local sample = gyro6dof.sample
    if not sample.hasAttitude or not sample.attitudeCFrame then
        return false
    end

    if not gyro6dof.basePhone or not gyro6dof.baseCamera then
        gyro6dof.basePhone = sample.attitudeCFrame
        gyro6dof.baseCamera = referenceRot or CFrame.new()
        gyro6dof.currentRot = referenceRot or gyro6dof.currentRot or CFrame.new()
    end

    return true
end

function getGyroDesiredRotation()
    local sample = gyro6dof.sample
    if not sample.hasAttitude or not sample.attitudeCFrame then
        return nil
    end
    if not gyro6dof.basePhone or not gyro6dof.baseCamera then
        return nil
    end

    local relativePhone = gyro6dof.basePhone:ToObjectSpace(sample.attitudeCFrame)
    return gyro6dof.baseCamera * relativePhone
end

function updateGyroMotionVector(camRot, speedNow, dt)
    local motionWorld = Vector3.zero
    local linearDevice = getGyroLinearAccelerationDevice()
    if linearDevice and camRot then
        local accelLocal = Vector3.new(
            applySignedDeadzone(linearDevice.X, gyro6dof.moveDeadzone),
            applySignedDeadzone(linearDevice.Y, gyro6dof.moveDeadzone) * gyro6dof.verticalAssist,
            -applySignedDeadzone(linearDevice.Z, gyro6dof.moveDeadzone)
        ) * gyro6dof.moveGain
        local accelWorld = camRot:VectorToWorldSpace(accelLocal)
        gyro6dof.worldVelocity = gyro6dof.worldVelocity + accelWorld * dt
    end

    local dampingAlpha = smooth(gyro6dof.moveDamping, dt)
    gyro6dof.worldVelocity = gyro6dof.worldVelocity + (Vector3.zero - gyro6dof.worldVelocity) * dampingAlpha
    local maxVel = math.max(speedNow * 3, speedNow + gyro6dof.moveGain)
    local velMag = gyro6dof.worldVelocity.Magnitude
    if velMag > maxVel and velMag > 1e-5 then
        gyro6dof.worldVelocity = gyro6dof.worldVelocity.Unit * maxVel
    end
    motionWorld = motionWorld + gyro6dof.worldVelocity

    if camRot and gyro6dof.basePhone and gyro6dof.sample.hasAttitude and gyro6dof.sample.attitudeCFrame then
        local relativePhone = gyro6dof.basePhone:ToObjectSpace(gyro6dof.sample.attitudeCFrame)
        local relPitch, _, relRoll = relativePhone:ToOrientation()
        local function tiltAxis(angle)
            local absAngle = math.abs(angle)
            if absAngle <= gyro6dof.tiltDeadzoneRad then
                return 0
            end
            local scaled = math.clamp(
                (absAngle - gyro6dof.tiltDeadzoneRad) / math.max(1e-4, (gyro6dof.maxTiltRad - gyro6dof.tiltDeadzoneRad)),
                0,
                1
            )
            return angle < 0 and -scaled or scaled
        end

        local tiltLocal = Vector3.new(
            tiltAxis(relRoll),
            0,
            -tiltAxis(relPitch)
        ) * (speedNow * gyro6dof.tiltGain)
        motionWorld = motionWorld + camRot:VectorToWorldSpace(tiltLocal)
    end

    return motionWorld
end

local MAX_STEP = 1 / 60
local UI_UPDATE_DT = 1 / 20
local uiUpdateAccum = 0

function wrapAngle(a)
    a = (a + math.pi) % TWO_PI
    return a - math.pi
end

function applyDeadzone(v, dz)
    local av = math.abs(v)
    if av <= dz then
        return 0
    end
    local scaled = (av - dz) / math.max(1e-4, (1 - dz))
    return (v < 0 and -scaled or scaled)
end

function applyExpo(v, expo)
    return v * (1 - expo) + (v * v * v) * expo
end

function applySuperRate(v, superRate)
    if superRate <= 0 then
        return v
    end
    local av = math.abs(v)
    local denom = math.max(1e-3, 1 - av * superRate)
    return v / denom
end

function applyRates(v, expo, superRate)
    local out = applyExpo(v, expo)
    out = applySuperRate(out, superRate)
    return math.clamp(out, -1, 1)
end

function applyActualRates(stickInput, centerSens, maxRate, expo)
    local stickAbs = math.abs(stickInput)
    local centerRate = centerSens
    local stickFactor = stickAbs * (1 - expo) + (stickAbs * stickAbs * stickAbs) * expo
    local rate = centerRate + (maxRate - centerRate) * stickFactor
    return rate * stickInput
end

function applyThrottleCurve(x, mid, expo)
    x = math.clamp(x, 0, 1)
    mid = math.clamp(mid, 0.05, 0.95)
    expo = math.clamp(expo, 0, 1)
    if x < mid then
        local t = x / mid
        local curved = t * (1 - expo) + (t * t) * expo
        return curved * mid
    else
        local t = (x - mid) / (1 - mid)
        local curved = t * (1 - expo) + (t * t) * expo
        return mid + curved * (1 - mid)
    end
end

function motorCommandToThrustFraction(command)
    command = math.clamp(command, 0, 1)
    return math.pow(command, DRONE_MOTOR_THRUST_EXPONENT)
end

function thrustFractionToMotorCommand(fraction)
    fraction = math.clamp(fraction, 0, 1)
    return math.pow(fraction, 1 / DRONE_MOTOR_THRUST_EXPONENT)
end

function thrustRatioToMotorCommand(thrustRatio, thrustToWeight)
    local maxRatio = math.max(0.1, thrustToWeight)
    return thrustFractionToMotorCommand(thrustRatio / maxRatio)
end

function computeDroneDragForce(rot, velocity)
    local bodyForward = rot:VectorToWorldSpace(BODY_FORWARD)
    local bodyRight = rot:VectorToWorldSpace(BODY_RIGHT)
    local bodyUp = rot:VectorToWorldSpace(BODY_UP)

    local velForward = velocity:Dot(bodyForward)
    local velRight = velocity:Dot(bodyRight)
    local velUp = velocity:Dot(bodyUp)

    local dragScalar = math.max(0, droneDrag)
    local dragForce = -(bodyForward * velForward * droneDragForward
        + bodyRight * velRight * droneDragSideways
        + bodyUp * velUp * droneDragVertical) * dragScalar

    local velMag = velocity.Magnitude
    if velMag > 0.1 then
        dragForce = dragForce - velocity * velMag * droneQuadDrag * dragScalar
    end

    return dragForce
end

function computeDroneGroundEffectForce(position, thrustDir, motorThrustFraction, massNow, gravityNow)
    if droneGroundEffectHeight <= 0 or droneGroundEffectStrength <= 0 then
        return Vector3.zero
    end

    local rayResult = workspace:Raycast(position, Vector3.new(0, -droneGroundEffectHeight, 0), droneGroundRayParams)
    if not rayResult then
        return Vector3.zero
    end

    local heightAboveGround = (position - rayResult.Position).Magnitude
    local geFactor = 1 - (heightAboveGround / droneGroundEffectHeight)
    geFactor = math.clamp(geFactor, 0, 1)
    local downwashToGround = math.max(0, thrustDir:Dot(BODY_UP))
    local geStrength = geFactor * geFactor * droneGroundEffectStrength
        * motorThrustFraction * massNow * gravityNow * downwashToGround
    return thrustDir * geStrength
end

function resolveDroneCollision(position, movement)
    local distance = movement.Magnitude
    if distance <= 1e-5 then
        return movement
    end

    local result = workspace:Raycast(position, movement, droneGroundRayParams)
    if not result then
        return movement
    end

    local dir = movement / distance
    local allowedDistance = math.max(0, result.Distance - DRONE_COLLISION_RADIUS)
    local normal = result.Normal
    local normalVelocity = droneVelocity:Dot(normal)
    if normalVelocity < 0 then
        local normalPart = normal * normalVelocity
        local tangentPart = droneVelocity - normalPart
        droneVelocity = tangentPart * DRONE_COLLISION_TANGENTIAL_KEEP - normalPart * DRONE_COLLISION_BOUNCE
        droneAngVel = droneAngVel * 0.65
    end

    return dir * allowedDistance
end

resetDronePhysicsState = function()
    for i = 1, 4 do
        droneMotorOutputs[i] = 0
    end
    droneMotorOutput = 0
    droneMotorCommand = 0
    droneBatterySag = 0
end

function updateDroneMotorOutputs(targets, dt)
    local totalCommand = 0
    local totalThrustFraction = 0
    for i = 1, 4 do
        local current = droneMotorOutputs[i] or 0
        local target = math.clamp(targets[i] or 0, 0, 1)
        local delta = target - current
        local motorRate
        if delta > 0 then
            motorRate = smooth(droneMotorSpinUp, dt)
        else
            motorRate = smooth(droneMotorSpinDown, dt)
        end
        current = current + delta * motorRate
        current = math.clamp(current, 0, 1)
        droneMotorOutputs[i] = current
        totalCommand = totalCommand + current
        totalThrustFraction = totalThrustFraction + motorCommandToThrustFraction(current)
    end

    droneMotorCommand = totalCommand * 0.25
    droneMotorOutput = totalThrustFraction * 0.25
    return droneMotorOutput
end

function getGamepadSticks()
    local lx, ly, rx, ry = 0, 0, 0, 0
    local state = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
    for _, input in ipairs(state) do
        if input.KeyCode == Enum.KeyCode.Thumbstick1 then
            lx, ly = input.Position.X, input.Position.Y
        elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
            rx, ry = input.Position.X, input.Position.Y
        end
    end
    return lx, ly, rx, ry
end

function gamepadConnected()
    local pads = UserInputService:GetConnectedGamepads()
    return pads and #pads > 0
end

function updateStickOverlay(lx, ly, rx, ry)
    if not stickOverlayVisible then return end
    if not uiRefs.leftStickDot or not uiRefs.rightStickDot then return end
    local function setDot(dot, x, y)
        x = math.clamp(x, -1, 1)
        y = math.clamp(y, -1, 1)
        dot.Position = UDim2.new(0.5 + x * 0.5, 0, 0.5 - y * 0.5, 0)
    end
    setDot(uiRefs.leftStickDot, lx, ly)
    setDot(uiRefs.rightStickDot, rx, ry)
end

table.insert(connections, RunService.RenderStepped:Connect(function(dt)
    if scriptKilled then return end

    local lx, ly, rx, ry = 0, 0, 0, 0
    local padActive = UserInputService.GamepadEnabled and gamepadConnected()
    if padActive then
        lx, ly, rx, ry = getGamepadSticks()
    end
    updateStickOverlay(lx, ly, rx, ry)

    if not freecam then return end
    if not refreshCameraReference() then return end
    cam.CameraType = Enum.CameraType.Scriptable
    if not currentCFrame or not targetCFrame then
        currentCFrame = cam.CFrame
        targetCFrame = cam.CFrame
    end
    syncDroneRaycastFilter()

    local isDrone = currentMode == "Drone"
    local isGyroscope = currentMode == "Gyroscope"
    local usingGamepad = isDrone and controlsEnabled and padActive
    local droneYawInput, dronePitchInput, droneRollInput, droneThrottleInput = 0, 0, 0, 0
    if usingGamepad then
        droneRollInput = -applyDeadzone(rx, droneDeadzone)
        droneThrottleInput = applyDeadzone(ly, droneDeadzone)
        droneYawInput = -applyDeadzone(lx, droneDeadzone)
        dronePitchInput = applyDeadzone(-ry, droneDeadzone)

        -- Yaw is always a rate, so we always apply rate curves to it
        if droneRateType == "Betaflight" then
            local yawDeg = applyActualRates(droneYawInput, droneActualCenter, droneActualMaxRate, droneActualExpo)
            droneYawInput = yawDeg / droneYawRate
        else
            droneYawInput = applyRates(droneYawInput, droneYawExpo, droneYawSuper)
        end

        if droneFlightMode == "Angle" then
            -- For Angle mode, pitch and roll inputs directly command tilt angle.
            -- Using Betaflight "MaxRate" causes them to exceed 1.0 and severely limits stick resolution.
            -- Apply simple expo for better center stick feel without inflating the max target angle.
            dronePitchInput = applyExpo(dronePitchInput, dronePitchExpo)
            droneRollInput = applyExpo(droneRollInput, droneRollExpo)
        else
            -- Acro & 3D mode: Pitch and Roll act as angular rates
            if droneRateType == "Betaflight" then
                local pitchDeg = applyActualRates(dronePitchInput, droneActualCenter, droneActualMaxRate, droneActualExpo)
                local rollDeg = applyActualRates(droneRollInput, droneActualCenter, droneActualMaxRate, droneActualExpo)
                
                dronePitchInput = pitchDeg / dronePitchRate
                droneRollInput = rollDeg / droneRollRate
            else
                dronePitchInput = applyRates(dronePitchInput, dronePitchExpo, dronePitchSuper)
                droneRollInput = applyRates(droneRollInput, droneRollExpo, droneRollSuper)
            end
        end
    end

    local boostDown = controlsEnabled and UserInputService:IsKeyDown(CONFIG.boostKey)
    local slowDown = controlsEnabled and not isGyroscope and UserInputService:IsKeyDown(CONFIG.slowKey)

    local inputVec = Vector3.zero
    if controlsEnabled and not usingGamepad then
        local verticalUp = (moveState[Enum.KeyCode.E] and 1 or 0)
        local verticalDown = (moveState[Enum.KeyCode.Q] and 1 or 0)
        if isGyroscope then
            verticalUp = verticalUp + (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0)
            verticalDown = verticalDown + (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)
        end
        inputVec = Vector3.new(
            (moveState[Enum.KeyCode.D] and 1 or 0) - (moveState[Enum.KeyCode.A] and 1 or 0),
            verticalUp - verticalDown,
            (moveState[Enum.KeyCode.S] and 1 or 0) - (moveState[Enum.KeyCode.W] and 1 or 0)
        )
    end
    local inputMag = inputVec.Magnitude
    local inputUnit = inputVec
    if inputMag > 0 then
        inputUnit = inputVec.Unit
    end

    local orbitPos
    local orbitActive = false
    if orbitEnabled and orbitTarget then
        if not orbitTarget.Parent then
            clearOrbitTarget()
        else
            orbitPos = getOrbitTargetPosition(orbitTarget)
            if orbitPos then
                orbitActive = true
            elseif not orbitTarget:IsA("Player") then
                clearOrbitTarget()
            end
        end
    end

    local yawRateRad, pitchRateRad, rollRateRad, maxTiltRad
    local droneMassNow, droneGNow, droneTwr, dronePower, hoverCurveBase
    -- MOI scaling (lower = snappier response)
    local moiPitchNow, moiRollNow, moiYawNow
    if usingGamepad then
        yawRateRad = math.rad(droneYawRate)
        pitchRateRad = math.rad(dronePitchRate)
        rollRateRad = math.rad(droneRollRate)
        if droneFlightMode == "Angle" then
            maxTiltRad = math.rad(droneAngleMaxTilt)
        end
        droneMassNow = math.max(0.1, droneMass)
        droneGNow = math.max(0, droneGravity)
        droneTwr = math.clamp(speed, 1, 20)
        dronePower = math.clamp(droneThrottlePower, 1, 3)
        moiPitchNow = math.max(0.2, droneMoiPitch)
        moiRollNow = math.max(0.2, droneMoiRoll)
        moiYawNow = math.max(0.2, droneMoiYaw)
        if droneFlightMode ~= "3D" then
            local hoverInput = math.clamp(droneHoverThrottle, 0.05, 0.95)
            hoverCurveBase = applyThrottleCurve(hoverInput, droneThrottleMid, droneThrottleExpo)
            hoverCurveBase = math.pow(hoverCurveBase, dronePower)
        end
    end

    local steps = math.max(1, math.ceil(dt / MAX_STEP))
    local stepDt = dt / steps
    local mouseStepX, mouseStepY = 0, 0
    if controlsEnabled and not usingGamepad and not isGyroscope then
        local mouseDelta = UserInputService:GetMouseDelta()
        mouseStepX = mouseDelta.X / steps
        mouseStepY = mouseDelta.Y / steps
    end
    local rotAlphaStep = smooth(rotSmooth, stepDt)
    local posAlphaStep = smooth(posSmooth, stepDt)
    local fovAlphaStep = smooth(fovSmooth, stepDt)
    local gyroStepYaw, gyroStepPitch, gyroStepRoll = 0, 0, 0
    local gyroDesiredRot = nil
    if isGyroscope and controlsEnabled then
        updateGyroPolling(dt)
        gyroStepYaw, gyroStepPitch, gyroStepRoll = readGyroDelta(steps, dt)
        local referenceRot = extractRotationCFrame(targetCFrame or currentCFrame or cam.CFrame)
        if ensureGyroPoseCalibrated(referenceRot) then
            gyroDesiredRot = getGyroDesiredRotation()
            if not gyro6dof.currentRot then
                gyro6dof.currentRot = referenceRot
            end
        end
    end
    local angleLevelAlphaStep
    local rateResponseAlphaStep
    if usingGamepad then
        rateResponseAlphaStep = smooth(droneRateResponse, stepDt)
        if droneFlightMode == "Angle" then
            angleLevelAlphaStep = smooth(droneAngleLevelStrength, stepDt)
        end
    end

    for i = 1, steps do
        local dt = stepDt

        local orbitKeyboardActive = orbitActive and currentMode == "Normal" and controlsEnabled and not usingGamepad
        if orbitKeyboardActive then
            local orbitDir = (moveState[Enum.KeyCode.D] and 1 or 0) - (moveState[Enum.KeyCode.A] and 1 or 0)
            local orbitVerticalDir = (moveState[Enum.KeyCode.S] and 1 or 0) - (moveState[Enum.KeyCode.W] and 1 or 0)
            if orbitDir ~= 0 then
                -- Keep the orbit target continuous so we don't snap when crossing 360 degrees.
                yawTarget = yawTarget + orbitDir * orbitSpinSpeed * dt
            end
            if orbitVerticalDir ~= 0 then
                -- Keep vertical orbit continuous so W/S can pass over the poles without a snap.
                pitchTarget = pitchTarget + orbitVerticalDir * orbitSpinSpeed * dt
            end
        end

        -- Look input
        if controlsEnabled then
            if isGyroscope then
                if not gyroDesiredRot then
                    yawTarget = yawTarget + gyroStepYaw
                    pitchTarget = pitchTarget + gyroStepPitch
                    rollTarget = rollTarget + gyroStepRoll
                end
            elseif not usingGamepad then
                yawTarget = yawTarget - mouseStepX * sensitivity * 0.01
                pitchTarget = pitchTarget - mouseStepY * sensitivity * 0.01
            end
            if not gyroDesiredRot and not (orbitActive and currentMode == "Normal" and controlsEnabled and not usingGamepad) then
                pitchTarget = math.clamp(pitchTarget, -pitchClamp, pitchClamp)
            end
        end

        local targetMotorCmd = 0
        local acroThrustForce = Vector3.zero
        if usingGamepad and droneFlightMode == "Acro" then
            -- Acro uses the command precompute only to shape motor authority.
            local throttleRaw = (droneThrottleInput + 1) * 0.5
            droneThrottleState = droneThrottleState + (throttleRaw - droneThrottleState) * smooth(droneThrustResponse, dt)
            droneThrottleState = math.clamp(droneThrottleState, 0, 1)

            local throttleCurve = applyThrottleCurve(droneThrottleState, droneThrottleMid, droneThrottleExpo)
            throttleCurve = math.pow(throttleCurve, dronePower)

            local ratio2
            if throttleCurve >= hoverCurveBase then
                ratio2 = 1 + (throttleCurve - hoverCurveBase) / math.max(1e-3, (1 - hoverCurveBase)) * (droneTwr - 1)
            else
                ratio2 = throttleCurve / math.max(1e-3, hoverCurveBase)
            end
            ratio2 = math.max(0, ratio2)
            targetMotorCmd = thrustRatioToMotorCommand(ratio2, droneTwr)
        end

        local rot
        if usingGamepad then
            if droneFlightMode == "Angle" then
                -- === ANGLE MODE with coordinated turns ===
                local targetPitch = math.clamp(dronePitchInput, -1, 1) * maxTiltRad
                local targetRoll = math.clamp(droneRollInput, -1, 1) * maxTiltRad
                local levelAlpha = angleLevelAlphaStep or smooth(droneAngleLevelStrength, dt)
                droneAngVel = Vector3.zero

                pitch = pitch + (targetPitch - pitch) * levelAlpha
                roll = roll + (targetRoll - roll) * levelAlpha

                -- Yaw: stick yaw + coordinated turn yaw from roll angle
                local coordYaw = math.sin(roll) * droneAngleYawCoord * yawRateRad * dt
                yaw = wrapAngle(yaw + yawRateRad * droneYawInput * dt + coordYaw)

                rot = CFrame.Angles(0, yaw, 0) *
                    CFrame.Angles(pitch, 0, 0) *
                    CFrame.Angles(0, 0, roll)
                droneOrient = rot
            elseif droneFlightMode == "3D" then
                -- === 3D MODE with MOI tensor ===
                if not droneOrient then
                    droneOrient = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll)
                end

                -- Target angular rates (deg/s converted to rad/s already)
                local targetRates = Vector3.new(
                    pitchRateRad * dronePitchInput,
                    yawRateRad * droneYawInput,
                    rollRateRad * droneRollInput
                )

                -- Apply MOI: higher MOI = slower angular acceleration
                -- Angular acceleration = torque / MOI, we model this as rate of rate-change scaled by 1/MOI
                local rateAlphaBase = rateResponseAlphaStep or smooth(droneRateResponse, dt)
                local pitchRateAlpha = math.clamp(rateAlphaBase / moiPitchNow, 0, 1)
                local rollRateAlpha = math.clamp(rateAlphaBase / moiRollNow, 0, 1)
                local yawRateAlpha = math.clamp(rateAlphaBase / moiYawNow, 0, 1)

                droneAngVel = Vector3.new(
                    droneAngVel.X + (targetRates.X - droneAngVel.X) * pitchRateAlpha,
                    droneAngVel.Y + (targetRates.Y - droneAngVel.Y) * yawRateAlpha,
                    droneAngVel.Z + (targetRates.Z - droneAngVel.Z) * rollRateAlpha
                )

                -- Angular damping
                local damp = math.clamp(droneAngularDamping, 0, 5)
                if damp > 0 then
                    local dampFactor = math.max(0, 1 - damp * dt)
                    droneAngVel = droneAngVel * dampFactor
                end

                -- === PROPWASH OSCILLATION ===
                -- Detect if drone is descending into its own propwash
                if dronePropwashStrength > 0 then
                    local bodyUp = droneOrient:VectorToWorldSpace(BODY_UP)
                    local velMag = droneVelocity.Magnitude
                    if velMag > 1 then
                        local velDir = droneVelocity / velMag
                        -- Dot product: how much velocity is aligned opposite to body-up (descending into prop stream)
                        local propwashDot = -bodyUp:Dot(velDir)
                        -- Only trigger when descending roughly along body-up axis
                        local propwashZoneFactor = math.clamp(propwashDot - (1 - dronePropwashZone), 0, dronePropwashZone)
                        if propwashZoneFactor > 0 then
                            local descentSpeed = math.max(0, -droneVelocity:Dot(bodyUp))
                            local pwIntensity = (propwashZoneFactor / math.max(0.01, dronePropwashZone))
                                * dronePropwashStrength
                                * math.clamp(descentSpeed / 20, 0, 1)
                                * math.clamp(droneMotorOutput, 0, 1)
                            if pwIntensity > 0 then
                                dronePropwashPhase = (dronePropwashPhase + (8 + descentSpeed * 0.35 + velMag * 0.15) * dt) % TWO_PI
                                local phase = dronePropwashPhase
                                local pwPitch = math.sin(phase * 1.31 + 1.3) * pwIntensity * pitchRateRad * 0.08
                                local pwRoll = math.sin(phase * 1.73 + 3.7) * pwIntensity * rollRateRad * 0.08
                                local pwYaw = math.sin(phase * 2.11 + 5.1) * pwIntensity * yawRateRad * 0.05
                                droneAngVel = droneAngVel + Vector3.new(pwPitch, pwYaw, pwRoll)
                            end
                        end
                    end
                end

                if droneFullRotation then
                    droneOrient = droneOrient * CFrame.Angles(
                        droneAngVel.X * dt,
                        droneAngVel.Y * dt,
                        droneAngVel.Z * dt
                    )
                    local rx, ry, rz = droneOrient:ToOrientation()
                    pitch, yaw, roll = rx, ry, rz
                else
                    yaw = wrapAngle(yaw + droneAngVel.Y * dt)
                    pitch = math.clamp(pitch + droneAngVel.X * dt, -pitchClamp, pitchClamp)
                    roll = wrapAngle(roll + droneAngVel.Z * dt)
                    droneOrient = CFrame.Angles(0, yaw, 0)
                        * CFrame.Angles(pitch, 0, 0)
                        * CFrame.Angles(0, 0, roll)
                end
                rot = droneOrient
            else
                -- === ACRO MODE with motor mixer and torque response ===
                if not droneOrient then
                    droneOrient = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll)
                end

                local targetRates = Vector3.new(
                    pitchRateRad * dronePitchInput,
                    yawRateRad * droneYawInput,
                    rollRateRad * droneRollInput
                )

                local rateAlphaBase = rateResponseAlphaStep or smooth(droneRateResponse, dt)
                local inertiaScale = 1 + math.clamp(droneInertia, 0, 1) * 1.35
                local pitchError = math.clamp((targetRates.X - droneAngVel.X) / math.max(1, pitchRateRad * 0.35), -1, 1)
                local rollError = math.clamp((targetRates.Z - droneAngVel.Z) / math.max(1, rollRateRad * 0.35), -1, 1)
                local yawError = math.clamp((targetRates.Y - droneAngVel.Y) / math.max(1, yawRateRad * 0.45), -1, 1)
                local controlAuthority = motorCommandToThrustFraction(targetMotorCmd)
                local controlGain = math.clamp((0.08 + controlAuthority * 0.72) * (0.75 + rateAlphaBase) / inertiaScale, 0, 1)
                local pitchCtrl = pitchError * controlGain
                local rollCtrl = rollError * controlGain
                local yawCtrl = yawError * controlGain

                local motorTargets = {
                    math.clamp(targetMotorCmd - pitchCtrl + rollCtrl - yawCtrl, 0, 1),
                    math.clamp(targetMotorCmd - pitchCtrl - rollCtrl + yawCtrl, 0, 1),
                    math.clamp(targetMotorCmd + pitchCtrl - rollCtrl - yawCtrl, 0, 1),
                    math.clamp(targetMotorCmd + pitchCtrl + rollCtrl + yawCtrl, 0, 1),
                }
                local motorAvg = updateDroneMotorOutputs(motorTargets, dt)

                local load = math.clamp(motorAvg, 0, 1)
                local activity = math.max(math.abs(pitchCtrl), math.abs(rollCtrl), math.abs(yawCtrl))
                local sagTarget = math.clamp(load * 0.85 + activity * 0.35, 0, 1)
                droneBatterySag = droneBatterySag + (sagTarget - droneBatterySag) * smooth(math.max(1.2, droneMotorSpinDown * 0.18), dt)
                local batteryFactor = math.clamp(1 - droneBatterySag * DRONE_BATTERY_SAG_MAX, 0.80, 1)

                local perMotorThrust = droneMassNow * droneGNow * droneVertMult * droneTwr * batteryFactor * 0.25
                local motorThrust1 = motorCommandToThrustFraction(droneMotorOutputs[1]) * perMotorThrust
                local motorThrust2 = motorCommandToThrustFraction(droneMotorOutputs[2]) * perMotorThrust
                local motorThrust3 = motorCommandToThrustFraction(droneMotorOutputs[3]) * perMotorThrust
                local motorThrust4 = motorCommandToThrustFraction(droneMotorOutputs[4]) * perMotorThrust
                local totalThrust = motorThrust1 + motorThrust2 + motorThrust3 + motorThrust4

                local pitchTorque = ((motorThrust3 + motorThrust4) - (motorThrust1 + motorThrust2)) * DRONE_ARM_LENGTH
                local rollTorque = ((motorThrust1 + motorThrust4) - (motorThrust2 + motorThrust3)) * DRONE_ARM_LENGTH
                local yawTorque = ((motorThrust2 + motorThrust4) - (motorThrust1 + motorThrust3)) * DRONE_YAW_TORQUE

                local angAccel = Vector3.new(
                    pitchTorque / math.max(0.2, moiPitchNow * inertiaScale),
                    yawTorque / math.max(0.2, moiYawNow * inertiaScale),
                    rollTorque / math.max(0.2, moiRollNow * inertiaScale)
                )
                droneAngVel = droneAngVel + angAccel * dt

                local damp = math.clamp(droneAngularDamping, 0, 5)
                if damp > 0 then
                    local dampFactor = math.max(0, 1 - damp * dt)
                    droneAngVel = droneAngVel * dampFactor
                end

                if dronePropwashStrength > 0 then
                    local bodyUp = droneOrient:VectorToWorldSpace(BODY_UP)
                    local velMag = droneVelocity.Magnitude
                    if velMag > 1 then
                        local velDir = droneVelocity / velMag
                        local propwashDot = -bodyUp:Dot(velDir)
                        local propwashZoneFactor = math.clamp(propwashDot - (1 - dronePropwashZone), 0, dronePropwashZone)
                        if propwashZoneFactor > 0 then
                            local descentSpeed = math.max(0, -droneVelocity:Dot(bodyUp))
                            local pwIntensity = (propwashZoneFactor / math.max(0.01, dronePropwashZone))
                                * dronePropwashStrength
                                * math.clamp(descentSpeed / 20, 0, 1)
                                * math.clamp(motorAvg, 0, 1)
                            if pwIntensity > 0 then
                                dronePropwashPhase = (dronePropwashPhase + (8 + descentSpeed * 0.35 + velMag * 0.15) * dt) % TWO_PI
                                local phase = dronePropwashPhase
                                local pwPitch = math.sin(phase * 1.31 + 1.3) * pwIntensity * pitchRateRad * 0.08
                                local pwRoll = math.sin(phase * 1.73 + 3.7) * pwIntensity * rollRateRad * 0.08
                                local pwYaw = math.sin(phase * 2.11 + 5.1) * pwIntensity * yawRateRad * 0.05
                                droneAngVel = droneAngVel + Vector3.new(pwPitch, pwYaw, pwRoll)
                            end
                        end
                    end
                end

                if droneFullRotation then
                    droneOrient = droneOrient * CFrame.Angles(
                        droneAngVel.X * dt,
                        droneAngVel.Y * dt,
                        droneAngVel.Z * dt
                    )
                    local rx, ry, rz = droneOrient:ToOrientation()
                    pitch, yaw, roll = rx, ry, rz
                else
                    yaw = wrapAngle(yaw + droneAngVel.Y * dt)
                    pitch = math.clamp(pitch + droneAngVel.X * dt, -pitchClamp, pitchClamp)
                    roll = wrapAngle(roll + droneAngVel.Z * dt)
                    droneOrient = CFrame.Angles(0, yaw, 0)
                        * CFrame.Angles(pitch, 0, 0)
                        * CFrame.Angles(0, 0, roll)
                end
                rot = droneOrient
                acroThrustForce = droneOrient:VectorToWorldSpace(BODY_UP) * totalThrust
            end
        else
            if isGyroscope and gyroDesiredRot then
                local currentRot = gyro6dof.currentRot or extractRotationCFrame(currentCFrame or targetCFrame or cam.CFrame)
                gyro6dof.currentRot = currentRot:Lerp(gyroDesiredRot, rotAlphaStep)
                rot = gyro6dof.currentRot
                pitch, yaw, roll = rot:ToOrientation()
                pitchTarget, yawTarget, rollTarget = pitch, yaw, roll
            else
                yaw = yaw + (yawTarget - yaw) * rotAlphaStep
                pitch = pitch + (pitchTarget - pitch) * rotAlphaStep

                -- Roll per mode
                if isDrone then
                    roll = 0
                elseif isGyroscope then
                    roll = roll + (rollTarget - roll) * rotAlphaStep
                else
                    -- Normal manual roll
                    local rollDir = controlsEnabled and ((rollState[CONFIG.rollRightKey] and 1 or 0) - (rollState[CONFIG.rollLeftKey] and 1 or 0)) or 0
                    roll = roll + rollDir * rollSpeed * dt
                end

                rot =
                    CFrame.Angles(0, yaw, 0) *
                    CFrame.Angles(pitch, 0, 0) *
                    CFrame.Angles(0, 0, roll)
            end
        end

        local camRot = rot
        if isDrone then
            camRot = rot * CFrame.Angles(math.rad(droneCameraTilt), 0, 0)
        end

        if orbitActive then
            local orbitRot = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
            local offset = orbitRot:VectorToWorldSpace(Vector3.new(0, 0, orbitRadius))
            local desiredPos = orbitPos + offset
            local orbitUp = orbitRot:VectorToWorldSpace(BODY_UP)
            targetCFrame = CFrame.lookAt(desiredPos, orbitPos, orbitUp) * CFrame.Angles(0, 0, roll)
        else
            local move = Vector3.zero
            if not orbitEnabled and controlsEnabled then
                if usingGamepad then
                    if droneFlightMode == "Acro" then
                        -- Use the torque-based motor model from the rotation step.
                        local thrustForce = acroThrustForce
                        local gravityForce = Vector3.new(0, -droneGNow * droneMassNow, 0)
                        local dronePos = (targetCFrame or currentCFrame or cam.CFrame).Position
                        local thrustDir = rot:VectorToWorldSpace(BODY_UP)
                        local dragForce = computeDroneDragForce(rot, droneVelocity)
                        local groundEffectForce = computeDroneGroundEffectForce(dronePos, thrustDir, droneMotorOutput, droneMassNow, droneGNow)
                        local totalForce = thrustForce + gravityForce + dragForce + groundEffectForce
                        local accel = totalForce / math.max(0.01, droneMassNow)
                        droneVelocity = droneVelocity + accel * dt
                        move = droneVelocity * dt
                    else
                        -- === THROTTLE / THRUST COMPUTATION ===
                        local targetMotor
                        local thrustSign = 1

                        if droneFlightMode == "3D" then
                            -- 3D mode: stick center = 0 thrust, up = +thrust, down = -thrust (symmetric)
                            local signed = math.clamp(droneThrottleInput, -1, 1)
                            droneThrottleState = droneThrottleState + (signed - droneThrottleState) * smooth(droneThrustResponse, dt)
                            droneThrottleState = math.clamp(droneThrottleState, -1, 1)
                            local absVal = math.abs(droneThrottleState)
                            local curved = math.pow(absVal, dronePower)
                            local signedCurve = (droneThrottleState < 0 and -curved or curved)
                            -- Symmetric: no penalty for reverse thrust in 3D mode
                            targetMotor = thrustFractionToMotorCommand(math.abs(signedCurve))
                            thrustSign = signedCurve < 0 and -1 or 1
                        else
                            -- Acro / Angle: stick low = 0 thrust, stick high = max
                            local throttleRaw = (droneThrottleInput + 1) * 0.5
                            droneThrottleState = droneThrottleState + (throttleRaw - droneThrottleState) * smooth(droneThrustResponse, dt)
                            droneThrottleState = math.clamp(droneThrottleState, 0, 1)

                            local throttleCurve = applyThrottleCurve(droneThrottleState, droneThrottleMid, droneThrottleExpo)
                            throttleCurve = math.pow(throttleCurve, dronePower)

                            local ratio2
                            if throttleCurve >= hoverCurveBase then
                                ratio2 = 1 + (throttleCurve - hoverCurveBase) / math.max(1e-3, (1 - hoverCurveBase)) * (droneTwr - 1)
                            else
                                ratio2 = throttleCurve / math.max(1e-3, hoverCurveBase)
                            end
                            ratio2 = math.max(0, ratio2)
                            targetMotor = thrustRatioToMotorCommand(ratio2, droneTwr)
                        end

                        -- === ASYMMETRIC MOTOR RESPONSE ===
                        -- Motors spin up faster than they spin down
                        targetMotor = math.clamp(targetMotor, 0, 1)
                        local motorDelta = targetMotor - droneMotorCommand
                        local motorRate
                        if motorDelta > 0 then
                            motorRate = smooth(droneMotorSpinUp, dt)
                        else
                            motorRate = smooth(droneMotorSpinDown, dt)
                        end
                        droneMotorCommand = droneMotorCommand + motorDelta * motorRate
                        droneMotorCommand = math.clamp(droneMotorCommand, 0, 1)
                        droneMotorOutput = motorCommandToThrustFraction(droneMotorCommand)

                        local sagTarget = math.clamp(droneMotorOutput * 0.85, 0, 1)
                        droneBatterySag = droneBatterySag + (sagTarget - droneBatterySag) * smooth(math.max(1.2, droneMotorSpinDown * 0.18), dt)
                        local batteryFactor = math.clamp(1 - droneBatterySag * DRONE_BATTERY_SAG_MAX, 0.80, 1)
                        local maxThrust = droneTwr * droneMassNow * droneGNow * droneVertMult * batteryFactor
                        local effectiveThrust = thrustSign * droneMotorOutput * maxThrust

                        -- Thrust direction (always body-local up)
                        local thrustDir = rot:VectorToWorldSpace(BODY_UP)
                        local thrustForce = thrustDir * effectiveThrust

                        -- Gravity
                        local gravityForce = Vector3.new(0, -droneGNow * droneMassNow, 0)
                        local dronePos = (targetCFrame or currentCFrame or cam.CFrame).Position
                        local dragForce = computeDroneDragForce(rot, droneVelocity)
                        local groundMotorFraction = thrustSign > 0 and droneMotorOutput or 0
                        local groundEffectForce = computeDroneGroundEffectForce(dronePos, thrustDir, groundMotorFraction, droneMassNow, droneGNow)

                        -- === TOTAL ACCELERATION ===
                        local totalForce = thrustForce + gravityForce + dragForce + groundEffectForce
                        local accel = totalForce / math.max(0.01, droneMassNow)

                        -- Euler integration (massa sejati secara inheren mengatur momentum translasi, percepatan = F/m)
                        droneVelocity = droneVelocity + accel * dt
                        move = droneVelocity * dt
                    end
                else
                    if isDrone then
                        droneVelocity = Vector3.zero
                        droneThrottleState = 0
                        resetDronePhysicsState()
                    end
                    if inputMag > 0 or isGyroscope then
                        local speedNow = speed
                        if boostDown then
                            speedNow = speedNow * boostMultiplier
                        elseif slowDown then
                            speedNow = speedNow * slowMultiplier
                        end

                        if isDrone or isGyroscope then
                            -- Body-relative move is more precise than yaw-only movement.
                            if isDrone then
                                local localMove = Vector3.new(
                                    inputVec.X,
                                    inputVec.Y * droneVertMult,
                                    inputVec.Z
                                )
                                move = rot:VectorToWorldSpace(localMove) * speedNow * dt
                            else
                                local keyboardWorld = Vector3.zero
                                if inputMag > 0 then
                                    local horizontalMove = camRot:VectorToWorldSpace(Vector3.new(inputVec.X, 0, inputVec.Z))
                                    keyboardWorld = (horizontalMove + Vector3.new(0, inputVec.Y, 0)) * speedNow
                                end
                                local gyroWorld = controlsEnabled and updateGyroMotionVector(camRot, speedNow, dt) or Vector3.zero
                                move = (keyboardWorld + gyroWorld) * dt
                            end
                        else
                            -- Normal full 3D movement
                            move = rot:VectorToWorldSpace(inputUnit) * speedNow * dt
                        end
                    end
                end
            else
                if isDrone then
                    droneVelocity = Vector3.zero
                    droneThrottleState = 0
                    resetDronePhysicsState()
                elseif isGyroscope then
                    gyro6dof.worldVelocity = gyro6dof.worldVelocity + (Vector3.zero - gyro6dof.worldVelocity) * smooth(gyro6dof.moveDamping, dt)
                end
            end

            local baseCFrame = targetCFrame or currentCFrame or cam.CFrame
            if not baseCFrame then
                return
            end
            if usingGamepad then
                move = resolveDroneCollision(baseCFrame.Position, move)
            end
            targetCFrame = CFrame.new(baseCFrame.Position + move) * camRot
        end

        currentCFrame = (currentCFrame or targetCFrame or cam.CFrame):Lerp(targetCFrame or currentCFrame or cam.CFrame, posAlphaStep)
        cam.CFrame = currentCFrame
        cam.FieldOfView = cam.FieldOfView + (targetFov - cam.FieldOfView) * fovAlphaStep
        if i == steps then
            updateOrbitPickPreview()
        end
        updateDofAutoFocus(dt)
        uiUpdateAccum = uiUpdateAccum + dt
        if i == steps then
            if uiUpdateAccum >= UI_UPDATE_DT then
                refreshUiText()
                uiUpdateAccum = 0
            end
        end
    end
end))
