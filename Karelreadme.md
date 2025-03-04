# Karel - Webová aplikace

Tato aplikace představuje robota Karla, který se pohybuje po 2D herním poli na základě zadaných textových příkazů. Jedná se o **klientskou** implementaci pomocí **HTML, CSS a JavaScriptu**, která běží přímo v prohlížeči bez nutnosti serverové komunikace.

## 🚀 Funkce aplikace
- **Herní mřížka 10×10** s vizuálním zobrazením Karla.
- **Příkazy pro ovládání Karla:**
  - `KROK X` - Posune Karla o X polí ve směru natočení.
  - `VLEVOBOK X` - Otočí Karla doleva X krát.
  - `POLOZ A` - Položí na aktuální pozici Karla písmeno A.
  - `RESET` - Vrátí Karla do levého horního rohu a vyčistí herní pole.
- **Podpora více příkazů najednou** (každý na novém řádku).
- **Použití malých i velkých písmen v příkazech**.

## 📜 Použití
1. Spusť soubor `index.html` v prohlížeči.
2. Do textového pole napiš příkazy a klikni na tlačítko `Proveď`.
3. Karel se pohybuje podle zadaných instrukcí.

## 🛠 Technologie
- **HTML** - Struktura stránky.
- **CSS** - Stylování mřížky a prvků.
- **JavaScript** - Logika pro zpracování příkazů a aktualizaci herní mřížky.

## Možná vylepšení
- Grafické otočení Karla pomocí šipek.
- Přidání barevných objektů místo textu `POLOZ`.
- Podpora dalších příkazů, jako je `VPRAVOBOK`.
- Možnost krokování příkazů.

## Licence
Tento projekt je open-source a může být volně použit a upravován. 😊