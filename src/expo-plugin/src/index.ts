import { type ConfigPlugin } from '@expo/config-plugins';

import type { ConfigProps } from './types';

const CAMERA_USAGE = 'Allow $(PRODUCT_NAME) to access your camera';

const withCameraPermissionIos: ConfigPlugin<ConfigProps> = (
  config,
  props = {}
) => {
  if (config.ios == null) config.ios = {};
  if (config.ios.infoPlist == null) config.ios.infoPlist = {};

  if (props.enableCameraPermission === true) {
    config.ios.infoPlist.NSCameraUsageDescription =
      props.cameraPermissionText ??
      (config.ios.infoPlist.NSCameraUsageDescription as string | undefined) ??
      CAMERA_USAGE;
  }

  return config;
};

export default withCameraPermissionIos;
