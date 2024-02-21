import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PageKategori extends StatefulWidget {
  const PageKategori({Key? key}) : super(key: key);

  @override
  State<PageKategori> createState() => _PageKategoriState();
}

class _PageKategoriState extends State<PageKategori> {
  final TextEditingController _kategoriController = TextEditingController();
  late int _selectedItemIndex;
  late List<DocumentSnapshot> kategoriBukuList;
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
      appBar: AppBar(title: const Text('Kategori Buku')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
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
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('kategori')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    kategoriBukuList = snapshot.data!.docs;

                    List<DocumentSnapshot> filteredList =
                        kategoriBukuList.where((document) {
                      var rakData = document.data() as Map<String, dynamic>;
                      var namaRak = rakData['nama'].toString().toLowerCase();
                      var searchQuery = _searchController.text.toLowerCase();

                      return namaRak.contains(searchQuery);
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var rakData = filteredList[index].data()
                              as Map<String, dynamic>;
                          var namaRak = rakData['nama'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedItemIndex = kategoriBukuList
                                    .indexOf(filteredList[index]);
                              });
                              _showOptionsDialog(context);
                            },
                            child: ListTile(
                              title: Text('${index + 1}. $namaRak'),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Tidak ada kategori buku',
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 60, 57, 57),
        label: const Text(
          'Tambah Kategori',
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
          _showTambahKategoriDialog(context);
        },
      ),
    );
  }

  void _showTambahKategoriDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Buku'),
          content: TextField(
            controller: _kategoriController,
            decoration: const InputDecoration(labelText: 'Nama Kategori Buku'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _tambahKategoriBuku();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _tambahKategoriBuku() async {
    try {
      String namaRak = _kategoriController.text;

      if (namaRak.isNotEmpty) {
        await FirebaseFirestore.instance.collection('kategori').add({
          'nama': namaRak,
        });

        _kategoriController.clear();

        print('Kategori Buku berhasil ditambahkan: $namaRak');
      } else {
        print('Kategori Rak Buku tidak boleh kosong');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilihan'),
          content: const Text('Pilih opsi untuk item terpilih'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editKategoriBuku();
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _hapusKategoriBuku();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _editKategoriBuku() {
    String currentNamaRak = kategoriBukuList[_selectedItemIndex]['nama'];

    TextEditingController _editController =
        TextEditingController(text: currentNamaRak);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Kategori Buku'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori Buku',
              hintText: 'Kategori Baru',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_editController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Kolom tidak boleh kosong!')));
                } else {
                  _simpanEditKategoriBuku(currentNamaRak, _editController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _simpanEditKategoriBuku(
      String currentNamaRak, String editedNamaRak) async {
    try {
      if (currentNamaRak != editedNamaRak) {
        await FirebaseFirestore.instance
            .collection('kategori')
            .doc(kategoriBukuList[_selectedItemIndex].id)
            .update({'nama': editedNamaRak});

        print(
            'Kategori Buku berhasil diedit: $currentNamaRak -> $editedNamaRak');
      } else {
        print('Tidak ada perubahan pada nama Kategori');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _hapusKategoriBuku() async {
    try {
      bool isKategoriTerpakai = await _cekKategoriTerpakai();

      if (isKategoriTerpakai) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori Buku masih terpakai oleh beberapa buku.'),
          ),
        );
      } else {
        FirebaseFirestore.instance
            .collection('kategori')
            .doc(kategoriBukuList[_selectedItemIndex].id)
            .delete();

        print('Kategori Buku berhasil dihapus');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> _cekKategoriTerpakai() async {
    try {
      String namaKategori = kategoriBukuList[_selectedItemIndex]['nama'];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buku')
          .where('kategori', isEqualTo: namaKategori)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
