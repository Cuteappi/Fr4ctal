import QtQuick
import Quickshell

Item{
	anchors.top: parent.top
	height: container.height
	width: parent.width
	anchors.topMargin: 4

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}

	Item{
		id: container
		anchors.centerIn: parent
		width: Math.max(hours.implicitWidth, minutes.implicitWidth)
		height: hours.implicitHeight + minutes.implicitHeight
		
		
		Text {
			id: hours
			anchors.horizontalCenter: parent.horizontalCenter
			font.family: "PPNeueMachina"
			font.styleName: "Plain Ultrabold"
			font.pixelSize: 26
			text: Qt.formatDateTime(clock.date, "hh")
		}

		Text {
			id: minutes
			anchors.top: hours.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			font.styleName: "Plain Ultrabold"
			font.family: "PPNeueMachina"
			font.pixelSize: 26		
			text: Qt.formatDateTime(clock.date, "mm")
		}
	}
}