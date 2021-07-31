static class MovesData {
  //N S W E NW NE SW SE
  final static int[] offsetsByDirection = {8, -8, -1, 1, 7, 9, -9, -7};
  final static int[] knightMoves = {6, 10, 15, 17, -6, -10, -15, -17};
  private static boolean[][] knightDistancesFromEdges; 
  //final static int[][][] castlingsTargets = {{{2, 3}, {5, 6}}, {{58, 59}, {61, 62}}};
    private static int[][] distancesFromEdges;

  static void calculateData() {
    distancesFromEdges = new int[64][8];
    knightDistancesFromEdges = new boolean[64][8];
    for (int file = 0; file < 8; file++) {
      for (int rank = 0; rank < 8; rank++) {
        int index = 8 * rank + file;
        int N = 7 - rank;
        int S = rank;
        int W = file;
        int E = 7 - file;
        int[] distances = {N, S, W, E, min(N, W), min(N, E), min(S, W), min(S, E)};
        distancesFromEdges[index] = distances;

        boolean[] knightDistances = {
          N >= 1 && W >= 2, 
          N >= 1 && E >= 2, 
          N >= 2 && W >= 1, 
          N >= 2 && E >= 1, 
          S >= 1 && E >= 2, 
          S >= 1 && W >= 2, 
          S >= 2 && E >= 1, 
          S >= 2 && W >= 1, 
        };

        knightDistancesFromEdges[index] = knightDistances;
      }
    }
  }

  static int[][] getDistancesFromEdges() {
    return distancesFromEdges;
  }

  static boolean[][] getKnightDistancesFromEdges() {
    return knightDistancesFromEdges;
  }
}
