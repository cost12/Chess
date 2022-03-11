public class ChessAI extends ChessPlayer {
  
  private final float REAL_BAD = -9999999;
  private final float REAL_GOOD = 99999999;
  
  private int k;
  //private int k2;
  private int depth;
  
  private String chatText;
  
  private final float[][] SQUARE_SCORES = new float[][] {  { 0.87, 0.88, 0.90, 0.91, 0.91, 0.90, 0.88, 0.87},
                                                           { 0.87, 0.88, 0.91, 0.93, 0.93, 0.91, 0.88, 0.87},
                                                           { 0.88, 0.89, 0.92, 0.95, 0.95, 0.92, 0.89, 0.88},
                                                           { 0.88, 0.89, 0.92, 0.95, 0.95, 0.92, 0.89, 0.88},
                                                           { 0.88, 0.89, 0.92, 0.95, 0.95, 0.92, 0.89, 0.88},
                                                           { 0.87, 0.88, 0.90, 0.92, 0.92, 0.90, 0.88, 0.87},
                                                           { 0.86, 0.87, 0.88, 0.90, 0.90, 0.88, 0.87, 0.86},
                                                           { 0.85, 0.86, 0.87, 0.89, 0.89, 0.87, 0.86, 0.85} };
  
  public ChessAI(String name) {
    super(name);
    isUserInput = false;
    depth = 1;
    k = 10;
    chatText = "Think!";
  }
  
  public ChessAI(String name, int d, int k) {
    super(name);
    isUserInput = false;
    depth = d;
    this.k = k;
    chatText = "Think!";
  }
  
  public int[] proposeMove(ChessBoard board) {
    ArrayList<int[]> moves = board.validMoves;
    if (moves.size() == 0) { return new int[] {-1,-1,-1,-1}; }

    float[] scores = new float[moves.size()];
    float maxScore = REAL_BAD;
    boolean myPieceColor = board.currentTurn();
    
    ArrayList<ChessBoard> bestBoards = new ArrayList<ChessBoard>();; // = kBestBoards(board, myPieceColor, true);
    ArrayList<int[]> bestMoves = new ArrayList<int[]>();
    kBestMoves(board, myPieceColor, true, bestBoards, bestMoves);
    
    for (int i = 0; i < bestBoards.size(); i++) {
      scores[i] = lookAheadBoardScore(bestBoards.get(i), myPieceColor, 1);
      if (scores[i] > maxScore) { maxScore = scores[i]; }
    }
    
    ArrayList<int[]> topMoves = new ArrayList<int[]>();
    for (int i = 0; i < bestMoves.size(); i++) {
      if (maxScore - 0.25 <= scores[i]) { topMoves.add(bestMoves.get(i)); }
    }
    chatText = "Think!";
    return topMoves.get( (int) random(0, topMoves.size()) );
  }
  
  private ArrayList<ChessBoard> kBestBoards(ChessBoard initial, boolean myPieceColor, boolean highIsGood) {
    ArrayList<int[]> moves = initial.getValidMoves();
    ArrayList<ChessBoard> bestBoards = new ArrayList<ChessBoard>();
    float[] topScores = new float[k];
    
    for (int i = 0; i < moves.size(); i++) {
      ChessBoard testBoard = initial.getBoardStateIf(moves.get(i));
      float score = scoreBoard(testBoard, myPieceColor);
      if (bestBoards.size() < k) {
        bestBoards.add(testBoard);
        topScores[i] = score;
      } else {
        int mindex = -1;
        float worst = REAL_GOOD;
        if (highIsGood) { worst = REAL_BAD; }
        for (int j = 0; j < k; j++) {
          if (topScores[j] < worst && highIsGood || topScores[j] > worst && !highIsGood) {
            worst = topScores[j];
            mindex = j;
          }
        }
        if (score < worst && highIsGood || score > worst && !highIsGood) {
          bestBoards.set(mindex, testBoard);
          topScores[mindex] = score;
        }
      }
    }
    return bestBoards;
  }
  
  private void kBestMoves(ChessBoard initial, boolean myPieceColor, boolean highIsGood, ArrayList<ChessBoard> bB, ArrayList<int[]> bM) {
    ArrayList<int[]> moves = initial.getValidMoves();
    //ArrayList<ChessBoard> bestBoards = new ArrayList<ChessBoard>();
    //ArrayList<int[]> topMoves = new ArrayList<int[]>();
    float[] topScores = new float[k];
    
    for (int i = 0; i < moves.size(); i++) {
      ChessBoard testBoard = initial.getBoardStateIf(moves.get(i));
      float score = scoreBoard(testBoard, myPieceColor);
      if (bB.size() < k) {
        //bestBoards.add(testBoard);
        bB.add(testBoard);
        //topMoves.add(moves.get(i));
        bM.add(moves.get(i));
        topScores[i] = score;
      } else {
        int mindex = -1;
        float worst = REAL_GOOD;
        if (highIsGood) { worst = REAL_BAD; }
        for (int j = 0; j < k; j++) {
          if (topScores[j] < worst && highIsGood || topScores[j] > worst && !highIsGood) {
            worst = topScores[j];
            mindex = j;
          }
        }
        if (score < worst && highIsGood || score > worst && !highIsGood) {
          //bestBoards.set(mindex, testBoard);
          bB.set(mindex, testBoard);
          //topMoves.set(mindex, moves.get(i));
          bM.set(mindex, moves.get(i));
          topScores[mindex] = score;
        }
      }
    }
    //return topMoves;
  }
  
  private float lookAheadBoardScore(ChessBoard boardState, boolean myPieceColor, int myDepth) {
    if (myDepth >= depth) {
       return scoreBoard(boardState, myPieceColor);
    } else {
      if (myPieceColor == boardState.currentTurn()) {
        float maxScore = REAL_BAD;
        ArrayList<ChessBoard> bestBoards = kBestBoards(boardState, myPieceColor, true);
        for (int i = 0; i < bestBoards.size(); i++) {
          float score = lookAheadBoardScore(bestBoards.get(i), myPieceColor, myDepth + 1);
          if (score > maxScore) { maxScore = score; }
        }
        return maxScore;
      } else {
        float minScore = REAL_GOOD;
        ArrayList<ChessBoard> bestBoards = kBestBoards(boardState, myPieceColor, false);
        for (int i = 0; i < bestBoards.size(); i++) {
          float score = lookAheadBoardScore(bestBoards.get(i), myPieceColor, myDepth + 1);
          if (score < minScore) { minScore = score; }
        }
        return minScore;
      }
    }
  }
  
  public void drawDecisionMaking(float x, float y, float s, ChessBoard c) {
    fill(255);
    rect(x, y, s, s, 7);
    fill(0);
    textSize(s*0.3);
    text(chatText, x + s*0.05, y + s*0.3);
    textSize(s*0.15);
    text(scoreBoard(c, c.currentTurn()), x+s*0.07, y + s*0.75);
  }
  
  private float squareControlBonus(int myControl, int theirControl) {
    if (myControl > 0) {
      if (theirControl > 0) {
        return 1 + 0.01*(myControl - theirControl);
      } else {
        return 1.02 + 0.01*(myControl-1);
      }
    } else {
      if (theirControl > 0) {
        return 0.6 - 0.01*(theirControl-1);
      } else {
        return 0.96;
      }
    }
  }
  
  private float scoreBoard(ChessBoard boardState, boolean myPieceColor) {
    // need some way to access moves for both players, not just whose turn it is
    char[][] board = boardState.getBoard();
    ArrayList<int[]> validMovesMe = boardState.getValidMoves();
    ArrayList<int[]> validMovesThem = boardState.calculateValidMovesFor(!myPieceColor);
    ArrayList<int[]> validMoves = new ArrayList<int[]>(validMovesMe);
    validMoves.addAll(validMovesThem);
    float mine = 0;
    float theirs = 0;
    
    int[][] boardControlW = new int[8][8];
    int totalW = 0;
    int[][] boardControlB = new int[8][8];
    int totalB = 0;
    
    for (int[] move : validMoves) {
      int r = move[0];
      int c = move[1];
      int r2 = move[2];
      int c2 = move[3];
      if ("rnbqkp".indexOf(board[r][c]) > -1) {
        boardControlB[r2][c2] += 1;
        if (boardControlB[r2][c2] == 1) { totalB++; }
      } else if ("RNBQKP".indexOf(board[r][c]) > -1) {
        boardControlW[r2][c2] += 1;
        if (boardControlW[r2][c2] == 1) { totalW++; }
      }
    }
    
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] == 'p') {
          if (myPieceColor) { mine += 1+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); } else { theirs += 1+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); }
        } else if (board[r][c] == 'b' || board[r][c] == 'n') {
          if (myPieceColor) { mine += 3+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); } else { theirs += 3+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); }
        } else if (board[r][c] == 'r') {
          if (myPieceColor) { mine += 5+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); } else { theirs += 5+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); }
        } else if (board[r][c] == 'q') {
          if (myPieceColor) { mine += 9+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); } else { theirs += 9+SQUARE_SCORES[7-r][c]*squareControlBonus(boardControlB[7-r][c], boardControlW[7-r][c]); }
        
      } else if (board[r][c] == 'P') {
          if (!myPieceColor) { mine += 1+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); } else { theirs += 1+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); }
        } else if (board[r][c] == 'B' || board[r][c] == 'N') {
          if (!myPieceColor) { mine += 3+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); } else { theirs += 3+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); }
        } else if (board[r][c] == 'R') {
          if (!myPieceColor) { mine += 5+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); } else { theirs += 5+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); }
        } else if (board[r][c] == 'Q') {
          if (!myPieceColor) { mine += 9+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); } else { theirs += 9+SQUARE_SCORES[r][c]*squareControlBonus(boardControlW[r][c], boardControlB[r][c]); }
        } 
      }
    }
    if (myPieceColor) {
      mine +=   0.2*totalB;
      theirs += 0.2*totalW;
    } else {
      mine +=   0.2*totalW;
      theirs += 0.2*totalB;
    }
    
    if (boardState.isInCheck(board, myPieceColor)) { theirs += 0.5; if (validMovesMe.size() == 0) { theirs = REAL_GOOD; } }
    else if (boardState.isInCheck(board, !myPieceColor)) { mine += 0.5; if (validMovesThem.size() == 0) { mine = REAL_GOOD; } }
    
    return mine - theirs;
  }
  
  public void input(int[] square) {
    chatText = "I am...\nThinking...";
  }
  
}
