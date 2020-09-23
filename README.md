# ui3d2d
A simple and optimised library for drawing 3D2D UIs in Garry's Mod. Supports both immediate mode drawing and VGUI (found in the extras file).

# Example Usage
## Adding UI to an entity:
```lua
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local pos = Vector(0, 0, 0)
local angles = Angle(0, 0, 0)

local color_red = Color(255, 0, 0)

function ENT:DrawTranslucent()
    if not ui3d2d.startDraw(self:WorldToLocal(pos), self:WorldToLocalAngles(angles), .1, self) then return end --Skip drawing if the player can't see the UI

    --Draw your UI here
    surface.SetFont("DermaLarge")
    local w, h = surface.GetTextSize("Hover me!")

    draw.RoundedBox(0, 0, 0, w, h, color_white)

    if ui3d2d.isPressed() then --Flash red if input was pressed this frame
        draw.RoundedBox(0, 0, 0, w, h, color_red)
    end

    if ui3d2d.isHovering(0, 0, w, h) then --Check if the box is being hovered
        if ui3d2d.isPressing() then --Check if input is being held
            draw.SimpleText("Wow!", nil, 0, 0, color_black)
        else
            draw.SimpleText("Click me!", nil, 0, 0, color_black)
        end
    else
        draw.SimpleText("Hover me!", nil, 0, 0, color_black)
    end

    ui3d2d.endDraw() --Finish the UI render
end
```

## Adding UI to the world:
```lua
local pos = Vector(0, 0, 0)
local angles = Angle(0, 0, 0)

hook.Add("PostDrawTranslucentRenderables", "DrawMyUI", function(_, depthDrawing)
    if depthDrawing then return end

    if ui3d2d.startDraw(pos, angles, .1) then
        --Draw your UI here
        ui3d2d.endDraw()
    end
end)
```

# Global Functions
## ui3d2d.startDraw
```lua
ui3d2d.startDraw(pos :: Vector, angles :: Angle, scale :: number, ignoredEntity :: Entity) :: boolean
```
This starts a UI3D2D rendering context in immediate mode, calling this will calculate your mouse position and input status for the same frame.
- The ignoredEntity paramater is optional, this is used for disabling eyetrace collisions with the entity you're attaching your UI to.

## ui3d2d.endDraw
```lua
ui3d2d.endDraw()
```
This ends a UI3D2D rendering context, only call this if you have called startDraw already and it has returned true.

## ui3d2d.isPressing
```lua
ui3d2d.isPressing() :: boolean
```
This returns true if the user is holding down the UI input key.

## ui3d2d.isPressed
```lua
ui3d2d.isPressed() :: boolean
```
This returns true if the user started pressing the UI input key on this frame.

## ui3d2d.getCursorPos
```lua
ui3d2d.getCursorPos() :: number, number
```
This returns two numbers, the x and y values of the cursor position on the current UI.
- This will return nil if the player isn't looking at the UI.

## ui3d2d.isHovering
```lua
ui3d2d.isHovering(x :: number, y :: number, w :: number, h :: number) :: boolean
```
This will return true if the cursor is currently within the bounds of the box specified in the parameters.

## ui3d2d.drawVgui (Extra only)
```lua
ui3d2d.drawVgui(panel :: Panel, pos :: Vector, angles :: Angle, scale :: number, ignoredEntity :: Entity)
```
This will draw a VGUI panel in 3D space and allow the user to interact with it. **This may not work always work as intended.**
- The ignoredEntity paramater is optional, this is used for disabling eyetrace collisions with the entity you're attaching your UI to.

# Credits
- The main library code was based on [IMGUI by Wyozi](https://github.com/wyozi-gmod/imgui).
- The VGUI feature was based on [3d2d-vgui by handsomematt](https://github.com/handsomematt/3d2d-vgui).
