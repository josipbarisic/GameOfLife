import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_of_life_starter_code/app/constants.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends ReactiveViewModel {
  HomeViewModel() {
    timer = Timer.periodic(Duration(milliseconds: TICK_MS), (timer) => tick());
    _rows = 30;
    _columns = 30;
    _generation = 0;
    _initGrid();
  }

  late Timer timer;
  late List<List<int>> _grid;
  late int _rows;
  late int _columns;
  late int _generation;
  late Random genLife = Random();

  /// Getters
  List<List<int>> get grid => _grid;

  int get rows => _rows;

  int get columns => _columns;

  int get generation => _generation;

  void _initGrid() {
    _grid = List.generate(_rows, (_) => List.filled(_columns, 0));
    for (int i = 0; i < _rows; i++) {
      for (int j = 0; j < _columns; j++) {
        _grid[i][j] = genLife.nextBool() ? ALIVE : DEAD;
      }
    }
  }


  // 1. Initialize a counter variable called count to 0.
  // 2. Loop through all the neighboring cells around the given cell. This is
  // done by using two nested for loops that iterate from -1 to 1 in both dimensions.
  // 3. Check if the current neighboring cell is the given cell itself. If it is, skip it using the continue statement and move to the next neighboring cell.
  // 4. Calculate the row and column indices of the current neighboring cell by adding the loop indices to the row and column indices of the given cell.
  // 5. Check if the current neighboring cell is within the bounds of the grid and is alive. If it is, increment the count variable.
  // 6. Return the final count value, which represents the number of alive neighbors of the given cell.
  int _countAliveNeighbors(int row, int column) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;
        int r = row + i;
        int c = column + j;
        if (r >= 0 &&
            r < _rows &&
            c >= 0 &&
            c < _columns &&
            _grid[r][c] == ALIVE) {
          count++;
        }
      }
    }
    return count;
  }

  // 1. Increment the _generation variable by 1 to indicate that a new
  // generation is being calculated.
  // 2. Create a new two-dimensional list called nextGrid that has the same
  // dimensions as the current grid, but with all cells initially set to 0 (dead).
  // 3. Loop through all the cells in the current grid using two nested for loops.
  // 4. Calculate the number of alive neighbors of the current cell using the
  // _countAliveNeighbors method.
  // 5. Check the current state of the cell in the current grid.
  // 6. If the cell is alive, check if it has 2 or 3 neighbors, which means it
  // survives to the next generation, and set the corresponding cell in nextGrid
  // to alive. Otherwise, set the corresponding cell in nextGrid to dead.
  // 7. If the cell is dead, check if it has exactly 3 neighbors, which means it becomes alive due to reproduction, and set the corresponding cell in nextGrid to alive. Otherwise, set the corresponding cell in nextGrid to dead.
  // 8. After all cells have been checked and updated in nextGrid, set _grid to nextGrid, which represents the new state of the game grid for the next generation.
  // 9. Call the rebuildUi() method to update the user interface to reflect the new state of the grid.
  void tick() {
    _generation++;
    List<List<int>> nextGrid =
        List.generate(_rows, (_) => List.filled(_columns, 0));
    for (int i = 0; i < _rows; i++) {
      for (int j = 0; j < _columns; j++) {
        int neighbors = _countAliveNeighbors(i, j);
        if (_grid[i][j] == ALIVE) {
          if (neighbors == 2 || neighbors == 3) {
            nextGrid[i][j] = ALIVE;
          } else {
            nextGrid[i][j] = DEAD;
          }
        } else {
          if (neighbors == 3) {
            nextGrid[i][j] = ALIVE;
          } else {
            nextGrid[i][j] = DEAD;
          }
        }
      }
    }
    _grid = nextGrid;
    rebuildUi();
  }

  void promptUserInput(BuildContext context) async {
    String? userInput;
    // Show the dialog box
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter a number of rows and columns:'),
          content: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
            onChanged: (value) => userInput = value, // Store the user's input
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog box
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Do something with the user's input, then close the dialog box
                print('User input: $userInput');
                Navigator.pop(context);
                int newMatrixValue = int.tryParse(userInput ?? '') ?? 30;
                _rows = newMatrixValue;
                _columns = newMatrixValue;
                restart();
                pause();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void restart() {
    _generation = 0;
    _initGrid();
    rebuildUi();
  }

  void pause() {
    timer.cancel();
    rebuildUi();
  }

  void resume() {
    timer = Timer.periodic(Duration(milliseconds: TICK_MS), (timer) => tick());
    rebuildUi();
  }
}
