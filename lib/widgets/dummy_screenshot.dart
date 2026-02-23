import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

const _kSampleQr = 'assets/images/sample_QR.png';
const _kSampleTxn = 'assets/images/sample_Transaction.png';

// ─────────────────────────────────────────────────────────────
// Routing helper used by all screens
// ─────────────────────────────────────────────────────────────

/// Returns the right image widget for a screenshot/QR path:
///   'dummy:*'     → sample_Transaction.png
///   'assets/...'  → Image.asset(path)
///   'http(s)://'  → Image.network(path)
///   anything else → Image.file(File(path))
Widget buildScreenshotPreview(String path) {
  if (path.startsWith('dummy:') || path.startsWith('assets/')) {
    final asset = path.startsWith('assets/') ? path : _kSampleTxn;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
  if (path.startsWith('https://') || path.startsWith('http://')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const _Placeholder('Could not load image'),
      ),
    );
  }
  if (!kIsWeb && File(path).existsSync()) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(File(path), fit: BoxFit.contain),
    );
  }
  return const _Placeholder('Preview not available on this platform');
}

// ─────────────────────────────────────────────────────────────
// Sample QR image widget
// ─────────────────────────────────────────────────────────────

/// Shows sample_QR.png as the QR code placeholder.
/// [url] is retained for API-compatibility but is unused.
class NetworkQrImage extends StatelessWidget {
  // ignore: unused_field
  final String url;
  final double size;
  const NetworkQrImage({super.key, required this.url, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        _kSampleQr,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sample transaction screenshot widget
// ─────────────────────────────────────────────────────────────

/// Shows sample_Transaction.png as the payment receipt.
/// [type] is retained for API-compatibility ('deposit' | 'withdrawal').
class DummyScreenshotWidget extends StatelessWidget {
  // ignore: unused_field
  final String type;
  const DummyScreenshotWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        _kSampleTxn,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Internal placeholder fallback
// ─────────────────────────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  final String message;
  const _Placeholder(this.message);

  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.broken_image_outlined,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary)),
        ]),
      );
}
