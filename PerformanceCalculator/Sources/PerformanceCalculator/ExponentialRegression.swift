import Foundation

func exponentialRegression(inputX: [Double], inputY: [Double], newX: [Double]) -> [Double] {
    guard inputX.count == inputY.count, inputX.count > 1 else {
        // Check if input arrays have valid data
        return []
    }
    
    // Calculate the natural logarithm of inputY
    let logInputY = inputY.map { log($0) }
    
    // Calculate the coefficients of the exponential regression equation (a and b)
    let sumX = inputX.reduce(0, +)
    let sumLogInputY = logInputY.reduce(0, +)
    let sumXLogInputY = zip(inputX, logInputY).map { $0 * $1 }.reduce(0, +)
    let sumXSquare = inputX.map { $0 * $0 }.reduce(0, +)
    
    let n = Double(inputX.count)
    let b = (n * sumXLogInputY - sumX * sumLogInputY) / (n * sumXSquare - sumX * sumX)
    let a = (sumLogInputY - b * sumX) / n
    
    // Calculate the new values using the exponential regression equation
    let newY = newX.map { x in
        return exp(a) * exp(b * x)
    }
    
    return newY
}
