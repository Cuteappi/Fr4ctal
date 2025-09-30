pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Hyprland
import "../wallpaper"
import "../background"
import "../../globals"
import "../../components"

Loader {
	id: loader
	asynchronous: true
	active: true
	sourceComponent: rect
	focus: true

	property ShellScreen screen
	property bool visibility: false

	anchors.fill: parent

	Component {
		id: rect
		Item{
			id: root
			visible: loader.visibility
			anchors.fill: parent

			Scope {
				id: scope
				function onFinished_nlv() {
					anim.from = anim.endp
					anim.to = anim.startp
				}

				function onFinished_nr() {
					loader.visibility = false
					anim.from = anim.startp
					anim.to = anim.endp
				}
			}


			Connections {
				target: Signals
				function onWallpaperPickerToggled() {
					anim.finished.disconnect(scope.onFinished_nr)
					anim.finished.disconnect(scope.onFinished_nlv)

					listView.focus = !listView.focus

					if(!loader.visibility) {
						// console.log("n vis")
						loader.visibility = true
						anim.reverse = true

						anim.start()
						
						anim.finished.connect(scope.onFinished_nlv)
						return
					}
					if(!anim.running) {
						// console.log("n running")
						anim.reverse = false
						animDelay.start()

						anim.finished.connect(scope.onFinished_nr)
						return
					}

					if (anim.reverse) {
						animDelay.stop()
						anim.stop()

						anim.from = wallpaperPickerContainer.anchors.verticalCenterOffset
						anim.to = anim.startp

						anim.reverse = false

						animDelay.start()
						anim.finished.connect(scope.onFinished_nr)
						return

					} else {
						animDelay.stop()
						anim.stop()

						anim.from = wallpaperPickerContainer.anchors.verticalCenterOffset
						anim.to = anim.endp

						anim.reverse = true

						anim.start()
						anim.finished.connect(scope.onFinished_nlv)
						return
					}
				}
			}

			NumberAnimation {
				id: anim
				property real startp: loader.screen.height * 0.8 + 60
				property real endp: 0
				property bool reverse: false

				target: wallpaperPickerContainer
				property: "anchors.verticalCenterOffset"
				from: startp
				to: endp
				duration: 500
				easing.amplitude: 1
				easing.period: 1.5
				easing.type: Easing.InOutCirc
			}

			Timer {
				id: animDelay
				interval: 100
				running: false
				repeat: false
				onTriggered: {
					anim.start()
				}
			}
			
			Item {
				id: wallpaperPickerContainer
				anchors.centerIn: parent
				height: loader.screen.height * 0.6 
				width: (loader.screen.width - BgSettings.rightWidth - BgSettings.leftWidth) * 0.6

				anchors.verticalCenterOffset: loader.screen.height * 0.8 + 60

				
				
				// The bg with the gradient overlay
				Item {
					id: wallpaperPreview
					anchors.fill: parent	
					visible: false			

					Image{
						id: wallpaperPreviewImage
						anchors.fill: parent
						source: ""
						fillMode: Image.PreserveAspectCrop
					}

					Rectangle{
						id: wallpaperPreviewImageOverlay
						anchors.fill: parent
						gradient: Gradient {
							GradientStop {
								position: 0.75
								color: Qt.rgba(0, 0, 0, 0.45)
							}
							GradientStop {
								position: 0
								color: Qt.rgba(0, 0, 0, 0)
							}
						}
					}
				}

				ImgBezierRectangle {
					id: shape
					anchors.fill: parent
					radius: 0.1
					roundingStrength: 0.9
					source: wallpaperPreview
					anchors.margins: 10
				}
				

				Item{
					id: sourceRect
					anchors.fill: parent

					property real spacing: 20

					FolderListModel {
						id: folderModel
						folder: `file://${WallpaperSettings.wallpaperDir}`
						showFiles: true
					}
				

					ListView {
						id: listView
						anchors.centerIn: parent
						height: parent.height
						width: contentWidth
						clip: true
						model: folderModel
						spacing: sourceRect.spacing
						orientation: ListView.Horizontal
						// focus: true

						delegate: WallpaperListPreview {
							listView: listView
							source: sourceRect
						}

						header: Item {
							anchors.top: parent.top
							anchors.bottom: parent.bottom

							width: sourceRect.width * 0.04
							
						}

						footer: Item {
							anchors.top: parent.top
							anchors.bottom: parent.bottom

							width: sourceRect.width * 0.04
						}

						onCurrentIndexChanged: {
							wallpaperPreviewImage.source = folderModel.get(listView.currentIndex, "filePath")
						}

						

						Component.onCompleted: {
							let url = folderModel.get(listView.currentIndex, "filePath")
							if (url === undefined) return
							wallpaperPreviewImage.source = url
						}


					}
				}

			}

			Item {
				anchors.bottom: parent.bottom
				anchors.horizontalCenter: parent.horizontalCenter
				height: 25
				width: loader.screen.width * 0.6
				clip: true

				Text {
					text: "Wallpaper"
					anchors.centerIn: parent
				}
			}
		}

	}

}

