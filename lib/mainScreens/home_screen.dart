import 'package:flutter/material.dart';
import 'package:sellers_app/authentication/auth_screen.dart';
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/uploadScreens/menus_upload_screen.dart';
import 'package:sellers_app/widgets/user_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserDrawer(),
      appBar: AppBar(
        // TODO: colorful gradient thingy you'll want to change later
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan,
                  Colors.amber,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
          ),
        ),
        title: Text(
          sharedPreferences!.getString("name")!,
          style: const TextStyle(fontSize: 30, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: Colors.cyan,),
            onPressed: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const MenusUploadScreen()));
            },
          ),
        ],
      ),
      body: Center(
      ),
    );
  }
}
