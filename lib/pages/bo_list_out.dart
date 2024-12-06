import 'package:flutter/material.dart';
import '../bloc/bo_list_out_bloc.dart';
import '../widget/popup_bo_list_out.dart';
import '../widget/internet.dart';
import '../services/api.dart';
import 'home.dart';

class BookingOrderOutListPage extends StatefulWidget {
  const BookingOrderOutListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BookingOrderOutListPageState();
  }
}

class _BookingOrderOutListPageState extends State<BookingOrderOutListPage> {
  final BoListOutBloc _bookorderBloc = BoListOutBloc();
  Icon _searchIcon = const Icon(
    Icons.search,
    color: Colors.black87,
  );
  final TextEditingController _filter = TextEditingController();

  Widget _appBarTitle = const Row(
    children: <Widget>[
      Image(
        image: AssetImage('assets/logo-bams.png'),
      ),
      Text(
        " - Check Out",
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
                                return WidgetPopUpBoListOut(params: element);
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
        _searchIcon = const Icon(
          Icons.close,
          color: Colors.black87,
        );
        _appBarTitle = TextField(
          controller: _filter,
          decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.black87,
              ),
              hintText: 'Search...'),
          onChanged: (String value) {
            _bookorderBloc.searchData(value);
          },
        );
      } else {
        _searchIcon = const Icon(
          Icons.search,
          color: Colors.black87,
        );
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
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          title: _appBarTitle,
          leading: IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Colors.black87,
                ),
                onPressed: () {
                  // Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }),
          ],
        ),
        body: _buildList());
  }
}
