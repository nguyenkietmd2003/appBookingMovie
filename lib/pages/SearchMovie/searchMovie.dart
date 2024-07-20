import 'package:flutter/material.dart';
import 'package:movie/api_service.dart';
import 'package:movie/pages/detailPage/detailPage.dart';
import 'package:movie/pages/selectSeat/test.dart';

class SearchMoviePage extends StatefulWidget {
  const SearchMoviePage({super.key});

  @override
  State<SearchMoviePage> createState() => _SearchMoviePageState();
}

class Movie {
  late String maPhim;
  late String title;
  late String image;
  late String description;
  late String duration;

  Movie({
    required this.maPhim,
    required this.title,
    required this.image,
    required this.description,
    required this.duration,
  });
}

class _SearchMoviePageState extends State<SearchMoviePage> {
  dynamic apiResultDanhSachPhim;
  final ApiService apiService =
      ApiService(baseUrl: 'https://movienew.cybersoft.edu.vn');
  List<Movie> movies = [];
  List<String> movieTitles = [];
  bool isLoading = true; // Add a loading state variable
  String? selectedMaPhim; // Store the selected movie's maPhim

  @override
  void initState() {
    super.initState();
    fetchDanhSachphim();
  }

  Future<void> fetchDanhSachphim() async {
    try {
      final result = await apiService.getRequest(
        '/api/QuanLyPhim/LayDanhSachPhim?maNhom=GP03',
        {
          'Content-Type': 'application/json',
          'TokenCybersoft':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZW5Mb3AiOiJCb290Y2FtcCA2NCIsIkhldEhhblN0cmluZyI6IjA4LzA5LzIwMjQiLCJIZXRIYW5UaW1UaW1lIjoiMTcyNTc1MzYwMDAwMCIsIm5iZiI6MTY5NTkyMDQwMCwiZXhwIjoxNzI1OTAxMjAwfQ.fWIHiHRVx9B7UlCgFCwvvXAlcVc-I-RB603rEDsM_wI',
        },
      );

      setState(() {
        apiResultDanhSachPhim = result;
        movies = (result['content'] as List)
            .map((movie) => Movie(
                  maPhim: movie['maPhim'].toString(),
                  title: movie['tenPhim'] ?? 'No Title',
                  image: movie['hinhAnh'] ?? '',
                  description: movie['moTa'] ?? 'No Description',
                  duration:
                      movie['thoiLuong']?.toString() ?? 'Unknown Duration',
                ))
            .toList();

        movieTitles = movies.map((movie) => movie.title).toList();
        isLoading = false; // Update loading state
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Update loading state in case of error
      });
    }
  }

  String removeDiacritics(String str) {
    final diacriticsMap = {
      'a': 'áàảãạăắằẳẵặâấầẩẫậ',
      'e': 'éèẻẽẹêếềểễệ',
      'i': 'íìỉĩị',
      'o': 'óòỏõọôốồổỗộơớờởỡợ',
      'u': 'úùủũụưứừửữự',
      'y': 'ýỳỷỹỵ',
      'd': 'đ',
      'A': 'ÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬ',
      'E': 'ÉÈẺẼẸÊẾỀỂỄỆ',
      'I': 'ÍÌỈĨỊ',
      'O': 'ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ',
      'U': 'ÚÙỦŨỤƯỨỪỬỮỰ',
      'Y': 'ÝỲỶỸỴ',
      'D': 'Đ',
    };
    diacriticsMap.forEach((key, value) {
      for (int i = 0; i < value.length; i++) {
        str = str.replaceAll(value[i], key);
      }
    });
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      home: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Tìm kiếm phim',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.black,
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Show loading indicator
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              }
                              String query = removeDiacritics(
                                  textEditingValue.text.toLowerCase());
                              return movieTitles.where((String option) {
                                String normalizedOption =
                                    removeDiacritics(option.toLowerCase());
                                return normalizedOption.contains(query);
                              });
                            },
                            onSelected: (String selection) {
                              final selectedMovie = movies.firstWhere(
                                  (movie) => movie.title == selection);
                              setState(() {
                                selectedMaPhim = selectedMovie.maPhim;
                              });
                              print('You just selected $selection');
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController
                                    fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              return TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  hintText: 'Nhập tên phim...',
                                  hintStyle:
                                      const TextStyle(color: Colors.white70),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                              );
                            },
                            optionsViewBuilder: (BuildContext context,
                                AutocompleteOnSelected<String> onSelected,
                                Iterable<String> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    color: Colors.black,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final String option =
                                            options.elementAt(index);
                                        return InkWell(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              option,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
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
                          const SizedBox(height: 20),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedMaPhim != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailPage(
                                    id: selectedMaPhim!,
                                  ),
                                ),
                              );
                            } else {
                              // Show a message to select a movie first
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Vui lòng chọn một bộ phim trước'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Xem Chi Tiết',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}