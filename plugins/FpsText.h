#ifndef FPSTEXT_H
#define FPSTEXT_H

#include <QQuickPaintedItem>
#include <QPainter>
#include <QDateTime>
#include <QDebug>
#include <QVector>

class FPSText : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(int fps READ fps NOTIFY fpsChanged)
public:
    FPSText(QQuickItem *parent = nullptr);
    ~FPSText();
    void paint(QPainter *painter) override;
    Q_INVOKABLE int fps() const;

signals:
    void fpsChanged(int fps);

private:
    void recalculateFPS();
    int _currentFPS;
    int _cacheCount;
    QVector<qint64> _times;
};

#endif // FPSTEXT_H
