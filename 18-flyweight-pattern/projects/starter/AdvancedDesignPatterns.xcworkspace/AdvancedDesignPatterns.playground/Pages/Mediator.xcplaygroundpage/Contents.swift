/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Mediator
 - - - - - - - - - -
 ![Mediator Diagram](Mediator_Diagram.png)
 
 The mediator pattern is a behavioral design pattern that encapsulates how objects communicate with one another. It involves four types:
 
 1. The **colleagues** are the objects that want to communicate with each other. They implement the colleague protocol.
 
 2. The **colleague protocol** defines methods and properties that each colleague must implement.
 
 3. The **mediator** is the object that controls the communication of the colleagues. It implements the mediator protocol.
 
 4. The **mediator protocol** defines methods and properties that the mediator must implement.
 
 ## Code Example
 */
// MARK: - Colleague Protocol
public protocol Colleague: AnyObject {
  func colleague(_ colleague: Colleague?,
                 didSendMessage message: String)
}

// MARK: - Mediator Protocol
public protocol MediatorProtocol: AnyObject {
  func addColleague(_ colleague: Colleague)
  func sendMessage(_ message: String, by colleague: Colleague)
}

// MARK: - Colleague
// 1
public class Musketeer {

  // 2
  public var name: String
  public weak var mediator: MediatorProtocol?

  // 3
  public init(mediator: MediatorProtocol, name: String) {
    self.mediator = mediator
    self.name = name
    mediator.addColleague(self)
  }

  // 4
  public func sendMessage(_ message: String) {
    print("\(name) sent: \(message)")
    mediator?.sendMessage(message, by: self)
  }
}

extension Musketeer: Colleague {
  public func colleague(_ colleague: Colleague?,
                        didSendMessage message: String) {
    print("\(name) received: \(message)")
  }
}

// MARK: - Mediator
// 1
public class MusketeerMediator: Mediator<Colleague> {

}

extension MusketeerMediator: MediatorProtocol {

  // 2
  public func addColleague(_ colleague: Colleague) {
    self.addColleague(colleague, strongReference: true)
  }

  // 3
  public func sendMessage(_ message: String,
                          by colleague: Colleague) {
    invokeColleagues(by: colleague) {
      $0.colleague(colleague, didSendMessage: message)
    }
  }
}
// MARK: - Example
let mediator = MusketeerMediator()
let athos = Musketeer(mediator: mediator, name: "Athos")
let porthos = Musketeer(mediator: mediator, name: "Porthos")
let aramis = Musketeer(mediator: mediator, name: "Aramis")

athos.sendMessage("One for all...!")
print("")

porthos.sendMessage("and all for one...!")
print("")

aramis.sendMessage("Unus pro omnibus, omnes pro uno!")
print("")


mediator.invokeColleagues() {
  $0.colleague(nil, didSendMessage: "Charge!")
}







