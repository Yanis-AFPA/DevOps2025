# Importation des modules nécessaires
import os
from dotenv import load_dotenv
import google.generativeai as genai

# Chargement des variables d'environnement depuis le fichier .env
load_dotenv()

# Récupération de la clé API à partir des variables d'environnement
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    # Affiche un message d'erreur si la clé API n'est pas trouvée
    print("Error: GEMINI_API_KEY not found.")
    print("Please make sure you have created a .env file with your API key.")
    print("Example .env content:\nGEMINI_API_KEY=your_actual_key_here")
    exit(1)

# Configuration de l'API Gemini
genai.configure(api_key=api_key)

# Définition du modèle à utiliser
model_name = "gemini-flash-latest"
try:
    model = genai.GenerativeModel(model_name)
    # Création d'une session de chat
    chat_session = model.start_chat(history=[])
    print(f"Session de chat démarrée avec le modèle : {model_name}")
except Exception as e:
    print(f"Erreur lors de l'initialisation du modèle : {e}")
    exit(1)

print("Tapez 'bye', 'quit' ou 'exit' pour arrêter.")

# Boucle infinie pour permettre une interaction continue
while True:
    try:
        # Demande à l'utilisateur d'entrer un prompt
        prompt = input("\n=> Entrez votre prompt : ")
    except EOFError:
        break

    # Vérifie si l'utilisateur souhaite quitter
    if prompt.lower() in ["bye", "quit", "exit"]:
        print("Au revoir !")
        break
    
    # Ignore les entrées vides
    if not prompt.strip():
        continue

    try:
        # Envoi du message au modèle
        response = chat_session.send_message(prompt)
        # Affichage de la réponse du modèle
        print(response.text)
    except Exception as e:
        print(f"Une erreur est survenue : {e}")
