//
//  CalculatorBrain.swift
//  CalculatorMVC
//
//  Created by Ivan on 25.04.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    
    private var accumulator = 0.0
    
    private var internalProgram  = [AnyObject]()
    
    var description = ""
    
    private var isPartialResult = false
    
    let descriptionNumberFormatter = NSNumberFormatter()

    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        
        if description.rangeOfString("...") != nil {
            let range = description.endIndex.advancedBy(-3)..<description.endIndex
            description.removeRange(range)
        }
        
        if operand % 1 == 0 {
            descriptionNumberFormatter.allowsFloats = false
        } else {
            descriptionNumberFormatter.allowsFloats = true
            descriptionNumberFormatter.maximumFractionDigits = 6
        }
        
        let operandString = descriptionNumberFormatter.stringFromNumber(operand)!
        
        if isPartialResult {
            description += operandString//String(operand)
        } else {
            description = operandString//String(operand)
        }
    }
    
    private var operations = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "±" : Operation.UnaryOperation{-$0},
        "×" : Operation.BinaryOperation{$0 * $1},
        "÷" : Operation.BinaryOperation{$0 / $1},
        "+" : Operation.BinaryOperation{$0 + $1},
        "−" : Operation.BinaryOperation{$0 - $1},
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        
        if let operation = operations[symbol]{
            
            internalProgram.append(symbol)
            
            switch operation {
            case .Constant (let value):
                
                accumulator = value
                removeSymbol("...")
                
                if isPartialResult {
                    description += symbol
                } else {
                    description = symbol
                }
                
            case .UnaryOperation (let function):
                
                if isPartialResult{
                    if let plusRange = description.rangeOfString("+"){
                        let range = Range(plusRange.startIndex.successor()..<description.endIndex)
                        description.removeRange(range)
                        if accumulator == M_PI {
                            description.insertContentsOf("\(symbol)π".characters, at: description.endIndex)
                        } else {
                            description.insertContentsOf("\(symbol)(\(accumulator))".characters, at: description.endIndex)
                        }
                    }
                }

                accumulator = function(accumulator)
                
                if !isPartialResult{
                    removeSymbol("=")
                    description = "\(symbol)(\(description))"
                }
                isPartialResult = false
                
            case .BinaryOperation (let function):
                insertAccumulatorValueIsteadOfPoints()
                
                executePendingBinaryOperation()
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                
                removeSymbol("=")
                description += symbol + "..."
                
                isPartialResult = true
                
            case .Equals:
                
                removeSymbol("=")
                insertAccumulatorValueIsteadOfPoints()
                
                executePendingBinaryOperation()
                
                description += symbol
                isPartialResult = false
            }
        }
    }
    
    private func insertAccumulatorValueIsteadOfPoints(){
        if let pointsRange = description.rangeOfString("..."){
            description.removeRange(pointsRange)
            
            if accumulator == M_PI {
                description = ("\(description)π")
            } else {
                description = ("\(description)\(accumulator)")
            }
        }
    }
    
    private func removeSymbol(symbol: String){
        if let equalRange = description.rangeOfString(symbol){
            description.removeRange(equalRange)
        }
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: pendingBinaryOperationInfo?
    
    private struct pendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private func operate(){}
    
    var result: Double? {
        if accumulator.isNaN {
            return nil
        } else {
            return accumulator
        }
    }
    
    func clear(){
        pending = nil
        accumulator = 0.0
        internalProgram.removeAll()
        description = " "
        isPartialResult = false
    }
    
    typealias PropertyList = AnyObject
    
    var program : PropertyList{
        get {
            return internalProgram
        }
        set{
            self.clear()
            if let ArrayOfOps = newValue as? [AnyObject]{
                for op in ArrayOfOps{
                    if let operand = op as? Double{
                        self.setOperand(operand)
                    }
                    else if let operation = op as? String{
                        self.performOperation(operation)
                    }
                }
            }
        }
    }
}


