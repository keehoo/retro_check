part of 'user_profile_cubit.dart';

class UserProfileState extends Equatable {
  final int? userPoints;

  const UserProfileState({this.userPoints});

  @override
  List<Object?> get props => [userPoints];

  UserProfileState copyWith({
    int? userPoints,
  }) {
    return UserProfileState(
      userPoints: userPoints ?? this.userPoints,
    );
  }
}
