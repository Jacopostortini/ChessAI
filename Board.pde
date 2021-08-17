class Board {

  final color whiteSquare = #ffebb3;
  final color blackSquare = #997d2f;
  final color fromSquare = color(255, 0, 0, 255);
  final color toSquare = color(255, 0, 0, 50);

  //Long white - short white - long black - short black
  final int[][] castlings = {{1, 2}, {4, 8}};

  int squareDim;
  int[] state;
  int playingPlayer = Pieces.WHITE;
  int castlingState = 15;
  int enPassant = -1;

  ArrayList<BoardState> history;

  MovesManager movesManager;

  int dragging = -1;
  PVector translateVector = new PVector(0, 0);


  private Board() {
    squareDim = min(width, height) / 8 - 20;
    state = new int[8*8];
    history = new ArrayList();
  }

  Board(String fen) {
    this();
    FenCast.load(this, fen);
    saveState();
    movesManager = new MovesManager(this);
  }

  void displayBoard() {
    for (int file = 0; file < 8; file++) {
      for (int rank = 0; rank < 8; rank++) {
        int isWhite = (file + rank) & 1;
        int col = isWhite * whiteSquare + (1-isWhite) * blackSquare;

        fill(col);
        square(file*squareDim, (7 - rank)*squareDim, squareDim);

        if (dragging != -1) {
          int index = 8 * rank + file;
          if (dragging == index) {
            fill(fromSquare);
            square(file*squareDim, (7 - rank)*squareDim, squareDim);
          } else if (movesManager.currentPlayersMoves[dragging].targetsContains(index)) {
            fill(toSquare);
            square(file*squareDim, (7 - rank)*squareDim, squareDim);
          }
        }
      }
    }
  }

  void displayPieces() {
    for (int i = 0; i < state.length; i++) {
      if (state[i] != 0) {
        PImage image = loadImage(Pieces.getFileName(state[i]));
        image.resize(squareDim, squareDim);
        pushMatrix();
        if (dragging == i) {
          image.resize((int)(squareDim * 1.2), (int)(squareDim * 1.2));
          translate(translateVector.x, translateVector.y);
        }
        image(image, i % 8 * squareDim, (state.length - i - 1) / 8 * squareDim);
        popMatrix();
      }
    }
  }

  void move(int from, int to) {

    int movingPiece = state[from];
    int targetPiece = state[to];

    if (!Pieces.isColor(movingPiece, playingPlayer)) return;

    int playerIndex = (playingPlayer>>>3)-1;

    enPassant = -1;
    state[from] = Pieces.NONE;
    state[to] = movingPiece;

    //Check for promotions
    if (Pieces.getType(movingPiece) == Pieces.PAWN) {
      if (abs(to / 8 - 7*playerIndex) == 7) {
        state[to] = playingPlayer | Pieces.QUEEN;
      }

      //Update en passant
      if (abs(from - to) == 16) {
        enPassant = to - MovesData.offsetsByDirection[playerIndex];
      }

      //Check en passant move
      if ((to - from) % 8 != 0 && Pieces.getType(targetPiece) == Pieces.NONE) {

        state[to - MovesData.offsetsByDirection[playerIndex]] = Pieces.NONE;
      }
    }

    //Check for king or rooks moves (castilngs)
    if (Pieces.getType(movingPiece) == Pieces.KING) {

      if (abs(from - to)==2) {
        castle(from, to, playerIndex);
      }


      castlingState &= ~castlings[playerIndex][0];
      castlingState &= ~castlings[playerIndex][1];
    } else if (Pieces.getType(movingPiece) == Pieces.ROOK) {
      if (from == playerIndex * 56 || from == playerIndex * 56 + 7) {
        int castlingsType = from / 7 - 8 * playerIndex;
        castlingState &= ~castlings[playerIndex][castlingsType];
      }
    }

    togglePlayer();

    saveState();
  }

  void move(Move move) {
    move(move.getFrom(), move.getTo());
  }

  private void castle(int from, int to, int playerIndex) {
    int direction = (to - from) / 2;
    int rookSquare = direction == 1 ? 7 : 0;
    rookSquare += playerIndex * 56;

    state[to-direction] = state[rookSquare];
    state[rookSquare] = Pieces.NONE;
  }

  private void togglePlayer() {
    playingPlayer ^= 24;
  }

  private void updateAvailableMoves() {
    movesManager.currentPlayersMoves = movesManager.getMovesByColor(playingPlayer, true, true);
  }

  boolean isFree(int[] targets) {
    for (int t : targets) {
      if (state[t] != Pieces.NONE) return false;
    }
    return true;
  }

  boolean gameOver() {
    return !canMove() || !enoughPieces();
  }

  String getMatchState() {
    if (!canMove()) {
      if (isCheck()) return "Check mate, "+(playingPlayer == Pieces.WHITE ? "black" : "white")+" wins!";
      else return "Draw";
    } else {
      return enoughPieces() ? "Playing" : "Draw";
    }
  }

  boolean isCheck() {
    MovesList[] opponentsMoves = movesManager.getMovesByColor(playingPlayer ^ 24, false, false);
    int kingsIndex = -1;
    for (int i = 0; i < 64; i++) {
      if (state[i] == ( playingPlayer | Pieces.KING )) {
        kingsIndex = i;
      }
    }
    for (MovesList list : opponentsMoves) {
      if (list.targetsContains(kingsIndex)) return true;
    }
    return false;
  }

  boolean canMove() {
    boolean canMove = false;
    for (MovesList list : movesManager.currentPlayersMoves) {
      if (list.size() > 0) canMove = true;
    }
    return canMove;
  }

  boolean enoughPieces() {
    int countBishops = 0;
    int[] countKnights = {0, 0};
    for (int piece : state) {
      int type = Pieces.getType(piece);
      int col = Pieces.getColor(piece);
      if ( type != Pieces.KING && type != Pieces.BISHOP && type != Pieces.KNIGHT && type != Pieces.NONE) return true;
      if ( type == Pieces.BISHOP ) countBishops++;
      else if ( type == Pieces.KNIGHT ) countKnights[col == Pieces.WHITE ? 0 : 1]++;
    }
    return !(
      (countBishops == 0 && countKnights[0] <= 2) ||
      (countBishops == 1 && countKnights[0] == 0) ||
      (countBishops == 0 && countKnights[1] <= 2) ||
      (countBishops == 1 && countKnights[1] == 0) );
  }

  void print() {
    println("\n\n------------");
    println("Playing player: "+playingPlayer);
    println("Castling state: "+Integer.toBinaryString(castlingState));
    println("En passant: "+enPassant);
    println("State:");
    for (int rank = 7; rank >= 0; rank--) {
      String line = "";
      for (int file = 0; file < 8; file++) {
        String piece = Integer.toBinaryString(state[rank*8+file]);
        while (piece.length() < 5) {
          piece = "0"+piece;
        }
        line += piece + "  ";
      }
      println(line);
    }
    println("------------\n\n");
  }

  int evaluateState(int player) {
    int value = 0;
    for (int i = 0; i < 64; i++) {
      int sign = Pieces.isColor(state[i], player) ? 1 : -1;
      switch(Pieces.getType(state[i])) {
      case Pieces.PAWN:
        value += Pieces.PAWN_VALUE * sign;
        break;
      case Pieces.BISHOP:
        value += Pieces.BISHOP_VALUE * sign;
        break;
      case Pieces.KNIGHT:
        value += Pieces.KNIGHT_VALUE * sign;
        break;
      case Pieces.ROOK:
        value += Pieces.ROOK_VALUE * sign;
        break;
      case Pieces.QUEEN:
        value += Pieces.QUEEN_VALUE * sign;
        break;
      case Pieces.NONE:
        value -= 1;
        break;
      }
    }

    return value;
  }

  void saveState() {
    history.add(new BoardState(this));
  }


  void undo(int howMany) {
    restore(history.get(history.size()-howMany-1));
    int lowerBound = history.size()-howMany-1;
    for (int i = history.size()-1; i > lowerBound; i--) {
      history.remove(i);
    }
  }

  void restore(BoardState board) {
    for (int i = 0; i < 64; i++) this.state[i] = board.state[i];
    this.playingPlayer = board.playingPlayer;
    this.castlingState = board.castlingState;
    this.enPassant = board.enPassant;
  }

  void restart() {
    undo(history.size()-1);
  }
}
