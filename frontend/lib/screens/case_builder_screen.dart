import 'package:flutter/material.dart';

class CaseBuilderScreen extends StatefulWidget {
  const CaseBuilderScreen({super.key});

  @override
  State<CaseBuilderScreen> createState() => _CaseBuilderScreenState();
}

class _CaseBuilderScreenState extends State<CaseBuilderScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<CaseEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    
    // Add sample events
    _addSampleEvents();
  }

  void _addSampleEvents() {
    _events.addAll([
      CaseEvent(
        id: '1',
        title: 'Initial Incident',
        description: 'The incident that started the case',
        date: DateTime.now().subtract(const Duration(days: 30)),
        type: EventType.incident,
      ),
      CaseEvent(
        id: '2',
        title: 'Police Complaint Filed',
        description: 'Filed complaint at local police station',
        date: DateTime.now().subtract(const Duration(days: 28)),
        type: EventType.document,
      ),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddEventBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEventBottomSheet(
        onEventAdded: (event) {
          setState(() {
            _events.add(event);
            _events.sort((a, b) => a.date.compareTo(b.date));
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.timeline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Case Timeline',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Build a comprehensive timeline of your case',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Organize events chronologically to build a strong case foundation',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Timeline Content
          Expanded(
            child: _events.isEmpty
                ? _EmptyTimeline()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return _TimelineEventCard(
                        event: _events[index],
                        isFirst: index == 0,
                        isLast: index == _events.length - 1,
                        onEdit: () => _editEvent(_events[index]),
                        onDelete: () => _deleteEvent(_events[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventBottomSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Event'),
      ),
    );
  }

  void _editEvent(CaseEvent event) {
    // Implementation for editing event
  }

  void _deleteEvent(CaseEvent event) {
    setState(() {
      _events.remove(event);
    });
  }
}

class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timeline_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Building Your Case',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add incidents, documents, and important dates to create a comprehensive timeline',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _EmptyStateAction(
                  icon: Icons.event_outlined,
                  label: 'Add Incident',
                  color: Colors.red,
                ),
                _EmptyStateAction(
                  icon: Icons.description_outlined,
                  label: 'Add Document',
                  color: Colors.blue,
                ),
                _EmptyStateAction(
                  icon: Icons.date_range_outlined,
                  label: 'Add Date',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _EmptyStateAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final CaseEvent event;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimelineEventCard({
    required this.event,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getEventColor(event.type),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.background,
                      width: 3,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Event Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getEventIcon(event.type),
                        size: 20,
                        color: _getEventColor(event.type),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outlined, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.incident:
        return Colors.red;
      case EventType.document:
        return Colors.blue;
      case EventType.meeting:
        return Colors.green;
      case EventType.deadline:
        return Colors.orange;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.incident:
        return Icons.warning_outlined;
      case EventType.document:
        return Icons.description_outlined;
      case EventType.meeting:
        return Icons.people_outlined;
      case EventType.deadline:
        return Icons.schedule_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddEventBottomSheet extends StatefulWidget {
  final Function(CaseEvent) onEventAdded;

  const _AddEventBottomSheet({required this.onEventAdded});

  @override
  State<_AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<_AddEventBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  EventType _selectedType = EventType.incident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Add New Event',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                hintText: 'Enter event title',
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter event description',
              ),
            ),
            const SizedBox(height: 16),
            
            // Event Type Selection
            Text(
              'Event Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: EventType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  selected: isSelected,
                  label: Text(_getTypeLabel(type)),
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addEvent,
                child: const Text('Add Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(EventType type) {
    switch (type) {
      case EventType.incident:
        return 'Incident';
      case EventType.document:
        return 'Document';
      case EventType.meeting:
        return 'Meeting';
      case EventType.deadline:
        return 'Deadline';
    }
  }

  void _addEvent() {
    if (_titleController.text.trim().isEmpty) return;

    final event = CaseEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      type: _selectedType,
    );

    widget.onEventAdded(event);
    Navigator.pop(context);
  }
}

// Data Models
class CaseEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;

  CaseEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });
}

enum EventType {
  incident,
  document,
  meeting,
  deadline,
}
