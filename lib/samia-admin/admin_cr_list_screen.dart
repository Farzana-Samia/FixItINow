import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixitnow/screens/cr_profile_screen.dart';

class AdminCRListScreen extends StatefulWidget {
  const AdminCRListScreen({super.key});

  @override
  State<AdminCRListScreen> createState() => _AdminCRListScreenState();
}

class _AdminCRListScreenState extends State<AdminCRListScreen> {
  Stream<QuerySnapshot> getPendingCRs() {
    return FirebaseFirestore.instance
        .collection('cr_registrations')
        .where('approved', isEqualTo: false)
        .snapshots();
  }

  Future<void> approveCR(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final department = data['department'];
    final level = data['level'];
    final section = data['section'];

    final existing = await FirebaseFirestore.instance
        .collection('user')
        .where('department', isEqualTo: department)
        .where('level', isEqualTo: level)
        .where('section', isEqualTo: section)
        .where('role', isEqualTo: 'cr')
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❗ Only one CR allowed per section."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('cr_registrations')
        .doc(docId)
        .update({'approved': true});

    await FirebaseFirestore.instance.collection('user').doc(docId).set({
      ...data,
      'approved': true,
      'role': 'cr',
      'userType': 'cr',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ CR approved and added to user list.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> declineCR(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('cr_registrations')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ CR request declined.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> deleteApprovedCR(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete CR?"),
        content: const Text(
          "This will remove the CR from the system permanently.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('user').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ CR deleted.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCRDetailsDialog(
    BuildContext context,
    Map<String, dynamic> crData,
    String docId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("CR Registration Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${crData['name']}"),
            Text("MIST Roll: ${crData['mist_roll']}"),
            Text("Email: ${crData['email']}"),
            Text("Mobile: ${crData['mobile']}"),
            Text("Level: ${crData['level']}"),
            Text("Section: ${crData['section']}"),
            Text("Department: ${crData['department']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              approveCR(context, docId, crData);
              Navigator.pop(context);
            },
            child: const Text("Approve"),
          ),
          ElevatedButton(
            onPressed: () {
              declineCR(context, docId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Decline"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[700],
        title: const Text("Registered CR"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "⏳ Pending CR Requests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getPendingCRs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No pending CR."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () => _showCRDetailsDialog(context, data, doc.id),
                      child: Card(
                        color: Colors.yellow[100],
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(data['name'] ?? 'Unnamed'),
                          subtitle: Text(
                            "Level ${data['level']} - Section ${data['section']}",
                          ),
                          trailing: const Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "✅ Approved CR",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .where('role', isEqualTo: 'cr')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('❌ No approved CR.'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final cr = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text('${cr['name']} (${cr['mist_roll']})'),
                        subtitle: Text(
                          'Dept: ${cr['department']} | Level ${cr['level']} - Sec ${cr['section']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteApprovedCR(context, doc.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CRProfileScreen(crData: cr),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
