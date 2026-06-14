#ifndef FLOWEXPORTER_H
#define FLOWEXPORTER_H

#include <QObject>
#include <QString>
#include "flowgraph.h"

class FlowExporter : public QObject
{
    Q_OBJECT

public:
    explicit FlowExporter(QObject *parent = nullptr);

    Q_INVOKABLE QString exportToText(FlowGraph *graph) const;
    Q_INVOKABLE bool exportToFile(FlowGraph *graph, const QString &filePath) const;

    Q_INVOKABLE QString generateFlowDescription(FlowGraph *graph) const;

private:
    QStringList topologicalSort(FlowGraph *graph) const;
    QString describeNode(FlowNode *node) const;
    QString getNodeTypeLabel(FlowNode::NodeType type) const;
};

#endif
