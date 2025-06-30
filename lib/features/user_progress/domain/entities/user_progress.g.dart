// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      userId: json['userId'] as String,
      level: json['level'] as int,
      points: json['points'] as int,
      conversationsCompleted: json['conversationsCompleted'] as int,
      wordsLearned: json['wordsLearned'] as int,
      lastActive: DateTime.parse(json['lastActive'] as String),
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'level': instance.level,
      'points': instance.points,
      'conversationsCompleted': instance.conversationsCompleted,
      'wordsLearned': instance.wordsLearned,
      'lastActive': instance.lastActive.toIso8601String(),
    };