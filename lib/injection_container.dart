import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/create_pair.dart';
import 'features/auth/domain/usecases/join_pair.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/timer/data/repositories/timer_repository_impl.dart';
import 'features/timer/domain/repositories/timer_repository.dart';
import 'features/timer/domain/usecases/start_session.dart';
import 'features/timer/domain/usecases/end_session.dart';
import 'features/timer/presentation/bloc/timer_bloc.dart';

import 'features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'features/tasks/data/repositories/tasks_repository_impl.dart';
import 'features/tasks/domain/repositories/tasks_repository.dart';
import 'features/tasks/domain/usecases/get_tasks.dart';
import 'features/tasks/domain/usecases/add_task.dart';
import 'features/tasks/domain/usecases/update_task.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/presentation/bloc/tasks_bloc.dart';

import 'features/timeline/data/datasources/timeline_remote_datasource.dart';
import 'features/timeline/data/repositories/timeline_repository_impl.dart';
import 'features/timeline/domain/repositories/timeline_repository.dart';
import 'features/timeline/presentation/bloc/timeline_bloc.dart';

import 'features/quotes/data/datasources/quotes_remote_datasource.dart';
import 'features/quotes/data/repositories/quotes_repository_impl.dart';
import 'features/quotes/domain/repositories/quotes_repository.dart';
import 'features/quotes/domain/usecases/get_daily_quote.dart';
import 'features/quotes/presentation/bloc/quotes_bloc.dart';

import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'features/canvas/data/datasources/canvas_remote_datasource.dart';
import 'features/canvas/data/repositories/canvas_repository_impl.dart';
import 'features/canvas/domain/repositories/canvas_repository.dart';
import 'features/canvas/domain/usecases/get_canvases.dart';
import 'features/canvas/domain/usecases/create_canvas.dart';
import 'features/canvas/domain/usecases/delete_canvas.dart';
import 'features/canvas/domain/usecases/add_stroke.dart';
import 'features/canvas/domain/usecases/undo_stroke.dart';
import 'features/canvas/presentation/bloc/canvas_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn(
        clientId: Platform.isIOS
            ? '361376502244-lsajhr4l57o0iq04bagr9ic7mq9ovtb4.apps.googleusercontent.com'
            : null,
      ));

  // Auth
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => CreatePair(sl()));
  sl.registerLazySingleton(() => JoinPair(sl()));
  sl.registerFactory(() => AuthBloc(
        signInWithGoogle: sl(),
        signOut: sl(),
        getCurrentUser: sl(),
        createPair: sl(),
        joinPair: sl(),
      ));

  // Timer
  sl.registerLazySingleton<TimerRepository>(
    () => TimerRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton(() => StartSession(sl()));
  sl.registerLazySingleton(() => EndSession(sl()));
  sl.registerFactory(() => TimerBloc(
        startSession: sl(),
        endSession: sl(),
      ));

  // Tasks
  sl.registerLazySingleton<TasksRemoteDatasource>(
    () => TasksRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerFactory(() => TasksBloc(
        getTasks: sl(),
        addTask: sl(),
        updateTask: sl(),
        deleteTask: sl(),
      ));

  // Timeline
  sl.registerLazySingleton<TimelineRemoteDatasource>(
    () => TimelineRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<TimelineRepository>(
    () => TimelineRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerFactory(() => TimelineBloc(repository: sl()));

  // Quotes
  sl.registerLazySingleton<QuotesRemoteDatasource>(
    () => QuotesRemoteDatasourceImpl(preferences: sl()),
  );
  sl.registerLazySingleton<QuotesRepository>(
    () => QuotesRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton(() => GetDailyQuote(sl()));
  sl.registerFactory(() => QuotesBloc(getDailyQuote: sl()));

  // Settings
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(preferences: sl()),
  );
  sl.registerFactory(() => SettingsBloc(repository: sl()));

  // Canvas
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton<CanvasRemoteDatasource>(
    () => CanvasRemoteDatasourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );
  sl.registerLazySingleton<CanvasRepository>(
    () => CanvasRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton(() => GetCanvases(sl()));
  sl.registerLazySingleton(() => CreateCanvas(sl()));
  sl.registerLazySingleton(() => DeleteCanvas(sl()));
  sl.registerLazySingleton(() => AddStroke(sl()));
  sl.registerLazySingleton(() => UndoStroke(sl()));
  sl.registerFactory(() => CanvasBloc(
        getCanvases: sl(),
        createCanvas: sl(),
        deleteCanvas: sl(),
      ));
}
