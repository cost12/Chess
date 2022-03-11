public abstract class ChessPlayer { // interface? almost certainly
  
  protected String name;  // player name
  protected int[] record; // player record
  protected boolean isUserInput;
  
  // creates a new chess player with name n
  public ChessPlayer(String n) {
    name = n;
    record = new int[3]; // defaults to 0s
    isUserInput = false;
  }
  
  // takes in a chess board and color and returns a move
  public abstract int[] proposeMove(ChessBoard board);
  
  public boolean takesUserInput() {
    return isUserInput;
  }
  
  public abstract void input(int[] square);
  
  public abstract void drawDecisionMaking(float x, float y, float s, ChessBoard c);
  
  public String name() {
    return name;
  }
  
}
