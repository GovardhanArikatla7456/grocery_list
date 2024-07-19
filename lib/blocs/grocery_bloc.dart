import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';

abstract class GroceryEvent {}

class AddGroceryItem extends GroceryEvent {
  final String name;
  AddGroceryItem(this.name);
}

class RemoveGroceryItem extends GroceryEvent {
  final String id;
  RemoveGroceryItem(this.id);
}

class EditGroceryItem extends GroceryEvent {
  final String id;
  final String newName;
  EditGroceryItem(this.id, this.newName);
}

// State
class GroceryState {
  final List<GroceryItem> items;
  GroceryState(this.items);
}

// BLoC
class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {
  GroceryBloc() : super(GroceryState([])) {
    on<AddGroceryItem>(_onAddGroceryItem);
    on<RemoveGroceryItem>(_onRemoveGroceryItem);
    on<EditGroceryItem>(_onEditGroceryItem);
    _loadItems();
  }

  Future<void> _onAddGroceryItem(AddGroceryItem event, Emitter<GroceryState> emit) async {
    final newItem = GroceryItem(id: DateTime.now().toString(), name: event.name);
    final updatedItems = List<GroceryItem>.from(state.items)..add(newItem);
    emit(GroceryState(updatedItems));
    await _saveItems(updatedItems);
  }

  Future<void> _onRemoveGroceryItem(RemoveGroceryItem event, Emitter<GroceryState> emit) async {
    final updatedItems = state.items.where((item) => item.id != event.id).toList();
    emit(GroceryState(updatedItems));
    await _saveItems(updatedItems);
  }

  Future<void> _onEditGroceryItem(EditGroceryItem event, Emitter<GroceryState> emit) async {
    final updatedItems = state.items.map((item) {
      if (item.id == event.id) {
        return GroceryItem(id: item.id, name: event.newName);
      }
      return item;
    }).toList();
    emit(GroceryState(updatedItems));
    await _saveItems(updatedItems);
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString('grocery_items');
    if (itemsJson != null) {
      final List<dynamic> decodedItems = jsonDecode(itemsJson);
      final items = decodedItems.map((item) => GroceryItem.fromJson(item)).toList();
      emit(GroceryState(items));
    }
  }

  Future<void> _saveItems(List<GroceryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString('grocery_items', itemsJson);
  }
}