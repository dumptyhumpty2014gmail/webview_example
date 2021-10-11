import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_example/widgets/luchshij_obzor2/luchshij_obzor2.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LuchshijObzorPage extends StatefulWidget {
  const LuchshijObzorPage({Key? key}) : super(key: key);

  @override
  State<LuchshijObzorPage> createState() => _LuchshijObzorPageState();
}

class _LuchshijObzorPageState extends State<LuchshijObzorPage> {
  WebViewController? _controller;
  bool isHtmlLoaded = false;
  bool _isError = false;
  Timer? _timer;
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
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 10), () {
      setState(() {
        print('Timeout');
        _isError = true;
        isHtmlLoaded = true;
      });
    });
  }

  void reloadUrl() {
    if (_controller != null) {
      setBeforeStart();
      _controller!.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пример: Лучший обзор'),
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
                      builder: (context) => const LuchshijObzorPage2()),
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
                  child: Text('Вторая страница'),
                  value: 'secondPage',
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Сайт "Лучший обзор"', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Stack(children: [
                  WebView(
                    initialUrl:
                        'https://luchshij-obzor.ru/webview-flutter/', //'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webviewController) {
                      print('Страница создана');
                      _controller = webviewController;
                      //через 10 секунд показываем ошибку и кнопку перезагрузки
                      setBeforeStart();
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
                      if (_timer != null && _timer!.isActive) {
                        _timer!.cancel();
                      }
                      if (!_isError) {
                        setState(() {
                          //загрузка страницы так или иначе завершена
                          isHtmlLoaded = true;
                        });
                      }

                      //_controller!.getTitle(); можно по title пытаться определять, успешная ли загрузка
                    },
                    onProgress: (int progress) {
                      print('Загружено ${progress.toString()}%');
                      //можно попытаться выводить линейный прогрессбар, но проценты скачут
                    },
                    onWebResourceError: (error) {
                      print(error.description);
                      if (_timer != null && _timer!.isActive) {
                        _timer!.cancel();
                      }
                      setState(() {
                        //какая-то ошибка, прячем webview
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
