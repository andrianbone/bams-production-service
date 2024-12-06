import 'package:flutter/material.dart';
import '../bloc/checkin_list_bloc.dart';
import '../widget/popup_checkin.dart';
import '../widget/internet.dart';
import '../services/api.dart';
import 'home.dart';

class CheckInListPage extends StatefulWidget {
  const CheckInListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CheckInListPageState();
  }
}

class _CheckInListPageState extends State<CheckInListPage> {
  final CheckInListBloc _bookorderBloc = CheckInListBloc();
  Icon _searchIcon = const Icon(Icons.search);
  final TextEditingController _filter = TextEditingController();
  Widget _appBarTitle = const Row(
    children: <Widget>[
      Image(
        image: AssetImage('assets/logo-bams.png'),
      ),
      Text(
        "- Check In",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15.0),
      ),
    ],
  );

  Widget _buildList() {
    return Stack(
      children: <Widget>[
        IndexedStack(
          index: 0,
          children: <Widget>[
            Center(
              child: StreamBuilder(
                  stream: _bookorderBloc.bookingOrderObservable,
                  initialData: const [],
                  builder: (ctx, AsyncSnapshot snapshot) {
                    if (snapshot.data.length == 0) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.data['status'] == 'N') {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${snapshot.data['message']}'),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            highlightColor: Colors.blue,
                            onPressed: _getData,
                          ),
                        ],
                      );
                    } else {
                      return RefreshIndicator(
                          onRefresh: _getData,
                          child: ListView.separated(
                              // separatorBuilder: (context, index) =>
                              //     Divider(color: Colors.black),
                              separatorBuilder: (context, index) => Container(),
                              itemCount: snapshot.data['response'].length,
                              itemBuilder: (BuildContext ctx, int index) {
                                final element =
                                    snapshot.data['response'][index];
                                return WidgetPopUpCheckIn(
                                    params: element, parent: context);
                              }));
                    }
                  }),
            )
          ],
        ),
        const InternetWgt(),
      ],
    );
  }

  Future<void> _getData() async {
    setState(() {
      _bookorderBloc.getListData(packageID);
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = const Icon(Icons.close);
        _appBarTitle = TextField(
          controller: _filter,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search...'),
          onChanged: (String value) {
            _bookorderBloc.searchData(value);
          },
        );
      } else {
        _searchIcon = const Icon(Icons.search);
        _appBarTitle = const Row(
          children: <Widget>[
            Image(
              image: AssetImage('assets/logo-bams.png'),
            ),
            Text(
              "- Check Out",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0),
            ),
          ],
        );
        // filteredNames = names;
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        centerTitle: true,
        title: _appBarTitle,
        leading: IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.white10,
      //   titleSpacing: 0.0,
      //   title: Row(
      //     children: [
      //       IconButton(
      //           icon: Icon(Icons.home),
      //           onPressed: () {
      //             Navigator.pop(context);
      //           }),
      //       _appBarTitle,
      //     ],
      //   ),
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   actions: <Widget>[
      //     Row(
      //       children: <Widget>[
      //         new IconButton(
      //           icon: _searchIcon,
      //           onPressed: _searchPressed,
      //         )
      //       ],
      //     )
      //   ],
      // ),
      body: Container(
        child: _buildList(),
      ),
    );
  }
}
