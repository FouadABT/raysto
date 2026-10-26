import 'dart:convert';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../platform/platform.dart';

/// New commands share the same domain services as REST. Legacy endpoints remain.
class PlatformEndpoint extends Endpoint {
  Future<PlatformResponse> command(
    Session s,
    String operation,
    PlatformCommand command,
  ) => PlatformApi.command(s, operation, command);
  Future<PlatformResponse> query(
    Session s,
    String name,
    String parametersJson,
  ) async => PlatformResponse(
    requestId: 'read',
    dataJson: jsonEncode(
      await PlatformQueries.query(
        s,
        name,
        jsonDecode(parametersJson) as Map<String, dynamic>,
      ),
    ),
  );
  Future<PlatformResponse> createQuote(Session s, CreateQuote command) async {
    await PlatformApi.guard(s);
    return PlatformResponse(
      requestId: command.requestKey,
      dataJson: jsonEncode(await OrderingModule.quote(s, command)),
    );
  }

  Future<PlatformResponse> submitOrder(Session s, SubmitOrder command) async {
    await PlatformApi.guard(s);
    return PlatformResponse(
      requestId: command.requestKey,
      dataJson: jsonEncode(await OrderingModule.submit(s, command)),
    );
  }

  Future<PlatformResponse> startVisit(Session s, StartVisit command) async {
    await PlatformApi.guard(s);
    return PlatformResponse(
      requestId: command.requestKey,
      dataJson: jsonEncode(await DiningModule.start(s, command)),
    );
  }

  Future<PlatformResponse> allocatePayment(
    Session s,
    AllocatePayment command,
  ) async {
    await PlatformApi.guard(s);
    return PlatformResponse(
      requestId: command.requestKey,
      dataJson: jsonEncode(await MoneyModule.allocate(s, command)),
    );
  }

  Future<PlatformResponse> requestRefund(
    Session s,
    RequestRefund command,
  ) async {
    await PlatformApi.guard(s);
    return PlatformResponse(
      requestId: command.requestKey,
      dataJson: jsonEncode(await MoneyModule.refund(s, command)),
    );
  }

  Future<PlatformResponse> uploadContent(
    Session s,
    int mediaId,
    ByteData bytes,
  ) async {
    await PlatformApi.guard(s);
    return PlatformResponse(
      requestId: 'upload',
      dataJson: jsonEncode(
        await AiModule.uploadBytes(
          s,
          mediaId,
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        ),
      ),
    );
  }

  Stream<PlatformEvent> events(Session s, int restaurantId, int after) async* {
    await PlatformApi.guard(s);
    yield* PlatformQueries.events(s, restaurantId, after);
  }
}
