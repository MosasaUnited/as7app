import 'package:as7app/cubit/cubit.dart';
import 'package:as7app/cubit/states.dart';
import 'package:as7app/models/post_model.dart';
import 'package:as7app/modules/comments/comments_screen.dart';
import 'package:as7app/shared/components/components.dart';
import 'package:as7app/shared/styles/colors.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/styles/icon_broken.dart';

class FeedsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context)
  {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state){},
      builder: (context, state) => ConditionalBuilder(
        condition: SocialCubit.get(context).posts.isNotEmpty,
        builder: (context) => SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          child: Column(
            children:
            [
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 5.0,
                margin: EdgeInsets.all(8.0),
                child: Stack(
                    children: [
                      Image.network(
                        'https://img.freepik.com/free-photo/group-friends-jumping-top-hill_273609-15304.jpg',
                        fit: BoxFit.cover,
                        height: 180.0,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Communicate With Your Friends',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white,)),
                      ),
                    ]
                ),
              ),
              ListView.separated(
                itemBuilder: (context, index) => buildPostItem(SocialCubit.get(context).posts[index], context, index),
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(
                  height: 8.0,
                ),
                physics: NeverScrollableScrollPhysics(),
                itemCount: SocialCubit.get(context).posts.length,
              ),
              SizedBox(
                height: 8.0,
              )
            ],
          ),
        ), fallback: (BuildContext context) => Center(child: CircularProgressIndicator()),

      )
    );
  }

  Widget buildPostItem(PostModel model, context, index) => Card(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 5.0,
    margin: EdgeInsets.symmetric(
      horizontal: 10.0,
    ),
    child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 15.0,
                    backgroundImage: NetworkImage(
                      '${SocialCubit.get(context).userModel!.image}',
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${SocialCubit.get(context).userModel!.name}',
                              style: TextStyle(
                                height: 1.3,
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: defaultColor,
                              size: 14.0,)
                          ],
                        ),
                        Text(
                          '${model.dateTime}',
                          style: Theme.of(context).textTheme.caption!.copyWith(
                            height: 1.3,
                          ),

                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: (){},
                    icon: Icon(
                      Icons.more_horiz,
                      size: 15.0,
                    ),)
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                ),
                child: Container(
                  width: double.infinity,
                  height: 1.0,
                  color: Colors.grey[300],

                ),
              ),
              Text(
                '${model.text}',
                style: TextStyle(
                  height: 1.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
               if(model.postImage != '')
                Container(
                  height: 140.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      5.0,
                    ),

                    image: DecorationImage(
                      image: NetworkImage(
                        '${model.postImage}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 5.0),
                child: Row(
                  children:
                  [
                    Expanded(
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children:
                            [
                              Icon(
                                IconBroken.Heart,
                                size: 16.0,
                                color: Colors.red,
                              ),
                              Text(
                                '${SocialCubit.get(context).likes[index]}',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        onTap: (){},
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:
                            [
                              Icon(
                                IconBroken.Chat,
                                size: 16.0,
                                color: Colors.purple,
                              ),
                              Text(
                                'Comments',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        onTap: ()
                        {
                          navigateTo(context, CommentsScreen(postId: SocialCubit.get(context).postsId[index],));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: Container(
                  width: double.infinity,
                  height: 1.0,
                  color: Colors.grey[300],

                ),
              ),
              InkWell(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18.0,
                              backgroundImage: NetworkImage(
                                '${SocialCubit.get(context).userModel!.image}',
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              'Write a Comment.....',
                              style: Theme.of(context).textTheme.caption!.copyWith(
                                height: 1.3,
                            ),
                            )],
                        ),
                        onTap: ()
                        {
                          navigateTo(context, CommentsScreen(postId: SocialCubit.get(context).postsId[index],));
                        },
                      ),
                    ),
                    InkWell(
                      child: Row(
                        children:
                        [
                          Icon(
                            IconBroken.Heart,
                            size: 16.0,
                            color: Colors.red,
                          ),
                          Text(
                            'Like',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                      onTap: ()
                      {
                        SocialCubit.get(context).likePosts(SocialCubit.get(context).postsId[index]);
                      },
                    ),
                  ],
                ),
              ),
            ])
    ),
  );
}


