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
MouseArea {
    id: subtitleDragOverlay

    // Properties
    property bool isDragging: false
    property real dragStartY: 0
    property int initialMargin: 0
    
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    enabled: Player.hasVideoOutput
    
    // Only process events in the lower half where subtitles typically appear
    onPressed: (mouse) => {
        if (mouse.y > parent.height * 0.4) {
            isDragging = true
            dragStartY = mouse.y
            // Get current margin from config
            initialMargin = 0
            cursorShape = Qt.ClosedHandCursor
        }
    }
    
    onReleased: {
        if (isDragging) {
            isDragging = false
            cursorShape = Qt.ArrowCursor
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
        }
    }
    
    // Visual feedback when dragging
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        visible: subtitleDragOverlay.isDragging
        
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: subtitleDragOverlay.dragStartY - 20
            width: VLCStyle.dp(200, VLCStyle.scale)
            height: VLCStyle.dp(40, VLCStyle.scale)
            color: Qt.rgba(0, 0, 0, 0.7)
            radius: VLCStyle.dp(8, VLCStyle.scale)
            
            Text {
                anchors.centerIn: parent
                text: qsTr("Drag to adjust subtitle position")
                color: "white"
                font.pixelSize: VLCStyle.fontSize_normal
            }
        }
    }
}
