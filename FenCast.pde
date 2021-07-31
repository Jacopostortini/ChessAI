static class FenCast {

  static void load(Board board, String fen) {

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
              board.state[8 * rank + file] = Pieces.WHITE | lookupTable.get(c.toLowerCase());
            } else {
              board.state[8 * rank + file] = Pieces.BLACK | lookupTable.get(c);
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
    board.playingPlayer = parts[1].toLowerCase().equals("w") ? Pieces.WHITE : Pieces.BLACK;

    //Set castlings
    board.castlingState = 0;
    if (parts[2].contains("Q")) {
      board.castlingState |= board.castlings[0][0];
    }
    if (parts[2].contains("K")) {
      board.castlingState |= board.castlings[0][1];
    }
    if (parts[2].contains("q")) {
      board.castlingState |= board.castlings[1][0];
    }
    if (parts[2].contains("k")) {
      board.castlingState |= board.castlings[1][1];
    }

    //Set pris en passant
    if (!parts[3].equals("-")) {
      board.enPassant = fromCoorToIndex(parts[3]);
    }
  }

  static String export(Board board) {
    HashMap<Integer, String> lookupTable = new HashMap();
    lookupTable.put(Pieces.KING, "k");
    lookupTable.put(Pieces.PAWN, "p");
    lookupTable.put(Pieces.KNIGHT, "n");
    lookupTable.put(Pieces.BISHOP, "b");
    lookupTable.put(Pieces.ROOK, "r");
    lookupTable.put(Pieces.QUEEN, "q");

    String fen = "";

    int index, blanks, piece;

    for (int rank = 7; rank >= 0; rank--) {
      blanks = 0;
      for (int file = 0; file < 8; file++) {
        index = 8 * rank + file;
        piece = board.state[index];
        if (piece == Pieces.NONE) blanks++;
        else {
          if (blanks > 0) {
            fen += blanks;
            blanks = 0;
          }

          fen += Pieces.isColor(piece, Pieces.WHITE) ? lookupTable.get(Pieces.getType(piece)).toUpperCase() : lookupTable.get(Pieces.getType(piece));
        }
      }
      if(blanks != 0) fen += blanks;
      if(rank > 0) fen += "/";
    }

    //Playing player
    fen += " ";
    fen += board.playingPlayer == Pieces.WHITE ? "w" : "b";

    //Castlings
    fen += " ";
    if( (board.castlingState & board.castlings[0][1]) != 0 ) fen += "K";
    if( (board.castlingState & board.castlings[0][0]) != 0 ) fen += "Q";
    if( (board.castlingState & board.castlings[1][1]) != 0 ) fen += "k";
    if( (board.castlingState & board.castlings[1][0]) != 0 ) fen += "q";
    
    //En passant
    fen += " ";
    if(board.enPassant == -1) fen += "-";
    else fen += fromIndexToCoor(board.enPassant);
    
    return fen;
  }


  static int fromCoorToIndex(String coord) {
    String[] coor = coord.split("");
    String stringFile = coor[0];
    String stringRank = coor[1];

    int intRank = Integer.parseInt(stringRank) - 1;
    int intFile = ( (int) stringFile.toLowerCase().charAt(0) ) - 97;
    
    return 8 * intRank + intFile;
  }
  
  static String fromIndexToCoor(int index){
    int rank = index / 8;
    int file = index % 8;
    
    char charFile = (char) (file + 97);
    return ""+charFile+(rank+1);
  }
  
  
} 
