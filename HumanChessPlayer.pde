import java.util.Arrays;

public class HumanChessPlayer extends ChessPlayer {
  
  private int[] selectedSquare;
  private int[] proposedMove;
  
  public HumanChessPlayer(String name) {
    super(name);
    isUserInput = true;
    selectedSquare = new int[] {-1,-1};
    proposedMove = new int[] {-1,-1,-1,-1};
  }
  
  public int[] proposeMove(ChessBoard board) {
    for (int i = 0; i < board.validMoves.size(); i++) {
      if (Arrays.equals(proposedMove, board.validMoves.get(i))) {
        proposedMove[0] = -1;
        proposedMove[1] = -1;
        proposedMove[2] = -1;
        proposedMove[3] = -1;
        return board.validMoves.get(i);
      } 
    }
    return new int[] {-1,-1,-1,-1};
  }
  
  public void input(int[] square) {
    if (selectedSquare[0] == -1 && selectedSquare[1] == -1) {
      selectedSquare[0] = square[0];
      selectedSquare[1] = square[1];
      proposedMove[0] = -1;
      proposedMove[1] = -1;
      proposedMove[2] = -1;
      proposedMove[3] = -1;
    } else if (square[0] != -1 && square[1] != -1) {
      proposedMove[0] = selectedSquare[0];
      proposedMove[1] = selectedSquare[1];
      proposedMove[2] = square[0];
      proposedMove[3] = square[1];
      selectedSquare[0] = -1;
      selectedSquare[1] = -1;
    }
  }
  
  public void drawDecisionMaking(float x, float y, float s, ChessBoard c) {
    fill(255);
    rect(x, y, s, s, 7);
    fill(0);
    textSize(s*0.1);
    text("Selected:\n" + selectedSquare[0] + ", " + selectedSquare[1] + 
         "\nPossible Move:\n" + proposedMove[0] + ", " + proposedMove[1] + "->" + proposedMove[2] + ", " + proposedMove[3], x + s*0.05, y + s*0.1);
  }
  
}
