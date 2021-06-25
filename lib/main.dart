import 'package:flutter/material.dart';
import 'package:mlkit/pages/home_page.dart';
import 'package:mlkit/pages/sigin_page.dart';
import 'package:mlkit/providers/auth_provider.dart';
import 'package:provider/provider.dart';

//Modulo para inicializar la app en Firebase
import 'package:firebase_core/firebase_core.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Notifica a todos los widget hijos de los cambios de estados de auth
    return ChangeNotifierProvider(
      create: (BuildContext context) => AuthProvider.instance(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {

        },
        title: 'ML Kit',
        home: Consumer(
          builder: (BuildContext context,AuthProvider authProvider,_) {
            Widget w;
            switch (authProvider.status) {
              case AuthStatus.Uninitialized:
                w = Text('Cargando...');
                break;
              case AuthStatus.Authenticated:
                w = HomePage();
                break;
              case AuthStatus.Authenticating:
                w = SignInPage();
                break;
              case AuthStatus.Unauthenticated:
                w = SignInPage();
                break;
              default:
                w = Text("Widget no encontrado..."); 
            }
            return w;
          },      
        ),
      ),
    ); 
  }
}