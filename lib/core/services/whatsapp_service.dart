import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._();

  static Future<void> enviarMensaje({
    required String telefono,
    String mensaje = '',
  }) async {
    final url = Uri.parse(
      'https://wa.me/502$telefono?text=${Uri.encodeComponent(mensaje)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('No se pudo abrir WhatsApp');
    }
  }

  static Future<void> llamar(String telefono) async {
    final url = Uri.parse('tel:+502$telefono');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('No se pudo realizar la llamada');
    }
  }
}
