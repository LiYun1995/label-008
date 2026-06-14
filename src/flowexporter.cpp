#include "flowexporter.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QSet>
#include <QStack>
#include <functional>

FlowExporter::FlowExporter(QObject *parent)
    : QObject(parent)
{
}

QString FlowExporter::exportToText(FlowGraph *graph) const
{
    if (!graph || graph->nodeCount() == 0) {
        return QString("游戏流程图为空，请先添加节点。");
    }

    QString result;
    QTextStream stream(&result);

    stream << "========================================" << Qt::endl;
    stream << "      游戏主角行为流程说明书" << Qt::endl;
    stream << "========================================" << Qt::endl;
    stream << Qt::endl;

    stream << "【流程概览】" << Qt::endl;
    stream << "  节点总数: " << graph->nodeCount() << Qt::endl;
    stream << "  连接总数: " << graph->connectionCount() << Qt::endl;
    stream << Qt::endl;

    stream << "【节点列表】" << Qt::endl;
    stream << "----------------------------------------" << Qt::endl;

    QList<FlowNode*> nodes = graph->nodesList();
    int index = 1;
    for (FlowNode *node : nodes) {
        stream << "  " << index++ << ". [" << getNodeTypeLabel(node->nodeType()) << "] "
               << node->name() << Qt::endl;
        if (!node->description().isEmpty()) {
            stream << "     描述: " << node->description() << Qt::endl;
        }

        QVariantMap props = node->properties();
        if (!props.isEmpty()) {
            stream << "     属性:" << Qt::endl;
            for (auto it = props.constBegin(); it != props.constEnd(); ++it) {
                stream << "       - " << it.key() << ": " << it.value().toString() << Qt::endl;
            }
        }
    }
    stream << Qt::endl;

    stream << "【行为流程】" << Qt::endl;
    stream << "----------------------------------------" << Qt::endl;

    QString description = generateFlowDescription(graph);
    stream << description << Qt::endl;
    stream << Qt::endl;

    stream << "========================================" << Qt::endl;
    stream << "         流程说明书 - 结束" << Qt::endl;
    stream << "========================================" << Qt::endl;

    return result;
}

bool FlowExporter::exportToFile(FlowGraph *graph, const QString &filePath) const
{
    if (!graph) return false;

    QString content = exportToText(graph);

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行写入:" << filePath;
        return false;
    }

    QTextStream out(&file);
    out.setCodec("UTF-8");
    out << content;
    file.close();

    return true;
}

QString FlowExporter::generateFlowDescription(FlowGraph *graph) const
{
    if (!graph || graph->nodeCount() == 0) {
        return "  (暂无流程)";
    }

    QStringList sorted = topologicalSort(graph);

    if (sorted.isEmpty()) {
        return "  (无法生成有序流程，可能存在循环依赖)";
    }

    QString result;
    QTextStream stream(&result);

    int step = 1;
    for (const QString &nodeId : sorted) {
        FlowNode *node = graph->getNode(nodeId);
        if (!node) continue;

        QString desc = describeNode(node);
        stream << "  步骤 " << step++ << ": " << desc << Qt::endl;
    }

    return result;
}

QStringList FlowExporter::topologicalSort(FlowGraph *graph) const
{
    QStringList result;
    QSet<QString> visited;
    QSet<QString> recursionStack;
    bool hasCycle = false;

    QStringList startNodes;
    for (FlowNode *node : graph->nodesList()) {
        if (node->incomingConnections().isEmpty()) {
            startNodes.append(node->id());
        }
    }

    if (startNodes.isEmpty() && graph->nodeCount() > 0) {
        startNodes.append(graph->nodesList().first()->id());
    }

    std::function<void(const QString&)> dfs = [&](const QString &nodeId) {
        if (hasCycle) return;
        if (recursionStack.contains(nodeId)) {
            hasCycle = true;
            return;
        }
        if (visited.contains(nodeId)) return;

        visited.insert(nodeId);
        recursionStack.insert(nodeId);

        FlowNode *node = graph->getNode(nodeId);
        if (node) {
            for (const QString &nextId : node->outgoingConnections()) {
                dfs(nextId);
            }
        }

        recursionStack.remove(nodeId);
        result.prepend(nodeId);
    };

    for (const QString &startId : startNodes) {
        dfs(startId);
    }

    for (FlowNode *node : graph->nodesList()) {
        if (!visited.contains(node->id())) {
            dfs(node->id());
        }
    }

    if (hasCycle) {
        return QStringList();
    }

    return result;
}

QString FlowExporter::describeNode(FlowNode *node) const
{
    if (!node) return QString();

    FlowNode::NodeType type = node->nodeType();
    QString name = node->name();
    QString desc = node->description();

    switch (type) {
    case FlowNode::Start:
        return QString("主角开始冒险之旅");

    case FlowNode::End:
        return QString("流程结束，%1").arg(desc.isEmpty() ? "任务完成" : desc);

    case FlowNode::Task: {
        QVariantMap props = node->properties();
        QString taskType = props.value("taskType", "普通任务").toString();
        QString target = props.value("target", "").toString();
        QString count = props.value("count", "").toString();

        QString taskDesc = QString("接取任务【%1】").arg(name);
        if (!target.isEmpty() && !count.isEmpty()) {
            taskDesc += QString("，需要%1个%2").arg(count).arg(target);
        } else if (!target.isEmpty()) {
            taskDesc += QString("，目标：%1").arg(target);
        }
        if (!desc.isEmpty()) {
            taskDesc += QString("（%1）").arg(desc);
        }
        return taskDesc;
    }

    case FlowNode::Monster: {
        QVariantMap props = node->properties();
        QString count = props.value("count", "若干").toString();
        QString action = props.value("action", "击败").toString();

        QString monsterDesc = QString("%1 %2只%3").arg(action).arg(count).arg(name);
        if (!desc.isEmpty()) {
            monsterDesc += QString("（%1）").arg(desc);
        }
        return monsterDesc;
    }

    case FlowNode::NPC: {
        QVariantMap props = node->properties();
        QString action = props.value("action", "交谈").toString();

        QString npcDesc = QString("找到%1并与之%2").arg(name).arg(action);
        if (!desc.isEmpty()) {
            npcDesc += QString("：%1").arg(desc);
        }
        return npcDesc;
    }

    case FlowNode::Location: {
        QVariantMap props = node->properties();
        QString action = props.value("action", "前往").toString();

        QString locDesc = QString("%1 %2").arg(action).arg(name);
        if (!desc.isEmpty()) {
            locDesc += QString("（%1）").arg(desc);
        }
        return locDesc;
    }

    default:
        return name;
    }
}

QString FlowExporter::getNodeTypeLabel(FlowNode::NodeType type) const
{
    switch (type) {
    case FlowNode::Start: return "起点";
    case FlowNode::End: return "终点";
    case FlowNode::Task: return "任务";
    case FlowNode::Monster: return "怪物";
    case FlowNode::NPC: return "NPC";
    case FlowNode::Location: return "地点";
    default: return "未知";
    }
}
