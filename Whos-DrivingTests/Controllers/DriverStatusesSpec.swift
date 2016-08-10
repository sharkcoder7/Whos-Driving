import Quick
import Nimble

@testable import whos_driving_staging

class DriverStatusesSpec: QuickSpec {
    
    // MARK: Tests
    
    //    class func driverStatusAndResponseToConfirmation(driverStatus: DriverStatus, driverStatusResponse: DriverStatusResponse) -> ResponseConfirmation {

    override func spec() {
        it("driverStatusAndResponseToConfirmation should return ToSuccess") { () -> () in
            let driverStatus = DriverStatus.CanDriveTo
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.ToSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return ToSuccess") { () -> () in
            let driverStatus = DriverStatus.CanDriveToNotFrom
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.ToSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return FromSuccess") { () -> () in
            let driverStatus = DriverStatus.CanDriveFrom
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.FromSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return FromSuccess") { () -> () in
            let driverStatus = DriverStatus.CanDriveFromNotTo
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.FromSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return BothSuccess") { () -> () in
            let driverStatus = DriverStatus.CanDriveToAndFrom
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.BothSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CannotSuccess") { () -> () in
            let driverStatus = DriverStatus.CannotDriveFrom
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CannotSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CannotSuccess") { () -> () in
            let driverStatus = DriverStatus.CannotDriveTo
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CannotSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CannotSuccess") { () -> () in
            let driverStatus = DriverStatus.CannotDriveToAndFrom
            let driverStatusResponse = DriverStatusResponse.Success
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CannotSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CanPartialSuccess") { () -> () in
            let driverStatus = DriverStatus.CanDriveToAndFrom
            let driverStatusResponse = DriverStatusResponse.Partial
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CanPartialSuccess
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CanFailed") { () -> () in
            let driverStatus = DriverStatus.CanDriveTo
            let driverStatusResponse = DriverStatusResponse.Failure
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CanFailed
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CanFailed") { () -> () in
            let driverStatus = DriverStatus.CanDriveToAndFrom
            let driverStatusResponse = DriverStatusResponse.Failure
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CanFailed
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CanFailed") { () -> () in
            let driverStatus = DriverStatus.CanDriveFrom
            let driverStatusResponse = DriverStatusResponse.Failure
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CanFailed
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CanFailed") { () -> () in
            let driverStatus = DriverStatus.CanDriveFromNotTo
            let driverStatusResponse = DriverStatusResponse.Failure
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CanFailed
            
            expect(result).to(equal(expectedResult))
        }
        
        it("driverStatusAndResponseToConfirmation should return CanFailed") { () -> () in
            let driverStatus = DriverStatus.CanDriveToAndFrom
            let driverStatusResponse = DriverStatusResponse.Failure
            let result = DriverStatuses.driverStatusAndResponseToConfirmation(driverStatus, driverStatusResponse: driverStatusResponse)
            let expectedResult = ResponseConfirmation.CanFailed
            
            expect(result).to(equal(expectedResult))
        }
    }
}