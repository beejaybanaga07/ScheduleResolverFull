import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

// ── Theme constants ────────────────────────────────────────────────────────────
const _pink      = Color(0xFFFF2D78);
const _pinkLight = Color(0xFFFF6FA3);
const _darkBg    = Color(0xFF0D0D0D);
const _cardBg    = Color(0xFF1A1A1A);
const _cardBg2   = Color(0xFF222222);
const _textPri   = Colors.white;
const _textSec   = Color(0xFFAAAAAA);
const _divider   = Color(0xFF2A2A2A);

class TaskInputScreen extends StatefulWidget {
  const TaskInputScreen({super.key});
  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final _formKey = GlobalKey<FormState>();

  String    _title    = '';
  String    _category = 'Class';
  DateTime  _date     = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime   = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  double _urgency = 3, _importance = 3, _effort = 1.0;
  String _energy = 'Medium';

  final List<String> _cats     = ['Class', 'Org Work', 'Study', 'Rest', 'Other'];
  final List<String> _energies = ['Low', 'Medium', 'High'];

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Class':    return Icons.school_rounded;
      case 'Org Work': return Icons.group_rounded;
      case 'Study':    return Icons.menu_book_rounded;
      case 'Rest':     return Icons.self_improvement_rounded;
      default:         return Icons.task_alt_rounded;
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _pink,
            onPrimary: Colors.white,
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<ScheduleProvider>(context, listen: false).addTask(
        title: _title, category: _category, date: _date,
        startTime: _startTime, endTime: _endTime,
        urgency: _urgency.toInt(), importance: _importance.toInt(),
        estimatedEffortHours: _effort, energyLevel: _energy,
      );
      Navigator.pop(context);
    }
  }

  Color _sliderColor(double val) {
    if (val <= 2) return Colors.greenAccent;
    if (val <= 3) return const Color(0xFFFFB347);
    return _pink;
  }

  String _sliderLabel(double val) {
    if (val <= 2) return 'Low';
    if (val <= 3) return 'Medium';
    return 'High';
  }

  @override
  Widget build(BuildContext context) {
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
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_pink, _pinkLight],
          ).createShader(bounds),
          child: const Text(
            'Add Task',
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Task Title ───────────────────────────────────────────────
              _SectionLabel(label: 'Task Title'),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(color: _textPri),
                decoration: InputDecoration(
                  hintText: 'e.g. Math Lecture, Study Session...',
                  hintStyle: const TextStyle(color: _textSec),
                  prefixIcon: const Icon(Icons.edit_note_rounded, color: _pink),
                  filled: true,
                  fillColor: _cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _pink, width: 2),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),

              const SizedBox(height: 20),

              // ── Category ─────────────────────────────────────────────────
              _SectionLabel(label: 'Category'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _divider),
                ),
                child: DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: _cardBg2,
                  style: const TextStyle(color: _textPri),
                  decoration: InputDecoration(
                    prefixIcon: Icon(_getCategoryIcon(_category), color: _pink),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  items: _cats.map((c) => DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(c), size: 18, color: _pink),
                        const SizedBox(width: 8),
                        Text(c, style: const TextStyle(color: _textPri)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
              ),

              const SizedBox(height: 20),

              // ── Time Picker ───────────────────────────────────────────────
              _SectionLabel(label: 'Time Slot'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: 'Start',
                      time: _startTime.format(context),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: _pink, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeButton(
                      label: 'End',
                      time: _endTime.format(context),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Urgency ───────────────────────────────────────────────────
              _SliderCard(
                label: 'Urgency',
                value: _urgency,
                valueLabel: _sliderLabel(_urgency),
                color: _sliderColor(_urgency),
                onChanged: (val) => setState(() => _urgency = val),
              ),
              const SizedBox(height: 12),

              // ── Importance ────────────────────────────────────────────────
              _SliderCard(
                label: 'Importance',
                value: _importance,
                valueLabel: _sliderLabel(_importance),
                color: _sliderColor(_importance),
                onChanged: (val) => setState(() => _importance = val),
              ),

              const SizedBox(height: 20),

              // ── Energy Level ─────────────────────────────────────────────
              _SectionLabel(label: 'Energy Level Required'),
              const SizedBox(height: 8),
              Row(
                children: _energies.map((e) {
                  final isSelected = _energy == e;
                  final energyColor = e == 'Low'
                      ? Colors.greenAccent
                      : e == 'Medium'
                      ? const Color(0xFFFFB347)
                      : _pink;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _energy = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: e != _energies.last ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [energyColor.withOpacity(0.8), energyColor.withOpacity(0.4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isSelected ? null : _cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? energyColor : _divider,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: energyColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))]
                              : [],
                        ),
                        child: Text(
                          e,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : _textSec,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // ── Submit Button ─────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_pink, _pinkLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: _pink.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 6)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Add Task to Timeline',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _pink,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;
  const _TimeButton({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: _pink, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 15, color: _pinkLight),
                const SizedBox(width: 6),
                Text(time,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPri)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String label;
  final double value;
  final String valueLabel;
  final Color color;
  final ValueChanged<double> onChanged;
  const _SliderCard({
    required this.label, required this.value,
    required this.valueLabel, required this.color, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _textPri)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(valueLabel,
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.15),
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: value, min: 1, max: 5, divisions: 4,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 – Low',  style: TextStyle(fontSize: 11, color: Color(0xFF555555))),
              Text('5 – High', style: TextStyle(fontSize: 11, color: Color(0xFF555555))),
            ],
          ),
        ],
      ),
    );
  }
}