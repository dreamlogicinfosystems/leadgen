import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:lead_gen/lead_gen/constants/error.dart';
import 'package:lead_gen/lead_gen/constants/success.dart';
import 'package:lead_gen/lead_gen/data/auth/user_dto.dart';

import '../../constants/api.dart';
import '../../constants/shared_preference.dart';

class AuthApiDataSource{
  final ApiMethods _apiMethods;
  final LocalDataSource _localDataSource;
  AuthApiDataSource(this._apiMethods, this._localDataSource);

  String emailAddress = '';
  String saveOtp = '';
  Future<Either<ErrorMessage,Success>> tryRegister(UserDto userDto,BuildContext context) async{
    Map<String,dynamic> map = {};

    map['name'] = userDto.name;
    map['phone'] = userDto.phoneNumber;
    map['email'] = userDto.email;
    map['password'] = userDto.password;
    map['business_name'] = userDto.businessName;
    map['fcm_token'] = userDto.fcmToken;
    map['device'] = userDto.device;

    final response = await _apiMethods.post(
        url: 'register',
        data: map,
        context: context
    );

    final result = jsonDecode(response!.body);

    if(result['status'] == true){

      await _localDataSource.storeUserData(
          userDto.name!, userDto.phoneNumber!,
          userDto.email!, userDto.businessName!,result['user']['token']
      );

      return Right(Success(result['message']));
    }else{
      return Left(ErrorMessage('Something went wrong'));
    }
  }

  Future<Either<ErrorMessage,Success>> login(String email,String password,BuildContext context) async{
    Map<String,dynamic> map = {};

    map['email'] = email;
    map['password'] = password;

    final response = await _apiMethods.post(
        url: 'login',
        data: map,
        context: context
    );

    final result = jsonDecode(response!.body);

    if(result['status'] == true){
      await _localDataSource.setToken(result['user']['token']);
      return Right(Success(result['message']));
    }else{
      return Left(ErrorMessage(result['message']));
    }
  }

  Future<Either<ErrorMessage,Success>> logOut(BuildContext context) async{
    final response = await _apiMethods.post(
        url: 'logout',
        context: context
    );

    final result = jsonDecode(response!.body);

    if(result['status'] == true){
      return Right(Success(result['message']));
    }else{
      return Left(ErrorMessage(result['message']));
    }
  }

  Future<Either<ErrorMessage,Success>> verifyEmailAddress(String email,BuildContext context) async{
    Map<String,dynamic> map = {};

    emailAddress = email;

    map['email'] = email;
    
    final response = await _apiMethods.post(
        url: 'send_otp',
        data: map,
        context: context
    );

    final result = jsonDecode(response!.body);

    if(result['status'] == true){
      return Right(Success(result['message']));
    }else{
      return Left(ErrorMessage(result['message']));
    }
  }

  Future<Either<ErrorMessage,Success>> verifyOtp(String otp,BuildContext context) async{
    Map<String,dynamic> map = {};

    saveOtp = otp;
    debugPrint(emailAddress);
    map['email'] = emailAddress;
    map['otp'] = otp;

    final response = await _apiMethods.post(
        url: 'verify_otp',
        data: map,
        context: context
    );

    final result = jsonDecode(response!.body);

    if(result['status'] ==  true){
      return Right(Success(result['message']));
    }else{
      return Left(ErrorMessage(result['message']));
    }
  }

  Future<Either<ErrorMessage,Success>> changePassword(String password,BuildContext context) async {
    Map<String, dynamic> map = {};

    debugPrint(emailAddress);
    debugPrint(saveOtp);

    map['email'] = emailAddress;
    map['otp'] = saveOtp;
    map['password'] = password;

    final response = await _apiMethods.post(
        url: 'update_password',
        data: map,
        context: context
    );

    final result = jsonDecode(response!.body);

    if(result['status'] ==  true){
      return Right(Success(result['message']));
    }else{
      return Left(ErrorMessage(result['message']));
    }
  }
}