import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'berita.dart';
import 'detail_berita.dart';
import 'about_developer.dart';
import 'category_page.dart'; // Import the new page

class BeritaListView extends StatefulWidget {
  const BeritaListView({Key? key}) : super(key: key);

  @override
  BeritaListViewState createState() => BeritaListViewState();
}

class BeritaListViewState extends State<BeritaListView> {
  static const String URL = 'http://192.168.1.2/API-Berita';
  late Future<List<Berita>> result_data;
  List<Berita> beritaList = [];
  List<Berita> filteredBeritaList = [];
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    result_data = _fetchBerita();
    searchController.addListener(_filterBerita);
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  @override
  void dispose() {
    searchController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _filterBerita() {
    setState(() {
      if (_selectedCategory == 'All') {
        filteredBeritaList = beritaList.where((berita) {
          return berita.judul
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
        }).toList();
      } else {
        filteredBeritaList = beritaList.where((berita) {
          return berita.judul
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) &&
              berita.kategori == _selectedCategory;
        }).toList();
      }
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filterBerita();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(category: category),
          ),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AboutDeveloper()),
        );
      }
    });
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Widget _buildBody() {
    if (_selectedIndex == 1) {
      return _buildSearchPage();
    }
    return _buildHomePage();
  }

  Widget _buildHomePage() {
    return FutureBuilder<List<Berita>>(
      future: result_data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          beritaList = snapshot.data!;
          filteredBeritaList = beritaList;
          return RefreshIndicator(
            onRefresh: _pullRefresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategoryList(), // Tambahkan ini untuk menampilkan kategori
                  _buildBeritaList(filteredBeritaList),
                ],
              ),
            ),
          );
        }
        return Center(child: Text("No data available"));
      },
    );
  }

  Future<void> _pullRefresh() async {
    setState(() {
      result_data = _fetchBerita();
    });
  }

  Future<List<Berita>> _fetchBerita() async {
    var uri = Uri.parse('$URL/api/read_berita.php');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List jsonData = jsonResponse['data'];

      List<Berita> beritaList = jsonData.map((berita) {
        return Berita.fromJson(berita);
      }).toList();

      return beritaList;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Widget _buildBannerImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBeritaList(List<Berita> beritaList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.5, // Increase this value if card is still too long
      ),
      itemCount: beritaList.length,
      itemBuilder: (context, index) {
        return _buildBeritaCard(beritaList[index]);
      },
    );
  }

  Widget _buildBeritaCard(Berita berita) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        color: Color(0xFFF2F5F7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return DetailBerita(data: berita);
                },
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  "$URL/image/logo/${berita.logo}",
                  width: double.infinity,
                  height: 150, // Adjust height as needed
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      berita.kategori,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color.fromARGB(255, 100, 98, 98),
                      ),
                    ),
                    Text(
                      berita.judul,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      berita.tgl,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color.fromARGB(255, 100, 98, 98),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    List<String> categories = [
      'All',
      'Ekonomi',
      'Pendidikan',
      'Olahraga',
      'Korupsi'
    ]; // Sesuaikan kategori sesuai dengan kebutuhan Anda
    return Container(
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onCategorySelected(categories[index]),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _selectedCategory == categories[index]
                    ? Color.fromARGB(255, 19, 68, 141)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 19, 68, 141),
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: Text('BeritaApp'),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AboutDeveloper()),
                );
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari berita...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: _buildBeritaList(filteredBeritaList),
          ),
        ),
      ],
    );
  }
}
