#ifndef LEVELS_H
#define LEVELS_H

#include <QDir>
#include <QMultiMap>
#include <QObject>
#include <QVector>

class Levels : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString folder READ folder WRITE setFolder NOTIFY folderChanged)
    Q_PROPERTY(int count READ count NOTIFY folderChanged)
    Q_PROPERTY(Level *currentLevel READ currentLevel WRITE setCurrentLevel NOTIFY currentLevelChanged)

public:
    explicit Levels(QObject *parent = 0);

    void setFolder(const QString &folder);
    void setCurrentLevel(Level *level);

    QString folder() const {return m_folder.path();}
    int count() const {return m_packs.count();}
    Level *currentLevel() const {return m_currentLevel;}

    Q_INVOKABLE Pack *getPack(int i);
    Q_INVOKABLE int getPackIndex(Pack *pack);
    Q_INVOKABLE Level *getLevelByHash(const QString &hash);

Q_SIGNALS:
    void folderChanged();
    void currentLevelChanged();

private:
    QDir m_folder;
    QMultiMap<int, Pack*> m_packs;
    Level *m_currentLevel;
};


#endif // LEVELS_H
