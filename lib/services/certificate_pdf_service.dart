import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class CertificatePdfService {
  // ── Signing authority ──────────────────────────────────────────────────────
  static const _signerName = 'Zarek Tia';
  static const _signerTitle = 'Co-Founder & CEO, Learnify Academy';

  // ─── Public: Save to device + return saved path ────────────────────────────
  static Future<String> saveToDevice({
    required String studentName,
    required String courseTitle,
    required int score,
    required int totalQuestions,
    required String earnedDate,
    required BuildContext context,
  }) async {
    final bytes = await _buildBytes(
      studentName: studentName,
      courseTitle: courseTitle,
      score: score,
      totalQuestions: totalQuestions,
      earnedDate: earnedDate,
    );

    final filename =
        'Learnify_${courseTitle.replaceAll(RegExp(r'[^\w]'), '_')}_Certificate.pdf';
    final savePath = await _resolveSavePath(filename);

    final file = File(savePath);
    await file.writeAsBytes(bytes);
    return savePath;
  }

  // ─── Public: Share via OS share sheet ──────────────────────────────────────
  static Future<void> shareViaSheet({
    required String studentName,
    required String courseTitle,
    required int score,
    required int totalQuestions,
    required String earnedDate,
  }) async {
    final bytes = await _buildBytes(
      studentName: studentName,
      courseTitle: courseTitle,
      score: score,
      totalQuestions: totalQuestions,
      earnedDate: earnedDate,
    );
    final filename =
        'Learnify_${courseTitle.replaceAll(RegExp(r'[^\w]'), '_')}_Certificate.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ─── Resolve save directory ─────────────────────────────────────────────────
  static Future<String> _resolveSavePath(String filename) async {
    Directory dir;
    if (Platform.isAndroid) {
      // Try public Downloads first; fall back to app external storage
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) {
        dir = publicDownloads;
      } else {
        dir = (await getExternalStorageDirectory()) ??
            await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = (await getDownloadsDirectory()) ??
          await getApplicationDocumentsDirectory();
    }
    return '${dir.path}/$filename';
  }

  // ─── PDF bytes builder ──────────────────────────────────────────────────────
  static Future<Uint8List> _buildBytes({
    required String studentName,
    required String courseTitle,
    required int score,
    required int totalQuestions,
    required String earnedDate,
  }) async {
    final efficiency = totalQuestions > 0
        ? ((score / totalQuestions) * 100).toInt()
        : 100;

    // ── Fonts ─────────────────────────────────────────────────────────────
    final merriweatherBold = await PdfGoogleFonts.merriweatherBold();
    final merriweatherItalic = await PdfGoogleFonts.merriweatherItalic();
    final latoRegular = await PdfGoogleFonts.latoRegular();
    final latoBold = await PdfGoogleFonts.latoBold();
    final latoLight = await PdfGoogleFonts.latoLight();
    // Dancing Script for the signature
    final dancingScript = await PdfGoogleFonts.dancingScriptBold();

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => _page(
          studentName: studentName,
          courseTitle: courseTitle,
          efficiency: efficiency,
          score: score,
          total: totalQuestions,
          earnedDate: earnedDate,
          merriweatherBold: merriweatherBold,
          merriweatherItalic: merriweatherItalic,
          latoRegular: latoRegular,
          latoBold: latoBold,
          latoLight: latoLight,
          dancingScript: dancingScript,
        ),
      ),
    );
    return doc.save();
  }

  // ─── Page layout ───────────────────────────────────────────────────────────
  static pw.Widget _page({
    required String studentName,
    required String courseTitle,
    required int efficiency,
    required int score,
    required int total,
    required String earnedDate,
    required pw.Font merriweatherBold,
    required pw.Font merriweatherItalic,
    required pw.Font latoRegular,
    required pw.Font latoBold,
    required pw.Font latoLight,
    required pw.Font dancingScript,
  }) {
    // ── Palette (light, professional, Udemy/Coursera-style) ──────────────
    const bgColor = PdfColors.white;
    const navy = PdfColor.fromInt(0xFF1B2B4B);       // Deep navy — primary
    const navyMid = PdfColor.fromInt(0xFF2D4270);    // Medium navy
    const gold = PdfColor.fromInt(0xFFB8870B);       // Rich gold
    const goldLight = PdfColor.fromInt(0xFFD4A01A);  // Lighter gold
    const goldBand = PdfColor.fromInt(0xFFEEC900);   // Top/bottom band gold
    const cream = PdfColor.fromInt(0xFFF7F3E8);      // Warm cream tint
    const textDark = PdfColor.fromInt(0xFF1A1A2E);   // Near black
    const textMid = PdfColor.fromInt(0xFF4A5568);    // Mid grey
    const textLight = PdfColor.fromInt(0xFF718096);  // Light grey
    const dividerColor = PdfColor.fromInt(0xFFD6C48A); // Gold divider
    const accentBlue = PdfColor.fromInt(0xFF3B5998);  // Deep blue accent

    return pw.Container(
      color: bgColor,
      child: pw.Stack(
        children: [
          // ── Cream background tint (left 30%) ────────────────────────────
          pw.Positioned(
            left: 0, top: 0, bottom: 0,
            child: pw.Container(
              width: 238,
              color: cream,
            ),
          ),

          // ── Top gold accent band ─────────────────────────────────────────
          pw.Positioned(
            top: 0, left: 0, right: 0,
            child: pw.Container(height: 8, color: goldBand),
          ),
          // ── Bottom navy band ─────────────────────────────────────────────
          pw.Positioned(
            bottom: 0, left: 0, right: 0,
            child: pw.Container(height: 8, color: navy),
          ),

          // ── Left sidebar ─────────────────────────────────────────────────
          pw.Positioned(
            left: 0, top: 8, bottom: 8,
            child: pw.Container(
              width: 8, color: navy,
            ),
          ),
          // ── Right sidebar ────────────────────────────────────────────────
          pw.Positioned(
            right: 0, top: 8, bottom: 8,
            child: pw.Container(width: 8, color: navy),
          ),

          // ── Inner border ─────────────────────────────────────────────────
          pw.Positioned.fill(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(18),
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: dividerColor, width: 0.8),
                ),
              ),
            ),
          ),

          // ── Left panel content ───────────────────────────────────────────
          pw.Positioned(
            left: 18, top: 18, bottom: 18,
            child: pw.SizedBox(
              width: 210,
              child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(20, 24, 16, 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Seal circle
                  pw.Container(
                    width: 88, height: 88,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: gold, width: 2.5),
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'L',
                            style: pw.TextStyle(
                              font: merriweatherBold,
                              fontSize: 34,
                              color: navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'LEARNIFY',
                    style: pw.TextStyle(
                      font: latoBold,
                      fontSize: 11,
                      color: navy,
                      letterSpacing: 3.5,
                    ),
                  ),
                  pw.Text(
                    'ACADEMY',
                    style: pw.TextStyle(
                      font: latoRegular,
                      fontSize: 7,
                      color: textMid,
                      letterSpacing: 2.5,
                    ),
                  ),

                  pw.SizedBox(height: 20),
                  pw.Container(height: 0.8, color: dividerColor),
                  pw.SizedBox(height: 20),

                  // Score block
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: navy,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '$efficiency%',
                          style: pw.TextStyle(
                            font: merriweatherBold,
                            fontSize: 32,
                            color: goldBand,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'EFFICIENCY SCORE',
                          style: pw.TextStyle(
                            font: latoBold,
                            fontSize: 6,
                            color: PdfColors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '$score of $total correct',
                          style: pw.TextStyle(
                            font: latoLight,
                            fontSize: 8,
                            color: const PdfColor.fromInt(0xFFBBCCEE),
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 16),
                  pw.Container(height: 0.8, color: dividerColor),
                  pw.SizedBox(height: 14),

                  // Date block
                  pw.Text(
                    'DATE OF COMPLETION',
                    style: pw.TextStyle(
                      font: latoBold,
                      fontSize: 6,
                      color: textLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    earnedDate,
                    style: pw.TextStyle(
                      font: merriweatherBold,
                      fontSize: 10,
                      color: textDark,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),

                  pw.Spacer(),

                  // Bottom verification note
                  pw.Text(
                    'This certificate verifies the\ncompletion of an online course\non the Learnify platform.',
                    style: pw.TextStyle(
                      font: latoLight,
                      fontSize: 7,
                      color: textLight,
                      lineSpacing: 2,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            ),
          ),

          // ── Vertical divider between panels ─────────────────────────────
          pw.Positioned(
            left: 228, top: 18, bottom: 18,
            child: pw.Container(width: 1, color: dividerColor),
          ),

          // ── Right panel content ──────────────────────────────────────────
          pw.Positioned(
            left: 240, right: 18, top: 18, bottom: 18,
            child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(32, 28, 32, 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  // Headline
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 3, height: 28,
                        color: goldLight,
                      ),
                      pw.SizedBox(width: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'CERTIFICATE OF',
                            style: pw.TextStyle(
                              font: latoRegular,
                              fontSize: 10,
                              color: textMid,
                              letterSpacing: 2.5,
                            ),
                          ),
                          pw.Text(
                            'COMPLETION',
                            style: pw.TextStyle(
                              font: merriweatherBold,
                              fontSize: 22,
                              color: navy,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 22),

                  // "This is to certify"
                  pw.Text(
                    'This is to proudly certify that',
                    style: pw.TextStyle(
                      font: latoLight,
                      fontSize: 11,
                      color: textMid,
                    ),
                  ),
                  pw.SizedBox(height: 6),

                  // Student name — the centerpiece
                  pw.Text(
                    studentName,
                    style: pw.TextStyle(
                      font: merriweatherBold,
                      fontSize: 36,
                      color: navy,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.SizedBox(height: 4),

                  // Underline bar
                  pw.Container(
                    width: 280,
                    height: 2.5,
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        colors: [goldBand, const PdfColor.fromInt(0x00EEC900)],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 14),
                  pw.Text(
                    'has successfully completed the online course',
                    style: pw.TextStyle(
                      font: latoRegular,
                      fontSize: 11,
                      color: textMid,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Course title box
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFF0F4FF),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: accentBlue, width: 0.5),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 3, height: 28,
                          color: accentBlue,
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Text(
                            courseTitle,
                            style: pw.TextStyle(
                              font: merriweatherBold,
                              fontSize: 15,
                              color: navyMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // Achievement summary
                  pw.Row(
                    children: [
                      _pill('SCORE  $score / $total', latoBold, gold,
                          const PdfColor.fromInt(0xFFFDF6E3)),
                      pw.SizedBox(width: 8),
                      _pill('EFFICIENCY  $efficiency%', latoBold, accentBlue,
                          const PdfColor.fromInt(0xFFF0F4FF)),
                      pw.SizedBox(width: 8),
                      _pill('PASSING GRADE  60%+', latoRegular, textMid,
                          const PdfColor.fromInt(0xFFF7F7F7)),
                    ],
                  ),

                  pw.Spacer(),

                  // Horizontal rule before signatures
                  pw.Container(height: 0.8, color: dividerColor),
                  pw.SizedBox(height: 14),

                  // Signature row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Left signature
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Cursive signature
                          pw.Text(
                            _signerName,
                            style: pw.TextStyle(
                              font: dancingScript,
                              fontSize: 24,
                              color: navyMid,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Container(
                            width: 160, height: 0.8, color: textLight,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            _signerName.toUpperCase(),
                            style: pw.TextStyle(
                              font: latoBold,
                              fontSize: 7.5,
                              color: navy,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.Text(
                            _signerTitle,
                            style: pw.TextStyle(
                              font: latoRegular,
                              fontSize: 7,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),

                      // Right: Learnify brand note
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'learnify.academy',
                            style: pw.TextStyle(
                              font: latoLight,
                              fontSize: 8,
                              color: textLight,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Empowering futures through education',
                            style: pw.TextStyle(
                              font: latoLight,
                              fontSize: 6.5,
                              color: const PdfColor.fromInt(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Small label pill ──────────────────────────────────────────────────────
  static pw.Widget _pill(
    String text,
    pw.Font font,
    PdfColor textColor,
    PdfColor bgColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: textColor, width: 0.4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 7, color: textColor),
      ),
    );
  }
}
