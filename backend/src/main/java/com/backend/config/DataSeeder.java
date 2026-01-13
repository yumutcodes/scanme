package com.backend.config;

import com.backend.model.*;
import com.backend.repository.*;
import com.github.javafaker.Faker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

@Configuration
public class DataSeeder {

    private static final Logger logger = LoggerFactory.getLogger(DataSeeder.class);

    @Value("${seeding.enabled:true}")
    private boolean seedingEnabled;

    @Value("${seeding.user-count.min:5}")
    private int minUserCount;

    @Value("${seeding.user-count.max:10}")
    private int maxUserCount;

    @Value("${admin.username:admin}")
    private String adminUsername;

    @Value("${admin.password:admin123}")
    private String adminPassword;

    @Value("${admin.email:admin@scanme.com}")
    private String adminEmail;

    @Bean
    @Transactional
    CommandLineRunner initData(
            AllergyRepository allergyRepository,
            DangerousIngredientsRepository dangerousIngredientsRepository,
            IngredientRepository ingredientRepository,
            ProductRepository productRepository,
            UserRepository userRepository,
            PasswordEncoder passwordEncoder) {

        return args -> {
            // Check if seeding is enabled
            if (!seedingEnabled) {
                logger.info("Data seeding is disabled. Skipping...");
                return;
            }

            // Check if data already exists to avoid duplicate seeding
            if (userRepository.count() > 0 || productRepository.count() > 0) {
                logger.info("Database already populated. Skipping data seeding...");
                return;
            }

            logger.info("Starting data seeding...");

            // Initialize Faker
            Faker faker = new Faker();
            Random random = new Random();

            // ==================== SEED ALLERGIES ====================
            logger.info("Seeding allergies...");

            // Check if allergies already exist
            if (allergyRepository.count() > 0) {
                logger.info("Allergies already exist. Skipping...");
            } else {
                // Match frontend allergen names exactly
                Allergy peanuts = new Allergy("Peanuts", null);
                Allergy treeNuts = new Allergy("Tree Nuts", null);
                Allergy milkDairy = new Allergy("Milk (Dairy)", null);
                Allergy eggs = new Allergy("Eggs", null);
                Allergy soy = new Allergy("Soy", null);
                Allergy gluten = new Allergy("Gluten", null);
                Allergy fish = new Allergy("Fish", null);
                Allergy shellfish = new Allergy("Shellfish", null);
                Allergy sesame = new Allergy("Sesame", null);
                Allergy mustard = new Allergy("Mustard", null);
                // Additional backend allergies
                Allergy celery = new Allergy("Celery", null);
                Allergy sulfites = new Allergy("Sulfites", null);
                Allergy lupin = new Allergy("Lupin", null);
                Allergy molluscs = new Allergy("Molluscs", null);

                List<Allergy> allergies = Arrays.asList(
                        peanuts, treeNuts, milkDairy, eggs, soy, gluten,
                        fish, shellfish, sesame, mustard, celery, sulfites, lupin, molluscs);
                allergyRepository.saveAll(allergies);
                logger.info("Seeded {} allergies", allergies.size());
            }

            // ==================== SEED DANGEROUS INGREDIENTS ====================
            logger.info("Seeding dangerous ingredients...");

            if (dangerousIngredientsRepository.count() > 0) {
                logger.info("Dangerous ingredients already exist. Skipping...");
            } else {
                DangerousIngredients aspartame = new DangerousIngredients("Aspartame", 6);
                DangerousIngredients monosodiumGlutamate = new DangerousIngredients("Monosodium Glutamate (MSG)", 7);
                DangerousIngredients sodiumNitrite = new DangerousIngredients("Sodium Nitrite", 8);
                DangerousIngredients artificialColors = new DangerousIngredients("Artificial Colors (E102, E110, etc.)",
                        5);
                DangerousIngredients sodiumBenzoate = new DangerousIngredients("Sodium Benzoate", 4);
                DangerousIngredients transFat = new DangerousIngredients("Trans Fat", 9);
                DangerousIngredients highFructoseCornSyrup = new DangerousIngredients("High Fructose Corn Syrup", 6);
                DangerousIngredients potassiumSorbate = new DangerousIngredients("Potassium Sorbate", 3);
                DangerousIngredients sulfurDioxide = new DangerousIngredients("Sulfur Dioxide", 5);
                DangerousIngredients brominatedVegetableOil = new DangerousIngredients("Brominated Vegetable Oil", 7);
                DangerousIngredients acesulfamePotassium = new DangerousIngredients("Acesulfame Potassium", 5);
                DangerousIngredients saccharin = new DangerousIngredients("Saccharin", 4);
                DangerousIngredients bha = new DangerousIngredients("BHA (Butylated Hydroxyanisole)", 7);
                DangerousIngredients bht = new DangerousIngredients("BHT (Butylated Hydroxytoluene)", 6);
                DangerousIngredients parabens = new DangerousIngredients("Parabens", 4);

                List<DangerousIngredients> dangerousIngredientsList = Arrays.asList(
                        aspartame, monosodiumGlutamate, sodiumNitrite, artificialColors,
                        sodiumBenzoate, transFat, highFructoseCornSyrup, potassiumSorbate,
                        sulfurDioxide, brominatedVegetableOil, acesulfamePotassium, saccharin,
                        bha, bht, parabens);
                dangerousIngredientsRepository.saveAll(dangerousIngredientsList);
                logger.info("Seeded {} dangerous ingredients", dangerousIngredientsList.size());
            }

            // ==================== SEED COMMON INGREDIENTS ====================
            logger.info("Seeding common ingredients...");

            if (ingredientRepository.count() > 0) {
                logger.info("Ingredients already exist. Skipping...");
            } else {
                Ingredient sugar = getOrCreateIngredient(ingredientRepository, "Sugar");
                Ingredient salt = getOrCreateIngredient(ingredientRepository, "Salt");
                Ingredient flour = getOrCreateIngredient(ingredientRepository, "Flour");
                Ingredient water = getOrCreateIngredient(ingredientRepository, "Water");
                Ingredient vegetableOil = getOrCreateIngredient(ingredientRepository, "Vegetable Oil");
                Ingredient palmOil = getOrCreateIngredient(ingredientRepository, "Palm Oil");
                Ingredient butter = getOrCreateIngredient(ingredientRepository, "Butter");
                Ingredient milk = getOrCreateIngredient(ingredientRepository, "Milk");
                Ingredient wheatFlour = getOrCreateIngredient(ingredientRepository, "Wheat Flour");
                Ingredient cornStarch = getOrCreateIngredient(ingredientRepository, "Corn Starch");
                Ingredient soySauceIngredient = getOrCreateIngredient(ingredientRepository, "Soy Sauce");
                Ingredient vinegar = getOrCreateIngredient(ingredientRepository, "Vinegar");
                Ingredient garlic = getOrCreateIngredient(ingredientRepository, "Garlic");
                Ingredient onion = getOrCreateIngredient(ingredientRepository, "Onion");
                Ingredient tomatoPaste = getOrCreateIngredient(ingredientRepository, "Tomato Paste");
                Ingredient cheese = getOrCreateIngredient(ingredientRepository, "Cheese");
                Ingredient yeast = getOrCreateIngredient(ingredientRepository, "Yeast");
                Ingredient eggsIngredient = getOrCreateIngredient(ingredientRepository, "Eggs");
                Ingredient chocolate = getOrCreateIngredient(ingredientRepository, "Chocolate");
                Ingredient cocoa = getOrCreateIngredient(ingredientRepository, "Cocoa");
                Ingredient vanilla = getOrCreateIngredient(ingredientRepository, "Vanilla");
                Ingredient honey = getOrCreateIngredient(ingredientRepository, "Honey");
                Ingredient cinnamon = getOrCreateIngredient(ingredientRepository, "Cinnamon");
                Ingredient ginger = getOrCreateIngredient(ingredientRepository, "Ginger");
                Ingredient oliveOil = getOrCreateIngredient(ingredientRepository, "Olive Oil");
                Ingredient rice = getOrCreateIngredient(ingredientRepository, "Rice");
                Ingredient chicken = getOrCreateIngredient(ingredientRepository, "Chicken");
                Ingredient beef = getOrCreateIngredient(ingredientRepository, "Beef");
                Ingredient pork = getOrCreateIngredient(ingredientRepository, "Pork");
                Ingredient shrimp = getOrCreateIngredient(ingredientRepository, "Shrimp");
                Ingredient peanuts = getOrCreateIngredient(ingredientRepository, "Peanuts");
                Ingredient almonds = getOrCreateIngredient(ingredientRepository, "Almonds");
                Ingredient hazelnuts = getOrCreateIngredient(ingredientRepository, "Hazelnuts");
                Ingredient walnuts = getOrCreateIngredient(ingredientRepository, "Walnuts");
                Ingredient wheat = getOrCreateIngredient(ingredientRepository, "Wheat");
                Ingredient barley = getOrCreateIngredient(ingredientRepository, "Barley");
                Ingredient rye = getOrCreateIngredient(ingredientRepository, "Rye");
                Ingredient soybeans = getOrCreateIngredient(ingredientRepository, "Soybeans");

                Ingredient bakingPowder = getOrCreateIngredient(ingredientRepository, "Baking Powder");
                Ingredient potatoes = getOrCreateIngredient(ingredientRepository, "Potatoes");
                Ingredient seasoning = getOrCreateIngredient(ingredientRepository, "Seasoning");
                Ingredient carbonDioxide = getOrCreateIngredient(ingredientRepository, "Carbon Dioxide");
                Ingredient caramelColor = getOrCreateIngredient(ingredientRepository, "Caramel Color");
                Ingredient phosphoricAcid = getOrCreateIngredient(ingredientRepository, "Phosphoric Acid");
                Ingredient caffeine = getOrCreateIngredient(ingredientRepository, "Caffeine");
                Ingredient naturalFlavors = getOrCreateIngredient(ingredientRepository, "Natural Flavors");
                Ingredient cocoaButter = getOrCreateIngredient(ingredientRepository, "Cocoa Butter");
                Ingredient soyLecithin = getOrCreateIngredient(ingredientRepository, "Soy Lecithin");
                Ingredient cream = getOrCreateIngredient(ingredientRepository, "Cream");
                Ingredient spices = getOrCreateIngredient(ingredientRepository, "Spices");
                Ingredient gelatin = getOrCreateIngredient(ingredientRepository, "Gelatin");
                Ingredient liveCultures = getOrCreateIngredient(ingredientRepository, "Live Cultures");
                Ingredient tunaFish = getOrCreateIngredient(ingredientRepository, "Tuna");
                Ingredient hydrogenatedVegetableOil = getOrCreateIngredient(ingredientRepository,
                        "Hydrogenated Vegetable Oil");
                Ingredient fruit = getOrCreateIngredient(ingredientRepository, "Fruit");
                Ingredient emulsifiers = getOrCreateIngredient(ingredientRepository, "Emulsifiers");
                Ingredient sodiumCitrate = getOrCreateIngredient(ingredientRepository, "Sodium Citrate");
                Ingredient hazelnutPuree = getOrCreateIngredient(ingredientRepository, "Hazelnut Puree");
                Ingredient cocoaMass = getOrCreateIngredient(ingredientRepository, "Cocoa Mass");
                Ingredient starch = getOrCreateIngredient(ingredientRepository, "Starch");
                Ingredient wheyPowder = getOrCreateIngredient(ingredientRepository, "Whey Powder");
                Ingredient cocoaPowder = getOrCreateIngredient(ingredientRepository, "Cocoa Powder");
                Ingredient skimmedMilkPowder = getOrCreateIngredient(ingredientRepository, "Skimmed Milk Powder");
                Ingredient eggWhitePowder = getOrCreateIngredient(ingredientRepository, "Egg White Powder");
                Ingredient flavourings = getOrCreateIngredient(ingredientRepository, "Flavourings");
                Ingredient raisingAgents = getOrCreateIngredient(ingredientRepository, "Raising Agents");
                Ingredient wholeMilkPowder = getOrCreateIngredient(ingredientRepository, "Whole Milk Powder");

                Ingredient sodiumBenzoateIngredient = getOrCreateIngredient(ingredientRepository, "Sodium Benzoate");
                Ingredient monosodiumGlutamateIngredient = getOrCreateIngredient(ingredientRepository,
                        "Monosodium Glutamate");
                Ingredient sodiumNitriteIngredient = getOrCreateIngredient(ingredientRepository, "Sodium Nitrite");
                Ingredient artificialColorsIngredient = getOrCreateIngredient(ingredientRepository,
                        "Artificial Colors");

                List<Ingredient> ingredients = Arrays.asList(
                        sugar, salt, flour, water, vegetableOil, palmOil, butter, milk,
                        wheatFlour, cornStarch, soySauceIngredient, vinegar, garlic, onion, tomatoPaste,
                        cheese, yeast, eggsIngredient, chocolate, cocoa, vanilla, honey, cinnamon,
                        ginger, oliveOil, rice, chicken, beef, pork, shrimp, peanuts, almonds,
                        hazelnuts, walnuts, wheat, barley, rye, soybeans,
                        bakingPowder, potatoes, seasoning, carbonDioxide, caramelColor,
                        phosphoricAcid, caffeine, naturalFlavors, cocoaButter, soyLecithin,
                        cream, spices, gelatin, liveCultures, tunaFish, hydrogenatedVegetableOil,
                        fruit, emulsifiers, sodiumCitrate, hazelnutPuree, cocoaMass, starch,
                        wheyPowder, cocoaPowder, skimmedMilkPowder, eggWhitePowder, flavourings,
                        raisingAgents, wholeMilkPowder, sodiumBenzoateIngredient,
                        monosodiumGlutamateIngredient, sodiumNitriteIngredient, artificialColorsIngredient);
                ingredientRepository.saveAll(ingredients);
                logger.info("Seeded {} ingredients", ingredients.size());
            }

            // ==================== SEED SAMPLE PRODUCTS ====================
            logger.info("Seeding products with JavaFaker...");

            List<Ingredient> allIngredients = ingredientRepository.findAll();

            List<Product> products = new ArrayList<>();

            String[][] productTemplates = {
                    { "Chocolate Cookie",
                            "Wheat Flour,Sugar,Palm Oil,Cocoa,Chocolate,Vanilla,Eggs,Baking Powder,Salt,Milk" },
                    { "Potato Chips", "Potatoes,Vegetable Oil,Salt,Seasoning,Sugar" },
                    { "Cola Drink",
                            "Water,Sugar,Carbon Dioxide,Caramel Color,Phosphoric Acid,Caffeine,Natural Flavors,Sodium Benzoate" },
                    { "White Bread", "Wheat Flour,Water,Yeast,Salt,Sugar,Vegetable Oil" },
                    { "Chocolate Bar", "Sugar,Cocoa,Milk,Cocoa Butter,Vanilla,Soy Lecithin" },
                    { "Tomato Soup", "Water,Tomato Paste,Cream,Salt,Sugar,Onion,Garlic,Spices,Sodium Benzoate" },
                    { "Instant Noodles",
                            "Wheat Flour,Palm Oil,Salt,Seasoning,Monosodium Glutamate,Sodium Nitrite,Artificial Colors,Garlic,Onion" },
                    { "Fruit Yogurt", "Milk,Sugar,Fruit,Gelatin,Vanilla,Live Cultures" },
                    { "Canned Tuna", "Tuna,Water,Salt,Vegetable Oil,Sodium Benzoate" },
                    { "Peanut Butter", "Peanuts,Sugar,Palm Oil,Salt,Hydrogenated Vegetable Oil" },
                    { "Soy Sauce", "Soybeans,Wheat,Salt,Water,Sodium Benzoate" },
                    { "Processed Cheese",
                            "Cheese,Milk,Butter,Salt,Emulsifiers,Sodium Citrate,Artificial Colors,Sodium Benzoate" },
                    { "Ulker Chocolate Wafer",
                            "Sugar,Wheat Flour,Vegetable Oil,Hazelnut Puree,Whole Milk Powder,Cocoa Butter,Cocoa Mass,Starch,Whey Powder,Emulsifiers,Salt,Cocoa Powder,Skimmed Milk Powder,Egg White Powder,Flavourings,Raising Agents" },
                    { "Nutella Hazelnut Spread",
                            "Sugar,Palm Oil,Hazelnuts,Skimmed Milk Powder,Cocoa,Soy Lecithin,Vanillin" }
            };

            for (String[] template : productTemplates) {
                Product product = new Product();

                String barcode;
                String brand;

                // Special case for Ulker Chocolate Wafer and Nutella
                if (template[0].equals("Ulker Chocolate Wafer")) {
                    barcode = "8690504020509";
                    brand = "Ulker";
                } else if (template[0].equals("Nutella Hazelnut Spread")) {
                    barcode = "3017620422003";
                    brand = "Ferrero";
                } else {
                    barcode = "869" + String.format("%09d", faker.number().numberBetween(1, 999999999));
                    brand = faker.company().name();
                }

                product.setBarcode(barcode);

                String baseName = template[0];
                product.setProductName(brand + " " + baseName);

                String[] ingredientNames = template[1].split(",");
                List<Ingredient> productIngredients = new ArrayList<>();

                for (String ingName : ingredientNames) {
                    allIngredients.stream()
                            .filter(ing -> ing.getName().equals(ingName.trim()))
                            .findFirst()
                            .ifPresent(productIngredients::add);
                }

                int additionalCount = random.nextInt(3);
                for (int j = 0; j < additionalCount; j++) {
                    Ingredient randomIng = allIngredients.get(random.nextInt(allIngredients.size()));
                    if (!productIngredients.contains(randomIng)) {
                        productIngredients.add(randomIng);
                    }
                }

                product.setIngredients(productIngredients);
                products.add(product);
            }

            productRepository.saveAll(products);
            logger.info("Seeded {} products", products.size());

            // ==================== SEED USERS ====================
            logger.info("Seeding users with JavaFaker...");

            List<Allergy> allAllergies = allergyRepository.findAll();

            // Create Admin User from configuration
            User admin = new User();
            admin.setUsername(adminUsername);
            admin.setPassword(passwordEncoder.encode(adminPassword));
            admin.setEmail(adminEmail);
            admin.setName("System");
            admin.setSurname("Administrator");
            admin.setRole(Role.ROLE_ADMIN);
            admin.setAllergies(null);
            userRepository.save(admin);

            int userCount = faker.number().numberBetween(minUserCount, maxUserCount + 1);
            for (int i = 0; i < userCount; i++) {
                User user = new User();

                String firstName = faker.name().firstName();
                String lastName = faker.name().lastName();
                user.setUsername(faker.name().username().toLowerCase());
                user.setPassword(passwordEncoder.encode(faker.internet().password(6, 12)));
                user.setEmail(faker.internet().emailAddress());
                user.setName(firstName);
                user.setSurname(lastName);
                user.setRole(Role.ROLE_USER);

                int allergyCount = faker.number().numberBetween(1, 4);
                List<Allergy> userAllergies = new ArrayList<>();
                for (int j = 0; j < allergyCount; j++) {
                    Allergy randomAllergy = allAllergies.get(random.nextInt(allAllergies.size()));
                    if (!userAllergies.contains(randomAllergy)) {
                        userAllergies.add(randomAllergy);
                    }
                }
                user.setAllergies(userAllergies);
                userRepository.save(user);
            }

            // Create Test User with predefined allergies
            User testUser = new User();
            testUser.setUsername("testuser");
            testUser.setPassword(passwordEncoder.encode("testpass"));
            testUser.setEmail("test@scanme.com");
            testUser.setName("Test");
            testUser.setSurname("User");
            testUser.setRole(Role.ROLE_USER);

            List<Allergy> testAllergies = Arrays.asList(
                    allAllergies.stream().filter(a -> a.getName().equals("Gluten")).findFirst().orElse(null),
                    allAllergies.stream().filter(a -> a.getName().equals("Milk (Dairy)")).findFirst().orElse(null),
                    allAllergies.stream().filter(a -> a.getName().equals("Tree Nuts")).findFirst().orElse(null));
            testUser.setAllergies(testAllergies);
            userRepository.save(testUser);

            logger.info("Seeded {} users ({} random + 1 admin + 1 test user)", userCount + 2, userCount);

            // ==================== UPDATE ALLERGIES WITH USERS ====================
            List<User> users = userRepository.findAll();
            List<Allergy> allergies = allergyRepository.findAll();

            User foundTestUser = users.stream()
                    .filter(u -> u.getUsername().equals("testuser"))
                    .findFirst()
                    .orElse(testUser);

            for (Allergy allergy : allergies) {
                if (allergy.getName().equals("Gluten") ||
                        allergy.getName().equals("Milk (Dairy)") ||
                        allergy.getName().equals("Tree Nuts") ||
                        allergy.getName().equals("Eggs") ||
                        allergy.getName().equals("Soy") ||
                        allergy.getName().equals("Shellfish")) {

                    List<User> allergyUsers = new ArrayList<>();
                    allergyUsers.add(foundTestUser);

                    User randomUser = users.get(random.nextInt(users.size()));
                    if (!randomUser.getUsername().equals("admin") && !randomUser.getUsername().equals("testuser")) {
                        allergyUsers.add(randomUser);
                    }

                    allergy.setUser(allergyUsers);
                    allergyRepository.save(allergy);
                }
            }

            logger.info("Data seeding completed successfully!");
        };
    }

    private Ingredient getOrCreateIngredient(IngredientRepository repository, String name) {
        return repository.findByName(name)
                .orElseGet(() -> {
                    Ingredient ingredient = new Ingredient(name, null);
                    return repository.save(ingredient);
                });
    }
}
