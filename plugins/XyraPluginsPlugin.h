#ifndef XYRAPLUGINSPLUGIN_H
#define XYRAPLUGINSPLUGIN_H

#include <QQmlExtensionPlugin>

class XyraPluginsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlEngineExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // XYRAPLUGINSPLUGIN_H
