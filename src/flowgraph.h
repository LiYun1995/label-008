#ifndef FLOWGRAPH_H
#define FLOWGRAPH_H

#include <QObject>
#include <QList>
#include <QMap>
#include <QVariantList>
#include "flownode.h"

class FlowGraph : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int nodeCount READ nodeCount NOTIFY nodeCountChanged)
    Q_PROPERTY(int connectionCount READ connectionCount NOTIFY connectionCountChanged)
    Q_PROPERTY(QStringList nodeIds READ nodeIds NOTIFY nodesChanged)

public:
    explicit FlowGraph(QObject *parent = nullptr);

    Q_INVOKABLE FlowNode* addNode(const QString &type, const QString &name, qreal x, qreal y);
    Q_INVOKABLE FlowNode* addNodeWithId(const QString &id, const QString &type, const QString &name, qreal x, qreal y);
    Q_INVOKABLE void removeNode(const QString &id);
    Q_INVOKABLE FlowNode* getNode(const QString &id) const;
    Q_INVOKABLE bool hasNode(const QString &id) const;

    Q_INVOKABLE void addConnection(const QString &sourceId, const QString &targetId);
    Q_INVOKABLE void removeConnection(const QString &sourceId, const QString &targetId);
    Q_INVOKABLE bool hasConnection(const QString &sourceId, const QString &targetId) const;

    Q_INVOKABLE QVariantList getNodes() const;
    Q_INVOKABLE QVariantList getConnections() const;

    Q_INVOKABLE void clear();

    int nodeCount() const;
    int connectionCount() const;
    QStringList nodeIds() const;

    QList<FlowNode*> nodesList() const;

    Q_INVOKABLE QVariantList getOutgoingConnections(const QString &nodeId) const;
    Q_INVOKABLE QVariantList getIncomingConnections(const QString &nodeId) const;

    Q_INVOKABLE QString findStartNodeId() const;
    Q_INVOKABLE QStringList findEndNodeIds() const;

signals:
    void nodeAdded(FlowNode *node);
    void nodeRemoved(const QString &id);
    void nodesChanged();
    void nodeCountChanged();
    void connectionAdded(const QString &sourceId, const QString &targetId);
    void connectionRemoved(const QString &sourceId, const QString &targetId);
    void connectionCountChanged();
    void graphChanged();

private:
    QMap<QString, FlowNode*> m_nodes;
    int m_connectionCount;
};

#endif
