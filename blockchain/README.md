# Jednoduchý Blockchain s REST API

## 1. Úvod

Tento projekt demonstruje základní princip fungování blockchainu.  
Blockchain je datová struktura, která ukládá informace do bloků. Tyto bloky jsou navzájem propojeny pomocí kryptografických hashů.

Cílem projektu je vytvořit jednoduchou implementaci blockchainu a umožnit práci s ním pomocí REST API.

Projekt je vytvořen v programovacím jazyce Python a pro vytvoření API je použit framework Flask.


## 2. Použité technologie

V projektu byly použity tyto technologie:

- Python – hlavní programovací jazyk
- Flask – webový framework pro vytvoření REST API
- hashlib – knihovna pro vytváření hashů
- datetime – knihovna pro práci s časem


## 3. Princip fungování blockchainu

Blockchain v tomto projektu funguje jako seznam bloků.

Každý blok obsahuje tyto informace:

- index – pořadí bloku v blockchainu
- timestamp – čas vytvoření bloku
- data – informace uložené v bloku
- previous_hash – hash předchozího bloku
- hash – hash aktuálního bloku

Každý nový blok obsahuje hash předchozího bloku, díky čemuž jsou bloky propojené. Pokud by se změnil obsah některého bloku, změnil by se jeho hash a blockchain by přestal být validní.


## 4. REST API

Pro komunikaci s blockchainem bylo vytvořeno jednoduché REST API pomocí frameworku Flask.

API obsahuje tyto endpointy:

### Získání celého blockchainu

GET `/blockchain`

Vrátí seznam všech bloků v blockchainu.


### Přidání nového bloku

POST `/add_block`

Přidá nový blok do blockchainu.

Příklad JSON požadavku:

```json
{
  "data": "moje transakce"
}