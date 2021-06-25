main(List<String> args) {
  final you = You();
  if(you.sad){
    you.stopSadness();
    you.beAwesome();
  }
}

class You {
  String name;
  bool sad;

  void stopSadness(){
    print("Programming... n_n");
  }

  void beAwesome() {
    print('Yeah!!! B)');
  }
}