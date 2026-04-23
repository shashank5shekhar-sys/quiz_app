import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseInit {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://supabase.com/dashboard/project/okgybtvfsvsblbkibqun',        // 👈 from Supabase dashboard
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9rZ3lidHZmc3ZzYmxia2licXVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MjMwNjcsImV4cCI6MjA5MjQ5OTA2N30.iSpM13qBaFvC5Ax8rPNgCL9zdKTfKk5VojqN_zQ88xE', // 👈 from Supabase dashboard
      );
    } catch (e) {
      if (kDebugMode) {
        print('Supabase initialization error: $e');
      }
    }
  }
}
