import 'package:fans_arena/clubs/components/clubsaccountinfo.dart';
import 'package:fans_arena/clubs/screens/signupscreenc.dart';
import 'package:fans_arena/fans/screens/fansaccountinfo.dart';
import 'package:fans_arena/fans/screens/signupscreenf.dart';
import 'package:fans_arena/professionals/screens/professinalsaccountinfo.dart';
import 'package:fans_arena/professionals/screens/signupscreenp.dart';
import 'package:flutter/material.dart';
class Accountchoice extends StatefulWidget {
  const Accountchoice({super.key});

  @override
  State<Accountchoice> createState() => _AccountchoiceState();
}

class _AccountchoiceState extends State<Accountchoice> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold (
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              const SizedBox(height: 150),
              const Text("Sign Up As",style: TextStyle(fontSize: 25),),
              const SizedBox(height: 50),
              Container(
                height: 50,
                width: 200,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child:
                ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(4),
                    ),
                    child: Text(
                        "Fan".toUpperCase(),
                        style: const TextStyle(fontSize: 14,color: Colors.black)
                    ),
                    onPressed: () {

                      Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> const SignupscreenF1(),
                        ),
                      );
                      //to next page
                    }
                ),
              ),
              SizedBox(height: 40,
                child: TextButton(onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Fansaccountinfo(),
                    ),
                  );
                }, child: const Text('Learn more about Fans'),),
              ),
              Container(
                height: 50,
                width: 200,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child:
                ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(4),
                    ),
                    child: Text(
                        "Club".toUpperCase(),
                        style: const TextStyle(fontSize: 14, color: Colors.black)
                    ),
                    onPressed: () {

                      Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> const SignupscreenC(),
                        ),
                      );
                      //to next page
                    }
                ),
              ),
              SizedBox(height: 40,
                child: TextButton(onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Clubsaccountinfo(),
                    ),
                  );
                }, child: const Text('Learn more about Clubs'),),
              ),
              Container(
                height: 50,
                width: 200,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child:
                ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(4),
                    ),
                    child: Text(
                        "Professional".toUpperCase(),
                        style: const TextStyle(fontSize: 14, color: Colors.black)
                    ),
                    onPressed: () {

                      Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> const SignupP(),
                        ),
                      );
                      //to next page
                    }
                ),
              ),
              SizedBox(height: 40,
                child: TextButton(onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Profesaccountinfo(),
                    ),
                  );
                }, child: const Text('Learn more about Professionals'),),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
