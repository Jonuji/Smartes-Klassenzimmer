# Smartes Klassenzimmer 🎓

Willkommen! Diese Anleitung hilft dir, das Projekt **schnell und einfach** einzurichten.

---

## 📦 Schritt 1: Programme installieren

Falls noch nicht vorhanden, installiere:

- **Git** → [Hier herunterladen](https://git-scm.com/download/win)  
  _(Brauchst du um Code von GitHub zu laden)_

- **Node.js** → [Hier herunterladen](https://nodejs.org/)  
  _(Brauchst du um das Projekt auszuführen)_

> **Nach der Installation:** Computer neu starten! (bzw. vscode oder das terminal)

---

## 📁 Schritt 2: Ordner erstellen

1. **Erstelle einen neuen Ordner** für das Projekt, z.B.:
   - `C:\Projekte\Smartes-Klassenzimmer`
   - Oder auf dem Desktop: `Desktop\Smartes-Klassenzimmer`

2. **Öffne PowerShell in diesem Ordner:**

   **Methode 1 (Am einfachsten):**
   - Öffne den Ordner im Windows Explorer
   - **Rechtsklick** in den leeren Bereich
   - Wähle **"In Terminal öffnen"** oder **"PowerShell hier öffnen"**

   **Methode 2 (Mit Adressleiste):**
   - Öffne den Ordner im Windows Explorer
   - Klicke auf die **Adressleiste** oben
   - Tippe `powershell` und drücke **Enter**

   **Methode 3 (Mit cd-Befehl):**
   - Öffne PowerShell (Windows-Taste drücken, "powershell" eingeben)
   - Navigiere zum Ordner:
     ```powershell
     cd C:\Projekte\Smartes-Klassenzimmer
     ```

---

## 🚀 Schritt 3: Script herunterladen

Jetzt bist du im richtigen Ordner! Führe diesen Befehl aus:

```powershell
Invoke-WebRequest -Uri "https://github.com/Jonuji/Smartes-Klassenzimmer/releases/latest/download/project-manager.ps1" -OutFile "project-manager.ps1"
```

> **💡 Tipp:** Kopiere den Befehl und füge ihn mit **Rechtsklick** in PowerShell ein!

> **❌ Fehler beim Download?**  
> Lade das Script manuell herunter: [Releases](https://github.com/Jonuji/Smartes-Klassenzimmer/releases/latest)  
> Speichere die Datei `project-manager.ps1` in deinem Projekt-Ordner.

---

## ⚙️ Schritt 4: Script ausführen

Starte das Script:

```powershell
.\project-manager.ps1
```

> **🚫 Fehler "Ausführung von Skripts ist deaktiviert"?**  
> Das ist eine Windows-Sicherheitseinstellung. Führe **einmalig** aus:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Danach nochmal versuchen: `.\project-manager.ps1`

---

## 🎯 Schritt 5: Projekt einrichten

Ein Menü öffnet sich! Folge diesen Schritten:

### **Erste Einrichtung:**

1. **Wähle Option `2`**  
   _(Repositories klonen & Dependencies installieren)_

2. **Wähle einen Branch:**
   - Für Entwicklung: `dev`
   - Für stabile Version: `main`
   - Oder deinen Team-Branch (z.B. `team-alpha`)

3. **Warte bis alles heruntergeladen ist** ☕  
   _(Das dauert ein paar Minuten)_

4. **Fertig!** ✅

### **Projekt starten:**

1. **Wähle Option `4`**  
   _(Projekte starten)_

2. **Zwei Fenster öffnen sich:**
   - Backend-Server
   - Frontend-Server

3. **Öffne deinen Browser:**
   - Frontend: [http://localhost:5173](http://localhost:5173)
   - Backend: [http://localhost:3000](http://localhost:3000)

---

## 📋 Menü-Übersicht

Das Script bietet diese Optionen:

| Option | Beschreibung |
|--------|--------------|
| **1** | Nur Repositories klonen |
| **2** | Repositories klonen + alles installieren ⭐ |
| **3** | Nur Dependencies installieren |
| **4** | Projekte starten 🚀 |
| **5** | Updates von GitHub holen |
| **6** | Pull Request erstellen |
| **7** | Branch wechseln |
| **8** | Status anzeigen |
| **0** | Beenden |

---

## ❓ Häufige Fragen

**Wie stoppe ich das Projekt?**  
Drücke `Strg+C` in den beiden Server-Fenstern.

**Wie bekomme ich die neuesten Änderungen?**  
Script starten → Option `5` wählen → Updates werden geholt.

**Wie wechsle ich den Branch?**  
Script starten → Option `7` wählen → Branch auswählen.

**Welchen Branch soll ich nutzen?**  
- `dev` = Entwicklungsversion (aktuelle Features)
- `main` = Stabile Version
- `team-xyz` = Dein Team-Branch

**Was mache ich bei Problemen?**  
Kontaktiere dein Team oder schau in die Projekt-Dokumentation! 💬

---

## 🔄 Täglicher Workflow

1. **Script starten:** `.\project-manager.ps1`
2. **Option 5:** Updates holen
3. **Option 4:** Projekt starten
4. **Arbeiten!** 💻
5. **Änderungen pushen** (mit Git)
6. **Option 6:** Pull Request erstellen (wenn fertig)

---

**Viel Erfolg! 🎉**