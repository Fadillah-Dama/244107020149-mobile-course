import 'package:flutter/material.dart';
import 'Mahasiswa.dart';
import 'Lirik.dart';

void main() {
  runApp(const Dama());
}

class Dama extends StatelessWidget {
  const Dama ({super.key});

  @override
  Widget build(BuildContext context) {
    Mahasiswa mahasiswa1 = Mahasiswa(nama: 'Fadillah Dama', nim: '123456789', jurusan: 'Teknik Informatika');
    Lirik lirik1 = Lirik(judul: 'Total Eclipse of the Heart', penyanyi: 'Bonnie Tyler',lirik:'blalalala');

    return MaterialApp(
      title: 'Lirik Lagu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lirik Lagu', style: TextStyle(color: Colors.white)),
          shape: const Border (bottom: BorderSide(color: Colors.grey, width: 1)),
          backgroundColor: const Color.fromARGB(255, 0, 0, 128),
        ),
        body: Center(
          child:
          Container(
            width: 350,
            height: 400,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 128),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                "Turn around, every now and then I get a little bit lonely\nAnd you're never coming around\nTurn around, every now and then I get a little bit tired\nOf listening to the sound of my tears\nTurn around, every now and then I get a little bit nervous\nThat the best of all the years have gone by\nTurn around, every now and then I get a little bit terrified\nAnd then I see the look in your eyes\nTurn around bright eyes, every now and then I fall apart\nTurn around bright eyes, every now and then I fall apart",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
        
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {

              },
              child: const Icon(Icons.play_arrow),
            ),
            SizedBox(width: 20),
            FloatingActionButton(
              onPressed: () {

              },
              child: const Icon(Icons.pause),
            ),
            SizedBox(width: 20),
            FloatingActionButton(
              onPressed: () {

              },
              child: const Icon(Icons.stop),
            ),
            SizedBox(width: 20),
            FloatingActionButton(
              onPressed: () {

              },
              child: const Icon(Icons.skip_next),
            ),
          ]
        )      
      )
    );
  }
}


// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
