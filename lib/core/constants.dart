class Branch {
  const Branch({
    required this.name,
    required this.address,
    required this.landmark,
    required this.phone,
    required this.hours,
  });

  final String name;
  final String address;
  final String landmark;
  final String phone;
  final String hours;
}

class SocialLink {
  const SocialLink({required this.label, required this.handle, required this.url});

  final String label;
  final String handle;
  final String url;
}

class AppConstants {
  static const clinicName = 'DentiCare Dental Clinic';
  static const clinicPhone = '(02) 8123-4567';
  static const clinicEmail = 'hello@denticare.com';
  static const clinicAddress = '123 Smile Street, Quezon City';
  static const clinicHours =
      'Mon–Fri 8:00 AM – 5:00 PM · Sat 8:00 AM – 12:00 PM';

  static const tagline = 'Your smile, our passion.';

  static const mission =
      'To provide gentle, high-quality, and affordable dental care that helps '
      'every patient achieve a healthy, confident smile in a comfortable and '
      'welcoming environment.';

  static const vision =
      'To be the most trusted community dental clinic — known for compassionate '
      'care, modern treatments, and lasting relationships with the families we serve.';

  /// Highlights shown on the About screen.
  static const freeConsultation =
      'Free consultation for both online and walk-in patients. Book a visit or '
      'drop by any branch and our dentists will assess your needs at no charge.';

  static const socialLinks = [
    SocialLink(
      label: 'Facebook',
      handle: '@DentiCareDentalClinic',
      url: 'https://facebook.com/DentiCareDentalClinic',
    ),
    SocialLink(
      label: 'Instagram',
      handle: '@denticare.ph',
      url: 'https://instagram.com/denticare.ph',
    ),
    SocialLink(
      label: 'TikTok',
      handle: '@denticare.ph',
      url: 'https://tiktok.com/@denticare.ph',
    ),
    SocialLink(
      label: 'Email',
      handle: 'hello@denticare.com',
      url: 'mailto:hello@denticare.com',
    ),
  ];

  static const branches = [
    Branch(
      name: 'DentiCare — Quezon City (Main)',
      address: '123 Smile Street, Brgy. Diliman, Quezon City',
      landmark: 'Beside Diliman Public Market, across from the BPI branch',
      phone: '(02) 8123-4567',
      hours: 'Mon–Fri 8:00 AM – 5:00 PM · Sat 8:00 AM – 12:00 PM',
    ),
    Branch(
      name: 'DentiCare — Makati',
      address: '2nd Flr, Pearl Building, Chino Roces Ave, Makati City',
      landmark: 'Near Chino Roces MRT-3 access, above the corner pharmacy',
      phone: '(02) 8234-5678',
      hours: 'Mon–Sat 9:00 AM – 6:00 PM',
    ),
    Branch(
      name: 'DentiCare — Caloocan',
      address: 'Unit 5, Northgate Plaza, Samson Road, Caloocan City',
      landmark: 'Fronting Monumento Circle, beside Jollibee Samson Road',
      phone: '(02) 8345-6789',
      hours: 'Mon–Sat 9:00 AM – 6:00 PM · Sun by appointment',
    ),
  ];

  /// Fallback when clinic presets are not loaded yet.
  static const defaultProcedureTemplates = [
    {'id': 'checkup', 'name': 'Checkup', 'defaultCost': 800, 'defaultNotes': 'Routine dental examination'},
    {'id': 'cleaning', 'name': 'Cleaning', 'defaultCost': 1500, 'defaultNotes': 'Professional teeth cleaning'},
    {'id': 'filling', 'name': 'Filling', 'defaultCost': 2000, 'defaultNotes': 'Tooth-colored composite filling'},
    {'id': 'extraction', 'name': 'Extraction', 'defaultCost': 2500, 'defaultNotes': 'Simple tooth extraction'},
    {'id': 'root_canal', 'name': 'Root Canal', 'defaultCost': 8000, 'defaultNotes': 'Endodontic treatment'},
    {'id': 'crown', 'name': 'Crown', 'defaultCost': 15000, 'defaultNotes': 'Porcelain crown placement'},
    {'id': 'implant', 'name': 'Implant', 'defaultCost': 45000, 'defaultNotes': 'Dental implant procedure'},
    {'id': 'whitening', 'name': 'Whitening', 'defaultCost': 12000, 'defaultNotes': 'In-office whitening session'},
    {'id': 'orthodontics', 'name': 'Orthodontics', 'defaultCost': 35000, 'defaultNotes': 'Orthodontic consultation / braces'},
    {'id': 'other', 'name': 'Other', 'defaultCost': 0, 'defaultNotes': ''},
  ];
}
