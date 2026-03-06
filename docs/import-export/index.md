# Import & Export

## Import

Fragenkataloge lassen sich als JSON oder YAML importieren – per Dateiauswahl oder direkt aus der Zwischenablage. Die App erkennt das Format automatisch und extrahiert den Inhalt bei Bedarf aus einem Markdown-Code-Block (` ```json ` oder ` ```yaml `), sodass sich LLM-generierte Antworten direkt einfügen lassen.

**Ablauf:**

1. Im Menü **Import** wählen.
2. Datei auswählen oder Text aus Zwischenablage einfügen.
3. Vorschau prüfen: Anzahl der Fragen, Kategorie, enthaltene Schätzungen.
4. Optional: **Duplikate überspringen** – Fragen, die bereits mit gleichem Titel in der Datenbank existieren, werden standardmäßig übersprungen. Der Schalter lässt sich für einen Import deaktivieren.
5. **Importieren** bestätigen.

Enthält eine Frage bereits Schätzfelder, speichert die App sie sofort. Enthält sie eine Auflösung, wird die Vorhersage direkt als aufgelöst markiert.

Fehler bei ungültigem Schema führen zu einem Fehlerdialog mit Zeilennummer. Es wird kein partieller Import durchgeführt.

---

## Export

### Datensicherung

**Einstellungen → Daten exportieren** erzeugt ein vollständiges JSON-Backup aller Vorhersagen, Schätzungen und Auflösungen. Das Backup wird per Android-Share-Sheet geteilt und lässt sich auf einem anderen Gerät vollständig wiederherstellen.

### Aufgaben teilen

Der Teilen-Button in der AppBar der Vorhersagenliste exportiert die aktuell sichtbaren Vorhersagen ohne eigene Schätzungen. So können andere dieselben Fragen selbst kalibrieren.

Ablauf:

1. In der **Vorhersagenliste** den gewünschten Tab wählen (z.B. „Aufgelöst") und bei Bedarf Tags oder weitere Filter setzen.
2. Das **Teilen-Symbol** in der AppBar antippen.
3. Zieldienst im Android-Share-Sheet wählen – die Datei wird übertragen.

Die exportierte Datei enthält die Auflösungen obfuskiert. Kailibrate zeigt beim Empfänger „Lösung vorhanden" und löst die Vorhersage nach der Schätzung automatisch auf.

Mehr zum Format unter [Format-Referenz](format.md).
