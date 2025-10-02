//
//  OnboardingViews.swift
//  SituationistsWalkman
//
//  Created by msp on 15/9/25.
//

import SwiftUI
import WebKit

// MARK: - Reusable Components

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.configuration.allowsInlineMediaPlayback = true

        // YouTube embed URL
        let embedURL = "https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&showinfo=0&controls=1"
        if let url = URL(string: embedURL) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
}

struct OnboardingTitle: View {
    var body: some View {
        Text("app-title")
            .fontWeight(.bold)
            .font(.largeTitle)
            .foregroundColor(Color(highlightColor))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 20)
    }
}

struct OnboardingContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 40) {
            OnboardingTitle()
            content
        }
        .padding(.horizontal, 24)
    }
}

struct QuotesView: View {
    @State private var showQuote1 = false
    @State private var showAttribution1 = false
    @State private var showQuote2 = false
    @State private var showAttribution2 = false

    var body: some View {
        OnboardingContainer {
//                Spacer(minLength: 5)

                // Quote content - better distributed
                VStack(spacing: 30) {
                Text("quote-one")
                    .italic()
                    .font(.title3)
                    .foregroundColor(Color(textColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .opacity(showQuote1 ? 1 : 0)
                    .offset(y: showQuote1 ? 0 : 20)
                    .animation(.easeOut(duration: 0.8), value: showQuote1)
                
                Text("quote-one-attribution")
                    .foregroundColor(Color(textColor))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .opacity(showAttribution1 ? 1 : 0)
                    .offset(y: showAttribution1 ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: showAttribution1)
                
                Text("quote-two")
                    .italic()
                    .font(.title3)
                    .foregroundColor(Color(textColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .opacity(showQuote2 ? 1 : 0)
                    .offset(y: showQuote2 ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(1.0), value: showQuote2)
                
                Text("quote-two-attribution")
                    .foregroundColor(Color(textColor))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .opacity(showAttribution2 ? 1 : 0)
                    .offset(y: showAttribution2 ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(1.5), value: showAttribution2)
                }

                Spacer(minLength: 40)

                // Swipe hint - positioned to avoid tab dots
                Text("Swipe to continue →")
                    .foregroundColor(Color(highlightColor).opacity(0.8))
                    .font(.system(size: 16, weight: .medium))
                    .padding(.bottom, 80) // Increased space for tab dots on all devices
        }
        .onAppear {
            // Trigger animations in sequence
            showQuote1 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAttribution1 = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showQuote2 = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showAttribution2 = true
            }
        }
    }
}

struct BlurbView: View {
    @EnvironmentObject var state: AppState
    @State private var showBlurb = false
    @State private var showCTA = false
    @State private var showButtons = false

    var body: some View {
        OnboardingContainer {
            VStack(spacing: 25) {
            
            // Content - portrait optimized
            VStack(spacing: 40) {
                Text("blurb")
                    .foregroundColor(Color(textColor))
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .opacity(showBlurb ? 1 : 0)
                    .offset(y: showBlurb ? 0 : 30)
                    .animation(.easeOut(duration: 1.0), value: showBlurb)

                Text("cta")
                    .foregroundColor(Color(textColor))
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .opacity(showCTA ? 1 : 0)
                    .offset(y: showCTA ? 0 : 30)
                    .animation(.easeOut(duration: 1.0).delay(0.8), value: showCTA)
            }
            
            Spacer(minLength: 20)

            // Buttons - portrait optimized
            VStack(spacing: 12) {
                Button(action: {
                    print("Start Experience button tapped")
                    state.page = .checkingLocation
                }) {
                    Text("Start Experience")
                        .font(.headline)
                        .foregroundColor(Color(backgroundColor))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 280)
                        .background(Color(highlightColor))
                        .cornerRadius(12)
                }

                Button(action: {
                    print("View Credits button tapped")
                    state.page = .credits
                }) {
                    Text("View Credits")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(textColor))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 280)
                        .background(Color(textColor).opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .opacity(showButtons ? 1 : 0)
            .offset(y: showButtons ? 0 : 40)
            .animation(.spring().delay(1.5), value: showButtons)
            }
            .padding(.bottom, 80) // Space for tab dots
        }
        .onAppear {
            showBlurb = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showCTA = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showButtons = true
            }
        }
    }
}

struct VideoPlaceholderView: View {
    @Binding var currentPage: Int
    @EnvironmentObject var state: AppState
    @State private var showContent = false

    var body: some View {
        OnboardingContainer {
            VStack(spacing: 25) {

            // YouTube video - portrait optimized
            VStack(spacing: 20) {
                YouTubePlayerView(videoID: "nrmiL575ntI")
                    .frame(height: 200)
                    .frame(maxWidth: 320)
                    .cornerRadius(16)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .animation(.spring().delay(0.3), value: showContent)
                
                Text("Watch to learn about the experience")
                    .foregroundColor(Color(textColor))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: showContent)
            }

            Spacer(minLength: 20)

            // Next tab button - portrait optimized
            Button(action: {
                print("Next tab button tapped")
                currentPage = 2 // Go to OrientationView (next tab)
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(Color(backgroundColor))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 280)
                    .background(Color(highlightColor))
                    .cornerRadius(12)
            }
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.8).delay(1.2), value: showContent)
            }
            .padding(.bottom, 80) // Space for tab dots
        }
        .onAppear {
            showContent = true
        }
    }
}
