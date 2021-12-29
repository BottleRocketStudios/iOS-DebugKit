//
//  DebugOptionsCollectionController.swift
//  
//
//  Created by Will McGinty on 12/23/21.
//

import UIKit

protocol DebugOptionsCollectionFlowDelegate: AnyObject {
    func debugOptionsCollectionController(_ controller: DebugOptionsCollectionController, didRequestPresentationOf viewController: UIViewController)
}

public class DebugOptionsCollectionController: NSObject {

    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

    private let collectionView: UICollectionView
    private let dataSource: DataSource

    weak var delegate: DebugOptionsCollectionFlowDelegate?

    // MARK: - Initializer
    init(collectionView: UICollectionView, delegate: DebugOptionsCollectionFlowDelegate?) {
        let cellContentProvider = CellContentProvider()
        self.collectionView = collectionView
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: cellContentProvider.cell)
        self.delegate = delegate

        let supplementaryContentProvider = SupplementaryContentProvider(dataSource: dataSource)
        dataSource.supplementaryViewProvider = supplementaryContentProvider.supplementaryView

        super.init()

        collectionView.delegate = self
    }
}

// MARK: - Interface
extension DebugOptionsCollectionController {

    func configure(with configuredSections: [ConfiguredSection], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        for section in configuredSections {
            snapshot.appendSections([section.section])
            snapshot.appendItems(section.items, toSection: section.section)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DebugOptionsCollectionController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { collectionView.deselectItem(at: indexPath, animated: true) }

        if let item = dataSource.itemIdentifier(for: indexPath) {
            item.handleSelection(at: indexPath, from: self)
        }
    }
}
