class Events{
  String _id;
  bool _subscribed;

  Events(this._subscribed);

  Events.withId(this._id, this._subscribed);

  String get id => _id;

  bool get subscribed => _subscribed;

  set id(String newId){
    this._id = newId;
  }

  set subscriber(bool newSubscribed){
    this._subscribed = newSubscribed;
  }

  Map<String, dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['id'] = _id;
    map['subscribed'] = _subscribed;
    return map;
  }

  Events.fromMapObject(Map<String, dynamic> map){
    _id = map['id'];
    _subscribed = map['subscribed'];
  }

  
}