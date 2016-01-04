Neeman is an iOS WKWebView wrapper that allows you to quickly integrate a web app into a native app. You can use as much native UI as you like since Neeman can easily be embedded in any project.

It is designed for **native iOS developers** who would like to gain a productivity boost by using an existing web app instead of duplicating it. 

If you are a web developer you might be better served by [Cordova](https://cordova.apache.org/). If you are a Swift or Objective-C developer, or would like to be, keep reading.

Neeman enables you to get up and running fast and work out which elements need to be rebuild using native components. For example, you will probably want to implement the navigation using a UISplitViewController, UITabBarController or UINavigationController. 

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8 or OS X Mavericks (10.9).**
>
> Alamofire is no longer supported on iOS 7 due to the lack of support for frameworks. Without frameworks, running Travis-CI against iOS 7 would require a second duplicated test target. The separate test suite would need to import all the Swift files and the tests would need to be duplicated and re-written. This split would be too difficult to maintain to ensure the highest possible quality of the Alamofire ecosystem.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build Neeman.

To integrate Neeman into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Neeman'
```

Then, run the following command:

```bash
$ pod install
```

## Quickstart

###Step 1
Open your storyboard and select a UIViewController that you would like to show your web app in. Sets its class to WebViewController.

![](README-resources/Step-1.png?raw=true)

###Step 2
Define the URL of the page that it should show.

![](README-resources/Step-2.png?raw=true)

