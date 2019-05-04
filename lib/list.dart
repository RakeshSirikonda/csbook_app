import 'package:csbook_app/model/Instance.dart';
import 'package:csbook_app/model/Song.dart';
import 'package:csbook_app/song.dart';
import 'package:csbook_app/widgets.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListScreen extends StatefulWidget {
  static const routeName = '/song_list';
  ListScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<ListScreen> {
  List<Song> songs = new List<Song>();

  _ListState();

  void getInstances(BuildContext context, Song song) {
    Navigator.pushNamed(
      context,
      SongScreen.routeName,
      arguments: song,
    );
  }

  @override
  void initState() {
    Song.get(0, 0).then((s) {
      setState(() {
        this.songs = s;
      });
    });
    super.initState();
  }

  Widget makeBody() {
    if (this.songs.length > 0) {
      return Scrollbar(
        child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (BuildContext context, int index) {
              return SongTile(songs[index], onTap: (song) {
                getInstances(context, song);
              });
            }),
      );
    } else {
      return FetchingWidget("Fetching list ...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Filter',
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: SongSearch(songs, (song) {
                      getInstances(context, song);
                    }));
              },
            ),
            /*
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Refresh list',
              onPressed: () {
                Song.get(0, 0).then((s) {
                  setState(() {
                    this.songs = s;
                  });
                });
              },
            ),
            */
          ],
        ),
        body: makeBody());
  }
}

class SongSearch extends SearchDelegate<Song> {
  final List<Song> songs;
  final void Function(Song) callBack;

  SongSearch(this.songs, this.callBack);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // show results based on selection
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // We dont have any suggestion for songs... Maybe Recents...

    final suggestionList = query.isEmpty
        ? []
        : songs
            .where((song) =>
                song.title.toLowerCase().contains(query.toLowerCase()) ||
                (song.author != null &&
                    song.author.toLowerCase().contains(query.toLowerCase())) ||
                (song.subtitle != null &&
                    song.subtitle.toLowerCase().contains(query.toLowerCase())))
            .toList();

    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) =>
            SongTile(suggestionList[index], onTap: (song) {
              close(context, null);
              callBack(suggestionList[index]);
            }));
  }
}
