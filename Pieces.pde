public static class Pieces {
  
  final static int NONE = 0;
  final static int KING = 1;
  final static int PAWN = 2;
  final static int KNIGHT = 3;
  final static int BISHOP = 4;
  final static int ROOK = 5;
  final static int QUEEN = 6;
  
  final static int WHITE = 8;
  final static int BLACK = 16;
    
  static String getFileName(int piece){
    String fileName = Integer.toBinaryString(piece);
    while(fileName.length() != 5){
      fileName = "0"+fileName;
    }
    return fileName+".png";
  }
  
  //Return false if the piece is NONE 
  static boolean isColor(int piece, int col){
    if((piece & col) == 0) return false;
    return true;
  }
  
  static boolean sameColor(int p1, int p2){
    int c1 = getColor(p1);
    return isColor(p2, c1);
  }
  
  static int getColor(int piece){
    return piece & 24;
  }
  
  static boolean isSlidingPiece(int piece){
    int type = getType(piece);
    return type == BISHOP || type == ROOK || type == QUEEN;
  }
  
  static int getType(int piece){
    int p = piece & 7;
    return p;
  }
}
