import 'package:flutter/material.dart';
import 'package:mirror_wall/models/connectivity_provider.dart';
import 'package:mirror_wall/models/webview_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserScreen extends StatefulWidget {
  @override
  _BrowserScreenState createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late InAppWebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    // Access lidhu che WebViewModel and ConnectivityProvider nu

    var webViewModel = Provider.of<WebViewModel>(context);
    var connectivityProvider = Provider.of<ConnectivityProvider>(context);

    _urlController.text = webViewModel.currentUrl;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: "Enter URL or search",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
          ),
          onSubmitted: (url) {
            _loadUrl(url, connectivityProvider);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              _loadUrl(_urlController.text, connectivityProvider);
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.black),
            onPressed: () {
              webViewModel.addBookmark(webViewModel.currentUrl);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bookmark added!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmarks, color: Colors.black),
            onPressed: () {
              _showBookmarksDialog(context, webViewModel.bookmarks);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              if (connectivityProvider.isConnected) {
                _controller.reload();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No internet connection!')),
                );
              }
            },
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(webViewModel.currentUrl)),
              onWebViewCreated: (InAppWebViewController controller) {
                _controller = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false;
                });
                webViewModel.setUrl(url.toString());
              },
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            label: 'Back',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward, color: Colors.black),
            label: 'Forward',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh, color: Colors.black),
            label: 'Refresh',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          switch (index) {
            case 0:
              String homeUrl = "https://www.google.com";
              webViewModel.setUrl(homeUrl);
              _controller.loadUrl(
                urlRequest: URLRequest(url: WebUri(homeUrl)),
              );
              break;
            case 1:
              _controller.goBack();
              break;
            case 2:
              _controller.goForward();
              break;
            case 3:
              if (connectivityProvider.isConnected) {
                _controller.reload();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No internet connection!')),
                );
              }
              break;
          }
        },
      ),
    );
  }

  void _loadUrl(String url, ConnectivityProvider connectivityProvider) {
    if (!url.startsWith("http")) {
      url = "https://www.google.com/search?q=$url";
    }
    if (connectivityProvider.isConnected) {
      Provider.of<WebViewModel>(context, listen: false).setUrl(url);
      _controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection!')),
      );
    }
  }

  void _showBookmarksDialog(BuildContext context, List<String> bookmarks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bookmarks'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bookmarks.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(bookmarks[index]),
                  onTap: () {
                    Provider.of<WebViewModel>(context, listen: false)
                        .setUrl(bookmarks[index]);
                    _controller.loadUrl(
                      urlRequest: URLRequest(url: WebUri(bookmarks[index])),
                    );
                    Navigator.of(context).pop();
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      Provider.of<WebViewModel>(context, listen: false)
                          .removeBookmark(bookmarks[index]);
                      Navigator.of(context).pop();
                      _showBookmarksDialog(context, bookmarks);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
