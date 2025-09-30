import QtQuick
import Quickshell
import "../../globals"


Region {
	id: root
	required property Rectangle mask
	required property ShellScreen screen
	item: mask
	property bool wallpaperPickerToggle: false

	Region {
		id: wallpaperPickerRegion
		item: Rectangle {
			x: (root.screen.width - BgSettings.rightWidth - BgSettings.leftWidth) * 0.2 + BgSettings.leftWidth
			y: root.screen.height * 0.2
			height: root.screen.height * 0.6 
			width: (root.screen.width - BgSettings.rightWidth - BgSettings.leftWidth) * 0.6


			Connections{
				target: Signals
				function onWallpaperPickerToggled() {
					if (wallpaperPickerRegion.intersection == Intersection.Subtract) {
						wallpaperPickerRegion.intersection = Intersection.Combine
					} else {
						wallpaperPickerRegion.intersection = Intersection.Subtract
					}
				}
			}
		}
		intersection: root.wallpaperPickerToggle ? Intersection.Subtract :Intersection.Combine
	}



	intersection: Intersection.Xor
}
