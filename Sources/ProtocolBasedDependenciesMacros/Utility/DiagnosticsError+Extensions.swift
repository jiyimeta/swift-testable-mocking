import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacroExpansion

extension DiagnosticsError {
    init(
        _ message: String,
        at node: some SyntaxProtocol
    ) {
        self.init(
            diagnostics: [
                Diagnostic(
                    node: node,
                    message: MacroExpansionErrorMessage(message)
                )
            ]
        )
    }
}
