import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/analysis_models.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<HistoryEntry> _historyEntries = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filterTypes = ['All', 'analysis', 'summary', 'case_builder'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    _fadeController.forward();
    _loadHistory();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final history = await ApiService.getHistory();
      
      if (mounted) {
        setState(() {
          _historyEntries = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, show sample data
      if (mounted) {
        setState(() {
          _historyEntries = _getSampleHistory();
          _isLoading = false;
        });
        
        // Show subtle error message
        if (e.toString().contains('Failed to load history')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Using sample data - backend not available'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  List<HistoryEntry> _getSampleHistory() {
    return [
      HistoryEntry(
        id: '1',
        title: 'Contract Dispute Analysis',
        content: 'Analyzed a commercial contract dispute case with focus on breach of terms and remedies.',
        type: 'analysis',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HistoryEntry(
        id: '2',
        title: 'Legal Document Summary',
        content: 'Summarized a 50-page legal agreement into key points and obligations.',
        type: 'summary',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HistoryEntry(
        id: '3',
        title: 'Criminal Case Research',
        content: 'Comprehensive analysis of criminal law precedents for theft case.',
        type: 'analysis',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
      ),
      HistoryEntry(
        id: '4',
        title: 'Property Case Builder',
        content: 'Built comprehensive case file for property dispute with relevant documents.',
        type: 'case_builder',
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<HistoryEntry> get filteredEntries {
    if (_selectedFilter == 'All') {
      return _historyEntries;
    }
    return _historyEntries.where((entry) => entry.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Filter Tabs
            Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterTypes.map((filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getFilterDisplayName(filter)),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.primary,
                    ),
                  )).toList(),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEntries.isEmpty
                      ? _buildEmptyState()
                      : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All' ? 'No history yet' : 'No ${_getFilterDisplayName(_selectedFilter).toLowerCase()} found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your analysis history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = filteredEntries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showHistoryDetail(entry),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getTypeColor(entry.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getTypeIcon(entry.type),
                          color: _getTypeColor(entry.type),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(entry.timestamp),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(
                          _getFilterDisplayName(entry.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTypeColor(entry.type),
                          ),
                        ),
                        backgroundColor: _getTypeColor(entry.type).withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.metadata != null && entry.metadata!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: entry.metadata!.entries.take(3).map((e) => 
                        Chip(
                          label: Text(
                            '${e.key}: ${e.value}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHistoryDetail(HistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(entry.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(entry.type),
                      color: _getTypeColor(entry.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(entry.timestamp),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Content',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                      if (entry.metadata != null && entry.metadata!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.metadata!.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  '${e.key}:',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  e.value.toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'All': return 'All';
      case 'analysis': return 'Analyses';
      case 'summary': return 'Summaries';
      case 'case_builder': return 'Case Builder';
      default: return filter;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'analysis': return Icons.psychology;
      case 'summary': return Icons.summarize;
      case 'case_builder': return Icons.build;
      default: return Icons.description;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'analysis': return Colors.blue;
      case 'summary': return Colors.green;
      case 'case_builder': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
