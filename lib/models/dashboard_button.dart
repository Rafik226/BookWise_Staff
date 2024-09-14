import 'package:bookwise_staff/screens/book_management/add_book_category_screen.dart';
import 'package:bookwise_staff/screens/book_management/search_book.dart';
import 'package:bookwise_staff/screens/book_management/upload_or_edit_book.dart';
import 'package:bookwise_staff/screens/librarian_management/add_librarian_screen.dart';
import 'package:bookwise_staff/screens/librarian_management/search_librarian.dart';
import 'package:bookwise_staff/screens/member_management/search_member.dart';
import 'package:bookwise_staff/screens/member_management/upload_or_edit_member.dart';
import 'package:bookwise_staff/screens/requests_management/request_screen.dart';
import 'package:bookwise_staff/screens/statistics_screen.dart';
import 'package:bookwise_staff/screens/requests_management/unreturned_books_screen.dart';
import 'package:flutter/material.dart';

class DashboardButtonsModel {
  final String text, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(BuildContext context) => [
        DashboardButtonsModel(
          text: "Ajouter livre",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const EditOrUploadBookScreen(),
                ));
          },
        ),
        DashboardButtonsModel(
          text: "ajouter membre",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const EditOrUploadMemberScreen(isEditing: false
                )));
          },
        ),
        DashboardButtonsModel(
          text: "Ajouter categorie",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                       AddBookCategoryScreen(),
                ));
          },
          
        ),
        DashboardButtonsModel(
          text: "Recherche membre",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const MemberSearchScreen(),
                ));
          },
        ),
        DashboardButtonsModel(
          text: "Recherche livre",
          imagePath: "assets/3.png",
          onPressed: () {Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const SearchBook(),
                ));},
        ),
        DashboardButtonsModel(
          text: "statistiques",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const StatisticsScreen(),
                ));
          }
          ,
        ),
        DashboardButtonsModel(
          text: "Emprunt",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>  RequestScreen(),
                ));
          },
        ),
        DashboardButtonsModel(
          text: "Retour",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>  UnreturnedBooksPage(),
                ));
          },
        ),
      ];
      
  static List<DashboardButtonsModel> dashboardBtnListForAdmin(
          BuildContext context) =>
      [
        DashboardButtonsModel(
          text: "Ajouter bibliothecaire",
          imagePath: "assets/3.png",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const EditOrUploadLibrariansScreen(),
                ));
          },
        ),
        DashboardButtonsModel(
          text: "rechercher bibliothecaire",
          imagePath: "assets/3.png",
          onPressed: () {
           Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const StaffSearchScreen(),
                ));
          },
        ),
        DashboardButtonsModel(
          text: "",
          imagePath: "assets/3.png",
          onPressed: () {},
        ),
      ];
}
