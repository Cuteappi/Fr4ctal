pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "../../components"


Item{
	id: root
	required property string filePath
	required property string fileName
	property Flickable flickable
	required property int currentIndex
	required property int index
	property Item source

	height: flickable.parent.height
	width: flickable.parent.width * 0.04

	Item {
		id: container
		anchors.centerIn: parent
		height: parent.height * 0.6
		width: parent.width

		property var easing: Easing.InOutQuint


		anchors.verticalCenterOffset: root.index == root.currentIndex ?  -imgBezierRectangle.width : 0

		Behavior on anchors.verticalCenterOffset{
			NumberAnimation{
				duration: 400
				easing.type: container.easing
			}
		}

		Image {
			id: img
			anchors.fill: parent
			source: root.filePath
			fillMode: Image.PreserveAspectCrop
			visible: false
			cache: true
		}

		ImgBezierRectangle {
			id: imgBezierRectangle
			source: img
			anchors.fill: parent
			radius: 0.7
			roundingStrength: 0.8
			shadowEnabled: true
		}

		Item{
			id: name
			anchors.bottom: imgBezierRectangle.top
			anchors.bottomMargin: 20
			width: imgBezierRectangle.width
			height: 10

			Text {
				id: text
				text: root.fileName
				anchors.centerIn: parent
				color: "white"
				visible: false
				font.pixelSize: 14
			}

			DropShadow {
				id: dropShadow
				anchors.fill: text
				source: text
				radius: 6
				samples: 8
				horizontalOffset: 1
				verticalOffset: 1
				color: Qt.rgba(0.0, 0.0, 0.0, 1)
			}
			opacity: root.index === root.currentIndex ? 1 : 0

			Behavior on opacity{
				NumberAnimation{
					duration: 400
					easing.type: container.easing
				}
			}
		}

		Rectangle{
			id: circle
			anchors.top: imgBezierRectangle.bottom
			anchors.horizontalCenter: imgBezierRectangle.horizontalCenter
			anchors.topMargin: 10
			width: imgBezierRectangle.width * 0.5
			height: imgBezierRectangle.width * 0.5
			color: "transparent"
			border.color: "white"
			border.width: 2
			radius: imgBezierRectangle.width * 0.25
			opacity: root.index === root.currentIndex ? 1 : 0

			Behavior on opacity{
				NumberAnimation{
					duration: 400
					easing.type: container.easing
				}
			}

		}
	}
}