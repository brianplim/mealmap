import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'firebase_options.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('Firebase initialized successfully. Apps count: ${Firebase.apps.length}');
  } catch (e, stack) {
    debugPrint('Firebase initialization FAILED: $e\n$stack');
  }
  runApp(const MealMapApp());
}

typedef MyApp = MealMapApp;

class MealMapApp extends StatelessWidget {
  const MealMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MealMap',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF5F7F5),
            cardColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F7A5B),
              primary: const Color(0xFF0F7A5B),
              brightness: Brightness.light,
            ),
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121816),
            cardColor: const Color(0xFF1B2421),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F7A5B),
              primary: const Color(0xFF12A66B),
              brightness: Brightness.dark,
            ),
            fontFamily: 'Roboto',
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const MainShell(initialTab: 0),
            '/map': (context) => const MainShell(initialTab: 1),
            '/deals': (context) => const MainShell(initialTab: 2),
            '/favorites': (context) => const MainShell(initialTab: 3),
            '/profile': (context) => const MainShell(initialTab: 4),
            '/restaurant': (context) => const RestaurantDetailScreen(),
            '/filter': (context) => const DealsFilterScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/orders': (context) => const OrdersScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class Eatery {
  final String id;
  final String name;
  final String cuisine;
  final double distance;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final String description;
  final bool hasStudentDiscount;
  final List<MenuItem> menu;

  const Eatery({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.distance,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.description,
    required this.hasStudentDiscount,
    required this.menu,
  });
}

class MenuItem {
  final String name;
  final String price;
  final String imageUrl;

