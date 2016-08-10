import UIKit

/// Classes can conform to this protocol to be informed when a new state is selected.
protocol StatePickerDelegate: class {
    
    /**
     Called when a new state is selected.
     
     - parameter statePicker The sender of this method.
     - parameter pickedState The state that was picked.
     */
    func statePicker(statePicker: StatePicker, pickedState: String)
}

/// Custom UIPickerView for selecting a US state.
class StatePicker: NSObject {
    
    // MARK: Public properties
    
    /// Delegate of this class.
    weak var delegate: StatePickerDelegate?
    
    // MARK: Private properties
    
    /// Array of state abbreviations.
    var statesArray: NSArray?
    
    // MARK: Init and deinit methods
    
    required override init() {
        if let filePath = NSBundle.mainBundle().pathForResource("USStates", ofType: "plist") {
            statesArray = NSArray(contentsOfFile: filePath)
        }
        
        super.init()
    }
}

// MARK: UIPickerViewDataSource methods

extension StatePicker: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let array = statesArray {
            return array.count
        }
        
        return 0
    }
}

// MARK: UIPickerViewDelegate methods

extension StatePicker: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let array = statesArray {
            if let stateDictionary = array.objectAtIndex(row) as? NSDictionary {
                if let stateAbbreviation = stateDictionary.objectForKey(USStates.StateAbbreviationKey) as? String {
                    delegate?.statePicker(self, pickedState: stateAbbreviation)
                }
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let array = statesArray {
            if let stateDictionary = array.objectAtIndex(row) as? NSDictionary {
                if let stateName = stateDictionary.objectForKey(USStates.StateNameKey) as? String {
                    return stateName
                }
            }
        }
        
        return ""
    }
}
