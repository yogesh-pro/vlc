/*****************************************************************************
 * Copyright (C) 2024 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
import QtQuick
import VLC.Player
import VLC.Style

// Subtitle drag overlay for adjusting subtitle position
// Activated by holding Ctrl key and dragging in the subtitle area
MouseArea {
    id: subtitleDragOverlay

    // Properties
    property bool isDragging: false
    property real dragStartY: 0
    property int initialMargin: 0
    property real lastMouseY: 0
    
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    enabled: Player.hasVideoOutput
    propagateComposedEvents: true  // Allow events to pass through when not handled
    
    // Only activate drag when Ctrl is held and click is in subtitle area
    onPressed: (mouse) => {
        if ((mouse.modifiers & Qt.ControlModifier) && mouse.y > parent.height * 0.4) {
            isDragging = true
            dragStartY = mouse.y
            lastMouseY = mouse.y
            // Start with current margin (assuming 0 for now, could be enhanced to read config)
            initialMargin = 0
            cursorShape = Qt.ClosedHandCursor
            mouse.accepted = true
        } else {
            // Let other components handle the event
            mouse.accepted = false
        }
    }
    
    onReleased: (mouse) => {
        if (isDragging) {
            isDragging = false
            cursorShape = Qt.ArrowCursor
            mouse.accepted = true
        } else {
            mouse.accepted = false
        }
    }
    
    onPositionChanged: (mouse) => {
        if (isDragging) {
            // Calculate margin change based on drag distance
            // Positive deltaY means dragging down, which should decrease margin (move subtitle down)
            const deltaY = mouse.y - dragStartY
            // Convert to margin: each pixel dragged changes margin
            const newMargin = Math.max(0, initialMargin - Math.round(deltaY))
            
            // Update subtitle position
            Player.setSubtitleMargin(newMargin)
            lastMouseY = mouse.y
            mouse.accepted = true
        } else {
            mouse.accepted = false
        }
    }
    
    // Visual feedback when dragging
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        visible: subtitleDragOverlay.isDragging
        
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.min(Math.max(subtitleDragOverlay.lastMouseY - height / 2, 0), parent.height - height)
            width: VLCStyle.dp(240, VLCStyle.scale)
            height: VLCStyle.dp(50, VLCStyle.scale)
            color: Qt.rgba(0, 0, 0, 0.8)
            radius: VLCStyle.dp(8, VLCStyle.scale)
            border.color: Qt.rgba(1, 1, 1, 0.3)
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: qsTr("Adjusting subtitle position...")
                color: "white"
                font.pixelSize: VLCStyle.fontSize_normal
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
