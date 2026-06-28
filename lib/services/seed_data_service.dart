// Author: K K K Ekanayake
// Task: TASK-010 — Seed Data / Template Service
// ChronosAI — Guided template creation for goals, milestones, and habits
// based on persona type. Provides empty-state onboarding with user-controlled
// accept/modify/skip flow (no pre-seeded data).

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/habit.dart';
import '../repositories/goal_repository.dart';
import '../repositories/milestone_repository.dart';
import '../repositories/habit_repository.dart';
import '../config/app_constants.dart';

// ---------------------------------------------------------------------------
// Template classes
// ---------------------------------------------------------------------------

/// A goal template that can be applied to create a Goal + linked Milestones.
class GoalTemplate {
  final String title;
  final String description;
  final GoalCategory category;
  final String priority;
  final List<MilestoneTemplate> milestoneTemplates;
  final List<HabitTemplate> habitTemplates;

  const GoalTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.milestoneTemplates = const [],
    this.habitTemplates = const [],
  });
}

/// A milestone template linked to a goal. [daysFromNow] is relative to today.
class MilestoneTemplate {
  final String title;
  final String description;
  final int daysFromNow;

  const MilestoneTemplate({
    required this.title,
    required this.description,
    required this.daysFromNow,
  });
}

/// A habit template. [targetDays] uses ISO weekday integers (1=Mon … 7=Sun).
class HabitTemplate {
  final String title;
  final String description;
  final HabitFrequency frequency;
  final List<int> targetDays;

  const HabitTemplate({
    required this.title,
    required this.description,
    required this.frequency,
    this.targetDays = const [],
  });
}

// ---------------------------------------------------------------------------
// SeedDataService
// ---------------------------------------------------------------------------

/// Provides persona-based goal/milestone/habit templates and applies them
/// to the local Isar database.
class SeedDataService {
  final GoalRepository _goalRepo = GoalRepository();
  final MilestoneRepository _milestoneRepo = MilestoneRepository();
  final HabitRepository _habitRepo = HabitRepository();

  // -------------------------------------------------------------------------
  // Persona template lists
  // -------------------------------------------------------------------------

  static const List<GoalTemplate> _professionalTemplates = [
    GoalTemplate(
      title: 'Launch Side Project',
      description: 'Build and launch a meaningful side project this year',
      category: GoalCategory.creativity,
      priority: 'high',
      milestoneTemplates: [
        MilestoneTemplate(
          title: 'Define project scope',
          description: 'Outline the problem, target audience, and core features',
          daysFromNow: 30,
        ),
        MilestoneTemplate(
          title: 'Build MVP',
          description: 'Develop a minimum viable product with core functionality',
          daysFromNow: 90,
        ),
        MilestoneTemplate(
          title: 'Launch beta',
          description: 'Release beta version to early adopters',
          daysFromNow: 150,
        ),
        MilestoneTemplate(
          title: 'First 10 users',
          description: 'Get 10 active users on the platform',
          daysFromNow: 210,
        ),
      ],
      habitTemplates: [
        HabitTemplate(
          title: '1 hour deep work daily',
          description: 'Dedicate one uninterrupted hour to deep work on the project',
          frequency: HabitFrequency.daily,
        ),
        HabitTemplate(
          title: 'Weekly progress review',
          description: 'Review weekly metrics, blockers, and next steps',
          frequency: HabitFrequency.weekly,
        ),
      ],
    ),
    GoalTemplate(
      title: 'Career Growth \u2014 Senior Role',
      description: 'Position yourself for a senior promotion',
      category: GoalCategory.career,
      priority: 'high',
      milestoneTemplates: [
        MilestoneTemplate(
          title: 'Identify skill gaps',
          description: 'Audit current competencies against senior-level expectations',
          daysFromNow: 14,
        ),
        MilestoneTemplate(
          title: 'Complete leadership course',
          description: 'Finish an approved leadership or management course',
          daysFromNow: 90,
        ),
        MilestoneTemplate(
          title: 'Lead cross-team project',
          description: 'Successfully lead a project spanning at least two teams',
          daysFromNow: 180,
        ),
        MilestoneTemplate(
          title: 'Promotion conversation',
          description: 'Have a formal promotion discussion with your manager',
          daysFromNow: 270,
        ),
      ],
      habitTemplates: [
        HabitTemplate(
          title: 'Read industry articles 20min',
          description: 'Read at least one industry-relevant article for 20 minutes',
          frequency: HabitFrequency.daily,
        ),
        HabitTemplate(
          title: 'Network with 1 person weekly',
          description: 'Connect with one new professional contact each week',
          frequency: HabitFrequency.weekly,
        ),
      ],
    ),
    GoalTemplate(
      title: 'Improve Work-Life Balance',
      description: 'Set boundaries and reclaim personal time',
      category: GoalCategory.health,
      priority: 'medium',
      milestoneTemplates: [
        MilestoneTemplate(
          title: 'Define non-negotiables',
          description: 'Identify 3 personal boundaries to protect',
          daysFromNow: 7,
        ),
        MilestoneTemplate(
          title: 'No-work evenings 3x/week',
          description: 'Keep at least 3 evenings per week free from work',
          daysFromNow: 30,
        ),
        MilestoneTemplate(
          title: 'Take 2-week vacation',
          description: 'Plan and take a full two-week vacation',
          daysFromNow: 180,
        ),
      ],
      habitTemplates: [
        HabitTemplate(
          title: 'Evening walk 30min',
          description: 'Take a 30-minute walk every evening',
          frequency: HabitFrequency.daily,
        ),
        HabitTemplate(
          title: 'Digital sunset 9pm',
          description: 'No screens after 9 PM',
          frequency: HabitFrequency.daily,
        ),
      ],
    ),
  ];

