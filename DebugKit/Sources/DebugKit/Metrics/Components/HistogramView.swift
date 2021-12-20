//
//  Histogram.swift
//  
//
//  Created by Will McGinty on 6/19/21.
//

import Foundation
import SwiftUI
import MetricKit

struct HistogramView<T: Foundation.Unit>: View {

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
    static func displaying<T: Foundation.Unit>(histogram: Histogram<T>, withTitle title: String, using formatter: MeasurementFormatter) -> some View {
        let entries: [HistogramView<T>.Entry] = histogram.buckets.map { .init(rangeStart: $0.start, rangeEnd: $0.end, count: $0.count) }
        return HistogramView<T>(entries: entries, formatter: formatter, barColors: [.blue, .green])
                .navigationTitle(title)
    }

    // MARK: - Properties
    let entries: [Entry]
    let formatter: MeasurementFormatter
    let barColors: [Color]

    @State private var relativePanLocation: CGPoint?
    @State private var currentlyPannedEntry: Entry?

    // MARK: - View
    var body: some View {
        let maxValue = Double(entries.map(\.count).max() ?? 0)

        if entries.isEmpty {
            NoEntriesView(configuration: .default)

        } else {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    VStack {
                        LinearGradient(colors: barColors, startPoint: .bottom, endPoint: .top)
                            .mask(
                                VStack {
                                    Spacer(minLength: geometry.size.height * 0.1)
                                    HStack(alignment: .bottom) {
                                        ForEach(Array(zip(entries.indices, entries)), id: \.0) { index, entry in
                                            itemView(for: entry, at: index, relativeTo: maxValue, withMaxHeight: geometry.size.height * 0.85)
                                        }
                                    }
                                }
                                    .padding()
                            )
                    }

                    if let currentEntry = currentlyPannedEntry {
                        currentlySelectedView(for: currentEntry,
                                                 with: labelOffset(for: currentEntry.unitValue(relativeTo: maxValue),
                                                                      in: geometry.frame(in: .local)))
                    }
                }
                .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { self.handlePanChanged(to: $0.location, in: geometry.frame(in: .local), isEnding: false) }
                            .onEnded { self.handlePanChanged(to: $0.location, in: geometry.frame(in: .local), isEnding: true) })
            }
        }
    }
}

// MARK: - Subviews
private extension HistogramView {

    @ViewBuilder
    func itemView(for entry: Entry, at index: Int, relativeTo maxValue: Double, withMaxHeight maxHeight: CGFloat) -> some View {
        let isPanningOver = isPanningOverBar(atIndex: index)
        ItemView(value: entry.unitValue(relativeTo: maxValue), maxHeight: maxHeight)
            .opacity(isPanningOver ? 0.8 : 1)
            .scaleEffect(isPanningOver ? CGSize(width: 1.05, height: 1.05) : CGSize(width: 1, height: 1), anchor: .bottom)
            .animation(.spring())
    }

    @ViewBuilder
    func currentlySelectedView(for entry: Entry, with offset: CGSize) -> some View {
        VStack {
            Text(String(entry.count)).bold()
            Text(entry.formatted(using: formatter)).font(.caption)
        }
        .padding([.leading, .trailing])
        .padding([.top, .bottom], 5)
        .background(RoundedRectangle(cornerRadius: 5).foregroundColor(Color(UIColor.secondarySystemBackground)).shadow(radius: 3))
        .offset(offset)
        .animation(.spring())
    }
}

// MARK: - Item Subtype
private extension HistogramView {

    struct ItemView: View {
        let value: Double
        let maxHeight: CGFloat

        var body: some View {
            RoundedRectangle(cornerRadius: 6)
                .frame(height: value * maxHeight, alignment: .bottom)

        }
    }
}

// MARK: - Helper
private extension HistogramView {

    func handlePanChanged(to location: CGPoint, in frame: CGRect, isEnding: Bool) {
        withAnimation(.spring()) {
            relativePanLocation = CGPoint(x: location.x / frame.width, y: location.y / frame.height)
            guard let pannedIndex = relativePanLocation.map({ Int($0.x * CGFloat(entries.count)) }), pannedIndex < entries.count, pannedIndex >= 0 else { return }

            currentlyPannedEntry = entries[pannedIndex]
            if isEnding {
                resetPan()
            }
        }
    }

    func resetPan() {
        currentlyPannedEntry = nil
        relativePanLocation = nil
    }

    func labelOffset(for relativeValue: Double, in frame: CGRect) -> CGSize {
        guard let panLocation = relativePanLocation else { return .zero }

        let index = Int(panLocation.x * CGFloat(entries.count))
        guard index < entries.count && index >= 0 else { return .zero }

        let itemWidth = frame.width / CGFloat(entries.count)
        let actualWidth = frame.width - itemWidth
        return CGSize(width: itemWidth * CGFloat(index) - actualWidth * 0.5,
                      height: -1 * (frame.height - (panLocation.y * frame.height - 50)))
    }

    func isPanningOverBar(atIndex index: Int) -> Bool {
        guard let panLocation = relativePanLocation else { return false }
        let entryCount = CGFloat(entries.count)

        return panLocation.x > (CGFloat(index) / entryCount) && panLocation.x < (CGFloat(index + 1) / entryCount)
    }
}

// MARK: - Preview
struct HistogramView_Previews: PreviewProvider {
    

    static var previews: some View {
        HistogramView(entries: [.init(rangeStart: .init(value: 0, unit: UnitDuration.milliseconds),
                                                      rangeEnd: .init(value: 9, unit: UnitDuration.milliseconds), count: 10),
                                                .init(rangeStart: .init(value: 10, unit: UnitDuration.milliseconds),
                                                      rangeEnd: .init(value: 19, unit: UnitDuration.milliseconds), count: 7),
                                                .init(rangeStart: .init(value: 10, unit: UnitDuration.milliseconds),
                                                      rangeEnd: .init(value: 19, unit: UnitDuration.milliseconds), count: 2),
                                                .init(rangeStart: .init(value: 20, unit: UnitDuration.milliseconds),
                                                      rangeEnd: .init(value: 29, unit: UnitDuration.milliseconds), count: 14)],
                      formatter: .shortProvidedUnit, barColors: [.blue, .green])
    }
}
