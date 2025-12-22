import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:scanme_app/services/database_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    _historyFuture = DatabaseHelper.instance.readAllHistory();
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.history, size: 80, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text('No scans yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                ],
              ),
            );
          }

          final history = snapshot.data!;

          return ListView.separated(
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
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.isSafe ? const Color(0xFF00C9A7).withValues(alpha: 0.2) : const Color(0xFFFF5E5E).withValues(alpha: 0.2),
                      child: Icon(
                        item.isSafe ? Icons.check : Icons.warning_amber_rounded,
                        color: item.isSafe ? const Color(0xFF00C9A7) : const Color(0xFFFF5E5E),
                      ),
                    ),
                    title: Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(item.scanDate)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/result', extra: item.barcode);
                    },
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX(),
              );
            },
          );
        },
      ),
    );
  }
}
