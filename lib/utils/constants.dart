class Constants {
  // Frankfurt region endpoint - CRITICAL FIX!
  static const String appwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String appwriteProjectId = '696a5e940026621a01ee';
  static const String databaseId = '696a60cf00151d14bf35';

  // IMPORTANT: this is the ROW $id inside the `projects` collection
  static const String projectDocId = '6970934c003c641b26dc';

  // collections
  static const String colProjects = 'projects';
  static const String colFieldWorkers = 'field_workers';
  static const String colChildren = 'children';
  static const String colVisits = 'visits';
  static const String colVisitAnswers = 'visit_answers';

  static const String colQuestions = 'questions';
  static const String colQuestionOptions = 'question_options';
  static const String colProjectQuestions = 'project_questions';
  
  // counselling tables
  static const String colCounsellingItems = 'counselling_items';
  static const String colCounsellingVisits = 'counselling_visits';
  static const String colCounsellingResponses = 'counselling_responses';

  // phases
  static const String phaseBaseline = 'baseline';
  static const String phaseCounselling = 'counselling';
  static const String phaseEndline = 'endline';
}
