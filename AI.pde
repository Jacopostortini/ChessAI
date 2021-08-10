class AI {
  Board board;
  int player;
  boolean dead = false;

  AI(Board board, int player) {
    this.board = board;
    this.player = player;
  }

  void play() {
    if (!dead && myTurn()) {
      //Move move = null;
      //int rand;
      //while (move == null) {
      //  rand = (int)random(64);
      //  MovesList list = board.movesManager.currentPlayersMoves[rand];
      //  move = list.pickRandom();
      //}
      board.move(findBestMove());
      board.updateAvailableMoves();
    }
  }

  boolean myTurn() {
    return board.playingPlayer == player;
  }
  
  Move findBestMove(){
    Move bestMove = null;
    int bestValue = -99999;
    for(int i = 0; i < 64; i++){
      if(Pieces.isColor(board.state[i], player)){
        for(Move move: board.movesManager.currentPlayersMoves[i]){
          board.move(move);
          int val = board.evaluateState(player);
          board.undo(1);
          if(val > bestValue){
            bestValue = val;
            bestMove = move;
          }
        }
      }
    }
    
    return bestMove;
  }
}
