/// Global application configuration and medical disclaimers.
class AppConfig {
  static const String appName = 'Cloud IoT Health Monitor';
  static const String version = '1.0.0';
  
  // Default API endpoint
  static String backendUrl = 'http://127.0.0.1:8000/api/v1';

  // Required non-diagnostic disclaimer
  static const String disclaimer = 
      'NON-DIAGNOSTIC PROTOTYPE: This system is a research and engineering decision-support '
      'framework for IoT monitoring. It does not diagnose medical conditions, provide clinical advice, '
      'or replace professional healthcare interpretation.';
}
