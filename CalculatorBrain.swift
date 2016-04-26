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
    
    private let piSymbol = "π"
    private let eSymbol = "e"
    private let zeroSymbol = "0"
    private let squareRootSymbol = "√"
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    private var operations = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
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
            
            switch operation {
            case .Constant (let value):
                accumulator = value
            case .UnaryOperation (let function):
                accumulator = function(accumulator)
            case .BinaryOperation (let function):
                executePendingBinaryOperation()
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()            }
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
}


