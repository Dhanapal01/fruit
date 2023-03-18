import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDjddxk68be74UcKhb_Ey8y_L32mL9e5aU",
          authDomain: "employee-management-9a784.firebaseapp.com",
          projectId: "employee-management-9a784",
          storageBucket: "employee-management-9a784.appspot.com",
          messagingSenderId: "167429286442",
          appId: "1:167429286442:web:8f2b90d69d5c712df13153",
          measurementId: "G-CPF4DS9T78"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kindacode.com',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _pricecontroller = TextEditingController();

  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');
  // ignore: unused_element
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _namecontroller.text = documentSnapshot['name'];
      _pricecontroller.text = documentSnapshot['price'].toString();
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _namecontroller,
                decoration: const InputDecoration(labelText: 'name'),
              ),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _pricecontroller,
                decoration: const InputDecoration(labelText: 'price'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  final String? name = _namecontroller.text;
                  final double? price = double.tryParse(_pricecontroller.text);
                  if (name != null && price != null) {
                    if (action == 'create') {
                      await _products.add({"name": name, "price": price});
                    }
                    if (action == 'update') {
                      await _products
                          .doc(documentSnapshot!.id)
                          .update({"name": name, "price": price});
                    }
                    _namecontroller.text = '';
                    _pricecontroller.text = '';
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("your product created successfully")));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("your product created successfully")));
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteproduct(String productid) async {
    await _products.doc(productid).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("you have succesfully deleted product")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('kindacode.com'),
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot),
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: (() =>
                                  _deleteproduct(documentSnapshot.id)),
                              icon: Icon(Icons.delete)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => _createOrUpdate()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
