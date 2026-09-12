import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveActiveSession(int? id) async {
    final p = await SharedPreferences.getInstance();
    id == null
        ? await p.remove('active_session')
        : await p.setInt('active_session', id);
  }
}
