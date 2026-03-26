import '../models/service_item.dart';

class MockService extends ServiceItem {
  const MockService({
    required super.title,
    required super.category,
    required super.description,
    required super.provider,
    required super.price,
    required super.rating,
    required super.imageUrl,
    required super.location,
    required super.active,
  });
}

class MockChat {
  final String name;
  final String role;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool unread;

  const MockChat({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}

class MockReview {
  final String name;
  final double rating;
  final String comment;
  final String date;

  const MockReview({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

const List<String> categories = <String>[
  'Diseño',
  'Reparaciones',
  'Tutorías',
  'Tecnología',
  'Hogar',
  'Belleza',
];

const List<MockService> mockServices = <MockService>[
  MockService(
    title: 'Diseño de logo profesional',
    category: 'Diseño',
    description: 'Creación de identidad visual moderna para marcas locales.',
    provider: 'Laura Méndez',
    price: '\$120.000',
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
    location: 'Bogotá, Colombia',
    active: true,
  ),
  MockService(
    title: 'Clases personalizadas de matemáticas',
    category: 'Tutorías',
    description:
        'Acompañamiento académico para bachillerato y primeros semestres.',
    provider: 'Andrés Rojas',
    price: '\$35.000 / hora',
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7',
    location: 'Soacha, Colombia',
    active: true,
  ),
  MockService(
    title: 'Mantenimiento de computadores',
    category: 'Tecnología',
    description:
        'Diagnóstico, limpieza y optimización de equipos de escritorio y portátiles.',
    provider: 'Carlos Pérez',
    price: '\$90.000',
    rating: 4.7,
    imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475',
    location: 'Chía, Colombia',
    active: false,
  ),
];

const List<MockChat> mockChats = <MockChat>[
  MockChat(
    name: 'Laura Méndez',
    role: 'Diseñadora gráfica',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    lastMessage: 'Te envío una propuesta visual esta tarde.',
    time: '2:30 PM',
    unread: true,
  ),
  MockChat(
    name: 'Andrés Rojas',
    role: 'Tutor académico',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    lastMessage: 'Tengo disponibilidad mañana en la mañana.',
    time: 'Ayer',
    unread: false,
  ),
  MockChat(
    name: 'Carlos Pérez',
    role: 'Soporte técnico',
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
    lastMessage: 'Puedo revisar el equipo en tu domicilio.',
    time: 'Lun',
    unread: false,
  ),
];

const List<MockReview> mockReviews = <MockReview>[
  MockReview(
    name: 'Mariana Torres',
    rating: 5.0,
    comment: 'Excelente atención y muy buena presentación del servicio.',
    date: '12 Feb 2026',
  ),
  MockReview(
    name: 'David Gómez',
    rating: 4.5,
    comment: 'La experiencia fue clara y profesional. Volvería a contratar.',
    date: '28 Ene 2026',
  ),
  MockReview(
    name: 'Paula Herrera',
    rating: 4.8,
    comment: 'Muy buena comunicación y entrega visual bastante cuidada.',
    date: '14 Ene 2026',
  ),
];
