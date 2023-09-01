--[[
	UI3D2D - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

if not ui3d2d then return end

do --3d2d VGUI Drawing
    local insert = table.insert

    local function getParents(panel)
        local parents = {}
        local parent = panel:GetParent()

        while parent do
            insert(parents, parent)
            parent = parent:GetParent()
        end

        return parents
    end

    local ipairs = ipairs

    local function absolutePanelPos(panel)
        local x, y = panel:GetPos()
        local parents = getParents(panel)

        for _, parent in ipairs(parents) do
            local parentX, parentY = parent:GetPos()
            x = x + parentX
            y = y + parentY
        end

        return x, y
    end

    local function pointInsidePanel(panel, x, y)
        local absoluteX, absoluteY = absolutePanelPos(panel)
        local width, height = panel:GetSize()

        return panel:IsVisible() and x >= absoluteX and y >= absoluteY and x <= absoluteX + width and y <= absoluteY + height
    end

    local pairs = pairs
    local reverseTable = table.Reverse

    local function checkHover(panel, x, y, found, hoveredPanel)
        local validChild = false
        for _, child in pairs(reverseTable(panel:GetChildren())) do
            if not child:IsMouseInputEnabled() then continue end

            if checkHover(child, x, y, found or validChild) then validChild = true end
        end

        if not panel.isUi3d2dSetup then
            panel.IsHovered = function(s)
                return s.Hovered
            end

            panel:SetPaintedManually(true)
            panel.isUi3d2dSetup = true
        end

        if found then
            if panel.Hovered then
                panel.Hovered = false
                if panel.OnCursorExited then panel:OnCursorExited() end
            end
        else
            if not validChild and pointInsidePanel(panel, x, y) then
                panel.Hovered = true

                if panel.OnMousePressed then
                    local key = input.IsKeyDown(KEY_LSHIFT) and MOUSE_RIGHT or MOUSE_LEFT

                    if panel.OnMousePressed and ui3d2d.isPressed() then
                        panel:OnMousePressed(key)
                    end

                    if panel.OnMouseReleased and not ui3d2d.isPressing() then
                        panel:OnMouseReleased(key)
                    end
                elseif panel.DoClick and ui3d2d.isPressed() then
                    panel:DoClick()
                end

                if panel.OnCursorEntered then panel:OnCursorEntered() end

                return true
            else
                panel.Hovered = false
                if panel.OnCursorExited then panel:OnCursorExited() end
            end
        end
    end

    local oldMouseX, oldMouseY = gui.MouseX, gui.MouseY

    function ui3d2d.drawVgui(panel, pos, angles, scale, ignoredEntity)
        if not (IsValid(panel) and ui3d2d.startDraw(pos, angles, scale, ignoredEntity)) then return end

        do
            local cursorX, cursorY = ui3d2d.getCursorPos()
            cursorX, cursorY = cursorX or -1, cursorY or -1

            function gui.MouseX()
                return cursorX
            end

            function gui.MouseY()
                return cursorY
            end

            checkHover(panel, cursorX, cursorY)
        end

        panel:PaintManual()

        gui.MouseX, gui.MouseY = oldMouseX, oldMouseY

        ui3d2d.endDraw()
    end
end
