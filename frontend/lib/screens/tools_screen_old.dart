import 'package:flutter/material.dart';
import 'tool_detail_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for cards
    _cardAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          0.8 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      ));
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.build_rounded,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI-Powered Legal Tools',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comprehensive suite of tools to assist with your legal research and document analysis',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main Tools Grid
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    FadeTransition(
                      opacity: _cardAnimations[0],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_cardAnimations[0]),
                        child: _ToolCard(
                          icon: Icons.summarize_outlined,
                          title: 'Document Summarizer',
                          description: 'AI-powered document analysis and summarization',
                          color: Colors.blue,
                          onTap: () => _navigateToTool('Document Summarizer'),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _cardAnimations[1],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_cardAnimations[1]),
                        child: _ToolCard(
                          icon: Icons.explore_outlined,
                          title: 'Legal Topics Explorer',
                          description: 'Browse and learn about various legal topics',
                          color: Colors.green,
                          onTap: () => _navigateToTool('Legal Topics Explorer'),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _cardAnimations[2],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_cardAnimations[2]),
                        child: _ToolCard(
                          icon: Icons.gavel_outlined,
                          title: 'IPC Analyzer',
                          description: 'Analyze cases against Indian Penal Code sections',
                          color: Colors.orange,
                          onTap: () => _navigateToTool('IPC Analyzer'),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _cardAnimations[3],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_cardAnimations[3]),
                        child: _ToolCard(
                          icon: Icons.chat_outlined,
                          title: 'Legal Chatbot',
                          description: 'Get instant answers to legal questions',
                          color: Colors.purple,
                          onTap: () => _navigateToTool('Legal Chatbot'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Additional Tools Section
            Text(
              'Additional Resources',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _ResourceCard(
              icon: Icons.library_books_outlined,
              title: 'Legal Library',
              description: 'Access to legal documents, acts, and precedents',
              onTap: () => _navigateToTool('Legal Library'),
            ),
            const SizedBox(height: 12),
            _ResourceCard(
              icon: Icons.calculate_outlined,
              title: 'Legal Calculator',
              description: 'Calculate legal fees, penalties, and compensation',
              onTap: () => _navigateToTool('Legal Calculator'),
            ),
            const SizedBox(height: 12),
            _ResourceCard(
              icon: Icons.forum_outlined,
              title: 'Community Forum',
              description: 'Discuss legal matters with experts and peers',
              onTap: () => _navigateToTool('Community Forum'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTool(String toolName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToolDetailScreen(toolName: toolName),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Explore',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Tool Detail Screen
class ToolDetailScreen extends StatelessWidget {
  final String toolName;

  const ToolDetailScreen({super.key, required this.toolName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toolName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '$toolName Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This tool is under development',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
