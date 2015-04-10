# WatchKitAzureMobileServiceGetStart
The project shows how Apple Watch app (WatchKit) working together with Azure Mobile Services. 
If you take a look WatchKit architecture, it's not yet possible to create standalone WatchKit app. So we need to create a big iOS app (or so-called parent app) that actually accommodates communication between WatchKit app (or extension) to Azure Mobile Services.

This project is the enhancement of my project here: https://github.com/andriyadi/iOS-Zumo-Sample

I deliberately not changing that project for the sake of focus and history. I need to change the architecture of that project fundamentally so that there will be reusable code that accommodates both iOS app and WatchKit app. All code that's related to accessing Azure Mobile Services is moved to a component called "Engine" so it can be reused between big iOS app and WatchKit extension.
This project's setup on Mobile Services side is similar as that project. 

