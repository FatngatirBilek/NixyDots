import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import "root:/Data/" as Data

PanelWindow {
    id: borderWindow
    width: Screen.width
    height: Screen.height
    visible: true
    color: "transparent"
    mask: Region{}


    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        preferredRendererType: Shape.GeometryRenderer

        ShapePath {
            fillColor: Data.Colors.accentColor
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill

            // Outer Rectangle (Full Screen)
            PathMove { x: 0; y: 0 }
            PathLine { x: width; y: 0 }
            PathLine { x: width; y: height }
            PathLine { x: 0; y: height }
            PathLine { x: 0; y: 0 }

            // Inner Cutout (using properties)
            PathMove { 
                x: Data.Settings.borderWidth
                y: Data.Settings.borderWidth + Data.Settings.cornerRadius 
            }
            
            // Top-left concave corner
            PathArc {
                x: Data.Settings.borderWidth + Data.Settings.cornerRadius
                y: Data.Settings.borderWidth
                radiusX: Data.Settings.cornerRadius
                radiusY: Data.Settings.cornerRadius
                direction: PathArc.Clockwise
            }

            // Top edge
            PathLine { 
                x: width - Data.Settings.borderWidth - Data.Settings.cornerRadius
                y: Data.Settings.borderWidth 
            }

            // Top-right concave corner
            PathArc {
                x: width - Data.Settings.borderWidth
                y: Data.Settings.borderWidth + Data.Settings.cornerRadius
                radiusX: Data.Settings.cornerRadius
                radiusY: Data.Settings.cornerRadius
                direction: PathArc.Clockwise
            }

            // Right edge
            PathLine { 
                x: width - Data.Settings.borderWidth
                y: height - Data.Settings.borderWidth - Data.Settings.cornerRadius 
            }

            // Bottom-right concave corner
            PathArc {
                x: width - Data.Settings.borderWidth - Data.Settings.cornerRadius
                y: height - Data.Settings.borderWidth
                radiusX: Data.Settings.cornerRadius
                radiusY: Data.Settings.cornerRadius
                direction: PathArc.Clockwise
            }

            // Bottom edge
            PathLine { 
                x: Data.Settings.borderWidth + Data.Settings.cornerRadius
                y: height - Data.Settings.borderWidth 
            }

            // Bottom-left concave corner
            PathArc {
                x: Data.Settings.borderWidth
                y: height - Data.Settings.borderWidth - Data.Settings.cornerRadius
                radiusX: Data.Settings.cornerRadius
                radiusY: Data.Settings.cornerRadius
                direction: PathArc.Clockwise
            }

            // Close path
            PathLine { 
                x: Data.Settings.borderWidth
                y: Data.Settings.borderWidth + Data.Settings.cornerRadius 
            }
        }
    }
}