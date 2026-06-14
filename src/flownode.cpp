#include "flownode.h"
#include <QUuid>

FlowNode::FlowNode(QObject *parent)
    : QObject(parent)
    , m_id(QUuid::createUuid().toString(QUuid::WithoutBraces))
    , m_type(Task)
    , m_name("New Node")
    , m_description("")
    , m_x(0)
    , m_y(0)
{
}

FlowNode::FlowNode(const QString &id, NodeType type, const QString &name, QObject *parent)
    : QObject(parent)
    , m_id(id.isEmpty() ? QUuid::createUuid().toString(QUuid::WithoutBraces) : id)
    , m_type(type)
    , m_name(name)
    , m_description("")
    , m_x(0)
    , m_y(0)
{
}

QString FlowNode::id() const
{
    return m_id;
}

QString FlowNode::type() const
{
    return nodeTypeToString(m_type);
}

void FlowNode::setType(const QString &type)
{
    NodeType t = stringToNodeType(type);
    if (t != m_type) {
        m_type = t;
        emit typeChanged();
    }
}

FlowNode::NodeType FlowNode::nodeType() const
{
    return m_type;
}

void FlowNode::setNodeType(NodeType type)
{
    if (type != m_type) {
        m_type = type;
        emit typeChanged();
    }
}

QString FlowNode::name() const
{
    return m_name;
}

void FlowNode::setName(const QString &name)
{
    if (name != m_name) {
        m_name = name;
        emit nameChanged();
    }
}

QString FlowNode::description() const
{
    return m_description;
}

void FlowNode::setDescription(const QString &description)
{
    if (description != m_description) {
        m_description = description;
        emit descriptionChanged();
    }
}

qreal FlowNode::x() const
{
    return m_x;
}

void FlowNode::setX(qreal x)
{
    if (x != m_x) {
        m_x = x;
        emit xChanged();
        emit positionChanged();
    }
}

qreal FlowNode::y() const
{
    return m_y;
}

void FlowNode::setY(qreal y)
{
    if (y != m_y) {
        m_y = y;
        emit yChanged();
        emit positionChanged();
    }
}

QPointF FlowNode::position() const
{
    return QPointF(m_x, m_y);
}

void FlowNode::setPosition(const QPointF &pos)
{
    if (pos.x() != m_x || pos.y() != m_y) {
        m_x = pos.x();
        m_y = pos.y();
        emit xChanged();
        emit yChanged();
        emit positionChanged();
    }
}

QVariantMap FlowNode::properties() const
{
    return m_properties;
}

void FlowNode::setProperties(const QVariantMap &props)
{
    m_properties = props;
    emit propertiesChanged();
}

QVariant FlowNode::property(const QString &key) const
{
    return m_properties.value(key);
}

void FlowNode::setProperty(const QString &key, const QVariant &value)
{
    if (!m_properties.contains(key) || m_properties.value(key) != value) {
        m_properties[key] = value;
        emit propertiesChanged();
    }
}

QStringList FlowNode::outgoingConnections() const
{
    return m_outgoingConnections;
}

QStringList FlowNode::incomingConnections() const
{
    return m_incomingConnections;
}

void FlowNode::addOutgoingConnection(const QString &targetId)
{
    if (!m_outgoingConnections.contains(targetId)) {
        m_outgoingConnections.append(targetId);
        emit outgoingConnectionsChanged();
    }
}

void FlowNode::removeOutgoingConnection(const QString &targetId)
{
    if (m_outgoingConnections.removeOne(targetId)) {
        emit outgoingConnectionsChanged();
    }
}

void FlowNode::addIncomingConnection(const QString &sourceId)
{
    if (!m_incomingConnections.contains(sourceId)) {
        m_incomingConnections.append(sourceId);
        emit incomingConnectionsChanged();
    }
}

void FlowNode::removeIncomingConnection(const QString &sourceId)
{
    if (m_incomingConnections.removeOne(sourceId)) {
        emit incomingConnectionsChanged();
    }
}

QString FlowNode::nodeTypeToString(NodeType type)
{
    switch (type) {
    case Start: return "Start";
    case End: return "End";
    case Task: return "Task";
    case Monster: return "Monster";
    case NPC: return "NPC";
    case Location: return "Location";
    default: return "Unknown";
    }
}

FlowNode::NodeType FlowNode::stringToNodeType(const QString &typeStr)
{
    QString lower = typeStr.toLower();
    if (lower == "start") return Start;
    if (lower == "end") return End;
    if (lower == "task") return Task;
    if (lower == "monster") return Monster;
    if (lower == "npc") return NPC;
    if (lower == "location") return Location;
    return Task;
}

QString FlowNode::nodeTypeColor(NodeType type)
{
    switch (type) {
    case Start: return "#4CAF50";
    case End: return "#F44336";
    case Task: return "#2196F3";
    case Monster: return "#FF9800";
    case NPC: return "#9C27B0";
    case Location: return "#00BCD4";
    default: return "#9E9E9E";
    }
}

QString FlowNode::nodeTypeIcon(NodeType type)
{
    switch (type) {
    case Start: return "▶";
    case End: return "■";
    case Task: return "📋";
    case Monster: return "👾";
    case NPC: return "👤";
    case Location: return "📍";
    default: return "?";
    }
}
