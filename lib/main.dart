import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/item.dart';
void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),
      home:HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.text = "";
    });
    save();
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
    save();
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null ) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((value) => Item.fromJson(value)).toList(); 
      setState(() {
        widget.items = result;
      });
    }
  }

  _HomePageState() {
    load();
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
         
          ),
          decoration: InputDecoration(
            icon: Icon(Icons.list, color: Colors.white,),
            labelText: "Nova tarefa",
            labelStyle: TextStyle(
            color: Colors.white
          )
         )
        )
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final item = widget.items[index];
          return Dismissible(
          onDismissed: (direction) {
              remove(index);
          },
          background: Container(
            color: Colors.deepPurple.withOpacity(0.7),
            child: Row(
              children: <Widget>[
                Icon(Icons.delete, color: Colors.white,),
                Text("Deletar", style: TextStyle(color: Colors.white),)
              ],
            ),
          ) ,
          key: Key(item.title),
          child: CheckboxListTile(
            title: Text(item.title),
            value: item.done,
            onChanged: (value) {
              setState(() {
                item.done = value;
                save();
              });
            },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}