import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_m_f_s_l_staff/flutter_flow/flutter_flow_model.dart';

/// A concrete implementation of FlutterFlowModel for testing.
class _TestModel extends FlutterFlowModel<StatelessWidget> {
  bool initStateCalled = false;
  bool disposeCalled = false;
  int initCallCount = 0;

  @override
  void initState(BuildContext context) {
    initStateCalled = true;
    initCallCount++;
  }

  @override
  void dispose() {
    disposeCalled = true;
  }
}

void main() {
  group('FlutterFlowModel', () {
    late _TestModel model;

    setUp(() {
      model = _TestModel();
    });

    test('default values', () {
      expect(model.disposeOnWidgetDisposal, true);
      expect(model.updateOnChange, false);
      expect(model.widget, isNull);
      expect(model.context, isNull);
    });

    test('setOnUpdate configures callback and updateOnChange', () {
      var callbackInvoked = false;
      model.setOnUpdate(
        onUpdate: () => callbackInvoked = true,
        updateOnChange: true,
      );
      expect(model.updateOnChange, true);
      model.onUpdate();
      expect(callbackInvoked, true);
    });

    test('onUpdate does nothing when updateOnChange is false', () {
      var callbackInvoked = false;
      model.setOnUpdate(
        onUpdate: () => callbackInvoked = true,
        updateOnChange: false,
      );
      model.onUpdate();
      expect(callbackInvoked, false);
    });

    test('updatePage calls callback then triggers update', () {
      final calls = <String>[];
      model.setOnUpdate(onUpdate: () => calls.add('update'));
      model.updatePage(() => calls.add('page'));
      expect(calls, ['page', 'update']);
    });

    test('maybeDispose calls dispose when disposeOnWidgetDisposal is true', () {
      model.disposeOnWidgetDisposal = true;
      model.maybeDispose();
      expect(model.disposeCalled, true);
      expect(model.widget, isNull);
    });

    test('maybeDispose skips dispose when disposeOnWidgetDisposal is false', () {
      model.disposeOnWidgetDisposal = false;
      model.maybeDispose();
      expect(model.disposeCalled, false);
      expect(model.widget, isNull); // widget is still cleared
    });
  });

  group('FlutterFlowDynamicModels', () {
    late FlutterFlowDynamicModels<_TestModel> dynamicModels;

    setUp(() {
      dynamicModels = FlutterFlowDynamicModels(() => _TestModel());
    });

    test('getModel creates new model for unique key', () {
      final model = dynamicModels.getModel('key-1', 0);
      expect(model, isA<_TestModel>());
    });

    test('getModel returns same model for same key', () {
      final model1 = dynamicModels.getModel('key-1', 0);
      final model2 = dynamicModels.getModel('key-1', 0);
      expect(identical(model1, model2), true);
    });

    test('getModel returns different models for different keys', () {
      final model1 = dynamicModels.getModel('key-1', 0);
      final model2 = dynamicModels.getModel('key-2', 1);
      expect(identical(model1, model2), false);
    });

    test('getValues extracts values from all models', () {
      dynamicModels.getModel('a', 0).initStateCalled = true;
      dynamicModels.getModel('b', 1).initStateCalled = false;
      final values = dynamicModels.getValues((m) => m.initStateCalled);
      expect(values, [true, false]);
    });

    test('getValueForKey returns value from specific model', () {
      dynamicModels.getModel('my-key', 0).initCallCount = 42;
      final value = dynamicModels.getValueForKey(
        'my-key',
        (m) => m.initCallCount,
      );
      expect(value, 42);
    });

    test('getValueForKey returns null for missing key', () {
      final value = dynamicModels.getValueForKey(
        'missing',
        (m) => m.initCallCount,
      );
      expect(value, isNull);
    });

    test('dispose disposes all child models', () {
      final model1 = dynamicModels.getModel('a', 0);
      final model2 = dynamicModels.getModel('b', 1);
      dynamicModels.dispose();
      expect(model1.disposeCalled, true);
      expect(model2.disposeCalled, true);
    });
  });
}
