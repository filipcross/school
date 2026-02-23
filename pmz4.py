class Cinema:
    def __init__(self, pocet_mist):
        self.mista = [False] * pocet_mist

    def rezervuj(self, cislo):
        self.mista[cislo - 1] = True
        print("Misto rezervovano")

    def volna_mista(self):
        print(self.mista)


kino = Cinema(10)

while True:
    print("\n1 - rezervovat misto")
    print("2 - zobrazit volna mista")
    print("0 - konec")

    volba = input("Vyber: ")

    if volba == "1":
        cislo = int(input("Zadej cislo mista: "))
        kino.rezervuj(cislo)

    elif volba == "2":
        kino.volna_mista()

    elif volba == "0":
        break