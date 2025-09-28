pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import Quickshell
import "../wallpaper"
import "../../components"
import "../background"
import "../../globals"

Loader {
	id: loader
	asynchronous: true
	active: true
	sourceComponent: rect

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
				
				Item {
					id: wallpaperImagePreviewContainer
					anchors.fill: parent	
					visible: false			

					Image{
						id: wallpaperImagePreview
						anchors.fill: parent
						source: ""
						fillMode: Image.PreserveAspectCrop
					}

					Rectangle{
						id: wallpaperImagePreviewOverlay
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

				Shape {
					id: shape
					anchors.fill: parent

					preferredRendererType: Shape.CurveRenderer
					smooth: true
					antialiasing: true

					ShapePath {
						id: shapePath
						strokeWidth: 0
						fillColor: "white"

						property real radius: shape.width > shape.height ? (shape.height / 2) * 0.1 : (shape.width / 2) * 0.1
						property real roundingStrength: 1 - 0.9

						startX: 0 + radius
						startY: 0

						PathLine{ x: shape.width - shapePath.radius; y: 0}

						// Top right				
						PathCubic{ x: shape.width; y: shapePath.radius; 
							control1X: shape.width - shapePath.radius * shapePath.roundingStrength; 
							control1Y: 0;
							control2X: shape.width; 
							control2Y: shapePath.radius * shapePath.roundingStrength;
						}
						PathLine{ x: shape.width; y: shape.height - shapePath.radius}

						//Bottom right				
						PathCubic{ x: shape.width - shapePath.radius; y: shape.height; 
							control1X: shape.width; 
							control1Y: shape.height - shapePath.radius * shapePath.roundingStrength;
							control2X: shape.width - shapePath.radius * shapePath.roundingStrength; 
							control2Y: shape.height;
						}
						PathLine{ x: shapePath.radius ; y: shape.height}

						//Bottom left				
						PathCubic{ x: 0 ; y: shape.height - shapePath.radius; 
							control1X: shapePath.radius * shapePath.roundingStrength; 
							control1Y: shape.height; 
							control2X: 0; 
							control2Y: shape.height - shapePath.radius * shapePath.roundingStrength;
						}
						PathLine{ x: 0 ; y: shapePath.radius}

						//Top left				
						PathCubic{ x: shapePath.radius ; y: 0; 
							control1X: 0; 
							control1Y: shapePath.radius * shapePath.roundingStrength; 
							control2X: shapePath.radius * shapePath.roundingStrength; 
							control2Y: 0
						}
					}
				}

				ShaderEffectSource {
					id: maskSource
					sourceItem: shape
					hideSource: true
				}

				OpacityMask {
					anchors.fill: parent
					anchors.margins: 10
					source: wallpaperImagePreviewContainer
					maskSource: maskSource
				}

				Rectangle{
					id: sourceRect
					color: "transparent"
					anchors.centerIn: parent
					height: parent.height
					width: parent.width

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

						delegate: WallaperListPreview {
							listView: listView
							sourceRect: sourceRect
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
							wallpaperImagePreview.source = folderModel.get(listView.currentIndex, "filePath")
						}

						Component.onCompleted: {
							let url = folderModel.get(listView.currentIndex, "filePath")
							if (url === undefined) return
							wallpaperImagePreview.source = url
						}
					}
				}
			}

			Item {
				anchors.bottom: parent.bottom
				anchors.horizontalCenter: parent.horizontalCenter
				height: 25
				width: loader.screen.width * 0.6

				Text {
					text: "Wallpaper"
					anchors.centerIn: parent
				}
			}
		}

	}

}

