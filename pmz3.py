class Account:
    def __init__(self, zustatek):
        self.zustatek = zustatek
        self.historie = []

    def vklad(self, castka):
        self.zustatek += castka
        self.historie.append("Vklad " + str(castka))

    def vyber(self, castka):
        if castka <= self.zustatek:
            self.zustatek -= castka
            self.historie.append("Vyber " + str(castka))
        else:
            print("Nemas dost penez")


ucet = Account(float(input("Zadej pocatecni zustatek: ")))

while True:
    print("\n1 - vklad")
    print("2 - vyber")
    print("3 - historie")
    print("0 - konec")

    volba = input("Vyber: ")

    if volba == "1":
        castka = float(input("Kolik chces vlozit: "))
        ucet.vklad(castka)
        print("Novy zustatek:", ucet.zustatek)

    elif volba == "2":
        castka = float(input("Kolik chces vybrat: "))
        ucet.vyber(castka)
        print("Novy zustatek:", ucet.zustatek)

    elif volba == "3":
        print(ucet.historie)

    elif volba == "0":
        break