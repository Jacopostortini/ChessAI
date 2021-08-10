class MovesList extends ArrayList<Move> {

  MovesList() {
    super();
  }

  boolean contains(Move move) {
    for (Move m : this) {
      if (m.equals(move)) return true;
    }
    return false;
  }

  boolean targetsContains(int index) {
    for (Move m : this) {
      if (m.getTo() == index) return true;
    }
    return false;
  }
  
  boolean targetsContains(int[] indexes){
    for (Move m : this) {
      for(int i: indexes){
        if(m.getTo()==i) {
          //println(m.getFrom()+"   "+m.getTo());
          return true;
        }
      }
    }
    return false;
  }
  
  Move pickRandom(){
    if(this.size() == 0) return null;
    else return this.get((int)random(this.size()));
    
  }
}
