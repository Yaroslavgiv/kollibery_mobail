import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class HexImage {
  static String _normalize(String value) {
    var v = value.trim();
    if (v.isEmpty) return v;
    // Снимаем внешние кавычки, если они присутствуют
    if ((v.startsWith('"') && v.endsWith('"')) ||
        (v.startsWith("'") && v.endsWith("'"))) {
      v = v.substring(1, v.length - 1).trim();
    }
    // Если data-uri, оставляем только часть после запятой
    if (v.startsWith('data:')) {
      final comma = v.indexOf(',');
      if (comma != -1 && comma + 1 < v.length) {
        v = v.substring(comma + 1);
      }
    }
    return v;
  }

  static bool looksLikeHex(String value) {
    if (value.isEmpty) return false;
    var v = _normalize(value);
    if (v.isEmpty) return false;
    if (v.startsWith('0x') || v.startsWith('0X')) v = v.substring(2);
    if (v.length < 2 || v.length % 2 != 0) return false;
    final hexReg = RegExp(r'^[0-9a-fA-F]+$');
    return hexReg.hasMatch(v);
  }

  static Uint8List? tryDecodeHex(String value) {
    try {
      var v = _normalize(value);
      if (v.startsWith('0x') || v.startsWith('0X')) v = v.substring(2);
      if (!looksLikeHex(v)) return null;
      final length = v.length ~/ 2;
      final bytes = Uint8List(length);
      for (int i = 0; i < length; i++) {
        final byteStr = v.substring(i * 2, i * 2 + 2);
        bytes[i] = int.parse(byteStr, radix: 16);
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static bool looksLikeBase64(String value) {
    if (value.isEmpty) return false;
    final v = _normalize(value);
    if (v.isEmpty) return false;
    if (v.contains(' ')) return false;
    if (v.startsWith('/9j/') || v.startsWith('iVBOR') || v.startsWith('R0lG'))
      return true;
    final b64Reg = RegExp(r'^[A-Za-z0-9+/=]+$');
    return b64Reg.hasMatch(v) && v.length % 4 == 0;
  }

  static Uint8List? tryDecodeBase64(String value) {
    try {
      final v = _normalize(value);
      if (!looksLikeBase64(v)) return null;
      return base64Decode(v);
    } catch (_) {
      return null;
    }
  }

  static ImageProvider? resolveImageProvider(String? value) {
    if (value == null) return null;
    final v = _normalize(value);
    if (v.isEmpty) return null;

    final b64 = tryDecodeBase64(v);
    if (b64 != null) return MemoryImage(b64);

    final hex = tryDecodeHex(v);
    if (hex != null) return MemoryImage(hex);

    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }

    return AssetImage(v);
  }
}
