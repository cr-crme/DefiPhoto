import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_list_view.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_questions.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/widgets/are_you_sure_dialog.dart';
import '../../../common/widgets/grouped_radio_button.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    Key? key,
    required this.student,
    required this.onStateChange,
    required this.isActive,
  }) : super(key: key);

  final Student? student;
  final Question question;
  final Function(VoidCallback) onStateChange;
  final bool isActive;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
  var _isExpanded = false;

  void _expand() {
    _isExpanded = !_isExpanded;

    setState(() {});
  }

  void onStateChange(VoidCallback func) {
    _isExpanded = false;
    widget.onStateChange(() {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          ListTile(
            title: QuestionPart(
              question: widget.question,
              isActive: widget.isActive,
            ),
            trailing:
                Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: _expand,
          ),
          if (_isExpanded)
            AnswerPart(
              widget.student?.allAnswers[widget.question],
              onStateChange: onStateChange,
              student: widget.student,
              question: widget.question,
            ),
        ],
      ),
    );
  }
}

class QuestionPart extends StatelessWidget {
  const QuestionPart({
    Key? key,
    required this.question,
    required this.isActive,
  }) : super(key: key);

  final Question question;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Text(question.text,
        style: TextStyle(color: isActive ? Colors.black : Colors.grey));
  }
}

class AnswerPart extends StatelessWidget {
  const AnswerPart(
    this.answer, {
    Key? key,
    required this.onStateChange,
    required this.student,
    required this.question,
  }) : super(key: key);

  final Student? student;
  final Answer? answer;
  final Function(VoidCallback) onStateChange;
  final Question question;

  @override
  Widget build(BuildContext context) {
    late final bool isActive;
    if (answer != null) {
      isActive = answer!.isActive;
    } else {
      // Only active if active for all
      var indexInactive = Provider.of<AllStudents>(context).indexWhere(
        (s) {
          if (s.allAnswers[question] == null) false;
          return s.allAnswers[question]!.isActive;
        },
      );
      isActive = indexInactive >= 0;
    }

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer == null) _QuestionTypeChooser(question: question),
          if (isActive && question.type == QuestionType.photo && answer != null)
            _showPhoto(),
          if (isActive && answer != null && question.type == QuestionType.text)
            _showWrittenAnswer(),
          if (isActive && answer != null) const SizedBox(height: 12),
          if (isActive && answer != null) DiscussionListView(answer: answer),
          _ShowStatus(
            student: student,
            answer: answer,
            question: question,
            onStateChange: onStateChange,
            initialStatus: isActive,
          ),
        ],
      ),
    );
  }

  Widget _showPhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo : ', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        answer!.photoUrl == null
            ? const Center(
                child: Text('En attente de la photo de l\'étudiant',
                    style: TextStyle(color: Colors.red)))
            : Container(
                padding: const EdgeInsets.only(left: 15),
                child: FutureBuilder(builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Image.network(
                          answer!.photoUrl!,
                          fit: BoxFit.cover,
                        );
                }),
              ),
      ],
    );
  }

  Widget _showWrittenAnswer() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Réponse écrite : ', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      answer!.text == null
          ? const Center(
              child: Text('En attente de la réponse de l\'étudiant',
                  style: TextStyle(color: Colors.red)))
          : Container(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [Flexible(child: Text(answer!.text!.toString()))],
              ),
            )
    ]);
  }
}

class _QuestionTypeChooser extends StatefulWidget {
  const _QuestionTypeChooser({
    Key? key,
    required this.question,
  }) : super(key: key);

  final Question question;

  @override
  State<_QuestionTypeChooser> createState() => _QuestionTypeChooserState();
}

class _QuestionTypeChooserState extends State<_QuestionTypeChooser> {
  late QuestionType _questionType = QuestionType.photo;

  @override
  Widget build(BuildContext context) {
    _questionType = widget.question.type;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(child: Text('Le type de question est : ')),
        GroupedRadioButton<QuestionType>(
            title: const Text('Texte'),
            value: QuestionType.text,
            groupValue: _questionType,
            onChanged: (value) => _setQuestionType(context, value)),
        GroupedRadioButton<QuestionType>(
            title: const Text('Photo'),
            value: QuestionType.photo,
            groupValue: _questionType,
            onChanged: (value) => _setQuestionType(context, value)),
      ],
    );
  }

  void _setQuestionType(BuildContext context, value) async {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);

    final newQuestion = widget.question.copyWith(type: value);

    questions[widget.question] = newQuestion;

    for (var student in students) {
      final answer =
          student.allAnswers[widget.question]!.copyWith(question: newQuestion);
      student.allAnswers.replace(answer);
    }

    _questionType = value;
    setState(() {});
  }
}

class _ShowStatus extends StatefulWidget {
  const _ShowStatus(
      {Key? key,
      required this.student,
      required this.answer,
      required this.onStateChange,
      required this.initialStatus,
      required this.question})
      : super(key: key);

  final Student? student;
  final Answer? answer;
  final Question question;
  final bool initialStatus;
  final Function(VoidCallback) onStateChange;

  @override
  State<_ShowStatus> createState() => _ShowStatusState();
}

class _ShowStatusState extends State<_ShowStatus> {
  var _isActive = false;

  Future<void> _toggleQuestion(value) async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final sure = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AreYouSureDialog(
          title: 'Confimer le choix',
          content:
              'Voulez-vous vraiment ${value ? 'activer' : 'désactiver'} cette '
              'question${widget.student == null ? ' pour tous' : ''}?',
        );
      },
    );

    if (!sure!) return;

    _isActive = value;
    if (widget.student != null) {
      widget.student!.allAnswers
          .replace(widget.answer!.copyWith(isActive: value));
    } else {
      for (var student in students) {
        final answer =
            student.allAnswers[widget.question]!.copyWith(isActive: value);
        student.allAnswers.replace(answer);
      }
    }
    setState(() {});
    widget.onStateChange(() {});
  }

  @override
  Widget build(BuildContext context) {
    _isActive = widget.initialStatus;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            _isActive
                ? 'Désactiver la question pour tous'
                : 'Activer la question pour cet élève',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Switch(onChanged: _toggleQuestion, value: _isActive),
      ],
    );
  }
}
