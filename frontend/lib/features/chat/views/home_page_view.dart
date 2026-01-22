import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/my_drawer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../viewmodels/home_page_viewmodel.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<HomePageViewmodel>(
      create: (context) => HomePageViewmodel(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.home),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Consumer<HomePageViewmodel>(
          builder: (context, vm, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  MyTextFieldSearch(
                    hintText: "Search",
                    obscureText: false,
                    controller: vm.searchController,
                    icon: Icons.search,
                    suffixIcon: Icons.qr_code,
                    onSuffixTap: () {
                      // Handle suffix icon tap
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Welcome to the Home Page'),
                ],
              ),
            );
          },
        ),
        drawer: const MyDrawer(),
      ),
    );
  }
}
