import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:lead_gen/lead_gen/constants/error.dart';

import 'package:lead_gen/lead_gen/constants/success.dart';
import 'package:lead_gen/lead_gen/data/auth/user_dto.dart';

import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/user.dart';
import 'auth_api_data_source.dart';

class AuthRepositoryImpl extends AuthRepository{
  final AuthApiDataSource _apiDataSource;
  AuthRepositoryImpl(this._apiDataSource);
  @override
  Future<Either<ErrorMessage, Success>> registerUser(User user,BuildContext context) async{
    if(user == const User()){
      return Left(ErrorMessage('Something went wrong!'));
    }else{
      final userDto = UserDto.fromDomain(user);

      final result = await _apiDataSource.tryRegister(userDto,context);

      return result.fold((error){
        return Left(error);
      },(success){
        return Right(success);
      });
    }
  }

  @override
  Future<Either<ErrorMessage, Success>> tryLogin(String email,String password,BuildContext context) async{
    if(email.isEmpty || password.isEmpty){
      return Left(ErrorMessage('Something went wrong!'));
    }else{
      final tryLogin = await _apiDataSource.login(email, password,context);

      return tryLogin.fold((error){
        return Left(error);
      },(success){
        return Right(success);
      });
    }
  }
}