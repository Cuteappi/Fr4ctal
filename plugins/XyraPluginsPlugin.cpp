#include "XyraPluginsPlugin.h"
#include "FpsText.h"

void XyraPluginsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Xyra.Plugins"));
    
    // Register the FPSText component
    qmlRegisterType<FPSText>(uri, 1, 0, "FPSText");
}
