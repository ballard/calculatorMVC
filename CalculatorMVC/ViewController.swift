//
//  ViewController.swift
//  CalculatorMVC
//
//  Created by Ivan on 25.04.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var display: UILabel!
    
    let piSymbol = "π"
    
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var operandStack = [Double]()
    
    var displayValue: Double? {
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
                display.text = "0"
            }
        }
    }
    
    @IBAction func touchDigit(sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber{
            
            display.text = display.text! + digit
            
        } else {
            
            display.text = digit
            
        }
        
        userIsInTheMiddleOfTypingANumber = true
        
    }
    
    @IBAction func operate(sender: UIButton) {
        
        if let operation = sender.currentTitle {
            
            if userIsInTheMiddleOfTypingANumber{
                enter()
            }
        
            switch operation {
                case piSymbol: performOperation {$0 * M_PI}
                default:
                    break
            }
        }
    }
    
    func performOperation (operation:(Double) -> Double) {
        if operandStack.count >= 1{
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    @IBAction func enter() {
        
        if let input = displayValue {
            operandStack.append(input)
            userIsInTheMiddleOfTypingANumber = false
        }
        
        print("operandStack: \(operandStack)")
        
    }
    
    
    
    
    

}

