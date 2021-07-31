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


  Board() {
    squareDim = min(width, height) / 8 - 20;
    state = new int[8*8];
    for (int i = 0; i < state.length; i++) {
      state[i] = 0;
    }
    movesManager = new MovesManager(this);
  }

  Board(String fen) {
    this();
    setStateFromFen(fen);
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
          } else if (movesManager.currentPieceMoves.targetsContains(index)) {
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

  void move(int from, int to) {
    if (!movesManager.currentPieceMoves.targetsContains(to)) return; 

    int movingPiece = state[from];
    int targetPiece = state[to];

    if (!Pieces.isColor(movingPiece, playingPlayer)) return;
    enPassant = -1;

    int playerIndex = (playingPlayer>>>3)-1;
    state[from] = 0;
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
      if (to - from != MovesData.offsetsByDirection[playerIndex] && Pieces.getType(targetPiece) == Pieces.NONE){
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
      int castlingsType = from / 7 - 8 * playerIndex;
      castlingState &= ~castlings[playerIndex][castlingsType];
    }

    togglePlayer();
  }

  private void castle(int from, int to, int playerIndex) {
    int direction = (to - from) / 2;
    int rookSquare = direction == 1 ? 7 : 0;
    rookSquare += playerIndex * 56;
    board.state[to-direction] = board.state[rookSquare];
    board.state[rookSquare] = Pieces.NONE;
  }

  private void togglePlayer() {
    playingPlayer ^= 24;
  }

  void setStateFromFen(String fen) {
    HashMap<String, Integer> lookupTable = new HashMap();
    lookupTable.put("k", Pieces.KING);
    lookupTable.put("p", Pieces.PAWN);
    lookupTable.put("n", Pieces.KNIGHT);
    lookupTable.put("b", Pieces.BISHOP);
    lookupTable.put("r", Pieces.ROOK);
    lookupTable.put("q", Pieces.QUEEN);

    //Place the pieces
    String[] parts = fen.split(" ");
    String boardState = parts[0];
    int rank = 7, file = 0;
    try {
      String[] ranks = boardState.split("/");
      for (String r : ranks) {
        String[] chars = r.split("");
        for (String c : chars) {
          if ("0123456789".contains(c)) {
            file += Integer.parseInt(c);
          } else {
            if (c.toUpperCase().equals(c)) {
              state[8 * rank + file] = Pieces.WHITE | lookupTable.get(c.toLowerCase());
            } else {
              state[8 * rank + file] = Pieces.BLACK | lookupTable.get(c);
            }
            file++;
          }
        }
        rank--;
        file = 0;
      }
    } 
    catch(Exception e) {
      println("Invalid fen expression");
      throw(e);
    }

    //Find who is playing
    playingPlayer = parts[1].toLowerCase().equals("w") ? Pieces.WHITE : Pieces.BLACK;

    //Set castlings
    castlingState = 0;
    if (parts[2].contains("Q")) {
      castlingState |= castlings[0][0];
    }
    if (parts[2].contains("K")) {
      castlingState |= castlings[0][1];
    }
    if (parts[2].contains("q")) {
      castlingState |= castlings[1][0];
    }
    if (parts[2].contains("k")) {
      castlingState |= castlings[1][1];
    }

    //Set pris en passant
    if (!parts[3].equals("-")) {
      String[] coor = parts[3].split("");
      String stringFile = coor[0];
      String stringRank = coor[1];

      int intRank = Integer.parseInt(stringRank) - 1;
      int intFile = ( (int) stringFile.toLowerCase().charAt(0) ) - 97;

      enPassant = 8 * intRank + intFile;
    }
  }

  boolean isFree(int[] targets) {
    for (int t : targets) {
      if (state[t] != Pieces.NONE) return false;
    }
    return true;
  }
}
