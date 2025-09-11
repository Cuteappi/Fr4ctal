import QtQuick
import QtQuick.Shapes
import Quickshell

Item{

	Canvas {
		id: root
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		width: parent.width/2
		
		renderStrategy: Canvas.Immediate
		smooth: true
		antialiasing: true


		property ShellScreen screen

		property real radius: 24



		Image {
			id: myImage
			source: "/home/solo/Pictures/wallpapers/a_group_of_trees_with_green_leaves.jpg"
			visible: false 
		}


		onPaint:{
			var ctx = getContext("2d");
			ctx.reset();

			
			let { width, height, cropX, cropY, cropW, cropH } = getImageResizedDimensions(myImage);

			// draw cropped region into full screen
			ctx.drawImage(
				myImage,
				cropX / (width / myImage.width),   // sx
				cropY / (height / myImage.height), // sy
				cropW / (width / myImage.width),   // sWidth
				cropH / (height / myImage.height), // sHeight
				0, 0,                              // dx, dy (draw at top-left)
				screen.width, screen.height        // dWidth, dHeight (fit screen)
			);
		}

		onImageLoaded: {
			root.requestPaint();
		}

		onRadiusChanged:{
			root.requestPaint();
		}

		function getImageResizedDimensions(myImage, inset = 0.0) {
			// screen size
			let screenW = screen.width;
			let screenH = screen.height;

			// scale image to cover the screen
			let scale = Math.max(screenW / myImage.width, screenH / myImage.height);

			// scaled size
			let newW = myImage.width * scale;
			let newH = myImage.height * scale;

			// center offsets (cropping)
			let offsetX = (newW - screenW) / 2;
			let offsetY = (newH - screenH) / 2;

			// apply inset (shrink viewport inside by % of screen size)
			// e.g. inset = 0.05 → 5% padding
			let insetW = screenW * inset;
			let insetH = screenH * inset;

			return {
				width: newW,
				height: newH,
				cropX: offsetX + insetW,
				cropY: offsetY + insetH,
				cropW: screenW - 2 * insetW,
				cropH: screenH - 2 * insetH
			};
		}
	}



	Item {
		id: root2
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right

		width: parent.width/2
		

		Image {
			id: img
			anchors.fill: parent
			source: "/home/solo/Pictures/wallpapers/a_group_of_trees_with_green_leaves.jpg"
			fillMode: Image.PreserveAspectFit
			visible: false
		}

		Shape {
			id: maskShape
			anchors.fill: parent

			//preferredRendererType: Shape.GeometryRenderer

			ShapePath {
				startX: root.width/2
				startY: root.height/2
				strokeWidth: 30
				fillColor: "white"
				PathArc { x: root.width/2; y: root.height/2 + 600; radiusX: 300; radiusY: 300;  }
				PathArc { x: root.width/2; y: root.height/2; radiusX: 300; radiusY: 300;  }
			}
		}

		ShaderEffect {
			anchors.fill: parent

			property variant source: img
			property variant mask: ShaderEffectSource { sourceItem: maskShape }
			clip: true

			fragmentShader: "../default.frag.qsb"
		}
	}
}