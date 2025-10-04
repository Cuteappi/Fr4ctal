import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

Item {
	id: root

	required property string source
	required property real radius
	required property real startAngleDegrees
	required property real sweepAngleDegrees


	property bool shadowEnabled: false
	property real shadowRadius: 6.0
	property int shadowSamples: 4
	property real shadowHorizontalOffset: 0
	property real shadowVerticalOffset: 0
	property color shadowColor: Qt.rgba(0.05, 0.05, 0.05, 0.75)

	function degToRad(degrees) {
		return degrees * (Math.PI / 180);
	}

	Shape {
        id: arcRing
        anchors.fill: parent

		preferredRendererType: Shape.CurveRenderer
		smooth: true
		antialiasing: true
		

        // --- Customizable Properties ---
        property real centerX: width / 2
        property real centerY: height / 2


        // Helper function for trigonometry


        // --- The Shape Path ---
        ShapePath {
			id: path
			fillColor: "transparent"
            strokeColor: "#e67e22" // Orange color
            strokeWidth: 40     // We only want to fill the shape
			capStyle: ShapePath.RoundCap
			

            property point start: Qt.point(
                arcRing.centerX + root.radius * Math.cos(root.degToRad(root.startAngleDegrees)),
                arcRing.centerY + root.radius * Math.sin(root.degToRad(root.startAngleDegrees))
            )


            // Define the starting position of the path
            startX: start.x
            startY: start.y


			PathAngleArc {
				centerX: arcRing.centerX
				centerY: arcRing.centerY
				radiusX: root.radius
				radiusY: root.radius
				startAngle: root.startAngleDegrees
				sweepAngle: root.sweepAngleDegrees

			}

            
        }
    }

	Behavior on startAngleDegrees{
		NumberAnimation{
			duration: 500
			easing.type: Easing.InOutCirc
		}
	}

	Behavior on sweepAngleDegrees{
		NumberAnimation{
			duration: 500
			easing.type: Easing.InOutCirc
		}
	}

		// Timer {
		// 	id: timer
		// 	interval: 1000
		// 	running: true
		// 	repeat: true

		// 	property bool reversed: false

		// 	onTriggered: {
		// 		reversed =! reversed
		// 		if (reversed) {
		// 			arcRing.startAngleDegrees = -120
		// 			arcRing.sweepAngleDegrees = 30

		// 		} else {
		// 			arcRing.startAngleDegrees = -90
		// 			arcRing.sweepAngleDegrees = 270
		// 		}
		// 	}
		// }

	ShaderEffectSource {
		id: maskSource
		sourceItem: arcRing
		hideSource: true
	}

	OpacityMask {
		id: opacityMask
		anchors.fill: arcRing
		source: Image {
			source: root.source
        	fillMode: Image.PreserveAspectCrop
			anchors.fill: parent
		}
		maskSource: maskSource
		visible: !root.shadowEnabled
	}

	DropShadow {
        id: bgLayout
        source: opacityMask
        anchors.fill: opacityMask
        radius: root.shadowRadius
        samples: root.shadowSamples
        horizontalOffset: root.shadowHorizontalOffset
        verticalOffset: root.shadowVerticalOffset
        color: root.shadowColor
		visible: root.shadowEnabled
    }
}