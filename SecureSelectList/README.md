---
# ORACLE APEX  
P L U G I N - SecureSelectList
---
---
### Authors
* Daniel Ekberg @dan_ekb
* Mathias Magnusson @mathiasmag 
* Ulf Hellström @uhellstr 
### Purpose:
To prevent tampering the values of a selectlist item within Oracle APEX.
### Description
Instead of using the native selectlist in APEX you can use this plugin 
for preventing value tampering. 

After installing the plugin, you can create a page and add the item
SecureSelectList. 
As of now the SecureSelectList plugin covers:
* LOV -Static Values
* LOV -SQL Query
* LOV -PL/SQL function body returning sql query
* LOV -Cascading
* Custom Error Message

### Prerequisites
* APEX 5.X or newer.
### Installation
1. Download the plugin
2. Open/create your application in the APEX builder
3. Navigate to Shared Components->Other Components->Plugin
4. Press the import button and follow the instructions
5. You can now add the SecureSelectList to a page in your application
### Note
This plugin does not work at apex.oracle.com since that environment 
has limitation set for EXECUTE IMMEDIATE.
### License
This project is licensed under the MIT License
Free Software, Yes Sir!
