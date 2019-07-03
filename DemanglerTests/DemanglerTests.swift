@testable import Demangler
import XCTest

extension DemangleResult: Equatable {}

public func == (lhs: DemangleResult, rhs: DemangleResult) -> Bool {
    switch (lhs, rhs) {
    case (.Success(let string), .Success(let string2)):
        return string == string2
    case (.Ignored(let string), .Ignored(let string2)):
        return string == string2
    case (.Failed(let string), .Failed(let string2)):
        return string == string2
    default:
        return false
    }
}

final class DemanglerTests: XCTestCase {
    private var demangler: Demangler!
    
    override func setUp() {
        super.setUp()
        
        demangler = Demangler()
    }
    
    func testDemangleSanity() {
        let demangledResult = demangler.demangle(string: "__TFV3foo3BarCfT_S0_")
        let expectedName = "foo.Bar.init() -> foo.Bar"
        
        XCTAssertEqual(demangledResult, DemangleResult.Success(expectedName))
    }
    
    func testDemangleSwift5() {
        var  demangledResult = demangler.demangle(string: "_$s9Landmarks11CircleImageV7SwiftUI5_ViewAadEP06_visitF4Type7visitoryqd__z_tAD01_fH7VisitorRd__lFZTW")
        var expectedName = "protocol witness for static SwiftUI._View._visitViewType<A where A1: SwiftUI._ViewTypeVisitor>(visitor: inout A1) -> () in conformance Landmarks.CircleImage : SwiftUI._View in Landmarks"
        XCTAssertEqual(demangledResult, DemangleResult.Success(expectedName))
        
        
        demangledResult = demangler.demangle(string: "_$s7SwiftUI6HStackVyAA9TupleViewVyAA5ImageV_AA4TextVAA6SpacerVAA16_ModifiedContentVyAMyAgA30_EnvironmentKeyWritingModifierVyAG5ScaleOGGAOyAA5ColorVSgGGSgtGGML")
        expectedName = "lazy cache variable for type metadata for SwiftUI.HStack<SwiftUI.TupleView<(SwiftUI.Image, SwiftUI.Text, SwiftUI.Spacer, SwiftUI._ModifiedContent<SwiftUI._ModifiedContent<SwiftUI.Image, SwiftUI._EnvironmentKeyWritingModifier<SwiftUI.Image.Scale>>, SwiftUI._EnvironmentKeyWritingModifier<SwiftUI.Color?>>?)>>"
        XCTAssertEqual(demangledResult, DemangleResult.Success(expectedName))
    }
    
    func testReturningNonDemangledName() {
        let demangled = demangler.demangle(string: "sub_123")
        
        XCTAssertEqual(demangled, DemangleResult.Ignored("sub_123"))
    }
    
    func testDemanglingExtractedName() {
        let demangledString = demangler.demangle(string: "-[_TtC3foo3Baz objective]")
        let expectedString = "-[foo.Baz objective]"
        
        XCTAssertEqual(demangledString, DemangleResult.Success(expectedString))
    }
}
