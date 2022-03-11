public static int screenWidth  = 1300;
public static int screenHeight = 650;

public ChessGame game;
public ChessPlayer player1;
public ChessPlayer player2;

public void setup(){
  size(1300, 650);
  background(137, 87, 187);
  //size(screenWidth, screenHeight);
  initialize();
}

public void initialize() {
  //player1 = new HumanChessPlayer("Miles"); //<>//
  player1 = new ChessAI("The Thinker", 3, 30);
  player2 = new ChessAI("The Thinkerer", 2, 30);
  //player2 = new ChessTaker("The Taker");
  //player2 = new RandomChessAI("Genius AI");
  game =    new ChessGame(player1, player2, screenWidth, screenHeight);
  game.drawGame();
}

public void draw() {
  
}

public void keyPressed() {
  if (key == 'r') {
    initialize();
  } else if (key == 'a') {
    /*
    while (!game.gameOver()) {
      game.makeNextMove();
      game.drawGame();
    }*/
  } else if (key == ' ') {
    game.clicked(0,0);
  }
}

public void mouseClicked() {
  game.clicked(mouseX, mouseY);
}
