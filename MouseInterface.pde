class MouseInterface {

  Board board;

  MouseInterface(Board board) {
    this.board = board;
  }

  void onMousePressed() {
    int index = getIndexFromMouse();
    if(!Pieces.isColor(board.state[index], board.playingPlayer)) return;
    board.dragging = index;
    board.movesManager.currentPieceMoves = board.movesManager.getMovesByIndex(index, true);
  }

  void onMouseDragged() {
    if (board.dragging != -1) {
      board.translateVector.add(new PVector(mouseX - pmouseX, mouseY - pmouseY));
    }
  }

  void onMouseReleased() {
    if (board.dragging != -1) {
      board.move(board.dragging, getIndexFromMouse());
      board.dragging = -1;
      board.translateVector.mult(0);
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
