import 'package:flutter/material.dart';


class TestDragPage extends StatefulWidget {
    @override
    _TestDragPageState createState() => _TestDragPageState();
}

class _TestDragPageState extends State<TestDragPage> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: FlatButton(
                    child: Text("Drag test."),
                    onPressed: () {
                        showModalBottomSheet(context: context, builder: (context) {
                            return DraggableScrollableSheet(
                                initialChildSize: 1.0,
                                minChildSize: 0.7,
//                                expand: false,
                                builder: (BuildContext context, ScrollController scrollController) {
                                    return Container(
                                        color: Colors.blue[100],
                                        child: ListView.builder(
                                            controller: scrollController,
                                            itemCount: 25,
                                            itemBuilder: (BuildContext context, int index) {
                                                return ListTile(title: Text('Item $index'));
                                            },
                                        ),
                                    );
                                },
                            );
                        });
                    },
                ),
            ),
        );
    }
}
