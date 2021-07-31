class Move {
  private int from;
  private int to;

  Move(int from, int to) {
    this.from = from;
    this.to = to;
  }
  
  int getFrom() {
    return from;
  }

  int getTo() {
    return to;
  }
  
  boolean equals(Move other){
    return from == other.from && to == other.to;
  }
}
