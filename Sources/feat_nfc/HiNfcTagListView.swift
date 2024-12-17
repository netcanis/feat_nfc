//
//  HiNfcTagListView.swift
//  feat_nfc
//
//  Created by netcanis on 11/20/24.
//

import SwiftUI

/// A SwiftUI view for displaying scanned NFC tag information.
/// - The scanned date and payload data are displayed in a list.
public struct HiNfcTagListView: View {
    /// An array storing scanned NFC tag data with date and payload.
    @State private var tags: [(date: Date, payload: String)] = []

    /// Dismiss environment for closing the current view.
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initializer
    /// Initializes the NFC tag list view.
    public init() {}

    // MARK: - Body
    public var body: some View {
        VStack {
            /// Displays scanned NFC data in a list format.
            List(tags, id: \.payload) { result in
                VStack(alignment: .leading) {
                    Text("Scanned Date: \(result.date.formatted())") // Display the date of scan
                    Text("Payload: \(result.payload)") // Display the payload content
                }
            }
            .navigationTitle("NFC Scans") // Set the navigation title
            .navigationBarTitleDisplayMode(.inline) // Center align the navigation title
            .onAppear(perform: startNfcScan) // Start NFC scanning when the view appears
            .onDisappear { HiNfcScanner.shared.stop() } // Stop NFC scanning when the view disappears
        }
    }

    // MARK: - Start NFC Scanning
    /// Starts the NFC scanning process.
    /// - If a duplicate payload exists, it updates the existing data.
    /// - If a new payload is detected, it adds it to the list.
    private func startNfcScan() {
        HiNfcScanner.shared.start { result in
            let payload = result.data
            if let index = tags.firstIndex(where: { $0.payload == payload }) {
                // Update existing NFC data if payload is duplicate
                tags[index] = (date: Date(), payload: payload)
                print("Updated NFC Payload: \(payload)")
            } else {
                // Append new NFC data to the list
                tags.append((date: Date(), payload: payload))
                print("Added new NFC Payload: \(payload)")
            }

            /// Stop scanning if the payload starts with "ubpay" or "DEMOKIT"
            if payload.hasPrefix("ubpay") || payload.hasPrefix("DEMOKIT") {
                HiNfcScanner.shared.stop()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HiNfcTagListView()
}
