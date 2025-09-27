
import QtQuick
import QtQuick.Shapes
import Quickshell

ShapePath {
	id: root
	fillColor: Qt.rgba(0.84, 0.94, 0.78,)
	strokeWidth: 0
	startX: 0
	startY: 0

	property ShellScreen screen

	PathLine{
		x: root.screen.width
		y: 0
	}

	PathLine{
		x: root.screen.width
		y: root.screen.height
	}

	PathLine{
		x: 0
		y: root.screen.height
	}

	PathLine{
		x: 0
		y: 0
	}

	// Moving to rounded hole
	PathMove {
		x: BgSettings.leftWidth + BgSettings.radius
		y: BgSettings.topWidth
	}

	// Draw top line
	PathLine {
		x: root.screen.width - BgSettings.rightWidth - BgSettings.radius
		y: BgSettings.topWidth
	}

	// Draw top right arc
	PathCubic {
		x: root.screen.width - BgSettings.rightWidth
		y: BgSettings.topWidth + BgSettings.radius
        control1X: root.screen.width - BgSettings.rightWidth - (BgSettings.radius * BgSettings.roundingStrength)
		control1Y: BgSettings.topWidth
        control2X: root.screen.width - BgSettings.rightWidth
		control2Y: BgSettings.topWidth + (BgSettings.radius * BgSettings.roundingStrength)
	}

	// Draw right line
	PathLine {
		x: root.screen.width - BgSettings.rightWidth
		y: root.screen.height - BgSettings.bottomWidth - BgSettings.radius
	}

	// Draw bottom right arc
	PathCubic {
		x: root.screen.width - BgSettings.rightWidth - BgSettings.radius 
		y: root.screen.height - BgSettings.bottomWidth
        control1X: root.screen.width - BgSettings.rightWidth
		control1Y: root.screen.height - BgSettings.bottomWidth - (BgSettings.radius * BgSettings.roundingStrength)
        control2X: root.screen.width - BgSettings.rightWidth - (BgSettings.radius * BgSettings.roundingStrength)
		control2Y: root.screen.height - BgSettings.bottomWidth
	}

	// Draw bottom line
	PathLine {
		x: BgSettings.leftWidth + BgSettings.radius
		y: root.screen.height - BgSettings.bottomWidth
	}

	// Draw bottom left arc
	PathCubic {
		x: BgSettings.leftWidth
		y: root.screen.height - BgSettings.bottomWidth - BgSettings.radius
		control1X: BgSettings.leftWidth + (BgSettings.radius * BgSettings.roundingStrength)
		control1Y: root.screen.height - BgSettings.bottomWidth
		control2X: BgSettings.leftWidth
		control2Y: root.screen.height - BgSettings.bottomWidth - (BgSettings.radius * BgSettings.roundingStrength)
	}

	// Draw left line
	PathLine {
		x: BgSettings.leftWidth
		y: BgSettings.topWidth + BgSettings.radius
	}

	// Draw top left arc
	PathCubic {
		x: BgSettings.leftWidth + BgSettings.radius
		y: BgSettings.topWidth
		control1X: BgSettings.leftWidth
		control1Y: BgSettings.topWidth + (BgSettings.radius * BgSettings.roundingStrength)
		control2X: BgSettings.leftWidth + (BgSettings.radius * BgSettings.roundingStrength)
		control2Y: BgSettings.topWidth
	}
}