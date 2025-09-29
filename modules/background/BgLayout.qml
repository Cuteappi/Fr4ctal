
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../globals"

Item {
    id: root
    anchors.fill: parent
    property ShellScreen screen


    Connections {
		target: Signals
		function onWallpaperPickerToggled() {

            bwallAnimation.finished.disconnect(sWallCtrl.onFinished_nlv)
            bwallAnimation.finished.disconnect(sWallCtrl.onFinished_nr)
            mwallAnimation.finished.disconnect(sWallCtrl.onFinished_nlv)
            mwallAnimation.finished.disconnect(sWallCtrl.onFinished_nr)


            //opening if fully closed
            if (!sWallCtrl.isOpen) {
                sWallCtrl.isOpen = true
                sWallCtrl.anim_running = true
                sWallCtrl.reverse = true

                mwallAnimation.start()
                bwallDelay.start()

                bwallAnimation.finished.connect(sWallCtrl.onFinished_nlv)
                return 
                
            }


            // closing if fully open
            if (!sWallCtrl.anim_running) {
                sWallCtrl.anim_running = true
                sWallCtrl.reverse = false

                bwallAnimation.start()
                mwallDelay.start()


                mwallAnimation.finished.connect(sWallCtrl.onFinished_nr)
                return
            }

            // pressed in btw opening so as to close

            if(sWallCtrl.reverse){
                bwallDelay.stop()
                mwallDelay.stop()
                bwallAnimation.stop()
                mwallAnimation.stop()

                mwallAnimation.from = sWallCtrl.mwall_offset
                mwallAnimation.to = mwallAnimation.startp
                
                bwallAnimation.from = sWallCtrl.bwall_offset
                bwallAnimation.to = bwallAnimation.startp

                sWallCtrl.reverse = false

                bwallAnimation.start()
                mwallDelay.start()

                mwallAnimation.finished.connect(sWallCtrl.onFinished_nr)
                return

            // pressed in btw closing so as to open
            } else {
                bwallDelay.stop()
                mwallDelay.stop()
                bwallAnimation.stop()
                mwallAnimation.stop()

                mwallAnimation.from = sWallCtrl.mwall_offset
                mwallAnimation.to = mwallAnimation.endp
                
                bwallAnimation.from = sWallCtrl.bwall_offset
                bwallAnimation.to = bwallAnimation.endp

                sWallCtrl.reverse = true

                mwallAnimation.start()
                bwallDelay.start()

                bwallAnimation.finished.connect(sWallCtrl.onFinished_nlv)
                return
            }
        }
	}

    Scope {
        id: sWallCtrl
        property bool isOpen: false
        property bool anim_running: false
        property bool reverse: false
        
        property real startX: (root.width - BgSettings.rightWidth - BgSettings.leftWidth) * 0.2 + BgSettings.leftWidth
        property real endX: (root.width - BgSettings.rightWidth - BgSettings.leftWidth) * 0.8 + BgSettings.leftWidth

        property real mwall_offset: 0
        property real mwall_sp_y: root.height * 0.2 + mwall_offset
        property real mwall_ep_y: root.height * 0.8 + mwall_offset

        property real mwall_radius: 0.21
        property real mwall_rstrength: 0.9
        property int mwall_inverted: 0

        NumberAnimation {
            id: mwallAnimation
            target: sWallCtrl
            property real startp: root.height * 0.8 + 60
            property real endp: 0
            property: "mwall_offset"
            from: startp
            to: endp
            duration: 500
            easing.amplitude: 1
            easing.period: 1.5
            easing.type: Easing.InOutCirc
        }

        property real bwall_offset: 0
        property real bwall_sp_y: root.height - BgSettings.bottomWidth - 25 + bwall_offset
        property real bwall_ep_y: root.height + bwall_offset

        property real bwall_radius: 1
        property real bwall_rstrength: 0.6
        property int bwall_inverted: 0

        NumberAnimation {
            id: bwallAnimation
            target: sWallCtrl
            property real startp: 100
            property real endp: 0
            property: "bwall_offset"
            from: startp
            to: endp
            duration: 400
            easing.type: sWallCtrl.reverse ? Easing.InOutBack : Easing.InOutCirc
        }

        Timer {
            id: bwallDelay
            interval: 100
            running: false
            repeat: false
            onTriggered: {
                bwallAnimation.start()
            }
        }

        Timer {
            id: mwallDelay
            interval: 100
            running: false
            repeat: false
            onTriggered: {
                mwallAnimation.start()
            }
        }

        function swapStartEnd() {
            if(sWallCtrl.reverse) {
                bwallAnimation.from = bwallAnimation.endp
                bwallAnimation.to = bwallAnimation.startp

                mwallAnimation.from = mwallAnimation.endp
                mwallAnimation.to = mwallAnimation.startp

            } else {
                bwallAnimation.from = bwallAnimation.startp
                bwallAnimation.to = bwallAnimation.endp
                
                mwallAnimation.from = mwallAnimation.startp
                mwallAnimation.to = mwallAnimation.endp
            }
        }

        function onFinished_nlv(){
            sWallCtrl.anim_running = false
            swapStartEnd()
        }

        function onFinished_nr (){
            sWallCtrl.isOpen = false
            sWallCtrl.anim_running = false
            swapStartEnd()
        }
    }

    ShaderEffect {
        id: compositor
        anchors.fill: parent
        visible: false

        property var resolution: Qt.size(root.screen.width, root.screen.height)

        property real blending: 0.09
        property real softness: 0
        property var color: Qt.rgba(0.84, 0.94, 0.78,)
        property real antialiasing: 0.6


        //Main rectangle
        property var main_sp: Qt.point(BgSettings.leftWidth, BgSettings.topWidth)
        property var main_ep: Qt.point(root.screen.width - BgSettings.rightWidth, root.screen.height - BgSettings.bottomWidth)
        property real main_radius: 0.109
        property real main_rstrength: 0.9
        property int main_inverted: 1

        //Wallpaper settings
        property int wall_visible: sWallCtrl.isOpen
        property int center: 1

        //Main wallpaper rectangle
        property var mwall_sp: Qt.point(sWallCtrl.startX, sWallCtrl.mwall_sp_y)
        property var mwall_ep: Qt.point(sWallCtrl.endX, sWallCtrl.mwall_ep_y)
        property real mwall_radius: sWallCtrl.mwall_radius
        property real mwall_rstrength: sWallCtrl.mwall_rstrength
        property int mwall_inverted: sWallCtrl.mwall_inverted

        //Bottom wallpaper rectangle
        property var bwall_sp: Qt.point(sWallCtrl.startX, sWallCtrl.bwall_sp_y)
        property var bwall_ep: Qt.point(sWallCtrl.endX, sWallCtrl.bwall_ep_y)
        property real bwall_radius: sWallCtrl.bwall_radius
        property real bwall_rstrength: sWallCtrl.bwall_rstrength
        property int bwall_inverted: sWallCtrl.bwall_inverted

        fragmentShader: "Compositor.frag.qsb"

        
    }

    DropShadow {
        id: bgLayout
        source: compositor
        anchors.fill: compositor
        radius: 6.0
        samples: 4
        horizontalOffset: 0
        verticalOffset: 0
        color: Qt.rgba(0.05, 0.05, 0.05, 0.75)
    }



}