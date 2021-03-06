import 'package:flutter/material.dart';
import 'package:sellers_app/mainScreens/items_screen.dart';
import 'package:sellers_app/model/menus.dart';

class InfoDesignWidget extends StatefulWidget {
  Menus? model;
  BuildContext? context;

  InfoDesignWidget({this.model, this.context});

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}



class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemsScreen(
          model: widget.model
        )));
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: 285,
          width: MediaQuery.of(context).size.width,
          child:
          // wrapped Column in SingleChildScrollView to deal with menu descriptions that are longer than container
          SingleChildScrollView(
            child:           Column(
              children: [
                Divider(
                  height: 4,
                  thickness: 3,
                  // not too grey
                  color: Colors.grey[300],
                ),
                Image.network(
                  widget.model!.thumbnailUrl!,
                  height: 220.0,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 1.0,),
                Text(
                  widget.model!.menuTitle!,
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 20,
                    fontFamily: "Train",
                  ),
                ),
                Text(
                  widget.model!.menuInfo!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
                Divider(
                  height: 4,
                  thickness: 3,
                  color: Colors.grey[300],
                )
              ],
            ),
          )

        ),
      ),
    );
  }
}
