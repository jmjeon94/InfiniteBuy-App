import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Home(),
    );
  }
}

class Controller extends GetxController {
  var count = [1, 2, 3].obs;

  increment() {
    count[1]+=3;
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final Controller c = Get.put(Controller());

    return Scaffold(
      // Use Obx(()=> to update Text() whenever count is changed.
        appBar: AppBar(),

        // Replace the 8 lines Navigator.push by a simple Get.to(). You don't need context
        body: Center(
            child: Column(children: [
              // Obx(()=>Text('${c.count}')),
              ListWidget(1),
              // Obx(() => ListWidget(c.count)),
              ElevatedButton(
                  child: Text("Go to Other"), onPressed: () => Get.to(Other()))
            ])),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: c.increment));
  }
}

class ListWidget extends StatelessWidget {
  // const ListWidget({Key? key}) : super(key: key);
  final Controller c = Get.find();

  var idx;
  ListWidget(this.idx);


  @override
  Widget build(BuildContext context) {

    return Container(
        // child: Obx(()=>Text('${data}'))
        child: Obx(()=>Text('${c.count[idx]}'))
    );
  }
}


class Other extends StatelessWidget {
  // You can ask Get to find a Controller that is being used by another page and redirect you to it.
  final Controller c = Get.find();

  @override
  Widget build(context) {
    // Access the updated count variable
    return Scaffold(
        appBar: AppBar(
          // title: Obx(() => Text("Clicks: ${c.count}")),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shadowColor: Colors.transparent,
        ),
        body: Center(child: Obx(() => Text("${c.count}"))),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: c.increment));
  }
}
