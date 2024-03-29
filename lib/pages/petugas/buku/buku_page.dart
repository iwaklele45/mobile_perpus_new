import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/pages/petugas/buku/edit_buku.dart';
import 'package:mobile_perpus/pages/petugas/buku/tambah_buku_page.dart';

class PageBuku extends StatefulWidget {
  const PageBuku({super.key});

  @override
  State<PageBuku> createState() => _PageBukuState();
}

class _PageBukuState extends State<PageBuku> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Widget _buildBookList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('buku').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var bukuList = snapshot.data!.docs;

          List<DocumentSnapshot> filteredBukuList = bukuList.where((buku) {
            var judul = buku['judul'].toLowerCase();
            var searchQuery = _searchController.text.toLowerCase();

            return judul.contains(searchQuery);
          }).toList();
          if (filteredBukuList.isEmpty) {
            return const Center(
              child: Text(
                'Tidak Ada Buku',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredBukuList.length,
            itemBuilder: (context, index) {
              var buku = filteredBukuList[index];
              return ListTile(
                onTap: () {
                  _showDetailBukuDialog(context, buku);
                },
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.network(
                      buku['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    buku['judul'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                trailing: Text('Tahun Terbit: ${buku['tahun']}'),
              );
            },
          );
        }
      },
    );
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
            'Data Buku',
            style: GoogleFonts.inter(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          )),
      body: Column(
        children: [
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
                  keyboardType: TextInputType.text,
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
                      child: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(child: _buildBookList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 60, 57, 57),
        label: const Text(
          'Tambah Buku',
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
          Navigator.of(context).push(
              MaterialPageRoute(builder: ((context) => const TambahBuku())));
        },
      ),
    );
  }

  void _showDetailBukuDialog(BuildContext context, DocumentSnapshot buku) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Buku'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.network(
                    buku['imageUrl'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Judul Buku   :',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${buku['judul']}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Kategori   : ',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${buku['kategori']}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Penulis   : ',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${buku['penulis']}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penerbit   : ',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${buku['penerbit']}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Tahun Terbit   : ',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${buku['tahun']}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Stok   : ',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${buku['stokBuku']}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Sinopsis   :',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${buku['sinopsis']}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deleteBuku(buku);
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditBuku(
                              buku: buku,
                            )));
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBuku(DocumentSnapshot buku) async {
    try {
      await FirebaseFirestore.instance.collection('buku').doc(buku.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil di hapus!')));
    } catch (e) {
      print('Error deleting book: $e');
    }
  }
}
