#  ![alt text](https://user-images.githubusercontent.com/42153044/61584923-01d6df00-ab16-11e9-9811-9b2ece37889a.png)

HealthApp provides a series of tools to provide a better interaction between patients and doctors.
This application is integrated with HealthKit, Firebase and Realm it means that every record of alimentation, sports and more are synchronized between doctor and patient in real time.
In addition incorporates an image analyzer, working in conjunction with automated learning algorithms to predict the presence of different skin lesions with just one photo.

Check [Patient App](https://github.com/ColeMacGrath/HealthApp)

## Getting started

## Prerequsistes

| Software | **Minimum Version** |     **Recommended**     |
| :------: | :-----------------: | :---------------------: |
|  macOS   | High Sierra 10.13.6 | Mojave 10.14.3 or newer |
|  Xcode   |      Xcode 10       |       Xcode 10.2        |
|  Swift   |      Swift 4.0      |        Swift 5.0        |
|   iOS    |       iOS 12        |        iOS 12.1         |

### Packages

|        Package         | **Version Tested** | **Optional** |
| :--------------------: | :----------------: | :----------: |
|        CocaPods        |       1.5.2        |      No      |
|        Firebase        |       6.3.0        |     Yes      |
|     Firebase/Auth      |       6.3.0        |      No      |
|   Firebase/Database    |       6.3.0        |      No      |
|    Firebase/Storage    |       6.3.0        |      No      |
|     FloatingPanel      |       1.6.1        |      No      |
| IQKeyboardManagerSwift |       6.4.0        |     Yes      |
|    JTAppleCalendar     |       8.0.0        |      No      |
|         Charts         |       3.3.0        |     Yes      |
|       RealmSwift       |       3.17.0       |      No      |

Podfile included

```
pod 'Charts'
pod 'Firebase'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'FloatingPanel'
pod 'IQKeyboardManagerSwift'
pod 'JTAppleCalendar'
pod 'RealmSwift'
```

### How to Install

1. Clone the project
2. Create a new Pod file from .xcodeproj
3. Install packages listed before
4. Drag and drop [Machine Learning Model](google.com) in HealthApp/Visual Recognizer (Check the Target Membership)
5. Drag and drop your own GoogleService-Info.plist into HealthApp/
7. Activate MapKit to your Apple ID

![alt text](https://user-images.githubusercontent.com/42153044/51432666-ffe0a180-1c00-11e9-9358-e00ee5b00947.png)

## About Trained Model

The model was trained with more than 12,000 images in high resolution

#### Type

Image Classifier

#### Size

66 kb

#### Description

A model trained to determine the pathology of a naevus

#### Model Evaluation Parameters

##### Inputs:

* Image (Color 299x299)

#### Outputs

* classLabelProbs (String -> Double): Probability of each category
* classLabel (String): Most likely image category

## Skin lesion to determine

|        Skin Lesion         | **Number of images for training** | **Original Size** |
| :------------------------: | :-------------------------------: | :---------------: |
|           Nevus            |               8046                |      10.9 GB      |
|          Melanoma          |               2049                |      5.14 GB      |
| Pigmented Benign Keratosis |               1039                |      279 MB       |
|    Basal Cell Carcinoma    |                566                |      606 MB       |
|    Seborrheic Keratosis    |                419                |      1.47 GB      |

## languages
The app was manually translated to
* 🇺🇸 English (US)
* 🇲🇽 Spanish (MX) (not available)
* 🇪🇸 Catalan (ES) (not available)

## Upcoming Features

* macOS Compatibility with project catalyst
* SearchBar for patient filtering
* Siri Shortcuts
* Translations

## Some Screenshots

| ![alt text](https://user-images.githubusercontent.com/42153044/61669020-42646300-aca4-11e9-913d-cfaec5f3995a.png) | ![alt text](https://user-images.githubusercontent.com/42153044/61669021-42646300-aca4-11e9-9d06-1979d86de7e4.png) | ![alt text](https://user-images.githubusercontent.com/42153044/61612754-05a55700-ac25-11e9-9b91-c9f7ae23302c.png) |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![alt text](https://user-images.githubusercontent.com/42153044/61612752-050cc080-ac25-11e9-9933-69e57f29ac11.png) | ![alt text](https://user-images.githubusercontent.com/42153044/61612755-05a55700-ac25-11e9-94c7-d0a036becf06.png) | ![alt text](https://user-images.githubusercontent.com/42153044/61612756-05a55700-ac25-11e9-9545-7faffd2887c8.png) |
| ![alt text](https://user-images.githubusercontent.com/42153044/61612757-05a55700-ac25-11e9-9220-96a1bbbff892.png) | ![alt text](https://user-images.githubusercontent.com/42153044/61669022-42646300-aca4-11e9-9f7d-02d5ddcebc3b.png) | ![alt text](https://user-images.githubusercontent.com/42153044/61669019-42646300-aca4-11e9-8a61-3fdbf7e19eae.png) |


## Changelog

* Local saving for profile picture
* Added profile picture saved in cloud too
* Added four new skins lesions to determine
* Improved cloud querys
* Improved messages error in login and register
* App not crashes on refresh
* Appoitments are now working in cloud and local
* Views are improved now are responsive and works in iPhone and iPad
* Added food ingested calories and food name in health types
* Interface redisegned from stratch

### Comparative table with old and new HealthApp versions

|        Comparision         |       **Original version**       |                       **New version**                        |
| :------------------------: | :------------------------------: | :----------------------------------------------------------: |
|  Original Dataset images   |            170 images            |                        12,119 images                         |
|   Original Dataset size    |             25.9 Mb              |                           18.37 GB                           |
|   Training model options   |         Melanoma & Nevus         | Nevus, Melanoma, Pigmented Benign Keratosis, Basal Cell Carcinoma and Seborrheic Keratosis |
|     Local saving tool      |               None               |                            Realm                             |
|     Cloud saving tool      |             Firebase             |                           Firebase                           |
| iPhone / iPad adaptability | Partilly in iPhone App (patient) |                Full on patient and doctor app                |

## License

MIT

## Acknowledgements

* [ISC](https://www.isic-archive.com/#!/topWithHeader/wideContentTop/main) For main image data set
* [MED-NODE](http://www.cs.rug.nl/~imaging/databases/melanoma_naevi/)
