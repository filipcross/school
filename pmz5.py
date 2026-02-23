class Task:
    def __init__(self, text):
        self.text = text
        self.hotovo = False

    def splnit(self):
        self.hotovo = True


ukoly = []

while True:
    print("\n1 - pridat ukol")
    print("2 - splnit ukol")
    print("3 - vypsat ukoly")
    print("0 - konec")

    volba = input("Vyber: ")

    if volba == "1":
        text = input("Zadej ukol: ")
        ukoly.append(Task(text))

    elif volba == "2":
        for i in range(len(ukoly)):
            print(i, "-", ukoly[i].text)
        cislo = int(input("Ktery ukol splnit: "))
        ukoly[cislo].splnit()

    elif volba == "3":
        for u in ukoly:
            stav = "hotovo" if u.hotovo else "nesplneno"
            print(u.text, "-", stav)

    elif volba == "0":
        break