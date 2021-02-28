part of openapi.api;

// Subscription
class Subscription {
  int id;

  String title;

  int category;

  DateTime startsAt;

  DateTime endsAt;

  String recurrence;

  DateTime nextRecurrence;

  DateTime trialEndsAt;

  int cost;

  int trialCost;
  Subscription(
      {this.title,
      this.category,
      this.startsAt,
      this.endsAt,
      this.recurrence,
      this.nextRecurrence,
      this.trialEndsAt,
      this.cost});

  @override
  String toString() {
    return 'Subscription[id=$id, title=$title, category=$category, startsAt=$startsAt, endsAt=$endsAt, recurrence=$recurrence, nextRecurrence=$nextRecurrence, trialEndsAt=$trialEndsAt, cost=$cost, trialCost=$trialCost, ]';
  }

  fromJson(Map<String, dynamic> json) {
    if (json == null) return;

    id = (json[r'id'] == null) ? null : (json[r'id'] as int);
    title = (json[r'title'] == null) ? null : (json[r'title'] as String);
    category = (json[r'category'] == null) ? null : (json[r'category'] as int);
    startsAt = (json[r'starts_at'] == null)
        ? null
        : DateTime.parse(json[r'starts_at'] + 'T00:00:00.000Z');
    endsAt = (json[r'ends_at'] == null)
        ? null
        : DateTime.parse(json[r'ends_at'] + 'T00:00:00.000Z');
    recurrence =
        (json[r'recurrence'] == null) ? null : (json[r'recurrence'] as String);
    nextRecurrence = (json[r'next_recurrence'] == null)
        ? null
        : DateTime.parse(json[r'next_recurrence'] + 'T00:00:00.000Z');
    trialEndsAt = (json[r'trial_ends_at'] == null)
        ? null
        : DateTime.parse(json[r'trial_ends_at'] + 'T00:00:00.000Z');
    cost = (json[r'cost'] == null) ? null : (json[r'cost'] as int);
    trialCost =
        (json[r'trial_cost'] == null) ? null : (json[r'trial_cost'] as int);
  }

  Subscription.fromJson(Map<String, dynamic> json) {
    fromJson(json); // allows child classes to call
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (id != null) {
      json[r'id'] = id;
    }
    if (title != null) {
      json[r'title'] = title;
    }
    if (category != null) {
      json[r'category'] = category;
    }
    if (startsAt != null) {
      json[r'starts_at'] = startsAt.toDateString();
    }
    if (endsAt != null) {
      json[r'ends_at'] = endsAt.toDateString();
    }
    if (recurrence != null) {
      json[r'recurrence'] = recurrence;
    }
    if (nextRecurrence != null) {
      json[r'next_recurrence'] = nextRecurrence.toDateString();
    }
    if (trialEndsAt != null) {
      json[r'trial_ends_at'] = trialEndsAt.toDateString();
    }
    if (cost != null) {
      json[r'cost'] = cost;
    }
    if (trialCost != null) {
      json[r'trial_cost'] = trialCost;
    }
    return json;
  }

  static List<Subscription> listFromJson(List<dynamic> json) {
    return json == null
        ? <Subscription>[]
        : json.map((value) => Subscription.fromJson(value)).toList();
  }

  static Map<String, Subscription> mapFromJson(Map<String, dynamic> json) {
    final map = <String, Subscription>{};
    if (json != null && json.isNotEmpty) {
      json.forEach((String key, dynamic value) =>
          map[key] = Subscription.fromJson(value));
    }
    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is Subscription && runtimeType == other.runtimeType) {
      return id == other.id &&
          title == other.title &&
          category == other.category &&
          startsAt == other.startsAt && // other

          endsAt == other.endsAt && // other

          recurrence == other.recurrence &&
          nextRecurrence == other.nextRecurrence && // other

          trialEndsAt == other.trialEndsAt && // other

          cost == other.cost &&
          trialCost == other.trialCost;
    }

    return false;
  }

  @override
  int get hashCode {
    var hashCode = runtimeType.hashCode;

    if (id != null) {
      hashCode = hashCode * 31 + id.hashCode;
    }

    if (title != null) {
      hashCode = hashCode * 31 + title.hashCode;
    }

    if (category != null) {
      hashCode = hashCode * 31 + category.hashCode;
    }

    if (startsAt != null) {
      hashCode = hashCode * 31 + startsAt.hashCode;
    }

    if (endsAt != null) {
      hashCode = hashCode * 31 + endsAt.hashCode;
    }

    if (recurrence != null) {
      hashCode = hashCode * 31 + recurrence.hashCode;
    }

    if (nextRecurrence != null) {
      hashCode = hashCode * 31 + nextRecurrence.hashCode;
    }

    if (trialEndsAt != null) {
      hashCode = hashCode * 31 + trialEndsAt.hashCode;
    }

    if (cost != null) {
      hashCode = hashCode * 31 + cost.hashCode;
    }

    if (trialCost != null) {
      hashCode = hashCode * 31 + trialCost.hashCode;
    }

    return hashCode;
  }

  Subscription copyWith({
    int id,
    String title,
    int category,
    DateTime startsAt,
    DateTime endsAt,
    String recurrence,
    DateTime nextRecurrence,
    DateTime trialEndsAt,
    int cost,
    int trialCost,
  }) {
    Subscription copy = Subscription();
    id ??= this.id;
    title ??= this.title;
    category ??= this.category;
    startsAt ??= this.startsAt;
    endsAt ??= this.endsAt;
    recurrence ??= this.recurrence;
    nextRecurrence ??= this.nextRecurrence;
    trialEndsAt ??= this.trialEndsAt;
    cost ??= this.cost;
    trialCost ??= this.trialCost;

    copy.id = id;
    copy.title = title;
    copy.category = category;
    copy.startsAt = startsAt;
    copy.endsAt = endsAt;
    copy.recurrence = recurrence;
    copy.nextRecurrence = nextRecurrence;
    copy.trialEndsAt = trialEndsAt;
    copy.cost = cost;
    copy.trialCost = trialCost;

    return copy;
  }
}
