import 'dart:io';

import 'package:Tether/domain/alerts/model.dart';
import 'package:Tether/global/libs/hive.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

import './alerts/model.dart';
import './user/model.dart';
import './settings/model.dart';
import './rooms/model.dart';
import './matrix/model.dart';

import './alerts/reducer.dart';
import './rooms/reducer.dart';
import './matrix/reducer.dart';
import './user/reducer.dart';
import './settings/reducer.dart';

import 'package:redux_persist/redux_persist.dart';

// https://matrix.org/docs/api/client-server/#!/User32data/register
class AppState {
  final bool loading;
  final AlertsStore alertsStore;
  final UserStore userStore;
  final MatrixStore matrixStore;
  final SettingsStore settingsStore;
  final RoomStore roomStore;

  AppState(
      {this.loading = true,
      this.alertsStore = const AlertsStore(),
      this.userStore = const UserStore(),
      this.matrixStore = const MatrixStore(),
      this.settingsStore = const SettingsStore(),
      this.roomStore = const RoomStore()});

  // Helper function to emulate { loading: action.loading, ...appState}
  AppState copyWith({bool loading}) => AppState(
        loading: loading ?? this.loading,
        alertsStore: alertsStore ?? this.alertsStore,
        userStore: userStore ?? this.userStore,
        matrixStore: matrixStore ?? this.matrixStore,
        roomStore: roomStore ?? this.roomStore,
        settingsStore: settingsStore ?? this.settingsStore,
      );

  @override
  int get hashCode =>
      loading.hashCode ^
      alertsStore.hashCode ^
      userStore.hashCode ^
      matrixStore.hashCode ^
      roomStore.hashCode ^
      settingsStore.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          loading == other.loading &&
          alertsStore == other.alertsStore &&
          userStore == other.userStore &&
          matrixStore == other.matrixStore &&
          roomStore == other.roomStore &&
          settingsStore == other.settingsStore;

  @override
  String toString() {
    return '{' +
        '\alertsStore: $alertsStore,' +
        '\nuserStore: $userStore,' +
        '\nmatrixStore: $matrixStore, ' +
        '\nroomStore: $roomStore,' +
        '\nsettingsStore: $settingsStore,' +
        '\n}';
  }

  // // Allows conversion FROM json for redux_persist
  static AppState fromJson(dynamic json) {
    return json == null
        ? AppState()
        : AppState(
            loading: json['loading'],
            userStore: UserStore.fromJson(json['userStore']),
            settingsStore: SettingsStore.fromJson(json['settingsStore']));
  }

  // Allows conversion TO json for redux_persist
  dynamic toJson() {
    print('redux persisting ${userStore.toJson()}');
    return {
      'loading': loading,
      'userStore': userStore.toJson(),
      'settingsStore': settingsStore.toJson(),
    };
  }
}

AppState appReducer(AppState state, action) {
  return AppState(
    loading: state.loading,
    alertsStore: alertsReducer(state.alertsStore, action),
    roomStore: chatReducer(state.roomStore, action),
    settingsStore: settingsReducer(state.settingsStore, action),
    userStore: userReducer(state.userStore, action),
    matrixStore: matrixReducer(state.matrixStore, action),
  );
}

Future<Store> initStore() async {
// Create and Export Store
  await initHiveStorage();

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(), // Or use other engines
    serializer:
        JsonSerializer<AppState>(AppState.fromJson), // Or use other serializers
  );

  final initialState = await persistor.load();
  print('INITIAL STATE $initialState');

  final Store<AppState> store = new Store<AppState>(
    appReducer,
    initialState: initialState ?? AppState(),
    middleware: [thunkMiddleware, persistor.createMiddleware()],
  );

  return Future.value(store);
}