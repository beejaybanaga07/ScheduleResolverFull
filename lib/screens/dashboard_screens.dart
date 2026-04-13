import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_revolver/screens/task_input_screens.dart';
import '../providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'recommendation_screen.dart';

// ── Theme constants ────────────────────────────────────────────────────────────
const _pink       = Color(0xFFFF2D78);
const _pinkLight  = Color(0xFFFF6FA3);
const _darkBg     = Color(0xFF0D0D0D);
const _cardBg     = Color(0xFF1A1A1A);
const _cardBg2    = Color(0xFF222222);
const _textPri    = Colors.white;
const _textSec    = Color(0xFFAAAAAA);
const _divider    = Color(0xFF2A2A2A);

class DashboardScreens extends StatelessWidget {
  const DashboardScreens({super.key});

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Class':    return Icons.school_rounded;
      case 'Org Work': return Icons.group_rounded;
      case 'Study':    return Icons.menu_book_rounded;
      case 'Rest':     return Icons.self_improvement_rounded;
      default:         return Icons.task_alt_rounded;
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Class':    return const Color(0xFFFF2D78);
      case 'Org Work': return const Color(0xFFFF6FA3);
      case 'Study':    return const Color(0xFFFF9EC4);
      case 'Rest':     return const Color(0xFFFFB6C8);
      default:         return const Color(0xFFFFCCDA);
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour   = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min    = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService        = Provider.of<AiScheduleService>(context);

    final sortedTask = List<TaskModel>.from(scheduleProvider.task);
    sortedTask.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_pink, _pinkLight],
          ).createShader(bounds),
          child: const Text(
            'Schedule Resolver',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── AI Recommendation Banner ───────────────────────────────────
            if (aiService.currentAnalysis != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A0015), Color(0xFF1A000D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _pink.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(color: _pink.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_pink, _pinkLight]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Recommendation Ready!',
                              style: TextStyle(color: _textPri, fontWeight: FontWeight.w700, fontSize: 14)),
                          Text('Tap to view your optimized schedule',
                              style: TextStyle(color: _textSec, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RecommendationScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('View', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Error Banner ───────────────────────────────────────────────
            if (aiService.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A0A0A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade900),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(aiService.errorMessage!,
                          style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Task Count Header ──────────────────────────────────────────
            if (sortedTask.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${sortedTask.length} Task${sortedTask.length > 1 ? 's' : ''} Today',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textSec),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _pink.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _pink.withOpacity(0.3)),
                      ),
                      child: const Text('Sorted by time',
                          style: TextStyle(fontSize: 11, color: _pinkLight, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

            // ── Task List ─────────────────────────────────────────────────
            Expanded(
              child: sortedTask.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [_pink.withOpacity(0.15), Colors.transparent],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event_note_rounded, size: 52, color: _pink),
                    ),
                    const SizedBox(height: 16),
                    const Text('No tasks added yet!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textSec)),
                    const SizedBox(height: 6),
                    const Text('Tap + to add your first task',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  ],
                ),
              )
                  : ListView.separated(
                itemCount: sortedTask.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task     = sortedTask[index];
                  final catColor = _categoryColor(task.category);
                  return Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _divider),
                      boxShadow: [
                        BoxShadow(
                          color: _pink.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [catColor.withOpacity(0.25), catColor.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: catColor.withOpacity(0.4)),
                        ),
                        child: Icon(_categoryIcon(task.category), color: catColor, size: 22),
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15, color: _textPri),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: catColor.withOpacity(0.3)),
                              ),
                              child: Text(task.category,
                                  style: TextStyle(
                                      fontSize: 10, color: catColor, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time_rounded, size: 12, color: _textSec),
                            const SizedBox(width: 3),
                            Text(
                              '${_formatTime(task.startTime)} – ${_formatTime(task.endTime)}',
                              style: const TextStyle(fontSize: 12, color: _textSec),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.urgency >= 4
                                  ? _pink.withOpacity(0.2)
                                  : task.urgency >= 3
                                  ? const Color(0xFFFF9800).withOpacity(0.15)
                                  : Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: task.urgency >= 4
                                    ? _pink.withOpacity(0.5)
                                    : task.urgency >= 3
                                    ? const Color(0xFFFF9800).withOpacity(0.4)
                                    : Colors.green.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              'U${task.urgency}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: task.urgency >= 4
                                    ? _pinkLight
                                    : task.urgency >= 3
                                    ? const Color(0xFFFFB347)
                                    : Colors.greenAccent,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Color(0xFF666666), size: 20),
                            onPressed: () => scheduleProvider.removeTask(task.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Analyze Button ─────────────────────────────────────────────
            if (sortedTask.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: aiService.isLoading
                      ? null
                      : const LinearGradient(colors: [_pink, _pinkLight]),
                  color: aiService.isLoading ? _cardBg2 : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: aiService.isLoading
                      ? []
                      : [BoxShadow(color: _pink.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton(
                  onPressed: aiService.isLoading
                      ? null
                      : () => aiService.analyzeSchedule(scheduleProvider.task),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: aiService.isLoading
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _pink),
                      ),
                      SizedBox(width: 10),
                      Text('Analyzing...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textSec)),
                    ],
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Resolve Conflicts with AI',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_pink, _pinkLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: _pink.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const TaskInputScreen())),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}