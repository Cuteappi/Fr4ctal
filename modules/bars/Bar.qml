import QtQuick
import Quickshell
import "../background"
import "../"
Item {
	id: root 

	anchors.top: parent.top
	anchors.right: parent.right
	anchors.bottom: parent.bottom
	anchors.topMargin: BgSettings.topWidth
	anchors.bottomMargin: BgSettings.bottomWidth

	width: BgSettings.rightWidth

	Clock{}

	Workspaces{}

	
}