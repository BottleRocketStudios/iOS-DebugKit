//
//  DebugOptionsCollectionController.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import UIKit

protocol DebugOptionsCollectionFlowDelegate: AnyObject {
    func debugOptionsCollectionController(_ controller: DebugOptionsCollectionController,
                                          didRequestPresentationOf viewController: UIViewController, style: DebugOption.Item.Presentation.Style)
}

class DebugOptionsCollectionController: NSObject {

    // MARK: - Properties
    let collectionView: UICollectionView
    let dataSource: DebugOption.DataSource

    weak var delegate: DebugOptionsCollectionFlowDelegate?

    // MARK: - Initializer
    init(collectionView: UICollectionView,
         cellContentProvider: CellContentProvider = .init(),
         supplementaryContentProvider: (DebugOption.DataSource) -> SupplementaryContentProvider = { .init(dataSource: $0) },
         delegate: DebugOptionsCollectionFlowDelegate?) {
        self.collectionView = collectionView
        self.dataSource = DebugOption.DataSource(collectionView: collectionView, cellProvider: cellContentProvider.cell)
        self.delegate = delegate

        let supplementaryContentProvider = supplementaryContentProvider(dataSource)
        dataSource.supplementaryViewProvider = supplementaryContentProvider.supplementaryView

        super.init()

        collectionView.delegate = self
    }
}

// MARK: - Interface
extension DebugOptionsCollectionController {

    func configure(with configuredSections: [DebugOption.ConfiguredSection], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<DebugOption.Section, DebugOption.Item>()
        for section in configuredSections {
            snapshot.appendSections([section.section])
            snapshot.appendItems(section.items, toSection: section.section)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DebugOptionsCollectionController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                collectionView.deselectItem(at: indexPath, animated: true)
            }

            item.handleSelection(at: indexPath, from: self)
        }
    }
}
