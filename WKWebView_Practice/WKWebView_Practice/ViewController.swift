//
//  ViewController.swift
//  WKWebView_Practice
//
//  Created by 栗須　星舞 on 2025/06/03.
//

import UIKit
import WebKit

enum StandardScheme: String {
    case tel
}

class ViewController: UIViewController {
    private var webview: WKWebView!
    private let googleUrl = URL(string: "https://binbingin.com/")!
    
    override func loadView() {
        super.loadView()
        
        // WKWebViewConfiguration
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "MyApp/1.0"
        
        // websiteDataStore
        // WebViewのセッションや保存データを保持するか／保持しないか
        // .default()はSafariと同じような仕組みでデータを保持する
        // .nonPersistent()はアプリを閉じると全ての情報が破棄される
        webConfiguration.websiteDataStore = .default()
        webConfiguration.upgradeKnownHostsToHTTPS = false
        // 自動再生の制御
        webConfiguration.mediaTypesRequiringUserActionForPlayback = [.video]
        
        // コンテンツの細かい設定
        let preference = WKPreferences()
        preference.minimumFontSize = 17
        preference.isSiteSpecificQuirksModeEnabled = false
        
        webConfiguration.preferences = preference
        
        //WKUserContentController
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "myHandler")
        webConfiguration.userContentController = userContentController
        
        // JS注入
        let userScript = WKUserScript(source: "alert('Loaded!')",
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        userContentController.addUserScript(userScript)

        webview = WKWebView(frame: .zero, configuration: webConfiguration)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.underPageBackgroundColor = .clear
        
        webview.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                print("🍪 \(cookie.name): \(cookie.value)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webview)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        setCookie()
        setWebViewSetting(.loadHTMLString)
    }
    
    private func setCookie() {
        if let cookie = HTTPCookie(properties: [
            .domain: "google.com",
            .path: "/",
            .name: "session_id",
            .value: "",
            .secure: true,
            .expires: Date().addingTimeInterval(60 * 60 * 24 * 30)
        ]) {
            let cookieStore = webview.configuration.websiteDataStore.httpCookieStore
            cookieStore.setCookie(cookie)
        } else {
            print("クッキーの設定に失敗しました。")
        }
    }
}

extension ViewController {
    enum WebViewSetting {
        case loadURL
        case loadMimeTypeWithData
        case loadHTMLString
    }
    
    private func setWebViewSetting(_ setting: WebViewSetting) {
        switch setting {
        case .loadURL:
            webview.load(URLRequest(url: googleUrl, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10))
        case .loadMimeTypeWithData:
            let imagePath = Bundle.main.path(forResource: "download", ofType: "jpg")!
            let imageUrl = URL(fileURLWithPath: imagePath)
            if let imageData = try? Data(contentsOf: imageUrl) {
                webview.load(imageData, mimeType: "image/jpg", characterEncodingName: "", baseURL: imageUrl)
            }
        case .loadHTMLString:
            let html = """
            <!DOCTYPE html>
            <html>
            <body>
            <h2>写真をアップロード</h2>
            <form>
              <input type="file" accept="image/*">
            </form>
            <button onclick="sendMessage()">送信</button>
                        <script>
                          function sendMessage() {
                            window.webkit.messageHandlers.myHandler.postMessage("こんにちは、Swift！")
                          }
                        </script>
            <button onclick="window.open('https://google.com')">新規タブを開く</button>
            </body>
            </html>
            """
            let baseURL = Bundle.main.bundleURL
            webview.loadHTMLString(html, baseURL: baseURL)
        }
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        guard let url = navigationAction.request.url, let scheme = url.scheme else {
            decisionHandler(.cancel, preferences)
            return
        }
        if WKWebView.handlesURLScheme(scheme) {
            print("許可されているスキーム")
        } else {
            print("許可されていないスキーム")
        }
        if url.scheme == StandardScheme.tel.rawValue {
            // OS側で対応するのでWebViewで開かない
            decisionHandler(.cancel, preferences)
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "myHandler":
            print("通知を受け取りました message: \(message.body)")
        default:
            break
        }
    }
}
