import 'package:flutter/material.dart';
import 'package:game_of_life_starter_code/app/constants.dart';
import 'package:game_of_life_starter_code/views/home/home_viewmodel.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  Widget builder(
          BuildContext context, HomeViewModel viewModel, Widget? child) =>
      Scaffold(
        appBar: AppBar(
          title: Text('Generation: ${viewModel.generation}'),
        ),
        body: viewModel.isBusy
            ? CircularProgressIndicator()
            : GridView.count(
                crossAxisCount: viewModel.columns,
                children:
                    List.generate(viewModel.rows * viewModel.columns, (index) {
                  int row = index ~/ viewModel.columns;
                  int column = index % viewModel.columns;
                  return Container(
                    decoration: BoxDecoration(
                      color: viewModel.grid[row][column] == ALIVE
                          ? Colors.black
                          : Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.1),
                    ),
                  );
                }),
              ),
        persistentFooterButtons: [
          FloatingActionButton(
            onPressed: () => viewModel.promptUserInput(context),
            child: Icon(
              Icons.rectangle_outlined,
            ),
          ),
          FloatingActionButton(
            onPressed: viewModel.restart,
            child: Icon(
              Icons.restart_alt,
            ),
          ),
          FloatingActionButton(
            onPressed:
                viewModel.timer.isActive ? viewModel.pause : viewModel.resume,
            child:
                Icon(viewModel.timer.isActive ? Icons.pause : Icons.play_arrow),
          ),
        ],
      );
}
