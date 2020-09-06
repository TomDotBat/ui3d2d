
ui3d2d = {}

do --Input handling
    local inputEnabled, isPressing, isPressed

    hook.Add("PreRender", "ui3d2d.inputHandler", function() --Check the input state before rendering UIs
        if render.GetRenderTarget() then inputEnabled = false return end
        if vgui.CursorVisible() then inputEnabled = false return end

        inputEnabled = true

        local wasPressing = isPressing
        isPressing = input.IsMouseDown(MOUSE_LEFT) or input.IsKeyDown(KEY_E)
        isPressed = not wasPressing and isPressing
    end)

    function ui3d2d.isPressing() --Returns true if an input is being held
        return inputEnabled and isPressing
    end

    function ui3d2d.isPressed() --Returns true if an input was pressed this frame
        return inputEnabled and isPressed
    end
end

do
    local localPlayer

    hook.Add("PreRender", "ui3d2d.getLocalPlayer", function() --Keep getting the local player until it's available
        localPlayer = LocalPlayer()
        if IsValid(localPlayer) then hook.Remove("PreRender", "ui3d2d.getLocalPlayer") end
    end)

    local baseQuery = {filter = {}}
    local function isObstructed(eyePos, hitPos, ignoredEntity) --Check if the cursor trace is obstructed by another ent
        local query = baseQuery
        query.start = eyePos
        query.endpos = hitPos
        query.filter[1] = localPlayer
        query.filter[2] = ignoredEntity

        return util.TraceLine(query).Hit
    end

    local mouseX, mouseY
    local isRendering

    function ui3d2d.startDraw(pos, angles, scale, ignoredEntity) --Starts a new 3d2d ui rendering context
        if isRendering then print("[ui3d2d] Attempted to draw a new 3d2d ui without ending the previous one.") return end

        local eyePos = localPlayer:EyePos()
        local eyePosToUi = pos - eyePos

        do --Only draw the UI if the player is in front of it
            local normal = angles:Up()
            local dot = eyePosToUi:Dot(normal)

            if dot >= 0 then return end
        end

        isRendering = true
        mouseX, mouseY = nil, nil

        cam.Start3D2D(pos, angles, scale)

        local cursorVisible, hoveringWorld = vgui.CursorVisible(), vgui.IsHoveringWorld()
        if not hoveringWorld and cursorVisible then return true end

        local eyeNormal
        do
            if cursorVisible and hoveringWorld then
                eyeNormal = gui.ScreenToVector(gui.MousePos())
            else
                eyeNormal = localPlayer:GetEyeTrace().Normal
            end
        end

        local hitPos = util.IntersectRayWithPlane(eyePos, eyeNormal, pos, angles:Up())
        if not hitPos then return true end

        local obstructed = isObstructed(eyePos, hitPos, ignoredEntity)
        if obstructed then return true end

        local diff = pos - hitPos
        mouseX = diff:Dot(-angles:Forward()) / scale
        mouseY = diff:Dot(-angles:Right()) / scale

        return true
    end

    function ui3d2d.endDraw() --Safely ends the 3d2d ui rendering context
        if not isRendering then print("[ui3d2d] Attempted to end a non-existant 3d2d ui rendering context.") return end
        isRendering = false
        cam.End3D2D()
    end

    function ui3d2d.getCursorPos() --Returns the current 3d2d cursor position
        return mouseX, mouseY
    end

    function ui3d2d.isHovering(x, y, w, h) --Returns whether the cursor is within a specified area
        local mx, my = mouseX, mouseY
        return mx and my and mx >= x and mx <= (x + w) and my >= y and my <= (y + h)
    end
end