
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root
    anchors.fill: parent
    property ShellScreen screen

    Component.onCompleted: console.log("from BgLayout")

    ShaderEffect {
        id: compositor
        anchors.fill: parent
        visible: false

        property var resolution: Qt.size(parent.width, parent.height)

        property real blending: 0.1
        property real softness: 0
        property var color: Qt.rgba(0.84, 0.94, 0.78,)


        //main rectangle
        property var main_sp: Qt.point(BgSettings.leftWidth, BgSettings.topWidth)
        property var main_ep: Qt.point(root.screen.width - BgSettings.rightWidth, root.screen.height - BgSettings.bottomWidth)
        property real main_radius: 0.109
        property real main_rstrength: 0.9
        property int main_inverted: 1

        property real time: 0
        property real circle_radius: 150


        fragmentShader: "Compositor.frag.qsb"

        NumberAnimation {
            target: compositor
            property: "time"
            from: 0
            to: Math.PI * 2 // One full sine wave cycle
            duration: 8000 // 4 seconds
            loops: Animation.Infinite // Loop forever
            running: true
        }
    }

    DropShadow {
        id: bgLayout
        source: compositor
        anchors.fill: compositor
        radius: 10.0
        samples: 16
        horizontalOffset: 0
        verticalOffset: 0
        color: Qt.rgba(0.05, 0.05, 0.05)
    }

    Rectangle {
        id: button
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: 50
        width: 50
        color: "red"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                bgLayout.visible = !bgLayout.visible
            }
        }
    }

}