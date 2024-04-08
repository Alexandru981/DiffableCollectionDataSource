import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct DiffableCollectionViewPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DiffableCollectionDataSourceMacro.self
    ]
}

enum Errors: Error {
    case notAClass
}

private struct Variable {
    let name: PatternSyntax
    var type: TypeSyntax { getType() }
    private let typeAnnot: TypeAnnotationSyntax
    
    init(
        name: PatternSyntax,
        typeAnnot: TypeAnnotationSyntax
    ) {
        self.name = name
        self.typeAnnot = typeAnnot
    }
    
    private func getType() -> TypeSyntax {
        if let implicitUnwrap = typeAnnot.type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return implicitUnwrap.wrappedType
        }
        
        return typeAnnot.type
    }
}

public struct DiffableCollectionDataSourceMacro: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw Errors.notAClass
        }
        
        let members = classDecl.memberBlock.members
        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let variables: [Variable] = variableDecl.compactMap {
            guard let name = $0.bindings.first?.pattern, let type = $0.bindings.first?.typeAnnotation else {
                return nil
            }
            
            return .init(name: name, typeAnnot: type)
        }
        
        var code: String =
            """
            private enum Section {
                case single
            }
            
            private typealias DataSoruce = UICollectionViewDiffableDataSource<Section, AnyHashable>
            
            private var dataSource: DataSoruce?
            
            func set(_ data: [AnyHashable]) {
                var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
                snapshot.appendSections([.single])
                snapshot.appendItems(data, toSection: .single)
                dataSource?.apply(snapshot, animatingDifferences: false)
            }
            
            func apply(to collectionView: UICollectionView) {
            """
        
        variables.forEach {
            code += "\n    let \($0.name)Registration = \($0.type).makeCellRegistration()"
        }
        
        code += 
        """
        
        
            dataSource = .init(
                collectionView: collectionView,
                cellProvider: { collectionView, indexPath, cellModel in
                    switch cellModel {
        """
        
        variables.forEach {
            code += 
            """
                    
                        case let model as \($0.type).Model:
                            return collectionView.dequeueConfiguredReusableCell(
                                using: \($0.name)Registration,
                                for: indexPath,
                                item: model
                            )
            
            
            """
        }
        
        code += 
        """
                    default: fatalError("no such cell")
                    }
                }
            )
        }
        """
        
        return [.init(stringLiteral:code)]
    }
}
