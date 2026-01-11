class AppConfig {
  /// Whether to use mock data instead of real API calls.
  /// Useful for testing and development without internet or API limits.
  static bool useMockData = false;

  /// Initializes the application configuration.
  /// This is where you would load environment variables or other startup config.
  static Future<void> init() async {
    // For now, we can just log that config is initialized.
    // In a real app, you might load from .env file here.
    // For example:
    // await dotenv.load(fileName: ".env");
    // useMockData = dotenv.get('USE_MOCK_DATA', fallback: 'false') == 'true';
    
    // Default to false for production, but can be toggled manually or via code.
    useMockData = false;
  }
}
