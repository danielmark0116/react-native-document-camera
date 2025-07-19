package com.margelo.nitro.documentcamera
  
import com.facebook.proguard.annotations.DoNotStrip

@DoNotStrip
class DocumentCamera : HybridDocumentCameraSpec() {
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }
}
