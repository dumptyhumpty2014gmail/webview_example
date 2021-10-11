import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/widgets/luchshij_obzor/luchshij_obzor.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LuchshijObzorPage2 extends StatefulWidget {
  const LuchshijObzorPage2({Key? key}) : super(key: key);

  @override
  State<LuchshijObzorPage2> createState() => _LuchshijObzorPage2State();
}

class _LuchshijObzorPage2State extends State<LuchshijObzorPage2> {
  WebViewController? _controller;
  bool isHtmlLoaded = false;
  bool _isError = false;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //Можно какие-то сообщения выводить, если получили ошибку
      throw 'Could not launch $url';
    }
  }

  void setBeforeStart() {
    setState(() {
      isHtmlLoaded = false;
      _isError = false;
    });
    // _timer?.cancel();
    // _timer = Timer(const Duration(seconds: 10), () {
    //   setState(() {
    //     print('Timeout');
    //     _isError = true;
    //     isHtmlLoaded = true;
    //   });
    // });
  }

  void reloadUrl() {
    if (_controller != null) {
      setBeforeStart();
      _controller!.reload();
    }
  }

  void _loadUrl() {
    _controller!
        .loadUrl('https://luchshij-obzor.ru/karta-sajta/')
        .timeout(const Duration(milliseconds: 10), onTimeout: () {
      setState(() {
        print('Timeout');
        _isError = true;
        isHtmlLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пример 2'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == 'reload') {
                reloadUrl();
              }
              if (choice == 'secondPage') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LuchshijObzorPage()),
                );
              }
            },
            color: Colors.indigo,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  child: Text('Обновить'),
                  value: 'reload',
                ),
                const PopupMenuItem(
                  child: Text('Первая страница'),
                  value: 'secondPage',
                ),
              ];
            },
          ),
        ], // [
      ),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Сайт "Лучший обзор"', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Stack(children: [
                  WebView(
                    // initialUrl:
                    //     'https://luchshij-obzor.ru/novye-obzory/', //'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webviewController) {
                      print('Страница создана');
                      _controller = webviewController;
                      setBeforeStart();
                      _loadUrl();
                    },
                    navigationDelegate: (NavigationRequest request) {
                      if (request.url.startsWith('tel') ||
                          request.url.startsWith('https:') ||
                          request.url.startsWith('http:')) {
                        launchURL(request.url);
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                    onPageStarted: (String url) {
                      print('Старт загрузки');
                    },
                    onPageFinished: (String url) {
                      print('Загрузка завершена');
                      if (!_isError) {
                        setState(() {
                          isHtmlLoaded = true;
                        });
                      }
                    },
                    onProgress: (int progress) {
                      print('Загружено ${progress.toString()}%');
                    },
                    onWebResourceError: (error) {
                      print(error.description);
                      setState(() {
                        _isError = true;
                      });
                    },
                  ),
                  if (_isError || !isHtmlLoaded)
                    Center(
                        child: Container(
                      color: Colors.grey,
                      width: double.infinity,
                      height: double.infinity,
                    )),
                  if (!isHtmlLoaded && !_isError)
                    const Center(child: CircularProgressIndicator()),
                  if (!isHtmlLoaded && !_isError)
                    const Center(child: Text('Формируем...')),
                  if (_isError)
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Произошла ошибка загрузки формы поиска... Попробуйте позже.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                              onPressed: reloadUrl,
                              child: const Text('Проверить'))
                        ],
                      ),
                    ),
                ]),
              ),
            ]),
      ),
    );
  }
}
