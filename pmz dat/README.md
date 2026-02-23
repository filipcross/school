# Evidence nasazených serverových služeb

Tento projekt slouží jako jednoduchý návrh databáze pro evidenci serverů a služeb v malé firmě.  
Databáze ukládá informace o serverech, službách a o tom, kdy byla služba nasazena a v jakém stavu běží.


## 1 Entity a vztahy

### Entity


- **Server**  
  Slouží k uložení základních informací o serverech ve firmě (např. název a IP adresa).

- **Service**  
  Ukládá informace o službách, které běží na serverech (např. web, databáze, DNS).

- **Deployment**  
  Tato tabulka slouží jako propojení mezi Serverem a Service.  
  Ukládá informaci, kdy byla služba nasazena (`deployed_at`) a v jakém režimu běží (`status` – Installed, Started, Running, Stopped, Failed).

### Vztahy

- Server může mít více služeb  
- Jedna služba může běžet na více serverech  
- Vztah mezi Server a Service je řešen pomocí tabulky Deployment

**Zdůvodnění (studentsky):**  
Zvolil jsem tyto tři entity, protože potřebuju evidovat servery, služby a jejich nasazení.  
Vztah M:N jsem musel rozdělit pomocí tabulky Deployment, protože ukládám navíc datum nasazení a stav služby.

---

## 3 Atributy + normalizace (1. a 2. NF)

### Atributy entit

**Server**
- id  
- name  
- ip_address  

**Service**
- id  
- name  
- port  

**Deployment**
- id  
- server_id  
- service_id  
- deployed_at  
- status  

### Normalizace

- **1. normální forma (1. NF)**  
  Každý atribut má jen jednu hodnotu (např. IP adresa je v jednom sloupci, ne víc IP v jednom poli).

- **2. normální forma (2. NF)**  
  Všechny atributy závisí jen na primárním klíči tabulky.  
  V tabulce Deployment závisí datum nasazení a stav jen na konkrétním záznamu nasazení.

Návrh je podle mě v 1. i 2. normální formě a není potřeba ho dál rozdělovat.

---

## 5️⃣ EER diagram (textově v Markdownu)

### Tabulka Server
| PK id | name | ip_address |

### Tabulka Service
| PK id | name | port |

### Tabulka Deployment
| PK id | FK server_id | FK service_id | deployed_at | status |

### Vztahy mezi tabulkami

- `Deployment.server_id` → `Server.id`  
- `Deployment.service_id` → `Service.id`  

Server 1 --- N Deployment N --- 1 Service
