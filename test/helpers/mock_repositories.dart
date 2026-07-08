// test/helpers/mock_repositories.dart

import 'package:image_picker/image_picker.dart';
import 'package:medha/data/repositories/adherence_repository.dart';
import 'package:medha/data/repositories/interaction_repository.dart';
import 'package:medha/data/repositories/medicine_repository.dart';
import 'package:medha/data/repositories/reminder_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockMedicineRepository extends Mock implements MedicineRepository {}

class MockInteractionRepository extends Mock implements InteractionRepository {}

class MockAdherenceRepository extends Mock implements AdherenceRepository {}

class MockReminderRepository extends Mock implements ReminderRepository {}

class MockImagePicker extends Mock implements ImagePicker {}
