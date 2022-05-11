import 'package:flutter/material.dart';
import 'package:sellers_app/mainScreens/items_screen.dart';
import 'package:sellers_app/model/items.dart';
import 'package:sellers_app/model/menus.dart';

// TODO: Refactor to a Strategy Pattern (maybe) since the same as InfoDesign or extend an interface to Menus and Items
class ItemsDesignWidget extends StatefulWidget {
  Items? model;
  BuildContext? context;

  ItemsDesignWidget({this.model, this.context});

  @override
  State<ItemsDesignWidget> createState() => _ItemsDesignWidgetState();
}



class _ItemsDesignWidgetState extends State<ItemsDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemsScreen(
            // model: widget.model
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
                  const SizedBox(height: 1,),
                  Image.network(
                    widget.model!.thumbnailUrl!,
                    height: 220.0,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 1.0,),
                  Text(
                    widget.model!.title!,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 20,
                      fontFamily: "Train",
                    ),
                  ),
                  const SizedBox(height: 1,),
                  Text(
                    widget.model!.shortInfo!,
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
