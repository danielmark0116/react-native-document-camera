import { NitroModules } from 'react-native-nitro-modules';
import type { DocumentCamera } from './specs/DocumentCamera.nitro';
import type { DocumentScan, DocumentScanConfig } from './types/DocumentScanner';

const DocumentCameraHybridObject =
  NitroModules.createHybridObject<DocumentCamera>('DocumentCamera');

/**
 * Opens a native document scanner and returns the scanned documents.
 *
 * For iOS, the primitive is based on the Vision framework.
 * For Android, it uses the ML Kit Document Scanner (probably?)
 *
 * @param config - Configuration options for the document scanner.
 *
 * @param config.withOcr - Whether to perform OCR on the scanned documents.
 * Defaults to __true__.
 */
export function scanDocuments(
  config: DocumentScanConfig = { withOcr: true }
): Promise<DocumentScan[]> {
  return DocumentCameraHybridObject.scanDocuments(config);
}
