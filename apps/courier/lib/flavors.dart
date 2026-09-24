enum Flavor { dev, stg, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return '(DEV) Aura Courier';
      case Flavor.stg:
        return '(STG) Aura Courier';
      case Flavor.prod:
        return 'Aura Courier';
    }
  }
}
