# Donkey Kong: Retro Rampage+

Promo k naší hře: https://youtu.be/IZBDXoSwFKI

**Donkey Kong: Retro Rampage+** je vylepšená studentská 2D retro plošinovka vytvořená v **Godot Engine 4**.  
Vychází volně z klasického Donkey Konga, ale přidali jsme do ní vlastní nápady, hlavně **endless mode**, postupné zvyšování obtížnosti a další herní mechaniky, aby hra nebyla jen jednoduchá kopie originálu.

## O hře

Hráč se snaží dostat přes jednotlivá patra až nahoru k cíli, přitom se musí vyhýbat sudům, nepřátelům a stihnout level v časovém limitu.  
Po cestě sbírá bonusy, které zvyšují skóre a zároveň odemykají postup dál. Hra je udělaná tak, aby se levely postupně měnily a aby každé další patro bylo těžší.

## Co je ve hře nově

- sbírání bonusů pro odemčení cíle
- časový limit pro každý level
- časový bonus do skóre po dokončení levelu
- kladivo pro dočasné ničení sudů
- ohnivý nepřítel na patře
- finální fáze po sebrání všech bonusů
- ukládání nejlepšího skóre
- výsledková obrazovka po výhře i prohře
- nekonečný režim s postupně rostoucí obtížností
- nové rozložení žebříků a mezer v každém dalším patře
- bonusový život každých 5 dokončených levelů

## Endless mode v14

V této verzi hra funguje jako nekonečná věž:

- každé nové patro vygeneruje jinou kombinaci žebříků a mezer
- skóre se sčítá přes všechny levely
- barely se ve vyšších levelech spawnují častěji
- čas na dokončení levelu se postupně zkracuje
- přibývají další nepřátelé
- každých 5 levelů hráč získá bonusový život

Díky tomu hra není pořád stejná a má větší replay value.

## Ovládání

- **A / D** nebo **šipky** – pohyb
- **W / S** nebo **šipky** – lezení po žebříku
- **Space** – skok
- **R** – restart
- **P** – pauza

## Spuštění

Otevři soubor `project.godot` v **Godot 4.x** a spusť hlavní scénu.

Hlavní scéna hry:
- `res://scenes/MainMenu.tscn`

## Jaké nástroje a technologie jsme při vývoji použili

Na vývoj jsme použili hlavně tyto věci:

### Godot Engine 4
Celá hra byla vytvořená v **Godot 4.6**.  
Použili jsme ho proto, že je zdarma, přehledný a na 2D hru je podle nás super. Zároveň se v něm dobře dělá fyzika, kolize, scény i skriptování.

### GDScript
Logika hry je napsaná v **GDScriptu**, což je skriptovací jazyk přímo pro Godot.  
Používali jsme ho na:

- pohyb hráče
- skákání a lezení po žebříku
- spawnování sudů
- generování pater
- počítání skóre
- časovač
- práci s životy
- ukládání rekordu
- menu a HUD

### Scény a nody
Hru jsme skládali z více scén a nodeů.  
Například jsme používali:

- `Node2D` pro hlavní herní logiku
- `CharacterBody2D` pro hráče, barely a nepřátele
- `Area2D` pro sběratelné předměty, goal a interakce
- `StaticBody2D` pro platformy a překážky
- `CanvasLayer` pro HUD
- `Camera2D` pro kameru
- `Timer` pro čas a spawnování objektů
- `AudioStreamPlayer` pro zvuky a hudbu

## Jak jsme hru programovali

Nechtěli jsme mít jen jeden statický level, takže jsme udělali systém, který umí level částečně generovat.

### Generování levelu
Každé patro se skládá z:

- platforem
- mezer
- žebříků
- bonusů
- kladiv
- nepřátel

Rozložení žebříků a mezer se losuje náhodně, takže se hra pořád trochu mění.  
Použili jsme na to generátor náhodných hodnot (`RandomNumberGenerator`).

### Hráč
Hráč umí:

- chodit doleva a doprava
- skákat
- lézt po žebříku
- sbírat bonusy
- sebrat kladivo
- ničit sudy během omezeného času
- ztratit život při zásahu nepřítelem nebo pádu dolů

### Sudy a nepřátelé
Sudy se spawnují postupně a ve vyšších levelech rychleji.  
Některé mohou padat po žebřících, takže nejsou úplně předvídatelné.  
Kromě sudů jsme přidali i ohnivého nepřítele, který se pohybuje po vybraném patře.

### HUD a rozhraní
Na obrazovce se během hry zobrazuje:

- aktuální skóre
- počet životů
- zbývající čas
- počet sebraných bonusů
- nejlepší skóre
- čas zbývající do konce efektu kladiva

Přidali jsme i hlavní menu, pauzu a výsledkovou obrazovku.

### Zvuky a hudba
Ve hře jsou použité zvukové efekty pro:

- skok
- zásah
- spawn sudu
- výhru
- sebrání bonusu

K tomu běží i hudba na pozadí, aby hra nepůsobila prázdně.

### Ukládání skóre
Nejlepší skóre se ukládá do souboru ve formátu **JSON**, takže po vypnutí hry rekord nezmizí.  
Tohle jsme řešili přes `user://retro_rampage_save.json`.

## Co bylo naším cílem

Naším cílem nebylo udělat úplně profesionální kopii staré arkády, ale spíš vytvořit vlastní hratelnou verzi, na které bude vidět:

- že umíme pracovat v Godotu
- že umíme naprogramovat logiku 2D hry
- že zvládneme udělat menu, HUD, score systém a ukládání dat
- že dokážeme hru rozšířit o vlastní nápady

Chtěli jsme, aby hra působila jednoduše, retro a zároveň aby byla zábavnější než úplně základní školní projekt.

## Autoři

- **Filip Kříž**
- **Dominik Urban**

## Shrnutí

Na projektu **Donkey Kong: Retro Rampage+** jsme si vyzkoušeli kompletní tvorbu 2D hry v Godotu – od návrhu, přes programování mechanik až po testování a ladění.  
Projekt nám pomohl pochopit práci se scénami, fyzikou, kolizemi, UI, zvukem i ukládáním dat. Zároveň jsme si zkusili, jak rozšířit jednoduchý retro nápad do vlastní větší hry s endless režimem a postupnou obtížností.
