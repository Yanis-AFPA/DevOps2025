import re 
import csv              
import os               
import requests         
from dotenv import load_dotenv

# 1. Lire le fichier log
log_file = "test_sample.txt" 
print(f"Lecture du fichier : {log_file}")

with open(log_file, "r") as f:
    content = f.read()

# Trouver toutes les IPs (format X.X.X.X)
ips = re.findall(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", content)
unique_ips = []
for ip in ips:
    if ip not in unique_ips:
        unique_ips.append(ip)

# 2. Interroger AbuseIPDB
load_dotenv()
api_key = os.getenv("ABUSEIPDB_API_KEY")
url = "https://api.abuseipdb.com/api/v2/check"
headers = {
    'Key': api_key,
    'Accept': 'application/json'
}
results = []
print("\n--- Analyse AbuseIPDB ---")

for ip in unique_ips:
    response = requests.get(url, headers={'Key': api_key}, params={'ipAddress': ip})
    data = response.json()['data']
    score = data['abuseConfidenceScore']
    country = data['countryCode']
    
    if score == 0: risk = "Sûr"
    elif score < 25: risk = "Faible"
    elif score < 75: risk = "Moyen"
    else: risk = "Critique"

    print(f"{ip}: Score={score}, Risque={risk}, Pays={country}")
    results.append([ip, score, risk, country])

# Trier par Score (le plus grand en premier)
results.sort(key=lambda x: x[1], reverse=True)

# 3. Générer le CSV

with open("rapport.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["IP", "Score", "Risque", "Pays"])
    writer.writerows(results)

print("\nRapport CSV généré : rapport.csv")
