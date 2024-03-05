import 'package:admin_app/views/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Text(
                      "Available Stock: ",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF050404).withOpacity(0.8),
                      ),
                    ),
                    Text(
                      "${cartItem.stock}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF050404).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: const Color(0xFFd41111).withOpacity(0.8),
                  size: 25,
                ),
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .removeFromCart(cartItem);
                },
              ),
            ],
          ),
          Row(
            children: [
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.white,
                  checkboxTheme: CheckboxThemeData(
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return const Color(0xFF050404).withOpacity(0.9);
                        }
                        return Colors.white;
                      },
                    ),
                  ),
                ),
                child: Checkbox(
                  value: cartItem.isSelected,
                  onChanged: (value) {
                    Provider.of<CartProvider>(context, listen: false)
                        .toggleSelection(cartItem);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF050404),
                    width: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    cartItem.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF050404).withOpacity(0.8),
                      ),
                    ),
                    Text(
                      cartItem.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF050404).withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            cartItem.customerPrice * cartItem.quantity % 1 == 0
                                ? '₱${(cartItem.customerPrice * cartItem.quantity).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'
                                : '₱${(cartItem.customerPrice * cartItem.quantity).toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: const Color(0xFFd41111).withOpacity(0.8),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .decrementQuantity(cartItem);
                              },
                            ),
                            Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF050404).withOpacity(0.8),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .incrementQuantity(cartItem);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
