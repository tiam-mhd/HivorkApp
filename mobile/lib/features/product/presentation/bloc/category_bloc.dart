import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_category.dart';
import '../../data/services/category_api_service.dart';

// Events
abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final String businessId;
  final bool flatList;
  
  LoadCategories(this.businessId, {this.flatList = false});
}

class CreateCategory extends CategoryEvent {
  final Map<String, dynamic> categoryData;
  
  CreateCategory(this.categoryData);
}

class UpdateCategory extends CategoryEvent {
  final String id;
  final String businessId;
  final Map<String, dynamic> categoryData;
  
  UpdateCategory(this.id, this.businessId, this.categoryData);
}

class DeleteCategory extends CategoryEvent {
  final String id;
  final String businessId;
  
  DeleteCategory(this.id, this.businessId);
}

class MoveCategory extends CategoryEvent {
  final String id;
  final String businessId;
  final String? parentId;
  
  MoveCategory(this.id, this.businessId, this.parentId);
}

// States
abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<ProductCategory> categories;
  final bool isFlatList;
  
  CategoryLoaded(this.categories, {this.isFlatList = false});
}

class CategoryError extends CategoryState {
  final String message;
  
  CategoryError(this.message);
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  
  CategoryOperationSuccess(this.message);
}

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryApiService apiService;
  
  CategoryBloc(this.apiService) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<MoveCategory>(_onMoveCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = event.flatList
          ? await apiService.getCategoriesFlat(event.businessId)
          : await apiService.getCategories(event.businessId);
      emit(CategoryLoaded(categories, isFlatList: event.flatList));
    } catch (e) {
      emit(CategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateCategory(CreateCategory event, Emitter<CategoryState> emit) async {
    try {
      await apiService.createCategory(event.categoryData);
      emit(CategoryOperationSuccess('دسته‌بندی با موفقیت ایجاد شد'));
    } catch (e) {
      emit(CategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await apiService.updateCategory(event.id, event.businessId, event.categoryData);
      emit(CategoryOperationSuccess('دسته‌بندی با موفقیت ویرایش شد'));
    } catch (e) {
      emit(CategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await apiService.deleteCategory(event.id, event.businessId);
      emit(CategoryOperationSuccess('دسته‌بندی با موفقیت حذف شد'));
    } catch (e) {
      emit(CategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMoveCategory(MoveCategory event, Emitter<CategoryState> emit) async {
    try {
      await apiService.moveCategory(event.id, event.businessId, event.parentId);
      emit(CategoryOperationSuccess('دسته‌بندی با موفقیت جابجا شد'));
    } catch (e) {
      emit(CategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
