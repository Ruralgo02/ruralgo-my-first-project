import 'package:flutter/material.dart';
import '../screens/select_address_map_page.dart';

/// Returns:
/// - String → if user selects from list
/// - Map    → if user picks on map
Future<dynamic> showLocationPickerSheet(
  BuildContext context, {
  required String title,
  required List<String> items,
  String searchHint = "Search location...",
  String emptyText = "No result found",
  bool showPickOnMap = true,
  bool showList = true, // ✅ NEW
}) async {
  final searchController = TextEditingController();
  final filtered = ValueNotifier<List<String>>(List<String>.from(items));

  final result = await showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              // ================= PICK ON MAP =================
              if (showPickOnMap)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: const Text(
                      "Pick on map",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () async {
                      // ✅ IMPORTANT:
                      // Use parent context, not sheetContext, to avoid the red crash
                      final res = await Navigator.of(context).pushNamed(
                        SelectAddressMapPage.routeName,
                      );

                      if (res != null && sheetContext.mounted) {
                        Navigator.pop(sheetContext, res);
                      }
                    },
                  ),
                ),

              if (showPickOnMap && showList) const SizedBox(height: 12),

              // ================= SEARCH + LIST =================
              if (showList) ...[
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (v) {
                    final q = v.trim().toLowerCase();
                    filtered.value = items
                        .where((e) => e.toLowerCase().contains(q))
                        .toList();
                  },
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: filtered,
                    builder: (_, list, __) {
                      if (list.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: Text(
                              emptyText,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          return ListTile(
                            title: Text(
                              list[i],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pop(sheetContext, list[i]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

  searchController.dispose();
  filtered.dispose();

  return result;
}