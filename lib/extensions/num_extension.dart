///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/30/20 1:36 PM
///
import 'dart:math' as math;

final math.Random _random = math.Random();

extension NumExtension<T extends num> on T {
  T get lessThanOne => math.min<T>((this is int ? 1 : 1.0) as T, this);

  T get lessThanZero => math.min<T>((this is int ? 0 : 0.0) as T, this);

  T get moreThanOne => math.max<T>((this is int ? 1 : 1.0) as T, this);

  T get moreThanZero => math.max<T>((this is int ? 0 : 0.0) as T, this);

  T get betweenZeroAndOne => lessThanOne.moreThanZero;

  /// 根据位数四舍五入
  T roundAsFixed(int size) => num.parse(toStringAsFixed(size)) as T;
}

extension IntExtension on int {
  int nextRandom([int min = 0]) => min + _random.nextInt(this - min);
}

extension DoubleExtension on double {
  double nextRandom([int min = 0]) => min + _random.nextDouble() * (this - min);
}
