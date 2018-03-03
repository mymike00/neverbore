#include <QCryptographicHash>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QSet>
#include <QUrl>
#include "level.h"
#include "pack.h"

static QString presetColors[] = {"#444", "#f44", "#4a4", "#44f"};

QSettings *Level::m_settings = nullptr;

Level::Level(const QString &data, Pack *parent) :
    QObject(parent),
    m_pack(parent)
{
    parseData(data);
}

QSettings *Level::settings()
{
    if (m_settings == nullptr) {
        m_settings = new QSettings("neverbore.mterry", "neverbore.mterry");
    }
    return m_settings;
}

QList<int> Level::getRowHints(int row) const
{
    return m_rowHints.at(row);
}

QList<int> Level::getColumnHints(int column) const
{
    return m_columnHints.at(column);
}

QList<QString> Level::getRowHintColors(int row) const
{
    return m_rowHintColors.at(row);
}

QList<QString> Level::getColumnHintColors(int column) const
{
    return m_columnHintColors.at(column);
}

void Level::parseData(const QString &data)
{
    reset();
    if (!loadFile(data)) {
        m_hash = QString::null;
        return;
    }

    // Get list of all colors used
    QSet<QString> colors;
    for (int i = 0; i < m_rowHintColors.length(); i++) {
        for (int j = 0; j < m_rowHintColors[i].length(); j++) {
            colors.insert(m_rowHintColors[i][j]);
        }
    }
    for (int i = 0; i < m_columnHintColors.length(); i++) {
        for (int j = 0; j < m_columnHintColors[i].length(); j++) {
            colors.insert(m_columnHintColors[i][j]);
        }
    }
    Q_FOREACH(const QString &color, colors) {
        m_modes.prepend(color);
    }

    loadGuesses();
}

void Level::reset()
{
    m_columnHints.clear();
    m_columnHintColors.clear();
    m_columnHintsDepth = 0;
    m_rowHints.clear();
    m_rowHintColors.clear();
    m_rowHintsDepth = 0;
    m_modes = QStringList() << "blank";
    m_name = "";
    m_author = "";
    m_finished = false;
    m_hash = QString::null;
    m_filledBlocks = 0;
    m_rowStates.clear();
    m_columnStates.clear();
    m_guesses.clear();
    m_ghostGuesses.clear();
    m_ghostMode = false;
}

void Level::clearGuesses()
{
    m_filledBlocks = 0;
    m_finished = false;
    m_rowStates.fill(true, rows());
    m_columnStates.fill(true, columns());
    m_guesses.fill(0, m_guesses.size());
    m_ghostGuesses.fill(0, m_guesses.size());
    m_ghostMode = false;
    settings()->setValue("level" + m_hash + "/finished", QVariant(false));
    settings()->setValue("level" + m_hash + "/guesses", QVariant(""));
    settings()->setValue("level" + m_hash + "/ghostGuesses", QVariant(""));
    settings()->setValue("level" + m_hash + "/ghostMode", QVariant(false));
    Q_EMIT finishedChanged();
    Q_EMIT guessesChanged();
}

bool Level::readField(const QStringList &lines, int &i, QMap<QString, QString> &fields)
{
    QString line = lines[i].trimmed();
    if (line == "rows" || line == "columns") {
        QString key = line;
        QString dimensionKey = key == "rows" ? "height" : "width";
        uint dimension = fields.value(dimensionKey).toUInt();
        if (dimension == 0) {
            return false;
        }
        int endLine = i + dimension + 1;
        if (lines.length() < endLine) {
            return false;
        }
        QStringList values;
        for (i++; i < endLine; i++) {
            values << lines[i];
        }
        fields[key] = values.join(";");
        return true;
    }

    i++;
    int firstSpace = line.indexOf(' ');
    if (firstSpace < 0) {
        fields[line] = QString::null;
        return true;
    }

    QString key = line.left(firstSpace);
    QString value = line.mid(firstSpace + 1);
    if (value.startsWith('"')) {
        if (!value.endsWith('"')) {
            // FIXME: handle multi-line strings
            return false;
        }
        value = value.mid(1, value.size() - 2);
    }

    fields[key] = value;
    return true;
}

