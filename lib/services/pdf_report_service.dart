import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generates a TB (Mycobacterium Combined Panel) report PDF similar to the provided sample.
/// [logoImage] should be a Uint8List of the logo image (can be null for placeholder).
Future<Uint8List> generateTbReportPdf({
  Uint8List? logoImage,
  required String patientName,
  required int age,
  required String sex,
  required String pid,
  required String sampleAddress,
  required String refBy,
  required String specimenType,
  required String tbComplexResult,
  required String nonTbMycoResult,
  required String interpretation,
  required String comments,
  required DateTime registeredOn,
  required DateTime collectedOn,
  required DateTime reportedOn,
}) async {
  final pdf = pw.Document();

  pw.Widget headerSection() => pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        logoImage != null
            ? pw.Image(pw.MemoryImage(logoImage), width: 50, height: 50)
            : pw.Container(
                width: 50,
                height: 50,
                color: PdfColors.blue100,
                child: pw.Center(child: pw.Text('Logo', style: pw.TextStyle(fontSize: 10))),
              ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('DRLOGY PATHOLOGY LAB', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Text('Accurate | Caring | Instant', style: pw.TextStyle(fontSize: 10)),
              pw.Text('105 -108, SMART VISION COMPLEX, HEALTHCARE ROAD, OPPOSITE HEALTHCARE COMPLEX. MUMBAI - 689578', style: pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('0123456789 | 0912345678', style: pw.TextStyle(fontSize: 9)),
            pw.Text('drlogypathlab@drlogy.com', style: pw.TextStyle(fontSize: 9)),
            pw.Text('www.drlogy.com', style: pw.TextStyle(fontSize: 9)),
          ],
        ),
      ],
    ),
  );

  pw.Widget patientSection() => pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Yash M. Patel', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Age : $age Years'),
              pw.Text('Sex : $sex'),
              pw.Text('PID : $pid'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Sample Collected At:'),
              pw.Text(sampleAddress, style: pw.TextStyle(fontSize: 9)),
              pw.Text('Ref. By: $refBy', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Registered on: ${_formatDateTime(registeredOn)}', style: pw.TextStyle(fontSize: 8)),
            pw.Text('Collected on: ${_formatDateTime(collectedOn)}', style: pw.TextStyle(fontSize: 8)),
            pw.Text('Reported on: ${_formatDateTime(reportedOn)}', style: pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    ),
  );

  pw.Widget reportTitle() => pw.Center(
    child: pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(
        'MYCOBACTERIUM COMBINED PANEL - TB (COMBINE)',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
      ),
    ),
  );

  pw.Widget investigationTable() => pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey),
    columnWidths: {
      0: const pw.FlexColumnWidth(2),
      1: const pw.FlexColumnWidth(2),
      2: const pw.FlexColumnWidth(2),
      3: const pw.FlexColumnWidth(1),
    },
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Investigation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Result', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Reference Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('MYCOBACTERIUM TUBERCULOSIS, PCR; MYCOSURE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.Text('Real Time PCR', style: pw.TextStyle(fontSize: 8)),
                pw.Text('Type of Specimen', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                pw.Text(specimenType, style: pw.TextStyle(fontSize: 8)),
                pw.Text('Mycobacterium tuberculosis Complex', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                pw.Text(tbComplexResult, style: pw.TextStyle(fontSize: 8, color: tbComplexResult == 'Detected' ? PdfColors.red : PdfColors.green)),
                pw.Text('Non tuberculous Mycobacteria', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                pw.Text(nonTbMycoResult, style: pw.TextStyle(fontSize: 8, color: nonTbMycoResult == 'Detected' ? PdfColors.red : PdfColors.green)),
                pw.Text('Interpretation:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                pw.Text(interpretation, style: pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('', style: pw.TextStyle(fontSize: 8))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('', style: pw.TextStyle(fontSize: 8))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('', style: pw.TextStyle(fontSize: 8))),
        ],
      ),
    ],
  );

  pw.Widget notesSection() => pw.Container(
    margin: const pw.EdgeInsets.only(top: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Note :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.Bullet(text: 'This test includes 3 targets of which 2 are for Mycobacterium tuberculosis complex (IS6110 & MPB64) and 1 target for Mycobacterium genus (16s rRNA)', style: pw.TextStyle(fontSize: 8)),
        pw.Bullet(text: 'This is an in-house developed Real time PCR assay for Qualitative detection', style: pw.TextStyle(fontSize: 8)),
        pw.Bullet(text: 'Limit of detection of the assay is 1-10 Mycobacteria per PCR', style: pw.TextStyle(fontSize: 8)),
        pw.Bullet(text: 'This test does not differentiate between the Mycobacteria species', style: pw.TextStyle(fontSize: 8)),
        pw.Bullet(text: 'Mycobacterium culture is recommended in case inhibition is detected', style: pw.TextStyle(fontSize: 8)),
      ],
    ),
  );

  pw.Widget commentsSection() => pw.Container(
    margin: const pw.EdgeInsets.only(top: 4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Comments :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.Text(comments, style: pw.TextStyle(fontSize: 8)),
      ],
    ),
  );

  pw.Widget signaturesSection() => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 16),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Text('Medical Lab Technician', style: pw.TextStyle(fontSize: 9)),
            pw.Text('(DMLT, BMLT)', style: pw.TextStyle(fontSize: 8)),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('Dr. Payal Shah', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            pw.Text('(MD, Pathologist)', style: pw.TextStyle(fontSize: 8)),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('Dr. Vimal Shah', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            pw.Text('(MD, Pathologist)', style: pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(18),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
      ),
      build: (context) => [
        headerSection(),
        pw.SizedBox(height: 8),
        patientSection(),
        reportTitle(),
        investigationTable(),
        notesSection(),
        commentsSection(),
        signaturesSection(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text('Generated on : ${_formatDateTime(DateTime.now())}', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey)),
        ),
      ],
    ),
  );

  return pdf.save();
}

