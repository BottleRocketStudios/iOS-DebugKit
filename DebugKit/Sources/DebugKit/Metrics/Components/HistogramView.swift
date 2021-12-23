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

    // MARK: - Preset
    static func displaying<T: Foundation.Unit>(histogram: Histogram<T>, withTitle title: String, using formatter: MeasurementFormatter) -> some View {
        return HistogramView<T>(title: title, histogram: histogram, measurementFormatter: formatter, axisFormatter: .standard)
            .navigationTitle(title)
    }

    // MARK: - Properties
    let title: String
    let histogram: Histogram<T>
    let measurementFormatter: MeasurementFormatter
    let axisFormatter: NumberFormatter

    @State private var relativePanLocation: CGPoint?
    @State private var currentlyPannedEntry: Histogram<T>.Bucket?
    @State private var informationViewSize: CGSize = .zero

    private var backgroundGray: Color { Color(UIColor.lightGray).opacity(0.5) }

    // MARK: - View
    var body: some View {
        let maxValue = Double(histogram.buckets.map(\.count).max() ?? 0) * 1.1

        if histogram.buckets.isEmpty {
            NoEntriesView(configuration: .default)

        } else {
            let indexedEntries = Array(zip(histogram.buckets.indices, histogram.buckets))
            VStack(alignment: .trailing, spacing: 0) {
                if let highestFrequencyEntry = histogram.highestFrequencyEntry {
                    informationView(for: "Highest Frequency \(title)",
                                       value: highestFrequencyEntry.formatted(using: measurementFormatter))
                    Spacer()
                }

                HStack(spacing: 0) {
                    AxisView.displaying(countRange: 0...maxValue, along: .vertical, using: axisFormatter)
                        .foregroundColor(backgroundGray)

                    ZStack(alignment: .bottom) {
                        BackgroundView()
                            .foregroundColor(backgroundGray)

                        VStack {
                            GeometryReader { innerGeometry in
                                HStack(alignment: .bottom) {
                                    ForEach(indexedEntries, id: \.0) { index, entry in
                                        ItemView(value: entry.unitValue(relativeTo: maxValue),
                                                 count: entry.count,
                                                 label: entry.formatted(using: measurementFormatter),
                                                 maxHeight: innerGeometry.size.height,
                                                 isCurrentlySelected: currentlyPannedEntry == entry,
                                                 inSelectedMode: currentlyPannedEntry != nil)
                                    }
                                }
                                .gesture(DragGesture(minimumDistance: 0)
                                            .onChanged { self.handlePanChanged(to: $0.location, in: innerGeometry.frame(in: .local), isEnding: false) }
                                            .onEnded { self.handlePanChanged(to: $0.location, in: innerGeometry.frame(in: .local), isEnding: true) })
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                }

                if let measurementRange = histogram.measurementRange {
                    AxisView.displaying(measurementRange: measurementRange, along: .horizontal, using: measurementFormatter)
                        .foregroundColor(backgroundGray)
                }

            }
            .padding()
        }
    }
}

// MARK: - Subviews
private extension HistogramView {

    @ViewBuilder
    func informationView(for title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.gray)

            Text(value)
                .font(.largeTitle.bold())
                .foregroundColor(Color(UIColor.label))
        }
    }
}

// MARK: - ItemView
private extension HistogramView {

    struct ItemView: View {

        // MARK: - Properties
        let value: Double
        let count: Int
        let label: String
        let maxHeight: CGFloat
        let isCurrentlySelected: Bool
        let inSelectedMode: Bool

        @State private var labelSize: CGSize = .zero

        // MARK: - View
        var body: some View {
            ZStack(alignment: .top) {
                GeometryReader { geometry in
                    LinearGradient(colors: [.blue,.green], startPoint: .top, endPoint: .bottom)
                        .mask(
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .cornerRadius(6, corners: [.topLeft, .topRight])
                                    .frame(width: geometry.size.width * 0.8, height: value *  geometry.size.height, alignment: .bottom)
                                    .scaleEffect(isCurrentlySelected ? CGSize(width: 1.05, height: 1.05) : CGSize(width: 1, height: 1),
                                                 anchor: .bottom)
                            }
                            .frame(height: geometry.size.height, alignment: .bottom)
                        )
                }

                VStack {
                    Text(String(count))
                        .font(.subheadline)

                    Text(label)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .foregroundColor(.gray)
                .opacity(isCurrentlySelected ? 1 : 0 )
                .modifier(SizeModifier())
                .onPreferenceChange(SizePreferenceKey.self) { self.labelSize = $0 }
                .offset(x: 0, y: maxHeight - (value * maxHeight) - labelSize.height - (0.05 * value * maxHeight) - 4)
                .animation(.default, value: isCurrentlySelected)
            }
            .opacity(!inSelectedMode || isCurrentlySelected ? 1 : 0.5)
            .animation(.spring())
        }
    }
}

