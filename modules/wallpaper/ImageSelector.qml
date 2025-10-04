import QtQuick
import Qt.labs.folderlistmodel
import "../../components"

Item{
	id: root
	clip: true

	required property FolderListModel model
	required property int currentIndex
	required property int direction

	property real size: 1.1
	property real offset : 550
	property int spacing: 50
	property real startAngleDegrees: -110
	property real swipeAngleDegrees: 10
	property real mainSwipeAngleDegrees: 10 * 4
	

	property real angleOffset: 1	
	property real mul: (-Math.ceil(urls.length/2) + angleOffset)
	property real startAngleOffset: root.startAngleDegrees + (root.swipeAngleDegrees + root.spacingInDegrees)  * mul
	property real radius: parent.height * root.size * 0.45

	property real spacingInDegrees: Math.ceil((spacing/radius)*(180/Math.PI))
	property bool destroy: false

	property var urls: []

	onMulChanged: console.log(angleOffset, mul, startAngleOffset)


	function getDisplayIndex(index){
		let val = index + currentIndex

		if (val < 0) val = model.count - 1 + val
		else if (val >= model.count) val = val - model.count
		return val
	}

	function calcStartAngle(index){
		let u_start = root.startAngleOffset
		let u_index = index + 3
		
		while (u_index > 0) {
			if (u_index == 4) {
				u_start += root.mainSwipeAngleDegrees + root.spacingInDegrees
				u_index--
				continue
			} 
			u_start += root.swipeAngleDegrees + root.spacingInDegrees
			u_index--
		}
		return u_start
	}

	onCurrentIndexChanged: {
		if (urls.length == 0) return

		if (root.direction == 1) {
			
			let x = [...urls, root.model.get(root.getDisplayIndex(-3), "filePath")]
			root.angleOffset++
			root.urls = x
			return
		} else if (root.direction == -1) {
			let x = [root.model.get(root.getDisplayIndex(3), "filePath"), ...urls]
			root.angleOffset--
			root.urls = x
			return
		}
	}

	Item{
		id: container
		anchors.centerIn: parent
		anchors.verticalCenterOffset : root.offset
		

		height: parent.height * root.size
		width: parent.height * root.size



		function finishCreation(component){
			if (component.status == Component.Ready) {

				for (let i = 0; i < root.urls.length; i++) {

					let index = root.getDisplayIndex(i)

					let imgRing = component.createObject(container,{
						source: root.urls[i] !== undefined ? root.urls[i] : "",
						"anchors.fill": container,
						radius: root.radius,
						startAngleDegrees: Qt.binding(() => root.calcStartAngle(i - 3)),
						sweepAngleDegrees: Qt.binding(() => root.getDisplayIndex(i - 3) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees),
					})
					root.urlsChanged.connect(()=>{
						let x = root.urls.indexOf(imgRing.source)
						if(x == undefined || x == null) {
							console.log("destroying")
							imgRing.destroy()
						}
						// console.log("index: ", x, root.urls[i])
					})

					

					if (imgRing == null) {
						console.log("Error: " + component.errorString())
					}
				}


			} else if (component.status == Component.Error) {
				console.log("Error: " + component.errorString())
			}

		}

		function createImgRing(){
			var component = Qt.createComponent("../../components/ImgRing.qml")
			if (component.status == Component.Ready) {
				finishCreation(component)

				// root.destroyChanged.connect(component.destroy(0))

			} else if (component.status == Component.Error) {
				console.log("Error: " + component.errorString())
			} else {
				component.statusChanged.connect(finishCreation(component));
				console.log("Loading")
			}
		}

		// ImgRing{
		// 	anchors.fill: parent
		// 	source: root.urls[0] !== undefined ? root.urls[0] : ""
		// 	radius: root.radius
		// 	startAngleDegrees: root.calcStartAngle(-3)
		// 	sweepAngleDegrees: root.getDisplayIndex(-3) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
		// }

		// ImgRing{
		// 	anchors.fill: parent
		// 	source: root.urls[1] !== undefined ? root.urls[1] : ""
		// 	radius: root.radius
		// 	startAngleDegrees: root.calcStartAngle(-2)
		// 	sweepAngleDegrees: root.getDisplayIndex(-2) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
		// }

		// ImgRing{
		// 	anchors.fill: parent
		// 	source: root.urls[2] !== undefined ? root.urls[2] : ""
		// 	radius: root.radius
		// 	startAngleDegrees: root.calcStartAngle(-1)
		// 	sweepAngleDegrees: root.getDisplayIndex(-1) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
		// }

		// //center
		// ImgRing{
		// 	anchors.fill: parent
		// 	source: root.urls[3] !== undefined ? root.urls[3] : ""
		// 	radius: root.radius
		// 	startAngleDegrees: root.calcStartAngle(0)
		// 	sweepAngleDegrees: root.getDisplayIndex(0) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
		// }

		// ImgRing{
		// 	anchors.fill: parent
		// 	source: root.urls[4] !== undefined ? root.urls[4] : ""
		// 	radius: root.radius
		// 	startAngleDegrees: root.calcStartAngle(1)
		// 	sweepAngleDegrees: root.getDisplayIndex(1) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
		// }

		// ImgRing{
		// 	anchors.fill: parent
		// 	source: root.urls[5] !== undefined ? root.urls[5] : ""
		// 	radius: root.radius
		// 	startAngleDegrees: root.calcStartAngle(2)
		// 	sweepAngleDegrees: root.getDisplayIndex(2) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
		// }

		// ImgRing{
		// 	anchors.fill: parent
		// 	source: root.urls[6] !== undefined ? root.urls[6] : ""
		// 	radius: root.radius
		// 	startAngleDegrees: root.calcStartAngle(3)
		// 	sweepAngleDegrees: root.getDisplayIndex(3) == root.currentIndex ? root.mainSwipeAngleDegrees : root.swipeAngleDegrees
		// }
	}



	Connections {
		target: root.model
		function onStatusChanged() {
			if (root.model.status !== FolderListModel.Ready) return
			let x = []
			for (let i = -3; i <= 3; i++) {
				x.push(root.model.get(root.getDisplayIndex(i), "filePath"))
			}
			root.urls = x
			container.createImgRing()
		}
	}


	


}