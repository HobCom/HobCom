import 'package:flutter/material.dart';
import 'package:hobcom/Authentication/Forgotpass.dart';
import 'package:hobcom/Authentication/Login.dart';
import 'package:hobcom/Authentication/register.dart';
import 'package:hobcom/Utils/const..dart';

class AuthHome extends StatefulWidget {
  @override
  _AuthHomeState createState() => _AuthHomeState();
}

class _AuthHomeState extends State<AuthHome>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 1,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 50),
                      height: 250,
                      width: width,
                      decoration: BoxDecoration(
                        color: kprimary,
                      ),
                      child: Image.asset('images/logo.png'),
                    ),
                    SizedBox(
                      height: 80,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          bottom: TabBar(
                            controller: tabController,
                            indicatorColor: Colors.black,
                            indicatorWeight: 4,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: TabBarView(
                      controller: tabController,
                      children: [
                        LoginScreen(tabController),
                        RegisterScreen(tabController)
                        
                      ],
                    )),

                  
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
