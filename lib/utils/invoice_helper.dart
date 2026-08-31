import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/order_model.dart';

class InvoiceHelper {
  static Future<Uint8List> generateInvoice(OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('DADA SACRED OFFERINGS', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(order.customerName),
                      pw.Text(order.address),
                      pw.Text('${order.city}, ${order.state} - ${order.pincode}'),
                      pw.Text('Phone: ${order.phone}'),
                      pw.Text('Email: ${order.email}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Order Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Order ID: ${order.orderId}'),
                      pw.Text('Date: ${order.createdAt.toString().split(' ')[0]}'),
                      pw.Text('Payment: ${order.paymentMethod}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Product Name', 'Quantity', 'Price', 'Total'],
                data: order.items.map((item) => [
                  item['productName'],
                  item['quantity'].toString(),
                  'INR ${item['price']}',
                  'INR ${(item['price'] * item['quantity'])}',
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: INR ${order.subtotal}'),
                      pw.Text('Shipping: INR ${order.deliveryCharge}'),
                      pw.Text('Tax: INR ${order.tax}'),
                      pw.Divider(),
                      pw.Text('Grand Total: INR ${order.totalAmount}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text('Thank you for choosing Pu. Dada Sacred Offerings. Radhe Radhe!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printInvoice(OrderModel order) async {
    final pdfBytes = await generateInvoice(order);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  static Future<void> shareToWhatsApp(OrderModel order) async {
    final pdfBytes = await generateInvoice(order);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Invoice_${order.orderId}.pdf');
    await file.writeAsBytes(pdfBytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Radhe Radhe! Here is your order invoice from Dada Sacred Offerings. Order ID: ${order.orderId}',
    );
  }

  // Compatibility methods for Admin Panel
  static Future<void> generateAndShowInvoice(OrderModel order) async {
    await printInvoice(order);
  }
  
  static Future<void> shareInvoiceOnWhatsApp(OrderModel order) async {
    await shareToWhatsApp(order);
  }
}
