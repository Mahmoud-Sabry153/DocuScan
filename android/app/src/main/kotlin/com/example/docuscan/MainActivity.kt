package com.example.docuscan

import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.docuscan/native_cv"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "detectDocument" -> {
                    // Native boundary intentionally isolated here. Replace this conservative fallback
                    // with OpenCV/ML Kit Document Scanner if the product enables that dependency.
                    val path = call.argument<String>("path") ?: return@setMethodCallHandler result.error("ARG", "path missing", null)
                    val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                    BitmapFactory.decodeFile(path, options)
                    if (options.outWidth <= 0 || options.outHeight <= 0) result.success(null)
                    else result.success(mapOf(
                        "tlx" to 0.06, "tly" to 0.08,
                        "trx" to 0.94, "try" to 0.08,
                        "brx" to 0.94, "bry" to 0.92,
                        "blx" to 0.06, "bly" to 0.92
                    ))
                }
                "perspectiveCorrect" -> result.error("NOT_ENABLED", "Perspective correction requires the optional native CV module documented in README.", null)
                else -> result.notImplemented()
            }
        }
    }
}
