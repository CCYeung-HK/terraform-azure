from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import pyodbc

keyVaultName = "quiz-keyvault"
KVUri = f'https://{keyVaultName}.vault.azure.net'
secretName = "ap-cloud-quiz-sqldatabase-password"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KVUri, credential=credential)
retrieved_secret = client.get_secret(secretName)

print(f"The value of secret '{secretName}' in '{keyVaultName}' is: '{retrieved_secret.value}' ")

server = "tcp:ap-cloud-quiz-sqlserver.database.windows.net"
database = "ap-cloud-quiz-sqldatabase"
username = "quizadministrator"
password = f"{retrieved_secret.value}"
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
cursor = cnxn.cursor()

cursor.execute("SELECT * FROM recipes")
row=cursor.fetchone()
while row:
        print(row)
        row=cursor.fetchone()