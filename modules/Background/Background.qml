pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland

import "S3wClone.qml"


//possible names are "Xyra", "Titanova", "Fr4ctal", "Aero-13", "Orion"

LazyLoader {
	id: initLoader
	active: true
	property real fps: 165

	Variants{
		model: Quickshell.screens
		delegate: PanelWindow {
			id: panel;
			required property var modelData
			color: "transparent"

			screen: modelData

			WlrLayershell.layer: WlrLayer.Bottom
			WlrLayershell.namespace: "orion"
			WlrLayershell.exclusionMode: ExclusionMode.Ignore

			anchors.top: true
			anchors.bottom: true
			anchors.left: true
			anchors.right: true

			S3wClone {}
		}

	}

	onLoadingChanged: Qt.application.updateInterval = 1000 / initLoader.fps // 16 ms ≈ 60 FPS
	
}
	



