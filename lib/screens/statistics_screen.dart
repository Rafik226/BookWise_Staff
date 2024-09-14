import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int totalBooks = 0;
  int totalMembers = 0;
  int totalLibraries = 0; // Ajouté pour le nombre de bibliothèques
  Map<String, int> categoryCounts = {};
  bool _isLoading = true;
  bool _isAdmin = false; // Pour vérifier si l'utilisateur est admin

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndStatistics();
  }

  Future<void> _fetchUserRoleAndStatistics() async {
    try {
      // Récupérer l'ID de l'utilisateur connecté depuis Firebase Auth et verifier si il est admin
      const adminId = 'B5TKFgRkWfg2wqbBdemPll0z6qv2';
      final userDoc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(adminId)
          .get();
      final userData = userDoc.data();

      if (userData != null && userData['role'] == 'admin') {
        if (mounted) {
          setState(() {
            _isAdmin = true;
          });
        }
      }

      // Récupérer le nombre total de livres et leur quantité
      final booksSnapshot =
          await FirebaseFirestore.instance.collection('books').get();
      int totalBookQuantity = 0;
      for (var doc in booksSnapshot.docs) {
        final bookQuantity = int.parse(doc['bookQuantity']);
        totalBookQuantity += bookQuantity;
      }
      if (mounted) {
        setState(() {
          totalBooks = totalBookQuantity;
        });
      }

      // Récupérer le nombre total de membres
      final membersSnapshot =
          await FirebaseFirestore.instance.collection('members').get();
      if (mounted) {
        setState(() {
          totalMembers = membersSnapshot.size;
        });
      }

      // Récupérer le nombre de livres par catégorie en prenant en compte les quantités
      final categoriesSnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final booksCollection = FirebaseFirestore.instance.collection('books');
      final categoryCountsMap = <String, int>{};

      for (final categoryDoc in categoriesSnapshot.docs) {
        final categoryName = categoryDoc['categoryName'];
        final booksInCategory = await booksCollection
            .where('bookCategory', isEqualTo: categoryName)
            .get();
        int categoryQuantity = 0;
        for (var bookDoc in booksInCategory.docs) {
          final bookQuantity = int.parse(bookDoc['bookQuantity']);
          categoryQuantity += bookQuantity;
        }
        categoryCountsMap[categoryName] = categoryQuantity;
      }

      if (mounted) {
        setState(() {
          categoryCounts = categoryCountsMap;
          _isLoading = false;
        });
      }

      // Récupérer le nombre de bibliothèques si l'utilisateur est admin
      if (_isAdmin) {
        final librariesSnapshot =
            await FirebaseFirestore.instance.collection('staff').get();
        if (mounted) {
          setState(() {
            totalLibraries = librariesSnapshot.size;
          });
        }
      }
    } catch (error) {
      // Gérer les erreurs
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Afficher les statistiques générales
                    Card(
                      color: Colors.indigo[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre total de livres (quantité totale)',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.indigo[900]),
                            ),
                            Text(
                              '$totalBooks',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: Colors.indigo),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Nombre total de membres',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.indigo[900]),
                            ),
                            Text(
                              '$totalMembers',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: Colors.indigo),
                            ),
                            if (_isAdmin) ...[
                              const SizedBox(height: 16.0),
                              Text(
                                'Nombre total de bibliothèques',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.indigo[900]),
                              ),
                              Text(
                                '$totalLibraries',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(color: Colors.indigo),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    // Afficher les statistiques par catégorie
                    Text(
                      'Livres par catégorie (quantité totale)',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Colors.indigo[900]),
                    ),
                    const SizedBox(height: 16.0),
                    // Limiter la hauteur du graphique pour éviter les problèmes de taille infinie
                    Container(
                      height: 300, // Hauteur fixe pour le graphique
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      child: PieChart(
                        PieChartData(
                          sections: categoryCounts.entries.map((entry) {
                            return PieChartSectionData(
                              color: Colors.primaries[categoryCounts.keys
                                      .toList()
                                      .indexOf(entry.key) %
                                  Colors.primaries.length],
                              value: entry.value.toDouble(),
                              title: '${entry.key}\n${entry.value}',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            );
                          }).toList(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 4,
                          startDegreeOffset: 180,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
