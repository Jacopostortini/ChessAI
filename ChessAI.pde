String startFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

Board board;
MouseInterface mouseInterface;
AI player1, player2;
int bots = 2; 

void setup() {
  size(600, 600);
  MovesData.calculateData();
  board = new Board(startFen);
  reset(bots);
}

String matchState;

void draw() {
  background(200);
  translate(width/2-4*board.squareDim, height/2-4*board.squareDim);
  board.displayBoard();
  board.displayPieces();
  if (frameCount%1==0) {
    if (player1 != null && player1.myTurn()) player1.play();
    else if (player2 != null && player2.myTurn()) player2.play();
  }

  if (board.gameOver()) {
    matchState = board.getMatchState();
    textSize(30);
    text(matchState, 0, -20);
    if (player1 != null) player1.dead = true;
    if (player2 != null) player2.dead = true;
    reset(bots);
  }
}

void reset(int bots) {
  board.restart();
  switch(bots) {
  case 0:
    mouseInterface = new MouseInterface(board);
    break;
  case 1:
    player1 = new AI(board, Pieces.BLACK);
    mouseInterface = new MouseInterface(board);
    break;
  case 2:
    player1 = new AI(board, Pieces.WHITE);
    player2 = new AI(board, Pieces.BLACK);
    break;
  }
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
