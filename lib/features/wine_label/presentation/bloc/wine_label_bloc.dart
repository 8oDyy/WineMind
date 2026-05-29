import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_wine_label.dart';
import '../../domain/usecases/analyze_wine_label.dart';
import '../../domain/usecases/add_wine_to_cellar.dart';
import 'wine_label_event.dart';
import 'wine_label_state.dart';

class WineLabelBloc extends Bloc<WineLabelEvent, WineLabelState> {
  final UploadWineLabel uploadWineLabel;
  final AnalyzeWineLabel analyzeWineLabel;
  final AddWineToCellar addWineToCellar;

  WineLabelBloc({
    required this.uploadWineLabel,
    required this.analyzeWineLabel,
    required this.addWineToCellar,
  }) : super(const WineLabelInitial()) {
    on<UploadLabelPictureEvent>(_onUploadLabelPicture);
    on<AnalyzeLabelEvent>(_onAnalyzeLabel);
    on<AddWineToCellarEvent>(_onAddWineToCellar);
    on<CancelWineAddingEvent>(_onCancelWineAdding);
  }

  Future<void> _onUploadLabelPicture(
    UploadLabelPictureEvent event,
    Emitter<WineLabelState> emit,
  ) async {
    emit(WineLabelLoading());
    
    try {
      final result = await uploadWineLabel(event.userId, event.fileName, event.fileBytes);
      
      result.fold(
        (failure) => emit(WineLabelError(failure.toString())),
        (label) => emit(LabelUploadSuccess(label)),
      );
    } catch (e) {
      emit(WineLabelError('Upload failed: $e'));
    }
  }

  Future<void> _onAnalyzeLabel(
    AnalyzeLabelEvent event,
    Emitter<WineLabelState> emit,
  ) async {
    emit(LabelAnalysisLoading());
    
    try {
      final result = await analyzeWineLabel(event.filePath, event.userId);
      
      result.fold(
        (failure) => emit(WineLabelError(failure.toString())),
        (analysisResult) => emit(LabelAnalysisSuccess(analysisResult)),
      );
    } catch (e) {
      emit(WineLabelError('Analysis failed: $e'));
    }
  }

  Future<void> _onAddWineToCellar(
    AddWineToCellarEvent event,
    Emitter<WineLabelState> emit,
  ) async {
    emit(WineAddingLoading());
    
    try {
      final result = event.isExistingWine
          ? await addWineToCellar.addExistingWine(
              event.userId,
              event.wineId,
              event.stock,
              event.notes,
              event.location,
            )
          : await addWineToCellar.addNewWine(
              event.userId,
              event.wineData!,
              event.stock,
              event.notes,
              event.location,
            );
      
      result.fold(
        (failure) => emit(WineLabelError(failure.toString())),
        (message) => emit(WineAddingSuccess(message)),
      );
    } catch (e) {
      emit(WineLabelError('Add wine failed: $e'));
    }
  }

  Future<void> _onCancelWineAdding(
    CancelWineAddingEvent event,
    Emitter<WineLabelState> emit,
  ) async {
    emit(const WineAddingCancelled());
  }
}
