//
//  MarkdownWebView.swift
//  markdown-webview
//
//  Created by Mac Mini on 29.05.2025.
//

import SwiftUI

public struct MarkdownWebView: UIViewRepresentable {
    let markdownContent: String
    let customStylesheet: String?
    let onLinkTap: ((URL) -> Void)?
    let onRendered: ((String) -> Void)?
    let onSizeChange: ((CGSize) -> Void)?
    
    public init(_ markdownContent: String,
                customStylesheet: String? = nil,
                onLinkTap: ((URL) -> Void)? = nil,
                onRendered: ((String) -> Void)? = nil,
                onSizeChange: ((CGSize) -> Void)? = nil
    ) {
        self.markdownContent = markdownContent
        self.customStylesheet = customStylesheet
        self.onLinkTap = onLinkTap
        self.onRendered = onRendered
        self.onSizeChange = onSizeChange
    }

    public func makeUIView(context: Context) -> MarkdownView {
        let view = MarkdownView(markdownContent: markdownContent, customStylesheet: customStylesheet)
        view.onTapLink = onLinkTap
        view.renderedContentHandler = onRendered
        view.sizeChangeHandler = onSizeChange
        return view
    }

    public func updateUIView(_ uiView: MarkdownView, context: Context) {
        uiView.updateMarkdownContent(markdownContent)
    }
}
