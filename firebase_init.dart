import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseInit {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'YOUR_SUPABASE_URL',        // 👈 from Supabase dashboard
        anonKey: 'YOUR_SUPABASE_ANON_KEY', // 👈 from Supabase dashboard
      );
    } catch (e) {
      if (kDebugMode) {
        print('Supabase initialization error: $e');
      }
    }
  }
}
