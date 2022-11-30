part of auth_card_builder;

class LandingCard extends StatefulWidget {
  const LandingCard({
    Key? key,
    required this.loadingController,
    this.enableAnonAuth = false,
    this.hideProvidersTitle = false,
    this.onSubmitCompleted,
    this.onSignInWithEmail,
    this.onSignInWithPhone,
  }) : super(key: key);

  final AnimationController loadingController;
  final Function? onSignInWithEmail;
  final Function? onSignInWithPhone;
  final Function? onSubmitCompleted;
  final bool enableAnonAuth;
  final bool hideProvidersTitle;

  @override
  State<LandingCard> createState() => _LandingCardState();
}

class _LandingCardState extends State<LandingCard>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _showShadow = true;

  late Animation<double> _buttonScaleAnimation;

  ///list of AnimationController each one responsible for a authentication provider icon
  List<AnimationController> _providerControllerList = <AnimationController>[];

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);

    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: widget.loadingController,
      curve: const Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));

    _providerControllerList = auth.loginProviders
        .map(
          (e) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1000),
          ),
        )
        .toList();
  }

  Widget _buildProvidersLogInButton(ThemeData theme, LoginMessages messages,
      Auth auth, LoginTheme loginTheme) {
    var buttonProvidersList = <LoginProvider>[];
    var iconProvidersList = <LoginProvider>[];
    for (var loginProvider in auth.loginProviders) {
      if (loginProvider.button != null) {
        buttonProvidersList.add(LoginProvider(
          icon: loginProvider.icon,
          label: loginProvider.label,
          button: loginProvider.button,
          callback: loginProvider.callback,
        ));
      } else if (loginProvider.icon != null) {
        iconProvidersList.add(LoginProvider(
          icon: loginProvider.icon,
          label: loginProvider.label,
          button: loginProvider.button,
          callback: loginProvider.callback,
        ));
      }
    }
    if (buttonProvidersList.isNotEmpty) {
      return Column(
        children: [
          _buildButtonColumn(theme, messages, buttonProvidersList, loginTheme),
          iconProvidersList.isNotEmpty
              ? _buildProvidersTitleSecond(messages)
              : Container(),
          _buildIconRow(theme, messages, iconProvidersList, loginTheme),
        ],
      );
    } else if (iconProvidersList.isNotEmpty) {
      return _buildIconRow(theme, messages, iconProvidersList, loginTheme);
    }
    return Container();
  }

  Widget _buildButtonColumn(ThemeData theme, LoginMessages messages,
      List<LoginProvider> buttonProvidersList, LoginTheme loginTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttonProvidersList.map((loginProvider) {
        return Padding(
          padding: loginTheme.providerButtonPadding ??
              const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: ScaleTransition(
            scale: _buttonScaleAnimation,
            child: SignInButton(
              loginProvider.button!,
              onPressed: () => _loginProviderSubmit(
                loginProvider: loginProvider,
              ),
              text: loginProvider.label,
            ),
            // child: loginProvider.button,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconRow(ThemeData theme, LoginMessages messages,
      List<LoginProvider> iconProvidersList, LoginTheme loginTheme) {
    return Wrap(
      children: iconProvidersList.map((loginProvider) {
        var index = iconProvidersList.indexOf(loginProvider);
        return Padding(
          padding: loginTheme.providerButtonPadding ??
              const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: ScaleTransition(
              scale: _buttonScaleAnimation,
              child: Column(
                children: [
                  AnimatedIconButton(
                    icon: loginProvider.icon!,
                    controller: _providerControllerList[index],
                    tooltip: loginProvider.label,
                    onPressed: () => _loginProviderSubmit(
                      control: _providerControllerList[index],
                      loginProvider: loginProvider,
                    ),
                  ),
                  Text(loginProvider.label)
                ],
              )),
        );
      }).toList(),
    );
  }

  Widget _buildProvidersTitleFirst(LoginMessages messages) {
    return ScaleTransition(
        scale: _buttonScaleAnimation,
        child: Row(children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(messages.providersTitleFirst),
          ),
          const Expanded(child: Divider()),
        ]));
  }

  Widget _buildProvidersTitleSecond(LoginMessages messages) {
    return ScaleTransition(
        scale: _buttonScaleAnimation,
        child: Row(children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(messages.providersTitleSecond),
          ),
          const Expanded(child: Divider()),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isLogin = auth.isLogin;
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final loginTheme = Provider.of<LoginTheme>(context, listen: false);
    final theme = Theme.of(context);
    final cardWidth = min(MediaQuery.of(context).size.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final authForm = Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: cardPadding,
              right: cardPadding,
              top: cardPadding + 10,
            ),
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: Paddings.fromRBL(cardPadding),
                  width: cardWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: loginTheme.providerButtonPadding ??
                            const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 8.0),
                        child: ScaleTransition(
                          scale: _buttonScaleAnimation,
                          child: MaterialButton(
                            key: const ValueKey('Phone'),
                            height: 36,
                            elevation: 2.0,
                            padding: const EdgeInsets.all(0),
                            color: const Color(0xFFFFFFFF),
                            onPressed: () => widget.onSignInWithPhone?.call(),
                            splashColor: Colors.white30,
                            highlightColor: Colors.white30,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 220,
                              ),
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 13,
                                      ),
                                      child: Icon(
                                        Icons.phone,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Sign in with Phone',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        backgroundColor:
                                            Color.fromRGBO(0, 0, 0, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            shape: ButtonTheme.of(context).shape,
                          ),
                          // child: loginProvider.button,
                        ),
                      ),
                      Padding(
                        padding: loginTheme.providerButtonPadding ??
                            const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 8.0),
                        child: ScaleTransition(
                          scale: _buttonScaleAnimation,
                          child: SignInButton(
                            Buttons.Email,
                            onPressed: () => widget.onSignInWithEmail?.call(),
                          ),
                          // child: loginProvider.button,
                        ),
                      ),
                      auth.loginProviders.isNotEmpty &&
                              !widget.hideProvidersTitle
                          ? _buildProvidersTitleFirst(messages)
                          : Container(),
                      _buildProvidersLogInButton(
                          theme, messages, auth, loginTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: Paddings.fromRBL(cardPadding),
            width: cardWidth,
            child: Column(
              children: <Widget>[
                if (widget.enableAnonAuth)
                  _buildAnonAuthButton(theme, messages, auth),
              ],
            ),
          ),
        ],
      ),
    );

    return FittedBox(
      child: Card(
        elevation: _showShadow ? theme.cardTheme.elevation : 0,
        child: authForm,
      ),
    );
  }

  Widget _buildAnonAuthButton(
      ThemeData theme, LoginMessages messages, Auth auth) {
    final theme = Theme.of(context);
    final fontSize = theme.textTheme.bodyText1!.fontSize!;
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          child: Text(
            messages.anonAuth,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: theme.textTheme.bodyText1!.fontWeight,
              letterSpacing: theme.textTheme.bodyText1!.letterSpacing,
              color: theme.primaryColor,
            ),
          ),
          onPressed: () => false,
        ),
      ),
    );
  }

  Future<bool> _loginProviderSubmit(
      {required LoginProvider loginProvider,
      AnimationController? control}) async {
    await control?.forward();

    final auth = Provider.of<Auth>(context, listen: false);

    auth.authType = AuthType.provider;

    String? error;

    error = await loginProvider.callback!();

    // workaround to run after _cardSizeAnimation in parent finished
    // need a cleaner way but currently it works so..
    Future.delayed(const Duration(milliseconds: 270), () {
      if (mounted) {
        setState(() => _showShadow = false);
      }
    });

    await control?.reverse();

    final messages = Provider.of<LoginMessages>(context, listen: false);

    if (!DartHelper.isNullOrEmpty(error)) {
      if (error != 'skip') {
        showErrorToast(context, messages.flushbarTitleError, error!);
        Future.delayed(const Duration(milliseconds: 271), () {
          if (mounted) {
            setState(() => _showShadow = true);
          }
        });
      }

      return false;
    }

    final showSignupAdditionalFields =
        await loginProvider.providerNeedsSignUpCallback?.call() ?? false;

    // if (showSignupAdditionalFields) {
    //   widget.onSwitchSignUpAdditionalData();
    // }

    widget.onSubmitCompleted!();

    return true;
  }
}
