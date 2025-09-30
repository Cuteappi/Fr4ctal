import QtQuick
import QtQuick.Shapes

Shape {
	id: shape

	preferredRendererType: Shape.CurveRenderer
	smooth: true
	antialiasing: true

	required property real radius
	required property real roundingStrength
	property real strokeWidth: 0
	property color fillColor: "white"

	ShapePath {
		id: shapePath
		strokeWidth: shape.strokeWidth
		fillColor: shape.fillColor

		property real radius: shape.width > shape.height ? (shape.height / 2) * shape.radius : (shape.width / 2) * shape.radius
		property real roundingStrength: 1 - shape.roundingStrength

		startX: 0 + radius
		startY: 0

		PathLine{ x: shape.width - shapePath.radius; y: 0}

		// Top right				
		PathCubic{ x: shape.width; y: shapePath.radius; 
			control1X: shape.width - shapePath.radius * shapePath.roundingStrength; 
			control1Y: 0;
			control2X: shape.width; 
			control2Y: shapePath.radius * shapePath.roundingStrength;
		}
		PathLine{ x: shape.width; y: shape.height - shapePath.radius}

		//Bottom right				
		PathCubic{ x: shape.width - shapePath.radius; y: shape.height; 
			control1X: shape.width; 
			control1Y: shape.height - shapePath.radius * shapePath.roundingStrength;
			control2X: shape.width - shapePath.radius * shapePath.roundingStrength; 
			control2Y: shape.height;
		}
		PathLine{ x: shapePath.radius ; y: shape.height}

		//Bottom left				
		PathCubic{ x: 0 ; y: shape.height - shapePath.radius; 
			control1X: shapePath.radius * shapePath.roundingStrength; 
			control1Y: shape.height; 
			control2X: 0; 
			control2Y: shape.height - shapePath.radius * shapePath.roundingStrength;
		}
		PathLine{ x: 0 ; y: shapePath.radius}

		//Top left				
		PathCubic{ x: shapePath.radius ; y: 0; 
			control1X: 0; 
			control1Y: shapePath.radius * shapePath.roundingStrength; 
			control2X: shapePath.radius * shapePath.roundingStrength; 
			control2Y: 0
		}
	}
}
	