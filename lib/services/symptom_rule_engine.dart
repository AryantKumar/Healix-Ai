/// Offline symptom rule engine for basic symptom analysis.
/// This provides health guidance when the device is offline.
class SymptomRuleEngine {
  static final SymptomRuleEngine _instance = SymptomRuleEngine._internal();
  factory SymptomRuleEngine() => _instance;
  SymptomRuleEngine._internal();

  /// Symptom database - maps symptoms to conditions with advice
  static final Map<String, List<_SymptomCondition>> _rules = {
    'fever': [
      _SymptomCondition(
        condition: 'Common Cold / Flu',
        description: 'Fever is commonly associated with viral infections like the common cold or influenza.',
        severity: 'Mild to Moderate',
        advice: [
          'Rest and stay hydrated',
          'Take paracetamol/acetaminophen for fever',
          'Monitor temperature regularly',
          'If fever exceeds 103°F (39.4°C) or persists beyond 3 days, see a doctor',
        ],
        seeDoctor: false,
      ),
    ],
    'headache': [
      _SymptomCondition(
        condition: 'Tension Headache',
        description: 'Most common type of headache, often caused by stress, dehydration, or lack of sleep.',
        severity: 'Mild',
        advice: [
          'Rest in a quiet, dark room',
          'Stay hydrated — drink water',
          'Try over-the-counter pain relief',
          'Apply a cold compress to your forehead',
        ],
        seeDoctor: false,
      ),
    ],
    'cough': [
      _SymptomCondition(
        condition: 'Upper Respiratory Infection',
        description: 'Coughing is usually caused by a viral infection in the upper respiratory tract.',
        severity: 'Mild to Moderate',
        advice: [
          'Stay hydrated with warm fluids',
          'Use honey and lemon in warm water',
          'Avoid smoking and irritants',
          'If cough persists beyond 2 weeks or produces blood, see a doctor immediately',
        ],
        seeDoctor: false,
      ),
    ],
    'sore throat': [
      _SymptomCondition(
        condition: 'Pharyngitis',
        description: 'Sore throat often accompanies viral infections. Could also indicate bacterial infection (strep).',
        severity: 'Mild to Moderate',
        advice: [
          'Gargle with warm salt water',
          'Drink warm liquids',
          'Use throat lozenges',
          'If accompanied by high fever or white patches, see a doctor',
        ],
        seeDoctor: false,
      ),
    ],
    'stomach pain': [
      _SymptomCondition(
        condition: 'Gastritis / Indigestion',
        description: 'Stomach pain can result from indigestion, acidity, or gastritis.',
        severity: 'Mild',
        advice: [
          'Avoid spicy and oily foods',
          'Eat small, frequent meals',
          'Try antacids if available',
          'If pain is severe, persistent, or accompanied by vomiting blood, seek emergency care',
        ],
        seeDoctor: false,
      ),
    ],
    'nausea': [
      _SymptomCondition(
        condition: 'Gastric Distress',
        description: 'Nausea can be caused by food issues, motion sickness, or viral infections.',
        severity: 'Mild',
        advice: [
          'Sip clear fluids slowly',
          'Avoid solid food until nausea passes',
          'Try ginger tea or peppermint',
          'Rest in a comfortable position',
        ],
        seeDoctor: false,
      ),
    ],
    'vomiting': [
      _SymptomCondition(
        condition: 'Gastroenteritis',
        description: 'Vomiting is often caused by food poisoning or viral gastroenteritis.',
        severity: 'Moderate',
        advice: [
          'Stay hydrated with ORS or clear fluids',
          'Avoid solid food for a few hours',
          'Seek medical help if vomiting persists beyond 24 hours',
          'Watch for signs of dehydration',
        ],
        seeDoctor: true,
      ),
    ],
    'diarrhea': [
      _SymptomCondition(
        condition: 'Gastroenteritis / Food Poisoning',
        description: 'Diarrhea can result from viral infections, bacterial infections, or contaminated food/water.',
        severity: 'Moderate',
        advice: [
          'Drink ORS (Oral Rehydration Solution)',
          'Eat bland foods like rice, bananas, toast',
          'Avoid dairy and fatty foods',
          'Seek medical attention if blood in stool or dehydration signs appear',
        ],
        seeDoctor: true,
      ),
    ],
    'chest pain': [
      _SymptomCondition(
        condition: 'Possible Cardiac Issue',
        description: 'Chest pain can indicate serious conditions including heart problems. This requires immediate medical attention.',
        severity: 'Severe',
        advice: [
          'SEEK IMMEDIATE MEDICAL ATTENTION',
          'Call emergency services if accompanied by shortness of breath, sweating, or arm pain',
          'Do not exert yourself',
          'Chew an aspirin if available and not allergic',
        ],
        seeDoctor: true,
      ),
    ],
    'breathing difficulty': [
      _SymptomCondition(
        condition: 'Respiratory Distress',
        description: 'Difficulty breathing can be caused by asthma, allergies, anxiety, or serious conditions.',
        severity: 'Severe',
        advice: [
          'Sit upright in a comfortable position',
          'If you have an inhaler, use it',
          'Call emergency services for severe breathing difficulty',
          'Stay calm and try to breathe slowly',
        ],
        seeDoctor: true,
      ),
    ],
    'body pain': [
      _SymptomCondition(
        condition: 'Viral Infection / Fatigue',
        description: 'Generalized body pain often accompanies viral infections or results from physical exertion.',
        severity: 'Mild',
        advice: [
          'Rest and get adequate sleep',
          'Stay hydrated',
          'Take over-the-counter pain relief if needed',
          'Warm compress can help relieve muscle pain',
        ],
        seeDoctor: false,
      ),
    ],
    'fatigue': [
      _SymptomCondition(
        condition: 'Exhaustion / Nutritional Deficiency',
        description: 'Persistent fatigue can indicate nutritional deficiencies, anemia, or underlying health conditions.',
        severity: 'Mild',
        advice: [
          'Get 7-9 hours of sleep nightly',
          'Eat a balanced diet rich in iron and vitamins',
          'Stay physically active with light exercise',
          'If fatigue persists beyond 2 weeks, consult a doctor',
        ],
        seeDoctor: false,
      ),
    ],
    'dizziness': [
      _SymptomCondition(
        condition: 'Low Blood Pressure / Dehydration',
        description: 'Dizziness can be caused by dehydration, low blood pressure, or inner ear issues.',
        severity: 'Mild to Moderate',
        advice: [
          'Sit or lie down immediately',
          'Drink water or fluids with electrolytes',
          'Move slowly when changing positions',
          'If frequent or accompanied by fainting, see a doctor',
        ],
        seeDoctor: false,
      ),
    ],
    'rash': [
      _SymptomCondition(
        condition: 'Allergic Reaction / Dermatitis',
        description: 'Skin rashes can result from allergies, irritants, or infections.',
        severity: 'Mild to Moderate',
        advice: [
          'Avoid scratching the affected area',
          'Apply calamine lotion or hydrocortisone cream',
          'Take antihistamines if allergic reaction suspected',
          'If rash spreads rapidly or causes swelling, seek emergency care',
        ],
        seeDoctor: false,
      ),
    ],
    'cold': [
      _SymptomCondition(
        condition: 'Common Cold',
        description: 'The common cold is a viral infection of the upper respiratory tract.',
        severity: 'Mild',
        advice: [
          'Rest and stay warm',
          'Drink warm fluids (soup, tea, water)',
          'Use saline nasal drops for congestion',
          'Most colds resolve in 7-10 days',
        ],
        seeDoctor: false,
      ),
    ],
    'back pain': [
      _SymptomCondition(
        condition: 'Muscle Strain / Poor Posture',
        description: 'Back pain is commonly caused by muscle strain, poor posture, or prolonged sitting.',
        severity: 'Mild to Moderate',
        advice: [
          'Apply hot or cold compress',
          'Maintain good posture',
          'Do gentle stretching exercises',
          'If pain radiates to legs or is severe, consult a doctor',
        ],
        seeDoctor: false,
      ),
    ],
    'joint pain': [
      _SymptomCondition(
        condition: 'Arthritis / Strain',
        description: 'Joint pain can result from arthritis, injury, or overuse.',
        severity: 'Mild to Moderate',
        advice: [
          'Rest the affected joint',
          'Apply ice for swelling, heat for stiffness',
          'Gentle range-of-motion exercises can help',
          'If joints are swollen, red, or warm, see a doctor',
        ],
        seeDoctor: false,
      ),
    ],
    'eye pain': [
      _SymptomCondition(
        condition: 'Eye Strain / Conjunctivitis',
        description: 'Eye pain can be caused by screen strain, infections, or foreign bodies.',
        severity: 'Mild',
        advice: [
          'Rest your eyes — follow the 20-20-20 rule',
          'Apply warm compress to closed eyes',
          'Avoid rubbing your eyes',
          'If vision is affected or pain is severe, see an eye doctor',
        ],
        seeDoctor: false,
      ),
    ],
    'ear pain': [
      _SymptomCondition(
        condition: 'Ear Infection / Wax Build-up',
        description: 'Ear pain can result from infections, wax build-up, or pressure changes.',
        severity: 'Mild to Moderate',
        advice: [
          'Apply a warm cloth to the ear',
          'Take pain relief medication',
          'Do not insert objects into the ear',
          'See a doctor if pain is severe or accompanied by discharge',
        ],
        seeDoctor: false,
      ),
    ],
    'anxiety': [
      _SymptomCondition(
        condition: 'Anxiety / Stress Response',
        description: 'Anxiety symptoms include worry, restlessness, rapid heartbeat, and difficulty concentrating.',
        severity: 'Mild to Moderate',
        advice: [
          'Practice deep breathing exercises',
          'Try grounding techniques (5-4-3-2-1 method)',
          'Engage in physical activity',
          'Consider speaking with a mental health professional',
        ],
        seeDoctor: false,
      ),
    ],
    'insomnia': [
      _SymptomCondition(
        condition: 'Sleep Disorder',
        description: 'Difficulty falling or staying asleep can be caused by stress, poor habits, or health conditions.',
        severity: 'Mild',
        advice: [
          'Maintain a regular sleep schedule',
          'Avoid screens 1 hour before bed',
          'Limit caffeine intake after noon',
          'Create a dark, quiet sleep environment',
        ],
        seeDoctor: false,
      ),
    ],
  };

