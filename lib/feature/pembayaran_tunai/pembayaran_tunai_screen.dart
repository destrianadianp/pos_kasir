import 'package:flutter/material.dart';
import 'package:pos_kasir/feature/transaksi/transaksi_berhasil_screen.dart';
import 'package:pos_kasir/feature/ui/color.dart';
import 'package:pos_kasir/feature/ui/dimension.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_button.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_text_form_field.dart';

class PembayaranTunaiScreen extends StatefulWidget {
  final double totalPayment;
  final String? note;

  const PembayaranTunaiScreen({
    super.key, 
    required this.totalPayment,
    this.note});

  @override
  State<PembayaranTunaiScreen> createState() => _PembayaranTunaiScreenState();
}

class _PembayaranTunaiScreenState extends State<PembayaranTunaiScreen> {
  final _nominalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Tunai"),
        actions: [
          Text("Rp${widget.totalPayment.toStringAsFixed(0)}"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(screenPadding),
        child: Column(
          children: [
            CustomTextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: space400),
            CustomButton(
              child: const Text("Bayar Sekarang"),
              onPressed: () {
                double receivedAmount =
                    double.tryParse(_nominalController.text) ?? 0.0;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionSuccessScreen(
                      totalBill: widget.totalPayment,
                      receivedAmount: receivedAmount,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
