part of auth_card_builder;

class PhoneCard extends StatefulWidget {
  const PhoneCard({
    Key? key,
    required this.loadingController,
    required this.onSwitchSignUpAdditionalData,
    required this.requireAdditionalSignUpFields,
    required this.onSwitchConfirmSignup,
    required this.requireSignUpConfirmation,
    required this.onBack,
    this.onSwitchAuth,
    this.onSubmitCompleted,
    this.phoneLoginOtpSentNotifier,
    this.phoneLoginVerificationStatusNotifier,
  }) : super(key: key);

  final AnimationController loadingController;
  final Function onSwitchSignUpAdditionalData;
  final Function onSwitchConfirmSignup;
  final Function? onSwitchAuth;
  final Function? onSubmitCompleted;
  final Function onBack;
  final bool requireAdditionalSignUpFields;
  final bool requireSignUpConfirmation;

  final ValueNotifier<bool>? phoneLoginOtpSentNotifier;
  final ValueNotifier<String?>? phoneLoginVerificationStatusNotifier;

  @override
  _PhoneCardState createState() => _PhoneCardState();
}

class _PhoneCardState extends State<PhoneCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  var _isLoading = false;
  var _isSubmitting = false;
  var _showShadow = true;
  bool isKeyboardVisible = false;
  var _otpSent = false;

  /// switch between login and signup
  late AnimationController _otpController;

  late AnimationController _switchAuthController;
  late AnimationController _postSwitchAuthController;

  late AnimationController _submitController;
  late final ScrollController scrollController;
  final TextEditingController nameController = TextEditingController();

  Interval? _textButtonLoadingAnimationInterval;

  ///list of AnimationController each one responsible for a authentication provider icon
  List<AnimationController> _providerControllerList = <AnimationController>[];

  late Animation<double> _buttonScaleAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;

  @override
  void initState() {
    super.initState();

    widget.phoneLoginOtpSentNotifier?.addListener(onOtpSent);
    widget.phoneLoginVerificationStatusNotifier
        ?.addListener(onVerificationStatusChanged);

    if (widget.phoneLoginOtpSentNotifier != null) {}

    final auth = Provider.of<Auth>(context, listen: false);
    scrollController = ScrollController();

    widget.loadingController.addStatusListener(handleLoadingAnimationStatus);

    _otpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _switchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _postSwitchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _providerControllerList = auth.loginProviders
        .map(
          (e) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1000),
          ),
        )
        .toList();

    _textButtonLoadingAnimationInterval =
        const Interval(.6, 1.0, curve: Curves.easeOut);

    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: widget.loadingController,
      curve: const Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));
  }

  void onOtpSent() {
    if (widget.phoneLoginOtpSentNotifier!.value) {
      _otpController.forward();
    }
  }

  void onVerificationStatusChanged() {
    if (widget.phoneLoginVerificationStatusNotifier!.value != null) {
      // error
    } else {
      // success
    }
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    widget.phoneLoginOtpSentNotifier?.removeListener(onOtpSent);
    widget.phoneLoginVerificationStatusNotifier
        ?.removeListener(onVerificationStatusChanged);

    widget.loadingController.removeStatusListener(handleLoadingAnimationStatus);
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _otpController.dispose();
    _postSwitchAuthController.dispose();
    _switchAuthController.dispose();

    nameController.dispose();

    _submitController.dispose();
    scrollController.dispose();

    for (var controller in _providerControllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _submit() async {
    // a hack to force unfocus the soft keyboard. If not, after change-route
    // animation completes, it will trigger rebuilding this widget and show all
    // textfields and buttons again before going to new route
    FocusScope.of(context).requestFocus(FocusNode());

    final messages = Provider.of<LoginMessages>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    _formKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final auth = Provider.of<Auth>(context, listen: false);
    String? error;

    auth.authType = AuthType.userPassword;

    error = await auth.onPhoneLogin?.call(
      PhoneLoginData(
        phoneNumber: auth.phoneNumber,
        additionalSignupData: {'Username': nameController.text},
      ),
    );

    // workaround to run after _cardSizeAnimation in parent finished
    // need a cleaner way but currently it works so..
    Future.delayed(const Duration(milliseconds: 270), () {
      if (mounted) {
        setState(() => _showShadow = false);
      }
    });

    await _submitController.reverse();

    if (!DartHelper.isNullOrEmpty(error)) {
      showErrorToast(context, messages.flushbarTitleError, error!);
      Future.delayed(const Duration(milliseconds: 271), () {
        if (mounted) {
          setState(() => _showShadow = true);
        }
      });
      setState(() => _isSubmitting = false);
      return false;
    }

    if (widget.phoneLoginOtpSentNotifier != null) {
      return false;
    }
    _otpController.forward();

    return true;
  }

  Widget _buildPhoneNumberField(Auth auth) {
    return IntlPhoneField(
      autovalidateMode: AutovalidateMode.disabled,
      autofocus: true,
      invalidNumberMessage: 'Invalid Phone Number!',
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(fontSize: 25),
      onChanged: (phone) => auth.phoneNumber = phone.completeNumber,
      initialCountryCode: 'IN',
      flagsButtonPadding: const EdgeInsets.only(left: 10, right: 10),
      showDropdownIcon: false,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildNameField(
    Auth auth,
    double width,
  ) {
    return AnimatedTextFormField(
      controller: nameController,
      // interval: _fieldAnimationIntervals[widget.formFields.indexOf(formField)],
      loadingController: widget.loadingController,
      width: width,
      labelText: 'Display Name',
      prefixIcon: const Icon(FontAwesomeIcons.solidUserCircle),
      keyboardType: TextFieldUtils.getKeyboardType(LoginUserType.name),
      autofillHints: [TextFieldUtils.getAutofillHints(LoginUserType.name)],
      validator: (value) {
        if (auth.isSignup && value != null && value.length < 4) {
          return "Display name has to be at least 4 characters.";
        }
        return null;
      },
      enabled: !_isSubmitting,
    );
  }

  Widget _buildSubmitButton(
      ThemeData theme, LoginMessages messages, Auth auth) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        text: auth.isLogin ? messages.loginButton : messages.signupButton,
        onPressed: () => _submit(),
      ),
    );
  }

  void _switchAuthMode() {
    final auth = Provider.of<Auth>(context, listen: false);
    final newAuthMode = auth.switchAuth();

    if (newAuthMode == AuthMode.signup) {
      _switchAuthController.forward();
    } else {
      _switchAuthController.reverse();
    }
  }

  Widget _buildSwitchAuthButton(ThemeData theme, LoginMessages messages,
      Auth auth, LoginTheme loginTheme) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return FadeIn(
      controller: widget.loadingController,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      fadeDirection: FadeDirection.topToBottom,
      child: MaterialButton(
        disabledTextColor: theme.primaryColor,
        onPressed: buttonEnabled ? _switchAuthMode : null,
        padding: loginTheme.authButtonPadding ??
            const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: loginTheme.switchAuthTextColor ?? calculatedTextColor,
        child: AnimatedText(
          text: auth.isSignup ? messages.loginButton : messages.signupButton,
          textRotation: AnimatedTextRotation.down,
        ),
      ),
    );
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
                _buildPhoneNumberField(auth),
                ExpandableContainer(
                  backgroundColor: _switchAuthController.isCompleted
                      ? null
                      : theme.colorScheme.secondary,
                  controller: _switchAuthController,
                  initialState: isLogin
                      ? ExpandableContainerState.shrunk
                      : ExpandableContainerState.expanded,
                  alignment: Alignment.topLeft,
                  color: theme.cardTheme.color,
                  width: cardWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: cardPadding,
                    vertical: 10,
                  ),
                  onExpandCompleted: () => _postSwitchAuthController.forward(),
                  child: _buildNameField(auth, textFieldWidth),
                ),
                ExpandableContainer(
                  backgroundColor: _otpController.isCompleted
                      ? null
                      : theme.colorScheme.secondary,
                  controller: _otpController,
                  initialState: !_otpSent
                      ? ExpandableContainerState.shrunk
                      : ExpandableContainerState.expanded,
                  alignment: Alignment.topLeft,
                  color: theme.cardTheme.color,
                  width: cardWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: cardPadding,
                    vertical: 10,
                  ),
                  onExpandCompleted: () => _postSwitchAuthController.forward(),
                  child: _buildOTPField(auth, messages),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: Paddings.fromRBL(cardPadding),
            width: cardWidth,
            child: Column(
              children: <Widget>[
                if (!_isSubmitting) _buildSubmitButton(theme, messages, auth),
                if (!_isSubmitting)
                  _buildSwitchAuthButton(theme, messages, auth, loginTheme),
                _buildBackButton(theme, messages, loginTheme),
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

  Widget _buildOTPField(Auth auth, LoginMessages messages) {
    return Column(
      children: [
        const Text('OTP'),
        PinInputField(
          length: 6,
          onFocusChange: (hasFocus) async {
            if (hasFocus) await _scrollToBottomOnKeyboardOpen();
          },
          onSubmit: (enteredOtp) async {
            var error = await auth.onPhoneLoginOtp?.call(
              PhoneLoginData(
                phoneNumber: auth.phoneNumber,
                otp: enteredOtp,
                additionalSignupData: {'Username': nameController.text},
              ),
            );

            await _submitController.reverse();

            if (!DartHelper.isNullOrEmpty(error)) {
              showErrorToast(context, messages.flushbarTitleError, error!);
              Future.delayed(const Duration(milliseconds: 271), () {
                if (mounted) {
                  setState(() => _showShadow = true);
                }
              });
              setState(() => _isSubmitting = false);
            }
            if (widget.requireAdditionalSignUpFields) {
              widget.onSwitchSignUpAdditionalData();
              return;
            }

            widget.onSubmitCompleted?.call();
          },
        ),
      ],
    );
  }

  Widget _buildBackButton(
      ThemeData theme, LoginMessages messages, LoginTheme? loginTheme) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return MaterialButton(
      onPressed: () {
        _formKey.currentState!.save();
        widget.onBack();
      },
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
      child: Text(messages.goBackButton),
    );
  }

  Future<void> _scrollToBottomOnKeyboardOpen() async {
    while (!isKeyboardVisible) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }
}
