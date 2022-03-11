import java.util.HashMap;
import java.util.ArrayList;

class ChessBoard {
  
  private char[][] board;                 // 8 by 8 2D array of chess board + pieces where KQPBNR represent white and kqpbnr represent black
  private boolean check;                  // true if check, else false
  private boolean isOver;                 // true if the game is over, false otherwise
  private ArrayList<int[]> validMoves;    // a move is given ri, ci, rf, cf where i is initial and f is final
  private boolean turn;                   // false for white's turn, true for black's turn
  
  private boolean whiteCastleLeftOpen;    // false if rook/king moves and castling can't happen to that side
  private boolean whiteCastleRightOpen;
  private boolean blackCastleLeftOpen;
  private boolean blackCastleRightOpen;
  
  private HashMap<char[][], Integer> boardStates;  // necessary? for checking threefold repetition (super annoying), should be a hash table of a 2D array
  
  private int[] enPassantPawnB;  // a pawn that can currently be captured en passant, r, c where r, c is the location that can be taken
  private int[] enPassantPawnW;  // B for black, W for white -1, -1 for dne
                                
  private float x;          // x position of board
  private float y;          // y position of board
  private float boardSize;  // the size of each side of the board
  
  private int[] bKingRC;    // black king location
  private int[] wKingRC;    // white king location
  
  private int[] recentMove;
  
  private static final String whitePieces = "RNBQKP"; // string with the names of white pieces
  private static final String blackPieces = "rnbqkp"; // string with the names of black pieces
    
