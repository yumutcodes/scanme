import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:scanme_app/services/database_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanme_app/widgets/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = DatabaseHelper.instance.readAllHistory();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _loadHistory();
    });
    // Wait for the future to complete before completing the refresh
    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: FutureBuilder<List<ScanItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history_rounded,
              title: 'No scans yet',
              subtitle: 'Start by scanning your first product barcode to see your history here',
              buttonText: 'Scan Your First Product',
              onButtonPressed: () => context.go('/scan'),
              gradientColors: const [
                Color(0xFF00C9A7),
                Color(0xFF00B4DB),
              ],
            );
          }

          final history = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshHistory,
            color: const Color(0xFF00C9A7),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = history[index];
                return Dismissible(
                  key: Key(item.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    DatabaseHelper.instance.delete(item.id!);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: item.isSafe 
                              ? const Color(0xFF00C9A7).withValues(alpha: 0.15)
                              : const Color(0xFFFF5E5E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.isSafe ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                          color: item.isSafe ? const Color(0xFF00C9A7) : const Color(0xFFFF5E5E),
                        ),
                      ),
                      title: Text(
                        item.productName, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        DateFormat.yMMMd().add_jm().format(item.scanDate),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded, 
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      onTap: () {
                        context.push('/result', extra: item.barcode);
                      },
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
