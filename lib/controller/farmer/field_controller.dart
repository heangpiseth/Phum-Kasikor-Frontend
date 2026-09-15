import 'package:get/get.dart';

class FieldController extends GetxController {
  final fields = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> fetchFields() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> addField(Map<String, dynamic> field) async {
    fields.add(field);
  }

  Future<void> updateField(int index, Map<String, dynamic> field) async {
    if (index >= 0 && index < fields.length) {
      fields[index] = field;
    }
  }

  Future<void> deleteField(int index) async {
    if (index >= 0 && index < fields.length) {
      fields.removeAt(index);
    }
  }
}