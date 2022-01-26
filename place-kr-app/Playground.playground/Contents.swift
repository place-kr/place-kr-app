import UIKit

var greeting = "123456"

func formatter(_ number: String) -> String {
    var x = Array(number)
    
    if x.count >= 4 {
        for i in 0..<(number.count / 3) {
            var mult = i * 3
            var position = (number.count % 3) + mult + 1
            x.insert(",", at: position)
        }
    }
    
    return String(x)
}

formatter(greeting)


4 = 1
5 = 2
6 = 3
7 = 1, 4
8 = 2, 5
9 = 3, 6
10 = 1, 4, 7 -> (x % 3) + 0, 3, 6

