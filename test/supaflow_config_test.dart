import 'package:flutter_test/flutter_test.dart';
import 'package:i_m_f_s_l_staff/backend/supabase/supabase.dart';

/// Tests for SupaFlow configuration.
///
/// These verify that the Supabase configuration is correctly set up
/// without requiring an actual connection.
void main() {
  group('SupaFlow configuration', () {
    test('supabaseUrl is a valid HTTPS URL', () {
      final url = SupaFlow.supabaseUrl;
      expect(url, isNotNull);
      expect(url, isNotEmpty);
      expect(url, startsWith('https://'));
    });

    test('supabaseUrl points to expected domain', () {
      expect(SupaFlow.supabaseUrl, contains('admin-imarishamaisha.co.tz'));
    });

    test('singleton instance is consistent', () {
      final a = SupaFlow.instance;
      final b = SupaFlow.instance;
      expect(identical(a, b), true);
    });
  });
}
