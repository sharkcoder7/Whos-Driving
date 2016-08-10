import Quick
import Nimble

@testable import whos_driving_staging

class DetailHeaderViewModelSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        describe("headerLabelAttributedText") { () -> Void in
            it("should return empty string for EventDriverStatus.BothDrivers, show response: true", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.BothDrivers, responses: [DriverStatus](), shouldShowResponseView: true)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal(""))
            })
            
            it("should return empty string for EventDriverStatus.BothDrivers, show response: false", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.BothDrivers, responses: [DriverStatus](), shouldShowResponseView: false)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal(""))
            })
            
            it("should return correct text for EventDriverStatus.NoDriverFrom, show response: true", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.NoDriverFrom, responses: [DriverStatus](), shouldShowResponseView: true)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal("This carpool needs 1 more driver! Respond:"))
            })
            
            it("should return correct text for EventDriverStatus.NoDriverTo, show response: true", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.NoDriverTo, responses: [DriverStatus](), shouldShowResponseView: true)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal("This carpool needs 1 more driver! Respond:"))
            })
            
            it("should return correct text for EventDriverStatus.NoDriverTo, show response: false", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.NoDriverTo, responses: [DriverStatus](), shouldShowResponseView: false)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal("This carpool needs 1 more driver!"))
            })
            
            it("should return correct text for EventDriverStatus.NoDriverFrom, show response: false", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.NoDriverFrom, responses: [DriverStatus](), shouldShowResponseView: false)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal("This carpool needs 1 more driver!"))
            })
            
            it("should return correct text for EventDriverStatus.NoDrivers, show response: true", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.NoDrivers, responses: [DriverStatus](), shouldShowResponseView: true)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal("This carpool needs 2 drivers! Respond:"))
            })
            
            it("should return correct text for EventDriverStatus.NoDrivers, show response: false", closure: { () -> () in
                let viewModel = DetailHeaderViewModel(driverStatus: EventDriverStatus.NoDrivers, responses: [DriverStatus](), shouldShowResponseView: false)
                let text = viewModel.headerLabelAttributedText()
                
                expect(text.string).to(equal("This carpool needs 2 drivers!"))
            })
        }
    }
}