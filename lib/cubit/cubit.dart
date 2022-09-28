import 'dart:io';
import 'dart:async';
import 'package:as7app/cubit/states.dart';
import 'package:as7app/models/user_model.dart';
import 'package:as7app/modules/chats/chats_screen.dart';
import 'package:as7app/modules/feeds/feeds_screen.dart';
import 'package:as7app/modules/new_post/new_post_screen.dart';
import 'package:as7app/modules/settings/settings_screen.dart';
import 'package:as7app/modules/users/users_screen.dart';
import 'package:as7app/shared/components/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post_model.dart';


class SocialCubit extends Cubit<SocialStates>
{
  SocialCubit() : super(SocialInitialState());

  static SocialCubit get(context) => BlocProvider.of(context);

  SocialUserModel? userModel;

  void getUserData()
  {
    emit(SocialGetUserLoadingState());
    
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get()
        .then((value) {
          //print(value.data());
          userModel = SocialUserModel.fromJson(value.data());
          emit(SocialGetUserSuccessState());
    })
        .catchError((error){
          print(error.toString());
          emit(SocialGetUserErrorState(error));
    });
  }

  int currentIndex = 0;

  List<Widget> screens = [
    FeedsScreen(),
    ChatsScreen(),
    NewPostScreen(),
    UsersScreen(),
    SettingsScreen(),
  ];

  List<String> titles = [
    'Home',
    'Chats',
    'Post',
    'Users',
    'Settings',
  ];

   void changeBottomNav(int index)
   {

     if(index == 2)
     {
       emit(SocialNewPostState());
     }
     else
     {
       currentIndex = index;
       emit(SocialChangeBottomNavState());
     }
   }

  File? profileImage;

  var picker = ImagePicker();

  Future<void> getProfileImage() async
  {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null)
    {
      profileImage = File(pickedFile.path);
      print(pickedFile.path);
      emit(SocialProfileImagePickedSuccessState());
    }
    else
    {
      print('No Image Selected');
      emit(SocialProfileImagePickedErrorState());
    }
  }

  File? coverImage;

  Future<void> getCoverImage() async
  {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null)
    {
      coverImage = File(pickedFile.path);
      emit(SocialCoverPickedSuccessState());
    }
    else
    {
      print('No Cover Selected');
      emit(SocialCoverPickedErrorState());
    }
  }

  void uploadProfileImage({
    required String name,
    required String phone,
    required String bio,
})
  {
    emit(SocialUserUpdateLoadingState());

    FirebaseStorage.instance.ref()
        .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((value)
          {
            value.ref.getDownloadURL().then((value)
            {
              //emit(SocialUploadProfileSuccessState());
              print(value);
              updateUserData(
                  name: name,
                  phone: phone,
                  bio: bio,
                  image: value,
              );
            }).catchError((error)
            {
              emit(SocialUploadProfileErrorState());
            });
          })
        .catchError((error)
        {
          emit(SocialUploadProfileErrorState());
        });
  }


  void uploadCoverImage({
    required String name,
    required String phone,
    required String bio,
})
  {
    emit(SocialUploadProfileSuccessState());
    FirebaseStorage.instance.ref()
        .child('users/${Uri.file(coverImage!.path).pathSegments.last}')
        .putFile(coverImage!)
        .then((value)
    {
      value.ref.getDownloadURL().then((value)
      {
        //emit(SocialUploadCoverSuccessState());
        print(value);
        updateUserData(
            name: name,
            phone: phone,
            bio: bio,
            cover: value,
        );
      }).catchError((error)
      {
        emit(SocialUploadCoverErrorState());
      });
    })
        .catchError((error)
    {
      emit(SocialUploadCoverErrorState());
    });
  }

//   void updateUser({
//   required String name,
//   required String phone,
//   required String bio,
// })
//   {
//     if(coverImage != null)
//     {
//       uploadCoverImage();
//     }else if(profileImage != null)
//     {
//       uploadProfileImage();
//     }else if(coverImage != null && profileImage != null)
//     {
//
//     }else
//     {
//       updateUserData(
//         name: name,
//         phone: phone,
//         bio: bio,
//       );
//     }
//
//   }

  void updateUserData({
    required String name,
    required String phone,
    required String bio,
    String? cover,
    String? image,
  })
  {
    SocialUserModel model = SocialUserModel(
      name: name,
      phone: phone,
      uId: userModel!.uId,
      email: userModel!.email,
      cover: cover??userModel!.cover,
      image: image??userModel!.image,
      bio: bio,
      isEmailVerified: false,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .update(model.toMap())
        .then((value)
    {
      getUserData();
    })
        .catchError((error)
    {
      emit(SocialUserUpdateErrorState());
    });
  }
  // if this isn't working for you just try to change Storage Rules on FirebaseStorage to this (rules_version = '2';
// service firebase.storage {
//   match /b/{bucket}/o {
//     match /{allPaths=**} {
//       allow read, write: if true;
//     }
//   }
// })



  File? postImage;

  Future<void> getPostImage() async
  {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null)
    {
      postImage = File(pickedFile.path);
      emit(SocialCoverPickedSuccessState());
    }
    else
    {
      print('No Image Selected');
      emit(SocialCoverPickedErrorState());
    }
  }

  void removePostImage()
  {
    postImage = null;
    emit(SocialRemovePostImageState());
  }

  void uploadPostImage({
    required String dateTime,
    required String text,
  })
  {
    emit(SocialCreatPostLoadingState());
    FirebaseStorage.instance.ref()
        .child('posts/${Uri.file(postImage!.path).pathSegments.last}')
        .putFile(postImage!)
        .then((value)
    {
      value.ref.getDownloadURL().then((value)
      {
        //emit(SocialUploadCoverSuccessState());
        print(value);
        creatPost(
            dateTime: dateTime,
            text: text,
            postImage: value,
        );
      }).catchError((error)
      {
        emit(SocialCreatPostErrorState());
      });
    })
        .catchError((error)
    {
      emit(SocialCreatPostErrorState());
    });
  }

  void creatPost({
    required String dateTime,
    required String text,
    String? postImage,
  })
  {
    emit(SocialCreatPostLoadingState());

    PostModel model = PostModel(
      name: userModel!.name,
      uId: userModel!.uId,
      image: userModel!.image,
      dateTime: dateTime,
      text: text,
      postImage: postImage??'',
    );

    FirebaseFirestore.instance
        .collection('posts')
        .add(model.toMap())
        .then((value)
    {
      emit(SocialCreatPostSuccessState());
    })
        .catchError((error)
    {
      emit(SocialCreatPostErrorState());
    });
  }

  List<PostModel> posts = [];
  List<String> postsId = [];
  List<int> likes = [];

  void getPosts()
  {
    FirebaseFirestore.
    instance.
    collection('posts').
    get().
    then((value)
    {
      value.docs.forEach((element)
      {
        element.
        reference.
        collection('likes').
        get().
        then((value)
        {
          likes.add(value.docs.length);
          postsId.add(element.id);
          posts.add(PostModel.fromJson(element.data()));
        }).catchError((error){});

      });
      emit(SocialGetPostsSuccessState());
    }).catchError((error)
    {
      emit(SocialGetPostsErrorState(error.toString()));
    });
  }

  void likePosts(String postId)
  {
    FirebaseFirestore.
    instance.
    collection('posts').
    doc(postId).
    collection('likes').
    doc(userModel!.uId).
    set({
      'like' : true
    }).then((value)
    {
      emit(SocialLikePostsSuccessState());
    }).catchError((error)
    {
      emit(SocialLikePostsErrorState(error.toString()));
    });
  }


}