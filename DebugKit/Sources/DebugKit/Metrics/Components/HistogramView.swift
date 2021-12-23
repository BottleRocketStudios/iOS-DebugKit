//
//  Histogram.swift
//  
//
//  Created by Will McGinty on 6/19/21.
//

import Foundation
import SwiftUI

struct HistogramView<T: Foundation.Unit>: View {

    // MARK: - Preset
    static func displaying<T: Foundation.Unit>(histogram: Histogram<T>, withTitle title: String,
                                               using formatter: MeasurementFormatter, numberFormatter: NumberFormatter = .standard) -> some View {
        return HistogramView<T>(title: title, histogram: histogram,
                                measurementFormatter: formatter, numberFormatter: numberFormatter)
            .navigationTitle(title)
    }

    // MARK: - Properties
    let title: String
    let histogram: Histogram<T>
    let measurementFormatter: MeasurementFormatter
    let numberFormatter: NumberFormatter

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
                    TitleView(title: highestFrequencyEntry.formatted(using: measurementFormatter),
                              subtitle: "Highest Frequency \(title)")
                    Spacer()
                }

                HStack(spacing: 0) {
                    AxisView.displaying(countRange: 0...maxValue, along: .vertical, using: numberFormatter)
                        .foregroundColor(backgroundGray)

                    ZStack(alignment: .bottom) {
                        VStack {
                            GeometryReader { geometry in
                                HStack(alignment: .bottom) {
                                    ForEach(indexedEntries, id: \.0) { index, entry in
                                        ItemView(unitValue: entry.unitValue(relativeTo: maxValue),
                                                 absoluteValue: entry.count,
                                                 label: entry.formatted(using: measurementFormatter),
                                                 isCurrentlySelected: currentlyPannedEntry == entry,
                                                 inSelectedMode: currentlyPannedEntry != nil)
                                    }
                                }
                                .gesture(DragGesture(minimumDistance: 0)
                                            .onChanged { self.handlePanChanged(to: $0.location,
                                                                               in: geometry.frame(in: .local), isEnding: false) }
                                            .onEnded { self.handlePanChanged(to: $0.location,
                                                                             in: geometry.frame(in: .local), isEnding: true) })
                            }
                        }
                        .padding([.leading, .trailing])

                        BackgroundView()
                            .foregroundColor(backgroundGray)
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

    struct TitleView: View {

        // MARK: - Properties
        let title: String
        let subtitle: String

        // MARK: - View
        var body: some View {
            VStack(alignment: .trailing) {
                Text(subtitle)
                    .font(.caption.bold())
                    .foregroundColor(.gray)

                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(UIColor.label))
            }
        }
    }
}

// MARK: - ItemView
private extension HistogramView {

    struct ItemView: View {

        // MARK: - Properties
        let unitValue: Double
        let absoluteValue: Int
        let label: String
        let isCurrentlySelected: Bool
        let inSelectedMode: Bool

        @State private var labelSize: CGSize = .zero

        // MARK: - View
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    LinearGradient(colors: [.init(red: 0, green: 41/255.0, blue: 103/255.0),
                                            .init(red: 0, green: 91/255.0, blue: 210/255.0)], startPoint: .bottom, endPoint: .top)
                        .mask(
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .cornerRadius(6, corners: [.topLeft, .topRight])
                                    .frame(width: geometry.size.width * 0.8, height: unitValue *  geometry.size.height, alignment: .bottom)
                                    .scaleEffect(isCurrentlySelected ? CGSize(width: 1.05, height: 1.05) : CGSize(width: 1, height: 1), anchor: .bottom)
                            }
                            .frame(height: geometry.size.height, alignment: .bottom)
                        )
                }

                VStack(alignment: .center) {
                    Text(String(absoluteValue))
                        .font(.body.bold())

                    Text(label)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .foregroundColor(.gray)
                .opacity(isCurrentlySelected ? 1 : 0 )
                .modifier(SizeModifier())
                .onPreferenceChange(SizePreferenceKey.self) { self.labelSize = $0 }
                .offset(x: (0.5 * geometry.size.width) - (0.5 * labelSize.width),
                        y: geometry.size.height - (1.05 * unitValue * geometry.size.height) - labelSize.height - 4)
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
            let values = [range.lowerBound, range.upperBound]
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
}

// MARK: - Preview
struct HistogramView_Previews: PreviewProvider {

    static var previews: some View {
        let buckets: [Histogram<UnitDuration>.Bucket] = [.init(start: .init(value: 0, unit: UnitDuration.milliseconds),
                                                               end: .init(value: 9, unit: UnitDuration.milliseconds), count: 1),
                                                         .init(start: .init(value: 10, unit: UnitDuration.milliseconds),
                                                               end: .init(value: 19, unit: UnitDuration.milliseconds), count: 6),
                                                         .init(start: .init(value: 20, unit: UnitDuration.milliseconds),
                                                               end: .init(value: 29, unit: UnitDuration.milliseconds), count: 2),
                                                         .init(start: .init(value: 30, unit: UnitDuration.milliseconds),
                                                               end: .init(value: 39, unit: UnitDuration.milliseconds), count: 14)]

        HistogramView(title: "Time To First Draw", histogram: .init(buckets: buckets),
                      measurementFormatter: .shortProvidedUnit, numberFormatter: .standard)

        HistogramView(title: "Time To First Draw", histogram: .init(buckets: buckets),
                      measurementFormatter: .shortProvidedUnit, numberFormatter: .standard)
            .preferredColorScheme(.dark)
    }
}
