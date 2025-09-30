
import Quickshell.Hyprland
import Quickshell

Scope{
	GlobalShortcut {
		id: wallpaperPicker
		name: "wallpaperPicker"
		description: "Toggle Wallpaper Picker"
		onPressed: {
			Signals.wallpaperPickerToggled()
			Signals.wallpaperPickerGrabHandler()

		}
	}
}