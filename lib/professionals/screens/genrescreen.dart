import 'package:fans_arena/professionals/components/customelevatedbutton.dart';
import 'package:flutter/material.dart';
class Genre {
  String genre;
  Genre({required this.genre});
}
class Genrescreen extends StatefulWidget {
  final void Function(String) onNextPage;
  const Genrescreen({super.key,required this.onNextPage});

  @override
  State<Genrescreen> createState() => _GenrescreenState();
}

class _GenrescreenState extends State<Genrescreen> {
  bool _showCloseIcon = false;
  List<Genre> genres=[
    Genre(genre: 'Football'
    ),
    Genre(genre: 'Tennis'
    ),
    Genre(genre: 'Basketball'
    ),
    Genre(genre: 'Handball'
    ),
    Genre(genre: 'Rugby'
    ),
    Genre(genre: 'Horse racing'
    ),
    Genre(genre: 'Cricket'
    ),
    Genre(genre: 'Polo'
    ),
    Genre(genre: 'Boxing'
    ),
    Genre(genre: 'Rally'
    ),
    Genre(genre: 'Golf'
    ),
    Genre(genre: 'Formula one'
    ),
    Genre(genre: 'Baseball'
    ),
    Genre(genre: 'Cycling'
    ),
    Genre(genre: 'Hockey'
    ),
    Genre(genre: 'Motorsport'
    ),
    Genre(genre: 'Netball'
    ),
    Genre(genre: 'Chess'
    ),
    Genre(genre: 'Volleyball'
    ),
    Genre(genre: 'Swimming'
    ),
    Genre(genre: 'Badminton'
    ),
    Genre(genre: 'Wrestling'
    ),
    Genre(genre: 'NFL'
    ),
    Genre(genre: 'Marathon'
    ),
    Genre(genre: 'Gaming'
    ),
    Genre(genre: 'Javelin'
    ),
    Genre(genre: 'High Jump'
    ),
    Genre(genre: 'Long Jump'
    ),
    Genre(genre: 'Dancing'
    ),
    Genre(genre: 'Body Building'
    ),
    Genre(genre: 'NBA'
    ),
  ];
  TextEditingController genre= TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: true,
        initialChildSize: 0.85,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, pController) =>ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close,color: Colors.black,size: 26,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width*0.65,
                    child: TextFormField(
                      textAlign: TextAlign.justify,
                      textAlignVertical: TextAlignVertical.bottom,
                      controller: genre,
                      onChanged: (value) {
                        setState(() {
                          _showCloseIcon = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800],
                          fontSize: 20, fontWeight: FontWeight.normal,),
                        fillColor: Colors.white70,
                        suffixIcon: _showCloseIcon ? IconButton(
                          icon: const Icon(Icons.close,color: Colors.black,),
                          onPressed: () {
                            setState(() {
                              genre.clear();
                              _showCloseIcon = false;
                            });
                          },
                        ) : null,
                        hintText: 'Search', // Add this line
                      ),
                    ),
                  ),
                  const SizedBox(width: 14, height: 40),
                  ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.white70),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: (){
                      widget.onNextPage(genre.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add',style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),
            )
          ],
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: genres.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 24/9
              ),
              itemBuilder: (context, index) {
                return CustomElevatedButton(
                  buttonText: genres[index].genre,
                  onPressed: () {
                    setState(() {
                      genre.text=genres[index].genre;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    ));
  }
}
