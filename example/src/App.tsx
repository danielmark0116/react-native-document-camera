import { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, Image } from 'react-native';
import { scanDocuments } from 'react-native-document-camera';

export default function App() {
  const [result, setResult] = useState<string>();

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={async () => {
          const uris = await scanDocuments().catch(console.log);

          setResult(uris?.[0]?.imageUri ?? '');
        }}
      >
        <Text>Scan</Text>
      </TouchableOpacity>
      <Text>Result: {JSON.stringify(result)}</Text>
      {result && (
        <Image
          src={result || ''}
          width={299}
          height={299}
          resizeMode="contain"
        />
      )}
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
});
