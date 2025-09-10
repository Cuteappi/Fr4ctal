import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Quickshell


//possible names are "Xyra", "Titanova", "Fr4ctal", "Aero-13", "Orion"

Item{
	id: root
	anchors.fill: parent

	property real val: 0

	PropertyAnimation {
		running: true
		from: 0
		to: 1500
		duration: 10000
		target: root
		property: "val"
		easing.type: Easing.InOutCubic
		loops: 2
	}

	Image {
        id: img
		x: root.width/2
		y:0
		width: root.width
		height: root.height
		
		source: "/home/solo/Pictures/wallpapers/a_close_up_of_purple_flowers.jpg"
		fillMode: Image.PreserveAspectCrop
		smooth: true
		visible: false
    }
	
	// Item {
	// 	anchors.fill: parent
	// 	id: maskCircle

	// 	Rectangle {
			
	// 		x: root.width/2 - root.val/2 
	// 		y: root.height/2 - root.val/2 
	// 		width: root.val
	// 		height: root.val
	// 		radius: root.val
			
	// 	}
	// }

	Shape {
		id: maskCircle
        anchors.fill: parent

		preferredRendererType: Shape.CurveRenderer
		smooth: true
		antialiasing: true

		property real circleX: width / 2
		property real circleY: height / 2

        ShapePath {
            strokeWidth: 2
            strokeColor: "black"
            fillColor: "lightblue"

            // Start at top of the circle
            startX: maskCircle.circleX
            startY: maskCircle.circleY - root.val

            // Draw full circle using two arcs
            PathArc {
                x: maskCircle.circleX
                y: maskCircle.circleY + root.val
                radiusX: root.val
                radiusY: root.val
                useLargeArc: true
            }
            PathArc {
                x: maskCircle.circleX
                y: maskCircle.circleY - root.val
                radiusX: root.val
                radiusY: root.val
                useLargeArc: true
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: img
        maskSource: maskCircle
		invert:false
    }

	

}