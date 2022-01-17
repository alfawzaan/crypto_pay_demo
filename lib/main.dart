import 'package:crypto_pay_demo/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
  final ethAddress = "0x42B4c97C74Fe32A6c8De07fbfc6635E62bA37800";
  final hostAdd =
      "https://rinkeby.infura.io/v3/1b14411504784841a66f647f8b48e2ac";

  Client? httpClient;
  Web3Client? ethClient;
  double balance = 0;
  TextEditingController textEditingController = TextEditingController();
  bool processing = true;

  @override
  void initState() {
    super.initState();

    httpClient = Client();
    ethClient = Web3Client(hostAdd, httpClient!);
    getBalance();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.white60,
        child: Stack(
          children: [
            Positioned(
                height: getHeight(context, ratio: 0.3),
                width: getWidth(context),
                child: Container(
                  color: Colors.blue,
                  padding:
                      EdgeInsets.only(bottom: getHeight(context, ratio: 0.1)),
                  child: Center(
                    child: Text(
                      "RashCoin",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: getWidth(context, ratio: 0.08)),
                    ),
                  ),
                )),
            Positioned(
                // height: getHeight(context),
                top: getHeight(context, ratio: 0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: getWidth(context),
                      height: getHeight(context, ratio: 0.27),
                      child: customDeco(
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Balance",
                                  style: TextStyle(
                                      fontSize: getWidth(context, ratio: 0.06)),
                                ),
                                Text(
                                  "\$$balance",
                                  style: TextStyle(
                                      fontSize: getWidth(context, ratio: 0.09),
                                      fontWeight: FontWeight.bold),
                                ),
                                processing
                                    ? CircularProgressIndicator()
                                    : Container()
                              ],
                            ),
                          ),
                          Colors.white,
                          getWidth(context, ratio: 0.05)),
                    ),
                    SizedBox(
                      width: getWidth(context),
                      child: customDeco(
                          Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 3),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: "0.00", border: InputBorder.none),
                                style: TextStyle(
                                    fontSize: getWidth(context, ratio: 0.05)),
                                controller: textEditingController,
                              )),
                          Colors.white,
                          getWidth(context, ratio: 0.1)),
                    ),
                    const Text("Please refresh within 10 sec after transaction",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        GestureDetector(
                          child: customDeco(
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getWidth(context, ratio: 0.03)),
                                  child: Row(children: const [
                                    Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    Text("Refresh",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))
                                  ])),
                              Colors.blue,
                              getWidth(context, ratio: 0.03)),
                          onTap: () async {
                            setState(() {
                              processing = true;
                            });
                            await getBalance();

                            setState(() {
                              processing = false;
                            });
                          },
                        ),
                        GestureDetector(
                            child: customDeco(
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getWidth(context, ratio: 0.03)),
                                  child: Row(children: const [
                                    Icon(
                                      Icons.call_received_outlined,
                                      color: Colors.white,
                                    ),
                                    Text("Deposit",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))
                                  ]),
                                ),
                                Colors.green,
                                getWidth(context, ratio: 0.1)),
                            onTap: () async {
                              setState(() {
                                processing = true;
                              });
                              await receiveCoin();

                              setState(() {
                                processing = false;
                              });
                            }),
                        GestureDetector(
                            child: customDeco(
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getWidth(context, ratio: 0.03)),
                                  child: Row(children: const [
                                    Icon(
                                      Icons.call_made_outlined,
                                      color: Colors.white,
                                    ),
                                    Text("Withdrawal",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))
                                  ]),
                                ),
                                Colors.red,
                                getWidth(context, ratio: 0.1)),
                            onTap: () async {
                              setState(() {
                                processing = true;
                              });
                              await sendCoin();

                              setState(() {
                                processing = false;
                              });
                            }),
                      ],
                    )
                  ],
                )),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> getBalance() async {
    List<dynamic> data = await callFunction("getBalance", []);
    setState(() {
      debugPrint("${data[0]}");
      balance = (data[0] as BigInt).toDouble();
      processing = false;
    });
  }

  Future<String> submitTransaction(
      String funcName, List<dynamic> params) async {
    EthPrivateKey privateKey = EthPrivateKey.fromHex(
        "a1013d31b7d957ec0a6caa7fb3aa50d6f0f8cdd50afe662fc17d381c2e718cb5");
    DeployedContract contract = await loadContract();
    ContractFunction function = contract.function(funcName);
    final result = await ethClient?.sendTransaction(
        privateKey,
        Transaction.callContract(
            contract: contract, function: function, parameters: params),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    return result!;
  }

  Future<void> sendCoin() async {
    try {
      final val = textEditingController.text;
      BigInt.from(int.parse(val));
      final response = await submitTransaction(
          "withdrawAmount", [BigInt.from(int.parse(val))]);
      debugPrint(response);
    } catch (e, str) {
      debugPrint("$str");
      debugPrint("Something Went Wrong $e");
    }
  }

  Future<void> receiveCoin() async {
    final val = textEditingController.text;
    try {
      BigInt.from(int.parse(val));
      final response = await submitTransaction(
          "depositAmount", [BigInt.from(int.parse(val))]);
      debugPrint(response);
    } catch (e, str) {
      debugPrint("$str");
      debugPrint("Something Went Wrong $e");
    }
  }

  Future<DeployedContract> loadContract() async {
    var abiString = await rootBundle.loadString("assets/abi.json");
    var contract = DeployedContract(ContractAbi.fromJson(abiString, "RashCoin"),
        EthereumAddress.fromHex("0x670F41A880d1Eab1C6E1764C61aC01eAfFC408E5"));
    return contract;
  }

  Future<List<dynamic>> callFunction(
      String functionName, List<dynamic> params) async {
    DeployedContract contract = await loadContract();
    ContractFunction funct = contract.function(functionName);
    List<dynamic>? result = await ethClient?.call(
        contract: contract, function: funct, params: params);
    return result!;
  }
}
