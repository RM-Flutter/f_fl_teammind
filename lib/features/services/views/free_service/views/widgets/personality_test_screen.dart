import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({super.key});

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  int currentQuestionIndex = 0;
  List<int?> answers = [];
  bool testCompleted = false;
  String? personalityResult;

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  List<Map<String, dynamic>> get questions => [
    {
      'question': AppStrings.freeTime.tr(),
      'options': [
        AppStrings.readingLearning.tr(),
        AppStrings.socializingFriends.tr(),
        AppStrings.workingProjects.tr(),
        AppStrings.relaxingHome.tr(),
      ],
    },
    {
      'question': AppStrings.facingProblem.tr(),
      'options': [
        AppStrings.analyzeLogically.tr(),
        AppStrings.discussOthers.tr(),
        AppStrings.immediateAction.tr(),
        AppStrings.thinkQuietly.tr(),
      ],
    },
    {
      'question': AppStrings.teamSetting.tr(),
      'options': [
        AppStrings.leadTeam.tr(),
        AppStrings.supportOthers.tr(),
        AppStrings.workIndependently.tr(),
        AppStrings.coordinateMembers.tr(),
      ],
    },
    {
      'question': AppStrings.idealWorkEnvironment.tr(),
      'options': [
        AppStrings.structuredOrganized.tr(),
        AppStrings.flexibleCreative.tr(),
        AppStrings.fastPacedChallenging.tr(),
        AppStrings.calmStable.tr(),
      ],
    },
    {
      'question': AppStrings.makingDecisions.tr(),
      'options': [
        AppStrings.logicFacts.tr(),
        AppStrings.feelingsValues.tr(),
        AppStrings.pastExperiences.tr(),
        AppStrings.futurePossibilities.tr(),
      ],
    },
  ];

  List<String> get personalities => [
    AppStrings.analyticalThinker.tr(),
    AppStrings.socialConnector.tr(),
    AppStrings.actionOriented.tr(),
    AppStrings.thoughtfulObserver.tr(),
  ];

  @override
  void initState() {
    super.initState();
    answers = List.filled(5, null);
  }

  void _answerQuestion(int answerIndex) {
    setState(() {
      answers[currentQuestionIndex] = answerIndex;
      
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        _calculateResult();
      }
    });
  }

  void _calculateResult() {
    // Simple personality calculation based on most common answer type
    Map<int, int> answerCounts = {};
    for (var answer in answers) {
      if (answer != null) {
        answerCounts[answer] = (answerCounts[answer] ?? 0) + 1;
      }
    }
    
    int mostCommon = answerCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    setState(() {
      testCompleted = true;
      personalityResult = personalities[mostCommon];
    });
  }

  void _restartTest() {
    setState(() {
      currentQuestionIndex = 0;
      answers = List.filled(questions.length, null);
      testCompleted = false;
      personalityResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.white),
      appBar: AppBarWithBookmark(
        backgroundColor: Color(AppColors.white),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(AppColors.dark),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Color(AppColors.white), size: 18),
          ),
          onPressed: _goBack,
        ),
        title: AppStrings.personalityTest2.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        routeName: AppRoutes.personalityTestScreen.name,
      ),
      body: testCompleted ? _buildResultScreen() : _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    final question = questions[currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppStrings.personalityTest.tr(),
            style: TextStyle(
              color: Color(AppColors.dark),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Progress
          Text(
            AppStrings.questionOf.tr()
                .replaceAll('{current}', '${currentQuestionIndex + 1}')
                .replaceAll('{total}', '${questions.length}'),
            style: TextStyle(
              color: Color(AppColors.darkGrey),
              fontSize: 14,
            ),
          ),
          
          // Progress Bar
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            backgroundColor: Color(AppColors.lightGrey),
            valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.primary)),
          ),
          
          const SizedBox(height: 40),
          
          // Question
          Text(
            question['question'],
            style: TextStyle(
              color: Color(AppColors.dark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Options
          ...List.generate(question['options'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _answerQuestion(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: answers[currentQuestionIndex] == index
                        ? Color(AppColors.primary).withValues(alpha: 0.1)
                        : Color(AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: answers[currentQuestionIndex] == index
                          ? Color(AppColors.primary)
                          : Color(AppColors.lightGrey),
                    ),
                  ),
                  child: Text(
                    question['options'][index],
                    style: TextStyle(
                      color: answers[currentQuestionIndex] == index
                          ? Color(AppColors.primary)
                          : Color(AppColors.dark),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 60,
                color: Color(AppColors.primary),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              AppStrings.yourPersonalityType.tr(),
              style: TextStyle(
                color: Color(AppColors.lightGrey),
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              personalityResult ?? '',
              style: TextStyle(
                color: Color(AppColors.dark),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              AppStrings.personalityResultDescription.tr()
                  .replaceAll('{type}', personalityResult ?? ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(AppColors.darkGrey),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: _restartTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primary),
                foregroundColor: Color(AppColors.white),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                AppStrings.takeTestAgain.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
