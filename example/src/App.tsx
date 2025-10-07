import { useState } from 'react';
import {
  Text,
  View,
  StyleSheet,
  TouchableOpacity,
  Image,
  useWindowDimensions,
  ScrollView,
  type ViewStyle,
} from 'react-native';
import { scanDocuments } from 'react-native-document-camera';
import type { DocumentPage } from '../../src/types/DocumentScanner';

export default function App() {
  const { width, height } = useWindowDimensions();
  const [scans, setScans] = useState<DocumentPage[]>([]);
  const [title, setTitle] = useState('');

  return (
    <View style={styles.container}>
      <View style={styles.scanFab}>
        <TouchableOpacity
          style={styles.fab}
          onPress={async () => {
            try {
              const scansResponse = await scanDocuments({ withOcr: true });

              setTitle(scansResponse.title);
              setScans(scansResponse.pages);
            } catch (_) {
              //
            }
          }}
        >
          <Text>Scan</Text>
        </TouchableOpacity>
      </View>

      <ScrollView snapToInterval={width} horizontal>
        {scans.map((scan, index) => (
          <View style={[$slide(width, height)]} key={String(index)}>
            <Text style={styles.spacedTitle}>{`Title: ${title}`}</Text>
            <Text style={styles.spacedText}>OCR:</Text>
            <Text style={{ maxHeight: 200 }}>{scan?.ocrText ?? 'NO OCR'}</Text>
            {scan.imageUri && (
              <Image
                src={scan.imageUri || ''}
                width={width}
                style={styles.image}
                resizeMode="contain"
              />
            )}
          </View>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'green',
  },
  scanFab: {
    position: 'absolute',
    bottom: 40,
    right: 40,
  },
  fab: {
    width: 40,
    height: 40,
    backgroundColor: 'blue',
  },
  spacedTitle: {
    marginTop: 200,
    marginBottom: 20,
  },
  spacedText: {
    marginBottom: 20,
  },
  image: {
    aspectRatio: 1,
  },
});

const $slide = (width = 100, height = 100) =>
  ({
    width,
    height,
  }) satisfies ViewStyle;
