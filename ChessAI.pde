static String startFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

Board board;
MouseInterface mouseInterface;

void setup() {
  size(800, 800);
  MovesData.calculateData();
  board = new Board(startFen);
  mouseInterface = new MouseInterface(board);
}

void draw() {
  background(200);
  translate(width/2-4*board.squareDim, height/2-4*board.squareDim);
  board.displayBoard();
  board.displayPieces();
}

void mousePressed() {
  mouseInterface.onMousePressed();
}

void mouseDragged() {
  mouseInterface.onMouseDragged();
}

void mouseReleased() {
  mouseInterface.onMouseReleased();
}
