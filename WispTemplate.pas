unit WispTemplate;

interface

implementation

{
// Initialize the application
Application.Initialize;

// Initialize the constants controller, required to be initialized first
TConstantManager.Create;
//Global_Singleton_ConstantManager.CurrentLanguage := 'Arabic';
//Global_Singleton_ConstantManager.CurrentLanguage := 'English';
Global_Singleton_ConstantManager.CurrentLanguage := 'French';

// Constants
Global_Singleton_ConstantManager.AppTitle := 'TasYear';
Global_Singleton_ConstantManager.AppSubTitle := ' - Logiciel de gestion de la maintenance assistée par oridinateur';
Global_Singleton_ConstantManager.AppVersion := '0.9.1.1';
Global_Singleton_ConstantManager.DbName := 'WispDB';

// Initialize other controllers
TDbConnection.Create;
TAccesManager.Create;
TEntityManager.Create;
TStyleManager.Create;

// Register bitmaps for icons
Global_Singleton_Style.RegisterBitmap('Personnal', 'Skin\Icons\Personnal.bmp');

// Entity : Personnel
Global_Singleton_EntityManager.RegisterEntity('Personnel', 'Personnel');
LastHandledEntity.GlyphName := 'Personnal';
LastHandledEntity.AddProperty(TEPText.Create('FAMILY_NAME', 'Nom'));
LastHandledEntity.AddProperty(TEPText.Create('FIRST_NAME', 'Prénom'));
LastHandledEntity.AddProperty(TEPDate.Create('DATE_OF_BIRTH', 'Date de Naissance'));
LastHandledEntity.AddProperty(TEPText.Create('BIRTH_PLACE', 'Lieu de Naissance'));
LastHandledEntity.AddProperty(TEPDate.Create('RECRUITING_DATE', 'Date de recrutement'));

// Display the main menu
Application.MainFormOnTaskbar := True;
Application.CreateForm(TForm1, Form1);
TMainMenuManager.Create(Form1); // Transform form 1 into wisp's main menu
Application.Run;
}

end.
