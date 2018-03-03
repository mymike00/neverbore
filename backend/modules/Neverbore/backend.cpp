#include <QtQml>
#include <QtQml/QQmlContext>
#include "backend.h"
#include "level.h"
#include "levels.h"
#include "pack.h"

QObject *levels_provider(QQmlEngine *, QJSEngine *)
{
    return new Levels();
}

void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Neverbore"));

    qRegisterMetaType<QList<int> >();
    qRegisterMetaType<Level *>();
    qRegisterMetaType<Pack *>();
    qmlRegisterSingletonType<Levels>(uri, 1, 0, "Levels", levels_provider);
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
