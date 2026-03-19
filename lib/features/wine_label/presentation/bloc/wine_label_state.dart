import 'package:equatable/equatable.dart';
import '../../domain/entities/wine_label.dart';
import '../../domain/entities/wine_analysis_result.dart';

abstract class WineLabelState extends Equatable {
  const WineLabelState();
  
  @override
  List<Object?> get props => [];
}

class WineLabelInitial extends WineLabelState {
  const WineLabelInitial();
}

class WineLabelLoading extends WineLabelState {
  const WineLabelLoading();
}

class LabelPictureTaken extends WineLabelState {
  final String imagePath;

  const LabelPictureTaken(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class LabelUploadSuccess extends WineLabelState {
  final WineLabel label;

  const LabelUploadSuccess(this.label);

  @override
  List<Object?> get props => [label];
}

class LabelAnalysisLoading extends WineLabelState {
  const LabelAnalysisLoading();
}

class LabelAnalysisSuccess extends WineLabelState {
  final WineAnalysisResult analysisResult;

  const LabelAnalysisSuccess(this.analysisResult);

  @override
  List<Object?> get props => [analysisResult];
}

class WineAddingLoading extends WineLabelState {
  const WineAddingLoading();
}

class WineAddingSuccess extends WineLabelState {
  final String message;

  const WineAddingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WineAddingCancelled extends WineLabelState {
  const WineAddingCancelled();
}

class WineLabelError extends WineLabelState {
  final String message;

  const WineLabelError(this.message);

  @override
  List<Object?> get props => [message];
}