  static const List<GoalTemplate> _studentTemplates = [
    GoalTemplate(
      title: 'Ace Final Exams',
      description: 'Score top marks in all final exams',
      category: GoalCategory.education,
      priority: 'high',
      milestoneTemplates: [
        MilestoneTemplate(
          title: 'Create study schedule',
          description: 'Map out a day-by-day study plan for all subjects',
          daysFromNow: 7,
        ),
        MilestoneTemplate(
          title: 'Complete first review pass',
          description: 'Finish first pass through all course material',
          daysFromNow: 30,
        ),
        MilestoneTemplate(
          title: 'Practice exams',
          description: 'Complete at least 3 full practice exams per subject',
          daysFromNow: 60,
        ),
        MilestoneTemplate(
          title: 'Final review',
          description: 'Final review pass focusing on weak areas',
          daysFromNow: 85,
        ),
      ],
      habitTemplates: [
        HabitTemplate(
          title: 'Study 2 hours daily',
          description: 'Study for at least 2 focused hours every day',
          frequency: HabitFrequency.daily,
        ),
        HabitTemplate(
          title: 'Active recall practice',
          description: 'Practice active recall for at least 30 minutes daily',
          frequency: HabitFrequency.daily,
        ),
      ],
    ),
    GoalTemplate(
      title: 'Build Consistent Study Routine',
      description: 'Develop sustainable study habits for the semester',
      category: GoalCategory.education,
      priority: 'medium',
      milestoneTemplates: [
        MilestoneTemplate(
          title: 'Week 1-2: Establish schedule',
          description: 'Set a fixed daily study schedule and stick to it',
          daysFromNow: 14,
        ),
        MilestoneTemplate(
          title: 'Week 3-4: Optimize techniques',
          description: 'Experiment with and adopt effective study techniques',
          daysFromNow: 28,
        ),
        MilestoneTemplate(
          title: 'Month 2: Increase difficulty',
          description: 'Increase study intensity and tackle harder material',
          daysFromNow: 60,
        ),
      ],
      habitTemplates: [
        HabitTemplate(
          title: 'Pomodoro sessions 4x daily',
          description: 'Complete 4 Pomodoro sessions every day',
          frequency: HabitFrequency.daily,
        ),
        HabitTemplate(
          title: 'Weekly review Sunday',
          description: 'Review the week\u2019s material every Sunday',
          frequency: HabitFrequency.weekly,
          targetDays: [7], // Sunday
        ),
      ],
    ),
    GoalTemplate(
      title: 'Complete Thesis',
      description: 'Finish thesis draft by end of semester',
      category: GoalCategory.education,
      priority: 'high',
      milestoneTemplates: [
        MilestoneTemplate(
          title: 'Complete literature review',
          description: 'Finish the literature review section',
          daysFromNow: 45,
        ),
        MilestoneTemplate(
          title: 'Methodology draft',
          description: 'Complete the methodology section draft',
          daysFromNow: 90,
        ),
        MilestoneTemplate(
          title: 'Results section',
          description: 'Write up the results section with data analysis',
          daysFromNow: 150,
        ),
        MilestoneTemplate(
          title: 'Full draft',
          description: 'Assemble a complete first draft of the thesis',
          daysFromNow: 240,
        ),
        MilestoneTemplate(
          title: 'Final submission',
          description: 'Submit the final version of the thesis',
          daysFromNow: 300,
        ),
      ],
      habitTemplates: [
        HabitTemplate(
          title: 'Write 500 words daily',
          description: 'Write at least 500 words of thesis content every day',
          frequency: HabitFrequency.daily,
        ),
        HabitTemplate(
          title: 'Advisor check-in biweekly',
          description: 'Meet with thesis advisor every two weeks',
          frequency: HabitFrequency.biWeekly,
        ),
      ],
    ),
  ];

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Returns all goal templates for the given [persona].
  List<GoalTemplate> getTemplatesForPersona(PersonaType persona) {
    switch (persona) {
      case PersonaType.professional:
        return _professionalTemplates;
      case PersonaType.student:
        return _studentTemplates;
    }
  }

