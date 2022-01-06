//
//  DebugOptionsViewController.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI
import UIKit

public class DebugOptionsViewController: UIViewController {

    // MARK: - Appearance Subtype
    public struct Appearance {

        // MARK: - Properties
        public let style: UICollectionLayoutListConfiguration.Appearance
        public let cellContentProvider: CellContentProvider
        public let supplementaryContentProvider: (DebugOption.DataSource) -> SupplementaryContentProvider

        // MARK: - Initializer
        public init(style: UICollectionLayoutListConfiguration.Appearance = .insetGrouped,
                    cellContentProvider: CellContentProvider = .init(),
                    supplementaryContentProvider: @escaping (DebugOption.DataSource) -> SupplementaryContentProvider = { .init(dataSource: $0) }) {
            self.style = style
            self.cellContentProvider = cellContentProvider
            self.supplementaryContentProvider = supplementaryContentProvider
        }
    }

    // MARK: - Properties
    public let appearance: Appearance
    private var configuredSections: [DebugOption.ConfiguredSection]?

    private lazy var collectionController = DebugOptionsCollectionController(collectionView: collectionView,
                                                                             cellContentProvider: appearance.cellContentProvider,
                                                                             supplementaryContentProvider: appearance.supplementaryContentProvider,
                                                                             delegate: self)
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        return UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: self.appearance.style)
            configuration.headerMode = .supplementary
            configuration.footerMode = .supplementary

            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }()

    // MARK: - Initializers
    public init(appearance: Appearance = .init()) {
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do some basic collectionView configuration
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

        // Configure the data source
        if let configuredSections = configuredSections {
            collectionController.configure(with: configuredSections, animated: false)
        }
    }
}

// MARK: - Configurable
public extension DebugOptionsViewController {

    func configure(with element: [DebugOption.ConfiguredSection]) {
        configuredSections = element

        if isViewLoaded {
            collectionController.configure(with: element, animated: true)
        }
    }
}

// MARK: - DebugOptionsCollectionFlowDelegate
extension DebugOptionsViewController: DebugOptionsCollectionFlowDelegate {

    func debugOptionsCollectionController(_ controller: DebugOptionsCollectionController,
                                          didRequestPresentationOf viewController: UIViewController, style: DebugOption.Item.Presentation.Style) {
        switch style {
        case .navigation: navigationController?.pushViewController(viewController, animated: true)
        case .modal: present(viewController, animated: true)
        }
    }
}

// MARK: - DebugOptionsView - SwiftUI
public struct DebugOptionsView: UIViewControllerRepresentable {

    // MARK: - Properties
    public let appearance: DebugOptionsViewController.Appearance
    public let configuredSections: [DebugOption.ConfiguredSection]

    // MARK: - Initializer
    public init(appearance: DebugOptionsViewController.Appearance = .init(), configuredSections: [DebugOption.ConfiguredSection]) {
        self.appearance = appearance
        self.configuredSections = configuredSections
    }

    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> DebugOptionsViewController {
        let debugOptionsViewController = DebugOptionsViewController(appearance: appearance)
        debugOptionsViewController.configure(with: configuredSections)

        return debugOptionsViewController
    }

    public func updateUIViewController(_ viewController: DebugOptionsViewController, context: Context) {
        viewController.configure(with: configuredSections)
    }
}
