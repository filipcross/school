# Přenos hodnot mezi skripty (a.php a b.php)

Tento projekt demonstruje různé způsoby, jak přenést hodnotu z jednoho PHP skriptu do druhého v rámci webové aplikace.

## Skripty
- **a.php**: Generuje náhodné číslo a umožňuje jeho přenos pomocí GET, POST nebo SESSION.
- **b.php**: Přijatou hodnotu zobrazuje.

## Způsoby přenosu
1. **GET**
   - Hodnota je připojena k URL jako parametr (např. `b.php?value=42`).
   - Výhody: Snadné použití a možnost sdílení URL.
   - Nevýhody: Hodnota je viditelná v URL a lze ji snadno změnit.

2. **POST**
   - Hodnota je odeslána jako součást HTTP požadavku.
   - Výhody: Hodnota není viditelná v URL.
   - Nevýhody: Nelze sdílet jako URL, vyžaduje formulář.

3. **SESSION**
   - Hodnota je uložena na straně serveru a zpřístupněna v rámci relace.
   - Výhody: Bezpečné uložení hodnoty, není potřeba ji znovu přen