// MARK: - BackgroundView
private extension HistogramView {

    struct BackgroundView: View {

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Rectangle()
                        .frame(width: 1)
                    Spacer()
                }

                Rectangle()
                    .frame(height: 1)
            }
        }
    }
}

// MARK: - AxisView
private extension HistogramView {

    struct AxisView: View {

        // MARK: - Subtypes
        enum Axis {
            case vertical, horizontal
        }

        // MARK: - Preset
        static func displaying<T: Foundation.Unit>(measurementRange range: ClosedRange<Measurement<T>>, along axis: Axis,
                                                   using formatter: MeasurementFormatter) -> some View {
            let values = [range.lowerBound, ((range.upperBound + range.lowerBound) * 0.5), range.upperBound]
            return AxisView(axis: axis, labels: values.compactMap(formatter.string))
        }

        static func displaying(countRange range: ClosedRange<Double>, along axis: Axis,
                               using formatter: NumberFormatter) -> some View {
            let values = [range.upperBound, ((range.upperBound + range.lowerBound) * 0.5), range.lowerBound]
            return AxisView(axis: axis, labels: values.compactMap(formatter.string))
        }

        // MARK: - Properties
        let axis: Axis
        let labels: [String]

        // MARK: - View
        var body: some View {
            if axis == .horizontal {
                HStack {
                    stackContent
                }
                .padding(.leading)
                .padding(.top, 8)
            } else {
                VStack(alignment: .leading) {
                    stackContent
                }
                .padding([.trailing], 6)
            }
        }

        private var stackContent: some View {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.caption)

                if label != labels.last {
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Helper
private extension HistogramView {

    func handlePanChanged(to location: CGPoint, in frame: CGRect, isEnding: Bool) {
        withAnimation(.spring()) {
            relativePanLocation = CGPoint(x: location.x / frame.width, y: location.y / frame.height)
            guard let pannedIndex = relativePanLocation.map({ Int($0.x * CGFloat(histogram.buckets.count)) }),
                  pannedIndex < histogram.buckets.count, pannedIndex >= 0 else { return }

            currentlyPannedEntry = histogram.buckets[pannedIndex]

            if isEnding {
                resetPan()
            }
        }
    }

    func resetPan() {
        currentlyPannedEntry = nil
        relativePanLocation = nil
    }

    func labelOffset(in frame: CGRect) -> CGSize {
        guard let panLocation = relativePanLocation else { return .zero }

        let index = Int(panLocation.x * CGFloat(histogram.buckets.count))
        guard index < histogram.buckets.count && index >= 0 else { return .zero }

        let itemWidth = frame.width / CGFloat(histogram.buckets.count)
        let actualWidth = frame.width - itemWidth
        return CGSize(width: itemWidth * CGFloat(index) - actualWidth * 0.5, height: 0)
    }
}

// MARK: - Preview
struct HistogramView_Previews: PreviewProvider {

    static var previews: some View {
        HistogramView(title: "Time To First Draw", histogram: .init(buckets: [.init(start: .init(value: 0, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 9, unit: UnitDuration.milliseconds), count: 1),
                                                                              .init(start: .init(value: 10, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 19, unit: UnitDuration.milliseconds), count: 6),
                                                                              .init(start: .init(value: 20, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 29, unit: UnitDuration.milliseconds), count: 2),
                                                                              .init(start: .init(value: 30, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 39, unit: UnitDuration.milliseconds), count: 14)]),
                      measurementFormatter: .shortProvidedUnit, axisFormatter: .standard)

        HistogramView(title: "Time To First Draw", histogram: .init(buckets: [.init(start: .init(value: 0, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 9, unit: UnitDuration.milliseconds), count: 1),
                                                                              .init(start: .init(value: 10, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 19, unit: UnitDuration.milliseconds), count: 6),
                                                                              .init(start: .init(value: 20, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 29, unit: UnitDuration.milliseconds), count: 2),
                                                                              .init(start: .init(value: 30, unit: UnitDuration.milliseconds),
                                                                                    end: .init(value: 39, unit: UnitDuration.milliseconds), count: 14)]),
                      measurementFormatter: .shortProvidedUnit, axisFormatter: .standard)
            .preferredColorScheme(.dark)
    }
}
