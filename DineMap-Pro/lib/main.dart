import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'registration/login_page.dart';
import 'utils/db.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/user/user_cubit.dart';
import 'cubits/navigation/navigation_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initialize(); // Initialize database helper
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StoreCubit>(create: (_) => StoreCubit()),
        BlocProvider<UserCubit>(create: (_) => UserCubit()),
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
      ],
      child: MaterialApp(
        title: 'Store Finder',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}