# <img src="https://github.com/OwnYourData/app-consent/raw/master/app/assets/images/app-consent.png" width="92"> Consent Information    

The OwnYourData Consent App displays consent records and allows retrieving further information as well as revoking consent. An example application that provides consent information is the [DEC112 Training Chatbot](https://github.com/sem-con/sc-dec112). The following screenshots show the consent list as well as an individual record.

<img src="https://github.com/OwnYourData/app-consent/raw/master/app/assets/images/screenshot1.png">

<img src="https://github.com/OwnYourData/app-consent/raw/master/app/assets/images/screenshot2.png">


### OwnYourData Data Vault

The Consent App is deployed in your OwnYourData Data Vault. Usually you have to pass on your data to the operators of web services and apps in order to be able to use them. OwnYourData, however, turns the tables: You keep all your data and you keep them in your own data vault. You bring apps (data collection, algorithms and visualization) to you in the data vault.

more information: https://www.ownyourdata.eu    
for developer: https://www.ownyourdata.eu/developer/    
Docker images: https://hub.docker.com/r/oydeu/app-consent    

&nbsp;    

## Installation    

Install the Consent App in the Data Vault Plugin page (https://data-vault.eu/en/plugins) by clicking "+ Add Plugin" and either selecting "DEC112" from the available list of pre-defined plugins or paste the Manifest [available here](https://github.com/OwnYourData/app-consent/raw/master/config/dec112_en.json).

## Data Structure    

The repo (default `oyd.consent`) uses the following structure:    
```json
{
    "timestamp": "2020-09-27T13:05:01Z",
    "did": "did:example:123456789abcdefghi",
    "service-endpoint": "https://data-vault.eu/api/data",
    "service-description": "description",
    "identifier": "unique ID from source",
    "usage-policy": "machine readable usage policy",
    "receipt": "JSON structure with receipt information for writing into Semantic Container"
}
```

## Improve the Consent Information App

Please report bugs and suggestions for new features using the [GitHub Issue-Tracker](https://github.com/OwnYourData/app-consent/issues) and follow the [Contributor Guidelines](https://github.com/twbs/ratchet/blob/master/CONTRIBUTING.md).

If you want to contribute, please follow these steps:

1. Fork it!
2. Create a feature branch: `git checkout -b my-new-feature`
3. Commit changes: `git commit -am 'Add some feature'`
4. Push into branch: `git push origin my-new-feature`
5. Send a Pull Request

&nbsp;    

## License

[MIT License 2020 - OwnYourData.eu](https://raw.githubusercontent.com/OwnYourData/app-consent/master/LICENSE)