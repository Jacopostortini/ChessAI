class MouseInterface {

  Board board;

  MouseInterface(Board board) {
    this.board = board;
  }

  void onMousePressed() {
    int index = getIndexFromMouse();
    if (!Pieces.isColor(board.state[index], board.playingPlayer)) return;
    board.dragging = index;
  }

  void onMouseDragged() {
    if (board.dragging != -1) {
      board.translateVector.add(new PVector(mouseX - pmouseX, mouseY - pmouseY));
    }
  }

  void onMouseReleased() {
    if (board.dragging != -1) {
      int from = board.dragging;
      int to = getIndexFromMouse();
      board.dragging = -1;
      board.translateVector.mult(0);
      if (!board.movesManager.currentPlayersMoves[from].targetsContains(to)) return;
      board.move(from, to);
      board.updateAvailableMoves();
    }
  }

  void onKeyPressed() {
    if (key=='b') {
      if (board.history.size()>1) {
        board.undo(1);
        board.updateAvailableMoves();
      }
    } else if(key == 'r'){
      board.restart();
    }
  }

  private int getIndexFromMouse() {
    int x = mouseX-width/2+4*board.squareDim;
    int y = mouseY-height/2+4*board.squareDim;
    int rank = 8 - y / board.squareDim - 1;
    int file = x / board.squareDim;
    int index = rank * 8 + file;
    if (0 <= index && index <= 63) return index;
    else return -1;
  }
}
