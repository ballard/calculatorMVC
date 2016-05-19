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
    private var isAccumulatorSet = false
    private var isUnaryOperationPerformed = false
    
    private var internalProgram  = [AnyObject]()
    
    var description = ""
    
    private var isPartialResult = false
    
    let descriptionNumberFormatter = NSNumberFormatter()
    
    static func formatOperand (operandNumberFormatter: NSNumberFormatter, operand: Double) -> String {
        if operand % 1 == 0 {
            operandNumberFormatter.allowsFloats = false
        } else {
            operandNumberFormatter.allowsFloats = true
            operandNumberFormatter.minimumIntegerDigits = 1
            operandNumberFormatter.maximumFractionDigits = 6
        }
        return operandNumberFormatter.stringFromNumber(operand)!
    }

    func setOperand(operand: Double) {
        accumulator = operand
        isAccumulatorSet = true
        internalProgram.append(operand)
        if description.rangeOfString("...") != nil {
            let range = description.endIndex.advancedBy(-3)..<description.endIndex
            description.removeRange(range)
        }
        let operandString = CalculatorBrain.formatOperand(descriptionNumberFormatter, operand: operand)
        
        if !isPartialResult || isUnaryOperationPerformed {
            if isUnaryOperationPerformed {
                pending = nil
            }
            description = operandString
            isUnaryOperationPerformed = false
        } else {
            description += operandString
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
    
    var constantOperations: Set<Character> = ["π", "e"]
    var binaryOperationSymbols: Set<Character> = ["+","−","÷","×"]
    
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
                isAccumulatorSet = true
                removeSymbol("...")
                if isPartialResult {
                    if constantOperations.contains(description.characters.last!)  {
                        description.removeAtIndex(description.characters.endIndex.predecessor())
                    }
                    description += symbol
                } else {
                    description = symbol
                }
            case .UnaryOperation (let function):
                if isPartialResult {
                    var latestSymbol: Character = "0"
                    var DescriptionCharacterIndex = 0
                    var maxDescriptionCharacterIndex = 0
                    var binaryOperationSymbolsCount = 0
                    for descriptionCharacter in description.characters {
                            if binaryOperationSymbols.contains(descriptionCharacter) {
                                if DescriptionCharacterIndex > maxDescriptionCharacterIndex {
                                    maxDescriptionCharacterIndex = DescriptionCharacterIndex
                                    latestSymbol = descriptionCharacter
                                    binaryOperationSymbolsCount += 1
                                }
                            }
                            DescriptionCharacterIndex += 1
                    }
                    if binaryOperationSymbolsCount > 0 && !isAccumulatorSet {
                        removeSymbol("...")
                        if pending != nil {
                            removeLastBinaryOperationSymbol()
                            accumulator = function(pending!.firstOperand)
                            description = String("\(symbol)(\(description))")
                            isPartialResult = false
                            pending = nil
                            return
                        }
                    }
                    var reversedString = String(description.characters.reverse())
                    if let plusRange = reversedString.rangeOfString(String(latestSymbol)) {
                        let range = Range(reversedString.startIndex..<plusRange.endIndex.predecessor())
                        reversedString.removeRange(range)
                        description = String(reversedString.characters.reverse())
                        if accumulator == M_PI {
                            description.insertContentsOf("\(symbol)π".characters, at: description.endIndex)
                        } else if accumulator == M_E {
                            description.insertContentsOf("\(symbol)e".characters, at: description.endIndex)
                        } else {
                            description.insertContentsOf("\(symbol)(\(CalculatorBrain.formatOperand(descriptionNumberFormatter, operand: accumulator)))...".characters, at: description.endIndex)
                        }
                    }
                }
                accumulator = function(accumulator)
                if !isPartialResult{
                    removeSymbol("=")
                    description = "\(symbol)(\(description))"
                }
                isUnaryOperationPerformed = true
            case .BinaryOperation (let function):
                if isUnaryOperationPerformed {
                    return
                }
                removeSymbol("...")
                print("symbol is : \(symbol)")
                print("last character is: \(description.characters.last)")
                if !isAccumulatorSet && pending != nil {
                    if symbol != String(description.characters.last) {
                        pending!.binaryFunction = function
                        removeLastBinaryOperationSymbol()
                        description += symbol + "..."
                    }
                    return
                }
                insertAccumulatorValueIsteadOfPoints()
                executePendingBinaryOperation()
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                removeSymbol("=")
                description += symbol + "..."
                isPartialResult = true
                isAccumulatorSet = false
            case .Equals:
                if isUnaryOperationPerformed {
                    removeSymbol("...")
                    removeSymbol("=")
                    isUnaryOperationPerformed = false
                }
                insertAccumulatorValueIsteadOfPoints()
                executePendingBinaryOperation()
                description += symbol
                isPartialResult = false
            }
        }
    }
    
    private func removeLastBinaryOperationSymbol(){
        if binaryOperationSymbols.contains(description.characters.last!) {
            description.removeAtIndex(description.characters.endIndex.predecessor())
        }
    }
    
    private func insertAccumulatorValueIsteadOfPoints(){
        if let pointsRange = description.rangeOfString("..."){
            description.removeRange(pointsRange)
            if accumulator == M_PI {
                description = ("\(description)π")
            } else if accumulator == M_E {
                description = ("\(description)e")
            } else {
                description = ("\(description)\(CalculatorBrain.formatOperand(descriptionNumberFormatter, operand: accumulator))")
            }
        }
    }
    
    private func removeSymbol(symbol: String){
        if let symbolRange = description.rangeOfString(symbol){
            description.removeRange(symbolRange)
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


