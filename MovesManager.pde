class MovesManager {
  Board board;
  MovesList currentPieceMoves;

  MovesManager(Board board) {
    this.board = board;
    currentPieceMoves = new MovesList();
  }

  MovesList getMovesByColor(int player, boolean castlings) {
    MovesList moves = new MovesList();

    for (int i = 0; i < 64; i++) {
      int piece = board.state[i];
      if (Pieces.isColor(piece, player)) {
        moves.addAll(getMovesByIndex(i, castlings));
      }
    }

    return moves;
  }

  MovesList getMovesByIndex(int index, boolean castlings) {
    MovesList moves = new MovesList();
    int piece = board.state[index];
    if (Pieces.isSlidingPiece(piece)) moves.addAll(getSlidingMoves(index));
    else if (Pieces.getType(piece) == Pieces.PAWN) moves.addAll(getPawnMoves(index));
    else if (Pieces.getType(piece) == Pieces.KNIGHT) moves.addAll(getKnightMoves(index));
    else if (Pieces.getType(piece) == Pieces.KING) moves.addAll(getKingMoves(index, castlings));
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

  private MovesList getPawnMoves(int index) {
    int piece = board.state[index];
    MovesList moves  = new MovesList();

    int directionIndex = (Pieces.getColor(piece) >> 3) - 1;
    //Not at the end
    if (MovesData.distancesFromEdges[index][directionIndex] > 0) {
      int square;
      int target;

      //Check for diagonal eatables
      int diagonalsIndex = directionIndex * 2 + 4;
      square = index + MovesData.offsetsByDirection[diagonalsIndex];
      target = board.state[square];
      if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) {
        moves.add(new Move(index, square));
      }

      square = index + MovesData.offsetsByDirection[diagonalsIndex+1];
      target = board.state[square];
      if (Pieces.getType(target) != Pieces.NONE && !Pieces.sameColor(piece, target)) {
        moves.add(new Move(index, square));
      }

      square = index + MovesData.offsetsByDirection[directionIndex];
      target = board.state[square];
      if (Pieces.getType(target) == Pieces.NONE) moves.add(new Move(index, square));
      else return moves;

      //If white and on rank 1 or black and on rank 6
      if (abs(index / 8 - 7*directionIndex) == 1) {
        square += MovesData.offsetsByDirection[directionIndex];
        target = board.state[square];

        if (Pieces.getType(target) == Pieces.NONE) moves.add(new Move(index, square));
      }
    }
    
    if(board.enPassant != -1){
      
      if(abs( index - (board.enPassant - MovesData.offsetsByDirection[directionIndex]) ) == 1){
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

  private MovesList getKingMoves(int index, boolean castlings) {
    int piece = board.state[index];
    MovesList moves = new MovesList();

    int square;
    int target;
    for (int i = 0; i < MovesData.offsetsByDirection.length; i++) {
      square = index + MovesData.offsetsByDirection[i];
      if (square > 63 || square < 0) continue;

      target = board.state[square];
      if (Pieces.sameColor(piece, target)) continue;

      moves.add(new Move(index, square));
    }

    if (castlings) {
      int playerIndex = (Pieces.getColor(piece) >>> 3) - 1;
      //int[][] possibleCastlings = MovesData.castlingsTargets[playerIndex];
      boolean longCastlingAvailable = (board.castlingState & board.castlings[playerIndex][0]) != 0;
      boolean shortCastlingAvailable = (board.castlingState & board.castlings[playerIndex][0]) != 0;

      MovesList allOpponentsMoves = null;
      if (longCastlingAvailable || shortCastlingAvailable) allOpponentsMoves = getMovesByColor(((playerIndex+1) ^ 11) << 3, false);
      if ( longCastlingAvailable ) {
        //Long castling available for player
        int[] t = {index-2, index-1};
        if (board.isFree(t)) {
          int[] t1 = {t[0], t[1], index};
          if (!allOpponentsMoves.targetsContains(t1)) {
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
          if (!allOpponentsMoves.targetsContains(t1)) {
            //In between squares are not en pris
            moves.add(new Move(index, index + 2));
          }
        }
      }
    }

    return moves;
  }
}
