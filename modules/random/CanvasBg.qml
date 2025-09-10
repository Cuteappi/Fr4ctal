import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell


Item{
	id: wrapper
	anchors.fill: parent

	Canvas {
		id: root
		anchors.fill: parent
		renderStrategy: Canvas.Cooperative
		// renderTarget: Canvas.FramebufferObject

		antialiasing: true

		property real screenH: Quickshell.screens[1].height 
		property real screenW: Quickshell.screens[1].width 
		property real thinWidth: 8
		property real barWidth: 50
		property real radius: 24


		Image {
			id: myImage
			source: "/home/solo/Pictures/wallpapers/a_group_of_trees_with_green_leaves.jpg"
			fillMode: Image.PreserveAspectFit
			visible: false 
		}

		

		onPaint:{
			var ctx = getContext("2d");
			ctx.reset();

			ctx.beginPath();

			var x = thinWidth;
			var y = thinWidth;
			var w = screenW - barWidth - thinWidth;
			var h = screenH - 2 * thinWidth;
			var r = radius;
			

			// bg to clip rectangle from
			ctx.moveTo(0 ,0);
			ctx.lineTo(screenW, 0);
			ctx.lineTo(screenW, screenH);
			ctx.lineTo(0, screenH);
			ctx.lineTo(0, 0);

			// rounded rectangle
			ctx.moveTo(x + r, y);
			ctx.lineTo(x + w - r, y);
			ctx.arcTo(x + w, y, x + w, y + r, r);
			ctx.lineTo(x + w, y + h - r);
			ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
			ctx.lineTo(x + r, y + h);
			ctx.arcTo(x, y + h, x, y + h - r, r);
			ctx.lineTo(x, y + r);
			ctx.arcTo(x, y, x + r, y, r);

			ctx.closePath();

			ctx.clip("evenodd");
			

			if (myImage.status === Image.Ready) {
				ctx.drawImage(myImage, 0, 0, screenW, screenH);
				ctx.fillStyle = "rgba(70, 130, 180, 0)"
				ctx.fill()
			} else {
				ctx.fillStyle = "rgba(70, 130, 180, 0.7)"
				ctx.fill()
			}

			
				// fallback fill if no image
				// ctx.fillStyle = "rgba(70, 130, 180, 0.7)"
				// ctx.fill()
			

		}

		onImageLoaded: {
			root.requestPaint();
		}

		onRadiusChanged:{
			root.requestPaint();
		}
	}


	GaussianBlur {
		id: blur
		anchors.fill: root
		source: root
		radius: 0
		cached: true
	}
}