pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
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

	Wallpaper {
		id: wallpaperPicker
		screen: root.screen
	}

}

	
