import QtQuick
import qs.theme
import qs.core
import qs.widgets.buttons

IconButton {
    id: root

    icon: "nixos"
    size: Spacing.barHeight - 4
    iconSize: Spacing.iconMd

    onClicked: {
        Dispatcher.dispatch(Actions.togglePanel("home"))
    }
}
