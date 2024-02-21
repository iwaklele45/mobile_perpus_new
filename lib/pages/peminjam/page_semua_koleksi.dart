import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/assets/assets.gen.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/pages/peminjam/user_book_pinjam.dart';

class PageFavBook extends StatefulWidget {
  const PageFavBook({Key? key}) : super(key: key);

  @override
  State<PageFavBook> createState() => _PageFavBookState();
}

class _PageFavBookState extends State<PageFavBook> {
  late List<String> judulBukuFav = [];
  late List<DocumentSnapshot> bookList;
  final TextEditingController _searchController = TextEditingController();
  late String idBookFav = '';

  final StreamController<QuerySnapshot> _fetchUserFavBookStreamController =
      StreamController<QuerySnapshot>();

  Stream<QuerySnapshot> _fetchUserFavBookStream() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Future.delayed(Duration(seconds: 0), () async {
        var querySnapshot = await FirebaseFirestore.instance
            .collection('buku')
            .where('judul', whereIn: judulBukuFav)
            .orderBy('judul', descending: false)
            .get();

        _fetchUserFavBookStreamController.add(querySnapshot);
      });

      return _fetchUserFavBookStreamController.stream;
    } else {
      _fetchUserFavBookStreamController.close();
      return Stream.empty();
    }
  }

  Future<void> _fetchUserFavBook() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('koleksiBuku')
            .where('idUser', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          judulBukuFav = querySnapshot.docs
              .map((document) => document['judulBukuKoleksi'].toString())
              .toList();

          print('Favorite Book IDs: $judulBukuFav');
        } else {
          print('No favorite book found for the user with ID: ${user.uid}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada buku terfavorit')),
          );

          Navigator.pop(context);
        }
      } else {
        print('User is not authenticated.');
      }
    } catch (e) {
      print('Error fetching user\'s favorite book: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initData();
  }

  Future<void> _initData() async {
    await _fetchUserFavBook();

    _fetchUserFavBookStreamController.addStream(_fetchUserFavBookStream());
  }

  void _onSearchChanged() {
    setState(() {});
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
                    borderRadius: BorderRadius.circular(10.0)),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.mainColor,
                ),
              ),
            ),
          ),
          title: Text(
            'Koleksi',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchUserFavBookStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada buku',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    );
                  } else {
                    bookList = snapshot.data!.docs;
                    List<DocumentSnapshot> filteredList =
                        bookList.where((document) {
                      var bookData = document.data() as Map<String, dynamic>;
                      var author = bookData['penulis'].toString().toLowerCase();
                      var title = bookData['judul'].toString().toLowerCase();
                      var searchQuery = _searchController.text.toLowerCase();

                      return author.contains(searchQuery) ||
                          title.contains(searchQuery);
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var bookData = filteredList[index].data()
                              as Map<String, dynamic>;
                          bookList.length;
                          var book =
                              bookList[index].data() as Map<String, dynamic>;
                          var author = bookData['penulis'];
                          var coverUrl = bookData['imageUrl'];
                          var titleBook = bookData['judul'];
                          var year = bookData['tahun'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => PinjamBuku(
                                    buku: bookList[index],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      coverUrl,
                                      width: 80,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        titleBook,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            'Penulis: $author\nTahun : $year',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
