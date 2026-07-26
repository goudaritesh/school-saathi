import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const ComplaintDetailsScreen({Key? key, required this.complaint}) : super(key: key);

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  final _msgController = TextEditingController();
  late ComplaintModel _currentComplaint;

  @override
  void initState() {
    super.initState();
    _currentComplaint = widget.complaint;
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success = await provider.addResponse(_currentComplaint.id, text);
    
    if (success) {
      // Find the updated complaint in the list
      final updated = provider.complaints.firstWhere((c) => c.id == _currentComplaint.id);
      setState(() {
        _currentComplaint = updated;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send message')));
    }
  }

  void _updateStatus(String status) async {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success = await provider.updateStatus(_currentComplaint.id, status);
    if (success) {
      final updated = provider.complaints.firstWhere((c) => c.id == _currentComplaint.id);
      setState(() {
        _currentComplaint = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser?['_id'] ?? Provider.of<AuthProvider>(context, listen: false).currentUser?['id'];
    final isParent = Provider.of<AuthProvider>(context, listen: false).currentUser?['role'] == 'Parent';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Thread'),
      ),
      body: Column(
        children: [
          // Header / details
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(_currentComplaint.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    _buildStatusChip(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_currentComplaint.description),
                
                if (_currentComplaint.attachmentUrl != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // Optionally open full image
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${ApiClient.baseUrl.replaceAll('/api', '')}${_currentComplaint.attachmentUrl}',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],

                // Action buttons for status change
                if (_currentComplaint.status != 'resolved') ...[
                  const Divider(),
                  Row(
                    children: [
                      if (isParent) ...[
                        ElevatedButton(
                          onPressed: () => _updateStatus('resolved'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Mark as Resolved', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      if (!isParent && _currentComplaint.status == 'open') ...[
                        OutlinedButton(
                          onPressed: () => _updateStatus('in-progress'),
                          child: const Text('Mark In-Progress'),
                        ),
                      ],
                    ],
                  )
                ]
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Chat Thread
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _currentComplaint.responses.length,
                itemBuilder: (context, index) {
                  final resp = _currentComplaint.responses[index];
                  final isMe = resp.senderId == currentUserId;
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? Theme.of(context).primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                          bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ]
                      ),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            Text(resp.senderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            resp.message,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('h:mm a').format(resp.createdAt),
                            style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input area
          if (_currentComplaint.status != 'resolved')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (_currentComplaint.status) {
      case 'resolved': color = Colors.green; break;
      case 'in-progress': color = Colors.orange; break;
      default: color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _currentComplaint.status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
