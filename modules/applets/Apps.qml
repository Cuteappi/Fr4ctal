pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../background"
import "../../globals"


Item {
	id: root

	anchors.fill: parent
	anchors.topMargin: BgSettings.topWidth
	anchors.bottomMargin: BgSettings.bottomWidth
	anchors.leftMargin: BgSettings.leftWidth
	anchors.rightMargin: BgSettings.rightWidth

	property ShellScreen screen

	WallpaperPicker {
		id: wallpaperPicker
		screen: root.screen
	}
	Rectangle {
		id: button
		x: root.screen.width - 50
		y: root.screen.height - 50
		height: 50
		width: 50
		color: "red"

		MouseArea {
			anchors.fill: parent
			onClicked: {
				wallpaperPicker.visibility = !wallpaperPicker.visibility
			}
		}
	}
}

	
