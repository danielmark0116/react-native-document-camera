export type DocumentPage = {
  imageUri: string;
  ocrText: string;
};

export type DocumentScan = {
  title: string;
  pages: DocumentPage[];
};

export type DocumentScanConfig = {
  withOcr: boolean;
};
