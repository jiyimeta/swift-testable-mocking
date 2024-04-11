protocol CounterProtocol {
    var count: Int { get set }
    var title: String { get }

    func doNothing()
    func doSomething() -> Int
    func doSomething(with parameter: Int) throws -> Int
}
