import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/grocery_bloc.dart';
import 'models/grocery_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroceryBloc(),
      child: MaterialApp(
        title: 'Grocery List App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[100],
          fontFamily: 'Roboto',
        ),
        home: GroceryListScreen(),
      ),
    );
  }
}

class GroceryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'My Grocery List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          BlocBuilder<GroceryBloc, GroceryState>(
            builder: (context, state) {
              return state.items.isEmpty
                  ? Center(
                      child: Text(
                        'Your grocery list is empty!',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 20, bottom: 100),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            title: Text(
                              item.name,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editItem(context, item),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    context.read<GroceryBloc>().add(RemoveGroceryItem(item.id));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            },
          ),
          Positioned(
            right: 30,
            bottom: 30,
            child: GestureDetector(
              onTap: () => _addItem(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String newItemName = '';
        return AlertDialog(
          title: Text('Add Grocery Item'),
          content: TextField(
            onChanged: (value) => newItemName = value,
            decoration: InputDecoration(
              hintText: 'Enter item name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newItemName.isNotEmpty) {
                  context.read<GroceryBloc>().add(AddGroceryItem(newItemName));
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(BuildContext context, GroceryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String updatedItemName = item.name;
        return AlertDialog(
          title: Text('Edit Grocery Item'),
          content: TextField(
            onChanged: (value) => updatedItemName = value,
            decoration: InputDecoration(
              hintText: 'Enter new item name',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: item.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (updatedItemName.isNotEmpty) {
                  context.read<GroceryBloc>().add(EditGroceryItem(item.id, updatedItemName));
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}