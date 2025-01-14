( [RU](./README-RU.md) )
( [EN](./README.md) )
---

Der Server ist ein einfacher Skriptprozessor für Textdateien mit der Möglichkeit, Shell-Prozesse auszuführen und die Ausgabe an einen Browser zu streamen. Er kann als eigenständige Anwendung oder als Dienst betrieben werden.

### 1. Beschreibung der Hauptseite und des Skript-Interaktionsprinzips

Die Hauptseite kann neu konfiguriert werden, um eine andere Schnittstelle zu verwenden, aber hier wird erklärt, wie die Skripte miteinander interagieren.  
Die Hauptseite besteht aus einer festen Leiste mit einem Menübutton und einem Client-Bereich, in dem die Ergebnisse der ausgeführten Skripte angezeigt werden.  
Der Client-Bereich wird mit einem `<iframe>`-Element realisiert. Die Hauptseite enthält mehrere JavaScript-Hilfsfunktionen.  

Wenn der Menübutton geklickt wird, sendet die Funktion `loadMenu()` eine asynchrone AJAX-Anfrage an den Server. Nach Erhalt einer Antwort baut sie eine Baumstruktur der Menüelemente auf und zeigt sie dem Benutzer an.  

Wenn ein Menüelement ausgewählt wird, ändert JavaScript die `src`-Eigenschaft des `contentFrame` (iFrame)-Elements auf den Wert, der dem ausgewählten Menüelement entspricht. Auf diese Weise wird der Inhalt der neuen Anfrage innerhalb des Frames angezeigt.  

Eine weitere Hilfsfunktion ist `requestServer(URL)`. Sie sendet eine asynchrone Anfrage an den Server und gibt das Ergebnis zurück. Mit ihr können neue Variablen zum Server hinzugefügt, Menüelemente geändert und andere Aktionen durchgeführt werden.  

#### 1.1. Interne Server-URLs

##### 1.1.1. `/shell`
Führt einen Befehl aus, der im Parameter `cmd` übergeben wird. Implementiert in der Datei `shell.thtml`.  
Beispiel: `/shell?cmd=python myscript.py`  

##### 1.1.2. `/menulist`
Gibt eine Liste der Menüelemente und ihrer Befehle zurück. Standardmäßig werden sie aus der Konfigurationsdatei gelesen, können aber über die asynchrone Anfrage `/menu` geändert werden, die von der Funktion `requestServer()` gesendet wird.  

##### 1.1.3. `/menu`
Ermöglicht die Verwaltung des Menüs:  
- `/menu?clear` — löscht die Liste;  
- `/menu?default` — stellt die Liste aus der Konfigurationsdatei wieder her;  
- `/menu?captionX=Meine Beschriftung im Menü X&cmdX=meine URL` — ändert oder fügt ein Menüelement mit der angegebenen Beschriftung und URL hinzu.  
Alle Befehle können in einer Anfrage kombiniert werden. Sie werden in der Reihenfolge ausgeführt, die in der URL angegeben ist.  

##### 1.1.4. `/envvar`
Fügt eine neue Variable und ihren Wert zur Verwendung in Vorlagen hinzu.  
Beispiel: `/envvar?myvar=Mein Wert` — die Variable kann in der Vorlage als `$(myvar)` referenziert werden.  

##### 1.1.5. `/stop`
Beendet das Lauschen auf dem Port und beendet die Anwendung.  

##### 1.1.6. `/shellresponse`
Gibt alle ungelesenen Daten aus dem Ausgabestream zurück, nachdem ein Befehl über `/shell` ausgeführt wurde. Wenn kein Befehl ausgeführt wird, wird ein 404-Fehlercode zurückgegeben.  

##### 1.1.7. `/shellrun`
Gibt einen 200-Code zurück, wenn ein Befehl über `/shell` gestartet wurde. Andernfalls wird ein 404-Code zurückgegeben.  

### 2. Beschreibung der Konfigurationsdatei

#### 2.1. Abschnitt `Application`

