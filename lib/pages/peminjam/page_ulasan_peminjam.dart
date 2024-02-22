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
  late List<DocumentSnapshot> bookList;
  final TextEditingController _searchController = TextEditingController();

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
                    .collection('buku')
                    .orderBy('judul', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
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
                              Navigator.of(context).push(
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
                                      title: Text(titleBook),
                                      subtitle: Text(
                                        'Penulis: $author\nTahun : $year',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
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
