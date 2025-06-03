//
//  MarkdownView.swift
//  markdown-webview
//
//  Created by Mac Mini on 29.05.2025.
//

import UIKit
import WebKit

public class MarkdownView: UIView {
    
    public var webView: WKWebView
    public var markdownContent: String
    private var customStylesheet: String?
    
    private var mainFont: UIFont
    private var textColor: String
    private var linkColor: String
    private var opacity: CGFloat
    
    public var onTapLink: ((URL) -> Void)?
    public var renderedContentHandler: ((String) -> Void)?
    public var sizeChangeHandler: ((CGSize) -> Void)?
    
    public init(
        markdownContent: String,
        customStylesheet: String? = nil,
        mainFont: UIFont = .systemFont(ofSize: 17),
        textColor: String = "#FFFFFF",
        linkColor: String = "#3ACF9A",
        opacity: CGFloat = 0.85
    ) {
        self.markdownContent = markdownContent
        self.customStylesheet = customStylesheet
        self.mainFont = mainFont
        self.textColor = textColor
        self.linkColor = linkColor
        self.opacity = opacity
        
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        super.init(frame: .zero)
        
        self.webView.navigationDelegate = self
        self.webView.isOpaque = false
        self.webView.scrollView.isScrollEnabled = false
        self.webView.backgroundColor = .clear
        
        self.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        userContentController.add(self, name: "sizeChangeHandler")
        userContentController.add(self, name: "renderedContentHandler")
        userContentController.add(self, name: "copyToPasteboard")
        
        loadHTML()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadHTML() {
        let bundle = Bundle.module
        guard
            let templateURL = bundle.url(forResource: "template", withExtension: ""),
            let template = try? String(contentsOf: templateURL),
            let scriptURL = bundle.url(forResource: "script", withExtension: ""),
            let script = try? String(contentsOf: scriptURL),
            let stylesheetURL = bundle.url(forResource: "default-iOS", withExtension: ""),
            var defaultStylesheet = try? String(contentsOf: stylesheetURL)
        else {
            print("Failed to load resources.")
            return
        }
        
        defaultStylesheet = defaultStylesheet
            .replacingOccurrences(of: "PLACEHOLDER_COLOR", with: textColor)
            .replacingOccurrences(of: "PLACEHOLDER_LINK_COLOR", with: linkColor)
            .replacingOccurrences(of: "PLACEHOLDER_FONT", with: "system-ui")
            .replacingOccurrences(of: "PLACEHOLDER_SIZE_FONT", with: "\(mainFont.pointSize)px")
            .replacingOccurrences(of: "PLACEHOLDER_LINE_HEIGHT", with: "1.5")
            .replacingOccurrences(of: "PLACEHOLDER_OPACITY", with: "\(opacity)")
        
        let html = template
            .replacingOccurrences(of: "PLACEHOLDER_SCRIPT", with: script)
            .replacingOccurrences(of: "PLACEHOLDER_STYLESHEET", with: customStylesheet ?? defaultStylesheet)
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    public func updateMarkdownContent(_ content: String) {
        self.markdownContent = content
        guard let encoded = content.data(using: .utf8)?.base64EncodedString() else { return }
        webView.callAsyncJavaScript("window.updateWithMarkdownContentBase64Encoded(`\(encoded)`)", in: nil, in: .page, completionHandler: nil)
    }
}

// MARK: - WKNavigationDelegate, WKScriptMessageHandler

extension MarkdownView: WKNavigationDelegate, WKScriptMessageHandler {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateMarkdownContent(markdownContent)
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url {
            
            if let handler = onTapLink {
                handler(url)
            } else {
                UIApplication.shared.open(url)
            }
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "sizeChangeHandler":
            if let height = message.body as? CGFloat {
                invalidateIntrinsicContentSize()
                frame.size.height = height
                sizeChangeHandler?(self.frame.size)
            }
        case "renderedContentHandler":
            if let base64 = message.body as? String,
               let data = Data(base64Encoded: base64),
               let result = String(data: data, encoding: .utf8) {
                renderedContentHandler?(result)
            }
        case "copyToPasteboard":
            if let base64 = message.body as? String {
                let str = String(data: Data(base64Encoded: base64) ?? Data(), encoding: .utf8) ?? ""
                UIPasteboard.general.string = str
            }
        default:
            break
        }
    }
}

extension String {
    func copyToPasteboard() {
        UIPasteboard.general.string = self
    }
}
