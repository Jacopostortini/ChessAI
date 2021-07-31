class Board {

  final color whiteSquare = #ffebb3;
  final color blackSquare = #997d2f;
  final color fromSquare = color(255, 0, 0, 255);
  final color toSquare = color(255, 0, 0, 50);

  final int[][] castlings = {{1, 2}, {4, 8}};

  int squareDim;
  int[] state;
  int playingPlayer = Pieces.WHITE;
  int castlingState = 15;
  int enPassant = -1;

  MovesManager movesManager;

  int dragging = -1;
  PVector translateVector = new PVector(0, 0);

  final int enPassantChange = -1;
  final int castlingChange = -2;
  HashMap<Integer, Integer> simulation;


  private Board() {
    squareDim = min(width, height) / 8 - 20;
    state = new int[8*8];
  }

  Board(String fen) {
    this();
    FenCast.load(this, fen);
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
    //text(Integer.toBinaryString(castlingState), 0, 0 );
    //text(enPassant, 0, 0 );
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

  void move(int from, int to, boolean save) {

    int movingPiece = state[from];
    int targetPiece = state[to];

    if (!Pieces.isColor(movingPiece, playingPlayer)) return;

    if (save) {
      simulation = new HashMap();
    }

    int playerIndex = (playingPlayer>>>3)-1;

    if (save) {
      simulation.put(enPassantChange, enPassant);
      simulation.put(castlingChange, castlingState);
      simulation.put(from, movingPiece);
      simulation.put(to, targetPiece);
    }
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
      if (to - from != MovesData.offsetsByDirection[playerIndex] && Pieces.getType(targetPiece) == Pieces.NONE) {

        if (save) {
          simulation.put(to - MovesData.offsetsByDirection[playerIndex], state[to - MovesData.offsetsByDirection[playerIndex]]);
        }

        state[to - MovesData.offsetsByDirection[playerIndex]] = Pieces.NONE;
      }
    }

    //Check for king or rooks moves (castilngs)
    if (Pieces.getType(movingPiece) == Pieces.KING) {

      if (abs(from - to)==2) {
        castle(from, to, playerIndex, save);
      }


      castlingState &= ~castlings[playerIndex][0];
      castlingState &= ~castlings[playerIndex][1];
    } else if (Pieces.getType(movingPiece) == Pieces.ROOK) {
      int castlingsType = from / 7 - 8 * playerIndex;
      castlingState &= ~castlings[playerIndex][castlingsType];
    }

    if (!save) togglePlayer();
  }

  void move(Move move, boolean save) {
    move(move.getFrom(), move.getTo(), save);
  }

  void move(int from, int to) {
    move(from, to, false);
  }

  private void castle(int from, int to, int playerIndex, boolean save) {
    int direction = (to - from) / 2;
    int rookSquare = direction == 1 ? 7 : 0;
    rookSquare += playerIndex * 56;

    if (save) {
      simulation.put(to-direction, state[to-direction]);
      simulation.put(rookSquare, state[rookSquare]);
    }

    state[to-direction] = state[rookSquare];
    state[rookSquare] = Pieces.NONE;
  }

  private void togglePlayer() {
    playingPlayer ^= 24;
    
    movesManager.currentPlayersMoves = movesManager.getMovesByColor(playingPlayer, true, true);
  }

  boolean isFree(int[] targets) {
    for (int t : targets) {
      if (state[t] != Pieces.NONE) return false;
    }
    return true;
  }

  void simulateMove(Move move) {
    move(move, true);
  }

  void undoSimulation() {
    if (simulation == null) return;

    for (int i : simulation.keySet()) {
      if (i == enPassantChange) enPassant = simulation.get(i);
      else if (i == castlingChange) castlingState = simulation.get(i);
      else state[i] = simulation.get(i);
    }
    
    simulation = null;
  }
  
  void print(){
    println("\n\n------------");
    println("Playing player: "+playingPlayer);
    println("Castling state: "+Integer.toBinaryString(castlingState));
    println("En passant: "+enPassant);
    println("State:");
    for(int rank = 7; rank >= 0; rank--){
      String line = "";
      for(int file = 0; file < 8; file++){
        String piece = Integer.toBinaryString(state[rank*8+file]);
        while(piece.length() < 5){
          piece = "0"+piece;
        }
        line += piece + "  ";
      }
      println(line);
    }
    println("------------\n\n");
  }
}