  // copy constructor!
  public ChessBoard(ChessBoard b2) {
    this.board = new char[8][8];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        this.board[r][c] = b2.board[r][c];
      }
    }
    this.bKingRC = new int[2];
    this.wKingRC = new int[2];
    for (int i = 0; i < 2; i++) {
      this.bKingRC[i] = b2.bKingRC[i];
      this.wKingRC[i] = b2.wKingRC[i];
    }
    this.check =   b2.check;
    this.isOver =  b2.isOver;
    this.turn =    b2.turn;
    this.whiteCastleLeftOpen  = b2.whiteCastleLeftOpen;
    this.whiteCastleRightOpen = b2.whiteCastleRightOpen;
    this.blackCastleLeftOpen  = b2.blackCastleLeftOpen;
    this.blackCastleRightOpen = b2.blackCastleRightOpen;
    this.boardStates =    new HashMap<char[][], Integer>(b2.boardStates);
    this.enPassantPawnB = new int[] {-1, -1};
    this.enPassantPawnW = new int[] {-1, -1};
    for (int i = 0; i < 2; i++) {
      this.enPassantPawnB[i] = b2.enPassantPawnB[i];
      this.enPassantPawnW[i] = b2.enPassantPawnW[i];
    }
    this.x = b2.x;
    this.y = b2.x;
    this.boardSize = b2.boardSize;
    //this.validMoves = calculateValidMoves();
    this.validMoves = new ArrayList<int[]>();
    for (int i = 0; i < b2.validMoves.size(); i++) {
      this.validMoves.add(b2.validMoves.get(i));
    }
    this.recentMove = new int[4];
    for(int i= 0; i < 4; i++) {
      this.recentMove[i] = b2.recentMove[i];
    }
  }
  
  // create a new board with pieces at starting positions, white in 6, 7, black in 0, 1
  // a1 = [7,0], a2 = [7,1], g8 = [0,6], h8 = [0,7], c5 = [3,2]
  public ChessBoard() {
    char[] backRow = new char[] {'R','N','B','Q','K','B','N','R'};
    board = new char[8][8];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (r == 0) {
          board[r][c] = Character.toLowerCase(backRow[c]);
        } else if (r == 1) {
          board[r][c] = 'p';
        } else if (r == 6) {
          board[r][c] = 'P';
        } else if (r == 7) {
          board[r][c] = backRow[c];
        } else {
          board[r][c] = ' ';
        }
      }
    }
    bKingRC = new int[] {4, 0};
    wKingRC = new int[] {4, 7};
    
    check = false;
    isOver = false;
    turn = false;
    whiteCastleLeftOpen  = true;
    whiteCastleRightOpen = true;
    blackCastleLeftOpen  = true;
    blackCastleRightOpen = true;
    boardStates = new HashMap<char[][], Integer>();
    enPassantPawnB = new int[] {-1, -1};
    enPassantPawnW = new int[] {-1, -1};
    x = 0;
    y = 0;
    boardSize = 0;
    recentMove = new int[] {-1,-1,-1,-1};
    validMoves = calculateValidMoves();
  }
  
  private boolean inBetweenMove(int[] move, int r, int c) {
    int rM = max(move[0], move[2]);
    int rm = min(move[0], move[2]);
    int cM = max(move[1], move[3]);
    int cm = min(move[1], move[3]);
    if (rm == rM && r == rm && cm < c && c < cM) { return true; }
    if (cm == cM && c == cm && rm < r && r < rM) { return true; }
    if (rm < r && r < rM && cm < c && c < cM) {
      if (rm == move[0] && cm == move[1] || rm == move[2] && cm == move[3]) { if (rm - r == cm - c) { return true; } }
      else                                                                  { if (r + c == rm + cM) { return true; } }
    }
    return false;
  }
  
  // draws the current state of the board and pieces on the screen
  public void drawBoard(float x, float y, float size) {
    this.x = x;
    this.y = y;
    boardSize = size;
    
    //fill(0);
    //rect(x,y,size,size);
    
    float jump =  size / 8.0;
    textSize(jump/2.0);
    
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (r == recentMove[0] && c == recentMove[1] || r == recentMove[2] && c == recentMove[3]) {
          fill(17,82,46);
        } else if (inBetweenMove(recentMove, r, c)) {
          fill(34, 164, 92);
        } else if ((r + c) % 2 == 0) {
          fill(150);
        } else {
          fill(240);
        }
        rect( (x + c*jump),  (y + r*jump), jump, jump);
        if (whitePieces.indexOf(board[r][c]) > -1) {
          fill(255);
          circle(x + (c+0.5)*jump, y + (r+0.5)*jump, 0.9*jump);
        } else if (blackPieces.indexOf(board[r][c]) > -1) {
          fill(100);
          circle(x + (c+0.5)*jump, y + (r+0.5)*jump, 0.9*jump);
        }
        fill(0);
        text(board[r][c],  (x + (c+0.25)*jump),  (y + (r+0.5)*jump));
      }
    }
  }
  
  // determines first whether the move proposed is valid
  // if the move is valid, it makes the move and returns true
  // else it returns false
  public boolean movePiece(int[] move) {
    for (int[] m : validMoves) {
      if (move.equals(m)) { // probably should be array equals
        if (board[move[0]][move[1]] == 'K' && board[move[2]][move[3]] == 'R') {
          int k = 6;
          int r = 5;
          if (move[3] == 0) { k = 1; r = 2; }
          board[move[0]][r] = 'R';
          board[move[2]][k] = 'K';
          board[move[0]][move[1]] = ' ';
          board[move[2]][move[3]] = ' ';
        } else if (board[move[0]][move[1]] == 'k' && board[move[2]][move[3]] == 'r') {
          int k = 6;
          int r = 5;
          if (move[3] == 0) { k = 1; r = 2;}
          board[move[0]][r] = 'r';
          board[move[2]][k] = 'k';
          board[move[0]][move[1]] = ' ';
          board[move[2]][move[3]] = ' ';
        } else {
          board[move[2]][move[3]] = board[move[0]][move[1]];
          board[move[0]][move[1]] = ' ';
        }
        if (board[move[2]][move[3]] == 'K') { wKingRC[0] = move[2]; wKingRC[1] = move[3]; whiteCastleLeftOpen = false; whiteCastleRightOpen = false; }
        if (board[move[2]][move[3]] == 'k') { bKingRC[0] = move[2]; bKingRC[1] = move[3]; blackCastleLeftOpen = false; blackCastleRightOpen = false; }
        if (board[move[2]][move[3]] == 'R' && move[0] == 0 || move[2] == 0 && move[3] == 7) { whiteCastleLeftOpen  = false; }
        if (board[move[2]][move[3]] == 'R' && move[0] == 7 || move[2] == 7 && move[3] == 7) { whiteCastleRightOpen = false; }
        if (board[move[2]][move[3]] == 'r' && move[0] == 0 || move[2] == 0 && move[3] == 0) { blackCastleLeftOpen  = false; }
        if (board[move[2]][move[3]] == 'r' && move[0] == 7 || move[2] == 7 && move[3] == 0) { blackCastleRightOpen = false; }
        if (move[2] == 0 && board[move[2]][move[3]] == 'P') { board[move[2]][move[3]] = 'Q'; }
        if (move[2] == 7 && board[move[2]][move[3]] == 'p') { board[move[2]][move[3]] = 'q'; }
        if (enPassantPawnW[0] == move[2] && enPassantPawnW[1] == move[3]) { board[move[2]-1][move[3]] = ' '; }
        if (enPassantPawnB[0] == move[2] && enPassantPawnB[1] == move[3]) { board[move[2]+1][move[3]] = ' '; }
        if (board[move[2]][move[3]] == 'P' && move[2] == 4 && move[0] == 6) { enPassantPawnW[0] = 5; enPassantPawnW[1] = move[3]; } else { enPassantPawnW[0] = -1; enPassantPawnW[1] = -1; }
        if (board[move[2]][move[3]] == 'p' && move[2] == 3 && move[0] == 1) { enPassantPawnB[0] = 2; enPassantPawnB[1] = move[3]; } else { enPassantPawnB[0] = -1; enPassantPawnB[1] = -1; }
        turn = !turn;
        validMoves = calculateValidMoves();
        check = isInCheck(board, turn);
        recentMove = move;
        return true;
      }
    }
    return false;
  }
  
  // takes in a move and determines whether it is a valid move or not
  private boolean isValidMove(ArrayList<int[]> move) {
    return false;
  }
  
  private ArrayList<int[]> getValidMovesForPiece(char piece, int r, int c, boolean pieceColor, boolean pawnsGoingTowardsZero) {
    ArrayList<int[]> valM = new ArrayList<int[]>();
    String landableSquares = blackPieces + ' ';
    if (pieceColor) { landableSquares = whitePieces + ' '; }
    
    if (piece == 'R') {
      int r2 = r-1;
      while(r2 >= 0 && landableSquares.indexOf(board[r2][c]) > -1) { valM.add(new int[] {r, c, r2, c}); if(board[r2][c] != ' ') { break; } r2--; }
      r2 = r+1;
      while(r2 <= 7 && landableSquares.indexOf(board[r2][c]) > -1) { valM.add(new int[] {r, c, r2, c}); if(board[r2][c] != ' ') { break; } r2++; }
      int c2 = c-1;
      while(c2 >= 0 && landableSquares.indexOf(board[r][c2]) > -1) { valM.add(new int[] {r, c, r, c2}); if(board[r][c2] != ' ') { break; } c2--; }
      c2 = c+1;
      while(c2 <= 7 && landableSquares.indexOf(board[r][c2]) > -1) { valM.add(new int[] {r, c, r, c2}); if(board[r][c2] != ' ') { break; } c2++; }
    } else if (piece == 'B') {
      int d = 1;
      while(r-d >= 0 && c-d >= 0 && landableSquares.indexOf(board[r-d][c-d]) > -1) { valM.add(new int[] {r, c, r-d, c-d}); if(board[r-d][c-d] != ' ') { break; } d++; }
      d = 1;
      while(r+d <= 7 && c-d >= 0 && landableSquares.indexOf(board[r+d][c-d]) > -1) { valM.add(new int[] {r, c, r+d, c-d}); if(board[r+d][c-d] != ' ') { break; } d++; }
      d = 1;
      while(r-d >= 0 && c+d <= 7 && landableSquares.indexOf(board[r-d][c+d]) > -1) { valM.add(new int[] {r, c, r-d, c+d}); if(board[r-d][c+d] != ' ') { break; } d++; }
      d = 1;
      while(r+d <= 7 && c+d <= 7 && landableSquares.indexOf(board[r+d][c+d]) > -1) { valM.add(new int[] {r, c, r+d, c+d}); if(board[r+d][c+d] != ' ') { break; } d++; }
    } else if (piece == 'N') {
      if (r > 1 && c > 0 && landableSquares.indexOf(board[r-2][c-1]) > -1) { valM.add(new int[] {r, c, r-2, c-1}); }
      if (r > 1 && c < 7 && landableSquares.indexOf(board[r-2][c+1]) > -1) { valM.add(new int[] {r, c, r-2, c+1}); }
      if (r < 6 && c > 0 && landableSquares.indexOf(board[r+2][c-1]) > -1) { valM.add(new int[] {r, c, r+2, c-1}); }
      if (r < 6 && c < 7 && landableSquares.indexOf(board[r+2][c+1]) > -1) { valM.add(new int[] {r, c, r+2, c+1}); }
      if (r > 0 && c > 1 && landableSquares.indexOf(board[r-1][c-2]) > -1) { valM.add(new int[] {r, c, r-1, c-2}); }
      if (r > 0 && c < 6 && landableSquares.indexOf(board[r-1][c+2]) > -1) { valM.add(new int[] {r, c, r-1, c+2}); }
      if (r < 7 && c > 1 && landableSquares.indexOf(board[r+1][c-2]) > -1) { valM.add(new int[] {r, c, r+1, c-2}); }
      if (r < 7 && c < 6 && landableSquares.indexOf(board[r+1][c+2]) > -1) { valM.add(new int[] {r, c, r+1, c+2}); }
    } else if (piece == 'P') {
      int d = 1;
      int initial = 1;
      landableSquares = blackPieces;
      int[] enP = enPassantPawnB;
      if (pieceColor) { landableSquares = whitePieces; enP = enPassantPawnW;}
      if (pawnsGoingTowardsZero) { d = -1; initial = 6; }
      
      if (board[r+d][c] == ' ') {
        valM.add(new int[] {r, c, r+d, c});
        if (r == initial && board[r+2*d][c] == ' ') { valM.add(new int[] {r, c, r+2*d, c}); }
      }
      if (c > 0 && (landableSquares.indexOf(board[r+d][c-1]) > -1 || (r+d == enP[0] && c-1 == enP[1]))) { valM.add(new int[] {r, c, r+d, c-1}); }
      if (c < 7 && (landableSquares.indexOf(board[r+d][c+1]) > -1 || (r+d == enP[0] && c+1 == enP[1]))) { valM.add(new int[] {r, c, r+d, c+1}); }
    } else if (piece == 'K') {
      if (r > 0 &&          landableSquares.indexOf(board[r-1][c  ]) > -1) { valM.add(new int[] {r, c, r-1, c  }); }
      if (r > 0 && c < 7 && landableSquares.indexOf(board[r-1][c+1]) > -1) { valM.add(new int[] {r, c, r-1, c+1}); }
      if (r > 0 && c > 0 && landableSquares.indexOf(board[r-1][c-1]) > -1) { valM.add(new int[] {r, c, r-1, c-1}); }
      if (r < 7 &&          landableSquares.indexOf(board[r+1][c  ]) > -1) { valM.add(new int[] {r, c, r+1, c  }); }
      if (r < 7 && c < 7 && landableSquares.indexOf(board[r+1][c+1]) > -1) { valM.add(new int[] {r, c, r+1, c+1}); }
      if (r < 7 && c > 0 && landableSquares.indexOf(board[r+1][c-1]) > -1) { valM.add(new int[] {r, c, r+1, c-1}); }
      if (         c < 7 && landableSquares.indexOf(board[r  ][c+1]) > -1) { valM.add(new int[] {r, c, r,   c+1}); }
      if (         c > 0 && landableSquares.indexOf(board[r  ][c-1]) > -1) { valM.add(new int[] {r, c, r,   c-1}); }
      boolean castleLeft =  board[0][4] == 'k' && pieceColor && blackCastleLeftOpen  || board[7][4] == 'K' && !pieceColor && whiteCastleLeftOpen;
      boolean castleRight = board[0][4] == 'k' && pieceColor && blackCastleRightOpen || board[7][4] == 'K' && !pieceColor && whiteCastleRightOpen; // I think this misses one special case
      if (castleLeft  && board[r][c-1] == ' ' && board[r][c-2] == ' ' && board[r][c-3] == ' ' &&
          !isPinnedOrCovered(board, r, c,   turn) && !isPinnedOrCovered(board, r, c-1, turn)  && 
          !isPinnedOrCovered(board, r, c-2, turn) && !isPinnedOrCovered(board, r, c-3, turn))  { valM.add(new int[] {r, c, r, 0}); }
      if (castleRight && board[r][c+1] == ' ' && board[r][c+2] == ' ' &&
          !isPinnedOrCovered(board, r, c,   turn) && !isPinnedOrCovered(board, r, c+1, turn)  && 
          !isPinnedOrCovered(board, r, c+2, turn))                                             { valM.add(new int[] {r, c, r, 7}); }
    } else if (piece == 'Q') {
      valM.addAll(getValidMovesForPiece('R', r, c, pieceColor, pawnsGoingTowardsZero));
      valM.addAll(getValidMovesForPiece('B', r, c, pieceColor, pawnsGoingTowardsZero));
    }
    return valM;
  }
  
  // finds the valid moves given the current board state
  private ArrayList<int[]> calculateValidMoves() {
    return calculateValidMovesFor(turn);
  }
  
  public ArrayList<int[]> calculateValidMovesFor(boolean turn) {
    // look for pins/check next move, check, castle(and pins/special rules), first pawn move, pawn reaches end, en passant(pawn moves 2 + gets caught)
    // also need to consider draws
        // stalemate, threefold (and 5) repetition, fifty-move (and 75) rule, impossible to checkmate, mutual agreement
    ArrayList<int[]> valM = new ArrayList<int[]>();
    
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (turn) {
          if (board[r][c] == 'r') {
            valM.addAll(getValidMovesForPiece('R', r, c, true, false));
          } else if (board[r][c] == 'b') {
            valM.addAll(getValidMovesForPiece('B', r, c, true, false));
          } else if (board[r][c] == 'n') {
            valM.addAll(getValidMovesForPiece('N', r, c, true, false));
          } else if (board[r][c] == 'q') {
            valM.addAll(getValidMovesForPiece('Q', r, c, true, false));
          } else if (board[r][c] == 'k') {
            valM.addAll(getValidMovesForPiece('K', r, c, true, false));
          } else if (board[r][c] == 'p' && r < 7) { // add checks for check
            valM.addAll(getValidMovesForPiece('P', r, c, true, false));
          }
        } else {
          if (board[r][c] == 'R') {
            valM.addAll(getValidMovesForPiece('R', r, c, false, true));
          } else if (board[r][c] == 'B') {
            valM.addAll(getValidMovesForPiece('B', r, c, false, true));
          } else if (board[r][c] == 'N') {
            valM.addAll(getValidMovesForPiece('N', r, c, false, true));
          } else if (board[r][c] == 'Q') {
            valM.addAll(getValidMovesForPiece('Q', r, c, false, true));
          } else if (board[r][c] == 'K') {
            valM.addAll(getValidMovesForPiece('K', r, c, false, true));
          } else if (board[r][c] == 'P' && r > 0) { // add checks for check
            valM.addAll(getValidMovesForPiece('P', r, c, false, true));
          }
        }
      }
    }
    // add checks for check for each move here
    for (int i = valM.size() - 1; i >= 0; i--) {
      char[][] test = getBoardIf(valM.get(i));
      if (isInCheck(test, turn)) { valM.remove(valM.get(i)); }
    }
    return valM;
  }
  
  private boolean isPinnedOrCovered(char[][] board, int r, int c, boolean colorPinned) {
    if (r < 0 || r > 7 || c < 0 || c > 7) { return false; }
    boolean pinnedPiece = false;
    String friend = whitePieces;
    String enemy = blackPieces;
    if (colorPinned) { friend = blackPieces; enemy = whitePieces; }
    
    int r2 = r + 1;
    while (r2 < 7 && ((!pinnedPiece && friend.indexOf(board[r2][c]) > -1) || board[r2][c] == ' ')) { if (friend.indexOf(board[r2][c]) > -1) { pinnedPiece = true; } r2++; }
    if (r2 <= 7 && enemy.indexOf(board[r2][c]) > -1 && "QqRr".indexOf(board[r2][c]) > -1) { return true; }
    r2 = r - 1;
    while (r2 > 0 && ((!pinnedPiece && friend.indexOf(board[r2][c]) > -1) || board[r2][c] == ' ')) { if (friend.indexOf(board[r2][c]) > -1) { pinnedPiece = true; } r2--; }
    if (r2 >= 0 && enemy.indexOf(board[r2][c]) > -1 && "QqRr".indexOf(board[r2][c]) > -1) { return true; }
    int c2 = c + 1;
    while (c2 < 7 && ((!pinnedPiece && friend.indexOf(board[r][c2]) > -1) || board[r][c2] == ' ')) { if (friend.indexOf(board[r][c2]) > -1) { pinnedPiece = true; } c2++; }
    if (c2 <= 7 && enemy.indexOf(board[r][c2]) > -1 && "QqRr".indexOf(board[r][c2]) > -1) { return true; }
    c2 = c - 1;
    while (c2 > 0 && ((!pinnedPiece && friend.indexOf(board[r][c2]) > -1) || board[r][c2] == ' ')) { if (friend.indexOf(board[r][c2]) > -1) { pinnedPiece = true; } c2--; }
    if (c2 >= 0 && enemy.indexOf(board[r][c2]) > -1 && "QqRr".indexOf(board[r][c2]) > -1) { return true; }
    
    int d = 1;
    while (r+d < 7 && c+d < 7 && ((!pinnedPiece && friend.indexOf(board[r+d][c+d]) > -1) || board[r+d][c+d] == ' ')) { if (friend.indexOf(board[r+d][c+d]) > -1) { pinnedPiece = true; } d++; }
    if (r+d <= 7 && c+d <= 7 && enemy.indexOf(board[r+d][c+d]) > -1 && "QqBb".indexOf(board[r+d][c+d]) > -1) { return true; }
    d = 1;
    while (r+d < 7 && c-d > 0 && ((!pinnedPiece && friend.indexOf(board[r+d][c-d]) > -1) || board[r+d][c-d] == ' ')) { if (friend.indexOf(board[r+d][c-d]) > -1) { pinnedPiece = true; } d++; }
    if (r+d <= 7 && c-d >= 0 && enemy.indexOf(board[r+d][c-d]) > -1 && "QqBb".indexOf(board[r+d][c-d]) > -1) { return true; }
    d = 1;
    while (r-d > 0 && c+d < 7 && ((!pinnedPiece && friend.indexOf(board[r-d][c+d]) > -1) || board[r-d][c+d] == ' ')) { if (friend.indexOf(board[r-d][c+d]) > -1) { pinnedPiece = true; } d++; }
    if (r-d >= 0 && c+d <= 7 && enemy.indexOf(board[r-d][c+d]) > -1 && "QqBb".indexOf(board[r-d][c+d]) > -1) { return true; }
    d = 1;
    while (r-d > 0 && c-d > 0 && ((!pinnedPiece && friend.indexOf(board[r-d][c-d]) > -1) || board[r-d][c-d] == ' ')) { if (friend.indexOf(board[r-d][c-d]) > -1) { pinnedPiece = true; } d++; }
    if (r-d >= 0 && c-d >= 0 && enemy.indexOf(board[r-d][c-d]) > -1 && "QqBb".indexOf(board[r-d][c-d]) > -1) { return true; }
    
    return false;
  }
  
  /*
  private boolean isPieceForcingCheck(char[][] board, char piece, int r, int c, int[] kingRC, boolean pawnsGoingTowardsZero) {
    if (piece == 'R') {
      if (kingRC[0] == r) {
        int r1 = min(r, kingRC[0]);
        int r2 = max(r, kingRC[0]);
        boolean allEmpty = true;
        for (r1 = r1 + 1; r1 < r2; r1++) {
          if (board[r1][c] != ' ') {
            allEmpty = false;
          }
        }
        if (allEmpty) { return true; }
      } else if (kingRC[1] == c) {
        int c1 = min(c, kingRC[1]);
        int c2 = max(c, kingRC[1]);
        boolean allEmpty = true;
        for (c1 = c1 + 1; c1 < c2; c1++) {
          if (board[r][c1] != ' ') { allEmpty = false; }
        }
        if (allEmpty) { return true; }
      }
    } else if (piece == 'B') {
      if (kingRC[0] - r == kingRC[1] - c) {
        if (r > kingRC[0]) {
          boolean allEmpty = true;
          for (int d = 1; d < r - kingRC[0]; d++) {
            if (board[r-d][c-d] != ' ') { allEmpty = false; }
          }
          if (allEmpty) { return true; }
        } else {
          boolean allEmpty = true;
          for (int d = 1; d < kingRC[0] - r; d++) {
            if (board[r+d][c+d] != ' ') { allEmpty = false; }
          }
          if (allEmpty) { return true; }
        }
      } else if ( (kingRC[0] - r) + (kingRC[1] - c) == 0) {
        if (r > kingRC[0]) {
          boolean allEmpty = true;
          for (int d = 1; d < r - kingRC[0]; d++) {
            if (board[r-d][c+d] != ' ') { allEmpty = false; }
          }
          if (allEmpty) { return true; }
        } else {
          boolean allEmpty = true;
          for (int d = 1; d < kingRC[0] - r; d++) {
            if (board[r+d][c-d] != ' ') { allEmpty = false; }
          }
          if (allEmpty) { return true; }
        }
      }
    } else if (piece == 'N') {
      if      (abs(r-kingRC[0]) == 2 && abs(c-kingRC[1]) == 1) { return true; }
      else if (abs(r-kingRC[0]) == 1 && abs(c-kingRC[1]) == 2) { return true; }
    } else if (piece == 'P') {
      if (pawnsGoingTowardsZero) {
        if (kingRC[0] - r ==  1 && abs(kingRC[1] - c) == 1) { return true; }
      } else {
        if (kingRC[0] - r == -1 && abs(kingRC[1] - c) == 1) { return true; }
      }
    } else if (piece == 'Q') {
      if (isPieceForcingCheck(board, 'R', r, c, kingRC, pawnsGoingTowardsZero) || isPieceForcingCheck(board, 'B', r, c, kingRC, pawnsGoingTowardsZero)) { return true; }
    }
    return false;
  }
  */
  
  public boolean isInCheck(char[][] board, boolean pieceColor) {
    String enemy = blackPieces;
    char king = 'K';
    char king2 = 'k';
    if (pieceColor) { king = 'k'; king2 = 'K'; enemy = whitePieces; }
    int r = -1;
    int c = -1;
    int r2 = -1;
    int c2 = -1;
    boolean found = false;
    boolean found2 = false;
    for (int r1 = 0; r1 < 8; r1++) {
      for (int c1 = 0; c1 < 8; c1++) {
        if (board[r1][c1] == king)  { found  = true; r  = r1; c  = c1; }
        if (board[r1][c1] == king2) { found2 = true; r2 = r1; c2 = c1; }
      }
      if (found && found2) { break; }
    }
    assert(r >= 0 && r <= 7);
    assert(c >= 0 && c <= 7);
    
    if (abs(r - r2) <= 1 && abs(c - c2) <= 1) { return true; }
    
    if (r+2 <= 7 && c+1 <= 7 && enemy.indexOf(board[r+2][c+1]) > -1 && "Nn".indexOf(board[r+2][c+1]) > -1) { return true; }
    if (r+2 <= 7 && c-1 >= 0 && enemy.indexOf(board[r+2][c-1]) > -1 && "Nn".indexOf(board[r+2][c-1]) > -1) { return true; }
    if (r-2 >= 0 && c+1 <= 7 && enemy.indexOf(board[r-2][c+1]) > -1 && "Nn".indexOf(board[r-2][c+1]) > -1) { return true; }
    if (r-2 >= 0 && c-1 >= 0 && enemy.indexOf(board[r-2][c-1]) > -1 && "Nn".indexOf(board[r-2][c-1]) > -1) { return true; }
    if (r+1 <= 7 && c+2 <= 7 && enemy.indexOf(board[r+1][c+2]) > -1 && "Nn".indexOf(board[r+1][c+2]) > -1) { return true; }
    if (r+1 <= 7 && c-2 >= 0 && enemy.indexOf(board[r+1][c-2]) > -1 && "Nn".indexOf(board[r+1][c-2]) > -1) { return true; }
    if (r-1 >= 0 && c+2 <= 7 && enemy.indexOf(board[r-1][c+2]) > -1 && "Nn".indexOf(board[r-1][c+2]) > -1) { return true; }
    if (r-1 >= 0 && c-2 >= 0 && enemy.indexOf(board[r-1][c-2]) > -1 && "Nn".indexOf(board[r-1][c-2]) > -1) { return true; }
    
    int r1 = r+1;
    while (r1 <= 7 && board[r1][c] == ' ') { r1++; }
    if (r1 <= 7 && enemy.indexOf(board[r1][c]) > -1 && "QqRr".indexOf(board[r1][c]) > -1) { return true; }
    r1 = r-1;
    while (r1 >= 0 && board[r1][c] == ' ') { r1--; }
    if (r1 >= 0 && enemy.indexOf(board[r1][c]) > -1 && "QqRr".indexOf(board[r1][c]) > -1) { return true; }
    int c1 = c+1;
    while (c1 <= 7 && board[r][c1] == ' ') { c1++; }
    if (c1 <= 7 && enemy.indexOf(board[r][c1]) > -1 && "QqRr".indexOf(board[r][c1]) > -1) { return true; }
    c1 = c-1;
    while (c1 >= 0 && board[r][c1] == ' ') { c1--; }
    if (c1 >= 0 && enemy.indexOf(board[r][c1]) > -1 && "QqRr".indexOf(board[r][c1]) > -1) { return true; }
    
    int d = 1;
    while (r+d <= 7 && c+d <= 7 && board[r+d][c+d] == ' ') { d++; }
    if (r+d <= 7 && c+d <= 7 && enemy.indexOf(board[r+d][c+d]) > -1 && "QqBb".indexOf(board[r+d][c+d]) > -1) { return true; }
    d = 1;
    while (r+d <= 7 && c-d >= 0 && board[r+d][c-d] == ' ') { d++; }
    if (r+d <= 7 && c-d >= 0 && enemy.indexOf(board[r+d][c-d]) > -1 && "QqBb".indexOf(board[r+d][c-d]) > -1) { return true; }
    d = 1;
    while (r-d >= 0 && c+d <= 7 && board[r-d][c+d] == ' ') { d++; }
    if (r-d >= 0 && c+d <= 7 && enemy.indexOf(board[r-d][c+d]) > -1 && "QqBb".indexOf(board[r-d][c+d]) > -1) { return true; }
    d = 1;
    while (r-d >= 0 && c-d >= 0 && board[r-d][c-d] == ' ') { d++; }
    if (r-d >= 0 && c-d >= 0 && enemy.indexOf(board[r-d][c-d]) > -1 && "QqBb".indexOf(board[r-d][c-d]) > -1) { return true; }
    
    if (pieceColor) {
      if ((r+1 <= 7 && c-1 >= 0 && board[r+1][c-1] == 'P') || (r+1 <= 7 && c+1 <= 7 && board[r+1][c+1] == 'P')) { return true; }
    } else {
      if ((r-1 >= 0 && c-1 >= 0 && board[r-1][c-1] == 'p') || (r-1 >= 0 && c+1 <= 7 && board[r-1][c+1] == 'p')) { return true; }
    }
    return false;
  }
  
  /*
  // takes in a color, determines if that team is in check
  // false is white, true is black
  private boolean isInCheck(char[][] board, boolean pieceColor) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (pieceColor) {
          if (board[r][c] == 'R') {
            if (isPieceForcingCheck(board, 'R', r, c, bKingRC, true)) { return true; }
          } else if (board[r][c] == 'B') {
            if (isPieceForcingCheck(board, 'B', r, c, bKingRC, true)) { return true; }
          } else if (board[r][c] == 'N') {
            if (isPieceForcingCheck(board, 'N', r, c, bKingRC, true)) { return true; }
          } else if (board[r][c] == 'P') {
            if (isPieceForcingCheck(board, 'P', r, c, bKingRC, true)) { return true; }
          } else if (board[r][c] == 'Q') {
            if (isPieceForcingCheck(board, 'Q', r, c, bKingRC, true)) { return true; }
          }
        } else {
          if (board[r][c] == 'r') {
            if (isPieceForcingCheck(board, 'r', r, c, wKingRC, false)) { return true; }
          } else if (board[r][c] == 'b') {
            if (isPieceForcingCheck(board, 'b', r, c, wKingRC, false)) { return true; }
          } else if (board[r][c] == 'n') {
            if (isPieceForcingCheck(board, 'n', r, c, wKingRC, false)) { return true; }
          } else if (board[r][c] == 'p') {
            if (isPieceForcingCheck(board, 'p', r, c, wKingRC, false)) { return true; }
          } else if (board[r][c] == 'q') {
            if (isPieceForcingCheck(board, 'q', r, c, wKingRC, false)) { return true; }
          }
        }
      }
    }
    return false;
  }
  */
  
  // return a list of valid moves
  public ArrayList<int[]> getValidMoves() {
    ArrayList<int[]> retList = new ArrayList<int[]>(validMoves);
    return retList;
  }
  
  // takes in a move and returns a new board where the move has been made
  public char[][] getBoardIf(int[] move) {
    char[][] inTheory = new char[8][8];
    
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        inTheory[r][c] = board[r][c];
      }
    }
    
    //inTheory[move[2]][move[3]] = inTheory[move[0]][move[1]];
    //inTheory[move[0]][move[1]] = ' ';
    
    if (inTheory[move[0]][move[1]] == 'K' && inTheory[move[2]][move[3]] == 'R') {
        int k = 6;
        int r = 5;
        if (move[3] == 0) { k = 1; r = 2; }
        inTheory[move[0]][r] = 'R';
        inTheory[move[2]][k] = 'K';
        inTheory[move[0]][move[1]] = ' ';
        inTheory[move[2]][move[3]] = ' ';
      } else if (inTheory[move[0]][move[1]] == 'k' && inTheory[move[2]][move[3]] == 'r') {
        int k = 6;
        int r = 5;
        if (move[3] == 0) { k = 1; r = 2;}
        inTheory[move[0]][r] = 'r';
        inTheory[move[2]][k] = 'k';
        inTheory[move[0]][move[1]] = ' ';
        inTheory[move[2]][move[3]] = ' ';
      } else {
        inTheory[move[2]][move[3]] = inTheory[move[0]][move[1]];
        inTheory[move[0]][move[1]] = ' ';
      }
      //if (inTheory[move[2]][move[3]] == 'K') { wKingRC[0] = move[2]; wKingRC[1] = move[3]; whiteCastleLeftOpen = false; whiteCastleRightOpen = false; }
      //if (inTheory[move[2]][move[3]] == 'k') { bKingRC[0] = move[2]; bKingRC[1] = move[3]; blackCastleLeftOpen = false; blackCastleRightOpen = false; }
      //if (inTheory[move[2]][move[3]] == 'R' && move[0] == 0) { whiteCastleLeftOpen  = false; }
      //if (inTheory[move[2]][move[3]] == 'R' && move[0] == 7) { whiteCastleRightOpen = false; }
      //if (inTheory[move[2]][move[3]] == 'r' && move[0] == 0) { blackCastleLeftOpen  = false; }
      //if (inTheory[move[2]][move[3]] == 'r' && move[0] == 7) { blackCastleRightOpen = false; }
      if (move[2] == 0 && inTheory[move[2]][move[3]] == 'P') { inTheory[move[2]][move[3]] = 'Q'; }
      if (move[2] == 7 && inTheory[move[2]][move[3]] == 'p') { inTheory[move[2]][move[3]] = 'q'; }
      if (enPassantPawnW[0] == move[2] && enPassantPawnW[1] == move[3]) { inTheory[move[2]-1][move[3]] = ' '; }
      if (enPassantPawnB[0] == move[2] && enPassantPawnB[1] == move[3]) { inTheory[move[2]+1][move[3]] = ' '; }
      //if (inTheory[move[2]][move[3]] == 'P' && move[2] == 4 && move[0] == 6) { enPassantPawnW[0] = 5; enPassantPawnW[1] = move[3]; } else { enPassantPawnW[0] = -1; enPassantPawnW[1] = -1; }
      //if (inTheory[move[2]][move[3]] == 'p' && move[2] == 3 && move[0] == 1) { enPassantPawnB[0] = 2; enPassantPawnB[1] = move[3]; } else { enPassantPawnB[0] = -1; enPassantPawnB[1] = -1; }

    return inTheory;
  }
  
  public ChessBoard getBoardStateIf(int[] move) {
    ChessBoard newBoard = new ChessBoard(this);
    newBoard.movePiece(move);
    return newBoard;
  }
  
  // returns true if by any rotational symmetry, two boards are the same
  // in terms of relative piece placement and whose turn it is
  // returns false otherwise
  public boolean isEquivalentBoard(ChessBoard b2) {
    // maybe this won't really be that useful because of pawns
    return false;
  }
  
  // returns true if two boards are exactly the same and all other variables are the same
  public boolean equals(ChessBoard b2) {
    return false;
  }
  
  // called when a square on the board may have been clicked
  // modifies board if necessary with a move
  public int[] clicked(float mousex, float mousey) {
    int r = (int) ((mousey - y)/boardSize * 8);
    int c = (int) ((mousex - x)/boardSize * 8);
    if (r > 7 || r < 0) { r = -1; c = -1; }
    if (c > 7 || c < 0) { r = -1; c = -1; }
    return new int[] {r, c};
  }
  
  public boolean currentTurn() {
    return turn;
  }
  
  public void drawInfo(float x, float y, float s) {
    String infoText = "Turn: " + turn + "\nCheck: " + check + "\nOver: " + isOver + "\nWCL: " + whiteCastleLeftOpen + "\nWCR: " + whiteCastleRightOpen + 
                      "\nBCL: " + blackCastleLeftOpen + "\nBCR: " + blackCastleRightOpen + "\nen passant pawn b: \n" + enPassantPawnB[0] + ", " + enPassantPawnB[1] + 
                      "\nen passant pawn w: \n" + enPassantPawnW[0] + ", " + enPassantPawnW[1] + "\n wking: " + wKingRC[0] + ", " + wKingRC[1] +
                      "\n bking: " + bKingRC[0] + ", " + bKingRC[1];
    fill(255);
    rect(x, y, s, 2.4*s, 7);
    fill(0);
    textSize(s*0.10);
    text(infoText, x + s*0.05, y + s*0.25);
  }
  
  public char[][] getBoard() {
    char[][] newBoard = new char[8][8];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        newBoard[r][c] = board[r][c];
      }
    }
    return newBoard;
  }
  
  public boolean gameOver() {
    return isOver;
  }
  
}
