import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/assets/assets.gen.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/core/constrant/search_field.dart';
import 'package:mobile_perpus/pages/peminjam/all_book_genre.dart';
import 'package:mobile_perpus/pages/peminjam/page_favBook_user.dart';

class AllKoleksiBook extends StatefulWidget {
  const AllKoleksiBook({super.key});

  @override
  State<AllKoleksiBook> createState() => _AllKoleksiBookState();
}

class _AllKoleksiBookState extends State<AllKoleksiBook> {
  TextEditingController searchController = TextEditingController();
  int jumlahFavBookUser = 0;
  String selectedKategori = '0';
  late List<DocumentSnapshot> genreList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MoPer',
          style: GoogleFonts.inter(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFieldSearch(
                      label: 'Search',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          searchController.clear();
                          setState(() {});
                        },
                        child: Icon(Icons.clear),
                      ),
                      controller: searchController,
                      icon: Assets.icons.search.svg(
                        color: AppColors.mainColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('kategori')
                    .orderBy('nama', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    genreList = snapshot.data!.docs;

                    List<DocumentSnapshot> filteredList =
                        genreList.where((document) {
                      var nameKategoriBuku =
                          document.data() as Map<String, dynamic>;
                      var namaKategori =
                          nameKategoriBuku['nama'].toString().toLowerCase();
                      var searchQuery = searchController.text.toLowerCase();

                      return namaKategori.contains(searchQuery);
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var nameKategoriBuku = filteredList[index].data()
                              as Map<String, dynamic>;
                          var namaKategori = nameKategoriBuku['nama'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AllGenreBukuPage(
                                    genreName: namaKategori,
                                  ),
                                ),
                              );
                            },
                            child: SingleChildScrollView(
                              child: ListTile(
                                title: Text(namaKategori),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Tidak ada genre buku',
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
