import QtQuick

Item {
	id: root
	visible: false
	// Properties that match the GLSL struct members (excluding the 'u_' prefix for clean QML)
	required property point startPoint
	required property point endPoint
	required property real radius
	required property real strength
	required property real smoothness
	required property bool inverted

	// A function to package this item's data into a shader-compatible JS object
	function getShaderData() {
		return {
			u_start_point: root.startPoint,
			u_end_point: root.endPoint,
			u_radius: root.radius,
			u_strength: root.strength,
			u_smoothness: root.smoothness,
			u_inverted: root.inverted
		};
	}
}