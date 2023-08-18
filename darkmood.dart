import 'package:davaocityvet/adminpage.dart';
import 'package:davaocityvet/chatsupport.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DarkModeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Setting',
            theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),
            Text('Dark Mode'),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                // Add the route you want to navigate to when the chat icon is clicked
                // For example, you can replace 'ChatPage()' with your desired page.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupChat()),
                );
              },
            ),
            Text('General Group Chat')
          ],
        ),
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

