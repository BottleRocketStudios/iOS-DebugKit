//
//  Histogram.swift
//  
//
//  Created by Will McGinty on 6/19/21.
//

import Foundation
import SwiftUI
import MetricKit

public struct Histogram<T: Foundation.Unit>: View {

    // MARK: - Entry Subtype
    struct Entry: Identifiable {
        let id = UUID()
        
        let rangeStart: Measurement<T>
        let rangeEnd: Measurement<T>
        let count: Int
        
        func unitValue(relativeTo max: Double) -> Double {
            return Double(count) / max
        }
        
        func formatted(using formatter: MeasurementFormatter) -> String {
            if rangeStart != rangeEnd {
                return "\(formatter.string(from: rangeStart)) - \(formatter.string(from: rangeEnd))"
            }

            return formatter.string(from: rangeStart)
        }
    }

    // MARK: - Preset
    static func displaying<T: Foundation.Unit>(histogram: MXHistogram<T>, withTitle title: String) -> some View {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .providedUnit

        // TODO: The enumeration clears out the values in the histogram, so it can only be viewed once
        let entries: [Histogram<T>.Entry] = histogram.bucketEnumerator.compactMap {
            guard let bucket = $0 as? MXHistogramBucket<T> else { return nil }
            return .init(rangeStart: bucket.bucketStart, rangeEnd: bucket.bucketEnd, count: bucket.bucketCount)
        }

        return Histogram<T>(title: title, entries: entries, formatter: formatter)
    }

    // MARK: - Properties
    let title: String
    let entries: [Entry]
    let formatter: MeasurementFormatter

    @State private var relativePanLocation: CGPoint?
    @State private var currentEntry: Entry?
    @State private var currentLabel: String = ""

    // MARK: - Body
    public var body: some View {
        let maxValue = Double(entries.map(\.count).max() ?? 0)

        if entries.isEmpty {
            Text("nothing!")

        } else {
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .font(.largeTitle)

                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            HStack {
                                let indexedEntries = Array(zip(entries.indices, entries))
                                ForEach(indexedEntries, id: \.0) { index, entry in
                                    let isPanningOver = isPanningOverBar(atIndex: index)
                                    Item(value: entry.unitValue(relativeTo: maxValue), barColors: [.blue, .init(red: 0, green: 0.5, blue: 0.5)])
                                        .opacity(isPanningOver ? 0.8 : 1)
                                        .scaleEffect(isPanningOver ? CGSize(width: 1.05, height: 1.05) : CGSize(width: 1, height: 1), anchor: .bottom)
                                        .animation(.spring())
                                        .padding(.top)
                                }
                            }
                            .gesture(DragGesture(minimumDistance: 0)
                                        .onChanged { self.handlePanChanged(to: $0.location, in: geometry.frame(in: .local), isEnding: false) }
                                        .onEnded { self.handlePanChanged(to: $0.location, in: geometry.frame(in: .local), isEnding: true) })
                        }

                        if let currentEntry = currentEntry {
                            VStack {
                                Text(String(currentEntry.count))
                                    .bold()

                                Text(currentEntry.formatted(using: formatter))
                                    .font(.caption)
                            }
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 5)
                            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(Color(UIColor.secondarySystemBackground)).shadow(radius: 3))
                            .offset(labelOffset(for: currentEntry.unitValue(relativeTo: maxValue), in: geometry.frame(in: .local)))
                            .animation(.spring())
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Gestures
    func handlePanChanged(to location: CGPoint, in frame: CGRect, isEnding: Bool) {
        withAnimation(.spring()) {
            relativePanLocation = CGPoint(x: location.x / frame.width, y: location.y / frame.height)
            guard let pannedIndex = relativePanLocation.map({ Int($0.x * CGFloat(entries.count)) }), pannedIndex < entries.count, pannedIndex >= 0 else { return }

            currentEntry = entries[pannedIndex]
            if isEnding {
                resetPan()
            }
        }
    }

    func resetPan() {
        currentEntry = nil
        relativePanLocation = nil
    }

    // MARK: - Helper
    func labelOffset(for relativeValue: Double, in frame: CGRect) -> CGSize {
        guard let panLocation = relativePanLocation?.x else { return .zero }
        let index = Int(panLocation * CGFloat(entries.count))
        guard index < entries.count && index >= 0 else { return .zero }

        let itemWidth = frame.width / CGFloat(entries.count)
        let actualWidth = frame.width - itemWidth

        return CGSize(width: itemWidth * CGFloat(index) - actualWidth * 0.5,
                      height: (-relativeValue * frame.height))
    }

    func isPanningOverBar(atIndex index: Int) -> Bool {
        guard let panLocation = relativePanLocation else { return false }
        let entryCount = CGFloat(entries.count)

        return panLocation.x > (CGFloat(index) / entryCount)
            && panLocation.x < (CGFloat(index + 1) / entryCount)
    }
}

// MARK: - Item Subtype
private extension Histogram {

    struct Item: View {
        let value: Double
        let barColors: [Color]

        var body: some View {
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient(colors: barColors, startPoint: .bottom, endPoint: .top))
                .scaleEffect(CGSize(width: 1, height: value), anchor: .bottom)
        }
    }
}

// MARK: - Preview
struct Histogram_Previews: PreviewProvider {
    
    private static let formatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .providedUnit
        return formatter
    }()
    
    static var previews: some View {
        Histogram(title: "Title", entries: [.init(rangeStart: .init(value: 0, unit: UnitDuration.milliseconds),
                                                  rangeEnd: .init(value: 9, unit: UnitDuration.milliseconds), count: 10),
                                            .init(rangeStart: .init(value: 10, unit: UnitDuration.milliseconds),
                                                  rangeEnd: .init(value: 19, unit: UnitDuration.milliseconds), count: 7),
                                            .init(rangeStart: .init(value: 20, unit: UnitDuration.milliseconds),
                                                  rangeEnd: .init(value: 29, unit: UnitDuration.milliseconds), count: 14)],
                  formatter: formatter)
            .preferredColorScheme(.dark)
    }
}
