import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/product_providers.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFav;

  const ProductsGrid(this.showFav, {super.key});

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProviders>(context);
    final products = showFav ? productData.favItems : productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        // create: (c) => products[i],
        value: products[i],
        child: const ProductItem(),
      ),
    );
  }
}
