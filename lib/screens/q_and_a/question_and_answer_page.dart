import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/database.dart';
import '/common/models/enum.dart';
import '/common/models/question.dart';
import '/common/models/section.dart';
import '/common/providers/all_questions.dart';
import '/common/providers/all_students.dart';
import 'widgets/question_and_answer_tile.dart';

class QuestionAndAnswerPage extends StatelessWidget {
  const QuestionAndAnswerPage(
    this.sectionIndex, {
    super.key,
    required this.studentId,
    required this.viewSpan,
    required this.pageMode,
  });

  static const routeName = '/question-and-answer-page';
  final int sectionIndex;
  final String? studentId;
  final Target viewSpan;
  final PageMode pageMode;

  @override
  Widget build(BuildContext context) {
    final allStudents = Provider.of<AllStudents>(context, listen: false);
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    final questions = Provider.of<AllQuestions>(context, listen: true)
        .fromSection(sectionIndex);
    questions.sort(
        (first, second) => first.creationTimeStamp - second.creationTimeStamp);

    late final List<Question>? activeQuestions;
    if (studentId != null) {
      final student = allStudents[studentId];
      final answers = student.allAnswers.fromQuestions(questions);
      activeQuestions = answers.activeQuestions(questions);
    } else {
      activeQuestions = [];
    }

    final allAnswersSection = _buildQuestionSection(context,
        questions: questions.toList(growable: false),
        titleIfNothing: 'Aucune question dans cette section');
    final activeQuestionsSection = _buildQuestionSection(context,
        questions: activeQuestions,
        titleIfNothing: 'Aucune question dans cette section');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (userType == UserType.teacher)
            Container(
              padding: const EdgeInsets.only(left: 5, top: 15),
              child: Text(Section.name(sectionIndex),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.black)),
            ),
          if (viewSpan != Target.individual) const SizedBox(height: 10),
          if (viewSpan != Target.individual && pageMode == PageMode.edit)
            QuestionAndAnswerTile(
              null,
              sectionIndex: sectionIndex,
              studentId: studentId,
              viewSpan: viewSpan,
              pageMode: pageMode,
            ),
          if (viewSpan != Target.individual &&
              questions.isNotEmpty &&
              studentId != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text('Activé pour cet élève'),
                SizedBox(width: 25)
              ],
            ),
          viewSpan == Target.individual && pageMode != PageMode.edit
              ? activeQuestionsSection
              : allAnswersSection,
        ],
      ),
    );
  }

  Widget _buildQuestionSection(BuildContext context,
      {required List<Question> questions, required String titleIfNothing}) {
    return questions.isNotEmpty
        ? QAndAListView(
            questions.toList(growable: false),
            sectionIndex: sectionIndex,
            studentId: studentId,
            viewSpan: viewSpan,
            pageMode: pageMode,
          )
        : Container(
            padding: const EdgeInsets.only(top: 10, bottom: 30),
            child: Text(titleIfNothing),
          );
  }
}

class QAndAListView extends StatelessWidget {
  const QAndAListView(
    this.questions, {
    super.key,
    required this.sectionIndex,
    required this.studentId,
    required this.viewSpan,
    required this.pageMode,
  });

  final List<Question> questions;
  final int sectionIndex;
  final String? studentId;
  final Target viewSpan;
  final PageMode pageMode;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => QuestionAndAnswerTile(
        questions[index],
        sectionIndex: sectionIndex,
        studentId: studentId,
        viewSpan: viewSpan,
        pageMode: pageMode,
      ),
      itemCount: questions.length,
    );
  }
}
