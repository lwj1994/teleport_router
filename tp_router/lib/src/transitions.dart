import 'package:flutter/cupertino.dart';
import 'package:tp_router_annotation/tp_router_annotation.dart';

/// A fade transition that fades the page in/out.
class TpFadeTransition extends TpTransitionsBuilder {
  const TpFadeTransition();

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

/// A slide transition that slides the page from the right.
class TpSlideTransition extends TpTransitionsBuilder {
  const TpSlideTransition();

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutQuart,
      reverseCurve: Curves.easeInOutQuint,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    );
  }
}

/// A page transition that uses the Cupertino style.
class TpCupertinoPageTransition extends TpTransitionsBuilder {
  const TpCupertinoPageTransition();

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: child,
    );
  }
}

/// A slide transition that slides the page from the bottom.
class TpSlideUpTransition extends TpTransitionsBuilder {
  const TpSlideUpTransition();

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutQuart,
      reverseCurve: Curves.easeInOutQuint,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    );
  }
}

/// A scale transition that scales the page in/out.
class TpScaleTransition extends TpTransitionsBuilder {
  const TpScaleTransition();

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutQuart,
      reverseCurve: Curves.easeOutBack,
    );
    return ScaleTransition(
      scale: curvedAnimation,
      child: child,
    );
  }
}

/// No transition - page appears instantly.
class TpNoTransition extends TpTransitionsBuilder {
  const TpNoTransition();

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
