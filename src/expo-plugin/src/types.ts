export interface ConfigProps {
  /**
   * Whether to enable camera permission prompt for the scanner.
   *
   * @platform iOS
   * @default true
   * @example true
   */
  enableCameraPermission?: boolean;

  /**
   * Camera permission description text rendered in a native iOS permission dialog.
   * Explains why the app needs an access to the camera.
   *
   * @platform iOS
   * @default "Allow $(PRODUCT_NAME) to access your camera for screen recording with camera overlay"
   * @example "We need camera access to scan QR codes"
   */
  cameraPermissionText?: string;
}
