class LocalNote {
  final int? id;
  final String? serverId;
  final String title;
  final String content;
  final String createdAt;
  final bool isReminder;
  final bool isPinned;
  final bool isSynced;
  final bool isDeleted;
  final String? pendingAction; // 'create', 'update', 'delete'

  LocalNote({
    this.id,
    this.serverId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isReminder,
    this.isPinned = false,
    this.isSynced = false,
    this.isDeleted = false,
    this.pendingAction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'is_reminder': isReminder ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'pending_action': pendingAction,
    };
  }

  factory LocalNote.fromMap(Map<String, dynamic> map) {
    return LocalNote(
      id: map['id']?.toInt(),
      serverId: map['server_id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['created_at'] ?? '',
      isReminder: (map['is_reminder'] ?? 0) == 1,
      isPinned: (map['is_pinned'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      pendingAction: map['pending_action'],
    );
  }

  LocalNote copyWith({
    int? id,
    String? serverId,
    String? title,
    String? content,
    String? createdAt,
    bool? isReminder,
    bool? isPinned,
    bool? isSynced,
    bool? isDeleted,
    String? pendingAction,
  }) {
    return LocalNote(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isReminder: isReminder ?? this.isReminder,
      isPinned: isPinned ?? this.isPinned,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingAction: pendingAction ?? this.pendingAction,
    );
  }
}