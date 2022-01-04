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

    // MARK: - Properties

    // TODO: Wrap this in some kind of appearance struct?
    public let appearance: UICollectionLayoutListConfiguration.Appearance
    public let cellContentProvider: CellContentProvider
    public let supplementaryContentProvider: (DebugOption.DataSource) -> SupplementaryContentProvider

    private var configuredSections: [DebugOption.ConfiguredSection]?

    private lazy var collectionController = DebugOptionsCollectionController(collectionView: collectionView,
                                                                             cellContentProvider: cellContentProvider,
                                                                             supplementaryContentProvider: supplementaryContentProvider,
                                                                             delegate: self)
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        return UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: self.appearance)
            configuration.headerMode = .supplementary
            configuration.footerMode = .supplementary

            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }()

    // MARK: - Initializers
    public init(appearance: UICollectionLayoutListConfiguration.Appearance = .insetGrouped,
                cellContentProvider: CellContentProvider = .init(),
                supplementaryContentProvider: @escaping (DebugOption.DataSource) -> SupplementaryContentProvider = { .init(dataSource: $0) }) {
        self.appearance = appearance
        self.cellContentProvider = cellContentProvider
        self.supplementaryContentProvider = supplementaryContentProvider
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

    func debugOptionsCollectionController(_ controller: DebugOptionsCollectionController, didRequestPresentationOf viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - DebugOptionsView - SwiftUI
public struct DebugOptionsView: UIViewControllerRepresentable {

    // TODO: Ensure this has the same customization properties as the UIViewController

    // MARK: - Properties
    // TODO: Should this be a state var?
    let configuredSections: [DebugOption.ConfiguredSection]

    // MARK: - Initializer
    public init(configuredSections: [DebugOption.ConfiguredSection]) {
        self.configuredSections = configuredSections
    }

    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> DebugOptionsViewController {
        let debugOptionsViewController = DebugOptionsViewController()
        debugOptionsViewController.configure(with: configuredSections)

        return debugOptionsViewController
    }

    public func updateUIViewController(_ viewController: DebugOptionsViewController, context: Context) {
        viewController.configure(with: configuredSections)
    }
}
