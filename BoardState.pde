class BoardState {

  int[] state;
  int playingPlayer;
  int castlingState;
  int enPassant;

  BoardState(Board board) {

    this.playingPlayer = board.playingPlayer;
    this.castlingState = board.castlingState;
    this.enPassant = board.enPassant;
    this.state = new int[64];
    for (int i = 0; i < 64; i++) {
      this.state[i] = board.state[i];
    }
    
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
}
