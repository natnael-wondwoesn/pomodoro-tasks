class QuizQuestion {
  final String text;
  final List<QuizOption> options;

  const QuizQuestion({required this.text, required this.options});
}

class QuizOption {
  final String text;
  final String category;

  const QuizOption({required this.text, required this.category});
}

class QuizDefinition {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<QuizQuestion> questions;
  final Map<String, String> resultDescriptions;

  const QuizDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.questions,
    required this.resultDescriptions,
  });

  String calculateResult(List<int> answers) {
    final counts = <String, int>{};
    for (var i = 0; i < answers.length && i < questions.length; i++) {
      final category = questions[i].options[answers[i]].category;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class QuizPool {
  QuizPool._();

  static const List<QuizDefinition> quizzes = [
    _loveLanguages,
    _communicationStyle,
    _conflictStyle,
    _funCompatibility,
  ];

  static const _loveLanguages = QuizDefinition(
    id: 'love_languages',
    title: 'Love Languages',
    description: 'Discover how you prefer to give and receive love.',
    emoji: '\u2764\uFE0F',
    resultDescriptions: {
      'words': 'Words of Affirmation \u2014 You feel most loved through verbal compliments, encouragement, and hearing "I love you."',
      'acts': 'Acts of Service \u2014 You feel most loved when your partner does helpful things for you, like cooking or running errands.',
      'gifts': 'Receiving Gifts \u2014 You feel most loved through thoughtful presents and symbols of affection.',
      'time': 'Quality Time \u2014 You feel most loved when your partner gives you undivided attention and presence.',
      'touch': 'Physical Touch \u2014 You feel most loved through hugs, holding hands, and physical closeness.',
    },
    questions: [
      QuizQuestion(text: 'I feel most appreciated when my partner...', options: [
        QuizOption(text: 'Tells me they are proud of me', category: 'words'),
        QuizOption(text: 'Helps me with a chore without asking', category: 'acts'),
        QuizOption(text: 'Gives me a thoughtful small gift', category: 'gifts'),
        QuizOption(text: 'Spends quality one-on-one time with me', category: 'time'),
        QuizOption(text: 'Gives me a long hug', category: 'touch'),
      ]),
      QuizQuestion(text: 'On a bad day, I would most want my partner to...', options: [
        QuizOption(text: 'Say encouraging words', category: 'words'),
        QuizOption(text: 'Take something off my plate', category: 'acts'),
        QuizOption(text: 'Bring me my favorite treat', category: 'gifts'),
        QuizOption(text: 'Sit with me and listen', category: 'time'),
        QuizOption(text: 'Hold me close', category: 'touch'),
      ]),
      QuizQuestion(text: 'I feel disconnected when...', options: [
        QuizOption(text: 'We go days without saying anything kind', category: 'words'),
        QuizOption(text: 'I feel like I do everything alone', category: 'acts'),
        QuizOption(text: 'Special occasions go unacknowledged', category: 'gifts'),
        QuizOption(text: 'We are always too busy for each other', category: 'time'),
        QuizOption(text: 'There is no physical affection', category: 'touch'),
      ]),
      QuizQuestion(text: 'The most romantic thing my partner could do is...', options: [
        QuizOption(text: 'Write me a heartfelt note', category: 'words'),
        QuizOption(text: 'Plan and cook a special dinner', category: 'acts'),
        QuizOption(text: 'Surprise me with something meaningful', category: 'gifts'),
        QuizOption(text: 'Plan a day just for us', category: 'time'),
        QuizOption(text: 'Give me a massage', category: 'touch'),
      ]),
      QuizQuestion(text: 'I show love by...', options: [
        QuizOption(text: 'Complimenting and affirming them', category: 'words'),
        QuizOption(text: 'Doing things to make their life easier', category: 'acts'),
        QuizOption(text: 'Finding the perfect gift', category: 'gifts'),
        QuizOption(text: 'Making time to be together', category: 'time'),
        QuizOption(text: 'Being physically close and affectionate', category: 'touch'),
      ]),
    ],
  );

  static const _communicationStyle = QuizDefinition(
    id: 'communication',
    title: 'Communication Style',
    description: 'Learn how you naturally communicate in relationships.',
    emoji: '\u{1F4AC}',
    resultDescriptions: {
      'direct': 'Direct \u2014 You say what you mean clearly and value honesty above diplomacy.',
      'diplomatic': 'Diplomatic \u2014 You consider others\u2019 feelings and choose your words carefully.',
      'analytical': 'Analytical \u2014 You prefer logic, facts, and thinking before speaking.',
      'expressive': 'Expressive \u2014 You communicate with emotion, energy, and enthusiasm.',
    },
    questions: [
      QuizQuestion(text: 'When I have a concern, I usually...', options: [
        QuizOption(text: 'Say it directly right away', category: 'direct'),
        QuizOption(text: 'Find the right time and words', category: 'diplomatic'),
        QuizOption(text: 'Think about it before bringing it up', category: 'analytical'),
        QuizOption(text: 'Express how it makes me feel', category: 'expressive'),
      ]),
      QuizQuestion(text: 'In a disagreement, I tend to...', options: [
        QuizOption(text: 'State my position clearly', category: 'direct'),
        QuizOption(text: 'Look for common ground', category: 'diplomatic'),
        QuizOption(text: 'Present logical arguments', category: 'analytical'),
        QuizOption(text: 'Share how I feel about it', category: 'expressive'),
      ]),
      QuizQuestion(text: 'I prefer when my partner...', options: [
        QuizOption(text: 'Gets straight to the point', category: 'direct'),
        QuizOption(text: 'Is thoughtful about delivery', category: 'diplomatic'),
        QuizOption(text: 'Explains their reasoning', category: 'analytical'),
        QuizOption(text: 'Shares their emotions openly', category: 'expressive'),
      ]),
      QuizQuestion(text: 'When making decisions together, I...', options: [
        QuizOption(text: 'State my preference and decide quickly', category: 'direct'),
        QuizOption(text: 'Make sure we both feel heard', category: 'diplomatic'),
        QuizOption(text: 'Weigh pros and cons carefully', category: 'analytical'),
        QuizOption(text: 'Go with what feels right', category: 'expressive'),
      ]),
      QuizQuestion(text: 'My texts tend to be...', options: [
        QuizOption(text: 'Short and to the point', category: 'direct'),
        QuizOption(text: 'Warm and considerate', category: 'diplomatic'),
        QuizOption(text: 'Detailed and informative', category: 'analytical'),
        QuizOption(text: 'Full of emojis and enthusiasm', category: 'expressive'),
      ]),
    ],
  );

  static const _conflictStyle = QuizDefinition(
    id: 'conflict',
    title: 'Conflict Style',
    description: 'Understand how you handle disagreements.',
    emoji: '\u{1F91D}',
    resultDescriptions: {
      'collaborator': 'Collaborator \u2014 You work together to find a solution that satisfies both partners fully.',
      'compromiser': 'Compromiser \u2014 You meet in the middle, willing to give up something so both can be satisfied.',
      'accommodator': 'Accommodator \u2014 You prioritize harmony and your partner\u2019s needs, sometimes over your own.',
      'avoider': 'Avoider \u2014 You prefer to let things cool down and avoid confrontation when possible.',
    },
    questions: [
      QuizQuestion(text: 'When we disagree, my first instinct is to...', options: [
        QuizOption(text: 'Work together until we find a win-win', category: 'collaborator'),
        QuizOption(text: 'Find a middle ground quickly', category: 'compromiser'),
        QuizOption(text: 'Let them have their way to keep peace', category: 'accommodator'),
        QuizOption(text: 'Take a step back and cool off', category: 'avoider'),
      ]),
      QuizQuestion(text: 'After an argument, I usually...', options: [
        QuizOption(text: 'Want to talk it through completely', category: 'collaborator'),
        QuizOption(text: 'Suggest we both give a little', category: 'compromiser'),
        QuizOption(text: 'Apologize to restore harmony', category: 'accommodator'),
        QuizOption(text: 'Need space before reconnecting', category: 'avoider'),
      ]),
      QuizQuestion(text: 'I believe the best conflicts end with...', options: [
        QuizOption(text: 'Both people fully satisfied', category: 'collaborator'),
        QuizOption(text: 'A fair compromise', category: 'compromiser'),
        QuizOption(text: 'My partner feeling heard and happy', category: 'accommodator'),
        QuizOption(text: 'Peace and quiet restored', category: 'avoider'),
      ]),
      QuizQuestion(text: 'If my partner is upset about something small, I...', options: [
        QuizOption(text: 'Explore why it matters to them', category: 'collaborator'),
        QuizOption(text: 'Offer a quick fix we can both live with', category: 'compromiser'),
        QuizOption(text: 'Just do it their way, it is not worth fighting', category: 'accommodator'),
        QuizOption(text: 'Hope it blows over', category: 'avoider'),
      ]),
      QuizQuestion(text: 'My partner would say I handle conflict by...', options: [
        QuizOption(text: 'Talking it out until it is resolved', category: 'collaborator'),
        QuizOption(text: 'Being fair and reasonable', category: 'compromiser'),
        QuizOption(text: 'Putting their feelings first', category: 'accommodator'),
        QuizOption(text: 'Going quiet for a while', category: 'avoider'),
      ]),
    ],
  );

  static const _funCompatibility = QuizDefinition(
    id: 'fun_compat',
    title: 'Fun Compatibility',
    description: 'See how your preferences match up!',
    emoji: '\u{1F389}',
    resultDescriptions: {
      'adventurer': 'Adventurer \u2014 You love trying new things, spontaneity, and excitement.',
      'homebody': 'Homebody \u2014 You prefer comfort, routine, and cozy nights in.',
      'planner': 'Planner \u2014 You like structure, organization, and knowing what is ahead.',
      'free_spirit': 'Free Spirit \u2014 You go with the flow and let life surprise you.',
    },
    questions: [
      QuizQuestion(text: 'Ideal Friday night?', options: [
        QuizOption(text: 'Try a new restaurant or event', category: 'adventurer'),
        QuizOption(text: 'Movie and takeout at home', category: 'homebody'),
        QuizOption(text: 'Something we planned earlier this week', category: 'planner'),
        QuizOption(text: 'Whatever feels right in the moment', category: 'free_spirit'),
      ]),
      QuizQuestion(text: 'On vacation, I prefer to...', options: [
        QuizOption(text: 'Explore and see everything possible', category: 'adventurer'),
        QuizOption(text: 'Relax at the hotel or beach', category: 'homebody'),
        QuizOption(text: 'Follow a detailed itinerary', category: 'planner'),
        QuizOption(text: 'Wander with no plan', category: 'free_spirit'),
      ]),
      QuizQuestion(text: 'Morning routine?', options: [
        QuizOption(text: 'Up early, ready for adventure', category: 'adventurer'),
        QuizOption(text: 'Slow morning, coffee in bed', category: 'homebody'),
        QuizOption(text: 'Same time every day, structured', category: 'planner'),
        QuizOption(text: 'Depends on how I feel', category: 'free_spirit'),
      ]),
      QuizQuestion(text: 'Best surprise from partner?', options: [
        QuizOption(text: 'Spontaneous trip somewhere new', category: 'adventurer'),
        QuizOption(text: 'A cozy setup at home', category: 'homebody'),
        QuizOption(text: 'A well-thought-out plan', category: 'planner'),
        QuizOption(text: 'Something totally unexpected', category: 'free_spirit'),
      ]),
      QuizQuestion(text: 'How do you handle a free weekend?', options: [
        QuizOption(text: 'Find something exciting to do', category: 'adventurer'),
        QuizOption(text: 'Stay home and recharge', category: 'homebody'),
        QuizOption(text: 'Plan activities in advance', category: 'planner'),
        QuizOption(text: 'See what comes up', category: 'free_spirit'),
      ]),
    ],
  );
}
