import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_perpus/core/assets/assets.gen.dart';
import 'package:mobile_perpus/core/constrant/banner_slider.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/core/constrant/search_field.dart';
import 'package:mobile_perpus/core/constrant/settings_items.dart';
import 'package:mobile_perpus/pages/loginPage/login_page.dart';
import 'package:mobile_perpus/pages/peminjam/all_book.dart';
import 'package:mobile_perpus/pages/peminjam/change_profile_user.dart';
import 'package:mobile_perpus/pages/peminjam/history_peminjaman.dart';
import 'package:mobile_perpus/pages/peminjam/page_semua_koleksi.dart';
import 'package:mobile_perpus/pages/peminjam/page_ulasan_peminjam.dart';
import 'package:mobile_perpus/pages/peminjam/semua_koleksi_buku.dart';
import 'package:mobile_perpus/pages/peminjam/user_book_pinjam.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fullName = '';
  String email = '';

  StreamSubscription<QuerySnapshot>? _favBookSubscription;
  int dendaUser = 0;
  int currentPageIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController searchController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  TextEditingController ratingController = TextEditingController();

  late List<DocumentSnapshot> genreList;
  final List<String> banners1 = [
    Assets.images.perpusbanner.path,
    Assets.images.perpusbanner2.path,
  ];
  final List<String> banners2 = [
    Assets.images.banner2.path,
    Assets.images.banner2.path,
    Assets.images.banner2.path,
  ];
  int jumlahFavBookUser = 0;
  String selectedKategori = '0';

  String selectedDropdownValue = '';
  List<String> dropdownItems = [];

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        userDocRef.snapshots().listen((DocumentSnapshot userSnapshot) {
          if (userSnapshot.exists) {
            setState(() {
              fullName = userSnapshot['namaLengkap'] ?? '';
              email = userSnapshot['email'];
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  showDialogReview() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ulasan Buku'),
          content: SizedBox(
            height: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ulasan'),
                TextField(
                  decoration: const InputDecoration(hintText: 'Ulasan'),
                  keyboardType: TextInputType.text,
                  controller: reviewController,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Rating'),
                TextField(
                  decoration:
                      const InputDecoration(hintText: 'Rating Maksimal 9'),
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  controller: ratingController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: sentReviewBook,
              child: const Text('Kirim'),
            )
          ],
        );
      },
    );
  }

  Future<void> sentReviewBook() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (reviewController.text.isEmpty || ratingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kolom harus diisi semua')),
      );
      return;
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('peminjaman')
              .where('id user', isEqualTo: user?.uid)
              .where('status peminjaman', isEqualTo: 'telah dikembalikan')
              .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ada peminjaman yang telah dikembalikan')),
        );
        return;
      }

      final String idPeminjaman = snapshot.docs.first.id;
      final DocumentSnapshot peminjaman = await FirebaseFirestore.instance
          .collection('peminjaman')
          .doc(idPeminjaman)
          .get();

      final String judulBuku = peminjaman['judul buku dipinjam'];

      // Check if user has already reviewed the book
      final QuerySnapshot<Map<String, dynamic>> existingReviewSnapshot =
          await FirebaseFirestore.instance
              .collection('ulasan')
              .where('userId', isEqualTo: user?.uid)
              .where('judul buku', isEqualTo: judulBuku)
              .get();

      if (existingReviewSnapshot.docs.isNotEmpty) {
        Navigator.pop(context);
        reviewController.clear();
        ratingController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Anda sudah memberikan ulasan untuk buku ini')),
        );
        final CollectionReference<Map<String, dynamic>> updatePeminjaman =
            FirebaseFirestore.instance.collection('peminjaman');

        await updatePeminjaman
            .doc(idPeminjaman)
            .update({'status peminjaman': 'selesai di review'});

        reviewController.clear();
        ratingController.clear();
        return;
      }

      // Proceed with adding review if user hasn't reviewed the book before
      Future.delayed(Duration(seconds: 2), () async {
        await FirebaseFirestore.instance.collection('ulasan').add({
          'userId': user?.uid,
          'judul buku': judulBuku,
          'bukuId': peminjaman['id buku dipinjam'],
          'ulasan': reviewController.text,
          'userName': fullName,
          'rating': ratingController.text,
        });

        // Update status of borrowing to 'selesai di review'
        final CollectionReference<Map<String, dynamic>> updatePeminjaman =
            FirebaseFirestore.instance.collection('peminjaman');

        await updatePeminjaman
            .doc(idPeminjaman)
            .update({'status peminjaman': 'selesai di review'});

        reviewController.clear();
        ratingController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan Berhasil Terkirim')),
        );
        Navigator.pop(context);
      });
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat mengirim ulasan')),
      );
    }
  }

  Future<void> fetchDendaUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        userDocRef.snapshots().listen((DocumentSnapshot userSnapshot) {
          if (userSnapshot.exists) {
            setState(() {
              dendaUser = userSnapshot['denda'] ?? 0;
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchFavUser() async {
    try {
      _listenToFavUserChanges();
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _favBookSubscription?.cancel();
  }

  void _listenToFavUserChanges() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _favBookSubscription = FirebaseFirestore.instance
          .collection('koleksiBuku')
          .where('idUser', isEqualTo: user.uid)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        setState(() {
          jumlahFavBookUser = snapshot.size;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchDendaUser();
    fetchFavUser();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PageFavBook())),
                child: Badge(
                  label: Text(jumlahFavBookUser.toString()),
                  child: const Icon(
                    Icons.favorite,
                    size: 30,
                  ),
                ),
              )),
        ],
      ),
      // backgroundColor: AppColors.whiteColor,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.transparent,
        selectedIndex: currentPageIndex,
        backgroundColor: Colors.white,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Assets.icons.icon1.svg(
              color: AppColors.mainColor,
            ),
            icon: Assets.icons.icon1.svg(),
            label: 'HOME',
          ),
          NavigationDestination(
            selectedIcon: Assets.icons.search.svg(
              color: AppColors.mainColor,
            ),
            icon: Assets.icons.search.svg(),
            label: 'EXPLORE',
          ),
          NavigationDestination(
            selectedIcon: Assets.icons.group723.svg(
              color: AppColors.mainColor,
            ),
            icon: Assets.icons.group723.svg(),
            label: 'BORROW',
          ),
          NavigationDestination(
            selectedIcon: Assets.icons.icon.svg(
              color: AppColors.mainColor,
            ),
            icon: Assets.icons.icon.svg(),
            label: 'ACCOUNT',
          ),
        ],
      ),
      body: <Widget>[
        // HOME PAGE
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Selamat Datang $fullName !',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 60, 57, 57),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BannerSlider(items: banners1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kategori',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const AllKategoriBook()));
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.secontWhiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('kategori')
                          .where('nama')
                          .orderBy(
                            'nama',
                            descending: false,
                          )
                          .limit(4)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var categories = snapshot.data?.docs;

                        return ListView.builder(
                          itemCount: categories?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            var category = categories?[index].data()
                                as Map<String, dynamic>;
                            var namaKategori = category['nama'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AllKategoriBook()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.mainColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20.0, left: 20.0, top: 11),
                                        child: Text(
                                          namaKategori,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Buku',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const PageAllBook()));
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.secontWhiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 190,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('buku')
                          .where('stokBuku')
                          .orderBy('judul', descending: false)
                          .limit(3)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var books = snapshot.data?.docs;

                        return ListView.builder(
                          itemCount: books?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            var book =
                                books?[index].data() as Map<String, dynamic>;
                            var imageUrl = book['imageUrl'] ?? '';
                            var author = book['penulis'];
                            int stokBuku = book['stokBuku'];

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PinjamBuku(
                                      buku: books![index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        width: 100,
                                        height: 145,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: [
                                        Text('$author'),
                                        const SizedBox(
                                          width: 23,
                                        ),
                                        Text(
                                          stokBuku.toString(),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Text(
                    'Rekomendasi Buku',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight - 420,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('buku')
                          .where('stokBuku')
                          .limit(4)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var recommendedBooks = snapshot.data?.docs;

                        recommendedBooks?.shuffle();

                        return SizedBox(
                          height: 190,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: List.generate(
                                recommendedBooks?.length ?? 0,
                                (index) {
                                  var book = recommendedBooks?[index].data()
                                      as Map<String, dynamic>;
                                  var imageUrl = book['imageUrl'] ?? '';
                                  var author =
                                      book['penulis'] ?? 'Unknown Author';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PinjamBuku(
                                            buku: recommendedBooks![index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 80,
                                                  height: 100,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        book['judul'],
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '$author',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Tahun : ' +
                                                                book['tahun'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Explore Page
        SingleChildScrollView(
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
              //   child: TextFieldSearch(
              //     label: 'Search',
              //     suffixIcon: GestureDetector(
              //       onTap: () {
              //         searchController.clear();
              //         setState(() {});
              //       },
              //       child: const Icon(Icons.clear),
              //     ),
              //     controller: searchController,
              //     icon: Assets.icons.search.svg(
              //       color: AppColors.mainColor,
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 35.0,
                      width: MediaQuery.of(context).size.width / 2.3,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.mainColor),
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        color: AppColors.whiteColor,
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('kategori')
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<DropdownMenuItem> kategoriItems = [];
                          if (!snapshot.hasData) {
                            const CircularProgressIndicator();
                          } else {
                            final genres =
                                snapshot.data?.docs.reversed.toList();
                            kategoriItems.add(
                              const DropdownMenuItem(
                                value: '0',
                                child: Text(
                                  'Kategori',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                            for (var genre in genres!) {
                              kategoriItems.add(
                                DropdownMenuItem(
                                  value: genre['nama'],
                                  child: Text(
                                    genre['nama'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                          return DropdownButtonHideUnderline(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: DropdownButton(
                                  value: selectedKategori,
                                  items: kategoriItems,
                                  onChanged: (rakValue) {
                                    setState(() {
                                      selectedKategori = rakValue;
                                    });
                                    print(rakValue);
                                  }),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 500,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: selectedKategori == '0'
                          ? FirebaseFirestore.instance
                              .collection('buku')
                              .where('stokBuku')
                              .orderBy('judul', descending: false)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection('buku')
                              .where('kategori', isEqualTo: selectedKategori)
                              .where('stokBuku')
                              .orderBy('judul', descending: false)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var books = snapshot.data?.docs;

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Menampilkan 3 item per baris
                          ),
                          itemCount: books?.length,
                          itemBuilder: (context, index) {
                            var book =
                                books?[index].data() as Map<String, dynamic>;
                            var imageUrl = book['imageUrl'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PinjamBuku(
                                      buku: books![index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    width: 200,
                                    height: 345,
                                    // Memastikan gambar menutupi ukuran yang diberikan
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //  BORROW PAGE
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextFieldSearch(
                  label: 'Search',
                  suffixIcon: GestureDetector(
                      onTap: () {
                        searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.clear)),
                  controller: searchController,
                  icon: Assets.icons.search.svg(
                    color: AppColors.mainColor,
                  )),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('peminjaman')
                    .where('id user', isEqualTo: user?.uid)
                    .where('status peminjaman', whereIn: [
                  'terkonfirmasi',
                  'belum terkonfirmasi',
                  'telah dikembalikan'
                ]).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var peminjamanList = snapshot.data?.docs;

                    if (peminjamanList == null || peminjamanList.isEmpty) {
                      return const Center(
                        child: Text('Anda belum meminjam buku.'),
                      );
                    }

                    var filteredPeminjamanList =
                        peminjamanList.where((peminjaman) {
                      var judulBukuDipinjam =
                          peminjaman['judul buku dipinjam'] as String;
                      return judulBukuDipinjam
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase());
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredPeminjamanList.length,
                      itemBuilder: (context, index) {
                        var peminjaman = filteredPeminjamanList[index].data()
                            as Map<String, dynamic>;
                        var judulBukuDipinjam =
                            peminjaman['judul buku dipinjam'];
                        var statusPeminjaman = peminjaman['status peminjaman'];

                        var isConfirmed = statusPeminjaman == 'terkonfirmasi';

                        var isLongTitle =
                            judulBukuDipinjam.split(' ').length > 2;

                        return ListTile(
                          title: Text(
                            '${index + 1}. $judulBukuDipinjam',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: () {
                            switch (statusPeminjaman) {
                              case 'telah dikembalikan':
                                return const Text('Selesai',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w700));
                              case 'terkonfirmasi':
                                return const Text('Terkonfirmasi',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w700));
                              default:
                                return const Text('Belum Terkonfirmasi',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700));
                            }
                          }(),
                          onTap: () {
                            print('haha');
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Judul Buku'),
                                  content: SizedBox(
                                    height: 120,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            judulBukuDipinjam,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          () {
                                            switch (statusPeminjaman) {
                                              case 'telah dikembalikan':
                                                return const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Selesai',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                        'Buku telah dikembalikan.'),
                                                  ],
                                                );
                                              case 'terkonfirmasi':
                                                return const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Terkonfirmasi',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                        'Silahkan Pergi Ke Perpustakaan Untuk Menggambil Buku')
                                                  ],
                                                );
                                              default:
                                                return const Text(
                                                  'Belum Terkonfirmasi',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                );
                                            }
                                          }(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    () {
                                      switch (statusPeminjaman) {
                                        case 'telah dikembalikan':
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    showDialogReview();
                                                  },
                                                  child: const Text('Review'))
                                            ],
                                          );

                                        default:
                                          return const Text(
                                            '',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w700),
                                          );
                                      }
                                    }(),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (isLongTitle) {}
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),

        // ACCOUNT PAGE
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Text(
                        'Account',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const UbahProfile()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              child: Icon(
                                Icons.account_circle,
                                size: 90,
                                color: AppColors.twoWhiteColor,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 15,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.mainColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ItemSetting(
                    function: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const HistoryPeminjamanUser()));
                    },
                    icon: const Icon(Icons.history),
                    label: 'History',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ItemSetting(
                    function: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PageFavBook()));
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: 'Koleksi Buku',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ItemSetting(
                    function: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (contex) => const UlasanPeminjam()));
                    },
                    icon: const Icon(Icons.reviews_outlined),
                    label: 'Review Buku',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: AppColors.twoWhiteColor,
                                ),
                                child: const Icon(Icons.attach_money_sharp)),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Denda',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Rp ${dendaUser.toString()}',
                          style: GoogleFonts.inter(
                            color: AppColors.redColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: GestureDetector(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  child: Icon(
                                Icons.logout,
                                color: AppColors.redColor,
                              )),
                              const SizedBox(
                                width: 32,
                              ),
                              Text(
                                'Logout',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.redColor,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios_sharp,
                            size: 15,
                            color: AppColors.redColor,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ][currentPageIndex],
    );
  }
}
