import SwiftUI
import WebKit
import ArgumentParser

struct WebCLIArguments: ParsableCommand {
    @Argument(help: "URL or HTML file")
    var target: String
    
    @Option(name: .shortAndLong, help: "Window width")
    var width: Int? = nil
    
    @Option(name: .shortAndLong, help: "Window height")
    var height: Int? = nil

    @Option(name: .long, help: "Minimum window width, cannot be used with --width")
    var minWidth: Int? = nil

    @Option(name: .long, help: "Minimum window height, cannot be used with --height")
    var minHeight: Int? = nil
    
    @Option(name: .long, help: "Maximum window width, cannot be used with --width")
    var maxWidth: Int? = nil

    @Option(name: .long, help: "Maximum window height, cannot be used with --height")
    var maxHeight: Int? = nil

    @Flag(name: .shortAndLong, help: "Allow developer tools")
    var devTools: Bool = false
    
    func validate() throws {
        if let _ = minWidth, let _ = width {
            throw ValidationError("Cannot use --width and --min-width together")
        }
        if let _ = minHeight, let _ = height {
            throw ValidationError("Cannot use --height and --min-height together")
        }
    }
    
    mutating func run() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        WebViewApp.main()
    }
}

extension WebCLIArguments {
    func update(_ viewModel: WebViewAppModel) {
        viewModel.url = target
        viewModel.allowDevTools = devTools

        if let width = width {
            viewModel.minWidth = width
            viewModel.maxWidth = width
        } else {
            viewModel.minWidth = minWidth
            viewModel.maxWidth = maxWidth
        }
        if let height = height {
            viewModel.minHeight = height
            viewModel.maxHeight = height
        } else {
            viewModel.minHeight = minHeight
            viewModel.maxHeight = maxHeight
        }
    }
}

WebCLIArguments.main()
