import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gdsc_app/blank_pixel.dart';
import 'package:gdsc_app/food_pixel.dart';
import 'package:gdsc_app/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State <HomePage> createState() =>  HomePageState();
}

enum snakeDirection { UP, DOWN, LEFT, RIGHT }

class  HomePageState extends State <HomePage> {

  // grid dimensions
  int rowSize = 10;
  int totalNumberOfSquare = 100;

  bool gameHasStarted = false;

  //user score
  int currentScore = 0;

  // snake position
  List<int> snakePos = [
    0,
    1,
    2
  ];

  //food position
  int foodPos = 55;

  //snake direction is to the right
  var currentDirection = snakeDirection.RIGHT;

  //start the game
  void startGame(){
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
       // keep the snake moving
       moveSnake();

       //if snake eat food
       eatFood();

       //check game over
       if (gameOver()) {
         timer.cancel();

         showDialog(
          context: context, 
          barrierDismissible: false,
           builder: (context) {
             return AlertDialog(
              title: Text('Game Over'),
              content: Column(
                children: [
                  Text('Your score is: ' + currentScore.toString()),
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter Name'),
                  )
                ],
              ),
              actions: [
                MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  submitScore();
                  newGame(); 
                },
                child: Text('Submit'),
                color: Colors.pink,
                )
              ],
             );
           }, 
        );
       }
      });
    });
  }
  void submitScore(){
    //
  }
  void newGame(){
    setState(() {
      snakePos = [0,1,2];
      foodPos = 55;
      currentDirection = snakeDirection.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood(){
    while (snakePos.contains(foodPos)){
      currentScore++;
      foodPos = Random().nextInt(totalNumberOfSquare);
    }
  }
  bool gameOver(){
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)){
      return true;
    }
    return false;
  }

  void moveSnake(){
      switch (currentDirection) {
        case snakeDirection.RIGHT:
        {

          // if snake is at the right wall, re adjust
          if (snakePos.last % rowSize == 9) {
              snakePos.add(snakePos.last + 1 - rowSize);
          } else{
            snakePos.add(snakePos.last + 1);
          }
        }
          
          break;
        case snakeDirection.LEFT:
        {
          // if snake is at the left wall, re adjust
          if (snakePos.last % rowSize == 0) {
              snakePos.add(snakePos.last - 1 + rowSize);
          } else{
            snakePos.add(snakePos.last - 1);
          }
        }
        
          break;
        case snakeDirection.UP:
        {
          //add a head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquare);
          } else {
            snakePos.add(snakePos.last - rowSize);
          } 
        } 
          break;
        case snakeDirection.DOWN:
        {
          //add a head
          if (snakePos.last + rowSize > totalNumberOfSquare) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquare);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }  
        break;
        default:
      }
      // snake is eating food
       if (snakePos.last == foodPos) {
         eatFood();
       } else {
        //remove the tail
          snakePos.removeAt(0);
       }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
      children: [
        //high score
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //user current score
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Current Score'),
                  Text(
                    currentScore.toString(),
                    style: TextStyle(fontSize: 36),
                  ),
                ],
              ),

              //highscores, top 5 or 10
              Text('highscores..')
            ],
          ),
        ),

        //game grid
        Expanded(
          flex: 3,
          child: GestureDetector(
            onVerticalDragUpdate: (details){
              if (details.delta.dy > 0 && 
              currentDirection != snakeDirection.UP) {
                currentDirection = snakeDirection.DOWN;
              } else if (details.delta.dy < 0 &&
              currentDirection != snakeDirection.DOWN){
                currentDirection = snakeDirection.UP;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0 && 
              currentDirection != snakeDirection.LEFT) {
                currentDirection = snakeDirection.RIGHT;
              } else if (details.delta.dx < 0 &&
              currentDirection != snakeDirection.RIGHT){
                currentDirection = snakeDirection.LEFT;
              }
            },
            child: GridView.builder(
              itemCount: totalNumberOfSquare,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize), 
              itemBuilder: (context, index){
                if (snakePos.contains(index)) {
                  return const SnakePixel();
                  } else if (foodPos == index) {
                    return const FoodPixel();
                  }
                  else {
                    return const BlankPixel();
                }
              }),
          )
        ),

        //play button
        Expanded(
          child: Container(
            child: Center(
              child: MaterialButton(
                child: Text('PLAY'),
                color: gameHasStarted? Colors.grey :Colors.pink,
                onPressed: gameHasStarted ? () {} : startGame,
              ),
            ),
          ),
        ),
       ],
      ),
    );
  }
}