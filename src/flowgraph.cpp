#include "flowgraph.h"
#include <QDebug>

FlowGraph::FlowGraph(QObject *parent)
    : QObject(parent)
    , m_connectionCount(0)
{
}

FlowNode* FlowGraph::addNode(const QString &type, const QString &name, qreal x, qreal y)
{
    FlowNode *node = new FlowNode(QString(), FlowNode::stringToNodeType(type), name, this);
    node->setX(x);
    node->setY(y);

    m_nodes[node->id()] = node;

    connect(node, &FlowNode::positionChanged, this, &FlowGraph::graphChanged);

    emit nodeAdded(node);
    emit nodesChanged();
    emit nodeCountChanged();
    emit graphChanged();

    return node;
}

FlowNode* FlowGraph::addNodeWithId(const QString &id, const QString &type, const QString &name, qreal x, qreal y)
{
    if (m_nodes.contains(id)) {
        return m_nodes[id];
    }

    FlowNode *node = new FlowNode(id, FlowNode::stringToNodeType(type), name, this);
    node->setX(x);
    node->setY(y);

    m_nodes[node->id()] = node;

    connect(node, &FlowNode::positionChanged, this, &FlowGraph::graphChanged);

    emit nodeAdded(node);
    emit nodesChanged();
    emit nodeCountChanged();
    emit graphChanged();

    return node;
}

void FlowGraph::removeNode(const QString &id)
{
    if (!m_nodes.contains(id)) return;

    FlowNode *node = m_nodes[id];

    QStringList outgoing = node->outgoingConnections();
    QStringList incoming = node->incomingConnections();

    for (const QString &targetId : qAsConst(outgoing)) {
        if (m_nodes.contains(targetId)) {
            m_nodes[targetId]->removeIncomingConnection(id);
        }
        m_connectionCount--;
    }

    for (const QString &sourceId : qAsConst(incoming)) {
        if (m_nodes.contains(sourceId)) {
            m_nodes[sourceId]->removeOutgoingConnection(id);
        }
    }

    m_nodes.remove(id);
    node->deleteLater();

    emit nodeRemoved(id);
    emit nodesChanged();
    emit nodeCountChanged();
    emit connectionCountChanged();
    emit graphChanged();
}

FlowNode* FlowGraph::getNode(const QString &id) const
{
    return m_nodes.value(id, nullptr);
}

bool FlowGraph::hasNode(const QString &id) const
{
    return m_nodes.contains(id);
}

void FlowGraph::addConnection(const QString &sourceId, const QString &targetId)
{
    if (!m_nodes.contains(sourceId) || !m_nodes.contains(targetId)) return;
    if (sourceId == targetId) return;

    FlowNode *source = m_nodes[sourceId];
    FlowNode *target = m_nodes[targetId];

    if (source->outgoingConnections().contains(targetId)) return;

    source->addOutgoingConnection(targetId);
    target->addIncomingConnection(sourceId);

    m_connectionCount++;

    emit connectionAdded(sourceId, targetId);
    emit connectionCountChanged();
    emit graphChanged();
}

void FlowGraph::removeConnection(const QString &sourceId, const QString &targetId)
{
    if (!m_nodes.contains(sourceId) || !m_nodes.contains(targetId)) return;

    FlowNode *source = m_nodes[sourceId];
    FlowNode *target = m_nodes[targetId];

    if (!source->outgoingConnections().contains(targetId)) return;

    source->removeOutgoingConnection(targetId);
    target->removeIncomingConnection(sourceId);

    m_connectionCount--;

    emit connectionRemoved(sourceId, targetId);
    emit connectionCountChanged();
    emit graphChanged();
}

bool FlowGraph::hasConnection(const QString &sourceId, const QString &targetId) const
{
    if (!m_nodes.contains(sourceId)) return false;
    return m_nodes[sourceId]->outgoingConnections().contains(targetId);
}

QVariantList FlowGraph::getNodes() const
{
    QVariantList list;
    for (FlowNode *node : m_nodes) {
        QVariantMap map;
        map["id"] = node->id();
        map["type"] = node->type();
        map["name"] = node->name();
        map["description"] = node->description();
        map["x"] = node->x();
        map["y"] = node->y();
        map["properties"] = node->properties();
        list.append(map);
    }
    return list;
}

QVariantList FlowGraph::getConnections() const
{
    QVariantList list;
    for (FlowNode *node : m_nodes) {
        for (const QString &targetId : node->outgoingConnections()) {
            QVariantMap map;
            map["source"] = node->id();
            map["target"] = targetId;
            list.append(map);
        }
    }
    return list;
}

void FlowGraph::clear()
{
    qDeleteAll(m_nodes);
    m_nodes.clear();
    m_connectionCount = 0;

    emit nodesChanged();
    emit nodeCountChanged();
    emit connectionCountChanged();
    emit graphChanged();
}

int FlowGraph::nodeCount() const
{
    return m_nodes.size();
}

int FlowGraph::connectionCount() const
{
    return m_connectionCount;
}

QStringList FlowGraph::nodeIds() const
{
    return m_nodes.keys();
}

QList<FlowNode*> FlowGraph::nodesList() const
{
    return m_nodes.values();
}

QVariantList FlowGraph::getOutgoingConnections(const QString &nodeId) const
{
    FlowNode *node = getNode(nodeId);
    if (!node) return QVariantList();

    QVariantList result;
    for (const QString &targetId : node->outgoingConnections()) {
        result.append(targetId);
    }
    return result;
}

QVariantList FlowGraph::getIncomingConnections(const QString &nodeId) const
{
    FlowNode *node = getNode(nodeId);
    if (!node) return QVariantList();

    QVariantList result;
    for (const QString &sourceId : node->incomingConnections()) {
        result.append(sourceId);
    }
    return result;
}

QString FlowGraph::findStartNodeId() const
{
    for (FlowNode *node : m_nodes) {
        if (node->nodeType() == FlowNode::Start) {
            return node->id();
        }
    }
    return QString();
}

QStringList FlowGraph::findEndNodeIds() const
{
    QStringList result;
    for (FlowNode *node : m_nodes) {
        if (node->nodeType() == FlowNode::End) {
            result.append(node->id());
        }
    }
    return result;
}
