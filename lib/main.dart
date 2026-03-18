import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ibjnyfvihtdbpdtieegr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imliam55ZnZpaHRkYnBkdGllZWdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3NDMzNjcsImV4cCI6MjA4OTMxOTM2N30.amGCaTwPwqiKEdHXL9I7GBPWB1ESC-wuj4OK8GGbZyE',
  );

  await di.init();
  runApp(const App());
}