part of openapi.api;

// Category
class Category {
    
      int id;
    
      String name;
Category();

  @override
  String toString() {
    return 'Category[id=$id, name=$name, ]';
  }

  fromJson(Map<String, dynamic> json) {
    if (json == null) return;
  
    id = (json[r'id'] == null) ? null :   (json[r'id'] as int)
;
        name = (json[r'name'] == null) ? null :   (json[r'name'] as String)
;
    
  }

  Category.fromJson(Map<String, dynamic> json) {
    fromJson(json); // allows child classes to call
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (id != null) {
          json[r'id'] = id;
    } 
    if (name != null) {
          json[r'name'] = name;
    } 
    return json;
  }
  static List<Category> listFromJson(List<dynamic> json) {
    return json == null ? <Category>[] : json.map((value) => Category.fromJson(value)).toList();
  }

  static Map<String, Category> mapFromJson(Map<String, dynamic> json) {
    final map = <String, Category>{};
    if (json != null && json.isNotEmpty) {
      json.forEach((String key, dynamic value) => map[key] = Category.fromJson(value));
    }
    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is Category && runtimeType == other.runtimeType) {
    return 

     id == other.id &&
  

     name == other.name  
    ;
    }

    return false;
  }

  @override
  int get hashCode {
    var hashCode = runtimeType.hashCode;

    
      if (id != null) {
        hashCode = hashCode * 31 + id.hashCode;
    }

      if (name != null) {
        hashCode = hashCode * 31 + name.hashCode;
    }


    return hashCode;
  }

  Category copyWith({
         int id,
         String name,
    }) {
    Category copy = Category();
  id ??= this.id;
  name ??= this.name;
  
      copy.id =   id
;
          copy.name =   name
;
    
    return copy;
  }
}


