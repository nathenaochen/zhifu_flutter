import 'package:json_annotation/json_annotation.dart';
import "cacheConfig.dart";
part 'profile.g.dart';

@JsonSerializable()
class Profile {
    Profile();

    String token;
    num theme;
    CacheConfig cache;
    String lastLogin;
    String locale;
    String account;
    String id;
    String role;
    String username;
    
    factory Profile.fromJson(Map<String,dynamic> json) => _$ProfileFromJson(json);
    Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
