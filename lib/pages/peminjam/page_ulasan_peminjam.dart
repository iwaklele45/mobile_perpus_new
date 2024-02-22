import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/assets/assets.gen.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/core/constrant/search_field.dart';
import 'package:mobile_perpus/pages/peminjam/user_book_pinjam.dart';

class UlasanPeminjam extends StatefulWidget {
  const UlasanPeminjam({Key? key}) : super(key: key);

  @override
  State<UlasanPeminjam> createState() => _UlasanPeminjamState();
}

class _UlasanPeminjamState extends State<UlasanPeminjam> {
  late List<DocumentSnapshot> reviewList;
  final TextEditingController _searchController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.twoWhiteColor,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.mainColor,
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Ulasan Buku',
            style: GoogleFonts.inter(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            TextFieldSearch(
              label: 'Cari Buku',
              controller: _searchController,
              icon: Assets.icons.search.svg(),
              suffixIcon: GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: Icon(Icons.clear)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ulasan')
                    .where('userId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    reviewList = snapshot.data!.docs;

                    List<DocumentSnapshot> filteredList =
                        reviewList.where((document) {
                      var reviewData = document.data() as Map<String, dynamic>;
                      var titleBook =
                          reviewData['judul buku'].toString().toLowerCase();

                      var searchQuery = _searchController.text.toLowerCase();

                      return titleBook.contains(searchQuery);
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var reviewData = filteredList[index].data()
                              as Map<String, dynamic>;
                          reviewList.length;
                          var book =
                              reviewList[index].data() as Map<String, dynamic>;
                          var titleBook = reviewData['judul buku'];
                          var review = reviewData['ulasan'];
                          var rating = reviewData['rating'];

                          return Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text('${index + 1}. $titleBook'),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Text(
                                      'Ulasan : $review\nRating : $rating\\9',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Tidak ada buku',
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
      ),
    );
  }
}
