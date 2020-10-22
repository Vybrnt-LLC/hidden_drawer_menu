import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:hidden_drawer_menu/menu/hidden_menu_widget.dart';
import 'package:hidden_drawer_menu/model/item_hidden_menu.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/animated_drawer_content.dart';
import 'package:vybrnt_mvp/core/routes/router.gr.dart' as route;
import 'package:vybrnt_mvp/features/authentication/application/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybrnt_mvp/core/swipe_menu/widgets/simple_hidden_drawer_provider.dart';
import 'package:auto_route/auto_route.dart';

class HiddenMenu extends StatefulWidget {
  /// Decocator that allows us to add backgroud in the menu(img)
  final DecorationImage background;

  /// that allows us to add shadow above menu items
  final bool enableShadowItensMenu;

  /// that allows us to add backgroud in the menu(color)
  final Color backgroundColorMenu;

  /// Items of the menu
  final List<ItemHiddenMenu> itens;

  /// Callback to recive item selected for user
  final Function(int) selectedListern;

  /// position to set initial item selected in menu
  final int initPositionSelected;

  final TypeOpen typeOpen;

  HiddenMenu(
      {Key key,
      this.background,
      this.itens,
      this.selectedListern,
      this.initPositionSelected,
      this.backgroundColorMenu,
      this.enableShadowItensMenu = false,
      this.typeOpen = TypeOpen.FROM_LEFT})
      : super(key: key);

  @override
  _HiddenMenuState createState() => _HiddenMenuState();
}

class _HiddenMenuState extends State<HiddenMenu> {
  int _indexSelected;
  SimpleHiddenDrawerController controller;

  @override
  void initState() {
    _indexSelected = widget.initPositionSelected;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    controller = SimpleHiddenDrawerController.of(context);
    controller.addListener(_listenerController);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.removeListener(_listenerController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeMap(
          unauthenticated: (_) =>
              //ExtendedNavigator.of(context);
              context.navigator.replace(route.Routes.signInPage),
          orElse: () {},
        );
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: widget.background,
            color: widget.backgroundColorMenu,
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
              decoration: BoxDecoration(
                boxShadow: widget.enableShadowItensMenu
                    ? [
                        new BoxShadow(
                          color: const Color(0x44000000),
                          offset: const Offset(0.0, 5.0),
                          blurRadius: 50.0,
                          spreadRadius: 30.0,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0.0),
                    itemCount: widget.itens.length,
                    itemBuilder: (context, index) {
                      return HiddenMenuWidget(
                        name: widget.itens[index].name,
                        selected: index == _indexSelected,
                        colorLineSelected:
                            widget.itens[index].colorLineSelected,
                        baseStyle: widget.itens[index].baseStyle,
                        selectedStyle: widget.itens[index].selectedStyle,
                        typeOpen: widget.typeOpen,
                        onTap: () {
                          if (widget.itens[index].onTap != null) {
                            widget.itens[index].onTap();
                          }
                          controller.setSelectedMenuPosition(index);
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 150, 0),
                    child: FlatButton(
                      child: Row(children: [
                        Icon(Icons.power_settings_new),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Sign Out')
                      ]),
                      color: Colors.red,
                      onPressed: () {
                        context
                            .bloc<AuthBloc>()
                            .add(const AuthEvent.signedOut());
                      },
                    ),
                  ),
                  //SizedBox.expand(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listenerController() {
    setState(() {
      _indexSelected = controller.position;
    });
  }
}
