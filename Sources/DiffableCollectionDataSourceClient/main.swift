import DiffableCollectionDataSource
import Foundation
import UIKit

@DiffableCollectionDataSource
class TestDataSource {
    private var test1: TestCell1!
    private var test2: TestCell2!
}

final class TestCell1: UICollectionViewCell, CollectionViewCellRegistrable {
    func set(_ model: Model) {
        
    }
}

extension TestCell1 {
    struct Model: Hashable {
        
    }
}

final class TestCell2: UICollectionViewCell, CollectionViewCellRegistrable {
    func set(_ model: Model) {
        
    }
}

extension TestCell2 {
    struct Model: Hashable {
        
    }
}
