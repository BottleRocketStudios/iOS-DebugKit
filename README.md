# DebugKit

![CI Status](https://github.com/BottleRocketStudios/iOS-DebugKit/actions/workflows/main.yml/badge.svg)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/bottlerocketstudios/iOS-DebugKit)
[![License](https://img.shields.io/github/license/bottlerocketstudios/iOS-DebugKit)](LICENSE)

DebugKit is designed to make it as simple as possible to build and display useful information about your project. It was built to replace all the individual debugging view controllers, making it easy to use the functionality that is needed in your specific use case, without the need to write it yourself. The framework includes a simple way to build a `DebugOptionsViewController` (or `DebugOptionsView` in SwiftUI), containing a variety of debugging related information.

To utilize `DebugOptionsViewController`, the first step is instantiation:

```swift
let viewController = DebugOptionsViewController()
```

This is the simplest way to create a new view controller, but there are a multitude of appearance customization options available as part of the initializer. The view controller is currently created on its own, without a `UINavigationController`, so if the contents of your debug options will require navigation it must be nested in a `UINavigationController` or `NavigationView`.

Once you have the view controller, the only remaining step is populating it with the data you wish to see - this can be accomplished with a single call to `configure`.

```swift
viewController.configure(with: [.init(section: .init(title: "General"),
                                        items: [.version(for: .main), .build(for: .main), .pushToken(with: pushService.deviceToken, title: "Push Token")]),
                                .init(section: .init(title: "Debug"),
                                        items: [.crashTest()]),
                                .init(section: .init(title: "Logs"),
                                        items: [.log(for: "Metrics", logService: metricsLogService), .log(for: "Notifications", logService: notificationsLogService)]))
```

There are a variety of built in `DebugOption` presets, including displaying a build / version number, as well as a device APNs token. For custom actions, it is very easy to extend `DebugOption`. There are three types of `DebugOption` - action, selection and presentation.

- Action: Selection of this item invokes some kind of action determined by a handler
- Selection: Selection of this item updates the selected state of the menu, useful for things like an environment picker
- Presentation: Selection of this item causes either a navigation push or modal presentation to a given view controller

To implement the `crashTest()` item above, for example, would involve the following:

```swift
extension DebugOption.Item {

    public static func crashTest() -> Self {
        return .action(title: "Crash") { fatalError("Testing a crash!") }
    }
}
```

### Logging

In addition to simple action and selection items, the `DebugItem` is designed to work seamlessly with another capability of `DebugKit` - the `LogService`. This service is designed to record instances of any object, writing them to disk and displaying them in the `DebugViewController` on demand.

The `LogService` works with any type that conforms to the `Recordable` protocol, allowing entries in this log to be visually displayed using SwiftUI. These logs can be in memory only, or optionally written to some persistent storage if desired. The `LogService` will accept any item conforming to `LogStoring` upon initialization, and a default `LogFileStorage` is provided by the framework.

For example, if you wanted to keep a log of the `MXMetricPayload` the OS delivers to your app over the course of a few days, you could construct a `LogService<MXMetricPayload>`, using the provided convenience method:

```swift
// Create the log service (with optional file storage)
let metricLogService = LogService<MXMetricPayload>.metricPayloads(storedAt: myOptionalURL)

// then conform to MXMetricManagerSubscriber to append to the log
func didReceive(_ payloads: [MXMetricPayload]) {
    payloads.forEach(logService.append)
}
```

By default, the log's entries will persist for 1 week from recording, although this is customizable through the `LogService.expirationInterval` property. Once the time comes to display this log in a `DebugOptionsViewController` (or `DebugOptionsView`), this can be done using another convenience function on `DebugOption` where it can easily be added to a `DebugOptionsViewController`:

```swift
let option = DebugOption.log<T>(for: "Title", logService: metricLogService)
```

## Example

To run the example project, clone this repo and open `DebugKit.xcworkspace`.


## Requirements

Requires iOS 14.0


## Installation

### Swift Package Manager

Add this to your project using Swift Package Manager. In Xcode: File > Swift Packages > Add Package Dependency... and you're done. Alternative installations options are shown below for legacy projects.

### Carthage

Add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "BottleRocketStudios/iOS-DebugKit"
```

Run `carthage update` and follow the steps as described in Carthage's [README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).


## Author

[Bottle Rocket Studios](https://www.bottlerocketstudios.com/)


## License

DebugKit is available under the Apache 2.0 license. See [the LICENSE file](LICENSE) for more information.


## Contributing

See the [CONTRIBUTING] document. Thank you, [contributors]!

[CONTRIBUTING]: CONTRIBUTING.md
[contributors]: https://github.com/BottleRocketStudios/iOS-DebugKit/graphs/contributors
