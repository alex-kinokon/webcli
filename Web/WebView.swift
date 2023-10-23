import SwiftUI
import WebKit

final class WebViewAppModel: ObservableObject {
    @Published var url: String = "https://example.com"
    @Published var minWidth: Int?
    @Published var minHeight: Int?
    @Published var maxWidth: Int?
    @Published var maxHeight: Int?
    @Published var allowDevTools: Bool = false
}

struct WebViewApp: App {
    @State var pageTitle = "Safari"
    @StateObject var model: WebViewAppModel = {
        let model = WebViewAppModel()
        do {
            let args = try WebCLIArguments.parse()
            args.update(model)
        } catch {
            print("Error: Could not parse arguments")
            print(CommandLine.arguments.dropFirst().joined(separator: " "))
            print(WebCLIArguments.helpMessage())
            exit(1)
        }
        return model
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
                .frame(
                    minWidth: model.minWidth?.float(),
                    maxWidth: model.maxWidth?.float(),
                    minHeight: model.minHeight?.float(),
                    maxHeight: model.maxHeight?.float()
                )
        }.windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @State var pageTitle = "Safari"
    @StateObject var model: WebViewAppModel

    var body: some View {
        WebView(
            title: $pageTitle,
            allowDevTools: $model.allowDevTools,
            url: URL(string: model.url)!
        )
            .navigationTitle(pageTitle)
    }
}

extension Int {
    func float() -> CGFloat {
        return CGFloat(self)
    }
}

struct WebView: NSViewRepresentable {
    @Binding var title: String
    @Binding var allowDevTools: Bool
    
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        webView.navigationDelegate = context.coordinator
        webView.configuration.preferences.setValue(allowDevTools, forKey: "developerExtrasEnabled")
        context.coordinator.observeTitleUpdate(for: webView)

        loadURL(webView: webView, context: context)

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        loadURL(webView: nsView, context: context)
    }

    private func loadURL(webView: WKWebView, context: Context) {
        guard context.coordinator.lastLoadedURL != url else {
            return
        }

        context.coordinator.lastLoadedURL = url

        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($title)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let title: Binding<String>
        var lastLoadedURL: URL?
        private var titleObservation: NSKeyValueObservation?

        init(_ title: Binding<String>) {
            self.title = title
        }

        func observeTitleUpdate(for webView: WKWebView) {
            titleObservation = webView.observe(\.title) { [weak self] webView, _ in
                self?.title.wrappedValue = webView.title ?? ""
            }
        }
    }
}
