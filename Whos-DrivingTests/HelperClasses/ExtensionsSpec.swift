import Quick
import Nimble

@testable import whos_driving_staging

class ExtensionsSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        describe("Bool extension") { () -> Void in
            it("true.stringValue() should return true") { () -> () in
                let trueString = true.stringValue()
                let expectedResult = "true"
                
                expect(trueString).to(equal(expectedResult))
            }
            
            it("false.stringValue() should return false") { () -> () in
                let falseString = false.stringValue()
                let expectedResult = "false"
                
                expect(falseString).to(equal(expectedResult))
            }
        }
        
        describe("Dictionary extension") { () -> Void in
            it("dictionary should be updated correctly", closure: { () -> () in
                var dict = [
                    "oneKey" : 1,
                    "twoKey" : 2,
                ]
                
                let otherDict = [
                    "oneKey" : 11,
                    "threeKey" : 3,
                ]
                
                dict.update(otherDict)
                
                expect(dict["oneKey"]).to(equal(11))
                expect(dict["twoKey"]).to(equal(2))
                expect(dict["threeKey"]).to(equal(3))
            })
        }
        
        describe("String extension") { () -> () in
            it("trimmed string shouldn't have whitespace", closure: { () -> () in
                let string = "  test "
                let result = string.trimmedString()
                let expectedResult = "test"
                
                expect(result).to(equal(expectedResult))
            })
            
            it("trimmed string from trimmedStringOrNil shouldn't have whitespace", closure: { () -> () in
                let string = "  test "
                let result = string.trimmedStringOrNil()
                let expectedResult = "test"
                
                expect(result).to(equal(expectedResult))
            })
            
            it("empty string should return nil", closure: { () -> () in
                let string = "   "
                let result = string.trimmedStringOrNil()
                
                expect(result).to(beNil())
            })
        }
        
        describe("UIViewController extension") { () -> () in
            it("isRootViewController should return true", closure: { () -> () in
                let vc = UIViewController()
                let navController = UINavigationController()
                navController.viewControllers = [vc]

                expect(vc.isRootViewController).to(beTrue())
            })
            
            it("isRootViewController should return false", closure: { () -> () in
                let vc = UIViewController()
                expect(vc.isRootViewController).to(beFalse())
            })
            
            it("isRootViewController should return false", closure: { () -> () in
                let vc = UIViewController()
                let vc2 = UIViewController()
                let navController = UINavigationController()
                navController.viewControllers = [vc, vc2]
                expect(vc2.isRootViewController).to(beFalse())
            })
        }
    }
}