/// Generates a retina disease PDF report for the given patient and scan.
///
/// Only the predictions provided in the [predictions] argument will be included in the report.
/// This allows the caller (e.g., ScanResultsScreen) to control which diseases are shown.
Future<Uint8List> generateRetinaReportPdf({
  Uint8List? logoImage,
  required String patientName,
  required int? age,
  required String? sex,
  required String recordNumber,
  required DateTime scanDate,
  required Map<String, dynamic> predictions, // DiseasePrediction values
  String? imageName, // Optional: for image reference
}) async {
  final pdf = pw.Document();

  pw.Widget headerSection() => pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        logoImage != null
            ? pw.Image(pw.MemoryImage(logoImage), width: 50, height: 50)
            : pw.Container(
                width: 50,
                height: 50,
                color: PdfColors.grey300,
                child: pw.Center(child: pw.Text('No Logo', style: pw.TextStyle(fontSize: 10))),
              ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('OCUSCAN RETINA DISEASE REPORT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Text('105-108, Smart Vision Complex, Healthcare Road, Opposite Healthcare Complex, Germany', style: pw.TextStyle(fontSize: 8)),
              pw.Text('0123456789 | ocuscan@lab.com', style: pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),
        pw.Container(
          width: 50,
          height: 50,
          alignment: pw.Alignment.topRight,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: 'https://ocuscan.lab.com',
            width: 40,
            height: 40,
          ),
        ),
      ],
    ),
  );

  pw.Widget patientSection() => pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Patient: $patientName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Age: ${age ?? '-'}'),
              pw.Text('Sex: ${sex ?? '-'}'),
              pw.Text('Record #: $recordNumber'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Sample Collected At:', style: pw.TextStyle(fontSize: 10)),
              pw.Text('${_formatDateTime(scanDate)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text('Ref. By: Dr. AI', style: pw.TextStyle(fontSize: 10)),
              pw.Text('Report Date: ${_formatDateTime(scanDate)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ],
          ),
        )
        
      ],
    ),
  );

  pw.Widget diseaseTable() {
    // Sort predictions by probability descending and take top 3
    final topPredictions = predictions.values
        .where((p) => p != null && p is dynamic && p.probability != null)
        .toList()
        ..sort((a, b) => (b.probability as num).compareTo(a.probability as num));
    final top3 = topPredictions.take(3).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Disease', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Confidence', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Detected', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          ],
        ),
        ...top3.map((p) {
          return pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(p.fullName ?? '-')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(p.probability != null ? '${(p.probability * 100).toStringAsFixed(1)}%' : '-')),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  p.detected == true ? 'Detected' : 'Not detected',
                  style: pw.TextStyle(
                    color: p.detected == true ? PdfColors.red : PdfColors.green,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(18),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
      ),
      build: (context) => [
        headerSection(),
        pw.SizedBox(height: 8),
        patientSection(),
        pw.SizedBox(height: 8),
        if (imageName != null)
          pw.UrlLink(
            destination: '',
            child: pw.Text('Image: $imageName',
              style: pw.TextStyle(
                color: PdfColors.blue,
                decoration: pw.TextDecoration.underline,
                fontSize: 10,
              ),
            ),
          ),
        pw.SizedBox(height: 8),
        diseaseTable(),
        pw.SizedBox(height: 12),
        pw.Text('Note:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.Bullet(text: 'This test uses an AI model for disease prediction from retina images.'),
        pw.Bullet(text: 'Confidence values represent model certainty, not diagnosis.'),
        pw.Bullet(text: 'Consult a specialist for clinical correlation.'),
        pw.SizedBox(height: 8),
        pw.Text('Comments:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.Text('This report is generated by Ocuscan AI. For more information, contact your healthcare provider.', style: pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 18),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(children: [
              pw.Text('Medical Lab Technician', style: pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 16),
              pw.Container(width: 80, height: 1, color: PdfColors.grey300),
            ]),
            pw.Column(children: [
              pw.Text('Dr. Pathologist', style: pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 16),
              pw.Container(width: 80, height: 1, color: PdfColors.grey300),
            ]),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text('Generated on: ${_formatDateTime(DateTime.now())}', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey)),
      ],
    ),
  );

  return pdf.save();
}

String _formatDateTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
