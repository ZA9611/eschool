import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/chat/chatUsersCubit.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/cubits/slidersCubit.dart';
import 'package:eschool/cubits/userProfileCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/data/repositories/settingsRepository.dart';
import 'package:eschool/data/repositories/systemInfoRepository.dart';
import 'package:eschool/ui/screens/chat/chatUsersScreen.dart';
import 'package:eschool/ui/screens/home/homeScreen.dart';
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool/ui/widgets/latestNoticesContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/slidersContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/notificationUtils/generalNotificationUtility.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<SlidersCubit>(
            create: (context) => SlidersCubit(SystemRepository()),
          ),
          BlocProvider<UserProfileCubit>(
            create: (context) => UserProfileCubit(AuthRepository()),
          ),
        ],
        child: const ParentHomeScreen(),
      ),
    );
  }
}

class _ParentHomeScreenState extends State<ParentHomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      //fetching users on home page open to show unread counter
      context
          .read<ChatUsersCubit>()
          .fetchChatUsers(isParent: context.read<AuthCubit>().isParent());
      context.read<SlidersCubit>().fetchSliders();
      NotificationUtility.setUpNotificationService(context);
      context
          .read<NoticeBoardCubit>()
          .fetchNoticeBoardDetails(useParentApi: true);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //Refreshing the shared preferences to get the latest notification count, it there were any notifications in the background
    if (state == AppLifecycleState.resumed) {
      notificationCountValueNotifier.value =
          await SettingsRepository().getNotificationCount();
    }
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: ScreenTopBackgroundContainer(
        padding: EdgeInsets.zero,
        heightPercentage: UiUtils.appBarMediumHeightPercentage,
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Stack(
              children: [
                //Bordered circles
                PositionedDirectional(
                  top: MediaQuery.of(context).size.width * (-0.2),
                  start: MediaQuery.of(context).size.width * (-0.225),
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                        end: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.1),
                      ),
                      shape: BoxShape.circle,
                    ),
                    width: MediaQuery.of(context).size.width * (0.6),
                    height: MediaQuery.of(context).size.width * (0.6),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                //bottom fill circle
                PositionedDirectional(
                  bottom: MediaQuery.of(context).size.width * (-0.15),
                  end: MediaQuery.of(context).size.width * (-0.15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    width: MediaQuery.of(context).size.width * (0.4),
                    height: MediaQuery.of(context).size.width * (0.4),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.02),
                      start: boxConstraints.maxWidth * (0.075),
                      bottom: boxConstraints.maxHeight * (0.18),
                    ),
                    child: Row(
                      children: [
                        BorderedProfilePictureContainer(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(Routes.parentProfile);
                          },
                          boxConstraints: boxConstraints,
                          imageUrl: context
                              .read<AuthCubit>()
                              .getParentDetails()
                              .image,
                        ),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.04),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context
                                        .read<AuthCubit>()
                                        .getParentDetails()
                                        .getFullName(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  ),
                                  Text(
                                    context
                                        .read<AuthCubit>()
                                        .getParentDetails()
                                        .email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          iconSize: 20,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.settings);
                          },
                          icon: const Icon(Icons.settings),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildDetailsContainer({
    required double width,
    required Student student,
  }) {
    bool isCompulsoryFeePaymentAndDuePayment =
        context.read<AppConfigurationCubit>().isCompulsoryFeePaymentMode() &&
            student.isFeePaymentDue;
    return Animate(
      effects: customItemZoomAppearanceEffects(),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (isCompulsoryFeePaymentAndDuePayment) {
            Navigator.of(context).pushNamed(
              Routes.feesDetails,
              arguments: {
                "studentDetails": student,
                "sessionYearId": context
                    .read<AppConfigurationCubit>()
                    .getAppConfiguration()
                    .sessionYear
                    .id,
              },
            );
          } else {
            Navigator.of(context)
                .pushNamed(Routes.studentDetails, arguments: student);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          width: width,
          height: 160,
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AbsorbPointer(
                            child: BorderedProfilePictureContainer(
                              onTap: null,
                              heightAndWidthPercentage: 0.35,
                              boxConstraints: boxConstraints,
                              imageUrl: student.image,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            student.getFullName(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(
                            height: 2.5,
                          ),
                          Text(
                            "${UiUtils.getTranslatedLabel(context, classKey)} - ${student.classSectionNameWithSemester(context: context)}",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                          if (isCompulsoryFeePaymentAndDuePayment) ...[
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              UiUtils.getTranslatedLabel(
                                  context, feePaymentDueKey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: -15,
                    start: (boxConstraints.maxWidth * 0.5) - 15,
                    child: Container(
                      alignment: Alignment.center,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                            offset: const Offset(0, 5),
                            blurRadius: 20,
                          )
                        ],
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChildDetailsShimmerLoadingContainer({
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 150,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.125),
                    ),
                    ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        height: boxConstraints.maxHeight * (0.3),
                        width: boxConstraints.maxHeight * (0.3),
                        borderRadius: boxConstraints.maxHeight * (0.15),
                      ),
                    ),
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.075),
                    ),
                    ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        width: boxConstraints.maxWidth * (0.6),
                        height:
                            UiUtils.shimmerLoadingContainerDefaultHeight - 1,
                      ),
                    ),
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.05),
                    ),
                    ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        width: boxConstraints.maxWidth * (0.4),
                        height:
                            UiUtils.shimmerLoadingContainerDefaultHeight - 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChildrenContainer() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * (0.075),
            right: MediaQuery.of(context).size.width * (0.075),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  UiUtils.getTranslatedLabel(context, myChildrenKey),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              LayoutBuilder(
                builder: (context, boxConstraints) {
                  return Wrap(
                    spacing: boxConstraints.maxWidth * (0.1),
                    runSpacing: 32.5,
                    children: context
                        .read<AuthCubit>()
                        .getParentDetails()
                        .children
                        .map(
                          (student) => _buildChildDetailsContainer(
                            width: boxConstraints.maxWidth * (0.44),
                            student: student,
                          ),
                        )
                        .toList(),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildChildrenShimmerLoadingContainer() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Wrap(
          spacing: boxConstraints.maxWidth * (0.1),
          runSpacing: 32.5,
          children: context
              .read<AuthCubit>()
              .getParentDetails()
              .children
              .map(
                (student) => _buildChildDetailsShimmerLoadingContainer(
                  width: boxConstraints.maxWidth * (0.45),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildChatFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: primaryColor,
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const ChatUsersScreen(),
          ),
        );
      },
      child: BlocBuilder<ChatUsersCubit, ChatUsersState>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: SvgPicture.asset(
                  UiUtils.getImagePath("chat_icon.svg"),
                  fit: BoxFit.contain,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              //notification count showing on top of the icon
              if (state is ChatUsersFetchSuccess && state.totalUnreadUsers != 0)
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: redColor,
                    ),
                    margin: const EdgeInsets.all(7),
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      state.totalUnreadUsers > 9
                          ? "9+"
                          : state.totalUnreadUsers.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          context.read<AppConfigurationCubit>().appUnderMaintenance()
              ? null
              : context.read<AppConfigurationCubit>().forceUpdate()
                  ? FutureBuilder<bool>(
                      future: UiUtils.forceUpdate(
                        context.read<AppConfigurationCubit>().getAppVersion(),
                      ),
                      builder: (context, snaphsot) {
                        if (snaphsot.hasData) {
                          return (snaphsot.data ?? false)
                              ? const SizedBox()
                              : _buildChatFloatingActionButton();
                        }
                        return const SizedBox();
                      },
                    )
                  : _buildChatFloatingActionButton(),
      body: context.read<AppConfigurationCubit>().appUnderMaintenance()
          ? const AppUnderMaintenanceContainer()
          : BlocListener<UserProfileCubit, UserProfileState>(
              listener: (context, state) {
                if (state is UserProfileFetchSuccess) {
                  //updating profile in auth cubit as it's accessed throughout the application
                  if (context.read<AuthCubit>().isParent()) {
                    context.read<AuthCubit>().updateParentProfile(
                        parent: AuthRepository().getParentDetails());
                  } else {
                    context.read<AuthCubit>().updateStudentProfile(
                        student: AuthRepository().getStudentDetails());
                  }
                }
              },
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: RefreshIndicator(
                      displacement: UiUtils.getScrollViewTopPadding(
                        context: context,
                        appBarHeightPercentage:
                            UiUtils.appBarMediumHeightPercentage,
                      ),
                      onRefresh: () {
                        context.read<SlidersCubit>().fetchSliders();
                        context
                            .read<UserProfileCubit>()
                            .fetchAndSetUserProfile();
                        return Future.value();
                      },
                      child: SizedBox(
                        height: double.maxFinite,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: UiUtils.getScrollViewTopPadding(
                              context: context,
                              appBarHeightPercentage:
                                  UiUtils.appBarMediumHeightPercentage,
                            ),
                          ),
                          child: BlocBuilder<SlidersCubit, SlidersState>(
                            builder: (context, state) {
                              if (state is SlidersFetchSuccess) {
                                return Column(
                                  children: [
                                    SlidersContainer(sliders: state.sliders),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              (0.025),
                                    ),
                                    _buildChildrenContainer(),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              (0.05),
                                    ),
                                    const LatestNoticesContainer(),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              (0.05),
                                    ),
                                  ],
                                );
                              }
                              if (state is SlidersFetchFailure) {
                                return Center(
                                  child: ErrorContainer(
                                    errorMessageCode: state.errorMessage,
                                    onTapRetry: () {
                                      context
                                          .read<SlidersCubit>()
                                          .fetchSliders();
                                    },
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerLoadingContainer(
                                    child: CustomShimmerContainer(
                                      margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                (0.075),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      borderRadius: 25,
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          UiUtils.appBarBiggerHeightPercentage,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        (0.075),
                                  ),
                                  _buildChildrenShimmerLoadingContainer(),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        (0.025),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              (0.075),
                                    ),
                                    child: Column(
                                      children:
                                          List.generate(3, (index) => index)
                                              .map(
                                                (e) =>
                                                    const AnnouncementShimmerLoadingContainer(),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildAppBar(),
                  context.read<AppConfigurationCubit>().forceUpdate()
                      ? FutureBuilder<bool>(
                          future: UiUtils.forceUpdate(
                            context
                                .read<AppConfigurationCubit>()
                                .getAppVersion(),
                          ),
                          builder: (context, snaphsot) {
                            if (snaphsot.hasData) {
                              return (snaphsot.data ?? false)
                                  ? const ForceUpdateDialogContainer()
                                  : const SizedBox();
                            }

                            return const SizedBox();
                          },
                        )
                      : const SizedBox(),
                ],
              ),
            ),
    );
  }
}
