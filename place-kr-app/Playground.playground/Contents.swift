import Foundation

struct Animal {
    struct Cat {
        let description = "It's a cat"
    }
    
    struct Dog {
        let description = "It's a dog"
    }
}

// Restrict its input to one of the properties of Animal
func feedAnimal(type: Animal.Cat) {
    print(type.description)
}

feedAnimal(type: Animal.Cat())
// It's a cat
