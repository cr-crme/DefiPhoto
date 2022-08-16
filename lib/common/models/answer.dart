import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/discussion.dart';
import '../models/enum.dart';
import '../models/exceptions.dart';
import '../providers/login_information.dart';
import 'message.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    Discussion? discussion,
    this.isActive = true,
    this.isValidated = false,
    ActionRequired actionRequired = ActionRequired.none,
    id,
  })  : discussion = discussion ??= Discussion(),
        _actionRequired = actionRequired,
        super(id: id);
  Answer.fromSerialized(map)
      : discussion = Discussion.fromSerialized(map['discussion'] ?? {}),
        isActive = map['isActive'],
        isValidated = map['isValidated'],
        _actionRequired = ActionRequired.values[map['actionRequired']],
        super.fromSerialized(map);
  Answer copyWith(
      {Discussion? discussion,
      bool? isActive,
      bool? isValidated,
      ActionRequired? actionRequired,
      id}) {
    discussion ??= this.discussion;
    isActive ??= this.isActive;
    isValidated ??= this.isValidated;
    actionRequired ??= _actionRequired;
    id ??= this.id;
    return Answer(
      discussion: discussion,
      isActive: isActive,
      isValidated: isValidated,
      actionRequired: actionRequired,
      id: id,
    );
  }

  @override
  Answer deserializeItem(map) {
    return Answer.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'discussion': discussion.serialize(),
      'isActive': isActive,
      'isValidated': isValidated,
      'actionRequired': _actionRequired.index,
    };
  }

  // Attributes and methods
  final bool isActive;
  final Discussion discussion;
  final bool isValidated;
  final ActionRequired _actionRequired;
  ActionRequired action(BuildContext context) {
    if (!isActive) return ActionRequired.none;

    final loginType =
        Provider.of<LoginInformation>(context, listen: false).loginType;
    if (loginType == LoginType.none) {
      throw const NotLoggedIn();
    }

    if (loginType == LoginType.student &&
        _actionRequired == ActionRequired.fromStudent) {
      return ActionRequired.fromStudent;
    } else if (loginType == LoginType.teacher &&
        _actionRequired == ActionRequired.fromTeacher) {
      return ActionRequired.fromTeacher;
    } else {
      return ActionRequired.none;
    }
  }

  bool get isAnswered =>
      isActive && _actionRequired != ActionRequired.fromStudent;
  bool get hasAnswer => discussion.isNotEmpty;

  void addToDiscussion(Message message) => discussion.add(message);
}
