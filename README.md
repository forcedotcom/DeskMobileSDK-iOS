# desk-kit iOS SDK

The DeskKit SDK is a framework that makes it easy to incorporate your Desk site’s support portal into your iOS app. The SDK supports multiple methods for installing the framework in a project.

### Installation with CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager, which automates and simplifies the process of using 3rd-party libraries in your projects.

You can install it with the following command:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
  pod 'DeskKit', '~> 4.0'
end
```
Then, run the following command:

```bash
$ pod install
```

### Installation with Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate DeskKit SDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "forcedotcom/DeskMobileSDK-iOS" ~> 4.0
```
Run `carthage update` to build the framework and drag the built `DeskKit.framework` into your Xcode project.

**IMPORTANT: Currently we only support prebuilt frameworks. If you run carthage with `--no-use-binaries` option, you will get an error.**

### Installation using prebuilt Framework
Starting with DeskKit SDK version `4.0`, prebuilt frameworks are attached in github releases. In order to use prebuilt frameworks:

1. Download the appropriate version `Frameworks.zip` file from [Releases](https://github.com/forcedotcom/DeskMobileSDK-iOS/releases)
2. Unarchive the zip file  
3. With your project open in Xcode, select your Target. Under General tab, find Embedded Binaries and then click the + button.
4. Click the Add Other... button, navigate to the framework files (`DeskKit.framework`, `DeskAPIClient.framework`, `DeskCommon.framework`) and select them. Check the Destination: Copy items if needed checkbox when prompted.

**IMPORTANT: Attached prebuilt frameworks contain binaries which have been built for a number of architectures `(x86_64, i386, armv7, arm64)`. According to [this radar](http://www.openradar.me/radar?id=6409498411401216) before submission to AppStore you must strip off simulator slices `(x86_64, i386)`.**

## Starting up the Support Portal
Before presenting any support portal view controllers, you must start a `DKSession` to authorize the Desk API:

```
[DKSession startWithHostname:@"yoursite.desk.com"
                    APIToken:@"YOUR_API_TOKEN"];
```

You can obtain an API token in your site’s Admin console by visiting the Settings > API page. You can set up an API Application, and then click on the link for "Your Mobile SDK Token" to obtain the token you need to enter here.

### Configuring Apple’s App Transport Security
If your Support Center’s Security Mode (Admin->Channels->Advanced Settings->Security Mode) is set to ‘HTTP Only’ or ‘Mixed’ you’ll need to configure Apple’s App Transport Security to allow http content via the SDK. If your Security Mode is set to ‘HTTPS Only’ then you can skip the following.
* Open your Info.plist file and add the following:
```	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>yourdomain.desk.com</key>
			<dict>
				<key>NSIncludesSubdomains</key>
				<true/>
				<key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
				<true/>
			</dict>
		</dict>
	</dict>
```
* This will only apply to Desk SDK endpoints and should not affect other web content loaded in your app.


## Presenting Support Portal Topics
The `DeskKitExample` app presents a support portal in a top-level `UISplitViewController`. Of course, how you present your own support portal is up to you. The usual starting point, however, is the `DKTopicsViewController` which is a table-based list of all the support topics in your portal. This view controller also includes a search bar that lets your users search articles.

`DKSession` has a convenience method that allows you to create this controller:

`[DKSession newTopicsViewController]`

You’ll probably want to set yourself as the `DKTopicsViewControllerDelegate` and use a `DKArticleDetailViewController` to show the article. Please refer to the `DeskKitExample` app for an example of how to hook up these two view controllers.

## Presenting Contact Us options
The `DeskKitExample` app also demonstrates one way to present a "Contact Us" action sheet. `DSSession` has a class method to create a pre-configured `UIAlertController` that allows a user to choose whether to email you or call you by phone, depending on which settings you have enabled below. This controller can be instantiated like so:

```
[DKSession newContactUsAlertControllerWithCallHandler:^(UIAlertAction *callAction) {
        [[UIApplication sharedApplication] openURL:[[DKSession sharedInstance] contactUsPhoneNumberURL]];
    } emailHandler:^(UIAlertAction *emailAction) {
        [self alertControllerDidTapEmailUs];
    }];
```
When the user taps "Email Us" you can instantiate and configure an instance of `DKContactUsViewController`:

```
- (void)alertControllerDidTapEmailUs
{
    DKContactUsViewController *contactUsVC = [[DKSession sharedInstance] newContactUsViewController];
    contactUsVC.delegate = self;

    // Configure additional properties of DKContactUsViewController here


    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:contactUsVC];
    nvc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nvc animated:YES completion:nil];
}
```

You can configure which fields to show via the `DeskKitSettings.plist` (see  below) or via properties on your `DKContactUsViewController` instance. Properties set in code have precedence over `DeskKitSettings.plist` settings.

If you already have a name and email for your user, you can pass those to the `DKContactUsViewController` instance via a `DKUserIdentity` object like so:

```
DKUserIdentity *userIdentity = [[DKUserIdentity alloc] initWithEmail:@"users@email.com"];
userIdentity.givenName = @"John";
userIdentity.familyName = @"Doe";
contactUsVC.userIdentity = userIdentity;
```

If the user’s email is not provided via the `userIdentity` property, then a required "Your Email" `UITextfield` will be shown in the form.

### Custom Fields

The Custom Fields you specify through the SDK **must match** the Custom Fields you have defined in your site’s Admin console.

When you create a `DKContactUsViewController` through the `DKSession` singleton, the SDK automatically sets the `customFields` property using the dictionary provided via the `ContactUsStaticCustomFields` key of the DeskKit Settings (see below). You can further modify the `customFields` property at runtime.

```
// Grab initial custom fields populated from DeskKitSettings.plist
NSMutableDictionary *customFields = [contactUsVC.customFields mutableCopy];
// Add your own dynamic custom fields.
[customFields addEntriesFromDictionary:[self dynamicCustomFields]];
// Assign back to property.
contactUsVC.customFields = customFields;
```

The `customFields` dictionary you specify will be sent along when your customer taps Send in the `DKContactUsViewController`.

## DeskKit Settings
The following items can be customized in the support portal (all  settings are optional and can be omitted if desired). To do so, copy the existing `DeskKitSettings-Example.plist` file in this repository, and rename it to `DeskKitSettings.plist`. The following (optional) keys can be set:
* **ContactUsEmailAddress** - By default the SDK will check your list of inbound email addresses set up in your site admin and use the first one it finds. Use this setting if you would like to override that with an email address of your choosing.
* **ContactUsPhoneNumber** - If desired, you may provide a phone number that will allow users of your app to call you directly from the support portal. If omitted, this ‘Call Us’ option will not be available. The ‘Call Us’ option will also not be available if device cannot make phone calls.
* **ContactUsSubject** - By default the SDK uses a subject of "Feedback via iOS app" for emails sent through the `DKContactUsViewController`. You can override this string through this key. You can also specify the email subject in code through the `subject` property on `DKContactUsViewController`.
* **ContactUsShowSubjectItem** - Default is NO. The subject field in the Contact Us form is optional. Change this value to YES if you want to allow the user to see/edit the subject. You can also override this in code via the `showSubjectItem` property on ``DKContactUsViewController`.
* **ContactUsShowYourNameItem** - Default is NO. The user’s full name field in the Contact Us form is optional. Change this value to YES if you want to allow the user to see/edit the full name sent through the form. You can set an initial value for the user’s name through the `userIdentity` property on `DKContactUsViewController`.
* **ContactUsShowAllOptionalItems** - Default is NO. Setting this to YES is equivalent as setting `ContactUsShowSubjectItem` and `ContactUsShowYourNameItem` to YES.
* **ContactUsShowYourEmailItem** - Default is NO. Since the user’s email address is required, this toggle only has an effect when the email has been set through the `userIdentity` property on `DKContactUsViewController`. Change this value to YES if you want to allow the user to edit the email address set through `userIdentity`.
* **ContactUsStaticCustomFields** - The value is a dictionary with keys that must match the custom fields defined in your site’s Admin console. This dictionary is used to initialize the `customeFields` property of `DKContactUsViewController`.
* **BrandId** - If you use multiple brands, you may provide a brand id here that will limit the portal to only those topics and articles in that brand. If you omit this setting, the portal will display *all* topics and articles in your support center. Brand ids can be obtained by going to your site’s admin, clicking *Channels*, and then *Brand Overview*. Select the brand you’d like in the dropdown at the upper-right, and then the brand id will be shown in the support center URL. For example, in this support center URL, "https://mysite.desk.com/?b_id=2", the brand id is 2.

## DeskKitExample app
We have provided an example app to show how the above might work in your app. Here’s how to set it up and run it:

1. From the root of the `desk-kit` directory, `cd DeskKitExample`
1. `pod install`
1. `cp DeskKitExample/DeskKitSettings-Example.plist DeskKitExample/DeskKitSettings.plist`
1. `open ./DeskKitExample.xcworkspace`
1. In Xcode, open the `AppDelegate.m` file and enter your hostname and API token in:
```
[DKSession startWithHostname:@"yoursite.desk.com"
                        APIToken:@"YOUR_API_TOKEN"];
```
1. In Xcode, edit `DeskKitExample/Supporting Files/DeskKitSettings.plist` to set your settings as above, if desired.
1. In Xcode, choose Product > Run, or type ⌘R to run the app.

