class MaskingUtils {
  MaskingUtils._();

  static String maskAccount(String value, {int visibleCount = 4}) {
    if (value.length <= visibleCount) return value;
    final masked = 'X' * (value.length - visibleCount);
    return '$masked${value.substring(value.length - visibleCount)}';
  }

  static String maskTransactionId(String id, {int visibleCount = 4}) {
    return maskAccount(id.replaceAll('-', ''), visibleCount: visibleCount);
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 2) return email;

    final name = parts[0];
    final domain = parts[1];
    final maskedName =
        '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
    return '$maskedName@$domain';
  }
}
