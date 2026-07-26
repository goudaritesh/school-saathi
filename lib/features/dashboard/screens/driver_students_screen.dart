import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_provider.dart';
import '../../chat/screens/chat_screen.dart' as import_chat;
import '../../connections/providers/connection_provider.dart';

class DriverStudentsScreen extends StatefulWidget {
  const DriverStudentsScreen({super.key});

  @override
  State<DriverStudentsScreen> createState() => _DriverStudentsScreenState();
}

class _DriverStudentsScreenState extends State<DriverStudentsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0047FF), // Base background blue
      body: Consumer<DriverProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Blue Gradient Header
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0047FF), Color(0xFF007BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: _isSearching
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 45, // Add an explicit height for better alignment
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      hintText: 'Search students or parents...',
                                      hintStyle: TextStyle(color: Colors.white70),
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.search, color: Colors.white70, size: 20),
                                    ),
                                    onChanged: (value) {
                                      provider.setSearchQuery(value);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSearching = false;
                                    _searchController.clear();
                                  });
                                  provider.setSearchQuery('');
                                },
                                child: _buildTopIcon(Icons.close),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Students',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'View and manage all connected students',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSearching = true;
                                      });
                                    },
                                    child: _buildTopIcon(Icons.search),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      _showFilterBottomSheet(context, provider);
                                    },
                                    child: _buildTopIcon(Icons.filter_alt_outlined),
                                  ),
                                ],
                              )
                            ],
                          ),
                  ),
                ),
              ),
              
              // White rounded container for main content
              Padding(
                padding: const EdgeInsets.only(top: 145), // Increased from 130 to give search bar space
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Tabs
                      _buildTabs(provider),
                      
                      const SizedBox(height: 20),
                      // Stats Row
                      _buildStatsRow(provider),
                      
                      const SizedBox(height: 16),
                      // Main List Content
                      Expanded(
                        child: _buildMainContent(provider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(DriverProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage.isNotEmpty) {
      return Center(child: Text(provider.errorMessage));
    }

    if (provider.students.isEmpty) {
      return const Center(child: Text('No students connected yet.'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchStudents(),
      child: provider.filteredStudents.isEmpty
          ? const Center(child: Text('No students found.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: provider.filteredStudents.length,
              itemBuilder: (context, index) {
                final student = provider.filteredStudents[index];
                return _buildStudentCard(student, context);
              },
            ),
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildTabs(DriverProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          _buildTab(provider, 'All', Icons.people, Colors.blue),
          _buildTab(provider, 'Present', Icons.check_circle_outline, Colors.green),
          _buildTab(provider, 'Absent', Icons.person_off, Colors.red),
        ],
      ),
    );
  }

  Widget _buildTab(DriverProvider provider, String title, IconData icon, Color activeColor) {
    bool isSelected = provider.studentFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setStudentFilter(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : activeColor, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(DriverProvider provider) {
    final students = provider.students;
    final total = students.length;
    final present = students.where((s) => ['Present', 'Picked Up', 'Dropped Off'].contains(s['today_attendance'])).length;
    final absent = students.where((s) => s['today_attendance'] == 'Absent').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatColumn('Total Students', total.toString(), Colors.black87),
          _buildStatColumn('Present', present.toString(), Colors.green),
          _buildStatColumn('Absent', absent.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, Color countColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(count, style: TextStyle(color: countColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, BuildContext context) {
    final parentUser = student['user'] ?? {};
    final attendance = student['today_attendance'] ?? 'Pending';
    final isDropped = attendance == 'Dropped Off';
    final isPicked = attendance == 'Picked Up';
    final isAbsent = attendance == 'Absent';

    // Status UI Configuration
    Color statusColor = Colors.orange;
    Color statusBgColor = Colors.orange.shade50;
    IconData statusIcon = Icons.access_time;
    String statusText = attendance;

    if (isDropped || isPicked) {
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
    } else if (isAbsent) {
      statusColor = Colors.red;
      statusBgColor = Colors.red.shade50;
      statusIcon = Icons.cancel;
    }

    // Try extract time from updated at (or dummy)
    String timeStr = '--:-- --';
    if (student['updatedAt'] != null) {
      DateTime dt = DateTime.tryParse(student['updatedAt']) ?? DateTime.now();
      String ampm = dt.hour >= 12 ? 'PM' : 'AM';
      int hour12 = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      timeStr = '${hour12.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.blue, size: 30),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      student['child_name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Class ${student['class_info'] ?? '--'}',
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Parent: ${parentUser['name'] ?? '--'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              parentUser['phone'] ?? '--',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Row(
                      children: [
                        // Chat Action
                        _buildActionIcon(Icons.chat, Colors.blue, () {
                          final parentId = parentUser['_id'];
                          final parentName = parentUser['name'];
                          if (parentId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => import_chat.ChatScreen(
                                  userId: parentId,
                                  userName: parentName ?? 'Parent',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cannot chat: Parent ID missing')),
                            );
                          }
                        }),
                        
                        // Attendance Popup Menu
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.how_to_reg, size: 18, color: Colors.green),
                          ),
                          tooltip: 'Manual Attendance',
                          onSelected: (status) async {
                            if (student['qr_code_data'] == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cannot mark attendance: QR Code data missing')),
                              );
                              return;
                            }
                            try {
                              await Provider.of<DriverProvider>(context, listen: false)
                                  .markAttendance(student['qr_code_data'], status);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Marked as $status successfully'), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(value: 'Picked Up', child: Text('Picked Up')),
                            const PopupMenuItem<String>(value: 'Dropped Off', child: Text('Dropped Off')),
                            const PopupMenuItem<String>(value: 'Absent', child: Text('Absent')),
                          ],
                        ),

                        // History Action
                        _buildActionIcon(Icons.history, Colors.blue, () {
                          _showHistoryBottomSheet(context, student);
                        }),
                        
                        // Call Action
                        _buildActionIcon(Icons.call, Colors.blue, () {
                          // Call parent logic here
                        }),
                        
                        // More Options / Disconnect
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                          ),
                          tooltip: 'More options',
                          onSelected: (action) {
                            if (action == 'chat') {
                              // Chat logic
                            } else if (action == 'call') {
                              // Call logic
                            } else if (action == 'disconnect') {
                              _showDisconnectDialog(context, student);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'chat',
                              child: Text('Chat with Parent'),
                            ),
                            const PopupMenuItem(
                              value: 'call',
                              child: Text('Call Parent'),
                            ),
                            const PopupMenuItem(
                              value: 'disconnect',
                              child: Text('Disconnect', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(left: 2),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // Same history bottom sheet from previous version
  void _showHistoryBottomSheet(BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'History: ${student['child_name'] ?? 'Student'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: Provider.of<DriverProvider>(context, listen: false)
                        .fetchStudentAttendanceHistory(student['_id'] ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                      }
                      final history = snapshot.data ?? [];
                      if (history.isEmpty) {
                        return const Center(child: Text('No attendance history found.'));
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final record = history[index];
                          final dateStr = record['date'] ?? record['createdAt'];
                          DateTime? date;
                          if (dateStr != null) {
                            date = DateTime.tryParse(dateStr);
                          }
                          final formattedDate = date != null
                              ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                              : 'Unknown Date';
                          
                          Color statusColor = Colors.orange;
                          if (record['status'] == 'Picked Up' || record['status'] == 'Dropped Off') statusColor = Colors.green;
                          if (record['status'] == 'Absent') statusColor = Colors.red;

                          return ListTile(
                            leading: Icon(
                              Icons.history_toggle_off,
                              color: statusColor,
                            ),
                            title: Text(record['status'] ?? 'Unknown'),
                            subtitle: Text(formattedDate),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDisconnectDialog(BuildContext context, Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disconnect Student'),
          content: Text('Are you sure you want to disconnect from ${student['child_name']}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(context).pop();
                
                final parentUserId = student['user']?['_id'];
                
                final success = await Provider.of<ConnectionProvider>(context, listen: false)
                    .disconnectUser(targetUserId: parentUserId);
                    
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Disconnected successfully')),
                  );
                  Provider.of<DriverProvider>(context, listen: false).fetchStudents();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to disconnect')),
                  );
                }
              },
              child: const Text('Disconnect', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  void _showFilterBottomSheet(BuildContext context, DriverProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Students',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Attendance Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _buildFilterChip(context, provider, 'All'),
                  _buildFilterChip(context, provider, 'Present'),
                  _buildFilterChip(context, provider, 'Absent'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, DriverProvider provider, String label) {
    final isSelected = provider.studentFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          provider.setStudentFilter(label);
          Navigator.pop(context);
        }
      },
      selectedColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade800 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
