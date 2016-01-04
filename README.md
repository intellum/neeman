#Neeman
##Turn a web app into a great native user experience.

Web apps just can't compete with native navigation. We can use the strengths or both though.

<img src="README-resources/Navigation.gif?raw=true" width="540" height="294" />


Neeman is an [WKWebView](https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKWebView_Ref/) wrapper that allows you to quickly integrate a web app into a native iOS app. When the user clicks on a link another web view is pushed onto the [UINavigationController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UINavigationController_Class/) stack.

You can easily hide elements that you would like to implement natively. For example, you can hide the "hamburger menu" and implement the navigation using a [UITabBarController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITabBarController_Class/) instead. You can also inject javascript which can call back out to your code. 

Neeman is designed for **native iOS developers** who would like to gain a productivity boost by using an existing web app instead of duplicating it. Neemans goal is to help you turn a web app into a native iOS app with a great user experience.

If you are a web developer you might be better served by [Cordova](https://cordova.apache.org/). If you are a Swift or Objective-C developer, or would like to be, keep reading.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
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

<img src="README-resources/Step-1.png?raw=true" width="260" height="108" />

###Step 2
Define the URL of the page that it should show.

<img src="README-resources/Step-2.png?raw=true" width="260" height="80" />

