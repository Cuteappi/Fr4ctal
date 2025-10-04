pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import Qt.labs.folderlistmodel
import "../../components"

Item {
    id: root
    clip: true

    required property FolderListModel model
    required property int currentIndex
    required property int direction

    property real size: 1.1
    property real offset: 550
    property int spacing: 50
    property real startAngleDegrees: -110
    property real swipeAngleDegrees: 10
    property real mainSwipeAngleDegrees: 10 * 4

    property real angleOffset: 1
    property real mul: (-Math.ceil(urls.length / 2) + angleOffset)
    property real startAngleOffset: root.startAngleDegrees + (root.swipeAngleDegrees + root.spacingInDegrees) * mul
    property real radius: parent.height * root.size * 0.45

    property real spacingInDegrees: radius === 0 ? 0 : Math.ceil((spacing / radius) * (180 / Math.PI))

    property var urls: []

    function getDisplayIndex(index) {
        let val = index + currentIndex

        if (val < 0)
            val = model.count - 1 + val
        else if (val >= model.count)
            val = val - model.count
        return val
    }

    function calcStartAngle(index) {
        let u_start = root.startAngleOffset
        let u_index = index + 3

        while (u_index > 0) {
            if (u_index === 4) {
                u_start += root.mainSwipeAngleDegrees + root.spacingInDegrees
                u_index--
                continue
            }
            u_start += root.swipeAngleDegrees + root.spacingInDegrees
            u_index--
        }
        return u_start
    }

    function calcRotation(val:bool) {
        if (anim.running) {
            console.log("anim running")
            anim.stop()
            anim.from = container.rotation
            anim.to = val ? container.rotation + container.rotation % 18 : container.rotation - container.rotation % 18
            anim.start()
            return
        }
        anim.from = container.rotation
        anim.to = val ? container.rotation + 18 : container.rotation - 18
        anim.start()
    }

    onCurrentIndexChanged: {
        if (urls.length === 0)
            return

        if (root.direction === 1) {
            const nextUrl = root.model.get(root.getDisplayIndex(3), "filePath")
            const updated = urls.slice(1).concat(nextUrl)
            root.angleOffset++
            root.urls = updated
            calcRotation(false)
            console.log(container.rotation)
 
            return
        } else if (root.direction === -1) {
            const previousUrl = root.model.get(root.getDisplayIndex(-3), "filePath")
            const updated = [previousUrl].concat(urls.slice(0, urls.length - 1))
            root.angleOffset--
            calcRotation(true)
            root.urls = updated
            return
        }
    }

    Item {
        id: container
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.offset

        width: parent.height * root.size
        height: parent.height * root.size

        Instantiator {
            id: ringInstantiator
            model: root.urls
            active: false

            delegate: ImgRing {
                required property int index
                required property var modelData

                parent: container
                anchors.fill: parent

                source: modelData !== undefined ? modelData : ""
                radius: root.radius
                startAngleDegrees: root.calcStartAngle(index - 3)
                sweepAngleDegrees: root.getDisplayIndex(index - 3) === root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
            }
        }

        NumberAnimation{
            id: anim
            target: container
            property: "rotation"
            from: 0
            to: 0
            duration: 250
            easing.type: Easing.InOutCubic
        }
    }

    Connections {
        target: root.model
        function onStatusChanged() {
            if (root.model.status !== FolderListModel.Ready)
                return
            const x = []
            for (let i = -3; i <= 3; i++) {
                x.push(root.model.get(root.getDisplayIndex(i), "filePath"))
            }
            root.urls = x
            ringInstantiator.active = true
            // ringInstantiator.active = false
        }
    }
}
