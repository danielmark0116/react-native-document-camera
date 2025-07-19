import { NitroModules } from 'react-native-nitro-modules';
import type { DocumentCamera } from './specs/DocumentCamera.nitro';
import type { DocumentScan } from './types/DocumentScanner';

const DocumentCameraHybridObject =
  NitroModules.createHybridObject<DocumentCamera>('DocumentCamera');

export function scanDocuments(): Promise<DocumentScan[]> {
  return DocumentCameraHybridObject.scanDocuments();
}
