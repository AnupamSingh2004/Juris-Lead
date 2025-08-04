import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _currentPlan = 'free';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPlan = prefs.getString('subscription_type') ?? 'free';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription & Billing'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan
            _buildCurrentPlanCard(colorScheme),
            const SizedBox(height: 24),
            
            // Available Plans
            Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Plans
            _buildPlanCard(
              'Free',
              '₹0',
              '/month',
              [
                '5 case analyses per month',
                'Basic legal document templates',
                'Community support',
                'Standard response time',
              ],
              'free',
              colorScheme,
            ),
            const SizedBox(height: 16),
            
            _buildPlanCard(
              'Basic',
              '₹499',
              '/month',
              [
                '50 case analyses per month',
                'All legal document templates',
                'Email support',
                'Priority response time',
                'AI legal assistant access',
              ],
              'basic',
              colorScheme,
            ),
            const SizedBox(height: 16),
            
            _buildPlanCard(
              'Premium',
              '₹999',
              '/month',
              [
                'Unlimited case analyses',
                'Premium templates & forms',
                'Phone & chat support',
                'Instant response time',
                'Advanced AI legal insights',
                'Legal expert consultations',
                'Case tracking & reminders',
              ],
              'premium',
              colorScheme,
              isPopular: true,
            ),
            const SizedBox(height: 16),
            
            _buildPlanCard(
              'Professional',
              '₹1,999',
              '/month',
              [
                'Everything in Premium',
                'White-label solutions',
                'API access',
                'Custom integrations',
                'Dedicated account manager',
                'Priority feature requests',
                'Advanced analytics',
              ],
              'professional',
              colorScheme,
            ),
            
            const SizedBox(height: 24),
            
            // Billing Information
            if (_currentPlan != 'free') ...[
              _buildBillingInfoCard(colorScheme),
              const SizedBox(height: 24),
            ],
            
            // Features Comparison
            _buildFeaturesComparison(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_membership, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Current Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getPlanDisplayName(_currentPlan),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_currentPlan != 'free') ...[
              const SizedBox(height: 8),
              Text(
                'Next billing: ${_getNextBillingDate()}',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    String planName,
    String price,
    String period,
    List<String> features,
    String planId,
    ColorScheme colorScheme, {
    bool isPopular = false,
  }) {
    final isCurrentPlan = _currentPlan == planId;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? Colors.amber : colorScheme.outline.withValues(alpha: 0.3),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        planName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCurrentPlan)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(feature),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isCurrentPlan ? null : () => _selectPlan(planId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentPlan 
                            ? Colors.grey 
                            : (isPopular ? Colors.amber : colorScheme.primary),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isCurrentPlan ? 'Current Plan' : 'Select Plan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillingInfoCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildBillingRow('Payment Method', '**** **** **** 1234'),
            _buildBillingRow('Billing Cycle', 'Monthly'),
            _buildBillingRow('Next Payment', _getNextBillingDate()),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _updatePaymentMethod,
                    child: const Text('Update Payment'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _viewBillingHistory,
                    child: const Text('Billing History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '• Free: Perfect for individuals exploring legal analysis\n'
              '• Basic: Ideal for small law firms and frequent users\n'
              '• Premium: Best for established practices and consultants\n'
              '• Professional: Enterprise-grade solution for large firms',
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanDisplayName(String planId) {
    switch (planId) {
      case 'free':
        return 'Free Plan';
      case 'basic':
        return 'Basic Plan';
      case 'premium':
        return 'Premium Plan';
      case 'professional':
        return 'Professional Plan';
      default:
        return 'Unknown Plan';
    }
  }

  String _getNextBillingDate() {
    final nextMonth = DateTime.now().add(const Duration(days: 30));
    return '${nextMonth.day}/${nextMonth.month}/${nextMonth.year}';
  }

  Future<void> _selectPlan(String planId) async {
    setState(() => _isLoading = true);
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_type', planId);
    await prefs.setBool('is_premium', planId != 'free');
    
    setState(() {
      _currentPlan = planId;
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully upgraded to ${_getPlanDisplayName(planId)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updatePaymentMethod() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Method'),
        content: const Text('Payment method update feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewBillingHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Billing History'),
        content: const Text('Billing history feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
