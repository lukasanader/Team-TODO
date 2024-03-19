import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:english_words/english_words.dart';

String generateUniqueName(String docId) {
  final allNouns = Set<String>.from(nouns.take(5000));
  final allAdjectives = Set<String>.from(adjectives.take(5000));

  var bytes = utf8.encode(docId);
  var digest = sha256.convert(bytes);
  var hashInt = int.parse(digest.toString().substring(0, 8), radix: 16);

  String noun = allNouns.elementAt(hashInt % allNouns.length);
  String adjective = allAdjectives.elementAt(hashInt % allAdjectives.length);

  return '$adjective $noun';
}
