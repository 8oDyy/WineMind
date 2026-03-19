import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_picture.dart';
import 'dish_picture_event.dart';
import 'dish_picture_state.dart';
import 'package:image_picker/image_picker.dart';

class DishPictureBloc extends Bloc<DishPictureEvent, DishPictureState> {
  final UploadPicture uploadPicture;
  final ImagePicker _imagePicker;

  DishPictureBloc({
    required this.uploadPicture,
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       super(const DishPictureInitial()) {
    on<TakePictureEvent>(_onTakePicture);
    on<UploadPictureEvent>(_onUploadPicture);
  }

  Future<void> _onTakePicture(
    TakePictureEvent event,
    Emitter<DishPictureState> emit,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        emit(PictureTaken(image.path));
        // Auto-upload after taking picture
        add(UploadPictureEvent(
          userId: event.userId,
          fileName: image.name,
          fileBytes: bytes,
        ));
      }
    } catch (e) {
      emit(DishPictureError('Failed to take picture: $e'));
    }
  }

  Future<void> _onUploadPicture(
    UploadPictureEvent event,
    Emitter<DishPictureState> emit,
  ) async {
    emit(DishPictureLoading());
    
    final result = await uploadPicture(event.userId, event.fileName, event.fileBytes);
    
    result.fold(
      (failure) => emit(DishPictureError(failure.toString())),
      (picture) => emit(PictureUploadSuccess(picture)),
    );
  }
}
