import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/repositories/canvas_repository.dart';

class GetCanvases {
  final CanvasRepository repository;

  GetCanvases(this.repository);

  Stream<List<SharedCanvas>> call({required String pairId}) {
    return repository.getCanvases(pairId: pairId);
  }
}
