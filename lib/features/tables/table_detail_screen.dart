import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/core_providers.dart';
import '../../core/api/project_api.dart';
import 'tables_provider.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_skeleton.dart';
import '../../widgets/supa_button.dart';
import '../../widgets/supa_text_field.dart';
import 'package:flutter/services.dart';

class TableDetailScreen extends ConsumerStatefulWidget {
  final String projectRef;
  final String tableName;

  const TableDetailScreen({
    super.key,
    required this.projectRef,
    required this.tableName,
  });

  @override
  ConsumerState<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends ConsumerState<TableDetailScreen> {
  bool _isProcessing = false;
  int? _sortColumnIndex;
  bool _isAscending = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dataState = ref.watch(tableDataProvider((
      projectRef: widget.projectRef,
      tableName: widget.tableName,
    )));

    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: widget.tableName,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Table'),
                  content: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Enter search term...'),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(tableDataProvider((
              projectRef: widget.projectRef,
              tableName: widget.tableName,
            )).future),
          ),
        ],
      ),
      body: Stack(
        children: [
          dataState.when(
            data: (rows) {
              if (rows.isEmpty) {
                return const Center(child: Text('No data found in this table'));
              }

              final columns = (rows.first as Map<String, dynamic>).keys.toList();
              // Attempt to find a primary key (common pattern is 'id')
              final String pkCol = columns.contains('id') ? 'id' : columns.first;

              // Apply Search
              var displayRows = rows.where((row) {
                if (_searchQuery.isEmpty) return true;
                return row.values.any((v) => v.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
              }).toList();

              // Apply Sorting
              if (_sortColumnIndex != null) {
                final colName = columns[_sortColumnIndex!];
                displayRows.sort((a, b) {
                  final valA = a[colName];
                  final valB = b[colName];
                  if (valA == null) return 1;
                  if (valB == null) return -1;
                  final cmp = valA.toString().compareTo(valB.toString());
                  return _isAscending ? cmp : -cmp;
                });
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgOverlay,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: DataTable(
                      columnSpacing: 24,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _isAscending,
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.supaGreen,
                      ),
                      columns: [
                        ...columns.asMap().entries.map((entry) => DataColumn(
                          label: Text(entry.value),
                          onSort: (index, ascending) {
                            setState(() {
                              _sortColumnIndex = index;
                              _isAscending = ascending;
                            });
                          },
                        )),
                        const DataColumn(label: Text('Actions')),
                      ],
                      rows: displayRows.map((row) {
                        return DataRow(
                          cells: [
                            ...columns.map((col) {
                              final value = row[col];
                              return DataCell(
                                InkWell(
                                  onLongPress: () => _showEditCellDialog(context, col, value, row[pkCol], pkCol),
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 200),
                                    child: Text(
                                      value?.toString() ?? 'NULL',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: value == null ? AppColors.textMuted : AppColors.textPrimary,
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    onPressed: () => _confirmDelete(context, pkCol, row[pkCol]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: AppColors.supaGreen)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.supaGreen,
        child: Icon(Icons.add, color: AppColors.bgBase),
        onPressed: () => _showAddRowDialog(context),
      ),
    );
  }

  void _showEditCellDialog(BuildContext context, String column, dynamic value, dynamic pkValue, String pkCol) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $column'),
        content: SupaTextField(
          label: column,
          controller: controller,
          placeholder: 'New value...',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessing = true);
              try {
                final serviceKey = await ref.read(serviceRoleKeyProvider(widget.projectRef).future);
                final api = ProjectApi(projectRef: widget.projectRef, serviceRoleKey: serviceKey!);
                
                await api.updateRow(widget.tableName, pkCol, pkValue, {column: controller.text});
                ref.invalidate(tableDataProvider((projectRef: widget.projectRef, tableName: widget.tableName)));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Row updated')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                setState(() => _isProcessing = false);
              }
            },
            child: Text('Update', style: TextStyle(color: AppColors.supaGreen)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String pkCol, dynamic pkValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Row?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessing = true);
              try {
                final serviceKey = await ref.read(serviceRoleKeyProvider(widget.projectRef).future);
                final api = ProjectApi(projectRef: widget.projectRef, serviceRoleKey: serviceKey!);
                
                await api.deleteRow(widget.tableName, pkCol, pkValue);
                ref.invalidate(tableDataProvider((projectRef: widget.projectRef, tableName: widget.tableName)));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Row deleted')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                setState(() => _isProcessing = false);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddRowDialog(BuildContext context) {
    // For simplicity, we'll suggest using the SQL editor for now or implement a dynamic form
    // Given "everything should work", I'll implement a basic "insert row" if I have columns.
    final dataState = ref.read(tableDataProvider((projectRef: widget.projectRef, tableName: widget.tableName)));
    dataState.whenData((rows) {
      if (rows.isEmpty) return;
      final columns = (rows.first as Map<String, dynamic>).keys.toList();
      final controllers = {for (var col in columns) col: TextEditingController()};

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Insert Row into ${widget.tableName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: columns.map((col) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SupaTextField(
                  label: col, 
                  controller: controllers[col]!,
                  placeholder: 'Enter $col...',
                ),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isProcessing = true);
                try {
                  final data = {for (var col in columns) if(controllers[col]!.text.isNotEmpty) col: controllers[col]!.text};
                  final serviceKey = await ref.read(serviceRoleKeyProvider(widget.projectRef).future);
                  final api = ProjectApi(projectRef: widget.projectRef, serviceRoleKey: serviceKey!);
                  
                  await api.insertRow(widget.tableName, data);
                  ref.invalidate(tableDataProvider((projectRef: widget.projectRef, tableName: widget.tableName)));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Row inserted')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                } finally {
                  setState(() => _isProcessing = false);
                }
              },
              child: Text('Insert', style: TextStyle(color: AppColors.supaGreen)),
            ),
          ],
        ),
      );
    });
  }
}

