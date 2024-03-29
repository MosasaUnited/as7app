import 'dart:io';
import 'dart:async';
import 'package:as7app/cubit/states.dart';
import 'package:as7app/models/message_model.dart';
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

import '../models/comment_model.dart';
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
     if(index == 1)
     {
       getUsers();
     }

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

  File? chatImage;

  Future<void> getChatImage() async
  {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null)
    {
      chatImage = File(pickedFile.path);
      emit(SocialGetChatImagePickedSuccessState());
    }
    else
    {
      print('No Image Selected');
      emit(SocialGetChatImagePickedErrorState());
    }
  }

  void uploadChatImage({
  required receiverId,
  required dateTime,
  required text,
})
  {
    emit(SocialUploadChatImagePickedSuccessState());
    FirebaseStorage.instance.ref()
        .child('users/${Uri.file(chatImage!.path).pathSegments.last}')
        .putFile(chatImage!)
        .then((value)
    {
      value.ref.getDownloadURL().then((value)
      {
        print(value);
        sendMessage(
            receiverId: receiverId,
            dateTime: dateTime,
            text: text,
            chatImage: value,
        );
      }).catchError((error)
      {
        emit(SocialUploadChatImagePickedErrorState());
      });
    })
        .catchError((error)
    {
      emit(SocialUploadChatImagePickedErrorState());
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
      for (var element in value.docs) {
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
      }
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

  SocialCommentModel? commentModel;

  void writeComment({
    required String postId,
    required String dateTime,
    required String text,
  }) {
    commentModel = SocialCommentModel(
      name: userModel!.name,
      uId: userModel!.uId,
      image: userModel!.image,
      dateTime: dateTime,
      text: text,
    );

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(commentModel!.toMap())
        .then((value) {
      emit(SocialWriteCommentSuccessState());
    }).catchError((error) {
      emit(SocialWriteCommentErrorState((error).toString()));
    });
  }

  List<SocialCommentModel> comments = [];

  // List<int> commentsNumber = [];

  void getComments({
    required String postId,
  }) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('dateTime')
        .snapshots()
        .listen((event) {
            comments = [];
            for (var element in event.docs) {
              comments.add(SocialCommentModel.fromJson(element.data()));
      }
      emit(SocialGetCommentsSuccessState());
    });
  }

  List<SocialUserModel> users = [];

  void getUsers()
  {
    if(users.isEmpty)
    {
      FirebaseFirestore.
      instance.
      collection('users').
      get().
      then((value)
      {
        for (var element in value.docs) {
          if(element.data()['uId'] != userModel!.uId)
          {
            users.add(SocialUserModel.fromJson(element.data()));
          }
        }
        emit(SocialGetPostsSuccessState());
      }).catchError((error)
      {
        emit(SocialGetPostsErrorState(error.toString()));
      });
    }
  }

  void sendMessage({
  required String receiverId,
  required String dateTime,
  required String text,
  String? chatImage,
})
  {
    MessageModel model = MessageModel(
      text: text,
      senderId: userModel!.uId,
      receiverId: receiverId,
      dateTime: dateTime,
      chatImage: chatImage??'',
    );
// set my chats
    FirebaseFirestore.instance.
    collection('users').
    doc(userModel!.uId).
    collection('chats').
    doc(receiverId).
    collection('messages').
    add(model.toMap()).
    then((value)
    {
      emit(SocialSendMessageSuccessState());
    }).catchError((error){
      emit(SocialSendMessageErrorState());
    });
// set received chats
    FirebaseFirestore.instance.
    collection('users').
    doc(receiverId).
    collection('chats').
    doc(userModel!.uId).
    collection('messages').
    add(model.toMap()).
    then((value)
    {
      emit(SocialSendMessageSuccessState());
    }).catchError((error){
      emit(SocialSendMessageErrorState());
    });
  }

  List<MessageModel> messages = [];

  void getMessages({
  required String receiverId,
})
  {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('dateTime')
        .snapshots()
        .listen((event) 
    {

      messages = [];

      for (var element in event.docs)
      {
        messages.add(MessageModel.fromJson(element.data()));
      }

      emit(SocialGetMessageSuccessState());
    });
  }

  void sendChatMessage({
    required String receiverId,
    required String dateTime,
    required String text,
  })
  {
    MessageModel model = MessageModel(
      text: text,
      senderId: userModel!.uId,
      receiverId: receiverId,
      dateTime: dateTime,
    );
// set my chats
    FirebaseFirestore.instance.
    collection('users').
    doc(userModel!.uId).
    collection('chats').
    doc(receiverId).
    collection('messages').
    add(model.toMap()).
    then((value)
    {
      emit(SocialSendMessageSuccessState());
    }).catchError((error){
      emit(SocialSendMessageErrorState());
    });
// set received chats
    FirebaseFirestore.instance.
    collection('users').
    doc(receiverId).
    collection('chats').
    doc(userModel!.uId).
    collection('messages').
    add(model.toMap()).
    then((value)
    {
      emit(SocialSendMessageSuccessState());
    }).catchError((error){
      emit(SocialSendMessageErrorState());
    });
  }


  void getChatMessages({
    required String receiverId,
  })
  {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('dateTime')
        .snapshots()
        .listen((event)
    {

      messages = [];

      for (var element in event.docs)
      {
        messages.add(MessageModel.fromJson(element.data()));
      }

      emit(SocialGetMessageSuccessState());
    });
  }



}