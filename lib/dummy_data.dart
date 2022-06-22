import 'package:defi_photo/common/models/discussion.dart';

import 'common/models/all_answer.dart';
import './common/models/answer.dart';
import './common/models/company.dart';
import './common/models/question.dart';
import './common/models/student.dart';
import './common/providers/all_question_lists.dart';
import './common/providers/students.dart';

void prepareDummyData(Students students, AllQuestionList questions) {
  questions[0].add(Question('Photo?', needPhoto: true, needText: false));
  questions[1].add(Question('Photo?', needPhoto: true, needText: false));
  questions[2].add(Question('Photo?', needPhoto: true, needText: false));
  questions[3].add(Question('Photo?', needPhoto: true, needText: false));
  questions[4].add(Question('Photo?', needPhoto: true, needText: false));
  questions[5].add(Question('Photo?', needPhoto: true, needText: false));
  questions[5].add(Question('Texte?', needPhoto: false, needText: true));
  questions[5]
      .add(Question('Photo et texte?', needPhoto: true, needText: true));

  final benjaminAnswers = AllAnswer();
  benjaminAnswers
      .add(Answer(isActive: true, question: questions[0][0]!, discussion: []));
  benjaminAnswers
      .add(Answer(isActive: true, question: questions[5][0]!, discussion: []));
  benjaminAnswers.add(Answer(
      isActive: true,
      text: 'coucou',
      question: questions[5][1]!,
      discussion: []));
  benjaminAnswers.add(Answer(
      isActive: true,
      text: 'coucou2',
      question: questions[5][1]!,
      discussion: []));
  benjaminAnswers.add(Answer(
      isActive: true,
      text: 'coucou3',
      question: questions[5][2]!,
      discussion: []));

  students.add(Student(
      firstName: 'Benjamin',
      lastName: 'Michaud',
      company: Company(name: 'Ici'),
      allAnswers: benjaminAnswers));

  final aurelieAnswers = AllAnswer();
  aurelieAnswers.add(Answer(
      isActive: true,
      photoUrl: 'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
          'Landscape-Photography-steps.jpg',
      text: 'coucou3',
      question: questions[5][2]!,
      discussion: [
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
        Discussion(name: 'Prof', text: 'Coucou'),
        Discussion(name: 'Aurélie', text: 'Non pas coucou'),
      ]));

  students.add(Student(
      firstName: 'Aurélie',
      lastName: 'Tondoux',
      company: Company(name: null),
      allAnswers: aurelieAnswers));
}
