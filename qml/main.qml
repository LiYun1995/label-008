import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import GameFlow 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 600
    title: qsTr("游戏流程编辑器 - 低代码工具")

    property string selectedNodeId: ""
    property bool isConnecting: false
    property string connectionStartId: ""
    property real tempEndX: 0
    property real tempEndY: 0

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

    function getNodeTypeName(type) {
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

    function mapToCanvas(globalX, globalY) {
        var canvasPos = canvas.mapFromGlobal(globalX, globalY)
        return {
            x: canvasPos.x,
            y: canvasPos.y,
            valid: canvasPos.x >= 0 && canvasPos.y >= 0 &&
                   canvasPos.x <= canvas.width && canvasPos.y <= canvas.height
        }
    }

    function selectNode(nodeId) {
        selectedNodeId = nodeId
        propertyPanel.updateProperties()
    }

    function clearSelection() {
        selectedNodeId = ""
        propertyPanel.updateProperties()
    }

    function startConnection(nodeId) {
        isConnecting = true
        connectionStartId = nodeId
        var node = flowGraph.getNode(nodeId)
        if (node) {
            tempEndX = node.x + 160
            tempEndY = node.y + 35
        }
    }

    function endConnection(nodeId) {
        if (isConnecting && connectionStartId !== "" && connectionStartId !== nodeId) {
            flowGraph.addConnection(connectionStartId, nodeId)
        }
        isConnecting = false
        connectionStartId = ""
    }

    function cancelConnection() {
        isConnecting = false
        connectionStartId = ""
    }

    function updateTempEnd(x, y) {
        tempEndX = x
        tempEndY = y
    }

    header: ToolBar {
        id: toolBar
        RowLayout {
            anchors.fill: parent
            spacing: 4

            ToolButton {
                text: "新建"
                icon.name: "document-new"
                onClicked: {
                    if (flowGraph.nodeCount > 0) {
                        if (confirmDialog.visible) return
                        confirmDialog.text = "确定要新建流程图吗？当前内容将被清空。"
                        confirmDialog.title = "确认新建"
                        confirmDialog.visible = true
                        confirmDialog.onAccepted = function() {
                            flowGraph.clear()
                            clearSelection()
                        }
                    }
                }
            }

            ToolButton {
                text: "清空"
                icon.name: "edit-clear"
                onClicked: {
                    if (flowGraph.nodeCount > 0) {
                        confirmDialog.text = "确定要清空所有节点吗？"
                        confirmDialog.title = "确认清空"
                        confirmDialog.visible = true
                        confirmDialog.onAccepted = function() {
                            flowGraph.clear()
                            clearSelection()
                        }
                    }
                }
            }

            ToolButton {
                text: "删除选中"
                icon.name: "edit-delete"
                enabled: selectedNodeId !== ""
                onClicked: {
                    if (selectedNodeId) {
                        flowGraph.removeNode(selectedNodeId)
                        clearSelection()
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                text: "节点: " + flowGraph.nodeCount + " | 连接: " + flowGraph.connectionCount
                color: "#666"
                font.pointSize: 10
            }

            Item { width: 20 }

            ToolButton {
                text: "预览"
                icon.name: "document-print"
                onClicked: {
                    previewText.text = flowExporter.exportToText(flowGraph)
                    previewDialog.visible = true
                }
            }

            ToolButton {
                text: "导出 TXT"
                icon.name: "document-save"
                onClicked: {
                    exportDialog.visible = true
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ToolBox {
            id: toolBox
            Layout.preferredWidth: 200
            Layout.fillHeight: true
        }

        Rectangle {
            id: canvasContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            FlowCanvas {
                id: canvas
                anchors.fill: parent
            }
        }

        PropertyPanel {
            id: propertyPanel
            Layout.preferredWidth: 300
            Layout.fillHeight: true
        }
    }

    Dialog {
        id: confirmDialog
        title: "确认"
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modal: true
        visible: false
        property string text: ""

        Column {
            width: parent.width
            spacing: 10
            Text {
                text: confirmDialog.text
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }

    Dialog {
        id: previewDialog
        title: "流程预览"
        standardButtons: StandardButton.Close
        modal: true
        visible: false
        width: 650
        height: 550

        Column {
            anchors.fill: parent
            spacing: 10

            Text {
                text: "游戏流程说明书预览"
                font.bold: true
                font.pointSize: 12
            }

            ScrollView {
                width: parent.width
                height: parent.height - 40
                clip: true

                Text {
                    id: previewText
                    font.family: "Consolas, Courier New, monospace"
                    font.pointSize: 9
                    wrapMode: Text.NoWrap
                }
            }
        }
    }

    FileDialog {
        id: exportDialog
        title: "导出流程文件"
        selectExisting: false
        selectMultiple: false
        nameFilters: ["文本文件 (*.txt)", "所有文件 (*)"]
        defaultSuffix: "txt"
        onAccepted: {
            var filePath = exportDialog.fileUrl.toString()
            if (filePath.startsWith("file:///")) {
                filePath = filePath.substring(8)
            }
            var success = flowExporter.exportToFile(flowGraph, filePath)
            if (success) {
                showMessage("导出成功")
            } else {
                showMessage("导出失败")
            }
        }
    }

    function showMessage(msg) {
        messageText.text = msg
        messagePopup.open()
    }

    Popup {
        id: messagePopup
        x: (mainWindow.width - width) / 2
        y: 80
        width: 200
        height: 40
        modal: false
        visible: false
        timeout: 2000

        background: Rectangle {
            color: "#333"
            radius: 6
            opacity: 0.9
        }

        Text {
            id: messageText
            anchors.centerIn: parent
            color: "white"
            font.pointSize: 10
        }
    }

    Component.onCompleted: {
        var startNode = flowGraph.addNode("Start", "开始冒险", 80, 220)
        var npcNode = flowGraph.addNode("NPC", "新手引导员", 320, 220)
        var taskNode = flowGraph.addNode("Task", "新手任务：消灭大头怪", 580, 120)
        var monsterNode = flowGraph.addNode("Monster", "大头怪", 580, 340)
        var locationNode = flowGraph.addNode("Location", "新手村广场", 860, 220)
        var endNode = flowGraph.addNode("End", "任务完成", 1100, 220)

        taskNode.setProperty("taskType", "击杀任务")
        taskNode.setProperty("target", "大头怪")
        taskNode.setProperty("count", "20")

        monsterNode.setProperty("count", "20")
        monsterNode.setProperty("action", "击败")

        npcNode.setProperty("action", "交谈接任务")

        locationNode.setProperty("action", "返回")

        flowGraph.addConnection(startNode.id, npcNode.id)
        flowGraph.addConnection(npcNode.id, taskNode.id)
        flowGraph.addConnection(taskNode.id, monsterNode.id)
        flowGraph.addConnection(monsterNode.id, locationNode.id)
        flowGraph.addConnection(locationNode.id, endNode.id)

        canvas.refresh()
    }
}
