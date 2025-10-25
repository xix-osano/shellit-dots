#pragma once

#include <qobject.h>
#include <qqmlintegration.h>

namespace shellit {

class Qalculator : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Qalculator(QObject* parent = nullptr);

    Q_INVOKABLE QString eval(const QString& expr, bool printExpr = true) const;
};

} // namespace shellit
