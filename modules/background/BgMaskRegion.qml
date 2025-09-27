import QtQuick
import Quickshell
import "../../globals"


Region {
	id: root
	required property Rectangle mask
	required property ShellScreen screen
	item: mask

	Region {
		id: wallpaperPickerRegion
		item: Rectangle {

			



			Connections{
				target: Signals
				function onWallpaperPickerToggled() {
					console.log("from BgMaskRegion")
					if (wallpaperPickerRegion.intersection == Intersection.Subtract) {
						wallpaperPickerRegion.intersection = Intersection.Combine
					} else {
						wallpaperPickerRegion.intersection = Intersection.Subtract
					}
				}
			}
		}
		intersection: Intersection.Combine
	}



	intersection: Intersection.Xor
}
