class Student:
    def __init__(self, jmeno, znamky):
        self.jmeno = jmeno
        self.znamky = znamky

    def prumer(self):
        return sum(self.znamky) / len(self.znamky)


studenti = []

pocet = int(input("Kolik studentu chces zadat? "))

for i in range(pocet):
    jmeno = input("Zadej jmeno studenta: ")
    znamky = []
    for j in range(3):
        znamka = int(input("Zadej znamku: "))
        znamky.append(znamka)

    student = Student(jmeno, znamky)
    studenti.append(student)

studenti.sort(key=lambda s: s.prumer())

for s in studenti:
    prumer = s.prumer()
    print(f"{s.jmeno} - prumer: {prumer:.2f}")
    if prumer <= 4:
        print("Student prospel")
    else:
        print("Student neprospel")