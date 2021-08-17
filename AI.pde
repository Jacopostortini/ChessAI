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
      Move bestMove = findBestMove(-1, player);
      if (bestMove == null) return;
      board.move(bestMove);
      board.updateAvailableMoves();
    }
  }

  boolean myTurn() {
    return board.playingPlayer == player;
  }

  MovesList findBestCapturingMoves(int depth, int player) {

    int maxEvaluation = -9999;
    MovesList bestMoves = new MovesList();

    if (depth == 1) {
      for (int i = 0; i < 64; i++) {
        if (!Pieces.isColor(board.state[i], player)) continue;
        for (Move move : board.movesManager.currentPlayersMoves[i]) {
          board.move(move);
          int evaluation = board.evaluateState(player);
          if (evaluation > maxEvaluation) {
            maxEvaluation = evaluation;
            bestMoves.clear();
            bestMoves.add(move);
          } else if (evaluation == maxEvaluation) {
            bestMoves.add(move);
          }
          board.undo(1);
          board.updateAvailableMoves();
        }
      }
    } else {
      for (int i = 0; i < 64; i++) {
        if (!Pieces.isColor(board.state[i], player)) continue;
        for (Move move : board.movesManager.currentPlayersMoves[i]) {
          board.move(move);
          board.updateAvailableMoves();
          Move opponentsBestResponse = findBestMove(depth-1, player ^ 24);
          board.move(opponentsBestResponse);
          
          int evaluation = board.evaluateState(player);
          board.undo(2);
          board.updateAvailableMoves();
          
          if(board.history.size() < 16){
            evaluation += evaluateByCenterControl(move, player); 
          }
          
          if (evaluation > maxEvaluation) {
            maxEvaluation = evaluation;
            bestMoves.clear();
            bestMoves.add(move);
          } else if (evaluation == maxEvaluation) {
            bestMoves.add(move);
          }
        }
      }
    }
    return bestMoves;
  }

  Move findBestMove(int depth, int player) {
    MovesList bestMoves = findBestCapturingMoves(depth == -1 ? 3 : depth, player);
    return bestMoves.get((int)random(bestMoves.size()));
    //return getBestCenterControl(bestMoves, player);
  }

  Move getBestCenterControl(MovesList list, int player) {
    ArrayList<Integer> centerControlEvaluations = evaluateByCenterControl(list, player);
    int m = -9999;
    Move best = null;
    for(int i = 0; i < list.size(); i++){
      if(centerControlEvaluations.get(i) > m){
        m = centerControlEvaluations.get(i);
        best = list.get(i);
      }
    }
    return best;
  }

  ArrayList evaluateByCenterControl(MovesList list, int player) {
    ArrayList<Integer> evaluations = new ArrayList();
    for (Move move : list) {
      evaluations.add(evaluateByCenterControl(move, player));
    }
    return evaluations;
  }

  int evaluateByCenterControl(Move move, int player) {
    int evaluation = 0;
    
    board.move(move);
    MovesList[] availableMoves = board.movesManager.getMovesByColor(player, false, false);
    for(int i = 0; i < 64; i++){
      for(Move m: availableMoves[i]){
        int file = m.getTo() % 8;
        int rank = m.getTo() / 8;
        evaluation += (3.5 - abs(file - 3.5)) * (3.5 - abs(rank - 3.5));
      }
    }
    board.undo(1);

    return evaluation;
  }
}
