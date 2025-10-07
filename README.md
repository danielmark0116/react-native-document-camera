# react-native-document-camera

Native module utilizing platform's camera with document scanning capabilities

## Installation

```sh
npm install react-native-document-camera react-native-nitro-modules

> `react-native-nitro-modules` is required as this library relies on [Nitro Modules](https://nitro.margelo.com/).
```

## Usage

```js
import { scanDocuments } from 'react-native-document-camera';

try {
  const scansResponse = await scanDocuments({ withOcr: true });

  setTitle(scansResponse.title);
  setScans(scansResponse.pages);
} catch (_) {
  // Handle error
}
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
