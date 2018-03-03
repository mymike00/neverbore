#ifndef LEVEL_H
#define LEVEL_H

#include <QByteArray>
#include <QMap>
#include <QObject>
#include <QSettings>
#include <QStringList>
#include <QVector>

class Pack;

class Level : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Pack *pack READ pack NOTIFY filenameChanged)
    Q_PROPERTY(QString name READ name NOTIFY filenameChanged)
    Q_PROPERTY(QString author READ author NOTIFY filenameChanged)

    Q_PROPERTY(int rows READ rows NOTIFY filenameChanged)
    Q_PROPERTY(int rowHintsDepth READ rowHintsDepth NOTIFY filenameChanged)

    Q_PROPERTY(int columns READ columns NOTIFY filenameChanged)
    Q_PROPERTY(int columnHintsDepth READ columnHintsDepth NOTIFY filenameChanged)

    Q_PROPERTY(QStringList modes READ modes NOTIFY filenameChanged)
    Q_PROPERTY(QString hash READ hash NOTIFY filenameChanged)

    Q_PROPERTY(QList<bool> columnStates READ columnStates NOTIFY statesChanged)
    Q_PROPERTY(QList<bool> rowStates READ rowStates NOTIFY statesChanged)
    Q_PROPERTY(bool ghostMode READ ghostMode NOTIFY ghostModeChanged)
    Q_PROPERTY(bool hasGhostGuesses READ hasGhostGuesses NOTIFY guessesChanged)
    Q_PROPERTY(bool anyGuessed READ anyGuessed NOTIFY guessesChanged)
    Q_PROPERTY(bool allGuessed READ allGuessed NOTIFY guessesChanged)
    Q_PROPERTY(bool finished READ finished NOTIFY finishedChanged)

public:
    explicit Level(const QString &data = QString::null, Pack *parent = 0);

    // FIXME: figure out how to stuff these all sensibly into a giant Q_PROPERTY list of lists
    Q_INVOKABLE QList<int> getRowHints(int row) const;
    Q_INVOKABLE QList<QString> getRowHintColors(int row) const;
    Q_INVOKABLE QList<int> getColumnHints(int column) const;
    Q_INVOKABLE QList<QString> getColumnHintColors(int column) const;

    static QSettings *settings();

    Pack *pack() const { return m_pack; }
    QString name() const { return m_name; }
    QString author() const { return m_author; }
    int rows() const { return m_rowHints.length(); }
    int rowHintsDepth() const { return m_rowHintsDepth; }
    int columns() const { return m_columnHints.length(); }
    int columnHintsDepth() const { return m_columnHintsDepth; }
    QStringList modes() const { return m_modes; }
    QString hash() const { return m_hash; }
    QList<bool> rowStates() const { return m_rowStates.toList(); }
    QList<bool> columnStates() const { return m_columnStates.toList(); }

    void loadGuesses();
    bool anyGuessed() const { return m_filledBlocks > 0; }
    bool allGuessed() const { return m_filledBlocks >= columns() * rows(); }
    bool finished() const { return m_finished; }
    bool ghostMode() const { return m_ghostMode; }
    bool hasGhostGuesses() const;
    Q_INVOKABLE void enterGhostMode();
    Q_INVOKABLE void exitGhostMode(bool keep);
    Q_INVOKABLE QString guess(int n) const;
    Q_INVOKABLE QString realGuess(int n) const;
    Q_INVOKABLE void setGuess(int n, const QString &guess);
    Q_INVOKABLE void clearGuesses();
    Q_INVOKABLE void checkGuesses();

Q_SIGNALS:
    void filenameChanged();
    void guessesChanged();
    void statesChanged();
    void finishedChanged();
    void ghostModeChanged();

protected:
    void parseData(const QString &data);
    void reset();
    bool checkDimension(bool doColumns);
    bool checkGuessesHelper(bool isLoading);
    bool loadFile(const QString &content);
    bool readField(const QStringList &lines, int &i, QMap<QString, QString> &fields);
    char byteValue(int n) const;
    char byteValue(const QByteArray &bytes, int n) const;
    void setByteValue(int n, char v);
    void setByteValue(QByteArray &bytes, int n, char v);
    QString guessName(char v) const;

    QString m_name;
    QString m_author;
    QList< QList<int> > m_rowHints;
    QVector<bool> m_rowStates;
    QList< QList<QString> > m_rowHintColors;
    int m_rowHintsDepth;
    QList< QList<int> > m_columnHints;
    QVector<bool> m_columnStates;
    QList< QList<QString> > m_columnHintColors;
    int m_columnHintsDepth;
    QStringList m_modes;
    QString m_hash;
    QByteArray m_guesses;
    QByteArray m_ghostGuesses;
    bool m_finished;
    int m_filledBlocks;
    bool m_ghostMode;
    Pack *m_pack;
    static QSettings *m_settings;
};

#endif // LEVEL_H
