pragma Singleton

import Quickshell
import "../../Globals.qml"

Singleton {
	id: root

	property string currentWallpaper : ""
	property int animationCenter : Globals.AnimationCenter.Random


}