#ifndef PACK_H
#define PACK_H

#include <QDir>
#include <QObject>
#include <QVector>

class Pack : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool finished READ finished NOTIFY finishedChanged)
    Q_PROPERTY(int count READ count NOTIFY packChanged)
    Q_PROPERTY(QString name READ name NOTIFY packChanged)

public:
    explicit Pack(const QString &path, const QString &name, QObject *parent = 0);

    bool finished() const {return m_finished;}
    int count() const {return m_levels.length();}
    QString name() const {return m_name;}

    Q_INVOKABLE Level *getLevel(int i);
    Q_INVOKABLE int getLevelIndex(Level *level);
    Q_INVOKABLE Level *getLevelByHash(const QString &hash);

Q_SIGNALS:
    void packChanged();
    void finishedChanged();

private Q_SLOTS:
    void checkFinished();

private:
    QStringList readLevelData(const QString &path);

    bool m_finished;
    QString m_name;
    QVector<Level*> m_levels;
};


#endif // PACK_H
