import 'package:flutter/material.dart';

import 'Lagu.dart';

void main() {
  runApp(const Dama());
}

class Dama extends StatelessWidget {
  const Dama ({super.key});

  @override
  Widget build(BuildContext context) {
    
    Lagu lirik1 = Lagu(judul: 'Total Eclipse of the Heart', penyanyi: 'Bonnie Tyler', lirik:
    '''
      Turn around, every now and the I get a little bit lonely and you're never coming round

      Turn around, every now and the I get a little bit tired of listening to the sound of my tears

      Turn around, every now and the I get a little bit nervous that the best of all the years have gone by

      Turn around, every now and then I get a little bit terrified and then I see the look in your eyes

      Turn around, bright eyes

      Every now and then I fall apart

      Turn around, bright eyes

      Every now and then I fall apart
      Turn around, every now and then I
      get a little bit restless and I dream of something wild.
      Turn around, every now and then I get a little bit helpless and I'm lying like a child in your arms
      Turn around, every now and then I
      get a little bit angry and I know I've got to get out and cry.
      Turn around, every now and then I get a little bit terrified and then I see the look in your eyes.
      Turn around, bright eyes every now and then I fall apart.
      Turn around, bright eyes every now and then I fall apart.

      And I need you now tonight

      And I need you more than ever

      And if you only hold me tight

      We'll be holding on forever

      And we'll only be making it right

      Cause we'll never be wrong

      Together we can take it to the end of the line

      Your love is like a shadow on me all of the time

      I don't know what to do and I'm always in the dark

      We're living in a powder keg and giving off sparks

      I really need you tonight

      Forever's gonna start tonight

      Forever's gonna start tonight

      Once upon a time I was falling in love

      But now I'm only falling apart

      There's nothing I can do

      A total eclipse of the heart

      Once upon a time there was light in my life

      But now there's only love in the dark

      Nothing I can say

      A total eclipse of the heart
      (Music)
      Turn around, bright eyes
      Turn around, bright eyes
      Turn around, every now and then I know you'll never be the boy you always wanted to be.
      Turn around, every now and then I know you'll always be the only boy who wanted me the way that I am.
      Turn around, every now and then I know there's no one in the universe as magical and wonderful as you.
      Turn around, every now and then I know there's nothing any better, there's nothing that I just wouldn't do.
      Turn around,bright eyes
      Every now and then I fall apart

      Turn around, bright eyes

      Every now and then I fall apart

      And I need you now tonight

      And I need you more than ever

      And if you only hold me tight

      We'll be holding on forever

      And we'll only be making it right

      Cause we'll never be wrong

      Together we can take it to the end of the line

      Your love is like a shadow on me all of the time

      I don't know what to do, I'm always in the dark

      We're living in a powder keg and giving off sparks

      I really need you tonight

      Forever's gonna start tonight

      Forever's gonna start tonight

      Once upon a time I was falling in love

      But now I'm only falling apart

      There's nothing I can do

      A total eclipse of the heart
      Once upon a time there was light in my life but now there's only love in the dark.
      There's nothing I can say
      A total eclipse of the heart
      A total eclipse of the heart
      A total eclipse of the heart
      Turn around, bright eyes
      Turn around, bright eyes
    ''');

    return MaterialApp(
      title: 'Lirik Lagu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.music_note, color: Colors.white, size: 30),
            onPressed: () {
              // Handle back button press
            },
          ),
          title: Text('Lirik Lagu', style: TextStyle(color: Colors.white)),
          shape: const Border (bottom: BorderSide(color: Colors.grey, width: 1)),
          backgroundColor: const Color.fromARGB(255, 0, 0, 128),
        ),
        body: 
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100.0),
            child: 
            Center(
              child:
              Container(
                constraints: const BoxConstraints(
                maxWidth: 340.0,
                ),
                // width: 350,
                // height: 600,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 128),
                  borderRadius: BorderRadius.circular(15),
                ),
                child:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset(
                        'assets/images/bonnie_tyler.jpg',
                        width: 310,
                        height: 310,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lirik1.judul,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Penyanyi: ${lirik1.penyanyi}',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lirik:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Turn around, every now and then I get a little bit lonely\nAnd you're never coming around\nTurn around, every now and then I get a little bit tired\nOf listening to the sound of my tears . . . . . . .",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    
                    Builder(
                    builder: (BuildContext context) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: const Text(
                                    'Lirik Lengkap',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: const Color.fromARGB(255, 0, 0, 128),
                                  iconTheme: const IconThemeData(
                                    color: Colors.white,
                                  ),
                                ),
                                body: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    lirik1.lirik,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerRight,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Lirik Lengkap'),
                      );
                    },
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: 'play',
              backgroundColor: const Color.fromARGB(255, 0, 0, 128),
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              onPressed: () {

              },
              child: const Icon(
                Icons.play_arrow,
                size: 28,
              ),
            ),

            const SizedBox(width: 15),

            FloatingActionButton(
              heroTag: 'pause',
              backgroundColor: const Color.fromARGB(255, 0, 0, 128),
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              onPressed: () {

              },
              child: const Icon(
                Icons.pause,
                size: 28,
              ),
            ),

            const SizedBox(width: 15),

            FloatingActionButton(
              heroTag: 'stop',
              backgroundColor: const Color.fromARGB(255, 0, 0, 128),
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              onPressed: () {

              },
              child: const Icon(
                Icons.stop,
                size: 28,
              ),
            ),

            const SizedBox(width: 15),

            FloatingActionButton(
              heroTag: 'next',
              backgroundColor: const Color.fromARGB(255, 0, 0, 128),
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              onPressed: () {

              },
              child: const Icon(
                Icons.skip_next,
                size: 28,
              ),
            ),
          ],
        ),      
      )
    );
  }
}