import QtQuick
import Quickshell
import QtQuick.Shapes

Shape {
	anchors.fill: parent
	preferredRendererType : Shape.CurveRenderer


	ShapePath {
		strokeWidth: 0
		id: bg
		fillColor: Qt.rgba(1, 1, 1, 0.05)
		startX: 0
		startY: Quickshell.screens[1].height/2

		property real screenH: Quickshell.screens[1].height 
		property real screenW: Quickshell.screens[1].width 
		property real thinWidth: 8
		property real barWidth: 50
		property real radius: 22

		PathLine {x: 0; y: 0}	
		PathLine {x: bg.screenW; y: 0}
		PathLine {x: bg.screenW; y: bg.screenH}	
		PathLine {x: 0; y: bg.screenH}	
		PathLine {x: 0; y: bg.screenH/2}
		PathLine {x: bg.thinWidth; y:bg.screenH/2 }	
		PathLine {x: bg.thinWidth; y: bg.screenH - bg.thinWidth - bg.radius}
		//arc
		PathArc  {
			x: bg.thinWidth + bg.radius; 		
			y: bg.screenH - bg.thinWidth
			radiusX: bg.radius
			radiusY: bg.radius
			direction: PathArc.Counterclockwise
		}

		PathLine {x: bg.screenW - bg.barWidth - bg.radius; y: bg.screenH - bg.thinWidth}	
		//arc
		PathArc  {
			x: bg.screenW - bg.barWidth; 		
			y: bg.screenH - bg.thinWidth - bg.radius
			radiusX: bg.radius
			radiusY: bg.radius
			direction: PathArc.Counterclockwise
		}

		PathLine {x: bg.screenW - bg.barWidth; y: bg.thinWidth + bg.radius}
		//arc
		PathArc  {
			x: bg.screenW - bg.barWidth - bg.radius; 
			y: bg.thinWidth
			radiusX: bg.radius
			radiusY: bg.radius
			direction: PathArc.Counterclockwise
		}
		PathLine {x: bg.thinWidth + bg.radius; y: bg.thinWidth}
		//arc
		PathArc  {
			x: bg.thinWidth; 				 	
			y: bg.thinWidth + bg.radius
			radiusX: bg.radius
			radiusY: bg.radius
			direction: PathArc.Counterclockwise
		}

		PathLine {x: bg.thinWidth; y: bg.screenH/2}	
		PathLine {x: 0; y: bg.screenH/2}	


	}
}