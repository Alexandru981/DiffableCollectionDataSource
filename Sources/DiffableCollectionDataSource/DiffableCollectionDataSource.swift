// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: arbitrary)
public macro DiffableCollectionDataSource() = #externalMacro(module: "DiffableCollectionDataSourceMacros", type: "DiffableCollectionDataSourceMacro")

import UIKit

public extension UICollectionView.CellRegistration where Cell: Nibbbable {
    static func newUsingNib(handler: @escaping (Cell, IndexPath, Item) -> Void) -> Self {
        return .init(cellNib: Cell.nib(), handler: handler)
    }
}


public protocol CollectionViewCellRegistrable where Self: UICollectionViewCell {
    associatedtype Model: Hashable
    typealias Registration = UICollectionView.CellRegistration<Self, Model>
    static func makeCellRegistration() -> Registration
    func set(_ model: Model)
}

public extension CollectionViewCellRegistrable {
    static func makeCellRegistration() -> UICollectionView.CellRegistration<Self, Model> {
        return .init { cell, _, model in
            cell.set(model)
        }
    }
}

public extension CollectionViewCellRegistrable where Self: Nibbbable {
    static func makeCellRegistration() -> UICollectionView.CellRegistration<Self, Model> {
        return .newUsingNib { cell, _, model in
            cell.set(model)
        }
    }
}

public protocol Nibbbable: Identifiable {
    static func nib() -> UINib
}

public extension Nibbbable {
    static func nib() -> UINib {
        UINib(nibName: String(describing: self), bundle: nil)
    }
}