  /// Applies a single [template]: creates the Goal, its linked Milestones,
  /// and (optionally) its Habits in Isar.
  Future<void> applyTemplate(
    GoalTemplate template, {
    bool applyHabits = true,
  }) async {
    try {
      final now = DateTime.now();
      final goal = Goal(
        title: template.title,
        description: template.description,
        category: template.category.name,
        priority: template.priority,
        targetDate: now.add(Duration(days: 365)),
        createdDate: now,
        status: 'active',
        progress: 0.0,
      );

      final goalId = await _goalRepo.create(goal);

      await _createMilestonesForGoal(goalId, template.milestoneTemplates);

      if (applyHabits) {
        for (final ht in template.habitTemplates) {
          try {
            final habit = Habit(
              title: ht.title,
              description: ht.description,
              frequency: ht.frequency.name,
              targetDays: ht.targetDays,
              streakCount: 0,
              longestStreak: 0,
              lastCompletedDate: null,
              createdDate: now,
              status: 'active',
            );
            await _habitRepo.create(habit);
          } catch (e) {
            // Skip this habit on failure but continue with the rest.
            continue;
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Applies every template for the given [persona].
  Future<void> applyAllForPersona(PersonaType persona) async {
    final templates = getTemplatesForPersona(persona);
    for (final template in templates) {
      try {
        await applyTemplate(template);
      } catch (e) {
        // Skip failed templates but continue with remaining ones.
        continue;
      }
    }
  }

  /// Removes all goals, milestones, and habits from the database.
  /// Useful for the "start fresh" action.
  Future<void> clearAllSampleData() async {
    try {
      // Delete all goals (milestones are cascade-handled by Isar links).
      final goals = await _goalRepo.getAll();
      for (final goal in goals) {
        try {
          await _goalRepo.delete(goal.id);
        } catch (_) {
          continue;
        }
      }

      // Delete any remaining milestones.
      final milestones = await _milestoneRepo.getAll();
      for (final milestone in milestones) {
        try {
          await _milestoneRepo.delete(milestone.id);
        } catch (_) {
          continue;
        }
      }

      // Delete all habits.
      final habits = await _habitRepo.getAll();
      for (final habit in habits) {
        try {
          await _habitRepo.delete(habit.id);
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Creates milestones linked to the goal identified by [goalId].
  Future<void> _createMilestonesForGoal(
    int goalId,
    List<MilestoneTemplate> templates,
  ) async {
    final now = DateTime.now();
    for (final mt in templates) {
      try {
        final milestone = Milestone(
          title: mt.title,
          description: mt.description,
          dueDate: now.add(Duration(days: mt.daysFromNow)),
          createdDate: now,
          status: 'pending',
          progress: 0.0,
        );
        // Link to the goal.
        milestone.goal.value = await _goalRepo.getById(goalId);
        await _milestoneRepo.create(milestone);
      } catch (e) {
        // Skip this milestone on failure but continue with the rest.
        continue;
      }
    }
  }
}
