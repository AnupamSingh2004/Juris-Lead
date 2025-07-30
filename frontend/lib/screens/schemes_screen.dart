import 'package:flutter/material.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Health Schemes',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF64748B)),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 16.0 + MediaQuery.of(context).viewInsets.bottom, // Add keyboard padding
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Government Health Schemes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore available healthcare benefits and financial assistance programs',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Check Eligibility'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            const Text(
              'Browse by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // Category Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0, // Increased height by reducing aspect ratio
              children: [
                _buildCategoryCard(
                  'Central Schemes',
                  Icons.account_balance,
                  const Color(0xFF10B981),
                  'Ayushman Bharat, PMJAY',
                ),
                _buildCategoryCard(
                  'State Schemes',
                  Icons.location_city,
                  const Color(0xFF8B5CF6),
                  'Regional healthcare plans',
                ),
                _buildCategoryCard(
                  'Senior Citizens',
                  Icons.elderly,
                  const Color(0xFFF59E0B),
                  'Special elderly care programs',
                ),
                _buildCategoryCard(
                  'Women & Child',
                  Icons.family_restroom,
                  const Color(0xFFEF4444),
                  'Maternal and child health',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Popular Schemes
            const Text(
              'Popular Schemes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // Scheme Cards
            _buildSchemeCard(
              'Ayushman Bharat - PM-JAY',
              'Free treatment up to ₹5 lakh per family per year',
              'Central Government',
              '₹5,00,000',
              const Color(0xFF10B981),
              Icons.favorite,
              true,
            ),
            const SizedBox(height: 16),
            _buildSchemeCard(
              'Pradhan Mantri Suraksha Bima Yojana',
              'Accident insurance cover for ₹2 lakh',
              'Central Government',
              '₹2,00,000',
              const Color(0xFF2563EB),
              Icons.security,
              false,
            ),
            const SizedBox(height: 16),
            _buildSchemeCard(
              'Aam Aadmi Bima Yojana',
              'Life insurance for rural landless households',
              'Central Government',
              '₹30,000',
              const Color(0xFF8B5CF6),
              Icons.umbrella,
              false,
            ),
            const SizedBox(height: 16),
            _buildSchemeCard(
              'Janani Suraksha Yojana',
              'Cash assistance for institutional delivery',
              'Central Government',
              '₹1,400',
              const Color(0xFFEF4444),
              Icons.child_care,
              true,
            ),
            const SizedBox(height: 124), // Added extra bottom padding for navbar (24 + 100)
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Flexible( // Wrapped icon container in Flexible
            child: Container(
              padding: const EdgeInsets.all(12), // Reduced padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28), // Reduced icon size
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing
          Flexible( // Wrapped text in Flexible
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13, // Reduced font size
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Added max lines
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2), // Reduced spacing
          Flexible( // Wrapped subtitle in Flexible
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11, // Reduced font size
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(
    String title,
    String description,
    String provider,
    String coverage,
    Color color,
    IconData icon,
    bool isPopular,
  ) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular ? Border.all(color: color.withOpacity(0.3), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Changed alignment
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20), // Reduced icon size
              ),
              const SizedBox(width: 12), // Reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15, // Reduced font size
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2, // Added max lines
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Popular',
                              style: TextStyle(
                                fontSize: 9, // Reduced font size
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      provider,
                      style: const TextStyle(
                        fontSize: 11, // Reduced font size
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced spacing
          Text(
            description,
            style: const TextStyle(
              fontSize: 13, // Reduced font size
              color: Color(0xFF64748B),
              height: 1.3, // Reduced line height
            ),
            maxLines: 3, // Added max lines
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12), // Reduced spacing
          Row(
            children: [
              Flexible( // Changed from Container to Flexible
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Reduced padding
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Coverage: $coverage',
                    style: TextStyle(
                      fontSize: 11, // Reduced font size
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8), // Added some spacing
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                  minimumSize: Size.zero, // Remove minimum size constraints
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
                ),
                child: Text(
                  'Learn More',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12, // Reduced font size
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
