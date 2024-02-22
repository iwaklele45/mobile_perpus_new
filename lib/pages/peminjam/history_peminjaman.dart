import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';

class HistoryPeminjamanUser extends StatefulWidget {
  const HistoryPeminjamanUser({Key? key}) : super(key: key);

  @override
  State<HistoryPeminjamanUser> createState() => _HistoryPeminjamanUserState();
}

class _HistoryPeminjamanUserState extends State<HistoryPeminjamanUser> {
  List<DocumentSnapshot>? loanHistory; // Provide an initial value
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchLoanHistory();
  }

  Future<void> fetchLoanHistory() async {
    try {
      if (user != null) {
        QuerySnapshot loanSnapshot = await FirebaseFirestore.instance
            .collection('peminjaman')
            .where('id user', isEqualTo: user?.uid)
            .where('status peminjaman',
                whereIn: ['selesai di review', 'telah dikembalikan']).get();

        setState(() {
          loanHistory = loanSnapshot.docs;
        });
      }
    } catch (e) {
      print('Error fetching loan history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.twoWhiteColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.mainColor,
              ),
            ),
          ),
        ),
        title: Text(
          'History',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
      ),
      body: loanHistory != null && loanHistory!.isNotEmpty
          ? ListView.builder(
              itemCount: loanHistory!.length,
              itemBuilder: (context, index) {
                var loanData =
                    loanHistory![index].data() as Map<String, dynamic>;
                var bookTitle = loanData['judul buku dipinjam'];
                var tglPinjam = loanData['tanggal peminjaman'];
                var tglPengembalian = loanData['tanggal pengembalian'];
                Timestamp timePinjam = tglPinjam;
                DateTime datePinjam = timePinjam.toDate();
                Timestamp timePengembalian = tglPengembalian;
                DateTime datePengembalian = timePengembalian.toDate();

                // Format dates to display only date, month, and year
                String formattedDatePinjam =
                    DateFormat.yMMMEd().format(datePinjam);
                String formattedDatePengembalian =
                    DateFormat.yMMMEd().format(datePengembalian);

                return ListTile(
                  title: Text('${index + 1}. $bookTitle'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Peminjaman: $formattedDatePinjam',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Tanggal Pengembalian: $formattedDatePengembalian',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: loanHistory == null
                  ? CircularProgressIndicator()
                  : Text('Tidak ada history peminjaman.'),
            ),
    );
  }
}
