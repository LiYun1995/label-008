QT += quick qml widgets

CONFIG += c++11

TARGET = GameFlowEditor
TEMPLATE = app

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    src/main.cpp \
    src/flownode.cpp \
    src/flowgraph.cpp \
    src/flowexporter.cpp

HEADERS += \
    src/flownode.h \
    src/flowgraph.h \
    src/flowexporter.h

RESOURCES += qml.qrc

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
