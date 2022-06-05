import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swap_shop/models/database_manager.dart';
import 'package:swap_shop/tradeWindow/tradeWindowModel.dart';

class TradeWindow extends StatefulWidget {
  final chatDocID;
  final friendUID;

  const TradeWindow(
      {Key? key, required this.friendUID, required this.chatDocID})
      : super(key: key);

  @override
  _TradeWindowState createState() => _TradeWindowState(friendUID, chatDocID);
}

class _TradeWindowState extends State<TradeWindow> {
  final friendUID;
  final chatDocID;
  final currentUserID = FirebaseAuth.instance.currentUser?.uid;
  CollectionReference trades =
      FirebaseFirestore.instance.collection('tradeWindows');
  TradeWindowModel tm = TradeWindowModel();
  var tradeWindowID;
  String itemName = "";
  String imageURL = "";
  List yourlistings = [];
  List theirlistings = [];
  _TradeWindowState(this.friendUID, this.chatDocID);

  @override
  void initState() {
    checkTradeWindow();
    super.initState();
  }

  deleteItem(String item) async {
    List temp = [];
    List ids = [];
    int delete = 0;
    String docID;
    await trades
        .doc(tradeWindowID)
        .collection(currentUserID!)
        .get()
        .then((querySnapshot) => {
              for (var doc in querySnapshot.docs)
                {temp.add(doc.data()), ids.add(doc.id), print(temp), print(ids)}
            });
    for (int i = 0; i < temp.length; i += 1) {
      if (item == yourlistings[i]['itemName'].toString()) {
        delete = i;
      }
      docID = ids[delete];
      await trades
          .doc(tradeWindowID)
          .collection(currentUserID!)
          .doc(docID)
          .delete();
    }

    /*  await trades
        .doc(tradeWindowID)
        .collection(currentUserID!)
        .get()
        .then((QuerySnapshot querySnapshots) async {
          if (querySnapshots.docs.isNotEmpty) {
            for (var result in querySnapshots.docs) 
            {
            trades
        .doc(tradeWindowID)
        .collection(currentUserID!).doc(result.id).where('itemName', isEqualTo: {'itemName': item})
            }
            trades
                .doc(tradeWindowID)
                .collection(currentUserID!)
                .doc(querySnapshots.docs.single.id)
                .delete();

          }
        }); */
  }

  Future checkTradeWindow() async {
    await trades
        .where('users', isEqualTo: {friendUID: null, currentUserID: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                tradeWindowID = querySnapshot.docs.single.id;
              });
            } else {
              await trades.add({
                'users': {currentUserID: null, friendUID: null},
              }).then((value) => {
                    setState(() {
                      tradeWindowID = value.id;
                    })
                  });
            }
          },
        )
        .catchError((error) {});
  }

  addItem(String item_Name, String image_URL) async {
    tm.itemName = item_Name;
    tm.imageURL = image_URL;
    await trades.doc(tradeWindowID).collection(currentUserID!).add(tm.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Trade Window"),
        ),
        body: Row(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width / 2,
              child: FutureBuilder(
                future: FireStoreDataBase()
                    .usersItems(currentUserID!, tradeWindowID),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    yourlistings = snapshot.data as List;

                    return Scaffold(
                        appBar: AppBar(
                            backgroundColor: Colors.red,
                            automaticallyImplyLeading: false,
                            title: Text("Your Items")),
                        floatingActionButton: FloatingActionButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Listings());
                            },
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            )),
                        body: Container(
                          color: Colors.redAccent,
                          child: ListView.builder(
                              itemCount: yourlistings.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          yourlistings[index]['imageURL'])),
                                  title: Text(
                                    yourlistings[index]['itemName'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: new Text("Confirm"),
                                              content: new Text("Remove Item?"),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  child: const Text("YES"),
                                                  onPressed: () {
                                                    String item =
                                                        yourlistings[index]
                                                            ['itemName'];
                                                    deleteItem(item);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ));
                                  },
                                );
                              }),
                        ));
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width / 2,
              child: FutureBuilder(
                future:
                    FireStoreDataBase().usersItems(friendUID, tradeWindowID),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    theirlistings = snapshot.data as List;
                    return Scaffold(
                        appBar: AppBar(
                            backgroundColor: Colors.green,
                            automaticallyImplyLeading: false,
                            title: Text(" Their Items")),
                        body: Container(
                          color: Colors.green,
                          child: ListView.builder(
                              itemCount: theirlistings.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          theirlistings[index]['imageURL'])),
                                  title: Text(theirlistings[index]['itemName'],
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () {},
                                );
                              }),
                        ));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ));
  }

  Widget Listings() {
    final uids = FirebaseAuth.instance.currentUser?.uid;
    List listings = [];
    List yourlistings = [];
    return Scaffold(
        appBar: AppBar(
          title: Text("Select An Item"),
        ),
        body: FutureBuilder(
          future: FireStoreDataBase().getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              yourlistings = snapshot.data as List;
              //select only listings posted by the user
              for (int i = 0; i < yourlistings.length; i += 1) {
                if (uids == yourlistings[i]['uid'].toString()) {
                  listings.add(yourlistings[i]);
                }
              }
              return Scaffold(
                  body: Center(
                child: ListView.builder(
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(listings[index]['imagesUrls'][0])),
                        title: Text(listings[index]['itemName']),
                        subtitle: Text(listings[index]['description']),
                        onTap: () {
                          setState(() {
                            itemName = listings[index]['itemName'];
                            imageURL = listings[index]['imagesUrls'][0];
                            addItem(itemName, imageURL);
                          });
                          Navigator.pop(context);
                        },
                      );
                    }),
              ));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
