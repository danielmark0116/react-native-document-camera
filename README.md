# react-native-document-camera

Native module utilizing platform's camera with document scanning capabilities

## Installation

```sh
npm install react-native-document-camera react-native-nitro-modules

> `react-native-nitro-modules` is required as this library relies on [Nitro Modules](https://nitro.margelo.com/).
```

## Supported platforms

- iOS

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

## Expo

If your app does not handle camera permissions yet, you need to add the following keys to your `app.json`:

```json
{
  "expo": {
    "plugins": [
      [
        "react-native-document-camera",
        {
          "enableCameraPermission": true,
          "cameraPermissionText": "Optional text to explain the camera permission usage" // Optional, default is "Allow $(PRODUCT_NAME) to access your camera"
        }
      ]
    ]
  }
}
```

If you decide to add this plugin, first attempt at scanning documents will prompt the user for camera permissions.

## Bare workflow

If you have a bare React Native project, you need to add the following key to your `Info.plist`:

```plist
<key>NSCameraUsageDescription</key>
<string>Allow $(PRODUCT_NAME) to access your camera</string>
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

```

```
