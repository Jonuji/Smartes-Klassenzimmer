# Smartes Klassenzimmer 🎓

Willkommen! Mit dieser Anleitung richtest du das Projekt in nur **3 Schritten** ein.

## Was du brauchst

Installiere diese Programme (falls noch nicht vorhanden):
- [Git](https://git-scm.com/download/win) - Zum Herunterladen des Codes
- [Node.js](https://nodejs.org/) - Zum Ausführen des Projekts

## 🚀 In 3 Schritten starten

### Schritt 1: Script herunterladen

Öffne **PowerShell** und führe aus:

```powershell
Invoke-WebRequest -Uri "https://github.com/Jonuji/Smartes-Klassenzimmer/releases/latest/download/project-manager.ps1" -OutFile "project-manager.ps1"
```

> **Fehler?** Falls das nicht funktioniert, lade das Script manuell von [Releases](https://github.com/Jonuji/Smartes-Klassenzimmer/releases/latest) herunter.

### Schritt 2: Script ausführen

```powershell
.\project-manager.ps1
```

> **Fehler "Ausführung von Skripts ist deaktiviert"?** Dann einmalig ausführen:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

### Schritt 3: Im Menü auswählen

Es öffnet sich ein Menü. Wähle:

**Option 2** → Das lädt alles herunter und installiert es automatisch!

Danach kannst du mit **Option 4** das Projekt starten! 🎉

## ❓ Häufige Fragen

**Welchen Branch soll ich wählen?**
- Für Entwicklung: `dev`
- Für die stabile Version: `main`

**Wo läuft das Projekt?**
- Backend: `http://localhost:3000`
- Frontend: `http://localhost:5173`

**Wie stoppe ich das Projekt?**
Drücke `Strg+C` in den geöffneten Fenstern.

**Wie aktualisiere ich das Projekt?**
Starte das Script erneut und wähle **Option 5** (für dev) oder **Option 6** (für main).

---

**Probleme?** Kontaktiere dein Team! 💬