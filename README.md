# Powershell CountDown Game

## API keys
There are two API's being used in this script that require authentication. 

1. https://developer.oxforddictionaries.com
2. https://azure.microsoft.com/en-au/services/cognitive-services/spell-check/

You'll need to sign up and enter your own API keys and Oxford AppID into the keys.txt file.
Make sure this file is always in the scripts root directory. You should have something like this:

```
Bing = 5f4e2cbf3de242548a3d79c0333f51cd 
Oxford = c3e76f85, dc2334f9b3e8b24320add72730bfaaf39
```
###### FAKE KEYS


## Adding
* At the moment there are no checks being done to ensure numbers being used in 
  the answer are the numbers given or if they are being used more then once.

* Full Game. Will be three rounds of each game mode. 
  Numbers -> Letters -> Numbers -> Letters -> Numbers -> Letters -> END 