bool Level::loadFile(const QString &content)
{
    QStringList lines = content.split('\n');
    int i = 0;
    QMap<QString, QString> fields;

    while (i < lines.length()) {
        if (!readField(lines, i, fields)) {
            return false;
        }
    }

    m_name = fields.value("title", "");
    m_author = fields.value("by", "");

    // We don't care about security here, MD5 is fine
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(fields.value("rows").toUtf8());
    hash.addData(fields.value("columns").toUtf8());
    m_hash = hash.result().toHex();

    uint cols = fields.value("width").toUInt();
    QStringList colHints = fields.value("columns").split(';');
    for (uint j = 0; j < cols; j++) {
        QList<int> hints;
        QList<QString> hintColors;
        QStringList hintSet = colHints.value(j).split(',', QString::SkipEmptyParts);
        for (int k = 0; k < hintSet.length(); k++) {
            hints << hintSet[k].toUInt();
            hintColors << presetColors[0];
        }
        m_columnHints << hints;
        m_columnHintColors << hintColors;
        m_columnHintsDepth = std::max(hints.length(), m_columnHintsDepth);
    }

    uint rows = fields.value("height").toUInt();
    QStringList rowHints = fields.value("rows").split(';');
    for (uint j = 0; j < rows; j++) {
        QList<int> hints;
        QList<QString> hintColors;
        QStringList hintSet = rowHints.value(j).split(',', QString::SkipEmptyParts);
        for (int k = 0; k < hintSet.length(); k++) {
            hints << hintSet[k].toUInt();
            hintColors << presetColors[0];
        }
        m_rowHints << hints;
        m_rowHintColors << hintColors;
        m_rowHintsDepth = std::max(hints.length(), m_rowHintsDepth);
    }

    return true;
}

void Level::loadGuesses()
{
    QString base64Guesses = settings()->value("level" + m_hash + "/guesses").toString();
    m_guesses = QByteArray::fromBase64(base64Guesses.toUtf8());
    int properSize = (rows() * columns() + 1) / 2;
    if (m_guesses.size() < properSize) {
        m_guesses.append(QByteArray(properSize - m_guesses.size(), 0));
    } else if (m_guesses.size() > properSize) {
        m_guesses.truncate(properSize);
    }

    m_ghostMode = settings()->value("level" + m_hash + "/ghostMode").toBool();
    QString base64GhostGuesses = settings()->value("level" + m_hash + "/ghostGuesses").toString();
    m_ghostGuesses = QByteArray::fromBase64(base64GhostGuesses.toUtf8());
    properSize = m_guesses.size();
    if (m_ghostGuesses.size() < properSize) {
        m_ghostGuesses.append(QByteArray(properSize - m_ghostGuesses.size(), 0));
    } else if (m_ghostGuesses.size() > properSize) {
        m_ghostGuesses.truncate(properSize);
    }

    m_rowStates.fill(true, rows());
    m_columnStates.fill(true, columns());
    m_filledBlocks = 0;
    m_finished = false;
    for (int i = 0; i < m_guesses.length(); i++) {
        char byte = m_guesses[i];
        m_filledBlocks += (byte & 0x0f) ? 1 : 0;
        m_filledBlocks += (byte & 0xf0) ? 1 : 0;
    }

    checkGuessesHelper(true);

    Q_EMIT finishedChanged();
    Q_EMIT guessesChanged();
}

char Level::byteValue(int n) const
{
    if (m_ghostMode) {
        return byteValue(m_ghostGuesses, n);
    } else {
        return byteValue(m_guesses, n);
    }
}

char Level::byteValue(const QByteArray &bytes, int n) const
{
    if (n < 0 || n >= bytes.size() * 2) {
        return 0;
    }
    char byte = bytes.at(n/2);
    if (n % 2 == 0) {
        byte = byte >> 4;
    }
    return byte & 0x0f;
}

void Level::setByteValue(int n, char v)
{
    if (n < 0 || n >= m_guesses.size() * 2) {
        return; // both arrays are the same size, doesn't matter which we check
    }
    if (m_ghostMode) {
        setByteValue(m_ghostGuesses, n, v);
        settings()->setValue("level" + m_hash + "/ghostGuesses", QVariant(QString(m_ghostGuesses.toBase64())));
    } else {
        char oldVal = byteValue(m_guesses, n);
        setByteValue(m_guesses, n, v);
        if (oldVal == 0) {
            m_filledBlocks += 1;
        }
        if (v == 0) {
            m_filledBlocks -= 1;
        }
        settings()->setValue("level" + m_hash + "/guesses", QVariant(QString(m_guesses.toBase64())));
    }
}

