import '../data/ingredient_health_data.dart';

class IngredientHealthService {
  static List<String> findUnhealthyIngredients(
    String ingredientsText, {
    int threshold = 40,
  }) {
    final lowerText = ingredientsText.toLowerCase();

    return IngredientHealthData.scores.entries
        .where(
          (entry) => entry.value < threshold && lowerText.contains(entry.key),
        )
        .map((entry) => entry.key)
        .toList();
  }
}
