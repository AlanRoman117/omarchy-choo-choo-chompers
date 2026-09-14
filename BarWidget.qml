import QtQuick
import Quickshell
import qs.Ui

// A bar button that opens the game. The game itself runs in a browser window,
// not in the shell; this file only starts launch.sh next to it.
BarWidget {
  id: root
  moduleName: "alanroman.choo-choo-chompers"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: String.fromCodePoint(0xF052C) // nf-md-train
    horizontalMargin: 7.5
    onPressed: function(button) {
      var script = decodeURIComponent(String(Qt.resolvedUrl("launch.sh")).replace(/^file:\/\//, ""))
      // Argv form: the path only ever reaches bash as a positional parameter.
      Quickshell.execDetached(["bash", "-lc", 'exec bash "$@"', "bash", script])
    }
  }
}
