# desk-kit iOS SDK

The DeskKit SDK is a framework that makes it easy to incorporate your Desk site’s support portal into your iOS app. The SDK can be installed as a framework, along with its dependencies, but it is much easier to install it via Cocoapods:

```
pod 'DeskKit', '~> 1.2.2'
```

## Starting up the Support Portal
Before presenting any support portal view controllers, you must start a `DKSession` to authorize the Desk API:

```
[DKSession startWithHostname:@“yoursite.desk.com”
                    APIToken:@“YOUR_API_TOKEN”];
```

You can obtain an API token in your site’s Admin console by visiting the Settings > API page. You can set up an API Application, and then click on the link for “Your Mobile SDK Token” to obtain the token you need to enter here.

## Presenting Support Portal Topics
The `DeskKitExample` app presents a support portal in a top-level `UISplitViewController`. Of course, how you present your own support portal is up to you. The usual starting point, however, is the `DKTopicsViewController` which is a table-based list of all the support topics in your portal. This view controller also includes a search bar that lets your users search articles.

`DKSession` has a convenience method that allows you to create this controller:

`[DKSession newTopicsViewController]`

## Presenting Contact Us options
The `DeskKitExample` app also demonstrates one way to present a “Contact Us” action sheet. `DSSession` has a class method to create a pre-configured `UIAlertController` that allows a user to choose whether to email you or call you by phone, depending on which settings you have enabled below. This controller can be instantiated like so:

```
[DKSession newContactUsAlertControllerWithCallHandler:^(UIAlertAction *callAction) {
        [[UIApplication sharedApplication] openURL:[[DKSession sharedInstance] contactUsPhoneNumberURL]];
    } emailHandler:^(UIAlertAction *emailAction) {
        [self alertControllerDidTapEmailUs];
    }];
```
When the user taps “Email Us” you can instantiate and configure an instance of `DKContactUsViewController`:

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
DKUserIdentity *userIdentity = [[DKUserIdentity alloc] initWithEmail:@“users@email.com”];
userIdentity.givenName = @“John”;
userIdentity.familyName = @“Doe”;
contactUsVC.userIdentity = userIdentity;
```

If the user’s email is not provided via the `userIdentity` property, then a required “Your Email” `UITextfield` will be shown in the form.

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
* **NavigationBar** - This is a dictionary that points to another child dictionary that defines the colors for the navigation bar. The keys in the child dictionary are:
  * **TintColorRGBA** - This is a dictionary that defines the Red, Green, Blue, and Alpha values for your navigation bar’s tint color (the color of the title and button text in the bar). RGB values are 0-255, while Alpha is a floating point number between 0 and 1.
  * **BarTintColorRGBA** - This is a dictionary that defines the Red, Green, Blue, and Alpha values for your navigation bar’s bar tint color (the background color of the bar). RGB values are 0-255, while Alpha is a floating point number between 0 and 1.
* **TopNavIconFileName** - This is the filename of an icon to place in the navigation bar beside its title. You must add the image asset to your project first. For best results, use a square image approximately 33 x 33 pixels at 1x resolution.
* **ContactUsEmailAddress** - By default the SDK will check your list of inbound email addresses set up in your site admin and use the first one it finds. Use this setting if you would like to override that with an email address of your choosing.
* **ContactUsPhoneNumber** - If desired, you may provide a phone number that will allow users of your app to call you directly from the support portal. If omitted, this ‘Call Us’ option will not be available. The ‘Call Us’ option will also not be available if device cannot make phone calls.
* **ContactUsSubject** - By default the SDK uses a subject of “Feedback via iOS app” for emails sent through the `DKContactUsViewController`. You can override this string through this key. You can also specify the email subject in code through the `subject` property on `DKContactUsViewController`.
* **ContactUsShowSubjectItem** - Default is NO. The subject field in the Contact Us form is optional. Change this value to YES if you want to allow the user to see/edit the subject. You can also override this in code via the `showSubjectItem` property on ``DKContactUsViewController`.
* **ContactUsShowYourNameItem** - Default is NO. The user’s full name field in the Contact Us form is optional. Change this value to YES if you want to allow the user to see/edit the full name sent through the form. You can set an initial value for the user’s name through the `userIdentity` property on `DKContactUsViewController`.
* **ContactUsShowAllOptionalItems** - Default is NO. Setting this to YES is equivalent as setting `ContactUsShowSubjectItem` and `ContactUsShowYourNameItem` to YES.
* **ContactUsShowYourEmailItem** - Default is NO. Since the user’s email address is required, this toggle only has an effect when the email has been set through the `userIdentity` property on `DKContactUsViewController`. Change this value to YES if you want to allow the user to edit the email address set through `userIdentity`.
* **ContactUsStaticCustomFields** - The value is a dictionary with keys that must match the custom fields defined in your site’s Admin console. This dictionary is used to initialize the `customeFields` property of `DKContactUsViewController`.
* **BrandId** - If you use multiple brands, you may provide a brand id here that will limit the portal to only those topics and articles in that brand. If you omit this setting, the portal will display *all* topics and articles in your support center. Brand ids can be obtained by going to your site’s admin, clicking *Channels*, and then *Brand Overview*. Select the brand you’d like in the dropdown at the upper-right, and then the brand id will be shown in the support center URL. For example, in this support center URL, “https://mysite.desk.com/?b_id=2”, the brand id is 2.

## DeskKitExample app
We have provided an example app to show how the above might work in your app. Here’s how to set it up and run it:

1. From the root of the `desk-kit` directory, `cd DeskKitExample`
1. `pod install`
1. `cp DeskKitExample/DeskKitSettings-Example.plist DeskKitExample/DeskKitSettings.plist`
1. `open ./DeskKitExample.xcworkspace`
1. In Xcode, open the `AppDelegate.m` file and enter your hostname and API token in:
```
[DKSession startWithHostname:@“yoursite.desk.com”
                        APIToken:@“YOUR_API_TOKEN”];
```
1. In Xcode, edit `DeskKitExample/Supporting Files/DeskKitSettings.plist` to set your settings as above, if desired.
1. In Xcode, choose Product > Run, or type ⌘R to run the app.