##### 2.1.1. Parameter `Port`
Gibt den Port an, auf dem der Server auf Anfragen lauscht. Der Standardwert ist 8080. Bei Änderung des Ports muss der Zugriff über die Firewall konfiguriert werden. Zum Beispiel mit dem Tool `ufw`:  
```bash
sudo ufw allow 8080/tcp
```

##### 2.1.2. Parameter `RootPath`
Enthält den Pfad zum Verzeichnis mit den Vorlagen für angeforderte Seiten. Der Standardwert ist `/var/techtool/thtml/`, aber für Debugging-Zwecke kann ein anderes Verzeichnis verwendet werden.  

##### 2.1.3. Parameter `RootFileName`
Gibt den Namen der Vorlagendatei an, die beim Aufruf der URL `/` verwendet wird.  

##### 2.1.4. Parameter `WorkDir`
Enthält den Pfad zum Ordner für temporäre Dateien, wie z. B. Protokolle. Der Standardwert ist `/tmp`.  

#### 2.2. Abschnitt `MENU[X]`
Die Nummer im Abschnittsnamen ist obligatorisch und muss eindeutig sein.  

##### 2.2.1. Parameter `MenuCaption`
Enthält den Text, der dem Benutzer im Menü angezeigt wird.  

##### 2.2.2. Parameter `MenuCommand`
Enthält die URL der aufzurufenden Seite (siehe URL-Beschreibung).  

### 3. URL-Verarbeitung

Wenn ein Skriptname mit oder ohne Erweiterung angegeben wird, sucht der Server nach der Datei im Pfad, der in der Konfigurationsdatei (`APPLICATION.RootPath`) angegeben ist. Wenn die Datei nicht gefunden wird, erhält der Browser eine 404-Antwort.  

Wenn eine Seite angefordert wird, führt der Server die folgenden Substitutionen durch:  

#### 3.1. Konfigurationsvariablen
Im Skript müssen der Abschnittsname und der Parameter (ohne Trennzeichen) in Großbuchstaben angegeben werden.  
Beispiel: `$(APPLICATIONPORT)`  

#### 3.2. Umgebungsvariablen
Im Skript muss der Variablenname unter Berücksichtigung der Groß- und Kleinschreibung angegeben werden.  
Beispiel: `$(SHELL)`  

#### 3.3. Vom Entwickler definierte Variablen während der Shell-Ausführung
Die Bedingungen sind die gleichen wie für Umgebungsvariablen.  

### 4. Debugging von Skripten mit CSWS

In diesem Verzeichnis befinden sich drei vorkompilierte Versionen des Programms, die für verschiedene Plattformen entwickelt wurden:

- **`aarch64-linux`** — Version für Raspberry Pi-Geräte;
- **`x86_64-win64`** — Version für 64-Bit-Windows-Systeme;
- **`x86_64-linux`** — Version für 64-Bit-Linux-Systeme.

Das Starten der Anwendung mit einer separaten Konfigurationsdatei ermöglicht eine flexible Anpassung von Parametern und Vorlagen, was das Debugging von Skripten erleichtert. Dies ermöglicht es, ihre Funktionalität direkt im Browser zu testen, ohne Änderungen am Raspberry Pi-Gerät vornehmen zu müssen.


#### 4.1. Befehlszeilenparameter

Das Programm unterstützt die folgenden Befehlszeilenparameter:

- **`--conf="my.conf"`**  
  Startet das Programm mit der angegebenen Konfigurationsdatei. Dies ermöglicht die Verwendung von benutzerdefinierten Einstellungen und Vorlagen.

- **`--stop`**  
  Stoppt das Programm, falls es bereits ausgeführt wird.

- **`--envvar`**  
  Zeigt eine Liste aller Umgebungsvariablen an, die dem Programm zur Verfügung stehen.

- **`--addmenu="<menu caption>:=:<command>"`**  
  Fügt dem Konfigurationsdatei einen neuen Menüabschnitt hinzu.  
  - `<menu caption>` — der Menütitel;  
  - `<command>` — der mit diesem Menüpunkt verknüpfte Befehl.

