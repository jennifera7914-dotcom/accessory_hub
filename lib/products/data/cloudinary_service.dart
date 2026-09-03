import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// This class stores the result we get back from Cloudinary.
class CloudinaryUploadResult {
  final String imageUrl;
  final String publicId;

  CloudinaryUploadResult({
    required this.imageUrl,
    required this.publicId,
  });
}

class CloudinaryService {
  // Replace these two values with YOUR Cloudinary details.
  static const String cloudName = 'daffvucv';
  static const String uploadPreset = 'accessory_hub_unsigned';

  // This function uploads one product image to Cloudinary.
  static Future<CloudinaryUploadResult> uploadProductImage({
    required XFile imageFile,
    required String productId,
  }) async {
    final Uri url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = 'accessory_hub/products';

    // Unique public id prevents duplicate-name upload problems.
    // Example: P001_1723456789123
    request.fields['public_id'] =
        '${productId}_${DateTime.now().millisecondsSinceEpoch}';

    final bytes = await imageFile.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Cloudinary upload failed: ${response.body}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return CloudinaryUploadResult(
      imageUrl: data['secure_url'] ?? '',
      publicId: data['public_id'] ?? '',
    );
  }
}