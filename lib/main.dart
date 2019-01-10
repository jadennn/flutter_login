import 'package:flutter/material.dart';
import 'package:flutter_login/bean/User.dart';
import 'package:flutter_login/util/SharedPreferenceUtil.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  debugPaintSizeEnabled = false; //调试用
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey _globalKey = new GlobalKey(); //用来标记控件
  String _version; //版本号
  String _username = ""; //用户名
  String _password = ""; //密码
  bool _expand = false; //是否展示历史账号
  List<User> _users = new List(); //历史账号

  @override
  void initState() {
    super.initState();
    _getVersion();
    _gainUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: 500,
              child: Flex(direction: Axis.vertical, children: <Widget>[
                Expanded(
                  child: Container(
                    child: Icon(
                      Icons.account_balance,
                      size: 100,
                    ),
                  ),
                  flex: 3,
                ),
                _buildUsername(),
                _buildPassword(),
                _buildLoginButton(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 20),
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Text("版本号:$_version"),
                  ),
                  flex: 2,
                ),
              ]),
            ),
          ),
          Offstage(
            child: _buildListView(),
            offstage: !_expand,
          ),
        ],
      ),
    );
  }

  ///构建账号输入框
  Widget _buildUsername() {
    return TextField(
      key: _globalKey,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide()),
        contentPadding: EdgeInsets.all(8),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(Icons.person_outline),
        suffixIcon: GestureDetector(
          onTap: () {
            if (_users.length > 1 || _users[0] != User(_username, _password)) {
              //如果个数大于1个或者唯一一个账号跟当前账号不一样才弹出历史账号
              setState(() {
                _expand = !_expand;
              });
            }
          },
          child: _expand
              ? Icon(
                  Icons.arrow_drop_up,
                  color: Colors.red,
                )
              : Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
        ),
      ),
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: _username,
          selection: TextSelection.fromPosition(
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: _username == null ? 0 : _username.length,
            ),
          ),
        ),
      ),
      onChanged: (value) {
        _username = value;
      },
    );
  }

  ///构建密码输入框
  Widget _buildPassword() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide()),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.lock),
          contentPadding: EdgeInsets.all(8),
        ),
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: _password,
            selection: TextSelection.fromPosition(
              TextPosition(
                affinity: TextAffinity.downstream,
                offset: _password == null ? 0 : _password.length,
              ),
            ),
          ),
        ),
        onChanged: (value) {
          _password = value;
        },
        obscureText: true,
      ),
    );
  }

  ///构建历史账号ListView
  Widget _buildListView() {
    if (_expand) {
      List<Widget> children = _buildItems();
      if (children.length > 0) {
        RenderBox renderObject = _globalKey.currentContext.findRenderObject();
        final position = renderObject.localToGlobal(Offset.zero);
        double screenW = MediaQuery.of(context).size.width;
        double currentW = renderObject.paintBounds.size.width;
        double currentH = renderObject.paintBounds.size.height;
        double margin = (screenW - currentW) / 2;
        double offsetY = position.dy;
        double itemHeight = 30.0;
        double dividerHeight = 2;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: ListView(
            itemExtent: itemHeight,
            padding: EdgeInsets.all(0),
            children: children,
          ),
          width: currentW,
          height: (children.length * itemHeight +
              (children.length - 1) * dividerHeight),
          margin: EdgeInsets.fromLTRB(margin, offsetY + currentH, margin, 0),
        );
      }
    }
    return null;
  }

  ///构建历史记录items
  List<Widget> _buildItems() {
    List<Widget> list = new List();
    for (int i = 0; i < _users.length; i++) {
      if (_users[i] != User(_username, _password)) {
        //增加账号记录
        list.add(_buildItem(_users[i]));
        //增加分割线
        list.add(Divider(
          color: Colors.grey,
          height: 2,
        ));
      }
    }
    if (list.length > 0) {
      list.removeLast(); //删掉最后一个分割线
    }
    return list;
  }

  ///构建单个历史记录item
  Widget _buildItem(User user) {
    return GestureDetector(
      child: Container(
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(user.username),
              ),
            ),
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.highlight_off,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                setState(() {
                  _users.remove(user);
                  SharedPreferenceUtil.delUser(user);
                  //处理最后一个数据，假如最后一个被删掉，将Expand置为false
                  if (!(_users.length > 1 ||
                      _users[0] != User(_username, _password))) {
                    //如果个数大于1个或者唯一一个账号跟当前账号不一样才弹出历史账号
                    _expand = false;
                  }
                });
              },
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _username = user.username;
          _password = user.password;
          _expand = false;
        });
      },
    );
  }

  ///构建登录按钮
  Widget _buildLoginButton() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      width: double.infinity,
      child: FlatButton(
        onPressed: () {
          //提交
          SharedPreferenceUtil.saveUser(User(_username, _password));
          SharedPreferenceUtil.addNoRepeat(_users, User(_username, _password));
        },
        child: Text("登录"),
        color: Colors.blueGrey,
        textColor: Colors.white,
        highlightColor: Colors.blue,
      ),
    );
  }

  ///获取版本号
  void _getVersion() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _version = packageInfo.version;
      });
    });
  }

  ///获取历史用户
  void _gainUsers() async {
    _users.clear();
    _users.addAll(await SharedPreferenceUtil.getUsers());
    //默认加载第一个账号
    if (_users.length > 0) {
      _username = _users[0].username;
      _password = _users[0].password;
    }
  }
}
