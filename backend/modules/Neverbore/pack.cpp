#include <QDebug>
#include <QFileInfo>
#include <QRegExp>
#include <QUrl>
#include "level.h"
#include "pack.h"

Pack::Pack(const QString &path, const QString &name, QObject *parent) :
    QObject(parent),
    m_name(name)
{
    QStringList chunks = readLevelData(path);
    Q_FOREACH(const QString &chunk, chunks) {
        Level *level = new Level(chunk, this);
        if (level->hash().isEmpty()) {
            qWarning() << "Invalid file data, skipping level";
            level->deleteLater();
            break;
        } else {
            m_levels << level;
        }
    }

    checkFinished();
    Q_FOREACH(Level *level, m_levels) {
        connect(level, SIGNAL(finishedChanged()), this, SLOT(checkFinished()));
    }
}

QStringList Pack::readLevelData(const QString &path)
{
    QFileInfo info(path);
    QStringList chunks;

    if (info.isDir()) {
        QStringList files = QDir(path).entryList(QDir::Files | QDir::Readable);
        Q_FOREACH(const QString &file, files) {
            chunks << readLevelData(path + "/" + file);
        }
    } else {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly)) {
            qWarning() << "Error opening file" << path << file.errorString();
        } else {
            QByteArray bytes = file.readAll();
            if (bytes.isEmpty() && !file.errorString().isEmpty()) {
                qWarning() << "Error reading file" << path << file.errorString();
            } else {
                QString suffix = info.suffix();
                if (suffix.compare("non", Qt::CaseInsensitive) == 0) {
                    chunks << QString(bytes);
                } else if (suffix.compare("nonpack", Qt::CaseInsensitive) == 0) {
                    chunks = QString(bytes).split("\n====\n", QString::SkipEmptyParts);
                } else {
                    qWarning() << "Did not recognize filename" << path;
                }
            }
        }
    }

    return chunks;
}

Level *Pack::getLevel(int i)
{
    return m_levels.value(i);
}

int Pack::getLevelIndex(Level *level)
{
    return m_levels.indexOf(level);
}

Level *Pack::getLevelByHash(const QString &hash)
{
    Q_FOREACH(Level *level, m_levels) {
        if (level->hash() == hash) {
            return level;
        }
    }
    return nullptr;
}

void Pack::checkFinished()
{
    bool result = true;
    Q_FOREACH(Level *level, m_levels) {
        if (!level->finished()) {
            result = false;
            break;
        }
    }

    if (m_finished != result ) {
        m_finished = result;
        Q_EMIT finishedChanged();
    }
}
