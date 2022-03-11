public class ChessTaker extends ChessPlayer {
  
  public ChessTaker(String name) {
    super(name);
    isUserInput = false;
  }
  
  public int[] proposeMove(ChessBoard board) {
    ArrayList<int[]> moves = board.validMoves;
    if (moves.size() == 0) { return new int[] {-1,-1,-1,-1}; }
    char[][] b = board.getBoard();
    ArrayList<int[]> takers = new ArrayList<int[]>();
    for (int[] move : moves) {
      if (b[move[2]][move[3]] != ' ') { takers.add(move); }
    }
    if (takers.size() > 0) { return takers.get( (int) random(0, takers.size()) ); }
    return moves.get( (int) random(0, moves.size()) );
  }
  
  public void drawDecisionMaking(float x, float y, float s, ChessBoard c) {
    fill(255);
    rect(x, y, s, s, 7);
    fill(0);
    textSize(s*0.3);
    text("TAKE!", x + s*0.05, y + s*0.3);
  }
  
  public void input(int[] square) {}
  
}
