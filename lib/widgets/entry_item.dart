// lib/widgets/entry_item.dart
import 'package:flutter/material.dart';
import '../models/income_entry.dart';
import '../utils/date_formatter.dart';

class EntryItem extends StatelessWidget {
  final IncomeEntry entry;
  final VoidCallback onTap;
  final bool showNote;
  final bool useDetailedDate;

  const EntryItem({
    super.key,
    required this.entry,
    required this.onTap,
    this.showNote = false,
    this.useDetailedDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.trending_up_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          '${entry.amount.toStringAsFixed(0)} PKR',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              useDetailedDate
                  ? DateFormatter.formatDateTimeForHistory(entry.timestamp)
                  : DateFormatter.formatDateTime(entry.timestamp),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (showNote && entry.note.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                entry.note,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
