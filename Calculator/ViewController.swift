//
//  ViewController.swift
//  Calculator
//
//  Created by Lisa S Li on 7/19/17.
//  Copyright © 2017 Lisa S Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var sequenceDisplay: UILabel!
    @IBOutlet private weak var variableDisplay: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    private var variableValues = Dictionary<String,Double>()
    private var clearSequenceDisplay = false
    
    private var displayValue: Double {
        get{
            return Double(display.text!)!
        }
        set {
            display.text = formatNumber(numberToFormat: newValue)
        }
    }
    
    @IBAction func clearVariable(_ sender: UIButton) {
        variableValues = [:]
        brain.clear()
        updateDisplay()
    }
    
    private func updateDisplay() {
        let isPendingResult = brain.evaluate(using: variableValues).isPending
        let currentDescription = brain.evaluate(using: variableValues).description
        if currentDescription.isEmpty {
            sequenceDisplay.text = String(0)
        } else{
            if isPendingResult {
                sequenceDisplay.text = currentDescription + " ..."
            } else {
                sequenceDisplay.text = currentDescription + " ="
            }
        }
        displayValue = brain.evaluate(using: variableValues).result!
        let variableValue = variableValues["M"] ?? 0
        variableDisplay.text = formatNumber(numberToFormat: variableValue)
    }
    
    private func formatNumber(numberToFormat: Double) -> (String){
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumIntegerDigits = 1
        let formattedString = formatter.string(from: numberToFormat as NSNumber)!
        return formattedString
    }
    
    @IBAction func touchM(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        updateDisplay()
    }
    
    @IBAction func sendM(_ sender: Any) {
        variableValues = ["M" : displayValue]
        userIsInTheMiddleOfTyping = false
        updateDisplay()
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if !(display.text?.isEmpty)! {
                display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            }
            if (display.text?.isEmpty)! {
                displayValue = 0
                userIsInTheMiddleOfTyping = false
            }
        } else {
            brain.undo()
            updateDisplay()
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        var digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit == "." && textCurrentlyInDisplay.range(of:".") != nil{
                digit = ""
            }
            display.text = textCurrentlyInDisplay + digit
        } else {
            if digit == "." {
                display.text = String(0) + digit
            }else{
                display.text = digit
            }
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        updateDisplay()
    }
    
}

