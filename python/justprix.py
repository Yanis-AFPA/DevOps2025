import random


def jeu():
    nb_random = random.randint(1,100)
    nb_essais = 0
    while True:
        try:
            nb_proposer = int(input("Donner un nombre entre 1 et 100 : "))
            nb_essais +=1
            
            if nb_proposer not in range(1,100) :
                print("Entre un nombre valide")
                nb_essais -=1
            elif nb_proposer == nb_random:
                print(f"Bravo le nombre est {nb_random} en {nb_essais} essais")
                break
            elif nb_proposer < nb_random:
                print("C’est plus grand")
            else :
                print("C’est plus petit")
        except ValueError:
            print("Entre un nombre valide")

if __name__ == "__main__":
    jeu()  



    