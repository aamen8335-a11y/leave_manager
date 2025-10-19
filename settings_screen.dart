import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';

class SettingsScreen extends StatelessWidget {
  final AppUser currentUser;
  const SettingsScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الشِفتات')),
      body: StreamBuilder(
        stream: fs.usersStream(roles: ['employee','team_leader','supervisor']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data as List<AppUser>;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, i) {
              final u = users[i];
              return ListTile(
                title: Text(u.displayName),
                subtitle: Text('${u.role} - فريق: ${u.teamId ?? '-'}'),
                trailing: DropdownButton<String>(
                  value: u.department ?? 'Morning',
                  items: const [
                    DropdownMenuItem(value: 'Morning', child: Text('صباحي')),
                    DropdownMenuItem(value: 'Evening', child: Text('مسائي')),
                    DropdownMenuItem(value: 'Night', child: Text('ليلي')),
                  ],
                  onChanged: (val) async {
                    if (val != null) await fs.updateUserFields(u.uid, department: val);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
