class LocalReminder {
  final int? id;
  final String? serverId;
  final String title;
  final String description;
  final String time;
  final String date;
  final String runtime;
  final bool isCompleted;
  final String priority; // 'high', 'medium', 'low'
  final bool isSynced;
  final bool isDeleted;
  final String? pendingAction; // 'create', 'update', 'delete'

  LocalReminder({
    this.id,
    this.serverId,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.runtime,
    required this.isCompleted,
    required this.priority,
    this.isSynced = false,
    this.isDeleted = false,
    this.pendingAction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'title': title,
      'description': description,
      'time': time,
      'date': date,
      'runtime': runtime,
      'is_completed': isCompleted ? 1 : 0,
      'priority': priority,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'pending_action': pendingAction,
    };
  }

  factory LocalReminder.fromMap(Map<String, dynamic> map) {
    return LocalReminder(
      id: map['id']?.toInt(),
      serverId: map['server_id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      runtime: map['runtime'] ?? '',
      isCompleted: (map['is_completed'] ?? 0) == 1,
      priority: map['priority'] ?? 'medium',
      isSynced: (map['is_synced'] ?? 0) == 1,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      pendingAction: map['pending_action'],
    );
  }

  LocalReminder copyWith({
    int? id,
    String? serverId,
    String? title,
    String? description,
    String? time,
    String? date,
    String? runtime,
    bool? isCompleted,
    String? priority,
    bool? isSynced,
    bool? isDeleted,
    String? pendingAction,
  }) {
    return LocalReminder(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      date: date ?? this.date,
      runtime: runtime ?? this.runtime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingAction: pendingAction ?? this.pendingAction,
    );
  }
}