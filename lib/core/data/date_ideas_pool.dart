class DateIdea {
  final String id;
  final String title;
  final String description;
  final DateIdeaCategory category;

  const DateIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  String get categoryEmoji => switch (category) {
        DateIdeaCategory.adventure => '\u{1F3D4}\uFE0F',
        DateIdeaCategory.cozy => '\u{1F6CB}\uFE0F',
        DateIdeaCategory.creative => '\u{1F3A8}',
        DateIdeaCategory.foodie => '\u{1F37D}\uFE0F',
        DateIdeaCategory.free => '\u{1F33F}',
      };
}

enum DateIdeaCategory { adventure, cozy, creative, foodie, free }

class DateIdeasPool {
  DateIdeasPool._();

  static const List<DateIdea> ideas = [
    // Adventure
    DateIdea(id: 'a1', title: 'Sunrise Hike', description: 'Wake up early and watch the sunrise from a trail together.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a2', title: 'Road Trip', description: 'Pick a random direction and drive for an hour. Explore whatever you find.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a3', title: 'Stargazing Night', description: 'Drive somewhere dark and watch the stars. Bring blankets and hot chocolate.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a4', title: 'Escape Room', description: 'Work together to solve puzzles and escape in time.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a5', title: 'Bike Ride', description: 'Explore your city or a new trail on bikes.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a6', title: 'Kayaking or Canoeing', description: 'Get on the water together for a peaceful paddle.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a7', title: 'Geocaching', description: 'Use your phone to find hidden treasures in your area.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a8', title: 'Go-Kart Racing', description: 'Rev up the engines and see who wins.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a9', title: 'Visit a New Town', description: 'Explore a nearby town you have never been to. Find hidden gems.', category: DateIdeaCategory.adventure),
    DateIdea(id: 'a10', title: 'Rock Climbing', description: 'Try an indoor climbing wall and cheer each other on.', category: DateIdeaCategory.adventure),

    // Cozy
    DateIdea(id: 'c1', title: 'Movie Marathon', description: 'Pick a series or theme and watch movies all day with snacks.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c2', title: 'Cook Together', description: 'Pick a recipe neither of you has tried and cook it together.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c3', title: 'Puzzle Night', description: 'Open a 1000-piece puzzle and work on it together with music.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c4', title: 'Board Game Night', description: 'Pull out your favorite board games or learn a new one.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c5', title: 'Blanket Fort', description: 'Build a blanket fort in the living room. Watch a movie inside.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c6', title: 'Home Spa Night', description: 'Face masks, candles, and relaxing music. Pamper each other.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c7', title: 'Read Together', description: 'Read the same book or read your own books side by side.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c8', title: 'Video Game Night', description: 'Play co-op games together or take turns on single player.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c9', title: 'Tea & Conversation', description: 'Brew a pot of tea and ask each other deep questions.', category: DateIdeaCategory.cozy),
    DateIdea(id: 'c10', title: 'Binge a New Series', description: 'Find a show neither of you has seen and start from episode one.', category: DateIdeaCategory.cozy),

    // Creative
    DateIdea(id: 'cr1', title: 'Paint Night', description: 'Get canvases and paint the same scene. Compare results.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr2', title: 'Write Love Letters', description: 'Write each other a letter and exchange them at the end.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr3', title: 'Scrapbooking', description: 'Print photos and create a scrapbook of your memories.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr4', title: 'Learn a Dance', description: 'Find a YouTube tutorial and learn a dance together.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr5', title: 'Pottery Class', description: 'Take a pottery class or try an at-home clay kit.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr6', title: 'Photo Walk', description: 'Walk around your neighborhood and photograph beautiful things.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr7', title: 'Write a Song', description: 'Write silly or heartfelt lyrics together. No talent required.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr8', title: 'DIY Project', description: 'Build or fix something together for your home.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr9', title: 'Make a Playlist', description: 'Create a shared playlist of songs that mean something to you both.', category: DateIdeaCategory.creative),
    DateIdea(id: 'cr10', title: 'Tie-Dye Shirts', description: 'Buy white shirts and tie-dye kits. Make matching outfits.', category: DateIdeaCategory.creative),

    // Foodie
    DateIdea(id: 'f1', title: 'Try a New Cuisine', description: 'Pick a country and cook or order food from that culture.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f2', title: 'Bake Together', description: 'Bake cookies, cake, or bread from scratch. Decorate together.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f3', title: 'Picnic in the Park', description: 'Pack a basket and eat outside. Keep it simple and lovely.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f4', title: 'Food Truck Tour', description: 'Find local food trucks and sample something from each one.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f5', title: 'Breakfast for Dinner', description: 'Make pancakes, eggs, and bacon at 7pm. Why not?', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f6', title: 'Sushi Making', description: 'Buy ingredients and try making sushi rolls at home.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f7', title: 'Coffee Shop Crawl', description: 'Visit 3 coffee shops and rate the drinks at each.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f8', title: 'Farmers Market Date', description: 'Browse a local farmers market and cook with what you buy.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f9', title: 'Ice Cream Tour', description: 'Visit different ice cream spots and find your favorite.', category: DateIdeaCategory.foodie),
    DateIdea(id: 'f10', title: 'Fondue Night', description: 'Melt cheese or chocolate and dip everything you can think of.', category: DateIdeaCategory.foodie),

    // Free
    DateIdea(id: 'fr1', title: 'Sunset Walk', description: 'Find a scenic spot and walk during golden hour.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr2', title: 'Park Visit', description: 'Explore a park you have never been to. Bring a frisbee.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr3', title: 'Volunteer Together', description: 'Find a local cause and volunteer as a couple.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr4', title: 'Beach Day', description: 'Spend the day at the beach. Swim, build sandcastles, relax.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr5', title: 'Library Date', description: 'Browse books together and read in the quiet.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr6', title: 'People Watching', description: 'Sit at a cafe window and make up stories about passersby.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr7', title: 'Cloud Watching', description: 'Lie on a blanket and find shapes in the clouds.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr8', title: 'Museum Free Day', description: 'Many museums have free admission days. Look one up.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr9', title: 'Window Shopping', description: 'Walk through shops with no intention to buy. Just dream.', category: DateIdeaCategory.free),
    DateIdea(id: 'fr10', title: 'Morning Walk', description: 'Wake up early and take a quiet morning walk together.', category: DateIdeaCategory.free),
  ];
}
