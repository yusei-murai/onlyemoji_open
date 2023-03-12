import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/function_utils.dart';
import 'package:onlyemoji/utils/widget_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPage extends StatefulWidget {
  QrPage(this.me);
  Account me;

  @override
  _QrPageState createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  File? image;

  @override
  Widget build(BuildContext context) {
    final QrImage qr = QrUtils.qrImage(widget.me.id);

    return Scaffold(
      appBar: AppBarUtils.createAppbar(
          context,
          OutlinedButton(
              style: OutlinedButton.styleFrom(
              side: BorderSide.none,
              ),
              onPressed: () async {
                var result = await FunctionUtils.getImageFromGallery();
                if(result != null){
                  setState(() {
                    image = File(result.path);
                  });
                }
              },
            child: const Icon(Icons.qr_code_scanner_outlined),
         )
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("マイQRコード",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pink,width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.me.name,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
                  const SizedBox(height: 30,),
                  RepaintBoundary(
                      key: GlobalKey(),
                      child: qr
                  ),
                  // OutlinedButton(
                  //   style: OutlinedButton.styleFrom(
                  //     side: BorderSide.none,
                  //   ),
                  //   onPressed: () async {
                  //     await FunctionUtils.saveQr(qr,context);
                  //   },
                  //   child: const Icon(Icons.save_alt_outlined),
                  // )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
