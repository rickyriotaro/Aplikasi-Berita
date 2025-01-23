import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Import the flutter_html package
import 'berita.dart';

class DetailBerita extends StatelessWidget {
  final Berita data;

  const DetailBerita({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 19, 68, 141),
        title: const Text('Detail Berita'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Make the container transparent
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.judul,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.0),
                Text(
                  data.tgl,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color.fromARGB(255, 83, 84, 85),
                  ),
                ),
                SizedBox(height: 14.0),
                Center(
                  child: Image.network(
                    'http://192.168.1.2/api-berita/image/logo/${data.logo}',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  data.kategori,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color.fromARGB(255, 83, 84, 85),
                  ),
                ),
                SizedBox(height: 0.0),
                Html(
                  data:
                      data.deskripsi, // Use Html widget to display HTML content
                  style: {
                    "p": Style(
                      fontSize: FontSize(18.0),
                      color: Color.fromARGB(255, 0, 0, 0),
                      textAlign: TextAlign.justify, // Justify the text
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
