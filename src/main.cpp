#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>

#include "flownode.h"
#include "flowgraph.h"
#include "flowexporter.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    app.setApplicationName("GameFlowEditor");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("GameDev");

    qmlRegisterType<FlowNode>("GameFlow", 1, 0, "FlowNode");
    qmlRegisterType<FlowGraph>("GameFlow", 1, 0, "FlowGraph");
    qmlRegisterType<FlowExporter>("GameFlow", 1, 0, "FlowExporter");

    FlowGraph *graph = new FlowGraph();
    FlowExporter *exporter = new FlowExporter();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("flowGraph", graph);
    engine.rootContext()->setContextProperty("flowExporter", exporter);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
