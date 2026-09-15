class NotificationEmotionModel {
  final bool? allowed;
  final int? totalCount;
  final String? userReaction;
  final EmotionSummary? summary;

  NotificationEmotionModel({
    this.allowed,
    this.totalCount,
    this.userReaction,
    this.summary,
  });

  factory NotificationEmotionModel.fromJson(Map<String, dynamic> json) {
    return NotificationEmotionModel(
      allowed: json['allowed'] as bool?,
      totalCount: json['total_count'] as int?,
      // treat empty string as null (no reaction)
      userReaction: json['user_reaction'] is String &&
              (json['user_reaction'] as String).isNotEmpty
          ? json['user_reaction'] as String
          : null,
      summary: json['summary'] != null
          ? EmotionSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }

  NotificationEmotionModel copyWith({
    bool? allowed,
    int? totalCount,
    String? userReaction,
    bool clearUserReaction = false,
    EmotionSummary? summary,
  }) {
    return NotificationEmotionModel(
      allowed: allowed ?? this.allowed,
      totalCount: totalCount ?? this.totalCount,
      userReaction:
          clearUserReaction ? null : (userReaction ?? this.userReaction),
      summary: summary ?? this.summary,
    );
  }
}

class EmotionSummary {
  final int like;
  final int love;
  final int care;
  final int haha;
  final int wow;
  final int sad;
  final int angry;

  const EmotionSummary({
    this.like = 0,
    this.love = 0,
    this.care = 0,
    this.haha = 0,
    this.wow = 0,
    this.sad = 0,
    this.angry = 0,
  });

  factory EmotionSummary.fromJson(Map<String, dynamic> json) {
    return EmotionSummary(
      like: (json['like'] as num?)?.toInt() ?? 0,
      love: (json['love'] as num?)?.toInt() ?? 0,
      care: (json['care'] as num?)?.toInt() ?? 0,
      haha: (json['haha'] as num?)?.toInt() ?? 0,
      wow: (json['wow'] as num?)?.toInt() ?? 0,
      sad: (json['sad'] as num?)?.toInt() ?? 0,
      angry: (json['angry'] as num?)?.toInt() ?? 0,
    );
  }

  int getCount(String emotion) {
    switch (emotion) {
      case 'like':
        return like;
      case 'love':
        return love;
      case 'care':
        return care;
      case 'haha':
        return haha;
      case 'wow':
        return wow;
      case 'sad':
        return sad;
      case 'angry':
        return angry;
      default:
        return 0;
    }
  }

  EmotionSummary copyWithAdjusted({
    String? increment,
    String? decrement,
  }) {
    int delta(String key) {
      int d = 0;
      if (increment == key) d++;
      if (decrement == key) d--;
      return d;
    }

    return EmotionSummary(
      like: (like + delta('like')).clamp(0, 999999),
      love: (love + delta('love')).clamp(0, 999999),
      care: (care + delta('care')).clamp(0, 999999),
      haha: (haha + delta('haha')).clamp(0, 999999),
      wow: (wow + delta('wow')).clamp(0, 999999),
      sad: (sad + delta('sad')).clamp(0, 999999),
      angry: (angry + delta('angry')).clamp(0, 999999),
    );
  }

  int get total => like + love + care + haha + wow + sad + angry;
}
