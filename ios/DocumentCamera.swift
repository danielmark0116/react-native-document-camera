import NitroModules
import React
import UIKit
import Vision
import VisionKit

class DocumentCamera: HybridDocumentCameraSpec {
    private var scannerDelegate: ScannerDelegate?

    public func scanDocuments() throws -> NitroModules.Promise<[DocumentScan]> {
        let promise = Promise<[DocumentScan]>()
        let delegate = ScannerDelegate(parent: self, promise: promise)
        scannerDelegate = delegate

        guard let rootVC = RCTPresentedViewController() else {
            promise.reject(withError: ScanErrors.CouldNotConvertToJPG)
            scannerDelegate = nil
            return promise
        }

        guard VNDocumentCameraViewController.isSupported else {
            promise.reject(withError: ScanErrors.DeviceNotSupported)
            scannerDelegate = nil
            return promise
        }

        DispatchQueue.main.async {
            let scanner = VNDocumentCameraViewController()
            scanner.delegate = delegate
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
    let promise: Promise<[DocumentScan]>

    init(parent: DocumentCamera, promise: Promise<[DocumentScan]>) {
        self.parent = parent
        self.promise = promise
        super.init()
    }

    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        controller.dismiss(animated: true)
        defer { parent?.clearDelegate() }

        guard scan.pageCount > 0 else {
            promise.reject(withError: ScanErrors.NoPagesScanned)
            return
        }

        var docScans: [DocumentScan] = []

        guard let data = scan.imageOfPage(at: 0).jpegData(compressionQuality: 0.8) else {
            promise.reject(withError: ScanErrors.CouldNotConvertToJPG)
            return
        }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).jpg")
        do {
            try data.write(to: tmpURL, options: .atomic)
            let docScan = DocumentScan(imageUri: tmpURL.absoluteString, ocrText: "")

            docScans.append(docScan)

            promise.resolve(withResult: docScans)
        } catch {
            promise.reject(withError: ScanErrors.CouldNotWriteScanToFS)
        }
    }

    func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        controller.dismiss(animated: true)
        promise.reject(withError: ScanErrors.UserCancelled)
        parent?.clearDelegate()
    }

    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFailWithError _: Error
    ) {
        controller.dismiss(animated: true)
        promise.reject(withError: ScanErrors.Unknown)
        parent?.clearDelegate()
    }

    func extractTextFromScan(scan: VNDocumentCameraScan, shouldExtractText _: Bool?) {
        for pageNumber in 0 ..< scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            guard let cgImage = image.cgImage else { continue }

            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                var recognizedText = ""
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    recognizedText += topCandidate.string + "\n"
                }
                print("Recognized text for page \(pageNumber + 1): \n\(recognizedText)")
            }

            request.recognitionLanguages = ["en-US"] // Or your desired language
            request.usesLanguageCorrection = true // Optional: Enable language correction

            do {
                try requestHandler.perform([request])
            } catch {
                print("Error performing text recognition: \(error)")
            }
        }
    }
}

enum ScanErrors: Error {
    case NoPagesScanned
    case CouldNotConvertToJPG
    case CouldNotWriteScanToFS
    case UserCancelled
    case Unknown
    case DeviceNotSupported
}

// extension DocumentCamera: VNDocumentCameraViewControllerDelegate {
//  public func documentCameraViewController(
//     _ controller: VNDocumentCameraViewController,
//     didFinishWith scan: VNDocumentCameraScan
//   ) {
//     controller.dismiss(animated: true)
//
//     guard scan.pageCount > 0 else {
//       self.promise?.reject(withError: ScanErrors.NoPagesScanned)
//       return
//     }
//
//     let img = scan.imageOfPage(at: 0)
//     guard let data = img.jpegData(compressionQuality: 0.8) else {
//       self.promise?.reject(withError: ScanErrors.CouldNotConvertToJPG)
//       return
//     }
//
//     let tmpURL = FileManager.default.temporaryDirectory
//       .appendingPathComponent("\(UUID().uuidString).jpg")
//     do {
//       try data.write(to: tmpURL, options: .atomic)
//       self.promise?.resolve(withResult: [tmpURL.absoluteString])
//     } catch {
//       self.promise?.reject(withError: ScanErrors.CouldNotWriteScanToFS)
//     }
//   }
//
//
//  public func documentCameraViewControllerDidCancel(
//    _ controller: VNDocumentCameraViewController
//  ) {
//    controller.dismiss(animated: true)
//    self.promise?.reject(withError: ScanErrors.UserCancelled)
//    removeCallbacks()
//  }
//
//  public func documentCameraViewController(
//    _ controller: VNDocumentCameraViewController,
//    didFailWithError error: Error
//  ) {
//    controller.dismiss(animated: true)
//    self.promise?.reject(withError: ScanErrors.Unknown)
//    removeCallbacks()
//  }
//
// }
