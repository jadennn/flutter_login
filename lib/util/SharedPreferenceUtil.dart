import 'package:flutter_login/bean/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

///数据库相关的工具
class SharedPreferenceUtil {
  static const String ACCOUNT_NUMBER = "account_number";
  static const String USERNAME = "username";
  static const String PASSWORD = "password";

  ///删掉单个账号
  static void delUser(User user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<User> list = await getUsers();
    list.remove(user);
    saveUsers(list, sp);
  }

  ///保存账号，如果重复，就将最近登录账号放在第一个
  static void saveUser(User user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<User> list = await getUsers();
    addNoRepeat(list, user);
    saveUsers(list, sp);
  }

  ///去重并维持次序
  static void addNoRepeat(List<User> users, User user) {
    if (users.contains(user)) {
      users.remove(user);
    }
    users.insert(0, user);
  }

  ///获取已经登录的账号列表
  static Future<List<User>> getUsers() async {
    List<User> list = new List();
    SharedPreferences sp = await SharedPreferences.getInstance();
    int num = sp.getInt(ACCOUNT_NUMBER) ?? 0;
    for (int i = 0; i < num; i++) {
      String username = sp.getString("$USERNAME$i");
      String password = sp.getString("$PASSWORD$i");
      list.add(User(username, password));
    }
    return list;
  }

  ///保存账号列表
  static saveUsers(List<User> users, SharedPreferences sp){
    sp.clear();
    int size = users.length;
    for (int i = 0; i < size; i++) {
      sp.setString("$USERNAME$i", users[i].username);
      sp.setString("$PASSWORD$i", users[i].password);
    }
    sp.setInt(ACCOUNT_NUMBER, size);
  }
}
