import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'berita.dart';
import 'detail_berita.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  static const String URL = 'http://192.168.1.2/API-Berita';
  late Future<List<Berita>> result_data;
  List<Berita> beritaList = [];
  List<Berita> filteredBeritaList = [];

  @override
  void initState() {
    super.initState();
    result_data = _fetchBerita();
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

      filteredBeritaList = beritaList.where((berita) {
        return berita.kategori == widget.category;
      }).toList();

      return filteredBeritaList;
    } else {
      throw Exception('Failed to load data from API');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 19, 68, 141),
        title: Text('Berita ${widget.category}'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Berita>>(
        future: result_data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildBeritaList(snapshot.data!),
                ],
              ),
            );
          }
          return Center(child: Text("No data available"));
        },
      ),
    );
  }
}
