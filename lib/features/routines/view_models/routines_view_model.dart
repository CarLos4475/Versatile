import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/seed_data.dart';
import '../../../domain/entities/routine.dart';

final routinesProvider = Provider<List<Routine>>((ref) => SeedData.routines);
