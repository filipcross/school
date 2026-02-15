import pygame
import random

pygame.init()

# Rozměry
sirka = 800
vyska = 600
okenko = pygame.display.set_mode((sirka, vyska), pygame.RESIZABLE)
pygame.display.set_caption("Hadí hra")

# Barvy
cerna = (0, 0, 0)
zelena = (0, 255, 0)
cervena = (255, 0, 0)
bila = (255, 255, 255)

# Rychlost a blok
velikost_bloku = 20
rychlost = 10
hodiny = pygame.time.Clock()

# Fonty 
font = pygame.font.SysFont(None, 35)
maly_font = pygame.font.SysFont(None, 25)

def zprava(text, velikost=35, posun=0):
    if velikost == 35:
        render = font.render(text, True, cervena)
    else:
        render = maly_font.render(text, True, bila)
    text_rect = render.get_rect(center=(sirka / 2, vyska / 2 + posun))
    okenko.blit(render, text_rect)

def zobraz_skore(skore):
    text = font.render(f"Skóre: {skore}", True, bila)
    okenko.blit(text, (10, 10))

def hra():
    konec = False
    prohra = False

    x = sirka / 2
    y = vyska / 2
    dx = 0
    dy = 0

    telo = []
    delka_hada = 1
    skore = 0

    jidlo_x = round(random.randrange(0, sirka - velikost_bloku) / 20.0) * 20.0
    jidlo_y = round(random.randrange(0, vyska - velikost_bloku) / 20.0) * 20.0

    while not konec:
        while prohra:
            okenko.fill(cerna)
            zprava("Prohrál jsi! Stiskni Q pro konec nebo C pro restart")
            zprava(f"Skóre: {skore}", velikost=25, posun=40)
            pygame.display.update()

            for event in pygame.event.get():
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_q:
                        konec = True
                        prohra = False
                    if event.key == pygame.K_c:
                        hra()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                konec = True
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:
                    dx = -velikost_bloku
                    dy = 0
                elif event.key == pygame.K_RIGHT:
                    dx = velikost_bloku
                    dy = 0
                elif event.key == pygame.K_UP:
                    dy = -velikost_bloku
                    dx = 0
                elif event.key == pygame.K_DOWN:
                    dy = velikost_bloku
                    dx = 0

        x += dx
        y += dy

        if x >= sirka or x < 0 or y >= vyska or y < 0:
            prohra = True

        okenko.fill(cerna)
        pygame.draw.rect(okenko, cervena, [jidlo_x, jidlo_y, velikost_bloku, velikost_bloku])

        hlava = [x, y]
        telo.append(hlava)

        if len(telo) > delka_hada:
            del telo[0]

        for segment in telo[:-1]:
            if segment == hlava: 
                prohra = True

        for cast in telo:
            pygame.draw.rect(okenko, zelena, [cast[0], cast[1], velikost_bloku, velikost_bloku])

        if x == jidlo_x and y == jidlo_y:
            jidlo_x = round(random.randrange(0, sirka - velikost_bloku) / 20.0) * 20.0
            jidlo_y = round(random.randrange(20, vyska - velikost_bloku) / 20.0) * 20.0
            delka_hada += 1
            skore += 1

        zobraz_skore(skore)

        pygame.display.update()
        hodiny.tick(rychlost)

    pygame.quit()
    quit()

hra()
