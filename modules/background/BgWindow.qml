
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../applets"
import "../../globals"
import "../wallpaper"
import "../bars"


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
			focusable: true

			screen: modelData


			WlrLayershell.layer: WlrLayer.Top
			WlrLayershell.namespace: "xyra"
			WlrLayershell.exclusionMode: ExclusionMode.Ignore

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
				id: maskRegion
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

			Bar {}

			Apps{
				screen: panel.screen
			}

			Fps{}




			Connections{
				target: Signals
				function onWallpaperPickerGrabHandler(){
					if (panel.screen.name == "DP-2") return
					grab.active = !grab.active
					grab.open = !grab.open
				}

			}

			Connections{
				target:Hyprland
				function onRawEvent(event){
					if (event.name == "activewindowv2") {
						WallpaperSettings.lastActiveWindow = event.parse(1).toString()
					}
				}
			}

			HyprlandFocusGrab{
				id: grab
				windows: [panel]
				property bool open: false
				onCleared:{
					console.log("in")
					if(!grab.active && panel.screen.name != "DP-2"){
						WallpaperSettings.clickedOut = true
						Signals.wallpaperPickerToggled()
						grab.open = false
					}
				}
			}
			property bool active:false

		}	
	}
}