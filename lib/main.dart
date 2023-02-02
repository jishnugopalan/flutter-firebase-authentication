import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home:LoginPage()
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name="",email="",phone="",password="";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool issigned = false;

  Future<void> signUp() async {
    if(_formKey.currentState!.validate()){
      print(name);
      print(email);

      print(phone);
      print(password);
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
        );
        print("Login successfull");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showError("The password provided is too weak");
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          showError("The account already exists for that email");
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }

    }

  }
  logout(){

  }
  showError(String errorMsg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
  getUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    await firebaseUser?.reload();

    if (firebaseUser != null) {
    setState(() {
    issigned = true;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        DashBoard()), (Route<dynamic> route) => false);

    });
    }
    else{
    print("Nouser");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),

      ),
      body:  Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: ListView(
          children: [
            Form(
              key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Name"
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Name is required";

                        }
                        setState(() {
                          name=value;
                        });
                        return null;

                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Email"
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        setState(() {
                          email=value!;
                        });

                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Phone"
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        setState(() {
                          phone=value!;
                        });

                      },
                    ),

                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Password"
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        setState(() {
                          password=value!;
                        });

                      },
                    ),
                  ),
                  ElevatedButton(
                    child: const Text("Submit"),
                    onPressed: signUp
                  )


              ],
            ))
          ],
        )
      ),
    );
  }
}

//login
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name="",email="",phone="",password="";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool issigned=false;
  logIn() async {
    if(_formKey.currentState!.validate()){
      try {
        UserCredential user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            DashBoard()), (Route<dynamic> route) => false);


      }on FirebaseAuthException catch (e) {
        showError(e.message.toString());
        print(e.code);
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }

  }
  showError(String errorMsg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
  getUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    await firebaseUser?.reload();

    if (firebaseUser != null) {
      setState(() {
        issigned = true;
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            DashBoard()), (Route<dynamic> route) => false);

      });
    }

  }
  signInWithGoogle() async {
    await GoogleSignIn().signOut();
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    await GoogleSignIn().signIn().then((value) async {
      final GoogleSignInAuthentication? googleAuth = await value?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      FirebaseAuth.instance.signInWithCredential(credential);

      print(FirebaseAuth.instance.currentUser);
      this.getUser();

    });




    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Email"
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        setState(() {
                          email=value!;
                        });

                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Password"
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        setState(() {
                          password=value!;
                        });

                      },
                    ),
                  ),
                  ElevatedButton(
                      child: const Text("Submit"),
                      onPressed: logIn
                  ),
                  TextButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        HomePage()));

                  }, child: Text("Register")),
                  TextButton(onPressed: signInWithGoogle, child: Text("Sign in with Google"))

                ],

          ))
        ],
      ),
    );
  }
}



//dashboard
class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        HomePage()), (Route<dynamic> route) => false);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),

      ),
      body: Container(
        child: ElevatedButton(
          child: Text("Logout"),
          onPressed: logout,
        ),
      ),
    );
  }
}



