/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Observer
 - - - - - - - - - -
 ![Observer Diagram](Observer_Diagram.png)
 
 The observer pattern allows "observer" objects to register for and receive updates whenever changes are made to "subject" objects.
 
 This pattern allows us to define "one-to-many" relationships between many observers receiving updates from the same subject.
 
 ## Code Example
 */
// 1
import Combine

// 2
public class User {
    
    // 3
    @Published var name: String
    
    // 4
    public init(name: String) {
        self.name = name
    }
}

// 1
let user = User(name: "Ray")

// 2
let publisher = user.$name

// 3
var subscriber: AnyCancellable? = publisher.sink() {
    print("User's name is \($0)")
}

// 4
user.name = "Vicki"

subscriber = nil
user.name = "Ray has left the building"

