import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

enum homepageView{
    start,
    timeSelect,
    countdownTimer
  }

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Rest Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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

    void countdown(){
      if(isTimerRunning && timeLeft > 0){
        setState(() {
          timeLeft--;
        });
      }
      else{
        isTimerRunning = false;
      }
    }
  
  void startTimer() {
    _timer?.cancel();
    setState((){
      if (!isTimerRunning){
      isTimerRunning = true;
      countdown();
      }
      else{
        isTimerRunning = false;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer){
    countdown();
    });
  }

  void handleTimeout(){
    currentView = homepageView.timeSelect;
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: switch(currentView){
              homepageView.start => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(75.0)),
                    onPressed: (){
                      setState((){currentView = homepageView.timeSelect;});
                      },
                    tooltip: "Starts a new timer",
                    label: Text("Start a new timer",
                      style: TextStyle(
                        color: Colors.black
                      )
                    ),
                    backgroundColor: Colors.white,
                  )
                ],
              ),
              ),
                    homepageView.timeSelect => Center(child: 
                    Column(
            children: [
              Stack(
                children:[
                  SizedBox(
                    height: 40,
                    child: Container(
                      color: Colors.white,
                      ),
                    
                  ),
                  const Text(
                    "Please select desired rest time",
                    style: TextStyle(
                    fontSize: 24,
                ),
              ),
                ]
               ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: timeList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index){
                    final double seconds = timeList[index];
                    return ListTile(
                      onTap: (){
                        selectedRestSeconds = seconds;
                        setState(() {
                          currentView = homepageView.countdownTimer;
                          timeLeft = selectedRestSeconds;
                        });
                        },
                      leading: Icon(Icons.access_alarm),
                      title: Text(
                        seconds.toString(),
                        textAlign: TextAlign.center,
                      ),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: Colors.grey,
                          width: 2.0
                        )
                      ),
                      minVerticalPadding: 10.0,
                      
                    );
                  }
                )
              ),
            ],
                    )
                    ),
                homepageView.countdownTimer => Center(
                    child: Column(
                      children: [ 
                        SizedBox( 
                          width: 280.0,
                          height: 280.0,
                          child: 
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(timeLeft.toString()),
                                SizedBox(
                                  height: 280,
                                  width: 280,
                                  child: CircularProgressIndicator(
                                  value: (timeLeft / selectedRestSeconds),
                                )
                                )
                              ]
                            )
                        ),
                        IconButton(
                          onPressed: startTimer,
                          icon: Icon(isTimerRunning ? Icons.pause : Icons.play_arrow),
                        ),
                      ],
                    )
                  )
                },
          )
        );
  }
}