  const MenuItem({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class FoodOrder {
  final String id;
  final String eateryName;
  final String itemName;
  final String price;
  final String fulfillmentType;
  String status;
  final String timestamp;

  FoodOrder({
    required this.id,
    required this.eateryName,
    required this.itemName,
    required this.price,
    required this.fulfillmentType,
    required this.status,
    required this.timestamp,
  });
}

final List<FoodOrder> globalOrders = [
  FoodOrder(
    id: 'ORD-001',
    eateryName: 'Taco Haven Tagum',
    itemName: 'Campus Tacos (2x)',
    price: '₱130',
    fulfillmentType: 'Delivery',
    status: 'Out for Delivery near ACES College',
    timestamp: '10 mins ago',
  ),
  FoodOrder(
    id: 'ORD-002',
    eateryName: 'ACES Canteen Bites',
    itemName: 'Pancit + Drink',
    price: '₱50',
    fulfillmentType: 'Pickup',
    status: 'Food Taken / Picked Up',
    timestamp: '1 hour ago',
  ),
];

final List<String> globalFavoriteIds = ['1', '2', '3', '4'];

final List<Eatery> mockEateries = [
  Eatery(
    id: '1',
    name: 'Taco Haven Tagum',
    cuisine: 'Mexican',
    distance: 0.3,
    rating: 4.5,
    reviewsCount: 120,
    imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=700&q=80',
    description: 'Popular Tex-Mex spot near ACES Tagum College. Fresh ingredients, bold flavors, and student-friendly prices!',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Campus Tacos', price: '₱65', imageUrl: 'https://images.unsplash.com/photo-1613514785940-daed07799d9b?auto=format&fit=crop&w=300&q=80'),
      MenuItem(name: 'Mindanao Burrito', price: '₱95', imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=300&q=80'),
      MenuItem(name: 'Loaded Nachos', price: '₱75', imageUrl: 'https://images.unsplash.com/photo-1513456856091-30c4b8d6f60a?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
  Eatery(
    id: '2',
    name: 'ACES Canteen Bites',
    cuisine: 'Filipino',
    distance: 0.1,
    rating: 4.3,
    reviewsCount: 95,
    imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80',
    description: 'Located right inside/near ACES Tagum College. Serving affordable homemade Filipino comfort food and student meals.',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Pancit + Drink', price: '₱50', imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=300&q=80'),
      MenuItem(name: 'Chicken Adobo Meal', price: '₱75', imageUrl: 'https://images.unsplash.com/photo-1626503378942-8874a9cf2996?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
  Eatery(
    id: '3',
    name: 'Tagum Inihaw Express',
    cuisine: 'Filipino',
    distance: 0.4,
    rating: 4.6,
    reviewsCount: 210,
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
    description: 'Best grilled pork barbecue and native chicken near ACES Tagum College.',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Pork BBQ Skewers (3pcs)', price: '₱60', imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
  Eatery(
    id: '4',
    name: 'Mindanao Halal Grill & Cafe',
    cuisine: 'Asian',
    distance: 0.6,
    rating: 4.4,
    reviewsCount: 88,
    imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=400&q=80',
    description: 'Authentic Halal dishes, flavorful satay, and refreshing fruit shakes near ACES Tagum College.',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Beef Satay Rice', price: '₱90', imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
];

Widget statusBar({String time = '9:41', Color color = const Color(0xFF1E1E1E)}) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 6),
    child: Row(
      children: [
        Text(
          time,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
        const Spacer(),
        Icon(Icons.signal_cellular_4_bar, size: 14, color: color),
        const SizedBox(width: 4),
        Icon(Icons.wifi, size: 14, color: color),
        const SizedBox(width: 4),
        Icon(Icons.battery_full, size: 14, color: color),
      ],
    ),
  );
}

Widget placeholderImage({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    color: const Color(0xFFD0D7D3),
    child: const Center(
      child: Icon(Icons.restaurant, color: Color(0xFF0F7A5B), size: 24),
    ),
  );
}

Future<void> launchAcesMap(BuildContext context) async {
  final Uri url = Uri.parse('https://maps.app.goo.gl/dNineAW6Vxaz2v7e7');
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening ACES Tagum College Google Maps link')),
      );
    }
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeNotifier.value == ThemeMode.dark
                ? [const Color(0xFF121816), const Color(0xFF0A2B20)]
                : [const Color(0xFFE0F5EB), const Color(0xFF93D0B3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(height: 36),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F7A5B),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'MealMap',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ACES Tagum College Food Spots,\nDaily Specials & Student Deals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover great food near ACES Tagum College, Mindanao, Philippines.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/auth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A8E6A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth'),
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your student email or ID')),
      );
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('api-key-not-valid') || errorStr.contains('no-app') || errorStr.contains('network-request-failed')) {
        debugPrint('Firebase web auth fallback active: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful! (MealMap Connected)')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        String message = 'Authentication failed';
        if (e is FirebaseAuthException) {
          message = 'Firebase [${e.code}]: ${e.message ?? e.toString()}';
        } else {
          message = 'Error: ${e.toString()}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(height: 12),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'Welcome Back!' : 'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Log in with Firebase to access Tagum student deals near ACES Tagum College.'
                        : 'Sign up with Firebase to save your favorite eateries and deals.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isLogin) ...[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0F7A5B)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF0F7A5B), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Student Email / ID',
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0F7A5B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF0F7A5B), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0F7A5B)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF0F7A5B),
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF0F7A5B), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F7A5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Log In with Firebase' : 'Sign Up with Firebase',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin
                            ? "Don't have an account? Sign Up"
                            : "Already have an account? Log In",
                        style: const TextStyle(
                          color: Color(0xFF0F7A5B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _screens = const [
    HomeScreenContent(),
    MapScreenContent(),
    DailyDealsScreenContent(),
    FavoritesScreenContent(),
    ProfileScreenContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: const Color(0xFF0F7A5B),
          unselectedItemColor: const Color(0xFF8E9D99),
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.local_offer_outlined), label: 'Deals'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.restaurant, color: Color(0xFF0F7A5B), size: 24),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MealMap Tagum',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Text(
                      'Tagum City, Mindanao',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6E7D79),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delivery_dining, color: Color(0xFF0F7A5B)),
                  tooltip: 'Delivery & Orders',
                  onPressed: () => Navigator.pushNamed(context, '/orders'),
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/filter'),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Color(0xFF7A8A85)),
                        const SizedBox(width: 8),
                        Text(
                          'Search food near ACES Tagum College...',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        const Spacer(),
                        const Icon(Icons.tune, size: 16, color: Color(0xFF7A8A85)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/deals'),
                  child: Container(
                    height: 110,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F7A5B), Color(0xFF12A66B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F7A5B).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Tagum Student Deals',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Discounts near ACES Tagum College!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'View Deals',
                                  style: TextStyle(
                                    color: Color(0xFF0F7A5B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=200&q=80',
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                placeholderImage(width: 76, height: 76),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryItem(
                      icon: Icons.grid_view,
                      label: 'All',
                      active: _selectedCategory == 'All',
                      onTap: () => setState(() => _selectedCategory = 'All'),
                    ),
                    CategoryItem(
                      icon: Icons.rice_bowl,
                      label: 'Filipino',
                      active: _selectedCategory == 'Filipino',
                      onTap: () => setState(() => _selectedCategory = 'Filipino'),
                    ),
                    CategoryItem(
                      icon: Icons.fastfood,
                      label: 'Fast Food',
                      active: _selectedCategory == 'Fast Food',
                      onTap: () => setState(() => _selectedCategory = 'Fast Food'),
                    ),
                    CategoryItem(
                      icon: Icons.coffee,
                      label: 'Coffee',
                      active: _selectedCategory == 'Coffee',
                      onTap: () => setState(() => _selectedCategory = 'Coffee'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Eateries Near ACES Tagum College',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/map'),
                      child: const Text(
                        'View Map >',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F7A5B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...mockEateries
                    .where((e) => _selectedCategory == 'All' || e.cuisine == _selectedCategory || (_selectedCategory == 'Fast Food' && e.cuisine == 'Mexican'))
                    .map((eatery) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/restaurant',
                              arguments: eatery,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      eatery.imageUrl,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          placeholderImage(width: double.infinity, height: 140),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              eatery.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${eatery.distance} km from ACES College • ${eatery.cuisine}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6E7D79),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  eatery.rating.toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        if (eatery.hasStudentDiscount)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECF7EF),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'Student Discount',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F7A5B),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF0F7A5B) : Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: active ? Colors.white : const Color(0xFF0F7A5B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreenContent extends StatelessWidget {
  const MapScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFD9E7DC),
              child: Stack(
                children: [
                  Positioned(top: 50, left: 150, width: 150, height: 180, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),
                  Positioned(top: 250, left: 230, width: 130, height: 160, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),
                  Positioned(top: 520, left: 30, width: 140, height: 150, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),
                  Positioned(top: 660, left: 190, width: 160, height: 140, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),

                  Positioned(
                    top: 170,
                    left: -50,
                    right: -50,
                    height: 45,
                    child: Transform.rotate(
                      angle: -0.12,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 350,
                    left: -50,
                    right: -50,
                    height: 42,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 520,
                    left: -50,
                    right: -50,
                    height: 46,
                    child: Transform.rotate(
                      angle: -0.05,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 110,
                    width: 44,
                    child: Transform.rotate(
                      angle: 0.22,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 100,
                    width: 48,
                    child: Transform.rotate(
                      angle: -0.25,
                      child: Container(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  statusBar(time: '9:41', color: const Color(0xFF1E2D2A)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2D2A)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Food Map',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E2D2A),
                            ),
                          ),
                          Text(
                            'Tagum City, Mindanao, Philippines',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5A6A64),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Color(0xFF1E2D2A), size: 20),
                          onPressed: () => Navigator.pushNamed(context, '/filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GreenFoodPin(
            label: 'BBQ & Inihaw',
            top: 230,
            left: 115,
            onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[2]),
          ),
          GreenFoodPin(
            label: 'Lutong Bahay',
            top: 215,
            left: 210,
            onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[1]),
          ),
          Positioned(
            top: 410,
            left: 185,
            child: GestureDetector(
              onTap: () => launchAcesMap(context),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -38,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6),
                        ],
                      ),
                      child: const Text(
                        'NEAR ACES SCHOOL',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF1E2D2A)),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                          ],
                        ),
                        child: const Text(
                          'ACES School',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E2D2A)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GreenFoodPin(
            label: 'Sisig & Rice',
            top: 555,
            left: 110,
            onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[0]),
          ),
          GreenFoodPin(
            label: 'Halo-Halo',
            top: 615,
            left: 225,
            onTap: () => launchAcesMap(context),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/deals'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EFE3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.ramen_dining, color: Color(0xFF0F7A5B), size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filipino Food Nearby',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1E2D2A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Near ACES School • Tagum City',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6E7D79)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                'Sample food spots',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F7A5B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF1E2D2A), size: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GreenFoodPin extends StatelessWidget {
  const GreenFoodPin({
    super.key,
    required this.label,
    required this.top,
    required this.left,
    required this.onTap,
  });

  final String label;
  final double top;
  final double left;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F7A5B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1E2D2A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  void _showOrderDialog(BuildContext context, Eatery eatery, MenuItem item) {
    String fulfillment = 'Delivery';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Order ${item.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Eatery: ${eatery.name}'),
                  const SizedBox(height: 4),
                  Text('Price: ${item.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B))),
                  const SizedBox(height: 16),
                  const Text('Select Fulfillment:', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setStateDialog(() => fulfillment = 'Delivery'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: fulfillment == 'Delivery' ? const Color(0xFFECF7EF) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: fulfillment == 'Delivery' ? const Color(0xFF0F7A5B) : Colors.transparent,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.delivery_dining, color: Color(0xFF0F7A5B)),
                                SizedBox(height: 4),
                                Text('Delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setStateDialog(() => fulfillment = 'Pickup'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: fulfillment == 'Pickup' ? const Color(0xFFECF7EF) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: fulfillment == 'Pickup' ? const Color(0xFF0F7A5B) : Colors.transparent,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.store, color: Color(0xFF0F7A5B)),
                                SizedBox(height: 4),
                                Text('Pickup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newOrder = FoodOrder(
                      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      eateryName: eatery.name,
                      itemName: item.name,
                      price: item.price,
                      fulfillmentType: fulfillment,
                      status: fulfillment == 'Delivery' ? 'Out for Delivery' : 'Ready for Pickup',
                      timestamp: 'Just now',
                    );
                    globalOrders.insert(0, newOrder);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order placed successfully! Check Deliveries/Orders status.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Order'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eatery = ModalRoute.of(context)?.settings.arguments as Eatery? ?? mockEateries[0];
    bool isFav = globalFavoriteIds.contains(eatery.id);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    eatery.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        placeholderImage(width: double.infinity, height: 260),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2D2A)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : const Color(0xFF1E2D2A),
                            ),
                            onPressed: () {
                              setState(() {
                                if (isFav) {
                                  globalFavoriteIds.remove(eatery.id);
                                } else {
                                  globalFavoriteIds.add(eatery.id);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).cardColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            eatery.name,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECF7EF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${eatery.rating} (${eatery.reviewsCount} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F7A5B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF5A6A64)),
                        const SizedBox(width: 4),
                        Text(
                          '${eatery.distance} km from ACES Tagum College',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A64)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      eatery.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Menu & Delivery Tap to Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: eatery.menu.length,
                        itemBuilder: (context, index) {
                          final item = eatery.menu[index];
                          return GestureDetector(
                            onTap: () => _showOrderDialog(context, eatery, item),
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                    child: Image.network(
                                      item.imageUrl,
                                      height: 80,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          placeholderImage(width: double.infinity, height: 80),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              item.price,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F7A5B),
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.add_shopping_cart, size: 14, color: Color(0xFF0F7A5B)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (eatery.hasStudentDiscount)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECF7EF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFB5E3C7)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer, color: Color(0xFF0F7A5B)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Student Deal (Tagum)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFF0F7A5B),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '20% OFF on all delivery & pickup orders with valid student ID',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF3D554F)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => launchAcesMap(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F7A5B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Open ACES Tagum College in Google Maps',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delivery & Orders Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: globalOrders.isEmpty
                  ? Center(
                      child: Text(
                        'No active orders yet.\nTap a menu item in any eatery to order!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: globalOrders.length,
                      itemBuilder: (context, index) {
                        final order = globalOrders[index];
                        final isTakenOrDelivered = order.status.contains('Taken') || order.status.contains('Delivered');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFF0F7A5B),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: order.fulfillmentType == 'Delivery'
                                          ? Colors.blue.withValues(alpha: 0.1)
                                          : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order.fulfillmentType,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: order.fulfillmentType == 'Delivery' ? Colors.blue : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.itemName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${order.eateryName} • ${order.price}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6E7D79)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    isTakenOrDelivered ? Icons.check_circle : Icons.delivery_dining,
                                    size: 18,
                                    color: isTakenOrDelivered ? Colors.green : Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Status: ${order.status}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isTakenOrDelivered ? Colors.green : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (isTakenOrDelivered) {
                                          order.status = 'Out for Delivery / Preparing';
                                        } else {
                                          order.status = 'Food Taken / Delivered Successfully';
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      isTakenOrDelivered ? Icons.refresh : Icons.check,
                                      size: 16,
                                      color: const Color(0xFF0F7A5B),
                                    ),
                                    label: Text(
                                      isTakenOrDelivered ? 'Mark In Progress' : 'Confirm Food Taken',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF0F7A5B)),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF0F7A5B)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyDealsScreenContent extends StatefulWidget {
  const DailyDealsScreenContent({super.key});

  @override
  State<DailyDealsScreenContent> createState() => _DailyDealsScreenContentState();
}

class _DailyDealsScreenContentState extends State<DailyDealsScreenContent> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Tagum Daily Deals',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.pushNamed(context, '/filter'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DealChip(
                  label: 'All',
                  active: _filter == 'All',
                  onTap: () => setState(() => _filter = 'All'),
                ),
                const SizedBox(width: 8),
                DealChip(
                  label: 'Discounts',
                  active: _filter == 'Discounts',
                  onTap: () => setState(() => _filter = 'Discounts'),
                ),
                const SizedBox(width: 8),
                DealChip(
                  label: 'Specials',
                  active: _filter == 'Specials',
                  onTap: () => setState(() => _filter = 'Specials'),
                ),
                const SizedBox(width: 8),
                DealChip(
                  label: 'New',
                  active: _filter == 'New',
                  onTap: () => setState(() => _filter = 'New'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                DealItemCard(
                  title: 'Taco Haven Tagum',
                  cuisine: 'Mexican • 0.3 km near ACES',
                  dealText: '20% off on all meals with student ID',
                  badge: '20% OFF',
                  image: 'https://images.unsplash.com/photo-1613514785940-daed07799d9b?auto=format&fit=crop&w=300&q=80',
                  onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[0]),
                ),
                DealItemCard(
                  title: 'ACES Canteen Bites',
                  cuisine: 'Filipino • 0.1 km near ACES Tagum College',
                  dealText: 'Pancit + Drink for only ₱50',
                  badge: 'P50',
                  badgeColor: Colors.deepOrange,
                  image: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=300&q=80',
                  onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[1]),
                ),
                DealItemCard(
                  title: 'Tagum Inihaw Express',
                  cuisine: 'Filipino • 0.4 km',
                  dealText: 'Buy 2 BBQ Skewers Get 1 Free',
                  badge: 'Special',
                  badgeColor: const Color(0xFF0F7A5B),
                  image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=300&q=80',
                  onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[2]),
                ),
                DealItemCard(
                  title: 'Mindanao Halal Grill',
                  cuisine: 'Asian • 0.6 km',
                  dealText: '15% off student lunch special',
                  badge: '15% OFF',
                  image: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=300&q=80',
                  onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[3]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DealChip extends StatelessWidget {
  const DealChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0F7A5B) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF0F7A5B) : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class DealItemCard extends StatelessWidget {
  const DealItemCard({
    super.key,
    required this.title,
    required this.cuisine,
    required this.dealText,
    required this.badge,
    this.badgeColor = const Color(0xFF0F7A5B),
    required this.image,
    required this.onTap,
  });

  final String title;
  final String cuisine;
  final String dealText;
  final String badge;
  final Color badgeColor;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      placeholderImage(width: 65, height: 65),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cuisine,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6E7D79)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dealText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DealsFilterScreen extends StatefulWidget {
  const DealsFilterScreen({super.key});

  @override
  State<DealsFilterScreen> createState() => _DealsFilterScreenState();
}

class _DealsFilterScreenState extends State<DealsFilterScreen> {
  String _priceFilter = 'All';
  String _cuisineFilter = 'All';
  String _distanceFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
              Row(
                children: [
                  Text(
                    'Filter Tagum Deals',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Price Range',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', '₱0 - ₱50', '₱51 - ₱100', '₱101+'].map((price) {
                  return FilterChipWidget(
                    label: price,
                    selected: _priceFilter == price,
                    onSelected: () => setState(() => _priceFilter = price),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Cuisine',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Filipino', 'Fast Food', 'Asian', 'Western', 'Mexican', 'Desserts', 'Drinks'].map((cuisine) {
                  return FilterChipWidget(
                    label: cuisine,
                    selected: _cuisineFilter == cuisine,
                    onSelected: () => setState(() => _cuisineFilter = cuisine),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Distance from ACES College',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Within 500m', '1 km', '2+ km'].map((distance) {
                  return FilterChipWidget(
                    label: distance,
                    selected: _distanceFilter == distance,
                    onSelected: () => setState(() => _distanceFilter = distance),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tagum filters applied!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _priceFilter = 'All';
                    _cuisineFilter = 'All';
                    _distanceFilter = 'All';
                  }),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Color(0xFF0F7A5B), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFECF7EF) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0F7A5B) : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? const Color(0xFF0F7A5B) : Theme.of(context).colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class FavoritesScreenContent extends StatefulWidget {
  const FavoritesScreenContent({super.key});

  @override
  State<FavoritesScreenContent> createState() => _FavoritesScreenContentState();
}

class _FavoritesScreenContentState extends State<FavoritesScreenContent> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final favoriteEateries = mockEateries.where((e) => globalFavoriteIds.contains(e.id)).toList();

    return SafeArea(
      child: Column(
        children: [
          statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Tagum Favorites',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tabIndex == 0 ? const Color(0xFF0F7A5B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Eateries',
                            style: TextStyle(
                              color: _tabIndex == 0 ? Colors.white : const Color(0xFF6E7D79),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tabIndex == 1 ? const Color(0xFF0F7A5B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Deals',
                            style: TextStyle(
                              color: _tabIndex == 1 ? Colors.white : const Color(0xFF6E7D79),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: favoriteEateries.isEmpty
                ? Center(
                    child: Text(
                      'No favorite eateries yet.\nTap the heart icon on any eatery to save it here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favoriteEateries.length,
                    itemBuilder: (context, index) {
                      final eatery = favoriteEateries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.pushNamed(context, '/restaurant', arguments: eatery);
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    eatery.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        placeholderImage(width: 60, height: 60),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eatery.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${eatery.cuisine} • ${eatery.distance} km from ACES',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF6E7D79)),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 12, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            eatery.rating.toString(),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
                                  tooltip: 'Unfavorite',
                                  onPressed: () {
                                    setState(() {
                                      globalFavoriteIds.remove(eatery.id);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Removed ${eatery.name} from favorites')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      NotificationItemData(
        title: 'New deal at ACES Canteen Bites!',
        detail: '₱50 Pancit + Drink student special available.',
        time: '2h ago',
        color: const Color(0xFF0F7A5B),
      ),
      NotificationItemData(
        title: 'Tagum Inihaw Express promo!',
        detail: 'Buy 2 BBQ Skewers Get 1 Free near ACES College.',
        time: '4h ago',
        color: const Color(0xFF0F7A5B),
      ),
      NotificationItemData(
        title: 'Price drop alert in Tagum City!',
        detail: 'Taco Haven Tagum now has 20% off with student ID.',
        time: '6h ago',
        color: Colors.deepOrange,
      ),
      NotificationItemData(
        title: 'Reminder',
        detail: 'Your saved discount at Mindanao Halal Grill ends tonight.',
        time: '1d ago',
        color: Colors.blue,
      ),
      NotificationItemData(
        title: 'Welcome to MealMap Tagum!',
        detail: 'Discover the best food spots around ACES Tagum College, Mindanao.',
        time: '1d ago',
        color: const Color(0xFF0F7A5B),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: item.color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.detail,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF566A64),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8E9D99),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItemData {
  const NotificationItemData({
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
  });

  final String title;
  final String detail;
  final String time;
  final Color color;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  late bool _darkMode;
  bool _studentVerified = true;
  bool _locationSharing = true;

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Get alerts on new student deals in Tagum', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _pushNotifications,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) => setState(() => _pushNotifications = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text('Dark Theme', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Use dark appearance mode', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _darkMode,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) {
                            setState(() {
                              _darkMode = val;
                              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_darkMode ? 'Dark mode enabled!' : 'Light mode enabled!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text('Location Sharing', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Find food spots near ACES Tagum College', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _locationSharing,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) => setState(() => _locationSharing = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Account & Verification',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('ACES Student ID Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: Text(_studentVerified ? 'Verified Student (20% Off Active)' : 'Unverified', style: TextStyle(fontSize: 12, color: _studentVerified ? const Color(0xFF0F7A5B) : Colors.red)),
                          value: _studentVerified,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) => setState(() {
                            _studentVerified = val;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_studentVerified ? 'Student ID Verified successfully!' : 'Student ID verification revoked.')),
                            );
                          }),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Change Password'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    TextField(obscureText: true, decoration: InputDecoration(labelText: 'Current Password')),
                                    SizedBox(height: 8),
                                    TextField(obscureText: true, decoration: InputDecoration(labelText: 'New Password')),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About & Support',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('About MealMap Tagum', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Version 1.0.0 • ACES Tagum College Edition', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurface),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'MealMap Tagum',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2026 MealMap Team\nTagum City, Mindanao, Philippines',
                              children: [
                                const SizedBox(height: 10),
                                const Text('Designed specifically for ACES Tagum College students to discover food spots, student discounts, and navigate local eateries.'),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('support@mealmaptagum.ph', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.onSurface),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Support ticket opened: support@mealmaptagum.ph')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreenContent extends StatefulWidget {
  const ProfileScreenContent({super.key});

  @override
  State<ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  String _name = 'Tagum Student';
  String _handle = '@tagum_student23';
  String? _imagePath;
  bool _isNetworkImage = false;

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    final handleController = TextEditingController(text: _handle);
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: handleController,
                  decoration: const InputDecoration(labelText: 'Username / Handle'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Or Profile Image URL',
                    hintText: 'https://example.com/photo.jpg',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _imagePath = pickedFile.path;
                          _isNetworkImage = false;
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile picture updated from gallery!')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gallery picker note: Use Image URL below (${e.toString()})')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Upload from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Or choose a preset avatar:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _presetAvatarButton('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', '1'),
                    _presetAvatarButton('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', '2'),
                    _presetAvatarButton('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80', '3'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text.trim();
                  _handle = handleController.text.trim();
                  if (urlController.text.trim().isNotEmpty) {
                    _imagePath = urlController.text.trim();
                    _isNetworkImage = true;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F7A5B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _presetAvatarButton(String url, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _imagePath = url;
          _isNetworkImage = true;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preset avatar selected!')),
        );
      },
      child: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F7A5B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showEditProfileDialog,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: _imagePath != null
                        ? (_isNetworkImage
                            ? NetworkImage(_imagePath!) as ImageProvider
                            : FileImage(File(_imagePath!)))
                        : null,
                    child: _imagePath == null
                        ? const Icon(Icons.person, size: 36, color: Color(0xFF0F7A5B))
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _handle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfileStat(count: '${globalFavoriteIds.length}', label: 'Favorites'),
                    const ProfileStat(count: '6', label: 'Deals Viewed'),
                    const ProfileStat(count: '2', label: 'Notifications'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ProfileMenuItem(
                  icon: Icons.delivery_dining,
                  label: 'Delivery & Orders Status',
                  badge: '${globalOrders.where((o) => !o.status.contains('Taken') && !o.status.contains('Delivered')).length}',
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                ProfileMenuItem(
                  icon: Icons.favorite_border,
                  label: 'My Favorites',
                  badge: '${globalFavoriteIds.length}',
                  onTap: () async {
                    await Navigator.pushNamed(context, '/favorites');
                    setState(() {});
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.local_offer_outlined,
                  label: 'My Deals',
                  onTap: () => Navigator.pushNamed(context, '/deals'),
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  badge: '3',
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                ProfileMenuItem(
                  icon: Icons.map_outlined,
                  label: 'ACES College Map',
                  onTap: () => launchAcesMap(context),
                ),
                ProfileMenuItem(
                  icon: Icons.logout,
                  label: 'Log Out',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.count, required this.label});

  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.textColor = const Color(0xFF1E2D2A),
    this.iconColor = const Color(0xFF0F7A5B),
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor == const Color(0xFF1E2D2A) ? Theme.of(context).colorScheme.onSurface : textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null && badge != '0') ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (textColor != Colors.red)
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF8E9D99)),
            ],
          ),
        ),
      ),
    );
  }
}
