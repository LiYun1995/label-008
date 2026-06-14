#ifndef FLOWNODE_H
#define FLOWNODE_H

#include <QObject>
#include <QPointF>
#include <QVariantMap>
#include <QStringList>

class FlowNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(qreal x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(qreal y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(QVariantMap properties READ properties WRITE setProperties NOTIFY propertiesChanged)
    Q_PROPERTY(QStringList outgoingConnections READ outgoingConnections NOTIFY outgoingConnectionsChanged)
    Q_PROPERTY(QStringList incomingConnections READ incomingConnections NOTIFY incomingConnectionsChanged)

public:
    enum NodeType {
        Start,
        End,
        Task,
        Monster,
        NPC,
        Location
    };
    Q_ENUM(NodeType)

    explicit FlowNode(QObject *parent = nullptr);
    FlowNode(const QString &id, NodeType type, const QString &name, QObject *parent = nullptr);

    QString id() const;

    QString type() const;
    void setType(const QString &type);

    NodeType nodeType() const;
    void setNodeType(NodeType type);

    QString name() const;
    void setName(const QString &name);

    QString description() const;
    void setDescription(const QString &description);

    qreal x() const;
    void setX(qreal x);

    qreal y() const;
    void setY(qreal y);

    QPointF position() const;
    void setPosition(const QPointF &pos);

    QVariantMap properties() const;
    void setProperties(const QVariantMap &props);

    Q_INVOKABLE QVariant property(const QString &key) const;
    Q_INVOKABLE void setProperty(const QString &key, const QVariant &value);

    QStringList outgoingConnections() const;
    QStringList incomingConnections() const;

    void addOutgoingConnection(const QString &targetId);
    void removeOutgoingConnection(const QString &targetId);
    void addIncomingConnection(const QString &sourceId);
    void removeIncomingConnection(const QString &sourceId);

    static QString nodeTypeToString(NodeType type);
    static NodeType stringToNodeType(const QString &typeStr);

    static QString nodeTypeColor(NodeType type);
    static QString nodeTypeIcon(NodeType type);

signals:
    void typeChanged();
    void nameChanged();
    void descriptionChanged();
    void xChanged();
    void yChanged();
    void positionChanged();
    void propertiesChanged();
    void outgoingConnectionsChanged();
    void incomingConnectionsChanged();

private:
    QString m_id;
    NodeType m_type;
    QString m_name;
    QString m_description;
    qreal m_x;
    qreal m_y;
    QVariantMap m_properties;
    QStringList m_outgoingConnections;
    QStringList m_incomingConnections;
};

#endif
