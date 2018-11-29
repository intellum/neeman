<img src="http://intellum.github.io/neeman/images/Logo.png" width="320" height="64" />

[![Build Status](https://travis-ci.org/intellum/neeman.svg)](https://travis-ci.org/intellum/neeman)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/Neeman.svg)](http://cocoadocs.org/docsets/Neeman)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Neeman.svg)](https://img.shields.io/cocoapods/v/Neeman.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Neeman.svg?style=flat)](http://cocoadocs.org/docsets/Neeman)
[![License](https://img.shields.io/cocoapods/l/Neeman.svg?style=flat)](https://raw.githubusercontent.com/intellum/neeman/master/LICENSE)

Neeman is about choosing your battles. Spend your time working on things that make a great app and let web views do what they are good at: displaying content, sharing code between platforms and remaining updatable after app store submission.

## Turn a web app into a great native user experience.

Javascript in WKWebView is really fast and many things can now be done in web view, but some things just can't compete with native. Take, for example, the beautiful transitions provided by UINavigationController.

<img src="http://intellum.github.io/neeman/images/Navigation.gif" width="540" height="294" />


Neeman is a [WKWebView](https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKWebView_Ref/) wrapper that allows you to quickly integrate a web app into a native iOS app. When a link is tapped, another web view is pushed onto the [UINavigationController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UINavigationController_Class/) stack.

You can easily hide elements that you would like to implement natively. For example, a "hamburger menu" can be hidden with CSS. The navigation can then be replaced by a [UITabBarController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITabBarController_Class/). You can also easily inject javascript which can call back out to your code. 

Neeman is designed for **native iOS developers** who would like to gain a productivity boost by using an existing web app instead of duplicating it. Neemans goal is to help you turn a web app into a native iOS app with a great user experience.

If you are a web developer you might be better served by [Cordova](https://cordova.apache.org/). If you are a Swift developer, or would like to be, keep reading.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

#### Try

You can try Neeman with the following command:

```bash
$ pod try Neeman
```

#### Integration

To integrate Neeman into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'Neeman'
```

Then, run the following command:

```bash
$ pod install
```

## Quickstart

### Step 1
Open your storyboard and select a UIViewController that you would like to show your web app in. Sets its class to WebViewController.

<img src="http://intellum.github.io/neeman/images/Step-1.png" width="260" height="108" />

### Step 2
Define the URL of the page that it should show.

<img src="http://intellum.github.io/neeman/images/Step-2.png" width="260" height="80" />

## Customisation
<img src="http://intellum.github.io/neeman/images/ProjectNavigator.png" width="260" height="356" />

### WebView.css
Put CSS in here to hide elements that you intend to replace with native controls. You would hide a menu, for example, by adding

```CSS
nav {
    display: none;
}

```

### AtDocumentEnd.js
Put javascript in here that should be injected after the document has loaded. The following is from the Github example that gets the current username from the meta tag.

```javascript
(function(){
 var metaTags=document.getElementsByTagName("meta");

 var username = "";
 for (var i = 0; i < metaTags.length; i++) {
    if (metaTags[i].getAttribute("name") == "octolytics-actor-login") {
        username = metaTags[i].getAttribute("content");
        break;
    }
 }
 webkit.messageHandlers.didGetUserName.postMessage(username);
})();
```
