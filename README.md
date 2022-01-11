# terraform-azure

A playground for exploration of terraform in azure.

## Current Version

The current project worked on the basic configurations of the following design:
* Create a Linux virtual machine that can connect to a SQL database by retrieving SQL password via Azure key vault (using key vault api)

## Prerequisites

* Python 3.5 or greater
* pip package management tool (19.0 or higher)
* Terraform 1.1.3
* Package management such as Homebrew (for Mac), Chocolatey (for Windows)
* Azure Terraform & Azure Account extensions (if using VSCode)
* Nodejs latest version

## Getting Started

1. Create an Azure subscription
2. Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
3. Install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
4. Install Azure Terraform VS Code Extension: https://docs.microsoft.com/en-us/azure/developer/terraform/configure-vs-code-extension-for-terraform?tabs=azure-cli

## Build the resources

The terraform script automatically creates the solution highlighted below

(image placeholder)

The script will create the following resources on your behalf
* A resource group for the project
* A virtual network
* A Network Security Group
* A Network Interface
* A Public IP Address
* A SSH Key
* A Ubuntu Linux Virtual Machine (Standard DS1) with Disk
* A SQL server and database
* A key vault and a secret populated


**Notes**
The terraform script will populate the firewall rule of the SQL Server with your local IP and the created virtual machine IP. The local IP is added easier management.

The network security group allows all SSH and HTTPS traffic. If you want to improve the security, please only include your local IP as the source address for SSH traffic.

The SQL password value for creating the key vault secret is retrieved from variable.tf for demonstration purpose. Please never hardcode any sensitive data in the terraform script in any production environment.

## Testing Connection

To test the connection between the linux virtual machine and the sql server, we will query against the SQL Database.

1. Login to your SQL database. Query the database following the script in ./src/sql_query.txt. This will create a table called recipes with a record.

2. Login to your linux virtual machine. 
```ssh azureuser@<PublicIpAddress>```

3. Install the ODBC Driver and the python libraries including ```azure-keyvault-secrets```, ```azure.identity```, and ```pyodbc```. The script could be found in ./src/dependencies.txt

4. After installing the packages, create the python file sample.py and edit the file with the code in ./src/sample.py

5. Run sample.py. The console should return the value of the secret (your SQL password), and the 'recipes' table from the SQL Database created earlier.

## Clean up resources

When you finish with the testing, delete the deployed resources by simply running the command:
```terraform destroy```

## Next Steps
The current project is the basic configuration for building resources. In the future, the following will be implemented to improve the setups
* Utilise Terrafrom module for cleaner and more organised infrastructure setup
* Enhance the security by enabling role based access and identity authentication
* Experiment terraform vault for storing sensitive data








