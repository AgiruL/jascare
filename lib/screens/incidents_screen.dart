import 'dart:io';
import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

class IncidentsScreen extends StatelessWidget {
  final List<CustomIncident> incidentList;
  final Function(String) onSolve;
  final Function(String) onDelete;
  final bool isDark;

  const IncidentsScreen({
    super.key,
    required this.incidentList,
    required this.onSolve,
    required this.onDelete,
    required this.isDark,
  });

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("Do you really want to permanently delete this record from the solved incidents list?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                onDelete(id);
                Navigator.pop(ctx);
              },
              child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _viewAttachedImage(BuildContext context, String? path) {
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No photographic evidence attached to this incident record."))
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(title: const Text("Evidence Photo Preview"), backgroundColor: Colors.transparent, elevation: 0, leading: const CloseButton()),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(path), fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentListBlock(BuildContext context, List<CustomIncident> list, bool isActiveTab, Color txtColor, Color cardBg) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isActiveTab ? "🎉 All clean! No active concerns." : "No archived solved histories recorded.",
          style: TextStyle(color: txtColor.withAlpha(150), fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          color: cardBg,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: item.category == "Crime" ? Colors.purple.withAlpha(40) : Colors.orange.withAlpha(40),
                    child: Icon(item.category == "Crime" ? Icons.security : Icons.build, color: item.category == "Crime" ? Colors.purpleAccent : Colors.orange),
                  ),
                  title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, color: txtColor)),
                  subtitle: Text(item.description, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                ),
                const Divider(),
                if (isActiveTab)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text("View Photo"),
                        onPressed: () => _viewAttachedImage(context, item.imagePath),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Mark Solved"),
                        onPressed: () => onSolve(item.id),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("🟢 Resolved  ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _showDeleteConfirmation(context, item.id),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color txtColor = isDark ? Colors.white : const Color(0xFF1A233D);
    final Color cardBg = isDark ? const Color(0xFF161625) : Colors.white;

    final activeList = incidentList.where((e) => e.isActive).toList();
    final solvedList = incidentList.where((e) => !e.isActive).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Campus Tracking Panel", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: cardBg,
          foregroundColor: txtColor,
          bottom: TabBar(
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: txtColor.withAlpha(140),
            indicatorColor: const Color(0xFF6366F1),
            tabs: const [
              Tab(text: "Active", icon: Icon(Icons.warning_amber_rounded, size: 20)),
              Tab(text: "Solved", icon: Icon(Icons.task_alt_rounded, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIncidentListBlock(context, activeList, true, txtColor, cardBg),
            _buildIncidentListBlock(context, solvedList, false, txtColor, cardBg),
          ],
        ),
      ),
    );
  }
}