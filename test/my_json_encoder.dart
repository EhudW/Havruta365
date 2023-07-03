import 'package:mongo_dart/mongo_dart.dart';

// custom encode/decode to handle DateTime
// and also has changeLittle to small manipulate-change some json

const String prefix = "MYENCODER123";
Object? myEncode(Object? x) {
  String val = "";
  String type = "";
  switch (x.runtimeType) {
    case DateTime:
      val = (x as DateTime).millisecondsSinceEpoch.toString();
      type = 'DateTime';
      break;
    case ObjectId:
      val = (x as ObjectId).$oid;
      type = 'ObjectId';
      break;
    default:
      throw UnsupportedError(
          'not supported json decode/encode for ${x.runtimeType}');
  }
  return '$prefix $type $val';
}

Object? myDecode(Object? key, Object? x) {
  if (x.runtimeType == String && (x as String).startsWith(prefix)) {
    switch (x.split(' ')[1]) {
      case 'DateTime':
        return DateTime.fromMillisecondsSinceEpoch(int.parse(x.split(' ')[2]));
      case 'ObjectId':
        return ObjectId.fromHexString(x.split(' ')[2]);
      default:
        throw Exception('unknown type');
    }
  }
  return x;
}

// change one field a little (0->1  "a"-"hello")
// affet the given value (the list/map itself will cahnge)
dynamic _changeByType(dynamic value) {
  switch (value.runtimeType.toString().split("<")[0]) {
    case '_Map':
    case 'Map':
      if (value.isEmpty) return value;
      value.remove(value.keys.first);
      break;
    case 'List':
      if (value.isEmpty) return value;
      value.removeAt(0);
      break;
    default:
      break;
  }
  switch (value.runtimeType) {
    case ObjectId:
      value = ObjectId();
      break;
    case double:
      value = value == 0 ? 1 : 0;
      break;
    case int:
      value = value == 0 ? 1 : 0;
      break;
    case bool:
      value = !value;
      break;
    case String:
      value += 'hello';
      break;
    case DateTime:
      value = (value as DateTime).add(Duration(days: 1));
      break;
    default:
      break;
  }
  return value;
}

// change each field of the json, a little
// affect the given json itself, and may also change it child
// example:
// List x=[1,2]
// Map y={'a':x,'b':1}
// changeLittle(y)
// y is now {'a':x,'b':0}
// x is now [2]
void changeLittle(dynamic json) {
  for (var key in json.keys) {
    json[key] = _changeByType(json[key]);
  }
}
