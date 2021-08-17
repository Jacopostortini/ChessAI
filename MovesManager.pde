class MovesManager {
  Board board;
  MovesList[] currentPlayersMoves;

  MovesManager(Board board) {
    this.board = board;
    currentPlayersMoves = getMovesByColor(board.playingPlayer, true, true);
  }

  MovesList[] getMovesByColor(int player, boolean castlings, boolean checkLegal) {

    int playerIndex = (player >>> 3) - 1;

    MovesList[] moves = new MovesList[64];
    for (int i = 0; i < 64; i++) {
      int piece = board.state[i];
      if (Pieces.isColor(piece, player)) {
        moves[i] = getMovesByIndex(i, castlings, playerIndex);
      } else {
        moves[i] = new MovesList();
      }
    }

    if (checkLegal) {
      for (MovesList list : moves) {
        MovesList toRemove = new MovesList();
        for (Move move : list) {
          if (!isLegal(move)) toRemove.add(move);
        }
        for(Move move: toRemove) list.remove(move);
      }
    }

    return moves;
  }

  MovesList getMovesByIndex(int index, boolean castlings, int playerIndex) {
    MovesList moves = new MovesList();
    int piece = board.state[index];

    if (Pieces.isSlidingPiece(piece)) moves.addAll(getSlidingMoves(index));
    else if (Pieces.getType(piece) == Pieces.PAWN) moves.addAll(getPawnMoves(index, playerIndex));
    else if (Pieces.getType(piece) == Pieces.KNIGHT) moves.addAll(getKnightMoves(index));
    else if (Pieces.getType(piece) == Pieces.KING) moves.addAll(getKingMoves(index, castlings, playerIndex));
    return moves;
  }

  private MovesList getSlidingMoves(int index) {
    int piece = board.state[index];
    MovesList moves = new MovesList();

    int startingDirectionIndex = (Pieces.getType(piece) == Pieces.BISHOP) ? 4 : 0;
    int endingDirectionIndex = (Pieces.getType(piece) == Pieces.ROOK) ? 4 : 8;
    for (int directionIndex = startingDirectionIndex; directionIndex < endingDirectionIndex; directionIndex++) {
      for (int n = 0; n < MovesData.distancesFromEdges[index][directionIndex]; n++) {
        int square = index + (n+1) * MovesData.offsetsByDirection[directionIndex];
        int target = board.state[square];

        if (Pieces.sameColor(piece, target)) break;

        moves.add(new Move(index, square));

        if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) break;
      }
    }

    return moves;
  }

  private MovesList getPawnMoves(int index, int playerIndex) {
    int piece = board.state[index];
    MovesList moves  = new MovesList();

    int square;
    int target;
    int diagonalsIndex = playerIndex * 2 + 4;


    //Check room at NW or SW

    if (MovesData.distancesFromEdges[index][diagonalsIndex] > 0) {

      //Check for diagonal movement NW or SW
      square = index + MovesData.offsetsByDirection[diagonalsIndex];
      target = board.state[square];
      if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) {
        moves.add(new Move(index, square));
      }
    }

    //Check room at NE or SE
    if (MovesData.distancesFromEdges[index][diagonalsIndex+1] > 0) {
      //Check for diagonal movement NE or SE
      square = index + MovesData.offsetsByDirection[diagonalsIndex+1];
      target = board.state[square];
      if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) {
        moves.add(new Move(index, square));
      }
    }


    //Not at the end
    if (MovesData.distancesFromEdges[index][playerIndex] > 0) {
      //Check forwarding
      square = index + MovesData.offsetsByDirection[playerIndex];
      target = board.state[square];
      if (Pieces.getType(target) == Pieces.NONE) {
        moves.add(new Move(index, square));
      }

      //If white and on rank 1 or black and on rank 6
      if (abs(index / 8 - 7*playerIndex) == 1) {
        square += MovesData.offsetsByDirection[playerIndex];
        target = board.state[square];

        if (Pieces.getType(target) == Pieces.NONE) {
          moves.add(new Move(index, square));
        }
      }
    }

    if (board.enPassant != -1) {
      if (abs( index - (board.enPassant - MovesData.offsetsByDirection[playerIndex]) ) == 1) {
        moves.add(new Move(index, board.enPassant));
      }
    }

    return moves;
  }

  private MovesList getKnightMoves(int index) {
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

      moves.add(new Move(index, square));
    }

    return moves;
  }

  private MovesList getKingMoves(int index, boolean castlings, int playerIndex) {
    int piece = board.state[index];
    MovesList moves = new MovesList();

    int square;
    int target;
    for (int i = 0; i < MovesData.offsetsByDirection.length; i++) {
      if (MovesData.distancesFromEdges[index][i] == 0) continue;
      square = index + MovesData.offsetsByDirection[i];
      if (square > 63 || square < 0) continue;

      target = board.state[square];
      if (Pieces.sameColor(piece, target)) continue;

      moves.add(new Move(index, square));
    }

    if (castlings) {

      boolean longCastlingAvailable = (board.castlingState & board.castlings[playerIndex][0]) != 0;
      boolean shortCastlingAvailable = (board.castlingState & board.castlings[playerIndex][1]) != 0;

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

    board.move(move);
    
    int kingIndex = -1;
    for (int i = 0; i < 64; i++) {
      if (board.state[i] == ( playingPlayer | Pieces.KING) ) kingIndex = i;
    }
    
    MovesList[] nextMoves = getMovesByColor(playingPlayer ^ 24, false, false);
    boolean contains = false;
    for (MovesList list : nextMoves) {
      if (list.targetsContains(kingIndex)) contains = true;
    }

    board.undo(1);
    return !contains;
  }
}
