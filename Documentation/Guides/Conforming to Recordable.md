# Conforming to Recordable

There are two common ways in which a new type can be conformed to `Recordable`.

## Defining `Self` as `Recordable`

Every type that conforms to `Recordable` has an associated type `Record`, which by default, points to `Self`. In these cases, the `LogService` will be looking for `some SwiftUI.View` in which the content of `Self` can be displayed in the log. Conformance in these situations is as simple as the `View` that displays the content is. A simple example would be as follows:

```swift
public struct GeofenceEntry {

    public enum Event {
        case enter, exit
    }

    public let event: Event
    public let geofence: Geofence
}
```

Conforming this type to `Recordable` is straightforward, and has two requirements - an identifier and a view. A valid conformance may look something like:

```swift
public struct GeofenceEntry: Recordable {

    public enum Event: String {
        case enter, exit
    }
    
    public let id = UUID() // Add a unique identifier for this record
    public let event: Event
    public let geofence: Geofence
    
    // Create a SwiftUI view representation of this record
    public static func view(for entry: Log<GeofenceEntry>.Entry) -> some View {
        VStack {
            Text(entry.date, style: .date)
            Text(entry.element.event.rawValue)
            Text(entry.element.geofence.description)
        }
    }
}
```

The view can be as simplex or complex as needed, but will be rendered inside a `List` so scrolling performance may become a concern. It is also possible to utilize `UIViewRepresentable` here to use a `UIView` object, meaning that while `SwiftUI` is required for rendering, it is *not* required that a types `RecordView` is built in `SwiftUI`.

## Forwarding to a `Recordable` Property

Often times it becomes necessary to wrap a type inside another. In cases where this wrapped type is already `Recordable`, it is very easy to forward that conformance on to the wrapper object. Suppose we have the following set up, and we want to use `Geofence` conformance in our `GeofenceEntry` type:

```swift
public struct Geofence: Recordable, CustomStringConvertible {

    public let id = UUID()
    public var description: String { return id.uuidString }

    public static func view(for entry: Log<Geofence>.Entry) -> some View {
        VStack {
            Text(entry.date, style: .date)
            Text(entry.element.description)
        }
    }
}

public struct GeofenceEntry {

    public enum Event {
        case enter, exit
    }

    public let event: Event
    public let geofence: Geofence
}
```

In order to conform `GeofenceEntry` to `Recordable`, you can simply forward the request for a `View` to the `Geofence`:

```swift
public struct GeofenceEntry: Recordable {
    public enum Event: String {
        case enter, exit
    }

    public let id = UUID()
    public let event: Event
    public let geofence: Geofence

    public var record: Geofence {
        return geofence
    }

    public static func view(for entry: Log<Geofence>.Entry) -> some View {
       return Geofence.view(for: entry)
    }
}
```

The implementation of `record` tells the `LogService` how to find the object you want to display, and then that type can handle the request for a `View`.

### Hybrid

In addition to the individual methods described above, it is also possible to combine them. The `view(for entry: Log<Record>.Entry)` is a `@ViewBuilder`, allowing you to both define a new view for a `Recordable` type and utilize an existing `Recordable.LogView`. For example:

```swift
public struct GeofenceEntry: Recordable {
  
    // rest of implementation ...

    public static func view(for entry: Log<GeofenceEntry>.Entry) -> some View {
        VStack {
            Text(entry.date, style: .date)
            Text(entry.element.event.rawValue)
            Geofence.view(for: entry.map(\.geofence))
        }
    }
}
```
