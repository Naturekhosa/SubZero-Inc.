import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swap_shop/chatSystem/chat_detail.dart';
import 'package:swap_shop/models/database_manager.dart';
import 'package:swap_shop/models/user_listing_model.dart';
import 'package:swap_shop/models/user_model.dart';
import 'package:swap_shop/screens/create_listing.dart';
import 'package:swap_shop/screens/details_screen.dart';
import 'package:swap_shop/screens/edit_list.dart';
import 'package:swap_shop/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:swap_shop/screens/main_navigation_drawer.dart';
//   "flutter upgrade" to upgrade flutter

class Viewlist extends StatefulWidget {
  final String description;
  final String listingProvince;
  final String listingCity;
  final String itemName;
  final String timeStamp;
  final String category;
  final String listingID;
  final List imagesUrls;
  final List subCategories;

  const Viewlist(
      {Key? key,
      required this.description,
      required this.listingProvince,
      required this.listingCity,
      required this.itemName,
      required this.imagesUrls,
      required this.timeStamp,
      required this.category,
      required this.listingID,
      required this.subCategories})
      : super(key: key);

  @override
  State<Viewlist> createState() => _ViewlistState();
}

class _ViewlistState extends State<Viewlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditList(
                            description: description,
                            listingProvince: listingProvince,
                            listingCity: listingCity,
                            itemName: itemName,
                            imagesUrls: imagesUrls,
                            subCategories: subCategories,
                            timeStamp: timeStamp,
                            category: category,
                            listingID: listingID,
                          )));
            },
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(0), // Image border
            child: CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                viewportFraction: 1,
                enableInfiniteScroll: false,
              ),
              items: widget.imagesUrls.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(color: Colors.amber),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0), // Image border
                        child: AspectRatio(
                          aspectRatio: 15 / 9,
                          child: Image.network(
                            i,
                            fit: BoxFit.fill, // use this
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            )),
        Expanded(
            child: Container(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    widget.itemName,
                    style: Theme.of(context).textTheme.headline5,
                  ), //item name display
                ]),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text("Description : " + widget.description)),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text("City : " + widget.listingCity)
                    //style: Theme.of(context).textTheme.headlineSmall),
                    ),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text("Province : " + widget.listingProvince)
                    //style: Theme.of(context).textTheme.headlineSmall),
                    ),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text("Upload Date : " + widget.timeStamp)
                    //style: Theme.of(context).textTheme.headlineSmall),
                    ),
                if ((widget.subCategories[0] == "N/A") == false)
                  Text(widget.subCategories[0]),
              ],
            ),
          ),
        ))
      ]),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              deleteItem(docId: widget.listingID);
              Navigator.pop(context);
            },
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          )
        ],
      ),
    );
  }

  //A function responsible for deleting a listing
  static Future<void> deleteItem({
    required String docId,
  }) async {
    DocumentReference documentReferencer =
        FirebaseFirestore.instance.collection("Listing2").doc(docId);

    await documentReferencer
        .delete()
        .whenComplete(() => Fluttertoast.showToast(
            msg: "Listing deleted!",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Color.fromARGB(255, 136, 131, 131),
            fontSize: 20))
        .catchError((e) => print(e));
  }
}