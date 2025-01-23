class Berita {
  final int id;
  final String judul;
  final String kategori;
  final String tgl;
  final String deskripsi;
  final String logo;

  const Berita({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.tgl,
    required this.deskripsi,
    required this.logo,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      judul: json['judul'],
      kategori: json['kategori'],
      tgl: json['tgl'],
      deskripsi: json['deskripsi'],
      logo: json['logo'],
    );
  }
}
