# desk-kit iOS SDK

DISCLAIMER: The DeskKit SDK is in Private Customer Pilot. It does not work out-of-box without a prior arrangement with the Desk.com product team. If you are interested in participating in the Private Customer Pilot, please send an email to jpappas@salesforce.com.

The DeskKit SDK is a framework that makes it easy to incorporate your Desk site’s support portal into your iOS app. The SDK can be installed as a framework, along with its dependencies, but it is much easier to install it via Cocoapods:

```
pod ‘DeskKit’, :git => 'https://github.com/forcedotcom/DeskMobileSDK-iOS'
```

The open-source `DeskAPIClient` and `DeskCommon` are dependencies, and can also be installed via Cocoapods:

```
pod 'DeskAPIClient', :git => 'git@github.com:forcedotcom/DeskApiClient-ObjC', :tag => '1.0.6'
pod 'DeskCommon', :git => 'git@github.com:forcedotcom/DeskCommon-Cocoa', :tag => '1.0.3'
```

## Starting up the Support Portal
Before presenting any support portal view controllers, you must start a `DKSession` to authorize the Desk API:

```
[DKSession start:@“sitename.desk.com”
        apiToken:@“YOUR-API-TOKEN”];
```

You can obtain an API token in your site’s Admin console by visiting the Settings > API page. You can set up an API application, and then click on the link for “Your Mobile SDK Token” to obtain the token you need to enter here.

## Presenting Support Portal Topics
The `DeskKitExample` app presents a support portal in a top-level `UISplitViewController`. Of course, how you present your own support portal is up to you. The usual starting point, however, is the `DKTopicsViewController` which is a table-based list of all the support topics in your portal. This view controller also includes a search bar that lets your users search articles.

`DKSession` has a convenience method that allows you to create this controller:

`[DKSession newTopicsViewController]`

## Presenting Contact Us options
The `DeskKitExample` app also demonstrates one way to present a “Contact Us” action sheet. The `DKContactUsAlertController` is an action sheet in which your users can choose whether to email you or call you by phone, depending on which settings you have enabled below. This controller can be instantiated like so:

`[DKContactUsAlertController contactUsAlertController]`

When the user taps “Email Us” you can either show an `MFMailComposeViewController`, using the contact us email address in your session:

`[DKSession sharedInstance].contactUsEmailAddress`

Or you can present a `DKContactUsWebViewController`, which will show the contact us form from your support portal.

## DeskKit Settings
The following items can be customized in the support portal (all  settings are optional and can be omitted if desired). To do so, copy the existing `DeskKitSettings-Example.plist` file in this repository, and rename it to `DeskKitSettings.plist`. The following (optional) keys can be set:
* **NavigationBar** - This is a dictionary that points to another child dictionary that defines the colors for the navigation bar. The keys in the child dictionary are:
  * **TintColorRGBA** - This is a dictionary that defines the Red, Green, Blue, and Alpha values for your navigation bar’s tint color (the color of the title and button text in the bar). RGB values are 0-255, while Alpha is a floating point number between 0 and 1.
  * **BarTintColorRGBA** - This is a dictionary that defines the Red, Green, Blue, and Alpha values for your navigation bar’s bar tint color (the background color of the bar). RGB values are 0-255, while Alpha is a floating point number between 0 and 1.
* **TopNavIconFileName** - This is the filename of an icon to place in the navigation bar beside its title. You must add the image asset to your project first. For best results, use a square image approximately 33 x 33 pixels at 1x resolution.
* **ContactUsEmailAddress** - By default the SDK will check your list of inbound email addresses set up in your site admin and use the first one it finds. Use this setting if you would like to override that with an email address of your choosing.
* **ContactUsPhoneNumber** - If desired, you may provide a phone number that will allow users of your app to call you directly from the support portal. If omitted, this ‘Call Us’ option will not be available.
* **ShowContactUsWebForm** - If desired, instead of the contact us email button opening a generic iOS email sheet, you can set this setting to YES and use this value in code to conditionally show your portal’s contact us form in a web view.
* **BrandId** - If you use multiple brands, you may provide a brand id here that will limit the portal to only those topics and articles in that brand. If you omit this setting, the portal will display *all* topics and articles in your support center. Brand ids can be obtained by going to your site’s admin, clicking *Channels*, and then *Brand Overview*. Select the brand you’d like in the dropdown at the upper-right, and then the brand id will be shown in the support center URL. For example, in this support center URL, “https://mysite.desk.com/?b_id=2”, the brand id is 2.

## DeskKitExample app
We have provided an example app to show how the above might work in your app. Here’s how to set it up and run it:

1. From the root of the `desk-kit` directory, `cd DeskKitExample`
1. `bundle exec pod install`
1. `cp DeskKitExample/DeskAPIAuth-Example.plist DeskKitExample/DeskAPIAuth.plist`
1. `cp DeskKitExample/DeskKitSettings-Example.plist DeskKitExample/DeskKitSettings.plist`
1. `open ./DeskKitExample.xcworkspace`
1. In Xcode, edit `DeskKitExample/Supporting Files/DeskAPIAuth.plist` to include your app's hostname and api token. To obtain this token, you must first set up an API application in your Desk site’s admin settings, and click on the “Mobile SDK Token” link to obtain your token.
1. In Xcode, edit `DeskKitExample/Supporting Files/DeskKitSettings.plist` to set your settings as above, if desired.
1. In Xcode, choose Product > Run, or type ⌘R to run the app. The app should build and run, and when you hit the "Support" tab it should show a list of topics from your site.
