pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "../../components"


Item{
	id: root
	required property string filePath
	required property string fileName
	property ListView listView
	property Item source

	height: listView.parent.height
	width: listView.parent.width * 0.04

	Item {
		anchors.fill: parent

		anchors.topMargin: parent.height * 0.125
		anchors.bottomMargin: parent.height * 0.125

		Image {
			id: img
			anchors.fill: parent
			source: root.filePath
			fillMode: Image.PreserveAspectCrop
			visible: false
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
			anchors.bottomMargin: 10
			width: imgBezierRectangle.width
			height: 10

			Text {
				text: root.fileName
				anchors.centerIn: parent
				color: "white"
			}
		}

		Rectangle{
			id: cirlce
			anchors.top: imgBezierRectangle.bottom
			anchors.horizontalCenter: imgBezierRectangle.horizontalCenter
			anchors.topMargin: 10
			width: imgBezierRectangle.width * 0.5
			height: imgBezierRectangle.width * 0.5
			color: "transparent"
			border.color: "white"
			border.width: 2
			radius: imgBezierRectangle.width * 0.25
		}
	}
}