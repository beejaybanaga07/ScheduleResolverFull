import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart';

const _pink      = Color(0xFFFF2D78);
const _pinkLight = Color(0xFFFF6FA3);
const _darkBg    = Color(0xFF0D0D0D);
const _cardBg    = Color(0xFF1A1A1A);
const _textPri   = Colors.white;
const _textSec   = Color(0xFFAAAAAA);
const _divider   = Color(0xFF2A2A2A);

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);
    final analysis  = aiService.currentAnalysis;

    if (analysis == null) {
      return const Scaffold(
        backgroundColor: _darkBg,
        body: Center(child: Text('No Data', style: TextStyle(color: _textSec))),
      );
    }

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pink),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              const LinearGradient(colors: [_pink, _pinkLight]).createShader(bounds),
          child: const Text(
            'AI Recommendation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, _pink, Colors.transparent]),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              'Detected Conflicts',
              analysis.conflicts.isEmpty ? 'No conflicts detected.' : analysis.conflicts,
              Icons.warning_amber_rounded,
              const Color(0xFFFF6B6B),
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Ranked Tasks',
              analysis.rankedTasks.isEmpty ? 'No data.' : analysis.rankedTasks,
              Icons.format_list_numbered_rounded,
              _pinkLight,
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Recommended Schedule',
              analysis.recommendedSchedule.isEmpty ? 'No data.' : analysis.recommendedSchedule,
              Icons.calendar_today_rounded,
              Colors.greenAccent,
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Explanation',
              analysis.explanation.isEmpty ? 'No data.' : analysis.explanation,
              Icons.lightbulb_outline_rounded,
              const Color(0xFFFFB347),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData iconData, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
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
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Icon(iconData, size: 20, color: accentColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPri),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: accentColor.withOpacity(0.2), height: 1),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.65, color: _textSec),
            ),
          ],
        ),
      ),
    );
  }
}