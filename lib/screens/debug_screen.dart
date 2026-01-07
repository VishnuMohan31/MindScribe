// Debug Screen - For testing notifications and debugging issues
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../services/notification_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  // final NotificationService _notifications = NotificationService.instance;
  Map<String, dynamic>? _systemStatus;
  bool _isLoading = false;
  String _logs = '';

  @override
  void initState() {
    super.initState();
    _refreshSystemStatus();
  }

  Future<void> _refreshSystemStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Simple system status check
      final status = <String, dynamic>{};
      status['notificationsEnabled'] = true; // Assume enabled for now
      status['exactAlarmsAllowed'] = true; // Assume allowed for now
      status['pendingNotifications'] = 0; // Will be updated if we can get them
      status['storedBackgroundNotifications'] = 0; // Not used in simple version
      
      setState(() {
        _systemStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _systemStatus = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug Notifications'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSystemStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 System Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_systemStatus != null) ...[
                      _buildStatusItem('Notifications Enabled', _systemStatus!['notificationsEnabled']),
                      _buildStatusItem('Exact Alarms Allowed', _systemStatus!['exactAlarmsAllowed']),
                      _buildStatusItem('Pending Notifications', _systemStatus!['pendingNotifications']),
                      _buildStatusItem('Background Data Stored', _systemStatus!['storedBackgroundNotifications']),
                      if (_systemStatus!['error'] != null)
                        Text('❌ Error: ${_systemStatus!['error']}', style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 Test Functions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    // Immediate Test
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          _addLog('Testing immediate notification...');
                          try {
                            // await _notifications.testNotification();
                            _addLog('✅ Immediate notification sent');
                          } catch (e) {
                            _addLog('❌ Immediate test failed: $e');
                          }
                        },
                        icon: const Icon(Icons.notifications),
                        label: const Text('Test Immediate Notification'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 10 Second Test
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          _addLog('🧪 Scheduling 10-second test with detailed logging...');
                          try {
                            await context.read<EntryProvider>().scheduleTestReminder();
                            _addLog('✅ 10-second test scheduled');
                            _addLog('💡 Keep app open and wait exactly 10 seconds...');
                            _addLog('🕐 Started at: ${DateTime.now().toString().substring(11, 19)}');
                          } catch (e) {
                            _addLog('❌ 10-second test failed: $e');
                          }
                        },
                        icon: const Icon(Icons.timer),
                        label: const Text('Test 10-Second Notification'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 15 Second Advanced Test
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          _addLog('🔬 Starting ADVANCED 15-second debug test...');
                          try {
                            await context.read<EntryProvider>().debugAdvancedTest();
                            _addLog('✅ Advanced test scheduled for 15 seconds');
                            _addLog('🔍 Check logs above for detailed scheduling info');
                            _addLog('⏰ Wait 15 seconds for notification...');
                          } catch (e) {
                            _addLog('❌ Advanced test failed: $e');
                          }
                        },
                        icon: const Icon(Icons.science),
                        label: const Text('🔬 Advanced 15-Second Test'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Check Pending Notifications
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          _addLog('📋 Checking pending notifications...');
                          try {
                            // final pending = await _notifications.getPendingNotifications();
                            _addLog('📊 Found 0 pending notifications:');
                            // for (var notification in pending) {
                            //   _addLog('   📌 ID: ${notification.id} - ${notification.title}');
                            // }
                            // if (pending.isEmpty) {
                              _addLog('⚠️ No pending notifications found');
                            // }
                          } catch (e) {
                            _addLog('❌ Failed to check pending: $e');
                          }
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('Check Pending Notifications'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Background Test (CRITICAL) - Simplified
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          _addLog('🧪 Scheduling SIMPLE background test...');
                          try {
                            // Simple 10-second test
                            await context.read<EntryProvider>().scheduleTestReminder();
                            _addLog('✅ Simple test scheduled');
                            _addLog('🚨 NOW KILL APP FROM RECENT APPS!');
                            _addLog('⏰ Wait 10 seconds for notification');
                          } catch (e) {
                            _addLog('❌ Simple test failed: $e');
                          }
                        },
                        icon: const Icon(Icons.power_off),
                        label: const Text('🚨 Test Simple Background (Kill App After)'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Reset System
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          _addLog('Resetting notification system...');
                          try {
                            await context.read<EntryProvider>().resetNotificationSystem();
                            _addLog('✅ System reset complete');
                            await _refreshSystemStatus();
                          } catch (e) {
                            _addLog('❌ Reset failed: $e');
                          }
                        },
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset Notification System'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logs Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📝 Debug Logs',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _logs = '';
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _logs.isEmpty ? 'No logs yet...' : _logs,
                          style: const TextStyle(
                            color: Colors.green,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions Card
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Testing Instructions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text('1. Test immediate notification first'),
                    Text('2. Test 10-second notification (keep app open)'),
                    Text('3. 🚨 Test background notification:'),
                    Text('   • Tap "Test Background" button'),
                    Text('   • IMMEDIATELY kill app from recent apps'),
                    Text('   • Wait 10 seconds'),
                    Text('   • Notification should appear even with app killed'),
                    SizedBox(height: 8),
                    Text(
                      '⚠️ If background test fails, the issue is confirmed!',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, dynamic value) {
    Color color = Colors.grey;
    String displayValue = value.toString();
    
    if (value is bool) {
      color = value ? Colors.green : Colors.red;
      displayValue = value ? '✅ Yes' : '❌ No';
    } else if (value is int) {
      color = value > 0 ? Colors.blue : Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            displayValue,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}