pragma Singleton

import Quickshell

Singleton {

	property ShellScreen screen

	property var u_rectangles: [
		{
			u_start_point: Qt.point(BgSettings.leftWidth, BgSettings.topWidth),
			u_end_point: Qt.point(screen.width - BgSettings.rightWidth, screen.height - BgSettings.bottomWidth),
			u_radius: 0.109,
			u_strength: 0.9,
			u_smoothness: 0.25,
			u_inverted: true
		}
	]
}