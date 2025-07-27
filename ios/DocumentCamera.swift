import NitroModules
import React
import UIKit
import Vision
import VisionKit

class DocumentCamera: HybridDocumentCameraSpec {
    private var scannerDelegate: ScannerDelegate?

    public func scanDocuments(config: DocumentScanConfig) throws -> NitroModules.Promise<DocumentScan> {
        let promise = Promise<DocumentScan>()
        let delegate = ScannerDelegate(parent: self, promise: promise, config: config)
        scannerDelegate = delegate

        guard let rootVC = RCTPresentedViewController() else {
            promise.reject(withError: ScanErrors.couldNotConvertToJPG)
            scannerDelegate = nil
            return promise
        }

        guard VNDocumentCameraViewController.isSupported else {
            promise.reject(withError: ScanErrors.deviceNotSupported)
            scannerDelegate = nil
            return promise
        }

        DispatchQueue.main.async {
            let scanner = VNDocumentCameraViewController()
            scanner.delegate = self.scannerDelegate
            rootVC.present(scanner, animated: true)
        }

        return promise
    }

    fileprivate func clearDelegate() {
        scannerDelegate = nil
    }
}

private class ScannerDelegate: NSObject, VNDocumentCameraViewControllerDelegate {
    weak var parent: DocumentCamera?
    let promise: Promise<DocumentScan>
    let config: DocumentScanConfig?

    init(parent: DocumentCamera, promise: Promise<DocumentScan>, config: DocumentScanConfig? = nil) {
        self.parent = parent
        self.promise = promise
        self.config = config
        super.init()
    }

    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        controller.dismiss(animated: true)

        guard scan.pageCount > 0 else {
            promise.reject(withError: ScanErrors.noPagesScanned)
            return
        }

        var docScan = DocumentScan()
        var docScans: [DocumentPage] = []

        for pageNumber in 0 ..< scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)

            guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
                promise.reject(withError: ScanErrors.couldNotConvertToJPG)
                return
            }

            if pageNumber == 0 {
                let title = Date.now.ISO8601Format()

                docScan.title = title
            }

            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(UUID().uuidString).jpg")

            let docScan = DocumentPage(imageUri: tmpURL.absoluteString, ocrText: "")

            do {
                try jpegData.write(to: tmpURL, options: .atomic)
            } catch {
                promise.reject(withError: ScanErrors.couldNotWriteScanToFS)
            }

            docScans.append(docScan)
        }

        docScan.pages = docScans

        guard let withOcr = config?.withOcr, withOcr else {
            promise.resolve(withResult: docScan)

            return
        }

        // Now do OCR asynchronously
        // We want to process all scans in the background AFTER we close the camera view controller
        // It allows for better user experience (e.g. not blocking the UI)
        DispatchQueue.global(qos: .userInitiated).async {
            var finalScans = docScans

            for (index, scanItem) in finalScans.enumerated() {
                let path = URL(string: scanItem.imageUri)!
                if let imgData = try? Data(contentsOf: path),
                   let image = UIImage(data: imgData)
                {
                    do {
                        let text = try self.extractTextFromScan(image: image)
                        finalScans[index].ocrText = text

                        if index == 0 {
                            let title = text.split(separator: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Date.now.ISO8601Format()

                            docScan.title = title
                        }
                    } catch {
                        // you can handle OCR errors individually or ignore
                    }
                }
            }

            docScan.pages = finalScans

            // Once OCR done, resolve promise on main thread
            DispatchQueue.main.async {
                self.promise.resolve(withResult: docScan)
                self.parent?.clearDelegate()
            }
        }
    }

    func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        controller.dismiss(animated: true)
        promise.reject(withError: ScanErrors.userCancelled)
        parent?.clearDelegate()
    }

    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFailWithError _: Error
    ) {
        controller.dismiss(animated: true)
        promise.reject(withError: ScanErrors.unknown)
        parent?.clearDelegate()
    }

    func extractTextFromScan(image: UIImage) throws -> String {
        guard let cgImage = image.cgImage else { return "" }

        var recognizedText = ""

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + "\n"
            }
        }

        request.usesLanguageCorrection = true // Optional: Enable language correction

        if #available(iOS 16.0, *) {
            request.automaticallyDetectsLanguage = true
        } else {
            request.recognitionLanguages = ["en-US"] // Or your desired language
        }

        do {
            try requestHandler.perform([request])
        } catch {
            //
        }

        return recognizedText
    }
}

enum ScanErrors: Error {
    case noPagesScanned
    case couldNotConvertToJPG
    case couldNotWriteScanToFS
    case userCancelled
    case unknown
    case deviceNotSupported
    case ocrFailed
}
