import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'icons/icons1/my_icons_icons.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'dart:convert';

void main() => runApp(new MyApp());

//AppStarter
class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

//App States
enum PlayerState {stopped,playing,paused}


//Widgets
class MyAppState extends State<MyApp>{
  String _url;
  var ind=0;
  String name;
  List _songs;
  MusicFinder audioPlayer = new MusicFinder();

  PlayerState playerState = PlayerState.paused;

  @override
  void initState(){
      super.initState();
      initPlayer();
  }
  
  void initPlayer() async{
    var songs = await MusicFinder.allSongs();
    songs = new List.from(songs);

    setState(() {
     this._songs = songs;
     this.name = this._songs!=null?_songs[this.ind].title: "No Songs Found";
     this._url = this._songs!=null?_songs[this.ind].uri:"";
    });
  }

  var _page = 0;
  Page(){
    if(_page == 0){
      return _Page1();
    }
    if(_page == 1){
      return _Page2();
    }
    if(_page == 2){
      return Scaffold(body: Text('3'));
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amza Music',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
      ),
      home: new Center(
        child: new Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {

              },
            ),
            title: Center(child: Text("Amza Music",textAlign: TextAlign.center,),), 
            elevation: 0.0,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {

                },
              ),
            ],
          ),
          body: Page(),
          bottomNavigationBar: new BottomNavigationBar(
            currentIndex: _page,
            onTap: (int index) {
              setState(() {
                _page = index;    
              });
            },
            iconSize: 20.0,
            items: [
              BottomNavigationBarItem(
                icon: new Icon(FontAwesomeIcons.home),
                title: new Text("Home"),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.compactDisc),
                title: new Text("Player"),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.listAlt),
                title: new Text("Playlists"),
              ),
            ],
          )
        )
      )
    );
  }

  Widget _Page1() {
    return new DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
          title: Text(
            "Your Music",
            style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.normal,color: Colors.grey),
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: "ALL",
              ),
              Tab(
                text: "ALBUMS",
              ),
              Tab(
                text: "ARTISTS",
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: this._songs!=null? this._songs.length:0,
              itemBuilder: (context,i) {
                return new FlatButton(child: ListTile(
                  leading: CircleAvatar(
                    child: Text(this._songs[i].title[0]),
                  ),
                  title:Text(this._songs[i].title)
                ), onPressed: () {
                  setState(() {
                    this.name = this._songs[i].title;
                    this.ind = i;
                    this._url = this._songs[this.ind].uri;
                    _playLocal(this._url);
                    this._page = 1;
                  });
                },);
              },
            ),
            ListView.builder(
              itemCount: 4,
              itemBuilder: (context,i) {
                return new FlatButton(child: ListTile(
                  leading: CircleAvatar(
                    child: Text('$i'),
                  ),
                  title:Text("data1")
                ),onPressed: () {

                },);
              },
            ),
            ListView.builder(
              itemCount: 2,
              itemBuilder: (context,i) {
                return new FlatButton(child:ListTile(
                  leading: CircleAvatar(
                    child: Text('$i'),
                  ),
                  title:Text("data2")
                ),onPressed: () {

                },);
              },
            ),
          ],
        )
      ),
    );
  }

  Widget _Page2(){
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0, bottom: 8.0),
          child: Image.asset('graphics/sample_cover.jpg'),
        ),
        AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
          title: Text(this.name.toUpperCase(),style: TextStyle(fontSize: 18.0,color: Colors.grey,fontWeight: FontWeight.normal),),
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.info),
              iconSize: 18.0,
              onPressed: () {

              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            IconButton(
              icon: Icon(FontAwesomeIcons.stepBackward),
              onPressed: () {
                backward();
              },
            ),
            Spacer(),
            IconButton(
              icon: playerState==PlayerState.paused? Icon(FontAwesomeIcons.play):Icon(FontAwesomeIcons.pause),
              onPressed: () {
                if(playerState==PlayerState.paused){
                  setState(() {
                    _playLocal(_url);
                  });
                } else if(playerState==PlayerState.playing){
                  setState(() {
                    pause();
                  });
                }
              },
            ),
            Spacer(),
            IconButton(
              icon: Icon(FontAwesomeIcons.stepForward),
              onPressed: () {
                forward();
              },
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }


  Future _playLocal(String url) async{
    final result = await this.audioPlayer.play(url, isLocal: true);
    if (result == 1) setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  forward(){
    if(this.ind < this._songs.length){
      setState(() {
        this.ind = this.ind+1;
        this.name = this._songs[ind].title;
        this._url = this._songs[ind].uri;
        stop();
        _playLocal(this._url);        
      });
    } else {
      setState(() {
        this.ind = 0;
        this.name = this._songs[ind].title;
        this._url = this._songs[ind].uri;
        stop();
        _playLocal(this._url);        
      });
    }
  }

  backward(){
    if(this.ind > 0){
      setState(() {
        this.ind = this.ind-1;
        this.name = this._songs[ind].title;
        this._url = this._songs[ind].uri;
        stop();
        _playLocal(this._url);        
      });
    } else {
      setState(() {
        this.ind = this._songs.length-1;
        this.name = this._songs[ind].title;
        this._url = this._songs[ind].uri;
        stop();
        _playLocal(this._url);        
      });      
    }
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
    });
  }

}
