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
    private var configuration: [DebugOptionsCollectionController.ConfiguredSection]?

    private lazy var collectionController = DebugOptionsCollectionController(collectionView: collectionView, delegate: self)
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        return UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerMode = .supplementary
            configuration.footerMode = .supplementary

            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }()

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
        if let configuredSections = configuration {
            collectionController.configure(with: configuredSections, animated: false)
        }
    }
}

// MARK: - Configurable
public extension DebugOptionsViewController {

    func configure(with element: [DebugOptionsCollectionController.ConfiguredSection]) {
        configuration = element

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

// MARK: - DebugOptionsView
public struct DebugOptionsView: UIViewControllerRepresentable {

    // MARK: - Properties
    let configuredSections: [DebugOptionsCollectionController.ConfiguredSection]

    // MARK: - Initializer
    public init(configuredSections: [DebugOptionsCollectionController.ConfiguredSection]) {
        self.configuredSections = configuredSections
    }

    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> DebugOptionsViewController {
        let debugOptions = DebugOptionsViewController()
        debugOptions.configure(with: configuredSections)

        //let navigationController = UINavigationController(rootViewController: debugOptions)
        //return navigationController
        return debugOptions
    }

    public func updateUIViewController(_ uiViewController: DebugOptionsViewController, context: Context) {
        uiViewController.configure(with: configuredSections)
        //print("update")

    }
}
