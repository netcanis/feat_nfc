# **feat_nfc**

A **Swift Package** for NFC (Near Field Communication) tag reading on iOS.

---

## **Overview**

`feat_nfc` is a lightweight Swift package that enables:  
- Reading NFC NDEF tags.  
- Fetching payload data from scanned tags.  
- Providing a simple interface for NFC operations.  

This module is compatible with **iOS 16 and above** and integrates seamlessly via **Swift Package Manager (SPM)**.

---

## **Features**

- ✅ **NFC Tag Scanning**: Scan NFC NDEF tags and retrieve payload data.  
- ✅ **Error Handling**: Provides clear error information during scanning.  
- ✅ **Modular Integration**: Easy to integrate with minimal configuration.

---

## **Requirements**

| Requirement     | Minimum Version         |
|------------------|-------------------------|
| **iOS**         | 16.0                    |
| **Swift**       | 5.7                     |
| **Xcode**       | 14.0                    |

---

## **Installation**

### **Swift Package Manager (SPM)**  

1. Open your project in **Xcode**.  
2. Go to **File > Add Packages...**.  
3. Enter the repository URL:  https://github.com/netcanis/feat_nfc.git
4. Select the version and add the package.

---

## **Usage**

### **1. Start NFC Scanning**

To start NFC tag scanning:

```swift
import feat_nfc

HiNfcScanner.shared.start { result in
    print("NFC Scan Result: \(result.data)")
    HiNfcScanner.shared.stop() // Stop scanning
}
```

### **2. Custom Alert Message**
You can provide a custom alert message when scanning starts:

```swift
let alertMessage = "Place your device near the NFC tag."
HiNfcScanner.shared.start(alertMessage: alertMessage) { result in
    print("NFC Scan Result: \(result.data)")
    HiNfcScanner.shared.stop()
}
```

---

## **HiNfcResult**

The scan results are provided in the HiNfcResult class. Here are its properties:

| Property          | Type           | Description                         |
|-------------------|----------------|-------------------------------------|
| data              | String         | The payload data read from the tag. |
| error             | String         | Error message if the scan fails.    |

---

## **Permissions**

Add the following key to your Info.plist file to enable NFC scanning:

```
<key>NFCReaderUsageDescription</key>
<string>We use NFC to scan nearby tags.</string>
```

---

## **Example UI**

To display scanned NFC tag data in a SwiftUI view:

```swift
import SwiftUI
import feat_nfc

public struct HiNfcTagListView: View {
    @State private var tags: [(date: Date, payload: String)] = []

    public var body: some View {
        List(tags, id: \.payload) { result in
            VStack(alignment: .leading) {
                Text("Scanned Date: \(result.date.formatted())")
                Text("Payload: \(result.payload)")
            }
        }
        .navigationTitle("NFC Scans")
        .onAppear(perform: startNfcScan)
        .onDisappear { HiNfcScanner.shared.stop() }
    }

    private func startNfcScan() {
        HiNfcScanner.shared.start { result in
            let payload = result.data
            if let index = tags.firstIndex(where: { $0.payload == payload }) {
                tags[index] = (date: Date(), payload: payload)
            } else {
                tags.append((date: Date(), payload: payload))
            }
        }
    }
}
```

---

## **License**

feat_nfc is available under the MIT License. See the LICENSE file for details.

---

## **Contributing**

Contributions are welcome! To contribute:

1. Fork this repository.
2. Create a feature branch:
```
git checkout -b feature/your-feature
```
3. Commit your changes:
```
git commit -m "Add feature: description"
```
4. Push to the branch:
```
git push origin feature/your-feature
```
5. Submit a Pull Request.

---

## **Author**

### **netcanis**
GitHub: https://github.com/netcanis

---