void Level::setByteValue(QByteArray &bytes, int n, char v)
{
    char byte = bytes.at(n/2);
    if (n % 2 == 0) {
        byte = (v << 4) | (byte & 0x0f);
    } else {
        byte = (byte & 0xf0) | (v & 0x0f);
    }
    bytes[n/2] = byte;
}

QString Level::guessName(char v) const
{
    switch (v) {
    case 0: return "";
    case 1: return "blank";
    default:
        if (m_modes.length() < v) {
            return "";
        } else {
            return m_modes[v - 2];
        }
    }
}

QString Level::guess(int n) const
{
    char v = byteValue(n);
    char realV = byteValue(m_guesses, n);
    if (v == 0 && realV != 0) {
        v = realV;
    }
    return guessName(v);
}

QString Level::realGuess(int n) const
{
    return guessName(byteValue(m_guesses, n));
}

bool Level::checkDimension(bool doColumns)
{
    bool success = true;
    for (int i = 0; i < (doColumns ? columns() : rows()); i++) {
        QList<int> hints = doColumns ? getColumnHints(i) : getRowHints(i);
        QVector<bool> &states = doColumns ? m_columnStates : m_rowStates;
        int currentHint = 0;
        int currentRun = 0;
        states[i] = true;
        int endJ = (doColumns ? rows() : columns());
        for (int j = 0; j <= endJ; j++) {
            int index = doColumns ? j * columns() + i : i * columns() + j;
            QString currentGuess = j == endJ ? "blank" : guess(index);
            if (currentGuess == "blank") {
                if (currentRun > 0) {
                    if (hints.value(currentHint) == currentRun) {
                        currentHint++;
                        currentRun = 0;
                    } else {
                        states[i] = false;
                        success = false;
                        break;
                    }
                }
            } else if (currentGuess == "") {
                // Puzzle wasn't finished, shouldn't happen
                states[i] = false;
                success = false;
                break;
            } else {
                currentRun++;
            }
        }
        if (currentHint != hints.length()) {
            states[i] = false;
            success = false;
        }
    }

    return success;
}

bool Level::checkGuessesHelper(bool isLoading)
{
    if (!allGuessed())
        return false;

    bool success = checkDimension(true);
    if (!checkDimension(false)) {
        success = false;
    }

    if (isLoading) {
        // Erase any states we filled in
        m_columnStates.fill(true, columns());
        m_rowStates.fill(true, rows());
    }

    m_finished = success;
    Q_EMIT finishedChanged();
    Q_EMIT statesChanged();
    return true;
}

void Level::checkGuesses()
{
    if (!checkGuessesHelper(false))
        return;

    settings()->setValue("level" + m_hash + "/finished", QVariant(m_finished));
}

void Level::setGuess(int n, const QString &guess)
{
    char val;
    if (guess == "") {
        val = 0;
    } else if (guess == "blank") {
        val = 1;
    } else {
        for (int i = 0; i < m_modes.length() - 1; i++) {
            if (m_modes[i] == guess) {
                val = i + 2;
                break;
            }
        }
    }

    setByteValue(n, val);
    Q_EMIT guessesChanged();
}

bool Level::hasGhostGuesses() const
{
    for (int i = 0; i < m_ghostGuesses.size(); i++) {
        if (m_ghostGuesses[i] != 0) {
            return true;
        }
    }
    return false;
}

void Level::enterGhostMode()
{
    if (m_ghostMode) {
        return;
    }
    m_ghostMode = true;
    m_ghostGuesses.fill(0);
    settings()->setValue("level" + m_hash + "/ghostGuesses", QVariant(QString(m_ghostGuesses.toBase64())));
    settings()->setValue("level" + m_hash + "/ghostMode", QVariant(m_ghostMode));
    Q_EMIT ghostModeChanged();
}

void Level::exitGhostMode(bool keep)
{
    if (!m_ghostMode) {
        return;
    }
    m_ghostMode = false;
    if (keep) {
        for (int n = 0; n < rows() * columns(); n++) {
            char ghostGuess = byteValue(m_ghostGuesses, n);
            if (ghostGuess > 0) {
                setByteValue(n, ghostGuess);
            }
        }
    }
    m_ghostGuesses.fill(0);
    settings()->setValue("level" + m_hash + "/ghostGuesses", QVariant(QString(m_ghostGuesses.toBase64())));
    settings()->setValue("level" + m_hash + "/ghostMode", QVariant(m_ghostMode));
    Q_EMIT ghostModeChanged();
    Q_EMIT guessesChanged();
}
