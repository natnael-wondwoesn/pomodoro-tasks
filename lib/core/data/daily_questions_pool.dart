class DailyQuestionPool {
  DailyQuestionPool._();

  static const List<String> questions = [
    // Fun
    "What's one thing I do that always makes you smile?",
    "If we could travel anywhere tomorrow, where would you pick?",
    "What song reminds you of us?",
    "What's the funniest memory we share?",
    "If we had a couples superpower, what would it be?",
    "What's one food you'd never share with me?",
    "What would our couple reality show be called?",
    "If you could relive one day with me, which one?",
    "What animal best represents our relationship?",
    "What's your favorite outfit I wear?",
    "If we were in a movie, what genre would it be?",
    "What's a hobby you'd love for us to try together?",
    "What would you name our imaginary pet?",
    "What's your favorite lazy day activity with me?",
    "If we opened a business together, what would it be?",

    // Deep
    "What's a small thing I did recently that meant a lot to you?",
    "What's one dream you haven't told me about yet?",
    "What's something I do that makes you feel truly loved?",
    "What's one thing you admire most about me?",
    "When do you feel most connected to me?",
    "What's a fear you'd like us to overcome together?",
    "How have I helped you grow as a person?",
    "What's one thing you'd like us to do more of?",
    "What does home feel like to you?",
    "What's a value we share that makes us strong?",
    "When did you first know I was special to you?",
    "What's something you've learned from me?",
    "What's a challenge we handled well together?",
    "How do you feel most supported by me?",
    "What's one prayer you have for our future?",

    // Memories
    "What's your favorite date we've been on?",
    "What's a moment with me you'll never forget?",
    "What was your first impression of me?",
    "What's the best surprise I've ever given you?",
    "What's a tough moment that made us stronger?",
    "What's your favorite photo of us and why?",
    "What's the best meal we've shared?",
    "What trip together was your favorite?",
    "What's a silly argument we had that makes you laugh now?",
    "What's the most thoughtful thing I've done for you?",
    "What's a tradition of ours that you love?",
    "What moment made you proudest of us?",
    "What's your favorite thing we've built together?",
    "What adventure do you want us to have next?",
    "What's the best gift I've given you?",

    // Dreams
    "Where do you see us in 5 years?",
    "What's one goal you want us to achieve together?",
    "If money wasn't a factor, how would we spend next year?",
    "What kind of home do you dream of for us?",
    "What legacy do you want us to leave?",
    "What's one experience on your bucket list for us?",
    "How do you want us to celebrate our next milestone?",
    "What new skill would you love for us both to learn?",
    "If we could live anywhere for a year, where?",
    "What does your ideal weekend with me look like?",
    "What's a tradition you want us to start?",
    "What do you want our mornings to look like?",
    "How do you want to grow spiritually together?",
    "What cause would you want us to champion together?",
    "What's the wildest dream you have for us?",

    // Preferences
    "Morning person or night owl, and why?",
    "What's your love language this week?",
    "Coffee date or adventure date?",
    "What's the best way to cheer you up?",
    "What's one thing that instantly relaxes you?",
    "Do you prefer deep talks or comfortable silence?",
    "What's your favorite way to say 'I love you'?",
    "Surprise plans or planned-together plans?",
    "What's the best compliment I could give you?",
    "Staying in or going out tonight?",
    "What's a comfort food you'd want me to make?",
    "How do you like to be comforted when you're sad?",
    "What's your favorite time of day with me?",
    "Quality time or acts of service today?",
    "What's one small gesture that means the world to you?",

    // Bonus
    "What made you laugh today?",
    "What are you grateful for about us right now?",
    "What's one word that describes how you feel about me today?",
    "If you could change one thing about today, what would it be?",
    "What's something new you noticed about me recently?",
    "What's a compliment you've been meaning to tell me?",
    "Rate our week together from 1-10 and why.",
    "What's one thing you want more of from me?",
    "What made you think of me today?",
    "How can I make tomorrow better for you?",
  ];

  static String questionForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    return questions[dayOfYear % questions.length];
  }

  static int questionIdForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    return dayOfYear % questions.length;
  }
}
