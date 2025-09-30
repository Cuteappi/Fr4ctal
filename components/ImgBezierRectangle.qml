import QtQuick
import Qt5Compat.GraphicalEffects

Item {
	id: root

	required property QtObject source
	required property real radius
	required property real roundingStrength
	
	property bool shadowEnabled: false
	property real shadowRadius: 6.0
	property int shadowSamples: 4
	property real shadowHorizontalOffset: 0
	property real shadowVerticalOffset: 0
	property color shadowColor: Qt.rgba(0.05, 0.05, 0.05, 0.75)

	BezierRectangle {
		id: shape
		anchors.fill: parent
		radius: root.radius
		roundingStrength: root.roundingStrength
	}

	ShaderEffectSource {
		id: maskSource
		sourceItem: shape
		hideSource: true
	}

	OpacityMask {
		id: opacityMask
		anchors.fill: parent
		source: root.source
		maskSource: maskSource
		visible: !root.shadowEnabled
	}

	DropShadow {
        id: bgLayout
        source: opacityMask
        anchors.fill: opacityMask
        radius: root.shadowRadius
        samples: root.shadowSamples
        horizontalOffset: root.shadowHorizontalOffset
        verticalOffset: root.shadowVerticalOffset
        color: root.shadowColor
		visible: root.shadowEnabled
    }
	
}