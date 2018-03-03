#include <QDebug>
#include <QFileInfo>
#include <QRegExp>
#include <QUrl>
#include "level.h"
#include "levels.h"
#include "pack.h"

Levels::Levels(QObject *parent) :
    QObject(parent),
    m_currentLevel(nullptr)
{
}

void Levels::setFolder(const QString &folder)
{
    QUrl url(folder);
    m_folder = url.toLocalFile();
    m_packs.clear();

    QString currentLevelHash = Level::settings()->value("currentLevel").toString();

    QStringList files = m_folder.entryList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot | QDir::Readable);
    Q_FOREACH(const QString &file, files) {
        QString name = file;
        QFileInfo info(m_folder.absoluteFilePath(name));

        bool hasNumStarter;
        int numStarter = info.baseName().toInt(&hasNumStarter);

        if (info.suffix() == "non" || info.suffix() == "nonpack") {
            name = info.completeBaseName();
        }
        if (hasNumStarter) {
            name = name.mid(name.indexOf('.') + 1);
        }

        Pack *pack = new Pack(info.absoluteFilePath(), name, this);
        if (pack->count() > 0) {
            m_packs.insertMulti(numStarter, pack);
        } else {
            pack->deleteLater();
        }
    }

    Q_FOREACH(Pack *pack, m_packs) {
        Level *level = pack->getLevelByHash(currentLevelHash);
        if (level != nullptr) {
            m_currentLevel = level;
            Q_EMIT currentLevelChanged();
        }
    }

    Q_EMIT folderChanged();
}

Pack *Levels::getPack(int i)
{
    return m_packs.values().value(i);
}

int Levels::getPackIndex(Pack *pack)
{
    return m_packs.values().indexOf(pack);
}

void Levels::setCurrentLevel(Level *level)
{
    QString hash = level ? level->hash() : "";
    Level::settings()->setValue("currentLevel", hash);
    m_currentLevel = level;
    Q_EMIT currentLevelChanged();
}
