public class RandomChessAI extends ChessPlayer {
  
  public RandomChessAI(String name) {
    super(name);
    isUserInput = false;
  }
  
  public int[] proposeMove(ChessBoard board) {
    if (board.validMoves.size() == 0) { return new int[] {-1,-1,-1,-1}; }
    return board.validMoves.get( (int) random(0, board.validMoves.size()) );
  }
  
  public void drawDecisionMaking(float x, float y, float s, ChessBoard c) {
    fill(255);
    rect(x, y, s, s, 7);
    fill(0);
    textSize(s*0.1);
    text("RANDOM!", x + s*0.05, y + s*0.1);
  }
  
  public void input(int[] square) {}
  
}
