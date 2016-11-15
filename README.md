# TangoIndoorMapApp
iOS indoor map app for Aalto University

## Demo
[![Demo](/README_images/demo.png)](https://www.youtube.com/watch?v=D2wqsXd8nsY)

## Requirements
* Mac
* Xcode 8+
* iOS 10
* Mapbox API token

## Installation
This repo has all the dependencies. Just install Xcode 8, add your Mapbox API token and you are good.

## Mapbox API token
Mapbox API token is necessary for obtaining an access to Mapbox data. The token is a private property and thus **MUST NOT** be included in the repo.
The token should be stored in `project_root/PrivateKeys/` and the file name should be `mapbox_token`. Any file in `project_root/PrivateKeys/` is *git ignored*.

Here's an example project structure:

![project structure](/README_images/project structure.png)

## Dependencies
* Mapbox-iOS-SDK 3.3.6
* SwiftyJSON 3.1.1
* SwiftyBeaver 1.1.1 (logger)
* Toast-Swift 2.0.0 (Toast views)

Never ever git ignore `Pods/`. Don't trust StackOverflows. You might not be able to install old version of the dependencies.

## Swift 4? 5? 6?
This project was initially developed in Swift 2.3 and is upgraded to Swift 3. Next year it will be Swift 4. Swift upgrade is a disaster and it's bigger than Trump. I recommend you this [Tweet](https://twitter.com/cocoaphony/status/794988795208802305?utm_campaign=This%2BWeek%2Bin%2BSwift&utm_medium=email&utm_source=This_Week_in_Swift_109):
1. remove everything from target
2. add models
3. build up.

Here's my personal tip:
1. Don't use a migrator.
2. Update Pods.
3. Change old Swift production code(code you wrote) syntaxes manually.

## Credit
* [Jonathan Granskog](https://twitter.com/JonathanGranskg): Floor plan conversion
* [Seyoung Park](http://seyoung.xyz/ios/2016/09/26/tangoAalto/): iOS developer
* Juho Kannala: Professor
