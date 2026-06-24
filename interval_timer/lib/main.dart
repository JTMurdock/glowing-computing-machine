import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

enum homepageView { start, timeSelect, countdownTimer }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Rest Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Rest Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double selectedRestSeconds = 15;
  final List<double> timeList = [15, 30, 45, 60, 75, 90, 105, 120, 135];
  Timer? _timer;
  double timeLeft = 30.0;
  bool isTimerRunning = false;
  homepageView currentView = homepageView.start;

  void countdown() {
    if (isTimerRunning && timeLeft > 0) {
      setState(() {
        timeLeft--;
      });
    } else {
      isTimerRunning = false;
    }
  }

  void startTimer() {
    _timer?.cancel();
    setState(() {
      if (!isTimerRunning) {
        isTimerRunning = true;
        countdown();
      } else {
        isTimerRunning = false;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown();
    });
  }

  void restartTimer() {
    _timer?.cancel();
    setState(() {
      timeLeft = selectedRestSeconds;
      isTimerRunning = false;
    });
  }

  void cancelTimer() {
    setState(() {
      _timer?.cancel();
      isTimerRunning = false;
      currentView = homepageView.timeSelect;
    });
  }

  Future<void> customTimer() async{
    final TextEditingController minuteController = TextEditingController();
    final TextEditingController secondController = TextEditingController();
    final customTime = await showDialog<int>(context: context,
    builder: (context){
      final int customTime = 0;
      return AlertDialog(
        title: Text("Enter rest time:"),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: minuteController,
                textAlign: TextAlign.right,
              ),
            ),
            Text(":"),
            Expanded(
              child: TextField(
                controller: secondController,
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: (){
              final minutes = int.tryParse(minuteController.text);
              final seconds = int.tryParse(secondController.text);
              if (minutes != null && seconds != null){
                Navigator.pop(context, ((minutes * 60) + seconds));
              }
            },
            child: Text("Save")),
          TextButton(
            onPressed: (){Navigator.pop(context);},
            child: Text("Cancel"))
        ],
    
      );
      }
    );
    if (customTime == null){
        return;
      }
    selectedRestSeconds = customTime.toDouble();
    timeLeft = selectedRestSeconds;
    startTimer();
    setState(() {
      currentView = homepageView.countdownTimer;
    });
  }

  void handleTimeout() {
    currentView = homepageView.timeSelect;
  }

  String secondsToMinutes(double time) {
    int minutes = (time / 60).toInt();
    int seconds = (time % 60).toInt();

    return ("$minutes:${seconds.toString().padLeft(2, '0')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (currentView) {
        homepageView.start => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(75.0),
                ),
                onPressed: () {
                  setState(() {
                    currentView = homepageView.timeSelect;
                  });
                },
                tooltip: "Starts a new timer",
                label: Text(
                  "Start a new timer",
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),

        homepageView.timeSelect => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Select rest time", style: TextStyle(fontSize: 25)),
            ),
            Text("Choose a preset or customize your own time",
              style: TextStyle(
                color: Colors.grey,
              
              ),
            ),
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.10],
                    colors: [Colors.transparent, Colors.white],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    itemCount: timeList.length + 1,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0){
                        return Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            onTap: customTimer, 
                            leading: Icon(Icons.access_alarm, color: Colors.indigo,),
                          title: Text(
                            "Custom time",
                            textAlign: TextAlign.center,
                          ),
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          ),
                        );
                      }

                      final double seconds = timeList[index - 1];
                      return Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          onTap: () {
                            selectedRestSeconds = seconds;
                            setState(() {
                              currentView = homepageView.countdownTimer;
                              timeLeft = selectedRestSeconds;
                            });
                          },
                          leading: Icon(Icons.access_alarm, color: Colors.indigo,),
                          title: Text(
                            secondsToMinutes(seconds),
                            textAlign: TextAlign.center,
                          ),
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          minVerticalPadding: 10.0,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        homepageView.countdownTimer => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 280.0,
                height: 280.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 25.0),
                        Text(
                          secondsToMinutes(timeLeft),
                          style: TextStyle(fontSize: 60.0),
                        ),
                        Icon(Icons.fitness_center, size: 40.0),
                      ],
                    ),
                    SizedBox(
                      height: 280,
                      width: 280,
                      child: CircularProgressIndicator(
                        value: (timeLeft / selectedRestSeconds),
                        strokeWidth: 8.0,
                        color: Colors.indigo,
                        backgroundColor: const Color.fromARGB(
                          255,
                          228,
                          225,
                          225,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 50.0,
                      onPressed: startTimer,
                      icon: Icon(
                        isTimerRunning ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    IconButton(
                      iconSize: 50.0,
                      onPressed: restartTimer,
                      icon: Icon(Icons.repeat),
                    ),
                    SizedBox(width: 10.0),
                    IconButton(
                      iconSize: 50.0,
                      onPressed: cancelTimer,
                      icon: Icon(Icons.cancel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      },
    );
  }
}
