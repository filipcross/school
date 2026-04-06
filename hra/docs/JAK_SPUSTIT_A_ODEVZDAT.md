# Jak projekt spustit a odevzdat

## 1. Co je potřeba
- Godot Engine 4.x
- rozbalený ZIP projektu

## 2. Spuštění projektu
1. Otevři **Godot 4**.
2. Klikni na **Import**.
3. Najdi soubor `project.godot`.
4. Potvrď import projektu.
5. Otevři projekt.
6. Klikni na **Run Project** nebo stiskni **F5**.

## 3. Co zkontrolovat před odevzdáním
Po spuštění si zkus:
- jestli funguje menu
- jestli se postava hýbe doleva a doprava
- jestli skáče
- jestli jde lézt po žebříku
- jestli Donkey Kong spawnuje sudy
- jestli funguje ztráta životů
- jestli funguje výhra po dosažení cíle
- jestli hrají zvuky a hudba

## 4. Doporučené nastavení v Godotu
- spouštět ve **windowed režimu**
- nechat zapnuté defaultní nastavení importu
- nic dalšího není potřeba ručně nastavovat

## 5. Jak to zabalit na odevzdání
### Varianta A – odevzdání celého projektu
- odevzdej celý ZIP tak, jak je
- nebo nahraj celý projekt do GitHub repozitáře

### Varianta B – GitHub
1. vytvoř nový repozitář
2. nahraj do něj celý obsah složky projektu
3. zkontroluj, že je tam:
   - `project.godot`
   - `scenes`
   - `scripts`
   - `assets`
   - `README.md`
4. odevzdej odkaz na repo

## 6. Co říct u obhajoby
Můžeš říct něco v tomhle stylu:

> Projekt je vytvořený v Godot 4 pomocí GDScriptu.  
> Jde o fanouškovsky inspirovanou 2D plošinovku ve stylu Donkey Konga.  
> Vytvořili jsme vlastní jednoduchou pixel art grafiku, doplnili pohyb hráče, lezení po žebříku, překážky ve formě sudů, menu, HUD, zvuky a základní herní efekty.  
> Cílem bylo vytvořit kompletní malou hru, která působí hotově a je hratelná.

## 7. Když něco nepůjde
- zavři projekt a otevři znovu
- zkontroluj, že používáš **Godot 4**, ne Godot 3
- zkontroluj, že jsi importoval soubor `project.godot`
