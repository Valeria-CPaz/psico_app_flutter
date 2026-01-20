String formatPhoneNumber(String phone) {
  // Remove tudo que não é número
  final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

  if (digitsOnly.isEmpty) return '';

  // Se tiver mais de 11 dígitos, corta
  if (digitsOnly.length > 11) {
    return formatPhoneNumber(digitsOnly.substring(0, 11));
  }

  // Formata conforme o número de dígitos
  switch (digitsOnly.length) {
    case 1:
      return '($digitsOnly';
    case 2:
      return '($digitsOnly)';
    case 3:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
    case 4:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
    case 5:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
    case 6:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
    case 7:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
    case 8:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
    case 9:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
    case 10:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
    case 11:
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
    default:
      return digitsOnly;
  }
}