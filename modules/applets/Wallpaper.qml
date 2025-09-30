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

					if (loader.screen.name != "DP-2") return
					
					if (WallpaperSettings.clickedOut) {
						WallpaperSettings.clickedOut = false
						return
					}
					Hyprland.dispatch(`focuswindow address:0x${WallpaperSettings.lastActiveWindow}`)
					WallpaperSettings.clickedOut = false
				}
			}

			Connections {
				target: Signals
				function onWallpaperPickerToggled() {
					anim.finished.disconnect(scope.onFinished_nr)
					anim.finished.disconnect(scope.onFinished_nlv)

					flickable.focus = !flickable.focus

					if(!loader.visibility) {
						loader.visibility = true
						anim.reverse = true

						anim.start()
						
						anim.finished.connect(scope.onFinished_nlv)
						return
					}
					if(!anim.running) {
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

					property int currentImage: 1

					Image{
						id: wallpaperPreviewImage2
						anchors.fill: parent
						source: ""
						fillMode: Image.PreserveAspectCrop

						Behavior on opacity{
							NumberAnimation{
								duration: 500
								easing.type: Easing.Linear
							}
						}
					}

					Image{
						id: wallpaperPreviewImage
						anchors.fill: parent
						source: ""
						fillMode: Image.PreserveAspectCrop

						Behavior on opacity{
							NumberAnimation{
								duration: 500
								easing.type: Easing.Linear
							}
						}
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



				
				FolderListModel{
					id: folderModel
					folder: `file://${WallpaperSettings.wallpaperDir}`
					showFiles: true

					onStatusChanged: {
						if (folderModel.status === FolderListModel.Ready) {
							let url = folderModel.get(flickable.currentIndex, "filePath")
							if (url === undefined) return
							wallpaperPreviewImage.source = url

							let url2 = folderModel.get(flickable.currentIndex + 1, "filePath")
							if (url2 === undefined) return
							wallpaperPreviewImage2.source = url2
						}
					}
				}

				Flickable{
					id: flickable
					anchors.fill: parent
					anchors.margins: 10
					clip: true

					property int currentIndex: 0

					onCurrentIndexChanged: {
						if (wallpaperPreview.currentImage === 1) {
							wallpaperPreviewImage2.source = folderModel.get(flickable.currentIndex, "filePath")
							wallpaperPreviewImage.opacity = 0
							wallpaperPreview.currentImage = 2

						}else if(wallpaperPreview.currentImage === 2) {
							wallpaperPreviewImage.source = folderModel.get(flickable.currentIndex, "filePath")
							wallpaperPreviewImage.opacity = 1
							wallpaperPreview.currentImage = 1
						}
					}

					Row{
						id: row
						anchors.centerIn: parent
						spacing: 20


						Item {
							id: header
							width: 20
							height: parent.height
						}

						Repeater{
							model: folderModel
							anchors.fill: parent

							delegate: WallpaperListPreview {
								flickable: flickable
								source: row
								currentIndex: flickable.currentIndex
							}
						}

						Item {
							id: footer
							width: 20
							height: parent.height
						}
					}

					Keys.onPressed:(event)=> {
						if (event.key === Qt.Key_Right) {
							currentIndex = Math.min(currentIndex + 1, folderModel.count - 1)
						}else if (event.key === Qt.Key_Left) {
							currentIndex = Math.max(currentIndex - 1, 0)
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

