import Quick
import Nimble

@testable import whos_driving_staging

class CreateEventNotificationViewControllerViewModelSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        let eventFactory = EventFactory()
        eventFactory.startTime = NSDate(timeIntervalSince1970: 0)
        eventFactory.name = "Soccer Practice"
        let testPerson = PersonSpec.personFromTestJSON()
        
        describe("speechBubbleText") { () -> Void in
            it("should return correct text for EventFactory with driver TO") { () -> () in
                eventFactory.driverFrom = nil
                eventFactory.driverTo = testPerson
                let viewModel = CreateEventNotificationViewControllerViewModel(eventFactory: eventFactory)
                let text = viewModel.speechBubbleText()
                
                expect(text).to(equal("New carpool created: Wed 12/31 Soccer Practice. Jane D is driving TO; Can you drive FROM?"))
            }
            
            it("should return correct text for EventFactory with driver FROM") { () -> () in
                eventFactory.driverFrom = testPerson
                eventFactory.driverTo = nil
                let viewModel = CreateEventNotificationViewControllerViewModel(eventFactory: eventFactory)
                let text = viewModel.speechBubbleText()
                
                expect(text).to(equal("New carpool created: Wed 12/31 Soccer Practice. Jane D is driving FROM; Can you drive TO?"))
            }
            
            it("should return correct text for EventFactory with driver TO and FROM") { () -> () in
                eventFactory.driverFrom = testPerson
                eventFactory.driverTo = testPerson
                let viewModel = CreateEventNotificationViewControllerViewModel(eventFactory: eventFactory)
                let text = viewModel.speechBubbleText()
                
                expect(text).to(equal("New carpool created: Wed 12/31 Soccer Practice. Jane D is driving TO and FROM."))
            }
            
            it("should return correct text for EventFactory with no drivers") { () -> () in
                eventFactory.driverFrom = nil
                eventFactory.driverTo = nil
                let viewModel = CreateEventNotificationViewControllerViewModel(eventFactory: eventFactory)
                let text = viewModel.speechBubbleText()
                
                expect(text).to(equal("New carpool created: Wed 12/31 Soccer Practice. Drivers needed! Can you drive TO and/or FROM?"))
            }
        }
    }
}