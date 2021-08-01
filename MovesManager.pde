class MovesManager {
  Board board;
  MovesList[] currentPlayersMoves;
  int playerIndex;

  MovesManager(Board board) {
    this.board = board;
    currentPlayersMoves = getMovesByColor(board.playingPlayer, true, true);
  }

  MovesList[] getMovesByColor(int player, boolean castlings, boolean checkLegal) {
    playerIndex = (player >>> 3) - 1;

    MovesList[] moves = new MovesList[64];
    for (int i = 0; i < 64; i++) {
      int piece = board.state[i];
      if (Pieces.isColor(piece, player)) {
        moves[i] = getMovesByIndex(i, castlings, checkLegal);
      } else {
        moves[i] = new MovesList();
      }
    }


    return moves;
  }

  MovesList getMovesByIndex(int index, boolean castlings, boolean checkLegal) {
    MovesList moves = new MovesList();
    int piece = board.state[index];

    if (Pieces.isSlidingPiece(piece)) moves.addAll(getSlidingMoves(index, checkLegal));
    else if (Pieces.getType(piece) == Pieces.PAWN) moves.addAll(getPawnMoves(index, checkLegal));
    else if (Pieces.getType(piece) == Pieces.KNIGHT) moves.addAll(getKnightMoves(index, checkLegal));
    else if (Pieces.getType(piece) == Pieces.KING) moves.addAll(getKingMoves(index, castlings, checkLegal));
    return moves;
  }

  private MovesList getSlidingMoves(int index, boolean checkLegal) {
    int piece = board.state[index];
    MovesList moves = new MovesList();

    int startingDirectionIndex = (Pieces.getType(piece) == Pieces.BISHOP) ? 4 : 0;
    int endingDirectionIndex = (Pieces.getType(piece) == Pieces.ROOK) ? 4 : 8;
    for (int directionIndex = startingDirectionIndex; directionIndex < endingDirectionIndex; directionIndex++) {
      for (int n = 0; n < MovesData.distancesFromEdges[index][directionIndex]; n++) {
        int square = index + (n+1) * MovesData.offsetsByDirection[directionIndex];
        int target = board.state[square];

        if (Pieces.sameColor(piece, target)) break;

        Move move = new Move(index, square);
        if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, square));

        if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) break;
      }
    }

    return moves;
  }

  private MovesList getPawnMoves(int index, boolean checkLegal) {
    int piece = board.state[index];
    MovesList moves  = new MovesList();

    //Not at the end
    if (MovesData.distancesFromEdges[index][playerIndex] > 0) {
      int square;
      int target;

      //Check for diagonal

      int diagonalsIndex = playerIndex * 2 + 4;
      square = index + MovesData.offsetsByDirection[diagonalsIndex];
      try {
        target = board.state[square];
        if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) {
          Move move = new Move(index, square);
          if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, square));
        }
      } 
      catch(Exception e) {
        println(playerIndex);
        println(diagonalsIndex);
        println(square);
        println(index);
        e.printStackTrace();
        throw(e);
      }

      square = index + MovesData.offsetsByDirection[diagonalsIndex+1];
      target = board.state[square];
      if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) {
        Move move = new Move(index, square);
        if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, square));
      }

      //Check forwarding
      square = index + MovesData.offsetsByDirection[playerIndex];
      target = board.state[square];
      if (Pieces.getType(target) == Pieces.NONE) {
        Move move = new Move(index, square);
        if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, square));
      } else return moves;

      //If white and on rank 1 or black and on rank 6
      if (abs(index / 8 - 7*playerIndex) == 1) {
        square += MovesData.offsetsByDirection[playerIndex];
        target = board.state[square];

        if (Pieces.getType(target) == Pieces.NONE) {
          Move move = new Move(index, square);
          if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, square));
        }
      }
    }

    if (board.enPassant != -1) {

      if (abs( index - (board.enPassant - MovesData.offsetsByDirection[playerIndex]) ) == 1) {
        Move move = new Move(index, board.enPassant);
        if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, board.enPassant));
      }
    }

    return moves;
  }

  private MovesList getKnightMoves(int index, boolean checkLegal) {
    int piece = board.state[index];
    MovesList moves = new MovesList();

    int square;
    int target;
    for (int i = 0; i < MovesData.knightMoves.length; i++) {
      if (!MovesData.getKnightDistancesFromEdges()[index][i]) continue;
      square = index + MovesData.knightMoves[i];
      if (square > 63 || square < 0) continue;

      target = board.state[square];
      if (Pieces.sameColor(piece, target)) continue;

      Move move = new Move(index, square);
      if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, square));
    }

    return moves;
  }

  private MovesList getKingMoves(int index, boolean castlings, boolean checkLegal) {
    int piece = board.state[index];
    MovesList moves = new MovesList();

    int square;
    int target;
    for (int i = 0; i < MovesData.offsetsByDirection.length; i++) {
      square = index + MovesData.offsetsByDirection[i];
      if (square > 63 || square < 0) continue;

      target = board.state[square];
      if (Pieces.sameColor(piece, target)) continue;

      Move move = new Move(index, square);
      if (!checkLegal || (checkLegal && isLegal(move))) moves.add(new Move(index, square));
    }

    if (castlings) {

      boolean longCastlingAvailable = (board.castlingState & board.castlings[playerIndex][0]) != 0;
      boolean shortCastlingAvailable = (board.castlingState & board.castlings[playerIndex][0]) != 0;

      MovesList[] allOpponentsMoves = null;
      if (longCastlingAvailable || shortCastlingAvailable) allOpponentsMoves = getMovesByColor(Pieces.getColor(piece) ^ 24, false, false);
      if ( longCastlingAvailable ) {
        //Long castling available for player
        int[] t = {index-2, index-1};
        if (board.isFree(t)) {
          int[] t1 = {t[0], t[1], index};
          boolean contains = false;
          for (MovesList list : allOpponentsMoves) {
            if (list.targetsContains(t1)) contains = true;
          }
          if (!contains) {
            //In between squares are not en pris
            moves.add(new Move(index, index - 2));
          }
        }
      }
      if ( shortCastlingAvailable ) {
        //Short castling available for player
        int[] t = {index+2, index+1};
        if (board.isFree(t)) {
          int[] t1 = {t[0], t[1], index};
          boolean contains = false;
          for (MovesList list : allOpponentsMoves) {
            if (list.targetsContains(t1)) contains = true;
          }
          if (!contains) {
            //In between squares are not en pris
            moves.add(new Move(index, index + 2));
          }
        }
      }
    }

    return moves;
  }

  private boolean isLegal(Move move) {
    int playingPlayer = Pieces.getColor(board.state[move.getFrom()]);

    board.simulateMove(move);

    int kingIndex = -1;
    for (int i = 0; i < 64; i++) {
      if (board.state[i] == ( playingPlayer | Pieces.KING) ) kingIndex = i;
    }

    MovesList[] nextMoves = getMovesByColor(playingPlayer ^ 24, false, false);
    boolean contains = false;
    for (MovesList list : nextMoves) {
      if (list.targetsContains(kingIndex)) contains = true;
    }

    board.undoSimulation();
    playerIndex = 1 - playerIndex;

    return !contains;
  }
}
