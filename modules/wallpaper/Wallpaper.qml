pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import "S3wClone.qml"


//possible names are "Xyra", "Titanova", "Fr4ctal", "Aero-13", "Orion"

LazyLoader {
	id: initLoader
	active: true
	// property real fps: 10

	Variants{
		model: Quickshell.screens
		delegate:PanelWindow {
			id: panel;
			required property var modelData
			color: "transparent"

			screen: modelData

			WlrLayershell.layer: WlrLayer.Background
			WlrLayershell.namespace: "orion"
			WlrLayershell.exclusionMode: ExclusionMode.Ignore

			anchors.top: true
			anchors.bottom: true
			anchors.left: true
			anchors.right: true
			
			S3wClone {}
		}	
	}
}
	



