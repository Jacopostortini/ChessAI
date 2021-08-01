static String startFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

Board board;
MouseInterface mouseInterface;
AI player1, player2;

void setup() {
  size(800, 800);
  MovesData.calculateData();
  board = new Board(startFen);
  //mouseInterface = new MouseInterface(board);
  player1 = new AI(board, Pieces.WHITE);
  player2 = new AI(board, Pieces.BLACK);
}

String matchState;

void draw() {
  background(200);
  translate(width/2-4*board.squareDim, height/2-4*board.squareDim);
  board.displayBoard();
  board.displayPieces();
  if (frameCount%1==0) {
    if (player1.myTurn()) player1.play();
    else if (player2.myTurn()) player2.play();
  }
  matchState = board.getMatchState();
  text(matchState, 0, 0);
  if (!matchState.equals("Playing")) {
    board = new Board(startFen);
    //mouseInterface = new MouseInterface(board);
    player1 = new AI(board, Pieces.WHITE);
    player2 = new AI(board, Pieces.BLACK);
    //player1.dead = true;
    //player2.dead = true;
  }
}

//void mousePressed() {
//  mouseInterface.onMousePressed();
//}

//void mouseDragged() {
//  mouseInterface.onMouseDragged();
//}

//void mouseReleased() {
//  mouseInterface.onMouseReleased();
//}
