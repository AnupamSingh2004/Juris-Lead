import 'package:flutter/material.dart';

class ToolDetailScreen extends StatelessWidget {
  final String toolName;

  const ToolDetailScreen({super.key, required this.toolName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(toolName),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tool Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getToolIcon(toolName),
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    toolName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getToolDescription(toolName),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Tool Content
            _buildToolContent(context, toolName),
            
            const SizedBox(height: 32),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _handleToolAction(context, toolName),
                icon: const Icon(Icons.play_arrow),
                label: Text('Launch $toolName'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case 'Document Summarizer':
        return Icons.summarize_outlined;
      case 'Legal Topics Explorer':
        return Icons.explore_outlined;
      case 'Case Precedent Finder':
        return Icons.search_outlined;
      case 'Contract Generator':
        return Icons.description_outlined;
      case 'Legal Library':
        return Icons.library_books_outlined;
      case 'Legal Calculator':
        return Icons.calculate_outlined;
      case 'Community Forum':
        return Icons.forum_outlined;
      default:
        return Icons.build_outlined;
    }
  }

  String _getToolDescription(String toolName) {
    switch (toolName) {
      case 'Document Summarizer':
        return 'Upload legal documents and get AI-powered summaries highlighting key points, obligations, and risks.';
      case 'Legal Topics Explorer':
        return 'Browse comprehensive guides on various legal topics including criminal law, civil rights, and more.';
      case 'Case Precedent Finder':
        return 'Search through thousands of legal precedents to find cases similar to yours.';
      case 'Contract Generator':
        return 'Generate legal contracts and agreements using AI-powered templates.';
      case 'Legal Library':
        return 'Access to comprehensive legal documents, acts, and legal precedents.';
      case 'Legal Calculator':
        return 'Calculate legal fees, penalties, compensation amounts, and other legal metrics.';
      case 'Community Forum':
        return 'Connect with legal experts and community members to discuss legal matters.';
      default:
        return 'Professional legal tool to assist with your legal research and documentation needs.';
    }
  }

  Widget _buildToolContent(BuildContext context, String toolName) {
    final theme = Theme.of(context);
    
    switch (toolName) {
      case 'Document Summarizer':
        return _buildDocumentSummarizerContent(theme);
      case 'Legal Topics Explorer':
        return _buildTopicsExplorerContent(theme);
      case 'Case Precedent Finder':
        return _buildPrecedentFinderContent(theme);
      case 'Contract Generator':
        return _buildContractGeneratorContent(theme);
      default:
        return _buildGenericToolContent(theme, toolName);
    }
  }

  Widget _buildDocumentSummarizerContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _FeatureItem(
          icon: Icons.upload_file,
          title: 'Document Upload',
          description: 'Support for PDF, DOC, and text files',
        ),
        _FeatureItem(
          icon: Icons.psychology,
          title: 'AI Analysis',
          description: 'Advanced natural language processing',
        ),
        _FeatureItem(
          icon: Icons.highlight,
          title: 'Key Points Extraction',
          description: 'Automatic identification of important clauses',
        ),
      ],
    );
  }

  Widget _buildTopicsExplorerContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Topics',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Criminal Law',
            'Civil Rights',
            'Property Law',
            'Family Law',
            'Corporate Law',
            'Constitutional Law',
          ].map((topic) => Chip(label: Text(topic))).toList(),
        ),
      ],
    );
  }

  Widget _buildPrecedentFinderContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Capabilities',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _FeatureItem(
          icon: Icons.gavel,
          title: 'Supreme Court Cases',
          description: 'Access to Supreme Court judgments',
        ),
        _FeatureItem(
          icon: Icons.location_city,
          title: 'High Court Cases',
          description: 'State High Court precedents',
        ),
        _FeatureItem(
          icon: Icons.search,
          title: 'Smart Search',
          description: 'AI-powered case similarity matching',
        ),
      ],
    );
  }

  Widget _buildContractGeneratorContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contract Types',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Employment Contract',
            'Rental Agreement',
            'Service Agreement',
            'Non-Disclosure Agreement',
            'Partnership Agreement',
            'Sales Contract',
          ].map((type) => Chip(label: Text(type))).toList(),
        ),
      ],
    );
  }

  Widget _buildGenericToolContent(ThemeData theme, String toolName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This tool is currently under development and will be available soon.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _handleToolAction(BuildContext context, String toolName) {
    if (toolName == 'Document Summarizer' || 
        toolName == 'Legal Topics Explorer' || 
        toolName == 'Case Precedent Finder' || 
        toolName == 'Contract Generator') {
      // These tools are ready
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Launching $toolName...'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Other tools are coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$toolName is coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
