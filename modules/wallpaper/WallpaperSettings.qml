pragma Singleton

import Quickshell
import "../../globals"

Singleton {
	id: root

	property string currentWallpaper : ""
	property string wallpaperDir : "/home/solo/Pictures/wallpapers"
	property int animationCenter : Globals.AnimationCenter.Random

	//not configurable
	property string lastActiveWindow: ""
	property bool clickedOut: false

}