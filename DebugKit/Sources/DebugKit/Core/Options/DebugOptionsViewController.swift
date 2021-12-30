//
//  DebugOptionsViewController.swift
//  
//
//  Created by Will McGinty on 12/23/21.
//

import SwiftUI
import UIKit

public class DebugOptionsViewController: UIViewController {

    // MARK: - Properties
    public let appearance: UICollectionLayoutListConfiguration.Appearance
    public let cellContentProvider: DebugOptionsCollectionController.CellContentProvider
    public let supplementaryContentProvider: (DebugOptionsCollectionController.DataSource) -> DebugOptionsCollectionController.SupplementaryContentProvider

    private var configuredSections: [DebugOptions.ConfiguredSection]?

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
                cellContentProvider: DebugOptionsCollectionController.CellContentProvider = .init(),
                supplementaryContentProvider: @escaping (DebugOptionsCollectionController.DataSource) -> DebugOptionsCollectionController.SupplementaryContentProvider = { .init(dataSource: $0) }) {
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

    func configure(with element: [DebugOptions.ConfiguredSection]) {
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

    // MARK: - Properties
    let appearance: UICollectionLayoutListConfiguration.Appearance
    let configuredSections: [DebugOptions.ConfiguredSection]

    // MARK: - Initializer
    public init(appearance: UICollectionLayoutListConfiguration.Appearance, configuredSections: [DebugOptions.ConfiguredSection]) {
        self.appearance = appearance
        self.configuredSections = configuredSections
    }

    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> DebugOptionsViewController {
        let debugOptions = DebugOptionsViewController(appearance: appearance)
        debugOptions.configure(with: configuredSections)

        return debugOptions
    }

    public func updateUIViewController(_ uiViewController: DebugOptionsViewController, context: Context) {
        uiViewController.configure(with: configuredSections)
    }
}
