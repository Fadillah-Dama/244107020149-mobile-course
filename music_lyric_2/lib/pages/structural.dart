import 'package:flutter/material.dart';

class StructuralPage extends StatefulWidget {
  const StructuralPage({super.key});

  @override
  State<StructuralPage> createState() => _StructuralPageState();
}

class _StructuralPageState extends State<StructuralPage> {
  // Data for ReorderableListView
  List<String> reorderItems = [
    'Song 1',
    'Song 2',
    'Song 3',
    'Song 4',
  ];

  // Controller for Scrollbar
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Structural & App Widgets'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    'assets/images/bonnie_tyler.jpg',
                  ),
                ),

                SizedBox(width: 20),

                Text(
                  'Bonnie Tyler',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              '1. ListView',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 200,

              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Total Eclipse of the Heart'),
                      subtitle: Text('Bonnie Tyler'),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Song 2'),
                      subtitle: Text('Artist 2'),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Song 3'),
                      subtitle: Text('Artist 3'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              '2. GridView',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 10,
              mainAxisSpacing: 10,

              children: const [
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text('CircleAvatar'),
                    ],
                  ),
                ),

                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text('Card'),
                    ],
                  ),
                ),

                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.grid_view,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text('GridView'),
                    ],
                  ),
                ),

                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text('Popup Menu'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              '3. PageView',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Swipe left or right:',
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 180,

              child: PageView(
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: const Center(
                      child: Text(
                        'Page 1',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: const Center(
                      child: Text(
                        'Page 2',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: const Center(
                      child: Text(
                        'Page 3',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              '4. Wrap',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Widgets automatically move to the next line:',
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Play'),
                ),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Pause'),
                ),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Stop'),
                ),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Next'),
                ),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Favorite'),
                ),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Share'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              '5. CustomScrollView',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Example using SliverList:',
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 220,

              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      color: Colors.blue.shade100,

                      child: const Text(
                        'Custom Scroll Header',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate(
                      const [
                        ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text('Custom Item 1'),
                        ),

                        ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text('Custom Item 2'),
                        ),

                        ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text('Custom Item 3'),
                        ),

                        ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text('Custom Item 4'),
                        ),

                        ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text('Custom Item 5'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              '6. ReorderableListView',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Hold and drag an item to change its position:',
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 250,

              child: ReorderableListView(
                children: [
                  for (int index = 0;
                      index < reorderItems.length;
                      index++)
                    Card(
                      key: ValueKey(reorderItems[index]),

                      child: ListTile(
                        leading: const Icon(
                          Icons.drag_handle,
                        ),

                        title: Text(
                          reorderItems[index],
                        ),

                        trailing: const Icon(
                          Icons.menu,
                        ),
                      ),
                    ),
                ],

                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    final String item =
                        reorderItems.removeAt(oldIndex);

                    reorderItems.insert(
                      newIndex,
                      item,
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              '7. Scrollbar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Scroll the list and see the scrollbar on the right:',
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 200,

              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,

                child: ListView(
                  controller: scrollController,

                  children: const [
                    ListTile(
                      title: Text('Scrollbar Item 1'),
                    ),

                    ListTile(
                      title: Text('Scrollbar Item 2'),
                    ),

                    ListTile(
                      title: Text('Scrollbar Item 3'),
                    ),

                    ListTile(
                      title: Text('Scrollbar Item 4'),
                    ),

                    ListTile(
                      title: Text('Scrollbar Item 5'),
                    ),

                    ListTile(
                      title: Text('Scrollbar Item 6'),
                    ),

                    ListTile(
                      title: Text('Scrollbar Item 7'),
                    ),

                    ListTile(
                      title: Text('Scrollbar Item 8'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.blue.shade50,

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      size: 35,
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        'This entire page is inside a '
                        'SingleChildScrollView, so the whole page '
                        'can be scrolled vertically.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}