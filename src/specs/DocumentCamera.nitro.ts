import type { HybridObject } from 'react-native-nitro-modules';
import type { DocumentScan } from '../types/DocumentScanner';

export interface DocumentCamera
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  scanDocuments(): Promise<DocumentScan[]>;
}
