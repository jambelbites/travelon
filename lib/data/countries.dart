import '../models/country.dart';

final List<Country> countries = [
  // Asia
  Country(
    name: 'Japan',
    code: 'JP',
    continent: 'Asia',
    description:
        'A fascinating blend of traditional culture and modern technology.',
    imageUrl: 'https://images.unsplash.com/photo-1542640244-7e672d6cef4e',
  ),
  Country(
    name: 'Dubai',
    code: 'AE',
    continent: 'Asia',
    description:
        'Ultra-modern architecture, luxury shopping, and desert adventures.',
    imageUrl:
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&q=80', // Dubai skyline
  ),
  Country(
    name: 'Thailand',
    code: 'TH',
    continent: 'Asia',
    description: 'Beautiful beaches, ancient temples, and delicious cuisine.',
    imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a',
  ),
  Country(
    name: 'Vietnam',
    code: 'VN',
    continent: 'Asia',
    description: 'Rich history, stunning landscapes, and vibrant street life.',
    imageUrl:
        'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&q=80', // Ha Long Bay
  ),
  Country(
    name: 'Singapore',
    code: 'SG',
    continent: 'Asia',
    description:
        'Modern city-state with amazing architecture and diverse culture.',
    imageUrl: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd',
  ),

  // Europe
  Country(
    name: 'France',
    code: 'FR',
    continent: 'Europe',
    description: 'Known for art, cuisine, and the iconic Eiffel Tower.',
    imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
  ),
  Country(
    name: 'Italy',
    code: 'IT',
    continent: 'Europe',
    description: 'Home to ancient ruins, art masterpieces, and exquisite food.',
    imageUrl: 'https://images.unsplash.com/photo-1523531294919-4bcd7c65e216',
  ),
  Country(
    name: 'Spain',
    code: 'ES',
    continent: 'Europe',
    description: 'Rich culture, vibrant cities, and beautiful beaches.',
    imageUrl: 'https://images.unsplash.com/photo-1543783207-ec64e4d95325',
  ),
  Country(
    name: 'Greece',
    code: 'GR',
    continent: 'Europe',
    description: 'Ancient history, beautiful islands, and Mediterranean charm.',
    imageUrl:
        'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&q=80', // Santorini
  ),

  // North America
  Country(
    name: 'United States',
    code: 'US',
    continent: 'North America',
    description:
        'Diverse landscapes, vibrant cities, and endless opportunities.',
    imageUrl: 'https://images.unsplash.com/photo-1485738422979-f5c462d49f74',
  ),
  Country(
    name: 'Canada',
    code: 'CA',
    continent: 'North America',
    description: 'Natural beauty, friendly people, and modern cities.',
    imageUrl: 'https://images.unsplash.com/photo-1503614472-8c93d56e92ce',
  ),
  Country(
    name: 'Mexico',
    code: 'MX',
    continent: 'North America',
    description: 'Rich culture, ancient ruins, and beautiful beaches.',
    imageUrl: 'https://images.unsplash.com/photo-1512813195386-6cf811ad3542',
  ),

  // South America
  Country(
    name: 'Brazil',
    code: 'BR',
    continent: 'South America',
    description: 'Vibrant culture, Amazon rainforest, and beautiful beaches.',
    imageUrl: 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325',
  ),
  Country(
    name: 'Peru',
    code: 'PE',
    continent: 'South America',
    description: 'Home to Machu Picchu and ancient Incan culture.',
    imageUrl: 'https://images.unsplash.com/photo-1526392060635-9d6019884377',
  ),
  Country(
    name: 'Argentina',
    code: 'AR',
    continent: 'South America',
    description: 'Tango, wine country, and stunning landscapes.',
    imageUrl:
        'https://images.unsplash.com/photo-1612294037637-ec328d0e075e?auto=format&fit=crop&q=80', // Ecuador Andes Mountains
  ),

  // Africa
  Country(
    name: 'Egypt',
    code: 'EG',
    continent: 'Africa',
    description: 'Ancient pyramids, rich history, and the Nile River.',
    imageUrl: 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750',
  ),
  Country(
    name: 'South Africa',
    code: 'ZA',
    continent: 'Africa',
    description: 'Wildlife safaris, diverse culture, and beautiful landscapes.',
    imageUrl: 'https://images.unsplash.com/photo-1484318571209-661cf29a69c3',
  ),
  Country(
    name: 'Morocco',
    code: 'MA',
    continent: 'Africa',
    description: 'Colorful markets, desert adventures, and ancient medinas.',
    imageUrl: 'https://images.unsplash.com/photo-1489493887464-892be6d1daae',
  ),

  // Oceania
  Country(
    name: 'Australia',
    code: 'AU',
    continent: 'Oceania',
    description:
        'Unique wildlife, beautiful beaches, and the Great Barrier Reef.',
    imageUrl: 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be',
  ),
  Country(
    name: 'New Zealand',
    code: 'NZ',
    continent: 'Oceania',
    description: 'Stunning landscapes, Maori culture, and outdoor adventures.',
    imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800',
  ),
  Country(
    name: 'Fiji',
    code: 'FJ',
    continent: 'Oceania',
    description: 'Paradise islands, crystal clear waters, and friendly people.',
    imageUrl:
        'https://images.unsplash.com/photo-1505881402582-c5bc11054f91?auto=format&fit=crop&q=80', // Fiji beach
  ),
];

// Get unique continents for filtering
final List<String> continents =
    countries.map((country) => country.continent).toSet().toList()..sort();
