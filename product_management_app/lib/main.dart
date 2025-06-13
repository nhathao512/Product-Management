import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/screens/product_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProvider())],
      child: MaterialApp(
        title: 'Quản lý sản phẩm',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ProductListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
