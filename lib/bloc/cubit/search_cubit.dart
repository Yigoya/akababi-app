import 'package:akababi/repositiory/postRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  void search(String query) async {
    emit(SearchLoading());

    final posts = await PostRepo().searchUser(query);
    emit(SearchLoaded(posts));
  }
}
