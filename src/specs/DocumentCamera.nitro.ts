import type { HybridObject } from 'react-native-nitro-modules';
import type {
  DocumentScan,
  DocumentScanConfig,
} from '../types/DocumentScanner';

export interface DocumentCamera
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  scanDocuments(config: DocumentScanConfig): Promise<DocumentScan>;
}
