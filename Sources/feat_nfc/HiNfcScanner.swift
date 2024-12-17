//
//  HiNfcScanner.swift
//  feat_nfc
//
//  Created by netcanis on 11/1/24.
//

import CoreNFC
import UIKit

/// A class responsible for managing NFC scanning operations.
public class HiNfcScanner: NSObject, @unchecked Sendable {
    /// Shared singleton instance of `HiNfcScanner`.
    public static let shared = HiNfcScanner()

    private var isScanning: Bool = false
    private var scanCallback: ((HiNfcResult) -> Void)?
    private var nfcSession: NFCNDEFReaderSession?

    // MARK: - Start NFC Scanning
    /// Starts NFC scanning with a default alert message.
    /// - Parameter callback: The closure to handle scan results.
    @MainActor
    public func start(withCallback callback: @escaping (HiNfcResult) -> Void) {
        start(alertMessage: "Hold your device near an NFC tag.", withCallback: callback)
    }

    /// Starts NFC scanning with a custom alert message.
    /// - Parameters:
    ///   - alertMessage: Custom message displayed while scanning.
    ///   - callback: The closure to handle scan results.
    @MainActor
    public func start(alertMessage: String, withCallback callback: @escaping (HiNfcResult) -> Void) {
        guard !isScanning else {
            print("NFC scanning is already in progress.")
            return
        }

        // Ensure the app is active before starting the NFC session
        guard UIApplication.shared.applicationState == .active else {
            print("NFC scanning cannot start when the app is not active.")
            return
        }

        if hasRequiredPermissions() {
            self.scanCallback = callback
            isScanning = true
            // `invalidateAfterFirstRead` controls whether the session stops after the first tag read.
            nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            nfcSession?.alertMessage = alertMessage
            nfcSession?.begin()
        } else {
            showAlert(title: "NFC Alert", message: "NFC functionality is not available on this device.")
        }
    }

    // MARK: - Stop NFC Scanning
    /// Stops the current NFC scanning session.
    public func stop() {
        guard isScanning else { return }
        isScanning = false
        if let session = nfcSession {
            session.invalidate()
        }
        nfcSession = nil
    }

    /// Checks if NFC reading is available on the device.
    /// - Returns: A boolean indicating NFC availability.
    public func hasRequiredPermissions() -> Bool {
        return NFCNDEFReaderSession.readingAvailable
    }

    // MARK: - Helper Method for Alert
    /// Displays an alert message to the user.
    @MainActor
    private func showAlert(title: String, message: String) {
        if let topViewController = UIViewController.hiTopMostViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topViewController.present(alert, animated: true)
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension HiNfcScanner: NFCNDEFReaderSessionDelegate {
    /// Called when the NFC session becomes active.
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC Reader Session is now active.")
    }

    /// Called when an NDEF message is detected.
    /// - Parameters:
    ///   - session: The active NFC session.
    ///   - messages: The detected NDEF messages.
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let payloadString = String(data: record.payload, encoding: .utf8) {
                    Task { @MainActor [weak self] in
                        guard let self = self, self.isScanning else { return }
                        // Remove any control characters from the payload
                        let cleanedData = payloadString.hiSanitize()
                        self.scanCallback?(HiNfcResult(nfcData: cleanedData))
                    }
                }
            }
        }
    }

    /// Called when the NFC session is invalidated due to an error.
    /// - Parameters:
    ///   - session: The active NFC session.
    ///   - error: The error causing the invalidation.
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        guard let readerError = error as? NFCReaderError else { return }

        switch readerError.code {
        case .readerSessionInvalidationErrorUserCanceled:
            print("User canceled the NFC session.")
            return
        case .readerSessionInvalidationErrorFirstNDEFTagRead:
            print("First NDEF tag read; session automatically invalidated.")
            return
        default:
            print("NFC Session Error: \(readerError.code), \(readerError.localizedDescription)")
            stop()
        }
    }
}

// MARK: - Top ViewController Finder
extension UIViewController {
    /// Returns the top-most ViewController in the current app window.
    static func hiTopMostViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
              let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        return hiGetTopViewController(from: rootViewController)
    }

    private static func hiGetTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return hiGetTopViewController(from: presentedViewController)
        }
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return hiGetTopViewController(from: visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return hiGetTopViewController(from: selectedViewController)
        }
        return viewController
    }
}

// MARK: - String Sanitization
extension String {
    /// Removes control characters from the string.
    public func hiSanitize() -> String {
        return self.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }.reduce("") { $0 + String($1) }
    }
}
