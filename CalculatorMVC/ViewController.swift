//
//  ViewController.swift
//  CalculatorMVC
//
//  Created by Ivan on 25.04.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    private var userIsInTheMiddleOfTypingANumber = false
    
    let decimalSeparator = NSNumberFormatter().decimalSeparator
    
    private var brain = CalculatorBrain()
    
    private var displayValue: Double? {
        get{
            if let result = NSNumberFormatter().numberFromString(display.text!)?.doubleValue{
                return result
            } else {
                return nil
            }
        }
        set{
            if let result = newValue {
                display.text = String(result)
            } else {
                display.text = "Error"
            }
        }
    }
    
    @IBAction func backspace() {
        if display.text != nil {
            if display.text!.characters.count > 1 {
                display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            } else {
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        }
    }
    
    
    @IBAction func touchDecimalSeparator() {
        
        if userIsInTheMiddleOfTypingANumber{
            if display.text!.rangeOfString(decimalSeparator) == nil {
                display.text = display.text! + decimalSeparator
            }
        } else {
            display.text = decimalSeparator
        }
        userIsInTheMiddleOfTypingANumber = true
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        
        if let digit = sender.currentTitle {
            
            if userIsInTheMiddleOfTypingANumber{
            
                display.text = display.text! + digit
            
            } else {
                
                if digit == "0" && display.text?.rangeOfString("0") != nil {
                    return
                }
                
                display.text = digit
            }
        
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction private func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber{
            if let operand = displayValue{
                brain.setOperand(operand)
                //history.text = history.text! + String(operand)
                userIsInTheMiddleOfTypingANumber = false
            }
        }
        
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
            //history.text = history.text! + operation
        }
        
        history.text = brain.description
        displayValue = brain.result
    }
    
    var savedProgram : CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil{
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func clear() {
        
        brain.clear()
        
        display.text = "0"
        history.text = " "
    }
    
}


