import java.util.ArrayList;

public class ChessGame {

  private ChessBoard board;         // the board
  private ChessPlayer player1;      // player as white
  private ChessPlayer player2;      // player as black
  private ArrayList<int[]> moves;  // all moves made during the game in order
  private float gameWidth;         // width available to display game
  private float gameHeight;        // height available to display game

  
  // creates a new game
  public ChessGame(ChessPlayer p1, ChessPlayer p2, float w, float h) {
    board = new ChessBoard(); //<>//
    player1 = p1;
    player2 = p2;
    moves = new ArrayList<int[]>();
    gameWidth = w;
    gameHeight = h;
  }
  
  // returns true if the game area is wider than tall
  private boolean isWide() {
    return gameWidth > gameHeight;
  }
  
  // private float[] getBoardPlacement() {} // return x, y, s
  
  // draws the current state of the game
  public void drawGame() {
    background(137, 87, 187);
    float x = 0;
    float y = 0;
    float s = 0;
    if (isWide()) {
      y = gameHeight * 0.1;
      s = gameHeight - 2*y;            
      x = gameWidth / 2.0 - s / 2.0;   
    } else {
      x = gameWidth * 0.1;
      s = gameWidth - 2*x;
      y = gameHeight / 2.0 - s / 2.0;
    }
    board.drawBoard(x, y, s);
    
    fill(0);
    textSize(s/16.0);
    text(player2.name(), x, y);
    text(player1.name(), x, (y+1.06075*s));
    
    textSize(s*0.05);
    ArrayList<int[]> moves = board.getValidMoves();
    text("VALID MOVES (" + moves.size() + "):", (s/32.0),(s/16.0));
    textSize(s*0.035);
    for (int i = 0; i < moves.size(); i++) {
      text(moves.get(i)[0] + ", " + moves.get(i)[1] + "-> " + moves.get(i)[2] + ", " + moves.get(i)[3],  s*0.05,  s*0.075 + (i+1)*s*0.035);
    }
    
    board.drawInfo(x + 1.05*s, y, s*0.25);
    player1.drawDecisionMaking(x - 0.25*s, y + 0.75*s, s*0.2, board);
    player2.drawDecisionMaking(x - 0.25*s, y, s*0.2, board);
  }
  
  // makes the next move for whichever player has to go
  public void makeNextMove() {
    int[] move;
    if (board.currentTurn()) {
      move = player2.proposeMove(new ChessBoard(board)); // change this so board is a board state
    } else {
      move = player1.proposeMove(new ChessBoard(board));
    }
    board.movePiece(move);
    drawGame();
    /*
    if (board.currentTurn()) {
      if (!player2.takesUserInput() && board.getValidMoves().size() > 0) { makeNextMove(); }
    } else {
      if (!player1.takesUserInput() && board.getValidMoves().size() > 0) { makeNextMove(); }
    }
    */
  }
  
  // notifies the game that it has been clicked, so it can potentially update the board state or other state
  // returns the square clicked
  public void clicked(float mousex, float mousey) {
    int[] posClicked = board.clicked(mousex, mousey);
    if (board.currentTurn() && player2.takesUserInput()) {
      player2.input(posClicked);
    } else if (!board.currentTurn() && player1.takesUserInput()) {
      player1.input(posClicked);
    }
    makeNextMove();
  }
  
  public boolean gameOver() {
    return board.gameOver();
  }
  
}
