import 'package:equatable/equatable.dart';

enum SyncPhase {
  idle,
  fetchingQuestions,
  savingData,
  downloadingImages,
  completed,
  error,
}

class DownloadProgress extends Equatable {
  final SyncPhase phase;
  final String message;

  // API fetch progress
  final int apiTasksCompleted;
  final int apiTasksTotal;

  // Data save progress
  final int dataSaveTasksCompleted;
  final int dataSaveTasksTotal;

  // Image download progress
  final int imagesDownloaded;
  final int imagesTotalCount;
  final int imageDownloadsFailed;

  // Overall progress (0.0 to 1.0)
  final double overallProgress;

  const DownloadProgress({
    this.phase = SyncPhase.idle,
    this.message = '',
    this.apiTasksCompleted = 0,
    this.apiTasksTotal = 0,
    this.dataSaveTasksCompleted = 0,
    this.dataSaveTasksTotal = 0,
    this.imagesDownloaded = 0,
    this.imagesTotalCount = 0,
    this.imageDownloadsFailed = 0,
    this.overallProgress = 0.0,
  });

  String get displayMessage {
    switch (phase) {
      case SyncPhase.fetchingQuestions:
        return 'Fetching questions... ${_percentage(apiTasksCompleted, apiTasksTotal)}';
      case SyncPhase.savingData:
        return 'Preparing content... ${_percentage(dataSaveTasksCompleted, dataSaveTasksTotal)}';
      case SyncPhase.downloadingImages:
        return 'Downloading images $imagesDownloaded/$imagesTotalCount';
      case SyncPhase.completed:
        return 'All content synchronized!';
      case SyncPhase.error:
        return message;
      default:
        return message;
    }
  }

  String _percentage(int completed, int total) {
    if (total == 0) return '0%';
    return '${((completed / total) * 100).toInt()}%';
  }

  DownloadProgress copyWith({
    SyncPhase? phase,
    String? message,
    int? apiTasksCompleted,
    int? apiTasksTotal,
    int? dataSaveTasksCompleted,
    int? dataSaveTasksTotal,
    int? imagesDownloaded,
    int? imagesTotalCount,
    int? imageDownloadsFailed,
    double? overallProgress,
  }) {
    return DownloadProgress(
      phase: phase ?? this.phase,
      message: message ?? this.message,
      apiTasksCompleted: apiTasksCompleted ?? this.apiTasksCompleted,
      apiTasksTotal: apiTasksTotal ?? this.apiTasksTotal,
      dataSaveTasksCompleted: dataSaveTasksCompleted ?? this.dataSaveTasksCompleted,
      dataSaveTasksTotal: dataSaveTasksTotal ?? this.dataSaveTasksTotal,
      imagesDownloaded: imagesDownloaded ?? this.imagesDownloaded,
      imagesTotalCount: imagesTotalCount ?? this.imagesTotalCount,
      imageDownloadsFailed: imageDownloadsFailed ?? this.imageDownloadsFailed,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    message,
    apiTasksCompleted,
    apiTasksTotal,
    dataSaveTasksCompleted,
    dataSaveTasksTotal,
    imagesDownloaded,
    imagesTotalCount,
    imageDownloadsFailed,
    overallProgress,
  ];
}
