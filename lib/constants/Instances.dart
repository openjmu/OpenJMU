import 'package:event_bus/event_bus.dart';

import 'package:OpenJMU/constants/Constants.dart';

class Instances {
  static final EventBus eventBus = EventBus();
  static Notifications notifications = Notifications();
}
