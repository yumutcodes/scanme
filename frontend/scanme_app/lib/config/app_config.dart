/// Defines where the product data should be fetched from when online.
enum ScanningSource {
  backend,
  openFoodFacts,
}

class AppConfig {
  /// Whether to use mock data instead of real API calls.
  /// Useful for testing and development without internet or API limits.
  static bool useMockData = false;

  /// Configuration for the scanning source.
  /// Controls whether to use the self-hosted backend or the public OpenFoodFacts API.
  static ScanningSource scanningSource = ScanningSource.backend;

  /// Initializes the application configuration.
  /// This is where you would load environment variables or other startup config.
  static Future<void> init() async {
    // For now, we can just log that config is initialized.
    // In a real app, you might load from .env file here.
    // For example:
    // await dotenv.load(fileName: ".env");
    
    // Config defaults
    useMockData = false;
    scanningSource = ScanningSource.backend;
  }
}
