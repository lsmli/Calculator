//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Lisa S Li on 7/25/17.
//  Copyright © 2017 Lisa S Li. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum SequenceValue {
        case OperandValue(Double)
        case VariableValue(String)
        case OperationValue(String)
    }
    private var operationSequence = [SequenceValue]()
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String) {
        var accumulator = 0.0
        var descriptionAccumulator = ""
        var description = ""
        var pending: PendingBinaryOperationInfo?
        var isPartialResult: Bool {
            get {
                return pending != nil
            }
        }
        var displayDescription: String {
            get{
                if isPartialResult{
                    return description
                } else {
                    description = descriptionAccumulator
                    return description
                }
            }
        }
            
        func performOperation(symbol:String) {
            if let operation = operations[symbol]
            {
                switch operation{
                case .Constant(let value, let descriptionValue):
                    accumulator = value
                    descriptionAccumulator = descriptionValue
                case .UnaryOperation(let function, let descriptionFunction):
                    accumulator = function(accumulator)
                    descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                    if isPartialResult{
                        description = pending!.binaryDescription(pending!.descriptionOperand, descriptionAccumulator)
                    }
                case .BinaryOperation(let function, let descriptionFunction):
                    executePendingBinaryOperation()
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, binaryDescription: descriptionFunction, descriptionOperand: descriptionAccumulator)
                    description = pending!.binaryDescription(pending!.descriptionOperand, "")
                case .Equals:
                    executePendingBinaryOperation()
                }
            }
        }
            
        func executePendingBinaryOperation()
        {
            if pending != nil {
                descriptionAccumulator = pending!.binaryDescription(pending!.descriptionOperand, descriptionAccumulator)
                accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
                pending = nil
            }
        }
            
        struct PendingBinaryOperationInfo {
            var binaryFunction: (Double, Double) -> Double
            var firstOperand: Double
            var binaryDescription: (String, String) -> String
            var descriptionOperand: String
        }
            
        for step in operationSequence {
            switch step{
            case .OperandValue(let doubleOperand):
                accumulator = doubleOperand
                descriptionAccumulator = formatNumber(numberToFormat: doubleOperand)
            case .VariableValue(let stringOperand):
                accumulator = variables?[stringOperand] ?? 0
                descriptionAccumulator = stringOperand
            case .OperationValue(let stringOperation):
                performOperation(symbol: stringOperation)
            }
        }
        return(result: accumulator, isPending: isPartialResult, description: displayDescription)
    }
    
    func performOperation(symbol: String) {
        operationSequence.append(SequenceValue.OperationValue(symbol))
    }
    
    func setOperand(variable named: String) {
        operationSequence.append(SequenceValue.VariableValue(named))
    }
    
    func setOperand(operand: Double) {
        operationSequence.append(SequenceValue.OperandValue(operand))
    }
    
    func clear() {
        operationSequence = []
    }
    
    func undo() {
        if !operationSequence.isEmpty {
            operationSequence.removeLast()
        }
    }
    
    private func formatNumber(numberToFormat: Double) -> (String){
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumIntegerDigits = 1
        let formattedString = formatter.string(from: numberToFormat as NSNumber)!
        return formattedString
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(Double.pi, "π"),
        "e": Operation.Constant(M_E, "e"),
        "√": Operation.UnaryOperation(sqrt, {"√(" + $0 + ")"}),
        "cos": Operation.UnaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin": Operation.UnaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan": Operation.UnaryOperation(tan, {"tan(" + $0 + ")"}),
        "+/-": Operation.UnaryOperation({-$0}, {"-(" + $0 + ")"}),
        "xʸ": Operation.BinaryOperation({pow($0,$1)}, {$0 + "^" + $1}),
        "×": Operation.BinaryOperation({$0 * $1}, {$0 + "x" + $1}),
        "÷": Operation.BinaryOperation({$0 / $1}, {$0 + "÷" + $1}),
        "+": Operation.BinaryOperation({$0 + $1}, {$0 + "+" + $1}),
        "−": Operation.BinaryOperation({$0 - $1}, {$0 + "-" + $1}),
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double, String)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double,Double) -> Double, (String,String) -> String)
        case Equals
    }
    
    var result: Double {
        get {
            return evaluate().result!
        }
    }
    
    var description: String {
        get {
            return evaluate().description
        }
    }
    
    var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }
    
}
