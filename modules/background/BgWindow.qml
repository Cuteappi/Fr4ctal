
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../applets"
import QtApplicationManager

LazyLoader {
	id: initLoader
	active: true
	property real fps: 10

	Variants{
		model: Quickshell.screens
		delegate:PanelWindow {
			id: panel;
			required property var modelData
			color: "transparent"

			screen: modelData

			WlrLayershell.layer: WlrLayer.Top
			WlrLayershell.namespace: "xyra"
			WlrLayershell.exclusionMode: ExclusionMode.Ignore

			Component.onCompleted: {
				console.log("from BgWindow")
				BgShapesSettings.screen = screen
			}

			Rectangle{
				id: mask

				anchors.fill: parent
				anchors.topMargin: BgSettings.topWidth
				anchors.bottomMargin: BgSettings.bottomWidth
				anchors.leftMargin: BgSettings.leftWidth
				anchors.rightMargin: BgSettings.rightWidth
				visible: false
			}
			
			mask: BgMaskRegion {
				mask: mask
				screen: panel.screen
			}

			anchors.top: true
			anchors.bottom: true
			anchors.left: true
			anchors.right: true
			
			BgLayout {
				screen: panel.screen
			}

			Apps{
				screen: panel.screen
			}

			Fps{}
				

		}	
	}
}