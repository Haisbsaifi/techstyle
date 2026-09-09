# MVP – Rabatt- und Gutscheincodes

## Ziel

TechStyle möchte Rabatt- und Gutscheincodes einführen, damit Marketing gezielte Aktionen durchführen und Kunden zum Kauf motivieren kann.

Das Feature wird schrittweise in mehreren MVPs umgesetzt. Dadurch kann bereits früh eine einfache funktionierende Lösung ausgeliefert und später erweitert werden.

---

## MVP 1 – Einfacher Gutscheincode

### Ziel

Eine einfache und schnell umsetzbare Gutschein-Funktion im Checkout bereitstellen.

### Funktionen

- Im Checkout gibt es ein Eingabefeld für einen Gutscheincode.
- Ein vordefinierter Gutscheincode kann eingegeben werden.
- Das System prüft, ob der Code gültig ist.
- Ein gültiger Code gibt einen festen prozentualen Rabatt.
- Der reduzierte Gesamtpreis wird im Checkout angezeigt.
- Bei einem ungültigen Code wird eine Fehlermeldung angezeigt.

### Beispiel

```text
Gutscheincode: TECHSTYLE10
Rabatt: 10 %

Warenkorb: CHF 100.00
Rabatt:    CHF 10.00
Total:     CHF 90.00
```

---

## MVP 2 – Verwaltbare Gutscheine

### Ziel

Marketing soll mehrere unterschiedliche Rabattaktionen verwenden können.

### Zusätzliche Funktionen

- Gutscheincodes werden in der Datenbank gespeichert.
- Mehrere Gutscheincodes können gleichzeitig existieren.
- Jeder Gutschein besitzt einen eigenen Rabattwert.
- Gutscheine können ein Startdatum besitzen.
- Gutscheine können ein Ablaufdatum besitzen.
- Abgelaufene oder noch nicht gültige Gutscheine werden abgelehnt.

### Beispiel

```text
SUMMER20
Rabatt: 20 %
Gültig: 01.06.2026 – 31.08.2026
```

---

## MVP 3 – Personalisierte Gutscheine

### Ziel

Marketing soll gezielte und personalisierte Rabattaktionen durchführen können.

### Zusätzliche Funktionen

- Gutscheine können bestimmten Kunden zugeordnet werden.
- Gutscheine können nur einmal verwendet werden.
- Mindestbestellwerte können definiert werden.
- Unterschiedliche Rabattarten können unterstützt werden.
- Die Nutzung von Gutscheinen kann ausgewertet werden.

### Beispiel

```text
WELCOME15
Kunde: customer@example.com
Rabatt: 15 %
Mindestbestellwert: CHF 50
Maximale Nutzung: 1
```

---

## MVP-Entwicklung

| MVP | Funktion | Komplexität | Nutzen |
|---|---|---|---|
| MVP 1 | Einfacher Gutscheincode | Niedrig | Schnell nutzbare Rabattfunktion |
| MVP 2 | Verwaltbare Gutscheine | Mittel | Marketing kann Kampagnen verwalten |
| MVP 3 | Personalisierte Gutscheine | Hoch | Gezielte Kundenaktionen |

## Fazit

Mit MVP 1 kann TechStyle schnell eine einfache Gutschein-Funktion bereitstellen und erstes Feedback sammeln.

Anschliessend wird das Feature mit MVP 2 um verwaltbare und zeitlich begrenzte Gutscheine erweitert.

MVP 3 ermöglicht später personalisierte und komplexere Marketingkampagnen.
## INVEST-Check der User Stories

Die User Stories für MVP 1 wurden nach den INVEST-Kriterien formuliert.

| Kriterium | Bedeutung | Umsetzung im MVP |
|---|---|---|
| **I – Independent** | Unabhängig | Die Stories behandeln getrennte Funktionen wie Eingabe, Validierung und Preisanzeige. |
| **N – Negotiable** | Verhandelbar | Details der technischen Umsetzung und der Benutzeroberfläche können angepasst werden. |
| **V – Valuable** | Wertvoll | Jede Story liefert einen konkreten Nutzen für den Kunden. |
| **E – Estimable** | Schätzbar | Der Umfang jeder Story ist klar genug, um den Entwicklungsaufwand abzuschätzen. |
| **S – Small** | Klein | Die Gutschein-Funktion wurde in drei kleine, überschaubare Stories aufgeteilt. |
| **T – Testable** | Testbar | Jede Story besitzt klare Akzeptanzkriterien und kann automatisiert oder manuell getestet werden. |

### User Stories von MVP 1

1. **Gutscheincode im Checkout eingeben**
2. **Gutscheincode validieren**
3. **Rabattierten Gesamtpreis anzeigen**

Durch diese Aufteilung kann jede Funktion einzeln entwickelt, getestet und über den Kanban-Workflow bis zum Deployment gebracht werden.