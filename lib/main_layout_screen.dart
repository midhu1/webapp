import 'package:flutter/material.dart';

enum ActiveTab { home, features, pricing, workspace }

class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  String priority; // 'Low', 'Medium', 'High'

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = 'Medium',
  });
}

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  // Navigation State
  ActiveTab _currentTab = ActiveTab.home;

  // Hover States for Navbar & Cards
  String? _hoveredNavItem;
  String? _hoveredCardId;

  // Todo App States
  final List<TodoItem> _todos = [
    TodoItem(id: '1', title: 'Learn Flutter Web optimizations', isCompleted: true, priority: 'High'),
    TodoItem(id: '2', title: 'Review PR for the backend API', isCompleted: false, priority: 'Medium'),
    TodoItem(id: '3', title: 'Setup Firebase Hosting', isCompleted: false, priority: 'High'),
    TodoItem(id: '4', title: 'Water the plants', isCompleted: false, priority: 'Low'),
  ];

  String _filter = 'All'; // 'All', 'Active', 'Completed'
  String _searchQuery = '';
  final TextEditingController _addController = TextEditingController();
  String _newTodoPriority = 'Medium';
  final FocusNode _addFocusNode = FocusNode();

  @override
  void dispose() {
    _addController.dispose();
    _addFocusNode.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_addController.text.trim().isEmpty) return;
    setState(() {
      _todos.insert(0, TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _addController.text.trim(),
        priority: _newTodoPriority,
      ));
      _addController.clear();
      _newTodoPriority = 'Medium';
    });
    _addFocusNode.requestFocus();
  }

  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((t) => t.id == id);
      todo.isCompleted = !todo.isCompleted;
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
  }

  void _clearCompleted() {
    setState(() {
      _todos.removeWhere((t) => t.isCompleted);
    });
  }

  double get _completionRate {
    if (_todos.isEmpty) return 0.0;
    return _todos.where((t) => t.isCompleted).length / _todos.length;
  }

  List<TodoItem> get _filteredTodos {
    return _todos.where((t) {
      if (_filter == 'Active' && t.isCompleted) return false;
      if (_filter == 'Completed' && !t.isCompleted) return false;
      if (_searchQuery.isNotEmpty && !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return const Color(0xFFEF4444);
      case 'Medium': return const Color(0xFFF59E0B);
      case 'Low': return const Color(0xFF10B981);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 992;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      // Drawer is used for mobile menu
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(isMobile),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: _buildCurrentTabContent(isMobile),
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- NAVIGATION BAR ---
  Widget _buildNavBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo / Brand
              GestureDetector(
                onTap: () => setState(() => _currentTab = ActiveTab.home),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.blur_on, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'AURA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Options (Desktop)
              if (!isMobile)
                Row(
                  children: [
                    _buildNavButton('Home', ActiveTab.home),
                    _buildNavButton('Features', ActiveTab.features),
                    _buildNavButton('Pricing', ActiveTab.pricing),
                    _buildNavButton('Workspace', ActiveTab.workspace),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _currentTab = ActiveTab.workspace),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        elevation: 0,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
                      ),
                      child: const Text('Launch App', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              else
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, ActiveTab tab) {
    final bool isSelected = _currentTab == tab;
    final bool isHovered = _hoveredNavItem == label;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredNavItem = label),
      onExit: (_) => setState(() => _hoveredNavItem = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : (isHovered ? const Color(0xFFEC4899) : Colors.transparent),
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isHovered ? Colors.white : Colors.white.withOpacity(0.6)),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // --- MOBILE DRAWER ---
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.blur_on, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AURA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem('Home', ActiveTab.home, Icons.home_outlined),
          _buildDrawerItem('Features', ActiveTab.features, Icons.bolt_outlined),
          _buildDrawerItem('Pricing', ActiveTab.pricing, Icons.payments_outlined),
          _buildDrawerItem('Workspace App', ActiveTab.workspace, Icons.widgets_outlined),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, ActiveTab tab, IconData icon) {
    final bool isSelected = _currentTab == tab;

    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF6366F1) : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white10,
      onTap: () {
        setState(() => _currentTab = tab);
        Navigator.pop(context); // Close the drawer
      },
    );
  }

  // --- TAB ROUTING ---
  Widget _buildCurrentTabContent(bool isMobile) {
    switch (_currentTab) {
      case ActiveTab.home:
        return _buildHomeTab(isMobile);
      case ActiveTab.features:
        return _buildFeaturesTab(isMobile);
      case ActiveTab.pricing:
        return _buildPricingTab(isMobile);
      case ActiveTab.workspace:
        return _buildWorkspaceTab();
    }
  }

  // ==========================================
  // 1. HOME TAB (LANDING PAGE)
  // ==========================================
  Widget _buildHomeTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Banner Section
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Glowing Gradient Headline
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                  ).createShader(bounds),
                  child: Text(
                    'The Next-Gen\nTask Space',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 42 : 64,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Organize your work with custom priorities, responsive widgets, and high-fidelity progress meters. Aura keeps your focus exactly where it matters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 19,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _currentTab = ActiveTab.workspace),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Row(
                        children: [
                          Text('Get Started Free', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => setState(() => _currentTab = ActiveTab.features),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Explore Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 64),

        // Live App Mockup Render
        Center(
          child: Column(
            children: [
              Text(
                'LIVE WORKSPACE PREVIEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: const Color(0xFFEC4899).withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 750,
                decoration: BoxDecoration(
                  color: const Color(0xFF151D30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: IgnorePointer(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aura Todo',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Focus on what matters.',
                                style: TextStyle(fontSize: 12, color: Colors.white30),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 44, height: 44,
                            child: CustomPaint(
                              painter: CircularProgressPainter(progress: 0.6),
                              child: const Center(
                                child: Text('60%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Sample task items
                      _buildMockTodoItem('Develop high-fidelity UI sections', 'High', true),
                      _buildMockTodoItem('Configure global landing page routing', 'Medium', false),
                      _buildMockTodoItem('Check responsive layout metrics', 'Low', false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 64),

        // Quick Features Block
        Text(
          'Built for creators and developers.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 32),

        if (isMobile)
          Column(
            children: [
              _buildFeatureCard(
                cardId: 'feat_1',
                icon: Icons.bolt,
                iconColor: const Color(0xFFF59E0B),
                title: 'Instant Execution',
                description: 'Create and sort tasks immediately. Zero clutter, pure focus on execution.',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                cardId: 'feat_2',
                icon: Icons.pie_chart_outline,
                iconColor: const Color(0xFF6366F1),
                title: 'Visual Insights',
                description: 'Beautiful circular progress indicators dynamically illustrate your active workspace progress.',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                cardId: 'feat_3',
                icon: Icons.phonelink,
                iconColor: const Color(0xFFEC4899),
                title: 'Responsive Design',
                description: 'A fully responsive layout configured perfectly for desktop, tablet, and mobile browsers.',
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeatureCard(
                  cardId: 'feat_1',
                  icon: Icons.bolt,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Instant Execution',
                  description: 'Create and sort tasks immediately. Zero clutter, pure focus on execution.',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFeatureCard(
                  cardId: 'feat_2',
                  icon: Icons.pie_chart_outline,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Visual Insights',
                  description: 'Beautiful circular progress indicators dynamically illustrate your active workspace progress.',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFeatureCard(
                  cardId: 'feat_3',
                  icon: Icons.phonelink,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Responsive Design',
                  description: 'A fully responsive layout configured perfectly for desktop, tablet, and mobile browsers.',
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMockTodoItem(String title, String priority, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F19),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF10B981) : Colors.white30,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: done ? Colors.white30 : Colors.white,
              decoration: done ? TextDecoration.lineThrough : null,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getPriorityColor(priority).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              priority,
              style: TextStyle(color: _getPriorityColor(priority), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String cardId,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final bool isHovered = _hoveredCardId == cardId;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCardId = cardId),
      onExit: (_) => setState(() => _hoveredCardId = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF151D30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? iconColor.withOpacity(0.6) : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. FEATURES TAB
  // ==========================================
  Widget _buildFeaturesTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Engineered for Peak Performance',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'Explore the advanced mechanics powering Aura Todo.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5)),
        ),
        const SizedBox(height: 48),

        // Double column layouts explaining features
        if (isMobile)
          Column(
            children: [
              _buildFeaturePanel(
                title: 'Smart Priority Engine',
                description: 'Flag tasks as High, Medium, or Low. Color-coded signals enable rapid scan times so you always know what deserves immediate action next.',
                icon: Icons.label_important_outline,
                accentColor: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 24),
              _buildFeaturePanel(
                title: 'Visual Analytics Ring',
                description: 'A custom vector-drawn progress indicator computes your completion percentage. Keep track of achievements dynamically as you toggle tasks.',
                icon: Icons.track_changes,
                accentColor: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 24),
              _buildFeaturePanel(
                title: 'Realtime Search & Filtering',
                description: 'Locate tasks quickly with instantaneous query matching. Filter list views dynamically between all, active, and completed statuses.',
                icon: Icons.search,
                accentColor: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 24),
              _buildFeaturePanel(
                title: 'Dismissible Canvas Layout',
                description: 'Remove finished items with quick horizontal swipe gestures or simple clicks. Keeps your dashboard clean and rewarding to interact with.',
                icon: Icons.cleaning_services_outlined,
                accentColor: const Color(0xFF10B981),
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFeaturePanel(
                      title: 'Smart Priority Engine',
                      description: 'Flag tasks as High, Medium, or Low. Color-coded signals enable rapid scan times so you always know what deserves immediate action next.',
                      icon: Icons.label_important_outline,
                      accentColor: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildFeaturePanel(
                      title: 'Visual Analytics Ring',
                      description: 'A custom vector-drawn progress indicator computes your completion percentage. Keep track of achievements dynamically as you toggle tasks.',
                      icon: Icons.track_changes,
                      accentColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFeaturePanel(
                      title: 'Realtime Search & Filtering',
                      description: 'Locate tasks quickly with instantaneous query matching. Filter list views dynamically between all, active, and completed statuses.',
                      icon: Icons.search,
                      accentColor: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildFeaturePanel(
                      title: 'Dismissible Canvas Layout',
                      description: 'Remove finished items with quick horizontal swipe gestures or simple clicks. Keeps your dashboard clean and rewarding to interact with.',
                      icon: Icons.cleaning_services_outlined,
                      accentColor: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFeaturePanel({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // 3. PRICING TAB
  // ==========================================
  Widget _buildPricingTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Simple, Transparent Pricing',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'No credit card required. Upgrade or downgrade anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5)),
        ),
        const SizedBox(height: 48),

        // Pricing Cards
        Center(
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildPricingCard(
                tier: 'BASIC',
                price: '\$0',
                period: 'forever',
                description: 'Ideal for individuals starting out with lightweight planning.',
                features: ['Up to 10 active tasks', 'Color-coded priorities', 'Instant Search & filters', 'Local browser caching'],
                buttonText: 'Get Started',
                isHighlighted: false,
                onPressed: () => setState(() => _currentTab = ActiveTab.workspace),
              ),
              _buildPricingCard(
                tier: 'PRO',
                price: '\$5',
                period: 'per month',
                description: 'Perfect for creators demanding unlimited workspace analytics.',
                features: ['Unlimited active tasks', 'Progress analysis graphs', 'Cross-device cloud sync', 'Custom gradient themes', 'Priority email support'],
                buttonText: 'Upgrade to Pro',
                isHighlighted: true,
                onPressed: () => _showUpgradeModal('Pro'),
              ),
              _buildPricingCard(
                tier: 'ENTERPRISE',
                price: '\$19',
                period: 'per month',
                description: 'Tailored for teams requiring central productivity tools.',
                features: ['Shared group workspaces', 'Team analytics dashboards', 'Role permission management', 'Dedicated account manager', '24/7 Priority SLA support'],
                buttonText: 'Contact Sales',
                isHighlighted: false,
                onPressed: () => _showUpgradeModal('Enterprise'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String tier,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required String buttonText,
    required bool isHighlighted,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF151D30) : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.06),
          width: isHighlighted ? 2.0 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isHighlighted)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          Text(
            tier,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isHighlighted ? const Color(0xFF6366F1) : Colors.white54,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Text(
                '/$period',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), height: 1.4),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),
          // Features List
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isHighlighted ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.08),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeModal(String tierName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151D30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 12),
            Text('Upgrade to $tierName', style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'This is a visual demonstration. Under a production release, clicking this launches the secure checkout workflow for the $tierName license tier.',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white30)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentTab = ActiveTab.workspace);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF6366F1),
                  content: Text('Subscribed to $tierName tier preview! Enjoy the application.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: const Text('Demo Checkout'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. WORKSPACE TAB (INTERACTIVE TODO APP)
  // ==========================================
  Widget _buildWorkspaceTab() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWorkspaceHeader(),
            const SizedBox(height: 32),
            _buildAddTodoSection(),
            const SizedBox(height: 24),
            _buildFilterSection(),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: const Color(0xFF151D30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _filteredTodos.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredTodos.length,
                        separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.04), height: 1),
                        itemBuilder: (context, index) => _buildTodoItem(_filteredTodos[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aura Todo',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Focus on what matters.',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
        SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: CircularProgressPainter(progress: _completionRate),
            child: Center(
              child: Text(
                '${(_completionRate * 100).toInt()}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddTodoSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addController,
              focusNode: _addFocusNode,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _addTodo(),
            ),
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _newTodoPriority,
                dropdownColor: const Color(0xFF151D30),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                items: ['High', 'Medium', 'Low'].map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: _getPriorityColor(p), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(p),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _newTodoPriority = v);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _addTodo,
            icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1), size: 28),
            splashRadius: 24,
          )
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      children: [
        ...['All', 'Active', 'Completed'].map((f) {
          final isSelected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _filter = f),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1).withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1).withOpacity(0.5) : Colors.transparent,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        const Spacer(),
        SizedBox(
          width: 200,
          height: 36,
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3), size: 18),
              filled: true,
              fillColor: const Color(0xFF151D30),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
            ),
          ),
        ),
        if (_todos.any((t) => t.isCompleted)) ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: _clearCompleted,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEC4899),
            ),
            child: const Text('Clear done'),
          ),
        ]
      ],
    );
  }

  Widget _buildTodoItem(TodoItem todo) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteTodo(todo.id),
      background: Container(
        color: const Color(0xFFEF4444).withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: InkWell(
          onTap: () => _toggleTodo(todo.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: todo.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: todo.isCompleted ? const Color(0xFF10B981) : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: todo.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            color: todo.isCompleted ? Colors.white.withOpacity(0.3) : Colors.white,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(todo.priority).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                todo.priority,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(todo.priority),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white.withOpacity(0.3), size: 20),
              onPressed: () => _deleteTodo(todo.id),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your day.',
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  // --- FOOTER SECTION ---
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Center(
        child: Text(
          '© 2026 AURA Workspace Inc. All rights reserved.',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final Paint foregroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
