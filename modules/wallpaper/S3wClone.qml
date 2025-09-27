
import QtQuick
import QtQuick.Shapes
import "WallpaperSettings.qml"

import Qt5Compat.GraphicalEffects

Item{
    id: root
    anchors.fill: parent

    property real val: 0

    PropertyAnimation {
        running: true
        from: 0
        to: 1500
        duration: 5000
        target: root
        property: "val"
        easing.type: Easing.InOutCubic
    }

    Image {
        id: img
        x: root.width/2
        y:0
        width: root.width
        height: root.height
        
        source: "/home/solo/Pictures/wallpapers/a_foggy_mountain_with_trees_01.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: false
    }

    Shape {
        id: shape
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer
        smooth: true
        antialiasing: true

        property real circleX: width / 2
        property real circleY: height / 2

        ShapePath {
            strokeWidth: 0
            strokeColor: "black"
            fillColor: "white"

            // Start at top of the circle
            startX: shape.circleX
            startY: shape.circleY - root.val

            // Draw full circle using two arcs
            PathArc {
                x: shape.circleX
                y: shape.circleY + root.val
                radiusX: root.val
                radiusY: root.val
                useLargeArc: true
            }
            PathArc {
                x: shape.circleX
                y: shape.circleY - root.val
                radiusX: root.val
                radiusY: root.val
                useLargeArc: true
            }
        }
    }

    ShaderEffectSource {
        id: maskSource
        sourceItem: shape
        hideSource: true   // don't show the mask itself

    }

    OpacityMask {
		anchors.fill: parent
		source: img
		maskSource: maskSource
        invert: false

	}   

}