  /// Analyze user symptoms and return structured advice
  String analyzeSymptoms(String userInput) {
    final input = userInput.toLowerCase();
    final matchedConditions = <_SymptomCondition>[];
    final matchedSymptoms = <String>[];

    for (final entry in _rules.entries) {
      if (input.contains(entry.key)) {
        matchedSymptoms.add(entry.key);
        matchedConditions.addAll(entry.value);
      }
    }

    if (matchedConditions.isEmpty) {
      return _buildNoMatchResponse();
    }

    return _buildResponse(matchedSymptoms, matchedConditions);
  }

  String _buildResponse(
      List<String> symptoms, List<_SymptomCondition> conditions) {
    final buffer = StringBuffer();

    buffer.writeln('🔍 **Symptom Analysis** (Offline Mode)\n');
    buffer.writeln(
        'Based on your symptoms: ${symptoms.map((s) => "**$s**").join(", ")}\n');

    bool needsDoctor = false;

    for (int i = 0; i < conditions.length; i++) {
      final c = conditions[i];
      buffer.writeln('---');
      buffer.writeln('**Possible Condition:** ${c.condition}');
      buffer.writeln('**Severity:** ${c.severity}');
      buffer.writeln('${c.description}\n');
      buffer.writeln('**Recommended Actions:**');
      for (final advice in c.advice) {
        buffer.writeln('• $advice');
      }
      buffer.writeln();

      if (c.seeDoctor) needsDoctor = true;
    }

    if (needsDoctor) {
      buffer.writeln('---');
      buffer.writeln(
          '⚠️ **Based on your symptoms, we strongly recommend consulting a healthcare professional as soon as possible.**');
    }

    return buffer.toString();
  }

  String _buildNoMatchResponse() {
    return '''🔍 **Symptom Analysis** (Offline Mode)

I couldn't identify specific conditions from your description. Here are some general recommendations:

• If you're feeling unwell, rest and stay hydrated
• Monitor your symptoms and note any changes
• If symptoms are severe or worsening, please visit a doctor
• Try describing your symptoms with common terms like: fever, headache, cough, stomach pain, chest pain, etc.

**Common symptoms I can help with:**
Fever, Headache, Cough, Sore Throat, Stomach Pain, Nausea, Vomiting, Diarrhea, Chest Pain, Breathing Difficulty, Body Pain, Fatigue, Dizziness, Rash, Cold, Back Pain, Joint Pain, Eye Pain, Ear Pain, Anxiety, Insomnia''';
  }
}

class _SymptomCondition {
  final String condition;
  final String description;
  final String severity;
  final List<String> advice;
  final bool seeDoctor;

  const _SymptomCondition({
    required this.condition,
    required this.description,
    required this.severity,
    required this.advice,
    required this.seeDoctor,
  });
}
