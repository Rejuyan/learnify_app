import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generates and shares/downloads a beautiful Learnify certificate PDF.
class CertificatePdfService {
  static Future<void> shareOrDownload({
    required String studentName,
    required String courseTitle,
    required int score,
    required int totalQuestions,
    required String earnedDate,
    required BuildContext context,
  }) async {
    final Uint8List bytes = await _buildPdfBytes(
      studentName: studentName,
      courseTitle: courseTitle,
      score: score,
      totalQuestions: totalQuestions,
      earnedDate: earnedDate,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Learnify_Certificate_${courseTitle.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<Uint8List> _buildPdfBytes({
    required String studentName,
    required String courseTitle,
    required int score,
    required int totalQuestions,
    required String earnedDate,
  }) async {
    final doc = pw.Document();

    final efficiency = totalQuestions > 0
        ? ((score / totalQuestions) * 100).toInt()
        : 100;

    final fontBold = await PdfGoogleFonts.playfairDisplayBold();
    final fontItalic = await PdfGoogleFonts.playfairDisplayItalic();
    final fontSans = await PdfGoogleFonts.montserratRegular();
    final fontSansBold = await PdfGoogleFonts.montserratBold();
    final fontSansLight = await PdfGoogleFonts.montserratLight();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => _buildPage(
          studentName: studentName,
          courseTitle: courseTitle,
          efficiency: efficiency,
          score: score,
          totalQuestions: totalQuestions,
          earnedDate: earnedDate,
          fontBold: fontBold,
          fontItalic: fontItalic,
          fontSans: fontSans,
          fontSansBold: fontSansBold,
          fontSansLight: fontSansLight,
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildPage({
    required String studentName,
    required String courseTitle,
    required int efficiency,
    required int score,
    required int totalQuestions,
    required String earnedDate,
    required pw.Font fontBold,
    required pw.Font fontItalic,
    required pw.Font fontSans,
    required pw.Font fontSansBold,
    required pw.Font fontSansLight,
  }) {
    const bg = PdfColor.fromInt(0xFF0F0830);
    const gold = PdfColor.fromInt(0xFFFFD700);
    const goldLight = PdfColor.fromInt(0xFFFFEA70);
    const purpleLight = PdfColor.fromInt(0xFFBB9EFF);
    const white = PdfColors.white;
    const white70 = PdfColor.fromInt(0xB3FFFFFF);
    const white40 = PdfColor.fromInt(0x66FFFFFF);
    const purpleBg = PdfColor.fromInt(0x408B5CF6);
    const goldBg = PdfColor.fromInt(0x1AFFD700);

    return pw.Container(
      color: bg,
      child: pw.Stack(
        children: [
          // ── Outer gold border ──────────────────────────────────────────
          pw.Positioned.fill(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: gold, width: 2.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
              ),
            ),
          ),

          // ── Inner thin border ──────────────────────────────────────────
          pw.Positioned.fill(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: white40, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
            ),
          ),

          // ── Corner ornaments ────────────────────────────────────────────
          pw.Positioned(
            top: 16, left: 16,
            child: _corner(gold),
          ),
          pw.Positioned(
            top: 16, right: 16,
            child: _corner(gold),
          ),
          pw.Positioned(
            bottom: 16, left: 16,
            child: _corner(gold),
          ),
          pw.Positioned(
            bottom: 16, right: 16,
            child: _corner(gold),
          ),

          // ── Main content ───────────────────────────────────────────────
          pw.Positioned.fill(
            child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(56, 28, 56, 28),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Academy header
                  pw.Text(
                    'LEARNIFY  ACADEMY',
                    style: pw.TextStyle(
                      font: fontSansBold,
                      fontSize: 13,
                      color: gold,
                      letterSpacing: 5,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'CERTIFICATE  OF  COMPLETION',
                    style: pw.TextStyle(
                      font: fontSans,
                      fontSize: 8,
                      color: white40,
                      letterSpacing: 3,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Gold horizontal rule
                  pw.Container(height: 1, color: gold),

                  pw.SizedBox(height: 18),

                  pw.Text(
                    'This is to proudly certify that',
                    style: pw.TextStyle(font: fontSansLight, fontSize: 11, color: white70),
                  ),
                  pw.SizedBox(height: 10),

                  // Student name — large italic
                  pw.Text(
                    studentName,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 42,
                      color: white,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 8),

                  pw.Text(
                    'has successfully completed the course',
                    style: pw.TextStyle(font: fontSansLight, fontSize: 11, color: white70),
                  ),
                  pw.SizedBox(height: 10),

                  // Course title
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: purpleBg,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: purpleLight, width: 0.5),
                    ),
                    child: pw.Text(
                      courseTitle,
                      style: pw.TextStyle(font: fontBold, fontSize: 18, color: purpleLight),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Efficiency badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: goldBg,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                      border: pw.Border.all(color: gold, width: 0.8),
                    ),
                    child: pw.Text(
                      'Achievement: $score / $totalQuestions   |   Efficiency: $efficiency%',
                      style: pw.TextStyle(
                          font: fontSansBold, fontSize: 9, color: goldLight, letterSpacing: 0.5),
                    ),
                  ),

                  pw.Spacer(),

                  // Bottom row: Date | Seal | Signature
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Date
                      pw.SizedBox(
                        width: 150,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(earnedDate,
                                style: pw.TextStyle(
                                    font: fontSansBold, fontSize: 10, color: white)),
                            pw.SizedBox(height: 4),
                            pw.Container(height: 0.5, width: 140, color: white40),
                            pw.SizedBox(height: 3),
                            pw.Text('Date of Issue',
                                style: pw.TextStyle(
                                    font: fontSansLight, fontSize: 8, color: white40)),
                          ],
                        ),
                      ),

                      // Seal circle
                      pw.Container(
                        width: 72, height: 72,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: gold, width: 1.5),
                        ),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text('L',
                                  style: pw.TextStyle(
                                      font: fontBold, fontSize: 28, color: gold)),
                              pw.SizedBox(height: 1),
                              pw.Text('LEARNIFY',
                                  style: pw.TextStyle(
                                      font: fontSansBold,
                                      fontSize: 5, color: gold, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),

                      // Signature
                      pw.SizedBox(
                        width: 180,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              'Dr. Alexander Reid',
                              style: pw.TextStyle(
                                  font: fontItalic, fontSize: 17, color: goldLight),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Container(height: 0.5, width: 160, color: white40),
                            pw.SizedBox(height: 3),
                            pw.Text('Director, Learnify Academy',
                                style: pw.TextStyle(
                                    font: fontSansLight, fontSize: 8, color: white40)),
                          ],
                        ),
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

  // Corner L-bracket ornament
  static pw.Widget _corner(PdfColor color) {
    return pw.SizedBox(
      width: 28, height: 28,
      child: pw.Stack(
        children: [
          pw.Positioned(
            top: 0, left: 0,
            child: pw.Container(width: 20, height: 1.5, color: color),
          ),
          pw.Positioned(
            top: 0, left: 0,
            child: pw.Container(width: 1.5, height: 20, color: color),
          ),
        ],
      ),
    );
  }
}
