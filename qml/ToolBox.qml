import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: toolBox
    color: "#fafafa"
    border.width: 1
    border.color: "#ddd"
    clip: false

    signal createNodeRequested(string type, string name, real x, real y)

    property var nodeTypes: [
        { type: "Start", name: "起点", icon: "▶", color: "#4CAF50", desc: "流程开始" },
        { type: "End", name: "终点", icon: "■", color: "#F44336", desc: "流程结束" },
        { type: "Task", name: "任务", icon: "📋", color: "#2196F3", desc: "接取或完成任务" },
        { type: "Monster", name: "怪物", icon: "👾", color: "#FF9800", desc: "击败或遭遇怪物" },
        { type: "NPC", name: "NPC", icon: "👤", color: "#9C27B0", desc: "与NPC交互" },
        { type: "Location", name: "地点", icon: "📍", color: "#00BCD4", desc: "前往某个地点" }
    ]

    property string dragType: ""
    property string dragName: ""
    property bool isDragging: false
    property real dragStartX: 0
    property real dragStartY: 0

    Rectangle {
        id: dragGhost
        width: 130
        height: 48
        visible: false
        z: 9999
        opacity: 0.85
        radius: 6
        border.width: 2
        border.color: "#333"

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: ghostIcon
                font.pointSize: 16
                color: "white"
            }

            Text {
                id: ghostText
                font.bold: true
                color: "white"
            }
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: "工具箱"
            font.bold: true
            font.pointSize: 12
            color: "#333"
        }

        Text {
            text: "拖拽节点到画布"
            font.pointSize: 9
            color: "#888"
        }

        Repeater {
            model: nodeTypes

            Rectangle {
                width: parent.width
                height: 60
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: modelData.color

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pointSize: 16
                            color: "white"
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: modelData.name
                            font.bold: true
                            font.pointSize: 11
                            color: "#333"
                        }

                        Text {
                            text: modelData.desc
                            font.pointSize: 9
                            color: "#888"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.OpenHandCursor
                    acceptedButtons: Qt.LeftButton

                    onPressed: {
                        toolBox.dragType = modelData.type
                        toolBox.dragName = "新建" + modelData.name
                        toolBox.isDragging = true
                        toolBox.dragStartX = mouse.x
                        toolBox.dragStartY = mouse.y

                        dragGhost.color = modelData.color
                        ghostIcon.text = modelData.icon
                        ghostText.text = modelData.name
                        dragGhost.visible = true
                        updateGhostPosition()
                    }

                    onPositionChanged: {
                        if (toolBox.isDragging) {
                            updateGhostPosition()
                        }
                    }

                    onReleased: {
                        if (toolBox.isDragging) {
                            var canvasPos = mainWindow.mapToCanvas(
                                mouseArea.mapToGlobal(mouse.x, mouse.y)
                            )
                            if (canvasPos.valid) {
                                flowGraph.addNode(
                                    toolBox.dragType,
                                    toolBox.dragName,
                                    canvasPos.x - 80,
                                    canvasPos.y - 25
                                )
                            }
                        }
                        toolBox.isDragging = false
                        dragGhost.visible = false
                    }

                    function updateGhostPosition() {
                        var globalPos = mouseArea.mapToGlobal(mouse.x, mouse.y)
                        var localPos = toolBox.mapFromGlobal(globalPos.x, globalPos.y)
                        dragGhost.x = localPos.x - dragGhost.width / 2
                        dragGhost.y = localPos.y - dragGhost.height / 2
                    }
                }
            }
        }

        Item {
            height: 20
        }

        Text {
            text: "操作提示"
            font.bold: true
            font.pointSize: 11
            color: "#333"
        }

        Text {
            text: "• 拖拽节点到画布创建\n• 点击节点选中查看属性\n• 拖拽节点移动位置\n• 右键节点可删除\n• 点击输出端口连线\n• 点击输入端口完成连线"
            font.pointSize: 9
            color: "#666"
            lineHeight: 1.5
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }
}
