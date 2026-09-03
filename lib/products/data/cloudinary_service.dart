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

    // Upload preset tells Cloudinary:
    // "Allow this app to upload image without API secret."
    request.fields['upload_preset'] = uploadPreset;

    // Folder where images will be stored in Cloudinary.
    request.fields['folder'] = 'accessory_hub/products';

    // Public ID helps identify image.
    // Example: product P001 image will be named P001.
    request.fields['public_id'] = productId;

    // Read selected image as bytes.
    final bytes = await imageFile.readAsBytes();

    // Attach image file to request.
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ),
    );

    // Send image to Cloudinary.
    final streamedResponse = await request.send();

    // Convert response to readable format.
    final response = await http.Response.fromStream(streamedResponse);

    // If upload failed, show error.
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Cloudinary upload failed: ${response.body}');
    }

    // Convert Cloudinary response text into Map.
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Return image URL and public ID.
    return CloudinaryUploadResult(
      imageUrl: data['secure_url'] ?? '',
      publicId: data['public_id'] ?? '',
    );
  }
}