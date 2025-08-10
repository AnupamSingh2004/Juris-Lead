import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/analysis_models.dart';
import 'analysis_results_screen.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isAnalyzing = false;
  bool _detailedAnalysis = true;

  final List<String> _categories = [
    'Criminal Law',
    'Civil Law',
    'Corporate Law',
    'Property Law',
    'Family Law',
    'Employment Law',
    'Constitutional Law',
    'Tax Law',
  ];

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
  }

  @override
  void dispose() {
    _textController.dispose();
    _categoryController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAnalysis() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter some text to analyze'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final request = AnalysisRequest(
        description: _textController.text.trim(),
        category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
        detailed: _detailedAnalysis,
      );

      final response = await ApiService.analyzeCase(request);
      
      if (mounted) {
        // Add to history
        final historyEntry = HistoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Case Analysis - ${DateTime.now().toString().split(' ').first}',
          content: _textController.text.trim(),
          type: 'analysis',
          timestamp: DateTime.now(),
          metadata: {
            'category': _categoryController.text,
            'detailed': _detailedAnalysis,
          },
        );
        
        await ApiService.addToHistory(historyEntry);

        // Navigate to results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(
              analysisResponse: response,
              originalText: _textController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _pasteFromClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData('text/plain');
      if (data != null && data.text != null) {
        setState(() {
          _textController.text = data.text!;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to paste from clipboard: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _categoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Case Analyzer'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use'),
                  content: const Text(
                    'Enter a description of your legal situation or case details. '
                    'Our AI will analyze the text and identify applicable IPC sections, '
                    'provide legal recommendations, and suggest next steps.\n\n'
                    'For best results:\n'
                    '• Be detailed and specific\n'
                    '• Include relevant dates and circumstances\n'
                    '• Mention any evidence or witnesses\n'
                    '• Select an appropriate category if known',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gavel,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI-Powered Legal Analysis',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get instant analysis of your legal situation',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Legal Category (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                decoration: InputDecoration(
                  hintText: 'Select category for better analysis',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value ?? '';
                  });
                },
              ),

              const SizedBox(height: 24),

              // Text Input
              Text(
                'Case Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 12,
                      decoration: InputDecoration(
                        hintText: 'Describe your legal situation in detail...\n\n'
                                 'Example: "I was involved in a dispute with my neighbor regarding property boundaries. They built a fence that extends 2 feet into my property despite my objections. I have the property survey documents and witness statements from other neighbors."',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      style: theme.textTheme.bodyLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_textController.text.length} characters',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _pasteFromClipboard,
                                icon: const Icon(Icons.paste, size: 16),
                                label: const Text('Paste'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _clearText,
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text('Clear'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Analysis Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis Options',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Detailed Analysis'),
                        subtitle: const Text('Include defensive strategies and comprehensive recommendations'),
                        value: _detailedAnalysis,
                        onChanged: (value) {
                          setState(() {
                            _detailedAnalysis = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Analyze Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _startAnalysis,
                  icon: _isAnalyzing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(
                    _isAnalyzing ? 'Analyzing...' : 'Analyze Case',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Disclaimer: This AI analysis is for informational purposes only and does not constitute legal advice. Please consult with a qualified lawyer for professional legal guidance.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
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
    );
  }
}
