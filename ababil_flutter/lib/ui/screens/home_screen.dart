import 'dart:developer';

import 'package:ababil_flutter/ui/widgets/send_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:ababil_flutter/ui/viewmodels/home_view_model.dart';
import 'package:ababil_flutter/ui/widgets/sidebar.dart';
import 'package:ababil_flutter/ui/widgets/method_selector.dart';
import 'package:ababil_flutter/ui/widgets/tab_bar.dart';
import 'package:ababil_flutter/ui/widgets/headers_panel.dart';
import 'package:ababil_flutter/ui/widgets/body_panel.dart';
import 'package:ababil_flutter/ui/widgets/response_body_viewer.dart';
import 'package:ababil_flutter/ui/widgets/response_headers_viewer.dart';
import 'package:ababil_flutter/ui/widgets/add_header_dialog.dart';
import 'package:ababil_flutter/ui/widgets/resizable_column.dart';
import 'package:ababil_flutter/ui/widgets/resizable_sidebar.dart';
import 'package:ababil_flutter/ui/widgets/top_bar.dart';
import 'package:ababil_flutter/ui/widgets/params_panel.dart';
import 'package:ababil_flutter/ui/widgets/authorization_panel.dart';
import 'package:ababil_flutter/ui/widgets/response_tab_bar.dart';
import 'package:ababil_flutter/ui/viewmodels/collections_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  late final CollectionsViewModel _collectionsViewModel;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  int _requestTabIndex = 0;
  int _responseTabIndex = 0;
  final List<String> _responseTabs = [
    'Body',
    'Cookies',
    'Headers',
    'Test Results',
  ];

  final List<String> _sendDropDownItems = [
    'Send',
    'Send and download',
    // 'Send and Save to Collection',
  ];
  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _collectionsViewModel = CollectionsViewModel();
    // Connect view models for auto-sync
    _viewModel.setCollectionsViewModel(_collectionsViewModel);
    _viewModel.addListener(_onViewModelChanged);
    _collectionsViewModel.addListener(_onViewModelChanged);
    _urlController.text = _viewModel.url;
    _urlController.addListener(() => _viewModel.setUrl(_urlController.text));
    _bodyController.addListener(() => _viewModel.setBody(_bodyController.text));
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _collectionsViewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _collectionsViewModel.dispose();
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    // Update controllers when view model changes
    if (_urlController.text != _viewModel.url) {
      _urlController.text = _viewModel.url;
    }
    if (_bodyController.text != _viewModel.body) {
      _bodyController.text = _viewModel.body;
    }
    setState(() {});
  }

  // Future<void> _sendRequest() async {
  //   if (_viewModel.url.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Please enter a URL')));
  //     return;
  //   }

  //   await _viewModel.sendRequest();

  //   if (_viewModel.error != null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(_viewModel.error!)));
  //   }
  // }

  Future<void> _sendRequest({bool downloadJson = false}) async {
    if (_viewModel.url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a URL')));
      return;
    }

    await _viewModel.sendRequest(downloadJson: downloadJson);

    if (_viewModel.error != null) {
      log(_viewModel.error!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.error!)));
    }
  }

  Future<void> _showAddHeaderDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddHeaderDialog(),
    );

    if (result != null) {
      _viewModel.addHeader(result['key']!, result['value']!);
    }
  }

  Widget _buildRequestPanel() {
    return Column(
      children: [
        // Method selector and URL bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3D3D3D)
                    : Colors.grey.shade300,
              ),
            ),
          ),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3D3D3D)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Method selector button
                MethodSelector(
                  selectedMethod: _viewModel.selectedMethod,
                  onMethodChanged: _viewModel.setMethod,
                ),

                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3D3D3D)
                      : Colors.grey.shade300,
                ),
                // URL input field
                Expanded(
                  child: TextField(
                    // scrollPadding: EdgeInsets.zero,
                    textAlignVertical: TextAlignVertical.center,
                    controller: _urlController,
                    style: const TextStyle(fontSize: 14, height: 1),
                    maxLines: 1,
                    scrollPadding: EdgeInsets.zero,

                    decoration: InputDecoration(
                      hintText: 'Enter request URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                      ),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      // filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        // vertical: 20,
                      ),
                    ),
                  ),
                ),
                // Send button with dropdown
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _viewModel.isLoading ? null : _sendRequest,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  const Text(
                                    'Send',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withAlpha(128),
                      ),
                      SendDropdownItem(
                        items: _sendDropDownItems,
                        onSelected: (value) {
                          if (value != null) {
                            if (value.toLowerCase() == 'send') {
                              _sendRequest();
                            } else {
                              _sendRequest(downloadJson: true);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Request tabs
        CustomTabBar(
          tabs: _getRequestTabsWithCounts(),
          selectedIndex: _requestTabIndex,
          onTabChanged: (index) => setState(() => _requestTabIndex = index),
        ),
        // Request content
        Expanded(child: _buildRequestContent()),
      ],
    );
  }

  List<String> _getRequestTabs() {
    return [
      'Params',
      'Authorization',
      'Headers',
      'Body',
      'Scripts',
      'Settings',
    ];
  }

  List<String> _getRequestTabsWithCounts() {
    final tabs = _getRequestTabs();
    final result = <String>[];
    for (int i = 0; i < tabs.length; i++) {
      if (i == 0 && _viewModel.paramsMap.isNotEmpty) {
        // Params tab with count
        result.add('Params (${_viewModel.paramsMap.length})');
      } else if (i == 2 && _viewModel.headersMap.isNotEmpty) {
        // Headers tab with count
        result.add('Headers (${_viewModel.headersMap.length})');
      } else {
        result.add(tabs[i]);
      }
    }
    return result;
  }

  Widget _buildRequestContent() {
    switch (_requestTabIndex) {
      case 0: // Params
        return ParamsPanel(
          params: _viewModel.paramsMap,
          disabledParams: _viewModel.disabledParams,
          onAddParam: () {
            _viewModel.addParam('', '');
          },
          onRemoveParam: _viewModel.removeParam,
          onParamChanged: (param) {
            // Find the old key and update
            final oldKey = _viewModel.paramsMap.keys.firstWhere(
              (k) => _viewModel.paramsMap[k] == param.value,
              orElse: () => param.key,
            );
            _viewModel.updateParam(oldKey, param.key, param.value);
          },
          onToggleParamEnabled: _viewModel.toggleParamEnabled,
        );
      case 1: // Authorization
        return AuthorizationPanel(
          auth: _viewModel.auth,
          onAuthChanged: (auth) => _viewModel.setAuth(auth),
        );
      case 2: // Headers
        return HeadersPanel(
          headers: _viewModel.headersMap,
          disabledHeaders: _viewModel.disabledHeaders,
          onAddHeader: _showAddHeaderDialog,
          onRemoveHeader: _viewModel.removeHeader,
          onHeaderChanged: (entry) {
            _viewModel.addHeader(entry.key, entry.value);
          },
          onToggleHeaderEnabled: _viewModel.toggleHeaderEnabled,
        );
      case 3: // Body
        if (_viewModel.selectedMethod == 'GET' ||
            _viewModel.selectedMethod == 'HEAD' ||
            _viewModel.selectedMethod == 'OPTIONS') {
          return const Center(
            child: Text('Body not available for this method'),
          );
        }
        return BodyPanel(controller: _bodyController);
      case 4: // Scripts
        return const Center(child: Text('Scripts - Coming soon'));
      case 5: // Settings
        return const Center(child: Text('Settings - Coming soon'));
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }

  Widget _buildResponsePanel() {
    if (_viewModel.response == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.api_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'No response yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Send a request to see the response here',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    final responseSize = _viewModel.response!.body.length;

    return Column(
      children: [
        ResponseTabBar(
          tabs: _getResponseTabsWithCounts(),
          selectedIndex: _responseTabIndex,
          onTabChanged: (index) => setState(() => _responseTabIndex = index),
          statusCode: _viewModel.response!.statusCode,
          durationMs: _viewModel.response!.durationMs,
          responseSize: responseSize,
        ),
        Expanded(child: _buildResponseContent()),
      ],
    );
  }

  List<String> _getResponseTabsWithCounts() {
    if (_viewModel.response == null) return _responseTabs;
    final tabs = List<String>.from(_responseTabs);
    if (_viewModel.response!.headers.isNotEmpty) {
      tabs[2] = 'Headers (${_viewModel.response!.headers.length})';
    }
    return tabs;
  }

  Widget _buildResponseContent() {
    switch (_responseTabIndex) {
      case 0: // Body
        return ResponseBodyViewer(
          body: _viewModel.response!.body,
          headers: _viewModel.response!.headers,
        );
      case 1: // Cookies
        return const Center(child: Text('Cookies - Coming soon'));
      case 2: // Headers
        return ResponseHeadersViewer(headers: _viewModel.response!.headers);
      case 3: // Test Results
        return const Center(child: Text('Test Results - Coming soon'));
      default:
        return ResponseBodyViewer(
          body: _viewModel.response!.body,
          headers: _viewModel.response!.headers,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              children: [
                ResizableSidebar(
                  initialWidth: 240,
                  minWidth: 180,
                  maxWidth: 400,
                  child: Sidebar(
                    collectionsViewModel: _collectionsViewModel,
                    homeViewModel: _viewModel,
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: ResizableColumn(
                      initialTopHeight: 400,
                      minTopHeight: 200,
                      minBottomHeight: 200,
                      topChild: _buildRequestPanel(),
                      bottomChild: _buildResponsePanel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
