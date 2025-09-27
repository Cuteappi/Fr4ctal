pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Quickshell


Item {
	id: root
	required property string filePath
	property ListView listView
	property Rectangle sourceRect

	height: listView.parent.height
	width: listView.parent.width * 0.04

	Item {
		anchors.fill: parent

		anchors.topMargin: parent.height * 0.1
		anchors.bottomMargin: parent.height * 0.1

		Image {
			id: img
			anchors.fill: parent
			source: root.filePath
			fillMode: Image.PreserveAspectCrop
			visible: false
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

				property real radius: (shape.width / 2) * 0.7
				property real roundingStrength: 1 - 0.8

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
			id: opacityMask
			anchors.fill: parent
			source: img
			maskSource: maskSource
			invert: false
		}

		DropShadow {
			source: opacityMask
			anchors.fill: opacityMask
			radius: 10.0
			samples: 16
			horizontalOffset: 0
			verticalOffset: 0
			color: Qt.rgba(0.05, 0.05, 0.05)
		}
	}
}