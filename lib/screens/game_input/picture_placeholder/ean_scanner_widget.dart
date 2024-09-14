import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/utils/typedefs/typedefs.dart';

class EanScannerWidget extends StatefulWidget {
  const EanScannerWidget({super.key, required this.onEanScanned});

  final StringCallback onEanScanned;

  @override
  State<EanScannerWidget> createState() => _EanScannerWidgetState();
}

class _EanScannerWidgetState extends State<EanScannerWidget> {
  String? ean;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ean == null
            ? IconButton(
                onPressed: () async {
                  var eanNumber = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleBarcodeScannerPage(),
                      ));
                  if (eanNumber is String) {
                    widget.onEanScanned.call(eanNumber);
                    setState(() {
                      ean = eanNumber;
                    });
                  }
                },
                icon: Image.asset("assets/icons/barcode.webp"))
            : TextButton.icon(
                onPressed: () async {
                  String? ean = await openGameEanScanner(context);
                  if (ean != null) {
                    widget.onEanScanned(ean);
                    setState(() {
                      this.ean = ean;
                    });
                  }
                },
                icon: Image.asset("assets/icons/barcode.webp", width: 150, height: 150,),
                label: Text(ean!, style: context.textStyle.bodySmall,),
              ),
      ),
    );
  }
}
