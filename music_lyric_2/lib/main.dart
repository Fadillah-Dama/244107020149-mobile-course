import 'package:flutter/material.dart';

import 'Lagu.dart';
import 'pages/structural.dart';
import 'pages/input_form.dart';
import 'pages/feedback_widgets.dart';
import 'pages/animation_widgets.dart';

void main() {
  runApp(const Dama());
}

class Dama extends StatelessWidget {
  
  const Dama ({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Lirik Lagu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {

    Lagu lirik1 = Lagu(judul: 'Total Eclipse of the Heart', penyanyi: 'Bonnie Tyler', lirik:
    '''
      Turn around, every now and the I get a little bit lonely and you're never coming round
    ''');

    return Scaffold(
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
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ],

        ),
        drawer: Drawer(
          child: Builder(
            builder: (context) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 0, 128),
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Structural & App Widgets'),
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StructuralPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Input Form'),
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InputFormPage(),
                      ),
                    );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Feedback Widgets'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackWidgetsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.animation),
                    title: const Text('Animation Widgets'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnimationWidgetsPage(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        body: 
          SafeArea(
            child:
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

                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Penyanyi: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: lirik1.penyanyi,
                                style: const TextStyle(
                                  color: Colors.yellow,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Lirik:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
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
                                      child: SelectableText(
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
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Song Options',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ListTile(
                            leading: const Icon(Icons.play_arrow),
                            title: const Text('Play Song'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.favorite),
                            title: const Text('Add to Favorites'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
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
    );
  }
}
