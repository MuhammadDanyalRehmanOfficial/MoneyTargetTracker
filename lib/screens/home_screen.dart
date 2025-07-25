// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/income_entry.dart';
import '../services/storage_service.dart';
import '../widgets/progress_card.dart';
import '../widgets/entry_item.dart';
import '../widgets/set_target_bottom_sheet.dart';
import '../widgets/add_entry_bottom_sheet.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double monthlyTarget = 0;
  List<IncomeEntry> entries = [];
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _loadData();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final target = await StorageService.getMonthlyTarget();
      final loadedEntries = await StorageService.getEntries();

      setState(() {
        monthlyTarget = target;
        entries = loadedEntries;
        _isLoading = false;
      });

      _progressController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double get totalCollected =>
      entries.fold(0, (sum, entry) => sum + entry.amount);

  double get remainingAmount => monthlyTarget - totalCollected;

  double get progressPercentage =>
      monthlyTarget > 0 ? (totalCollected / monthlyTarget).clamp(0.0, 1.0) : 0;

  void _showSetTargetBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetTargetBottomSheet(
        currentTarget: monthlyTarget,
        onTargetSet: (target) async {
          await StorageService.setMonthlyTarget(target);
          setState(() {
            monthlyTarget = target;
          });
          _progressController.reset();
          _progressController.forward();
        },
      ),
    );
  }

  void _showAddEntryBottomSheet([IncomeEntry? entryToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEntryBottomSheet(
        entryToEdit: entryToEdit,
        onEntrySaved: (entry) async {
          if (entryToEdit != null) {
            await StorageService.updateEntry(entry);
          } else {
            await StorageService.addEntry(entry);
          }
          _loadData();
        },
        onEntryDeleted: (entryId) async {
          await StorageService.deleteEntry(entryId);
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Money Target Tracker',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showSetTargetBottomSheet,
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Set Target',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                ProgressCard(
                  monthlyTarget: monthlyTarget,
                  totalCollected: totalCollected,
                  remainingAmount: remainingAmount,
                  progressPercentage: progressPercentage,
                  progressAnimation: _progressAnimation,
                  onEditTarget: _showSetTargetBottomSheet,
                ),

                const SizedBox(height: 24),

                // Recent Entries Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Entries',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entries.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(
                                entries: entries,
                                onEntryTap: _showAddEntryBottomSheet,
                              ),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Entries List
                if (entries.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No entries yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first income entry',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...entries
                      .take(5)
                      .map(
                        (entry) => EntryItem(
                          entry: entry,
                          onTap: () => _showAddEntryBottomSheet(entry),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryBottomSheet(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry'),
      ),
    );
  }
}
