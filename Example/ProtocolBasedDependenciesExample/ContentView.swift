import ProtocolBasedDependencies
import SwiftUI

@MemberAttribute
struct Foo {
    // @Peer
    func doSomething(_ value: Int) -> String {
        "Message"
    }
}

struct ContentView: View {
    var text: String {
        let a = 17
        let b = 25
        let (result, code) = #stringify(a + b)
        return "\(result), \(code)"
    }

    var body: some View {
        VStack {
            Text(text)
        }
    }
}

#Preview {
    ContentView()
}
