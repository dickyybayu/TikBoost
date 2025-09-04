import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/subscription_service.dart';
import '../widgets/tikboost_logo.dart';
import 'premium_upgrade_screen.dart';

class LiveAnalysisScreen extends StatefulWidget {
  const LiveAnalysisScreen({super.key});

  @override
  State<LiveAnalysisScreen> createState() => _LiveAnalysisScreenState();
}

class _LiveAnalysisScreenState extends State<LiveAnalysisScreen> {
  bool _isAnalyzing = false;
  LiveAnalysisResult? _analysisResult;
  final TextEditingController _tiktokUrlController = TextEditingController();

  @override
  void dispose() {
    _tiktokUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = SubscriptionService.isPremium;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TikBoostLogoIcon(size: 24),
            SizedBox(width: 8),
            Text(
              'Live Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PremiumUpgradeScreen(
                    featureName: 'Live Analysis Premium Features',
                    onUpgradeSuccess: () => setState(() {}),
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: !isPremium 
        ? _buildPremiumRequired()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildAnalysisInput(),
                const SizedBox(height: 24),
                if (_analysisResult != null) ...[
                  _buildAnalysisResult(),
                  const SizedBox(height: 24),
                ],
                _buildFeaturesList(),
              ],
            ),
          ),
    );
  }

  Widget _buildPremiumRequired() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.orange[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.analytics,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '🔒 Premium Feature',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Live Analysis dengan AI adalah fitur premium yang memberikan insights mendalam tentang performa live streaming Anda, termasuk rekomendasi HOST yang optimal.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.orange[400]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumUpgradeScreen(
                        featureName: 'Live Analysis',
                        onUpgradeSuccess: () => setState(() {}),
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
                icon: const Icon(Icons.upgrade),
                label: const Text('Upgrade to Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.teal[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Premium Live Analysis Active',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Live Stream Analysis',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Analisis mendalam performa live streaming Anda dengan AI, termasuk rekomendasi HOST yang optimal untuk meningkatkan engagement.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[400]!, Colors.pink[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.live_tv,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyze Live Stream',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Masukkan URL TikTok live atau profil untuk analisis',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _tiktokUrlController,
            decoration: InputDecoration(
              labelText: 'TikTok URL atau Username',
              hintText: 'https://tiktok.com/@username atau @username',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Analyze with AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analysis Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Host Recommendation (Premium Only)
        _buildResultCard(
          title: 'HOST RECOMMENDATION',
          icon: Icons.person,
          color: Colors.orange[600]!,
          content: _analysisResult!.hostRecommendation,
          isPremiumFeature: true,
        ),
        
        const SizedBox(height: 16),
        
        // Performance Metrics
        _buildResultCard(
          title: 'PERFORMANCE METRICS',
          icon: Icons.analytics,
          color: Colors.blue[600]!,
          content: _analysisResult!.performanceMetrics,
        ),
        
        const SizedBox(height: 16),
        
        // Audience Insights
        _buildResultCard(
          title: 'AUDIENCE INSIGHTS',
          icon: Icons.people,
          color: Colors.green[600]!,
          content: _analysisResult!.audienceInsights,
        ),
        
        const SizedBox(height: 16),
        
        // AI Recommendations
        _buildResultCard(
          title: 'AI RECOMMENDATIONS',
          icon: Icons.lightbulb,
          color: Colors.purple[600]!,
          content: _analysisResult!.aiRecommendations,
        ),
        
        const SizedBox(height: 24),
        
        // Copy All Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _copyAllAnalysis(),
            icon: const Icon(Icons.copy),
            label: const Text('Copy Full Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    bool isPremiumFeature = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremiumFeature ? Colors.amber.withOpacity(0.3) : color.withOpacity(0.2)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPremiumFeature 
                    ? Colors.amber.withOpacity(0.1)
                    : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon, 
                  color: isPremiumFeature ? Colors.amber[700] : color, 
                  size: 20
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPremiumFeature ? Colors.amber[700] : color,
                ),
              ),
              if (isPremiumFeature) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: () => _copyText(content),
                icon: Icon(Icons.copy, size: 20, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPremiumFeature 
                ? Colors.amber[50]
                : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Premium Live Analysis Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFeatureItem(
            '👥 HOST Recommendations',
            'AI akan menganalisis gaya host terbaik berdasarkan audience engagement',
            Colors.orange[600]!,
          ),
          _buildFeatureItem(
            '📊 Real-time Metrics',
            'Monitor viewers, engagement rate, dan conversion secara real-time',
            Colors.blue[600]!,
          ),
          _buildFeatureItem(
            '🎯 Audience Behavior',
            'Insights mendalam tentang perilaku dan preferensi audience',
            Colors.green[600]!,
          ),
          _buildFeatureItem(
            '💡 AI Suggestions',
            'Rekomendasi strategis untuk meningkatkan performa live stream',
            Colors.purple[600]!,
          ),
          _buildFeatureItem(
            '📈 Competitive Analysis',
            'Bandingkan performa dengan kompetitor di niche yang sama',
            Colors.red[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeStream() async {
    if (_tiktokUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a TikTok URL or username'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisResult = LiveAnalysisResult(
          hostRecommendation: _generateHostRecommendation(),
          performanceMetrics: _generatePerformanceMetrics(),
          audienceInsights: _generateAudienceInsights(),
          aiRecommendations: _generateAiRecommendations(),
        );
      });
    }
  }

  String _generateHostRecommendation() {
    return """🎤 OPTIMAL HOST PROFILE:

👩 HOST: Dewi (Female, 25-30 tahun)
🎭 PERSONALITY: Friendly, energetic, approachable
🗣️ COMMUNICATION STYLE: Casual Indonesian dengan touch English
📱 ENGAGEMENT TECHNIQUE: Interactive Q&A setiap 3-5 menit

🔥 STRENGTHS TO LEVERAGE:
• Natural charisma dan authentic personality  
• Strong product knowledge dan storytelling
• Excellent timing untuk jokes dan engagement
• Responsive terhadap audience comments

💡 IMPROVEMENT AREAS:
• Pacing - sedikit lebih lambat saat explain produk
• Eye contact - lebih sering lihat ke kamera
• Product demo - lebih hands-on demonstration

🎯 RECOMMENDED SCRIPT STYLE:
"Halo beautiful people! Aku Dewi dan hari ini kita ada produk yang bener-bener game changer..."

SUCCESS RATE PREDICTION: 87% audience retention dengan host profile ini.""";
  }

  String _generatePerformanceMetrics() {
    return """📊 CURRENT LIVE METRICS:

👥 AUDIENCE DATA:
• Peak Viewers: 2,847 (8.2% above average)
• Average Watch Time: 12m 34s (+15% from last week)
• Engagement Rate: 23.5% (Industry avg: 18%)
• Comment Rate: 4.2 comments/minute

💰 CONVERSION METRICS:
• Conversion Rate: 9.8% (Excellent!)
• Add to Cart Rate: 24.7%  
• Click-through Rate: 31.2%
• Average Order Value: Rp 287,500

📈 PERFORMANCE TRENDS:
• Viewer growth: +45% week-over-week
• Sales increase: +38% from previous live
• New followers: +156 during this session
• Repeat customers: 34% of total buyers

⏰ OPTIMAL MOMENTS:
• Highest engagement: Minutes 15-25
• Peak sales: Minutes 30-45  
• Best Q&A timing: Minutes 10-15""";
  }

  String _generateAudienceInsights() {
    return """👥 AUDIENCE BEHAVIOR ANALYSIS:

🎯 DEMOGRAPHICS:
• Age: 68% (25-34), 22% (35-44), 10% (18-24)
• Gender: 73% Female, 27% Male
• Location: 45% Jakarta, 18% Surabaya, 12% Bandung
• Income: 58% Middle class, 32% Upper middle

⭐ ENGAGEMENT PATTERNS:
• Most active: First 20 minutes & last 15 minutes
• Question frequency: Higher during product demos
• Purchase decisions: 67% made within first 30 minutes
• Price sensitivity: Moderate (responds well to bundles)

💬 CHAT ANALYSIS:
• Top keywords: "berapa harga", "ada diskon", "gimana cara order"
• Emotional tone: 78% positive, 18% neutral, 4% concerned
• Most asked: Product authenticity & delivery time
• Conversion triggers: Social proof & limited time offers

🛒 BUYING BEHAVIOR:
• Impulse buyers: 43% of total sales
• Research-oriented: 31% ask multiple questions first
• Bundle preference: 26% choose package deals
• Return rate: 3.2% (Very low!)""";
  }

  String _generateAiRecommendations() {
    return """🤖 AI STRATEGIC RECOMMENDATIONS:

🚀 IMMEDIATE ACTIONS (Next 15 minutes):
• Highlight customer testimonials dari chat
• Demo produk #1 dengan more hands-on approach  
• Announce "15 menit terakhir untuk discount"
• Engage dengan viewers yang belum comment

📈 CONTENT OPTIMIZATION:
• Focus 70% waktu pada top-selling product
• Integrate customer stories setiap 10 menit
• Use countdown timers untuk urgency
• Show product comparison dengan kompetitor

🎯 AUDIENCE ENGAGEMENT:
• Ask specific questions: "Siapa yang udah pernah coba produk serupa?"
• Create mini-contests dengan small giveaways
• Respond to viewer names langsung dari chat
• Share personal experience dengan produk

💰 SALES ACCELERATION:
• Bundle strategy: Push 3-product package
• Price anchoring: Show original vs discounted price
• Scarcity tactics: "Only 50 units left for today"
• Social proof: "Sarah dari Jakarta just ordered 2 units"

📅 FUTURE SESSIONS:
• Optimal timing: Kamis 19:00-20:30 WIB
• Content themes: Behind-the-scenes, customer stories
• Collaboration opportunities: Micro-influencer partnerships
• Product lineup: Lead dengan bestseller, close dengan bundle""";
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyAllAnalysis() {
    if (_analysisResult == null) return;
    
    final allText = """${_analysisResult!.hostRecommendation}

---

${_analysisResult!.performanceMetrics}

---

${_analysisResult!.audienceInsights}

---

${_analysisResult!.aiRecommendations}""";
    
    Clipboard.setData(ClipboardData(text: allText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full analysis copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class LiveAnalysisResult {
  final String hostRecommendation;
  final String performanceMetrics;
  final String audienceInsights;
  final String aiRecommendations;

  LiveAnalysisResult({
    required this.hostRecommendation,
    required this.performanceMetrics,
    required this.audienceInsights,
    required this.aiRecommendations,
  });
}
