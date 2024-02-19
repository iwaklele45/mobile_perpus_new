import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/pages/admin/petugas/page_tambah_petugas.dart';

class PagePetugas extends StatefulWidget {
  const PagePetugas({Key? key}) : super(key: key);

  @override
  State<PagePetugas> createState() => _PagePetugasState();
}

class _PagePetugasState extends State<PagePetugas> {
  final TextEditingController _searchController = TextEditingController();
  late StreamController<List<DocumentSnapshot>> _searchControllerStream;
  List<DocumentSnapshot> _userList = [];

  @override
  void initState() {
    super.initState();
    _searchControllerStream = StreamController<List<DocumentSnapshot>>();
    _searchController.addListener(_onSearchChanged);
    _initializeUserListStream();
  }

  void _onSearchChanged() {
    var searchText = _searchController.text.toLowerCase();
    var filteredList = _filterUsers(searchText);
    _searchControllerStream.add(filteredList);
  }

  List<DocumentSnapshot> _filterUsers(String searchText) {
    return _userList.where((userDoc) {
      var user = userDoc.data() as Map<String, dynamic>;
      var fullName = user['username'].toLowerCase();
      return fullName.contains(searchText);
    }).toList();
  }

  void _initializeUserListStream() {
    FirebaseFirestore.instance
        .collection('users')
        .where('levelUser', isEqualTo: 'Petugas') // Filter berdasarkan level
        .snapshots()
        .listen((snapshot) {
      _userList = snapshot.docs;
      _searchControllerStream.add(_userList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Petugas')),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {});
                        },
                        child: const Icon(Icons.search)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _searchControllerStream.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var users = snapshot.data ?? [];

                  if (users.isNotEmpty) {
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index].data() as Map<String, dynamic>;
                        var email = user['email'];
                        var address = user['alamat'];
                        var statusEmail = user['statusEmail'];
                        var fine = user['denda'];
                        var fullName = user['namaLengkap'];
                        var username = user['username'];

                        return ListTile(
                          title: Text('${index + 1} . $username'),
                          onTap: () {
                            _showUserDetails(
                              context,
                              fullName,
                              username,
                              email,
                              address,
                              statusEmail,
                              fine,
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Tidak Ada Petugas',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.mainColor,
        label: const Text(
          'Tambah Petugas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PageTambahPetugas(),
          ));
        },
      ),
    );
  }

  void _showUserDetails(
    BuildContext context,
    String fullName,
    String username,
    String email,
    String address,
    bool statusEmail,
    int fine,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Petugas'),
          content: SizedBox(
            height: 280,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name   :',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$fullName',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Username   :',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$username',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Email   :',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$email',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Address   :',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$address',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Status Email   :',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Status Email: ${statusEmail ? 'Verified' : 'Not Verified'}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _showDeleteConfirmation(context, email);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userEmail) async {
    try {
      // Membuat pengguna dengan email dan password
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: userEmail, password: "temporary");

      var user = userCredential.user;

      if (user != null) {
        // Hapus pengguna
        await user.delete();
        print('User deleted successfully from Firebase Authentication!');
        print('Email: $userEmail');
      } else {
        print('User not found in Firebase Authentication');
        print('Email: $userEmail');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }

    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userQuery.docs.isNotEmpty) {
      var userDoc = userQuery.docs.first;
      await userDoc.reference.delete();
      print('Staf data deleted successfully from Firestore!');
      print('Email: $userEmail');
    } else {
      print('Staf data not found in Firestore');
      print('Email: $userEmail');
    }
  }

  void _showDeleteConfirmation(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
              'Apakah kamu yakin ingin menghapus petugas ini (Petugas akan Diblokir)!'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    _deleteUser(email);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}