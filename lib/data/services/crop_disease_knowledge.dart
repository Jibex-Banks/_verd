/// Comprehensive knowledge base for all 54 crop disease classes.
/// 
/// Each entry contains human-readable display info, visual inspection tips,
/// treatments, and severity weighting for hackathon-quality output.
class CropDiseaseKnowledge {
  final String displayName;
  final String cropType;
  final String healthStatus; // 'Healthy' | 'Warning' | 'Critical'
  final String visualSigns;
  final String treatment;
  final List<String> actionSteps;
  final bool requiresManualInspection;
  final String? disclaimer;

  const CropDiseaseKnowledge({
    required this.displayName,
    required this.cropType,
    required this.healthStatus,
    required this.visualSigns,
    required this.treatment,
    required this.actionSteps,
    this.requiresManualInspection = false,
    this.disclaimer,
  });

  static const Map<String, CropDiseaseKnowledge> _db = {
    // ── BEANS ──
    'beans_angular_leaf_spot': CropDiseaseKnowledge(
      displayName: 'Angular Leaf Spot',
      cropType: 'Beans',
      healthStatus: 'Warning',
      visualSigns: 'Angular, water-soaked lesions bounded by leaf veins. Spots turn brown with yellow halos.',
      treatment: 'Apply copper-based bactericide. Remove infected leaves. Avoid overhead irrigation.',
      actionSteps: [
        'Remove and destroy all infected plant material',
        'Apply copper hydroxide fungicide (e.g., Kocide) every 7–10 days',
        'Avoid wetting leaves when watering',
        'Ensure good plant spacing for air circulation',
      ],
    ),
    'beans_anthracnose': CropDiseaseKnowledge(
      displayName: 'Bean Anthracnose',
      cropType: 'Beans',
      healthStatus: 'Critical',
      visualSigns: 'Dark, sunken oval lesions with reddish-brown borders on pods and stems. Pink spore masses in wet conditions.',
      treatment: 'Apply mancozeb or chlorothalonil fungicide. Use certified disease-free seeds.',
      actionSteps: [
        'Destroy all infected plant material immediately',
        'Apply mancozeb fungicide (2g/L) preventively',
        'Use certified disease-free seeds next season',
        'Rotate crops — avoid beans in this area for 2 seasons',
      ],
    ),
    'beans_bean_rust': CropDiseaseKnowledge(
      displayName: 'Bean Rust',
      cropType: 'Beans',
      healthStatus: 'Warning',
      visualSigns: 'Small, round, raised orange-brown pustules (powdery) on leaf undersides. Upper leaf surface shows pale yellow spots.',
      treatment: 'Apply triazole fungicide (e.g., tebuconazole). Remove heavily infected leaves.',
      actionSteps: [
        'Apply tebuconazole or propiconazole fungicide',
        'Remove and burn heavily infected leaves',
        'Avoid overhead watering — water at base',
        'Monitor every 3 days and reapply after rain',
      ],
    ),
    'beans_healthy': CropDiseaseKnowledge(
      displayName: 'Healthy Beans',
      cropType: 'Beans',
      healthStatus: 'Healthy',
      visualSigns: 'Deep green leaves, no spots or lesions, firm stems.',
      treatment: 'No treatment needed. Continue regular monitoring.',
      actionSteps: [
        'Continue current watering and fertilization practices',
        'Monitor weekly for early disease signs',
        'Ensure soil drainage is adequate',
      ],
    ),
    'beans_mosaic_virus': CropDiseaseKnowledge(
      displayName: 'Bean Mosaic Virus',
      cropType: 'Beans',
      healthStatus: 'Critical',
      visualSigns: 'Irregular yellow-green mosaic pattern on leaves. Leaves may be distorted, crinkled, or smaller than normal.',
      treatment: 'No cure. Remove infected plants immediately. Control aphid vectors with insecticide.',
      actionSteps: [
        'Remove and destroy infected plants immediately — do NOT compost',
        'Apply systemic insecticide to control aphid spread',
        'Use reflective mulch to deter aphids',
        'Plant resistant varieties next season',
      ],
      disclaimer: 'Bean mosaic virus has no cure. Early removal prevents field spread.',
    ),

    // ── CASHEW ──
    'cashew_anthracnose': CropDiseaseKnowledge(
      displayName: 'Cashew Anthracnose',
      cropType: 'Cashew',
      healthStatus: 'Critical',
      visualSigns: 'Dark, sunken lesions on leaves, nuts, and panicles. Leaves show irregular brown spots with yellow margins.',
      treatment: 'Apply copper oxychloride or mancozeb. Remove infected parts before spreading.',
      actionSteps: [
        'Prune and destroy infected branches and panicles',
        'Apply copper oxychloride (3g/L) at bud break',
        'Repeat spray every 2 weeks during wet season',
        'Improve canopy airflow by strategic pruning',
      ],
    ),
    'cashew_gumosis': CropDiseaseKnowledge(
      displayName: 'Cashew Gummosis',
      cropType: 'Cashew',
      healthStatus: 'Warning',
      visualSigns: 'Gum exuding from trunk and branches. Bark darkens and may crack. Cankers visible under bark.',
      treatment: 'Scrape affected bark, apply Bordeaux paste. Improve drainage around roots.',
      actionSteps: [
        'Scrape off gum and infected bark with a clean knife',
        'Apply Bordeaux paste (copper sulfate + lime) to wounds',
        'Improve soil drainage around tree base',
        'Avoid waterlogging — check irrigation system',
      ],
    ),
    'cashew_healthy': CropDiseaseKnowledge(
      displayName: 'Healthy Cashew',
      cropType: 'Cashew',
      healthStatus: 'Healthy',
      visualSigns: 'Vibrant green foliage, no lesions, clean bark surface.',
      treatment: 'No treatment needed.',
      actionSteps: [
        'Continue regular monitoring',
        'Maintain adequate spacing for airflow',
        'Apply balanced fertilizer at start of rainy season',
      ],
    ),
    'cashew_leaf_miner': CropDiseaseKnowledge(
      displayName: 'Cashew Leaf Miner',
      cropType: 'Cashew',
      healthStatus: 'Warning',
      visualSigns: 'Serpentine (winding) mines or blotches on leaf surface. Leaves may curl or brown at tips.',
      treatment: 'Apply systemic insecticide (imidacloprid). Remove and destroy heavily mined leaves.',
      actionSteps: [
        'Apply imidacloprid or abamectin systemic insecticide',
        'Remove and destroy all heavily mined leaves',
        'Monitor new flush growth — larvae attack young leaves',
        'Use yellow sticky traps to monitor adult population',
      ],
      requiresManualInspection: true,
    ),
    'cashew_red_rust': CropDiseaseKnowledge(
      displayName: 'Cashew Red Rust',
      cropType: 'Cashew',
      healthStatus: 'Warning',
      visualSigns: 'Rust-red powdery coating (algae) on older leaves and branches. Not a true fungus — caused by algae.',
      treatment: 'Apply copper-based spray. Improve light penetration by pruning dense canopy.',
      actionSteps: [
        'Apply copper oxychloride spray to affected areas',
        'Prune dense inner branches to improve light and airflow',
        'Reduce shade — the algae thrive in low light',
      ],
    ),

    // ── CASSAVA ──
    'cassava_bacterial_blight': CropDiseaseKnowledge(
      displayName: 'Cassava Bacterial Blight',
      cropType: 'Cassava',
      healthStatus: 'Critical',
      visualSigns: 'Water-soaked leaf spots that turn angular and brown. Stem cankers with milky exudate. Wilting of shoots.',
      treatment: 'Use clean, disease-free cuttings. Remove infected plants. No effective chemical control.',
      actionSteps: [
        'Remove and burn all infected plants and cuttings',
        'Use only certified disease-free planting material',
        'Disinfect cutting tools with bleach between plants',
        'Rotate to non-cassava crops for 1 season',
      ],
      disclaimer: 'No effective chemical treatment exists. Prevention with clean cuttings is essential.',
    ),
    'cassava_brown_spot': CropDiseaseKnowledge(
      displayName: 'Cassava Brown Spot',
      cropType: 'Cassava',
      healthStatus: 'Warning',
      visualSigns: 'Small, circular brown spots with yellow halos on leaves. Spots may have lighter centers.',
      treatment: 'Apply mancozeb fungicide. Remove infected leaves to reduce spread.',
      actionSteps: [
        'Remove and destroy infected leaves',
        'Apply mancozeb (2g/L) as preventive spray',
        'Avoid planting in low-lying, poorly drained areas',
        'Use resistant varieties where available',
      ],
    ),
    'cassava_green_mite': CropDiseaseKnowledge(
      displayName: 'Cassava Green Mite',
      cropType: 'Cassava',
      healthStatus: 'Warning',
      visualSigns: 'Chlorotic (yellow-green) angular spots on young leaves. Leaf deformation and stunted new growth.',
      treatment: 'Apply acaricide (abamectin or sulphur). Introduce biological control (predatory mites).',
      actionSteps: [
        'Apply acaricide — abamectin or wettable sulphur',
        'Spray undersides of young leaves where mites congregate',
        'Avoid dusty conditions which favor mite outbreaks',
        'Conserve natural predators — avoid broad-spectrum pesticides',
      ],
      requiresManualInspection: true,
      disclaimer: 'Green mites are tiny — use a magnifying lens to confirm on leaf undersides.',
    ),
    'cassava_healthy': CropDiseaseKnowledge(
      displayName: 'Healthy Cassava',
      cropType: 'Cassava',
      healthStatus: 'Healthy',
      visualSigns: 'Dark green, lobed leaves with no spots or distortion.',
      treatment: 'No treatment needed.',
      actionSteps: [
        'Continue regular weeding and fertilization',
        'Monitor monthly for early pest or disease signs',
      ],
    ),
    'cassava_mosaic': CropDiseaseKnowledge(
      displayName: 'Cassava Mosaic Disease',
      cropType: 'Cassava',
      healthStatus: 'Critical',
      visualSigns: 'Yellow-green mosaic or chlorosis on leaves. Leaves distorted, twisted, or reduced in size.',
      treatment: 'No cure. Rogue out infected plants. Use virus-free cuttings and whitefly control.',
      actionSteps: [
        'Remove and destroy infected plants immediately',
        'Do NOT use cuttings from infected plants',
        'Apply insecticide to control whitefly vectors',
        'Source cuttings from certified disease-free nurseries',
      ],
      disclaimer: 'Cassava mosaic has no cure — transmitted by whiteflies and infected cuttings.',
    ),

    // ── MAIZE ──
    'maize_blight': CropDiseaseKnowledge(
      displayName: 'Maize Leaf Blight',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Long, tan to gray elliptical lesions running parallel to leaf veins. Lesions have wavy, irregular margins.',
      treatment: 'Apply mancozeb or propiconazole fungicide. Plant resistant varieties. Improve field drainage.',
      actionSteps: [
        'Apply propiconazole or mancozeb at first sign of disease',
        'Remove severely infected lower leaves',
        'Ensure adequate plant spacing (1 plant per 30cm)',
        'Use resistant hybrid varieties next season',
      ],
    ),
    'maize2nd_blight': CropDiseaseKnowledge(
      displayName: 'Maize Leaf Blight',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Long, tan to gray elliptical lesions running parallel to leaf veins.',
      treatment: 'Apply propiconazole fungicide. Plant resistant varieties.',
      actionSteps: [
        'Apply propiconazole at first sign of disease',
        'Remove severely infected lower leaves',
        'Use resistant hybrid varieties next season',
      ],
    ),
    'maize_common_rust': CropDiseaseKnowledge(
      displayName: 'Maize Common Rust',
      cropType: 'Maize',
      healthStatus: 'Warning',
      visualSigns: 'Small, oval, brick-red to brown pustules scattered on both leaf surfaces. Pustules rupture releasing powdery spores.',
      treatment: 'Apply triazole fungicide (tebuconazole). Rust-resistant varieties are most effective solution.',
      actionSteps: [
        'Apply tebuconazole or azoxystrobin fungicide',
        'Scout fields weekly — rust spreads rapidly in cool, wet weather',
        'Plant rust-resistant hybrids next season',
        'Avoid late planting which increases rust pressure',
      ],
    ),
    'maize2nd_common_rust': CropDiseaseKnowledge(
      displayName: 'Maize Common Rust',
      cropType: 'Maize',
      healthStatus: 'Warning',
      visualSigns: 'Small oval brick-red pustules on both leaf surfaces.',
      treatment: 'Apply triazole fungicide. Plant rust-resistant varieties.',
      actionSteps: [
        'Apply tebuconazole fungicide',
        'Plant rust-resistant hybrids next season',
      ],
    ),
    'maize_downy_mildew': CropDiseaseKnowledge(
      displayName: 'Maize Downy Mildew',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Yellow-white striping on young leaves. White downy growth on leaf undersides in early morning. Stunted plants.',
      treatment: 'Apply metalaxyl seed treatment. Remove infected plants. No curative spray available.',
      actionSteps: [
        'Remove and destroy infected plants immediately',
        'Use metalaxyl-treated seeds for next planting',
        'Improve field drainage — disease spreads in waterlogged soils',
        'Avoid continuous maize cultivation in same field',
      ],
      disclaimer: 'Downy mildew spreads rapidly in cool, wet conditions. Early roguing is critical.',
    ),
    'maize2nd_downy_mildew': CropDiseaseKnowledge(
      displayName: 'Maize Downy Mildew',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Yellow-white leaf striping, white downy growth on undersides.',
      treatment: 'Use metalaxyl seed treatment. Remove infected plants.',
      actionSteps: [
        'Remove infected plants immediately',
        'Use metalaxyl-treated seeds next season',
      ],
    ),
    'maize_fall_armyworm': CropDiseaseKnowledge(
      displayName: 'Fall Armyworm',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Ragged holes in leaves from caterpillar feeding. "Window-pane" damage on young leaves. Look for frass (dark droppings) in whorl.',
      treatment: 'Apply emamectin benzoate or spinetoram insecticide into the whorl. Early morning application most effective.',
      actionSteps: [
        'Apply emamectin benzoate (e.g., Coragen) into the whorl',
        'Scout early morning — larvae hide in whorl during day',
        'Use sand + lime or ash in whorl as organic deterrent',
        'Apply Bacillus thuringiensis (Bt) for organic option',
        'Report outbreak to local agricultural extension immediately',
      ],
      requiresManualInspection: true,
      disclaimer: 'Fall armyworm is a high-risk pest — model accuracy may be lower. Manual inspection of whorl recommended.',
    ),
    'maize_grasshopper': CropDiseaseKnowledge(
      displayName: 'Maize Grasshopper Damage',
      cropType: 'Maize',
      healthStatus: 'Warning',
      visualSigns: 'Irregular chewing damage on leaf edges. Clean-cut leaf margins. Visible adult insects on plants.',
      treatment: 'Apply malathion or lambda-cyhalothrin. Best treated early morning when insects are sluggish.',
      actionSteps: [
        'Apply malathion or lambda-cyhalothrin insecticide early morning',
        'Use barrier plants (e.g., vetiver grass) around field edges',
        'Hand-pick adults during cool morning hours',
      ],
      requiresManualInspection: true,
    ),
    'maize_gray_leaf_spot': CropDiseaseKnowledge(
      displayName: 'Maize Gray Leaf Spot',
      cropType: 'Maize',
      healthStatus: 'Warning',
      visualSigns: 'Narrow, rectangular tan lesions with parallel sides along leaf veins. Lesions have gray, dry appearance at maturity.',
      treatment: 'Apply strobilurin + triazole fungicide mix. Improve field airflow. Use resistant varieties.',
      actionSteps: [
        'Apply azoxystrobin + propiconazole mix fungicide',
        'Rotate crops — avoid maize after maize in same field',
        'Till crop residue to reduce disease carry-over',
        'Plant resistant varieties with GLS tolerance rating',
      ],
    ),
    'maize2nd_gray_leaf_spot': CropDiseaseKnowledge(
      displayName: 'Maize Gray Leaf Spot',
      cropType: 'Maize',
      healthStatus: 'Warning',
      visualSigns: 'Narrow rectangular tan lesions along leaf veins.',
      treatment: 'Apply strobilurin + triazole fungicide. Plant resistant varieties.',
      actionSteps: [
        'Apply azoxystrobin + propiconazole fungicide',
        'Rotate crops next season',
      ],
    ),
    'maize_healthy': CropDiseaseKnowledge(
      displayName: 'Healthy Maize',
      cropType: 'Maize',
      healthStatus: 'Healthy',
      visualSigns: 'Green, upright leaves with no spots, lesions, or pest damage.',
      treatment: 'No treatment needed.',
      actionSteps: [
        'Scout field weekly for early pest or disease signs',
        'Maintain adequate plant nutrition (especially nitrogen)',
        'Ensure weed control during first 4 weeks',
      ],
    ),
    'maize2nd_healthy': CropDiseaseKnowledge(
      displayName: 'Healthy Maize',
      cropType: 'Maize',
      healthStatus: 'Healthy',
      visualSigns: 'Healthy green leaves without any visible damage.',
      treatment: 'No treatment needed.',
      actionSteps: ['Continue regular monitoring and good agronomic practices.'],
    ),
    'maize_leaf_beetle': CropDiseaseKnowledge(
      displayName: 'Maize Leaf Beetle',
      cropType: 'Maize',
      healthStatus: 'Warning',
      visualSigns: 'Parallel feeding streaks (silvery stripes) along leaf blades. Small elongated beetles visible on leaves.',
      treatment: 'Apply carbaryl or lambda-cyhalothrin insecticide. Treat early to avoid silage contamination.',
      actionSteps: [
        'Apply lambda-cyhalothrin insecticide',
        'Best time to spray is early morning or evening',
        'Monitor for subsequent generations — multiple cycles possible',
      ],
    ),
    'maize_mln_lethal_necrosis': CropDiseaseKnowledge(
      displayName: 'Maize Lethal Necrosis',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Chlorotic (yellowing) starting from leaf margins, spreading to whole plant. Dead plant heart, complete drying of plant.',
      treatment: 'No chemical cure. Remove infected plants. Control vector insects. Use tolerant varieties.',
      actionSteps: [
        'Remove and burn all infected plants immediately',
        'Apply insecticide to control thrips and aphids (vectors)',
        'Report to local agricultural authority — MLN is a notifiable disease',
        'Plant tolerant varieties (e.g., AATF-approved MLN-tolerant hybrids)',
      ],
      disclaimer: 'Maize Lethal Necrosis is a serious, notifiable disease. Report confirmed cases to authorities.',
    ),
    'maize2nd_mln_lethal_necrosis': CropDiseaseKnowledge(
      displayName: 'Maize Lethal Necrosis',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Widespread yellowing from leaf margins, dead heart, plant collapse.',
      treatment: 'Remove infected plants. Control insect vectors. No chemical cure.',
      actionSteps: [
        'Remove and destroy infected plants',
        'Report to local agricultural authority',
        'Use MLN-tolerant varieties next season',
      ],
      disclaimer: 'Maize Lethal Necrosis is a serious, notifiable disease.',
    ),
    'maize_msv_streak_virus': CropDiseaseKnowledge(
      displayName: 'Maize Streak Virus',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Yellow-white streaks or dashes running parallel to leaf veins. Leaves may be narrow or distorted.',
      treatment: 'No cure. Control leafhopper vector. Use MSV-resistant varieties.',
      actionSteps: [
        'Apply imidacloprid seed treatment to reduce leafhopper spread',
        'Remove and destroy severely infected plants',
        'Plant MSV-resistant varieties (check local seed supplier)',
        'Plant early in the season to escape peak leafhopper populations',
      ],
    ),
    'maize_streak_virus': CropDiseaseKnowledge(
      displayName: 'Maize Streak Virus',
      cropType: 'Maize',
      healthStatus: 'Critical',
      visualSigns: 'Yellow-white streaks parallel to leaf veins. Narrow, distorted leaves.',
      treatment: 'No cure. Use resistant varieties and control leafhoppers.',
      actionSteps: [
        'Plant MSV-resistant varieties',
        'Control leafhopper vectors with insecticide',
        'Remove severely infected plants',
      ],
    ),

    // ── POTATO ──
    'potato_early_blight': CropDiseaseKnowledge(
      displayName: 'Potato Early Blight',
      cropType: 'Potato',
      healthStatus: 'Warning',
      visualSigns: 'Dark brown concentric ring lesions (target-board pattern) starting on older lower leaves.',
      treatment: 'Apply mancozeb or chlorothalonil fungicide. Remove infected lower leaves. Avoid leaf wetting.',
      actionSteps: [
        'Apply mancozeb (2g/L) every 7–10 days',
        'Remove and discard infected lower leaves',
        'Water at the base — avoid wetting foliage',
        'Ensure adequate potassium fertilization to boost resistance',
      ],
    ),
    'potato_fungal_diseases': CropDiseaseKnowledge(
      displayName: 'Potato Fungal Disease',
      cropType: 'Potato',
      healthStatus: 'Warning',
      visualSigns: 'Various symptoms: spots, blights, or molds on foliage. Confirm with more specific scan.',
      treatment: 'Apply broad-spectrum fungicide (mancozeb or copper-based). Improve drainage.',
      actionSteps: [
        'Apply mancozeb or copper fungicide preventively',
        'Remove visibly infected plant material',
        'Improve drainage — fungal diseases worsen in wet soils',
        'Consider submitting sample for lab identification',
      ],
      requiresManualInspection: true,
      disclaimer: 'Fungal disease class is broad — manual inspection recommended for precise identification.',
    ),
    'potato_healthy': CropDiseaseKnowledge(
      displayName: 'Healthy Potato',
      cropType: 'Potato',
      healthStatus: 'Healthy',
      visualSigns: 'Green, firm stems and compound leaves with no lesions or discoloration.',
      treatment: 'No treatment needed.',
      actionSteps: [
        'Continue regular hilling and fertilization',
        'Monitor for Colorado beetle and blight signs weekly',
      ],
    ),
    'potato_late_blight': CropDiseaseKnowledge(
      displayName: 'Potato Late Blight',
      cropType: 'Potato',
      healthStatus: 'Critical',
      visualSigns: 'Water-soaked, pale green lesions on leaves turning dark brown. White fuzzy mold on leaf undersides in humid conditions.',
      treatment: 'Apply metalaxyl + mancozeb (Ridomil Gold). Act IMMEDIATELY — late blight spreads within days.',
      actionSteps: [
        'Apply Ridomil Gold (metalaxyl + mancozeb) IMMEDIATELY',
        'Destroy severely infected foliage — do NOT leave on field',
        'Do NOT compost infected material — burn or bury deeply',
        'Harvest tubers quickly if foliage is badly infected',
        'Treat tubers with mancozeb before storage',
      ],
      disclaimer: 'Late blight is extremely dangerous — it caused the Irish Famine. Act within 24 hours of detection.',
    ),
    'potato_plant_pests': CropDiseaseKnowledge(
      displayName: 'Potato Plant Pests',
      cropType: 'Potato',
      healthStatus: 'Warning',
      visualSigns: 'Irregular chewing damage, holes, or tunnels in leaves. May see insect frass or insects themselves.',
      treatment: 'Apply appropriate insecticide based on pest type. Manual inspection recommended.',
      actionSteps: [
        'Identify the specific pest through manual inspection',
        'Apply lambda-cyhalothrin for general insect pest control',
        'Monitor tubers for underground pests during harvest',
      ],
      requiresManualInspection: true,
    ),
    'potato_potato_cyst_nematode': CropDiseaseKnowledge(
      displayName: 'Potato Cyst Nematode',
      cropType: 'Potato',
      healthStatus: 'Critical',
      visualSigns: 'Patchy yellowing and stunting in field (not on individual leaves). Roots show tiny white/yellow cysts.',
      treatment: 'No effective chemical control. Rotate crops. Use resistant varieties. Treat with nematicide at planting.',
      actionSteps: [
        'Rotate to non-host crops for minimum 6 years',
        'Plant nematode-resistant potato varieties',
        'Apply nematicide (aldicarb or oxamyl) at planting if legal',
      ],
      requiresManualInspection: true,
      disclaimer: 'Cyst nematodes are identified in soil, not on leaves. Visual leaf scan may be inconclusive — soil testing recommended.',
    ),
    'potato_potato_virus': CropDiseaseKnowledge(
      displayName: 'Potato Virus',
      cropType: 'Potato',
      healthStatus: 'Critical',
      visualSigns: 'Mosaic, mottling, or yellowing patterns on leaves. Leaf roll, crinkling, or stunted growth.',
      treatment: 'No cure. Remove infected plants. Control aphid vectors. Use certified seed potatoes.',
      actionSteps: [
        'Remove and destroy infected plants',
        'Control aphids with systemic insecticide (imidacloprid)',
        'Use certified virus-free seed potatoes',
        'Disinfect tools between plants',
      ],
    ),

    // ── RICE ──
    'rice_bacterial_blight': CropDiseaseKnowledge(
      displayName: 'Rice Bacterial Blight',
      cropType: 'Rice',
      healthStatus: 'Critical',
      visualSigns: 'Water-soaked lesions on leaf margins that turn yellow then whitish-gray. "Kresek" (wilting of seedlings) in severe cases.',
      treatment: 'Apply copper-based bactericide. Use resistant varieties. Avoid excess nitrogen.',
      actionSteps: [
        'Drain field to reduce spread in flood water',
        'Apply copper oxychloride spray',
        'Reduce nitrogen fertilizer — excess N increases susceptibility',
        'Plant resistant rice varieties (check IRRI database)',
      ],
    ),
    'rice_brown_spot': CropDiseaseKnowledge(
      displayName: 'Rice Brown Spot',
      cropType: 'Rice',
      healthStatus: 'Warning',
      visualSigns: 'Oval to circular brown spots with gray or white centers on leaves and grains. Often indicates nutrient deficiency.',
      treatment: 'Apply mancozeb or iprodione fungicide. Correct soil nutrient deficiencies (especially potassium).',
      actionSteps: [
        'Apply potassium fertilizer — brown spot is linked to K deficiency',
        'Apply mancozeb fungicide (2g/L) if symptoms are severe',
        'Use balanced fertilization based on soil test',
        'Avoid water stress during tillering stage',
      ],
    ),
    'rice_leaf_smut': CropDiseaseKnowledge(
      displayName: 'Rice Leaf Smut',
      cropType: 'Rice',
      healthStatus: 'Warning',
      visualSigns: 'Linear black streaks (smut pustules) on leaves and sheaths. Black powdery mass when pustules break open.',
      treatment: 'Apply mancozeb or propiconazole. Use clean, treated seed.',
      actionSteps: [
        'Treat seed with carbendazim before planting',
        'Apply mancozeb at early signs of symptom',
        'Avoid ratoon cropping from infected fields',
        'Remove and burn infected stubble after harvest',
      ],
    ),

    // ── TOMATO ──
    'tomato_bacterial_spot': CropDiseaseKnowledge(
      displayName: 'Tomato Bacterial Spot',
      cropType: 'Tomato',
      healthStatus: 'Warning',
      visualSigns: 'Small, water-soaked spots on leaves that turn dark brown with yellow halos. Raised, scab-like spots on fruits.',
      treatment: 'Apply copper-based bactericide + mancozeb. Avoid overhead irrigation. Use disease-free transplants.',
      actionSteps: [
        'Apply copper hydroxide + mancozeb mix every 7 days',
        'Remove infected leaves and fruits',
        'Switch to drip irrigation — avoid wetting foliage',
        'Use disease-free, certified transplants',
      ],
    ),
    'tomato_early_blight': CropDiseaseKnowledge(
      displayName: 'Tomato Early Blight',
      cropType: 'Tomato',
      healthStatus: 'Warning',
      visualSigns: 'Dark brown concentric rings (bullseye pattern) on older lower leaves. Yellow halo surrounds lesions.',
      treatment: 'Apply chlorothalonil or mancozeb fungicide. Remove infected lower leaves. Mulch soil to prevent splash.',
      actionSteps: [
        'Apply chlorothalonil or mancozeb every 7 days',
        'Remove and discard infected lower leaves',
        'Mulch around plants to prevent soil splash',
        'Avoid overhead watering — use drip or furrow irrigation',
      ],
    ),
    'tomato_healthy': CropDiseaseKnowledge(
      displayName: 'Healthy Tomato',
      cropType: 'Tomato',
      healthStatus: 'Healthy',
      visualSigns: 'Dark green compound leaves, vigorous stems, no discoloration or lesions.',
      treatment: 'No treatment needed.',
      actionSteps: [
        'Continue weekly scouting for early disease signs',
        'Maintain consistent irrigation — irregular watering causes blossom end rot',
        'Support plants with stakes or cages',
      ],
    ),
    'tomato_late_blight': CropDiseaseKnowledge(
      displayName: 'Tomato Late Blight',
      cropType: 'Tomato',
      healthStatus: 'Critical',
      visualSigns: 'Greasy-looking dark patches on leaves rapidly turning black. White mold on undersides. Fruit shows firm brown rot.',
      treatment: 'Apply metalaxyl + mancozeb IMMEDIATELY. This disease can destroy a crop within a week.',
      actionSteps: [
        'Apply Ridomil Gold (metalaxyl + mancozeb) immediately',
        'Remove and destroy all affected plant material',
        'Harvest any fruits at risk and process or sell quickly',
        'Do NOT touch healthy plants after handling infected ones',
      ],
      disclaimer: 'Late blight is extremely destructive — act within 24 hours of detection.',
    ),
    'tomato_leaf_blight': CropDiseaseKnowledge(
      displayName: 'Tomato Leaf Blight',
      cropType: 'Tomato',
      healthStatus: 'Warning',
      visualSigns: 'Dark, irregular necrotic patches on leaves. Affected areas dry out and may fall out, creating a "shot-hole" effect.',
      treatment: 'Apply mancozeb or copper fungicide. Improve drainage and airflow.',
      actionSteps: [
        'Apply mancozeb (2g/L) preventively every 10 days',
        'Remove dead leaf material from field',
        'Improve plant spacing for better airflow',
      ],
    ),
    'tomato_leaf_mold': CropDiseaseKnowledge(
      displayName: 'Tomato Leaf Mold',
      cropType: 'Tomato',
      healthStatus: 'Warning',
      visualSigns: 'Pale yellow spots on upper leaf surface. Olive-green to brown velvety mold growth on undersides of leaves.',
      treatment: 'Apply chlorothalonil or copper fungicide. Reduce humidity — improve greenhouse ventilation.',
      actionSteps: [
        'Improve ventilation — leaf mold thrives in humid, enclosed spaces',
        'Apply chlorothalonil or copper fungicide',
        'Reduce overhead irrigation',
        'Remove infected leaves promptly',
      ],
    ),
    'tomato_mosaic_virus': CropDiseaseKnowledge(
      displayName: 'Tomato Mosaic Virus',
      cropType: 'Tomato',
      healthStatus: 'Critical',
      visualSigns: 'Mosaic of light and dark green on leaves. Leaf distortion, fern-like or filiform leaves. Stunted plants.',
      treatment: 'No cure. Remove and destroy infected plants. Wash hands before handling healthy plants.',
      actionSteps: [
        'Remove and destroy infected plants — wear gloves',
        'Wash hands thoroughly before touching healthy plants',
        'Disinfect all tools with 10% bleach solution',
        'Control aphids and whiteflies (virus vectors) with insecticide',
        'Use certified virus-free transplants next season',
      ],
    ),
    'tomato_septoria_leaf_spot': CropDiseaseKnowledge(
      displayName: 'Tomato Septoria Leaf Spot',
      cropType: 'Tomato',
      healthStatus: 'Warning',
      visualSigns: 'Many small, circular spots with white centers and dark margins on lower leaves. Black dots (pycnidia) visible in spot centers.',
      treatment: 'Apply chlorothalonil, copper, or mancozeb fungicide. Remove infected lower leaves immediately.',
      actionSteps: [
        'Remove and destroy all infected leaves',
        'Apply chlorothalonil or mancozeb every 7–10 days',
        'Avoid wetting foliage — use drip irrigation',
        'Mulch around the base to prevent soil splash',
      ],
    ),
    'tomato_spider_mite': CropDiseaseKnowledge(
      displayName: 'Tomato Spider Mite',
      cropType: 'Tomato',
      healthStatus: 'Warning',
      visualSigns: 'Stippled, bronzed or silvery leaves. Fine webbing on leaf undersides. Leaves dry out and drop in severe cases.',
      treatment: 'Apply abamectin or spiromesifen acaricide. Increase humidity. Spray with water to dislodge mites.',
      actionSteps: [
        'Apply abamectin or spiromesifen acaricide to leaf undersides',
        'Increase humidity with misting — mites prefer dry conditions',
        'Spray forceful water jets on leaf undersides to reduce mite numbers',
        'Avoid overapplying nitrogen — lush growth attracts mites',
      ],
      requiresManualInspection: true,
    ),
    'tomato_target_spot': CropDiseaseKnowledge(
      displayName: 'Tomato Target Spot',
      cropType: 'Tomato',
      healthStatus: 'Warning',
      visualSigns: 'Circular lesions with concentric rings (target appearance) on leaves, stems, and fruits. Dark brown color.',
      treatment: 'Apply azoxystrobin or chlorothalonil fungicide. Remove crop debris.',
      actionSteps: [
        'Apply azoxystrobin or chlorothalonil fungicide',
        'Remove and discard infected plant material',
        'Improve plant spacing for better airflow',
        'Use crop rotation next season',
      ],
    ),
    'tomato_verticillium_wilt': CropDiseaseKnowledge(
      displayName: 'Tomato Verticillium Wilt',
      cropType: 'Tomato',
      healthStatus: 'Critical',
      visualSigns: 'V-shaped yellow lesions starting at leaf margins. Leaves wilt and yellow from bottom up. Brown vascular discoloration in stem cross-section.',
      treatment: 'No effective treatment once infected. Remove plants. Use resistant varieties and soil solarization.',
      actionSteps: [
        'Remove and destroy infected plants — soil is now contaminated',
        'Apply soil solarization (cover wet soil with clear plastic for 4–6 weeks in sun)',
        'Plant only Verticillium-resistant (V-rated) varieties next season',
        'Rotate to non-solanaceous crops for 3–4 seasons',
      ],
      disclaimer: 'Verticillium wilt persists in soil for years — rotation and resistant varieties are the only long-term solutions.',
    ),
    'tomato_yellow_leaf_curl_virus': CropDiseaseKnowledge(
      displayName: 'Tomato Yellow Leaf Curl Virus',
      cropType: 'Tomato',
      healthStatus: 'Critical',
      visualSigns: 'Upward curling and yellowing of leaves, especially young leaves. Stunted growth, flower drop, severely reduced yield.',
      treatment: 'No cure. Remove infected plants. Control whitefly vectors aggressively. This is a model strength class.',
      actionSteps: [
        'Remove infected plants to prevent whitefly spread',
        'Apply imidacloprid or thiamethoxam for whitefly control',
        'Use yellow sticky traps to monitor whitefly populations',
        'Install reflective mulches to deter whiteflies',
        'Plant TYLCV-resistant varieties next season',
      ],
    ),
  };

  /// Look up disease knowledge by model label key.
  /// Returns a default entry if the label is not found.
  static CropDiseaseKnowledge lookup(String labelKey) {
    return _db[labelKey] ?? CropDiseaseKnowledge(
      displayName: _humanize(labelKey),
      cropType: _extractCrop(labelKey),
      healthStatus: labelKey.contains('healthy') ? 'Healthy' : 'Warning',
      visualSigns: 'Inspect leaves and stems for unusual spots, lesions, or discoloration.',
      treatment: 'Consult your local agricultural extension officer for specific treatment.',
      actionSteps: ['Contact local agricultural extension office for expert diagnosis.'],
    );
  }

  static String _humanize(String label) {
    return label
        .replaceAll('maize2nd_', 'maize_')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  static String _extractCrop(String label) {
    if (label.startsWith('beans')) return 'Beans';
    if (label.startsWith('cashew')) return 'Cashew';
    if (label.startsWith('cassava')) return 'Cassava';
    if (label.startsWith('maize')) return 'Maize';
    if (label.startsWith('potato')) return 'Potato';
    if (label.startsWith('rice')) return 'Rice';
    if (label.startsWith('tomato')) return 'Tomato';
    return 'Unknown Crop';
  }
}
