import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(DiffableCollectionViewMacros)
import DiffableCollectionViewMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "DiffableCollectionView": DiffableCollectionViewMacro.self
]
#endif

final class DiffableCollectionViewTests: XCTestCase {
    func testMacro() throws {
        #if canImport(DiffableCollectionViewMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(DiffableCollectionViewMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testFoo() throws {
        #if canImport(DiffableCollectionViewMacros)
        assertMacroExpansion(
            """
            @DiffableCollectionView
            class Foo {
                private var testCell: TestCell1!
                private var testCell: TestCell2!
            }
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
