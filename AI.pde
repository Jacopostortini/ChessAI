class AI {
  Board board;
  int player;
  boolean dead = false;
  
  AI(Board board, int player){
    this.board = board;
    this.player = player;
  }
  
  void play(){
    if(!dead && myTurn()){
      Move move = null;
      int rand;
      while(move == null){
        rand = (int)random(64);
        MovesList list = board.movesManager.currentPlayersMoves[rand];
        move = list.pickRandom();
      }
      board.move(move);
    }
  }
  
  boolean myTurn(){
    return board.playingPlayer == player;
  }
}
