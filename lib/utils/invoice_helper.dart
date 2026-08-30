import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/order_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class InvoiceHelper {
  static Future<void> generateAndShowInvoice(OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('JIGNESH DADA OFFICIAL', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                      pw.Text('Devotional Store & Seva Portal', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Order ID: ${order.orderId}'),
                      pw.Text('Date: ${DateFormat('dd MMM yyyy').format(order.createdAt ?? DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Billing & Shipping Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILLED TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text(order.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(order.address),
                        pw.Text('${order.city}, ${order.state} - ${order.pincode}'),
                        pw.Text('Phone: ${order.phone}'),
                        pw.Text('Email: ${order.email}'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('SHIP FROM:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('Jignesh Dada Seva Trust', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('123 Temple Road, Spiritual Hub'),
                        pw.Text('Ahmedabad, Gujarat - 380001'),
                        pw.Text('GSTIN: 24AAABC1234A1Z1'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  ...order.items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['productName'] ?? 'Sacred Item')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${item['quantity']}', textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('₹${item['price']}', textAlign: pw.TextAlign.right)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _summaryRow('Subtotal:', '₹${order.subtotal.toStringAsFixed(2)}'),
                      _summaryRow('Delivery:', '₹${order.deliveryCharge.toStringAsFixed(2)}'),
                      if (order.discount > 0) _summaryRow('Discount:', '-₹${order.discount.toStringAsFixed(2)}'),
                      _summaryRow('GST (0%):', '₹0.00'),
                      pw.Divider(color: PdfColors.teal, thickness: 1.5),
                      pw.Row(
                        children: [
                          pw.Text('Grand Total:  ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                          pw.Text('₹${order.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('This is a computer-generated document. No signature required.', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    pw.Text('Thank you for your divine contribution. Radhe Radhe!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Show Preview
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _summaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(width: 20),
          pw.SizedBox(width: 80, child: pw.Text(value, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  static Future<void> shareInvoiceWhatsApp(OrderModel order) async {
    final pdf = pw.Document();
    // Re-use the same build logic (should be refactored into a helper if reused often)
    // For simplicity, just generating a minimal one here to demonstrate
    pdf.addPage(pw.Page(build: (c) => pw.Center(child: pw.Text('Invoice for ${order.orderId}'))));
    
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice_${order.orderId}.pdf");
    await file.writeAsBytes(await pdf.save());

    final cleanPhone = order.phone.replaceAll(RegExp(r'[^0-9]'), '');
    // WhatsApp sharing usually requires a message + the file
    await Share.shareXFiles([XFile(file.path)], text: 'Jai Shri Krishna! Here is your invoice for Order ${order.orderId}.');
  }
}
