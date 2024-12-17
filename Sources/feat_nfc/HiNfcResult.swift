//
//  HiNfcResult.swift
//  feat_nfc
//
//  Created by netcanis on 12/17/24.
//

import Foundation

/// Represents the result of an NFC scan.
public class HiNfcResult {
    /// Scanned data.
    public let data: String

    /// Error message, if any.
    public let error: String

    /// Initializes an NFC scan result object.
    /// - Parameters:
    ///   - nfcData: The data string scanned from an NFC tag.
    ///   - error: An optional error message (default is an empty string).
    public init(nfcData: String, error: String = "") {
        self.data = nfcData
        self.error = error
    }
}
