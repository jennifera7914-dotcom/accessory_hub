import '../models/product.dart';

// This is only backup/testing data.
// Main app is now using Firebase.

List<Product> dummyProducts = [
  Product(
    id: 'P001',
    name: 'iPhone 15 Silicone Case',
    description: 'Premium soft silicone case with microfiber lining.',
    image: '',
    mrp: 499,
    stock: 500,
    category: 'Cases',
    compatiblePhones: ['iPhone 15', 'iPhone 15 Pro'],
    isFeatured: true,
    isNewArrival: true,
  ),

  Product(
    id: 'P002',
    name: 'Samsung 25W Fast Charger',
    description: 'USB-C fast charging adapter.',
    image: '',
    mrp: 799,
    stock: 0,
    category: 'Chargers',
    compatiblePhones: ['Samsung S24', 'Samsung S23', 'Samsung A54'],
    isFeatured: true,
    isNewArrival: false,
  ),

  Product(
    id: 'P003',
    name: 'AirPods Pro Cover',
    description: 'Shockproof transparent cover for AirPods Pro.',
    image: '',
    mrp: 299,
    stock: 5,
    category: 'Cases',
    compatiblePhones: ['AirPods Pro 2'],
    isFeatured: false,
    isNewArrival: true,
  ),
];