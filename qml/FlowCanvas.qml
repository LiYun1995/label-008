import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: canvas
    clip: true

    property var nodeList: []
    property var connectionList: []

    function refresh() {
        nodeList = flowGraph.getNodes()
        connectionList = flowGraph.getConnections()
        lineCanvas.requestPaint()
    }

    function getNodeColor(type) {
        switch(type) {
            case "Start": return "#4CAF50"
            case "End": return "#F44336"
            case "Task": return "#2196F3"
            case "Monster": return "#FF9800"
            case "NPC": return "#9C27B0"
            case "Location": return "#00BCD4"
            default: return "#9E9E9E"
        }
    }

    function getNodeIcon(type) {
        switch(type) {
            case "Start": return "▶"
            case "End": return "■"
            case "Task": return "📋"
            case "Monster": return "👾"
            case "NPC": return "👤"
            case "Location": return "📍"
            default: return "?"
        }
    }

    function getOutputPortX(nodeId) {
        for (var i = 0; i < nodeList.length; i++) {
            if (nodeList[i].id === nodeId) {
                return nodeList[i].x + 160
            }
        }
        return 0
    }

    function getOutputPortY(nodeId) {
        for (var i = 0; i < nodeList.length; i++) {
            if (nodeList[i].id === nodeId) {
                return nodeList[i].y + 35
            }
        }
        return 0
    }

    function getInputPortX(nodeId) {
        for (var i = 0; i < nodeList.length; i++) {
            if (nodeList[i].id === nodeId) {
                return nodeList[i].x
            }
        }
        return 0
    }

    function getInputPortY(nodeId) {
        for (var i = 0; i < nodeList.length; i++) {
            if (nodeList[i].id === nodeId) {
                return nodeList[i].y + 35
            }
        }
        return 0
    }

    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"

        Image {
            anchors.fill: parent
            sourceSize.width: 20
            sourceSize.height: 20
            fillMode: Image.Tile

            canvas: Canvas {
                id: gridCanvas
                width: 20
                height: 20

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.fillStyle = "#f5f5f5"
                    ctx.fillRect(0, 0, width, height)
                    ctx.strokeStyle = "#e8e8e8"
                    ctx.lineWidth = 1
                    ctx.beginPath()
                    ctx.moveTo(0, height)
                    ctx.lineTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.stroke()
                }
            }
        }
    }

    Canvas {
        id: lineCanvas
        anchors.fill: parent
        z: 0

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            for (var i = 0; i < connectionList.length; i++) {
                var conn = connectionList[i]
                var startX = getOutputPortX(conn.source)
                var startY = getOutputPortY(conn.source)
                var endX = getInputPortX(conn.target)
                var endY = getInputPortY(conn.target)

                drawBezierLine(ctx, startX, startY, endX, endY, "#555555", 2)
                drawArrow(ctx, startX, startY, endX, endY, "#555555")
            }

            if (mainWindow.isConnecting && mainWindow.connectionStartId) {
                var sx = getOutputPortX(mainWindow.connectionStartId)
                var sy = getOutputPortY(mainWindow.connectionStartId)
                var ex = mainWindow.tempEndX
                var ey = mainWindow.tempEndY

                ctx.strokeStyle = "#888888"
                ctx.lineWidth = 2
                ctx.setLineDash([6, 4])
                ctx.beginPath()
                var dx = Math.abs(ex - sx)
                var cx1 = sx + dx * 0.5
                var cy1 = sy
                var cx2 = sx + dx * 0.5
                var cy2 = ey
                ctx.moveTo(sx, sy)
                ctx.bezierCurveTo(cx1, cy1, cx2, cy2, ex, ey)
                ctx.stroke()
                ctx.setLineDash([])
            }
        }

        function drawBezierLine(ctx, startX, startY, endX, endY, color, width) {
            ctx.strokeStyle = color
            ctx.lineWidth = width
            ctx.beginPath()

            var dx = Math.abs(endX - startX)
            var controlX = startX + dx * 0.5

            ctx.moveTo(startX, startY)
            ctx.bezierCurveTo(controlX, startY, controlX, endY, endX, endY)
            ctx.stroke()
        }

        function drawArrow(ctx, startX, startY, endX, endY, color) {
            var angle = Math.atan2(endY - startY, endX - startX)
            var arrowSize = 8

            var adjustedEndX = endX - 2
            var adjustedEndY = endY

            ctx.fillStyle = color
            ctx.beginPath()
            ctx.moveTo(adjustedEndX, adjustedEndY)
            ctx.lineTo(
                adjustedEndX - arrowSize * Math.cos(angle - Math.PI / 6),
                adjustedEndY - arrowSize * Math.sin(angle - Math.PI / 6)
            )
            ctx.lineTo(
                adjustedEndX - arrowSize * Math.cos(angle + Math.PI / 6),
                adjustedEndY - arrowSize * Math.sin(angle + Math.PI / 6)
            )
            ctx.closePath()
            ctx.fill()
        }
    }

    Item {
        id: nodeLayer
        anchors.fill: parent
        z: 1

        Repeater {
            id: nodeRepeater
            model: nodeList

            FlowNodeItem {
                nodeId: modelData.id
                nodeType: modelData.type
                nodeName: modelData.name
                nodeDesc: modelData.description
                nodeX: modelData.x
                nodeY: modelData.y
                nodeColor: getNodeColor(modelData.type)
                nodeIcon: getNodeIcon(modelData.type)
                isSelected: mainWindow.selectedNodeId === modelData.id

                onNodeMoved: function(x, y) {
                    var node = flowGraph.getNode(modelData.id)
                    if (node) {
                        node.x = x
                        node.y = y
                    }
                    canvas.refresh()
                }

                onNodeSelected: function(id) {
                    mainWindow.selectNode(id)
                    canvas.refresh()
                }

                onNodeDeleted: function(id) {
                    flowGraph.removeNode(id)
                    mainWindow.clearSelection()
                    canvas.refresh()
                }

                onStartConnect: function(id) {
                    mainWindow.startConnection(id)
                    canvas.refresh()
                }

                onEndConnect: function(id) {
                    mainWindow.endConnection(id)
                    canvas.refresh()
                }
            }
        }
    }

    MouseArea {
        id: mouseTracker
        anchors.fill: parent
        hoverEnabled: true
        z: 10
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: false

        onContainsMouseChanged: {
            if (containsMouse && mainWindow.isConnecting) {
                mainWindow.updateTempEnd(mouseX, mouseY)
                lineCanvas.requestPaint()
            }
        }

        onPositionChanged: {
            if (mainWindow.isConnecting) {
                mainWindow.updateTempEnd(mouse.x, mouse.y)
                lineCanvas.requestPaint()
            }
        }
    }

    MouseArea {
        id: bgMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        z: 0

        onPositionChanged: {
            if (mainWindow.isConnecting) {
                mainWindow.updateTempEnd(mouse.x, mouse.y)
                lineCanvas.requestPaint()
            }
        }

        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                if (mainWindow.isConnecting) {
                    mainWindow.cancelConnection()
                    lineCanvas.requestPaint()
                } else {
                    mainWindow.clearSelection()
                    canvas.refresh()
                }
            }
        }
    }

    Connections {
        target: flowGraph
        function onGraphChanged() { canvas.refresh() }
        function onNodeAdded(node) { canvas.refresh() }
        function onNodeRemoved(id) { canvas.refresh() }
        function onConnectionAdded(sourceId, targetId) { canvas.refresh() }
        function onConnectionRemoved(sourceId, targetId) { canvas.refresh() }
    }

    Component.onCompleted: {
        refresh()
    }
}
