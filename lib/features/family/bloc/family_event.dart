import 'package:equatable/equatable.dart';

abstract class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

class LoadFamily extends FamilyEvent {
  const LoadFamily();
}

class CreateFamily extends FamilyEvent {
  final String name;

  const CreateFamily(this.name);

  @override
  List<Object?> get props => [name];
}

class JoinFamily extends FamilyEvent {
  final String inviteCode;

  const JoinFamily(this.inviteCode);

  @override
  List<Object?> get props => [inviteCode];
}

class LeaveFamily extends FamilyEvent {
  const LeaveFamily();
}

class DeleteFamily extends FamilyEvent {
  const DeleteFamily();
}
