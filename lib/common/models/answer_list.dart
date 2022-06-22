import '../models/answer.dart';
import '../../misc/custom_containers/list_serializable.dart';

class AnswerList extends ListSerializable<Answer> {
  AnswerList();
  AnswerList.fromSerialized(map) {
    deserialize(map);
  }

  @override
  Answer deserializeItem(map) {
    return Answer.fromSerialized(map);
  }

  int get number => length;
}