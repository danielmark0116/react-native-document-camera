export type DocumentScan = {
  imageUri: string;
  ocrText: string;
};

export type DocumentScanConfig = {
  withOcr: boolean;
};
