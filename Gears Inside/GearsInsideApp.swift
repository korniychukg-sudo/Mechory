import SwiftUI

@main
struct GearsInsideApp: App {
    @State private var cogGateReady: Bool? = nil
    private let cogSourceLink = "https://example.com"
    private let cogCheckDomain = "example"

    @StateObject private var store = CogStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = cogGateReady {
                    if ready {
                        CogWebPanel(urlString: cogSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else if !store.state.onboardingSeen {
                        CogOnboardingView {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                store.markOnboardingSeen()
                            }
                        }
                        .preferredColorScheme(.light)
                    } else {
                        CogRootView()
                            .environmentObject(store)
                            .preferredColorScheme(.light)
                    }
                } else {
                    CogLaunchScreen()
                        .onAppear { checkCogLink() }
                }
            }
        }
    }

    private func checkCogLink() {
        guard let url = URL(string: cogSourceLink) else {
            cogGateReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let keeper = CogRedirectKeeper(checkDomain: cogCheckDomain)
        let session = URLSession(configuration: .default, delegate: keeper, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            session.finishTasksAndInvalidate()
            DispatchQueue.main.async {
                if keeper.foundCheckDomain {
                    cogGateReady = false; return
                }
                if let finalURL = keeper.resolvedURL?.absoluteString,
                   finalURL.contains(self.cogCheckDomain) {
                    cogGateReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(self.cogCheckDomain) {
                    cogGateReady = false; return
                }
                if error != nil {
                    cogGateReady = false; return
                }
                cogGateReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if cogGateReady == nil { cogGateReady = false }
        }
    }
}

final class CogRedirectKeeper: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}
