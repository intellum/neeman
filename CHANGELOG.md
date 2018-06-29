## [1.1.1](https://github.com/intellum/neeman/releases/tag/1.1.1)
#### Updated
- Remove the NeemanSettings.
- Refactored some code out of the WebViewController.
- Update the examples for swift 4.2.

## [1.1.0](https://github.com/intellum/neeman/releases/tag/1.1.0)
#### Updated
- Improved the pull to refresh bahaviour with the iOS 11 navigation bar.
- Improved network activity handling for UI testing.
- Added "Mobile/" to the user agent. I found a javascript library that, however ill-advised, was assuming the existance of this to detect iOS.

## [1.0.0](https://github.com/intellum/neeman/releases/tag/1.0.0)
#### Updated
- Now using Swift 4
- Improved network activity handling.
- Removed FastClick.
- Add the app's version to the user agent.

## [0.5.0](https://github.com/intellum/neeman/releases/tag/0.5.0)
#### Updated
- Now using Swift 3
- Supports printing using window.print()
- Allow alert() from subdomains.

## [0.4.1](https://github.com/intellum/neeman/releases/tag/0.4.1)
#### Updated
- Decoupled the `WebViewController`'s `createNewWebViewController` so we can override it to create view controllers that don't extend `WebViewController`.
- Implemented state restoration.
- Changed `shouldForcePushOfNewNavigationAction` to `shouldForcePushOfNavigationAction` for consistency.
- Inject an HTML class that is specific to the version of the app. i.e. `neeman-hybrid-app-version-[version]`.

## [0.4.0](https://github.com/intellum/neeman/releases/tag/0.4.0)
#### Updated
- Change delegate methods to use the navigation action instead of just the request.

## [0.3.0](https://github.com/intellum/neeman/releases/tag/0.3.0)
#### Updated
- Changed Settings to NeemanSettings to reduce the likelihood of a naming clash.
- Fixed a bug that was breaking the unit tests.
- Fixed a bug where the `shouldPushNewWebViewForRequest` delegate method was not always called.
- Updated to swift 2.2 syntax.
- Made `activityIndicator` and `progressView` public so they can be overridden.

## [0.2.8](https://github.com/intellum/neeman/releases/tag/0.2.8)
#### Updated
- Changed `rootAbsoluteURLString` to `absoluteURLString`.
- Cleaned up the reloading on viewWillAppear by adding a `shouldReloadOnViewWillAppear` method that can be overridden.
- Disallow .Other navigationActions to prevent an infinite loop of navigations.

## [0.2.7](https://github.com/intellum/neeman/releases/tag/0.2.7)
#### Added

- Added better http error messages.
- Added a delegate method to cancel a navigation.

#### Updated
- Made the refresh method public.

## [0.2.6](https://github.com/intellum/neeman/releases/tag/0.2.6)
#### Updated
- Changed the class that is added to the HTML tag to indicated that the page is inside a Neeman web view, from 'hybrid' to 'neeman-hybrid-app'.

## [0.2.5](https://github.com/intellum/neeman/releases/tag/0.2.5)
#### Updated
- Fixed a bug with the delegate method for preventing a navigation stack push.
- Changed `shouldForcePushOfNewWebView(request: NSURLRequest)` to `shouldForcePushOfNewRequest(request: NSURLRequest)`. 

## [0.2.4](https://github.com/intellum/neeman/releases/tag/0.2.4)
#### Updated
- Changed `rootURLString` to `URLString`.
- Fixed some bugs.
- Added a basic example.

## [0.2.3](https://github.com/intellum/neeman/releases/tag/0.2.3)

#### Updated
- Support Carthage: Include the resources in the framework build.
- Remove some CSS that was specific to Intellum projects. 

## [0.2.2](https://github.com/intellum/neeman/releases/tag/0.2.2)

#### Updated
- Included more detail about how to inject javascript and CSS.
- Cleaned up the example project a bit.

