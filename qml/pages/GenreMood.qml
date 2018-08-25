/**
 * Copyright (C) 2018 Willem-Jan de Hoog
 *
 * License: MIT
 */


import QtQuick 2.2
import Sailfish.Silica 1.0

import "../components"
import "../Spotify.js" as Spotify
import "../Util.js" as Util

Page {
    id: genreMoodPage
    objectName: "GenreMoodPage"

    property string defaultImageSource : "image://theme/icon-l-music"
    property bool showBusy: false

    property int offset: 0
    property int limit: app.searchLimit.value
    property bool canLoadNext: true
    property bool canLoadPrevious: offset >= limit
    property int currentIndex: -1

    allowedOrientations: Orientation.All

    ListModel {
        id: searchModel
    }

    SilicaListView {
        id: listView
        model: searchModel

        width: parent.width
        anchors.top: parent.top
        anchors.bottom: navPanel.top
        clip: navPanel.expanded

        LoadPullMenus {}
        LoadPushMenus {}

        header: Column {
            id: lvColumn

            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                id: pHeader
                width: parent.width
                title: qsTr("Genres & Moods")
                MenuButton {}
            }
        }

        delegate: ListItem {
            id: listItem
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            contentHeight: Theme.itemSizeLarge

            Image {
                id: categoryIcon
                width: Theme.iconSizeLarge
                height: width
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                source: category.icons[0].url
            }

            Label {
                id: categoryName
                anchors.left: categoryIcon.right
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.primaryColor
                truncationMode: TruncationMode.Fade
                text: category.name
            }
            onClicked: app.pushPage(Util.HutspotPage.GenreMoodPlaylist, {category: category})
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: parent.count == 0
            text: qsTr("No Genres or Moods found")
            hintText: qsTr("Pull down to reload")
        }

    }

    NavigationPanel {
        id: navPanel
    }

    function refresh() {
        var i;
        //showBusy = true
        searchModel.clear()

        Spotify.getCategories({offset: offset, limit: limit}, function(error, data) {
            if(data) {
                try {
                    console.log("number of Categories: " + data.categories.items.length)
                    offset = data.categories.offset
                    for(i=0;i<data.categories.items.length;i++) {
                        searchModel.append({category: data.categories.items[i]})
                    }
                } catch (err) {
                    console.log(err)
                }
            } else {
                console.log("No Data for getCategories")
            }
        })

    }

    Connections {
        target: app
        onLoggedInChanged: {
            if(app.loggedIn)
                refresh()
        }
        onLinked: refresh()
    }

    Component.onCompleted: {
        if(app.loggedIn)
            refresh()
    }
}
