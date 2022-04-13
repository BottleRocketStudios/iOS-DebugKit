# Integrating Wormholy

DebugKit does not come with Wormholy as a dependency, though it is very simple to integrate into the `DebugOptionsViewController`.

## Integrating the Framework

It is up to you to determine exactly how to pull the Wormholy framework into your project. Currently, both Cocoapods and Carthage are supported (see [here](https://github.com/pmusolino/Wormholy) for details).

## Adding the `DebugOption`

Once the framework is integrated, it is simple to add a new `DebugOption` that displays Wormholy's network traffic monitoring interface. One example is using the `Presentation` case of `DebugOption`, like below:

```swift
import DebugKit
import Wormholy

extension DebugOption.Item {

    public static func wormholy() -> Self {
        guard let wormholyViewController = Wormholy.wormholyFlow else {
            return .informational(title: "Wormholy not available")
        }

        return .modalPresentation(title: "Network Traffic", destination: wormholyViewController)
    }
}
```

The extension below will return a fallback informational item when Wormholy is not available. However, when Wormholy is available it will modally present it on top of the `DebugOptionsViewController`. Wormholy provides a `UIViewController` instance back, so the `modalPresentationStyle` and `modalTransitionStyle` can be customized if desired.

Note that because Wormholy nests it's content inside a `UINavigationController`, you will not be able to present this navigationally inside your `DebugOptionsViewController`s main navigation stack.

![An example implementation of debug menu](./Images/DebugMenu.png)
![An example of presenting Wormholy from the debug menu](./Images/WormholyUI.png)

## Disabling Shake to Present

The default way to use Wormholy is through a shake gesture - in the case you are implementing Wormholy into your `DebugOptionsViewController`, you may also want to disable the shake gesture that is used by default. This can be done by adding an environment variable: `WORMHOLY_SHAKE_ENABLED` = `NO`.
