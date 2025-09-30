
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Qt.labs.folderlistmodel
import "../../globals"

Item {
    id: sourceRect
    anchors.centerIn: parent
    height: parent.height
    width: parent.width

    property real spacing: 10
    // Property to manually track the current index, replacing ListView's built-in one.
    property int currentIndex: 0

	property Image wallpaperPreviewImage

    FolderListModel {
        id: folderModel
        folder: `file://${WallpaperSettings.wallpaperDir}`
        showFiles: true
    }

    // When currentIndex changes, update the main preview image.
    onCurrentIndexChanged: {
        console.log("url", folderModel.get(sourceRect.currentIndex, "filePath"))
        sourceRect.wallpaperPreviewImage.source = folderModel.get(sourceRect.currentIndex, "filePath");
        
    }



    // Flickable provides the scrolling container.
    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: layoutRow.width
        contentHeight: parent.height
        clip: true

        // Move key handling here. It needs focus to receive key events.
        focus: true

        // Row arranges the items horizontally.
        Row {
            id: layoutRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: sourceRect.spacing

            // Header for left padding
            Item {
                height: parent.height
                width: sourceRect.width * 0.04
            }

            // Repeater creates the delegates from the model.
            Repeater {
                model: folderModel
                delegate: WallpaperListPreview {
                    source: sourceRect
                    currentIndex: sourceRect.currentIndex
                    Component.onCompleted: {
                        let url = folderModel.get(sourceRect.currentIndex, "filePath")
                        if (url === undefined) return
                        sourceRect.wallpaperPreviewImage.source = url
                    }
                    Keys.onPressed: (event)=> {
                        if (event.key === Qt.Key_Right) {
                            console.log("right")
                            if (sourceRect.currentIndex < folderModel.count - 1) {
                                sourceRect.currentIndex++;
                                // Optional: ensure the selected item is visible
                                // flickable.ensureVisible(...) can be implemented if needed.
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left) {
                            if (sourceRect.currentIndex > 0) {
                                sourceRect.currentIndex--;
                            }
                            event.accepted = true;
                        }
                    }

                }
            }

            // Footer for right padding
            Item {
                height: parent.height
                width: sourceRect.width * 0.04
            }
        }
    }
}