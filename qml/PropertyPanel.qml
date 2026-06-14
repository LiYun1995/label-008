import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: propertyPanel
    color: "#fafafa"
    border.width: 1
    border.color: "#ddd"
    clip: true

    property string currentNodeId: ""

    function updateProperties() {
        currentNodeId = mainWindow.selectedNodeId
        var node = flowGraph.getNode(currentNodeId)
        if (node) {
            nameField.text = node.name
            descField.text = node.description
            typeLabel.text = getTypeName(node.type)
            idLabel.text = node.id.substring(0, 10) + "..."

            var props = node.properties || {}

            taskTypeField.text = props.taskType || ""
            taskTargetField.text = props.target || ""
            taskCountField.text = props.count || ""

            monsterCountField.text = props.count || ""
            monsterActionField.text = props.action || "击败"

            npcActionField.text = props.action || "交谈"

            locationActionField.text = props.action || "前往"

            currentPanel = node.type
        } else {
            currentPanel = ""
        }
    }

    property string currentPanel: ""

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

    function applyName() {
        var node = flowGraph.getNode(currentNodeId)
        if (node) node.name = nameField.text
    }

    function applyDesc() {
        var node = flowGraph.getNode(currentNodeId)
        if (node) node.description = descField.text
    }

    function applyTaskProps() {
        var node = flowGraph.getNode(currentNodeId)
        if (node) {
            node.setProperty("taskType", taskTypeField.text)
            node.setProperty("target", taskTargetField.text)
            node.setProperty("count", taskCountField.text)
        }
    }

    function applyMonsterProps() {
        var node = flowGraph.getNode(currentNodeId)
        if (node) {
            node.setProperty("count", monsterCountField.text)
            node.setProperty("action", monsterActionField.text)
        }
    }

    function applyNPCProps() {
        var node = flowGraph.getNode(currentNodeId)
        if (node) {
            node.setProperty("action", npcActionField.text)
        }
    }

    function applyLocationProps() {
        var node = flowGraph.getNode(currentNodeId)
        if (node) {
            node.setProperty("action", locationActionField.text)
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Text {
            text: "属性面板"
            font.bold: true
            font.pointSize: 12
            color: "#333"
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#e0e0e0"
        }

        ScrollView {
            width: parent.width
            Layout.fillHeight: true
            clip: true

            Column {
                width: parent.width
                spacing: 10
                visible: currentPanel !== ""

                Text {
                    text: "基本信息"
                    font.bold: true
                    font.pointSize: 10
                    color: "#333"
                }

                Row {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "类型:"
                        font.pointSize: 10
                        color: "#666"
                        width: 50
                    }

                    Text {
                        id: typeLabel
                        font.bold: true
                        font.pointSize: 10
                        color: "#333"
                    }
                }

                Row {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "ID:"
                        font.pointSize: 9
                        color: "#666"
                        width: 50
                    }

                    Text {
                        id: idLabel
                        font.pointSize: 9
                        color: "#999"
                        font.family: "Consolas, monospace"
                    }
                }

                Item { width: 1; height: 5 }

                Text {
                    text: "名称"
                    font.pointSize: 10
                    color: "#555"
                }

                TextField {
                    id: nameField
                    width: parent.width
                    placeholderText: "节点名称"
                    onEditingFinished: applyName()
                }

                Text {
                    text: "描述"
                    font.pointSize: 10
                    color: "#555"
                }

                TextArea {
                    id: descField
                    width: parent.width
                    height: 60
                    placeholderText: "节点描述"
                    wrapMode: Text.WordWrap
                    onEditingFinished: applyDesc()
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#e0e0e0"
                }

                Column {
                    width: parent.width
                    spacing: 8
                    visible: currentPanel === "Task"

                    Text {
                        text: "任务属性"
                        font.bold: true
                        font.pointSize: 10
                        color: "#2196F3"
                    }

                    Text { text: "任务类型"; font.pointSize: 9; color: "#666" }
                    TextField {
                        id: taskTypeField
                        width: parent.width
                        placeholderText: "例如：击杀任务、收集任务..."
                        onEditingFinished: applyTaskProps()
                    }

                    Text { text: "目标对象"; font.pointSize: 9; color: "#666" }
                    TextField {
                        id: taskTargetField
                        width: parent.width
                        placeholderText: "例如：大头怪"
                        onEditingFinished: applyTaskProps()
                    }

                    Text { text: "数量"; font.pointSize: 9; color: "#666" }
                    TextField {
                        id: taskCountField
                        width: parent.width
                        placeholderText: "例如：20"
                        onEditingFinished: applyTaskProps()
                    }
                }

                Column {
                    width: parent.width
                    spacing: 8
                    visible: currentPanel === "Monster"

                    Text {
                        text: "怪物属性"
                        font.bold: true
                        font.pointSize: 10
                        color: "#FF9800"
                    }

                    Text { text: "数量"; font.pointSize: 9; color: "#666" }
                    TextField {
                        id: monsterCountField
                        width: parent.width
                        placeholderText: "例如：20"
                        onEditingFinished: applyMonsterProps()
                    }

                    Text { text: "行为"; font.pointSize: 9; color: "#666" }
                    TextField {
                        id: monsterActionField
                        width: parent.width
                        placeholderText: "例如：击败、遭遇..."
                        onEditingFinished: applyMonsterProps()
                    }
                }

                Column {
                    width: parent.width
                    spacing: 8
                    visible: currentPanel === "NPC"

                    Text {
                        text: "NPC 属性"
                        font.bold: true
                        font.pointSize: 10
                        color: "#9C27B0"
                    }

                    Text { text: "交互方式"; font.pointSize: 9; color: "#666" }
                    TextField {
                        id: npcActionField
                        width: parent.width
                        placeholderText: "例如：交谈、交易、交任务..."
                        onEditingFinished: applyNPCProps()
                    }
                }

                Column {
                    width: parent.width
                    spacing: 8
                    visible: currentPanel === "Location"

                    Text {
                        text: "地点属性"
                        font.bold: true
                        font.pointSize: 10
                        color: "#00BCD4"
                    }

                    Text { text: "动作"; font.pointSize: 9; color: "#666" }
                    TextField {
                        id: locationActionField
                        width: parent.width
                        placeholderText: "例如：前往、返回、到达..."
                        onEditingFinished: applyLocationProps()
                    }
                }

                Column {
                    width: parent.width
                    spacing: 8
                    visible: currentPanel === "Start" || currentPanel === "End"

                    Text {
                        text: "提示"
                        font.pointSize: 10
                        color: "#888"
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        text: currentPanel === "Start" ?
                                     "起点节点是流程的开始，只能有输出连接。" :
                                     "终点节点是流程的结束，只能有输入连接。"
                        font.pointSize: 9
                        color: "#999"
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 10
            visible: currentPanel === ""
            anchors.centerIn: parent

            Text {
                text: "请选择一个节点"
                font.pointSize: 12
                color: "#999"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "点击画布中的节点查看和编辑属性"
                font.pointSize: 9
                color: "#bbb"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
