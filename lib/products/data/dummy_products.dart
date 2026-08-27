// This file contains FAKE products so we can build the UI
// without needing Firebase yet. Later we replace this with real data.

import '../models/product.dart';

// This is a simple list of 6 fake products.
// You can add more later by copying and pasting.

List<Product> dummyProducts = [
  Product(
    id: 'P001',
    name: 'iPhone 15 Silicone Case',
    description: 'Premium soft silicone case with microfiber lining. Protects from drops and scratches.',
    image: '',  // empty for now, we use icon placeholder
    price: 299,
    mrp: 499,
    rating: 4.5,
    soldCount: 128,
    stock: 500,
    category: 'Cases',
    compatiblePhones: ['iPhone 15', 'iPhone 15 Pro'],
  ),
  Product(
    id: 'P002',
    name: 'Samsung 25W Fast Charger',
    description: 'Original Samsung 25W USB-C fast charging adapter. Charges 50% in 30 minutes.',
    image: '',
    price: 499,
    mrp: 799,
    rating: 4.8,
    soldCount: 342,
    stock: 0,          // ← OUT OF STOCK on purpose, to test the red badge
    category: 'Chargers',
    compatiblePhones: ['Samsung S24', 'Samsung S23', 'Samsung A54'],
  ),
  Product(
    id: 'P003',
    name: 'AirPods Pro Cover',
    description: 'Shockproof transparent cover for AirPods Pro 2nd gen.',
    image: '',
    price: 149,
    mrp: 299,
    rating: 4.0,
    soldCount: 89,
    stock: 5,          // ← LOW STOCK, to test yellow badge later
    category: 'Cases',
    compatiblePhones: ['AirPods Pro 2'],
  ),
  Product(
    id: 'P004',
    name: 'OnePlus 12 Tempered Glass',
    description: '9H hardness tempered glass screen protector. Anti-fingerprint coating.',
    image: '',
    price: 199,
    mrp: 399,
    rating: 4.3,
    soldCount: 256,
    stock: 1200,
    category: 'Screen Guards',
    compatiblePhones: ['OnePlus 12', 'OnePlus 12R'],
  ),
  Product(
    id: 'P005',
    name: 'Xiaomi 20000mAh Power Bank',
    description: 'Fast charging power bank with dual USB output. Charges 4 phones.',
    image: '',
    price: 1299,
    mrp: 1999,
    rating: 4.6,
    soldCount: 445,
    stock: 35,
    category: 'Power Banks',
    compatiblePhones: ['All USB Devices'],
  ),
  Product(
    id: 'P006',
    name: 'Realme Buds T110',
    description: 'True wireless earbuds with 28 hours battery life and bass boost.',
    image: '',
    price: 999,
    mrp: 1499,
    rating: 4.1,
    soldCount: 67,
    stock: 80,
    category: 'Earphones',
    compatiblePhones: ['All Bluetooth Devices'],
  ),
  Product(
    id: 'P007',
    name: 'Xiaomi 20000mAh Power Bank',
    description: 'Fast charging power bank with dual USB output. Charges 4 phones.',
    image: '',
    price: 1299,
    mrp: 1999,
    rating: 4.6,
    soldCount: 445,
    stock: 35,
    category: 'Power Banks',
    compatiblePhones: ['All USB Devices'],
  ),
];