import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: nodeItem
    width: 160
    height: 70

    property string nodeId: ""
    property string nodeType: "Task"
    property string nodeName: "新节点"
    property string nodeDesc: ""
    property bool isSelected: false

    property real nodeX: 0
    property real nodeY: 0

    property color nodeColor: "#2196F3"
    property string nodeIcon: "📋"

    signal nodeMoved(real x, real y)
    signal nodeSelected(string id)
    signal nodeDeleted(string id)
    signal startConnect(string id)
    signal endConnect(string id)

    x: nodeX
    y: nodeY

    z: isSelected ? 10 : 1

    Rectangle {
        id: nodeRect
        anchors.fill: parent
        color: "white"
        border.color: isSelected ? "#FFC107" : nodeColor
        border.width: isSelected ? 3 : 2
        radius: 8
    }

    Rectangle {
        id: colorBar
        width: parent.width
        height: 4
        color: nodeColor
        anchors.top: parent.top
        radius: 2
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 10
        spacing: 10

        Rectangle {
            width: 38
            height: 38
            radius: 6
            color: nodeColor
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: nodeIcon
                font.pointSize: 20
                color: "white"
            }
        }

        Column {
            width: parent.width - 38 - 20 - 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                text: nodeName
                font.bold: true
                font.pointSize: 11
                color: "#333"
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: nodeDesc || getTypeName(nodeType)
                font.pointSize: 9
                color: "#888"
                elide: Text.ElideRight
                width: parent.width
            }
        }
    }

    Rectangle {
        id: inputPort
        width: 16
        height: 16
        radius: 8
        color: isSelected ? "#FFC107" : nodeColor
        border.color: "white"
        border.width: 3
        anchors.left: parent.left
        anchors.leftMargin: -8
        anchors.verticalCenter: parent.verticalCenter
        z: 5

        visible: nodeType !== "Start"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onEntered: {
                inputPort.scale = 1.3
            }
            onExited: {
                inputPort.scale = 1.0
            }

            onClicked: {
                mouse.accepted = true
                if (mainWindow.isConnecting) {
                    endConnect(nodeId)
                }
            }
        }
    }

    Rectangle {
        id: outputPort
        width: 16
        height: 16
        radius: 8
        color: isSelected ? "#FFC107" : nodeColor
        border.color: "white"
        border.width: 3
        anchors.right: parent.right
        anchors.rightMargin: -8
        anchors.verticalCenter: parent.verticalCenter
        z: 5

        visible: nodeType !== "End"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onEntered: {
                outputPort.scale = 1.3
            }
            onExited: {
                outputPort.scale = 1.0
            }

            onClicked: {
                mouse.accepted = true
                if (!mainWindow.isConnecting) {
                    startConnect(nodeId)
                }
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: nodeItem
        drag.axis: Drag.XAndYAxis
        cursorShape: Qt.OpenHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        z: 3

        onPressed: {
            if (mouse.button === Qt.LeftButton) {
                nodeSelected(nodeId)
                dragArea.cursorShape = Qt.ClosedHandCursor
            }
        }

        onReleased: {
            dragArea.cursorShape = Qt.OpenHandCursor
            nodeMoved(nodeItem.x, nodeItem.y)
        }

        onPositionChanged: {
            if (drag.active) {
                nodeMoved(nodeItem.x, nodeItem.y)
            }
        }
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: "删除节点"
            onTriggered: nodeDeleted(nodeId)
        }
        MenuSeparator {}
        MenuItem {
            text: "复制节点"
            onTriggered: {
                var newNode = flowGraph.addNode(nodeType, nodeName + " 副本", nodeX + 40, nodeY + 40)
            }
        }
    }

    function getTypeName(type) {
        switch(type) {
            case "Start": return "起点"
            case "End": return "终点"
            case "Task": return "任务"
            case "Monster": return "怪物"
            case "NPC": return "NPC"
            case "Location": return "地点"
            default: return "未知"
        }
    }
}
