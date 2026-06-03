# UI Revamp + Navigation + Roadmap Overhaul

## Navigation

Consolidate from 6 tabs to 4 tabs + app bar settings icon.

| Tab | Icon | Content |
|-----|------|---------|
| Home | home_rounded | Timer + partner panel (absorbs Together page) |
| Tasks | task_alt_rounded | Task list with progress |
| Roadmap | map_rounded | Revamped goal map |
| Canvas | brush_rounded | Gallery + drawing |

- Settings: gear icon in app bar top-right, opens via Navigator.push
- App bar: AppLogo (28px) left, page title center, gear icon right
- QuoteCard: shown below app bar on Home tab only

## Design Language (Bold & Playful)

### Cards & Containers
- Border radius: 16px (up from 8px)
- Gradient fills on key cards using AppGradients
- Warm-tinted shadows with slight elevation (2-4dp)

### Typography
- headlineLarge: 32px bold
- Emoji prefixes on status labels (FOCUS TIME, SHORT BREAK, etc.)
- Round filled number badges for counts

### Micro-interactions
- Timer completion: scale-bounce animation
- Task completion: checkmark pop animation
- Tab switch: fade transition

### Progress Indicators
- Pill-shaped (border radius 999)
- Animated shimmer gradient on active progress
- Terracotta for work, sage green for break/partner

### Empty States
- Large friendly icons (64px+) with encouraging copy
- CTA button instead of plain text

### FABs & Buttons
- Gradient background (AppGradients.accent)
- Shadow glow matching gradient

## Page Changes

### Home Page
- Absorbs partner panel from Together page into a collapsible section
- Timer circle gets bounce animation on completion
- Status labels get emoji prefixes
- Cards use 16px radius + gradient fills
- Greeting section more prominent with user name

### Tasks Page
- Progress bar gets shimmer animation
- Add task button becomes gradient FAB
- Task cards get 16px radius + subtle shadows
- Completion animation on checkmark

### Roadmap Page
- Keep game-map concept but polish visuals
- Nodes: larger (84px), gradient fills instead of flat color
- Path: smoother curves, animated progress stroke
- Current goal bar: gradient accent background
- Selector page: bolder tiles with gradient icons
- Add goal sheet: cleaner form with better spacing

### Canvas Gallery
- Cards get 16px radius (already has 16px, keep)
- Gradient FABs
- Better empty state with CTA

### Settings Page
- Full page via Navigator.push (not a tab)
- Same form layout, updated card styling

## Color Scheme
Preserved exactly as-is. No color value changes.

## Files to Modify
- lib/app_shell.dart (navigation restructure)
- lib/core/theme/app_theme.dart (border radius, elevation, button styles)
- lib/core/widgets/app_logo.dart (no change, used in app bar)
- lib/features/timer/presentation/pages/home_page.dart (absorb partner panel, animations)
- lib/features/timer/presentation/widgets/timer_circle.dart (bounce animation)
- lib/features/tasks/presentation/pages/tasks_page.dart (styling updates)
- lib/features/tasks/presentation/widgets/task_list_widget.dart (card styling, completion animation)
- lib/features/timeline/presentation/pages/together_page.dart (delete — absorbed into home)
- lib/features/roadmap/presentation/pages/roadmap_page.dart (visual overhaul)
- lib/features/canvas/presentation/pages/canvas_gallery_page.dart (styling updates)
- lib/features/settings/presentation/pages/settings_page.dart (styling + navigation change)
