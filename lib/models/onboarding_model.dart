// Onboarding Model - Manages user's first-time experience

typedef VoidCallback = void Function();

class OnboardingStep {
  final String title;
  final String description;
  final String imagePath;
  final String? actionText;
  final VoidCallback? action;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.imagePath,
    this.actionText,
    this.action,
  });
}

class AppFeature {
  final String name;
  final String description;
  final String icon;
  final String benefit;
  final String howTo;

  AppFeature({
    required this.name,
    required this.description,
    required this.icon,
    required this.benefit,
    required this.howTo,
  });
}

class OnboardingData {
  static List<OnboardingStep> getWelcomeSteps() {
    return [
      OnboardingStep(
        title: "Welcome to MindScribe! 📝",
        description: "Your personal digital diary with smart features to capture thoughts, memories, and organize your life.",
        imagePath: "assets/onboarding/welcome.png",
      ),
      OnboardingStep(
        title: "Create Beautiful Entries ✨",
        description: "Write diary entries, add tasks, and create events. Organize everything with categories and colors.",
        imagePath: "assets/onboarding/create_entry.png",
      ),
      OnboardingStep(
        title: "Smart Reminders 🔔",
        description: "Set reminders for important entries. Never forget appointments, tasks, or special moments.",
        imagePath: "assets/onboarding/reminders.png",
      ),
      OnboardingStep(
        title: "Calendar View 📅",
        description: "See all your entries in a beautiful calendar. Track your journaling journey and find entries easily.",
        imagePath: "assets/onboarding/calendar.png",
      ),
      OnboardingStep(
        title: "Search & Organize 🔍",
        description: "Find any entry instantly with powerful search. Filter by categories, dates, or keywords.",
        imagePath: "assets/onboarding/search.png",
      ),
    ];
  }

  static List<AppFeature> getAppFeatures() {
    return [
      AppFeature(
        name: "Diary Entries",
        description: "Write your thoughts, experiences, and memories",
        icon: "📝",
        benefit: "Keep track of your life journey",
        howTo: "Tap the + button to create your first entry",
      ),
      AppFeature(
        name: "Categories",
        description: "Organize entries by Personal, Work, Health, Travel, etc.",
        icon: "🏷️",
        benefit: "Find related entries quickly",
        howTo: "Select a category when creating an entry",
      ),
      AppFeature(
        name: "Reminders",
        description: "Set notifications for important entries",
        icon: "⏰",
        benefit: "Never miss important events or tasks",
        howTo: "Toggle reminder when creating an entry",
      ),
      AppFeature(
        name: "Calendar View",
        description: "See all entries in a monthly calendar layout",
        icon: "📅",
        benefit: "Visualize your journaling patterns",
        howTo: "Tap the calendar tab at the bottom",
      ),
      AppFeature(
        name: "Search",
        description: "Find entries by title, content, or category",
        icon: "🔍",
        benefit: "Quickly locate specific memories",
        howTo: "Use the search bar at the top",
      ),
      AppFeature(
        name: "Dark Mode",
        description: "Switch between light and dark themes",
        icon: "🌙",
        benefit: "Comfortable journaling day or night",
        howTo: "Tap the theme toggle in the top bar",
      ),
    ];
  }

  static List<String> getQuickTips() {
    return [
      "💡 Tip: Write regularly to build a journaling habit",
      "💡 Tip: Use categories to organize different aspects of your life",
      "💡 Tip: Set reminders for important events and tasks",
      "💡 Tip: Use the calendar view to see your journaling patterns",
      "💡 Tip: Search works on both titles and content",
      "💡 Tip: Dark mode is easier on your eyes at night",
      "💡 Tip: Your data is stored locally and completely private",
    ];
  }
}