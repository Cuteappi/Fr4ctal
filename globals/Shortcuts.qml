
import Quickshell.Hyprland
import Quickshell

Scope{
	GlobalShortcut {
		name: "wallpaperPicker"
		description: "Toggle Wallpaper Picker"
		onPressed: {
			console.log("toggled")
			Signals.wallpaperPickerToggled()
		}
	}
}