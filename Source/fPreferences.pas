unit fPreferences;

interface {********************************************************************}

uses
  Controls, Forms, Graphics, Windows, XMLDoc, XMLIntf,
  ExtCtrls, Classes, SysUtils, Registry, IniFiles,
  ComCtrls,
  MySQLDB;

type
  TPExportType = (etSQLFile, etTextFile, etExcelFile, etAccessFile, etSQLiteFile, etODBC, etHTMLFile, etXMLFile, etPDFFile, etPrinter);

  TPItems = class;
  TPPreferences = class;
  TABookmarks = class;
  TAFiles = class;
  TAJobs = class;
  TADesktop = class;
  TAConnection = class;
  TAAccount = class;
  TAAccounts = class;

  TPItem = class(TObject)
  private
    FName: string;
  protected
    FAItems: TPItems;
    FXML: IXMLNode;
    function GetIndex(): Integer; inline;
    function GetXML(): IXMLNode; virtual;
    procedure LoadFromXML(const XML: IXMLNode); virtual; abstract;
    procedure SaveToXML(const XML: IXMLNode); virtual; abstract;
    property XML: IXMLNode read GetXML;
  public
    procedure Assign(const Source: TPItem); virtual;
    constructor Create(const AAItems: TPItems; const AName: string = ''); virtual;
    property AItems: TPItems read FAItems;
    property Index: Integer read GetIndex;
    property Name: string read FName write FName;
  end;

  TPItems = class(TList)
  private
    function GetItem(Index: Integer): TPItem; inline;
  protected
    function GetXML(): IXMLNode; virtual; abstract;
    function InsertIndex(const Name: string; out Index: Integer): Boolean; virtual;
    property XML: IXMLNode read GetXML;
  public
    function Add(const AItem: TPItem): Integer; overload; virtual;
    procedure Clear(); override;
    constructor Create();
    destructor Destroy(); override;
    function IndexByName(const Name: string): Integer; virtual;
    property Item[Index: Integer]: TPItem read GetItem; default;
  end;

  TPImportType = (itInsert, itReplace, itUpdate);
  TPSeparatorType = (stTab, stChar);
  TPUpdateCheckType = (utNever, utDaily);

  TMRUList = class
  private
    FMaxCount: Integer;
    FValues: array of string;
    function GetCount(): Integer;
    function GetValue(Index: Integer): string;
  public
    property Count: Integer read GetCount;
    property MaxCount: Integer read FMaxCount;
    property Values[Index: Integer]: string read GetValue; default;
    procedure Add(const Value: string); virtual;
    procedure Assign(const Source: TMRUList); virtual;
    procedure Clear(); virtual;
    constructor Create(const AMaxCount: Integer); virtual;
    procedure Delete(const Index: Integer);
    destructor Destroy(); override;
    function IndexOf(const Value: string): Integer; virtual;
    procedure LoadFromXML(const XML: IXMLNode; const NodeName: string); virtual;
    procedure SaveToXML(const XML: IXMLNode; const NodeName: string); virtual;
  end;

  TPWindow = class
  private
    FPreferences: TPPreferences;
  protected
    property Preferences: TPPreferences read FPreferences;
    procedure LoadFromXML(const XML: IXMLNode); virtual;
    procedure SaveToXML(const XML: IXMLNode); virtual;
  public
    Height: Integer;
    Width: Integer;
    constructor Create(const APreferences: TPPreferences); virtual;
  end;

  TPDatabase = class(TPWindow)
  end;

  TPDatabases = class
  public
    Height: Integer;
    Left: Integer;
    Top: Integer;
    Width: Integer;
    constructor Create(const APreferences: TPPreferences); virtual;
  end;

  TPEditor = class
  private
    FPreferences: TPPreferences;
  protected
    procedure LoadFromXML(const XML: IXMLNode); virtual;
    procedure SaveToXML(const XML: IXMLNode); virtual;
  public
    AutoIndent: Boolean;
    CodeCompletition: Boolean;
    CodeCompletionTime: Integer;
    ConditionalCommentForeground, ConditionalCommentBackground: TColor;
    ConditionalCommentStyle: TFontStyles;
    CommentForeground, CommentBackground: TColor;
    CommentStyle: TFontStyles;
    CurrRowBGColorEnabled: Boolean;
    CurrRowBGColor: TColor;
    DataTypeForeground, DataTypeBackground: TColor;
    DataTypeStyle: TFontStyles;
    FunctionForeground, FunctionBackground: TColor;
    FunctionStyle: TFontStyles;
    IdentifierForeground, IdentifierBackground: TColor;
    IdentifierStyle: TFontStyles;
    KeywordForeground, KeywordBackground: TColor;
    KeywordStyle: TFontStyles;
    NumberForeground, NumberBackground: TColor;
    NumberStyle: TFontStyles;
    LineNumbers: Boolean;
    LineNumbersForeground, LineNumbersBackground: TColor;
    LineNumbersStyle: TFontStyles;
    RightEdge: Integer;
    StringForeground, StringBackground: TColor;
    StringStyle: TFontStyles;
    SymbolForeground, SymbolBackground: TColor;
    SymbolStyle: TFontStyles;
    TabAccepted: Boolean;
    TabToSpaces: Boolean;
    TabWidth: Integer;
    VariableForeground, VariableBackground: TColor;
    VariableStyle: TFontStyles;
    WordWrap: Boolean;
    constructor Create(const APreferences: TPPreferences); virtual;
  end;

  TPEvent = class(TPWindow)
  end;

  TAJob = class(TPItem)
  private
    function GetJobs(): TAJobs; inline;
  protected
    property Jobs: TAJobs read GetJobs;
  end;

  TPExport = class(TAJob)
  protected
    procedure LoadFromXML(const XML: IXMLNode); override;
    procedure SaveToXML(const XML: IXMLNode); override;
  public
    CSVHeadline: Boolean;
    CSVQuote: Integer;
    CSVQuoteChar: string;
    CSVSeparator: string;
    CSVSeparatorType: TPSeparatorType;
    ExcelHeadline: Boolean;
    HTMLData: Boolean;
    HTMLStructure: Boolean;
    SQLCreateDatabase: Boolean;
    SQLData: Boolean;
    SQLDisableKeys: Boolean;
    SQLDropBeforeCreate: Boolean;
    SQLReplaceData: Boolean;
    SQLStructure: Boolean;
    SQLUseDatabase: Boolean;
    procedure Assign(const Source: TPItem); override;
    constructor Create(const AAItems: TPItems = nil; const AName: string = ''); override;
  end;

  TPField = class(TPWindow)
  end;

  TPFind = class(TPWindow)
  type
    TOption = (foMatchCase, foWholeValue, foRegExpr);
    TOptions = set of TOption;
  protected
    procedure LoadFromXML(const XML: IXMLNode); override;
    procedure SaveToXML(const XML: IXMLNode); override;
  public
    FindTextMRU: TMRUList;
    Left: Integer;
    Options: TOptions;
    Top: Integer;
    constructor Create(const APreferences: TPPreferences); override;
    destructor Destroy(); override;
  end;

  TPHost = class(TPWindow)
  end;

  TPForeignKey = class(TPWindow)
  end;

  TPImport = class
  private
    FPreferences: TPPreferences;
  protected
    procedure LoadFromXML(const XML: IXMLNode); virtual;
    procedure SaveToXML(const XML: IXMLNode); virtual;
  public
    CSVHeadline: Boolean;
    CSVQuote: Integer;
    CSVQuoteChar: string;
    CSVSeparator: string;
    CSVSeparatorType: TPSeparatorType;
    ExcelHeadline: Boolean;
    ImportType: TPImportType;
    ODBCData: Boolean;
    ODBCObjects: Boolean;
    ODBCRowType: Integer;
    SaveErrors: Boolean;
    constructor Create(const APreferences: TPPreferences); virtual;
  end;

  TPIndex = class(TPWindow)
  end;

  TPODBC = class(TPWindow)
  public
    Left: Integer;
    Top: Integer;
    constructor Create(const APreferences: TPPreferences); override;
  end;

  TPPaste = class
  private
    FPreferences: TPPreferences;
  protected
    property Preferences: TPPreferences read FPreferences;
    procedure LoadFromXML(const XML: IXMLNode); virtual;
    procedure SaveToXML(const XML: IXMLNode); virtual;
  public
    Data: Boolean;
    constructor Create(const APreferences: TPPreferences); virtual;
  end;

  TPReplace = class(TPWindow)
  type
    TOption = (roMatchCase, roWholeValue, roRegExpr);
    TOptions = set of TOption;
  protected
    procedure LoadFromXML(const XML: IXMLNode); override;
    procedure SaveToXML(const XML: IXMLNode); override;
  public
    FindTextMRU: TMRUList;
    ReplaceTextMRU: TMRUList;
    Backup: Boolean;
    Left: Integer;
    Options: TOptions;
    Top: Integer;
    constructor Create(const APreferences: TPPreferences); override;
    destructor Destroy(); override;
  end;

  TPRoutine = class(TPWindow)
  end;

  TPServer = class(TPWindow)
  public
    Left: Integer;
    Top: Integer;
    constructor Create(const APreferences: TPPreferences); override;
  end;

  TPSQLHelp = class(TPWindow)
  protected
    procedure LoadFromXML(const XML: IXMLNode); override;
    procedure SaveToXML(const XML: IXMLNode); override;
  public
    Left: Integer;
    Top: Integer;
    constructor Create(const APreferences: TPPreferences); override;
  end;

  TPAccounts = class(TPWindow)
  protected
    procedure LoadFromXML(const XML: IXMLNode); override;
    procedure SaveToXML(const XML: IXMLNode); override;
  public
    SelectOrder: Integer;
    constructor Create(const APreferences: TPPreferences); override;
  end;

  TPStatement = class(TPWindow)
  end;

  TPTable = class(TPWindow)
  end;

  TPTableService = class(TPWindow)
  protected
    procedure LoadFromXML(const XML: IXMLNode); override;
    procedure SaveToXML(const XML: IXMLNode); override;
  public
    Analyze: Boolean;
    Check: Boolean;
    Flush: Boolean;
    Optimize: Boolean;
    Repair: Boolean;
    constructor Create(const APreferences: TPPreferences); override;
  end;

  TPTransfer = class(TPWindow)
  public
    Left: Integer;
    Top: Integer;
  end;

  TPTrigger = class(TPWindow)
  end;

  TPUser = class(TPWindow)
  end;

  TPView = class(TPWindow)
  end;

  TPLanguage = class(TMemIniFile)
  private
    FActiveQueryBuilderLanguageName: string;
    FLanguageId: Integer;
    FStrs: array of string;
    function GetStr(Index: Integer): string;
  protected
    property Strs[Index: Integer]: string read GetStr;
  public
    property ActiveQueryBuilderLanguageName: string read FActiveQueryBuilderLanguageName;
    property LanguageId: Integer read FLanguageId;
    constructor Create(const FileName: string); reintroduce;
    destructor Destroy(); override;
  end;

  TPPreferences = class(TRegistry)
  type
    TToolbarTabs = set of (ttObjects, ttBrowser, ttIDE, ttBuilder, ttEditor, ttDiagram);
  private
    FInternetAgent: string;
    FLanguage: TPLanguage;
    FLargeImages: TImageList;
    FSmallImages: TImageList;
    FVerMajor, FVerMinor, FVerPatch, FVerBuild: Integer;
    FXMLDocument: IXMLDocument;
    OldAssociateSQL: Boolean;
    procedure LoadFromRegistry();
    function GetFilename(): TFileName;
    function GetLanguage(): TPLanguage;
    function GetLanguagePath(): TFileName;
    function GetVersion(var VerMajor, VerMinor, VerPatch, VerBuild: Integer): Boolean;
    function GetVersionInfo(): Integer;
    function GetVersionStr(): string;
    function GetXML(): IXMLNode;
  protected
    KeyBase: string;
    property Filename: TFileName read GetFilename;
    property XML: IXMLNode read GetXML;
  public
    Database: TPDatabase;
    Databases: TPDatabases;
    Editor: TPEditor;
    Event: TPEvent;
    Export: TPExport;
    Field: TPField;
    Find: TPFind;
    ForeignKey: TPForeignKey;
    Host: TPHost;
    Import: TPImport;
    Index: TPIndex;
    ODBC: TPODBC;
    Paste: TPPaste;
    Replace: TPReplace;
    Routine: TPRoutine;
    Server: TPServer;
    SQLHelp: TPSQLHelp;
    Accounts: TPAccounts;
    Statement: TPStatement;
    Table: TPTable;
    TableService: TPTableService;
    Transfer: TPTransfer;
    Trigger: TPTrigger;
    User: TPUser;
    View: TPView;
    SoundFileNavigating: string;
    LanguageFilename: TFileName;
    WindowState: TWindowState;
    Left, Top, Width, Height: Integer;
    AddressBarVisible: Boolean;
    GridFontName: TFontName;
    GridFontStyle: TFontStyles;
    GridFontColor: TColor;
    GridFontSize, GridFontCharset: Integer;
    GridMaxColumnWidth: Integer;
    GridRowBGColorEnabled: Boolean;
    GridCurrRowBGColorEnabled: Boolean;
    GridCurrRowBGColor: TColor;
    GridNullBGColorEnabled: Boolean;
    GridNullBGColor: TColor;
    GridNullText: Boolean;
    GridShowMemoContent: Boolean;
    GridDefaultSorting: Boolean;
    SQLFontName: TFontName;
    SQLFontStyle: TFontStyles;
    SQLFontColor: TColor;
    SQLFontSize, SQLFontCharset: Integer;
    LogFontName: TFontName;
    LogFontStyle: TFontStyles;
    LogFontColor: TColor;
    LogFontSize, LogFontCharset: Integer;
    LogHighlighting: Boolean;
    LogTime: Boolean;
    LogResult: Boolean;
    LogSize: Integer;
    Path: TFileName;
    UserPath: TFileName;
    AssociateSQL: Boolean;
    TabsVisible: Boolean;
    ToolbarTabs: TToolbarTabs;
    UpdateCheck: TPUpdateCheckType;
    UpdateChecked: TDateTime;
    SetupProgram: TFileName;
    SetupProgramInstalled: Boolean;
    property InternetAgent: string read FInternetAgent;
    property Language: TPLanguage read GetLanguage;
    property LanguagePath: TFileName read GetLanguagePath;
    property LargeImages: TImageList read FLargeImages;
    property SmallImages: TImageList read FSmallImages;
    property VerMajor: Integer read FVerMajor;
    property VerMinor: Integer read FVerMinor;
    property VerPatch: Integer read FVerPatch;
    property VerBuild: Integer read FVerBuild;
    property Version: Integer read GetVersionInfo;
    property VersionStr: string read GetVersionStr;
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure LoadFromXML(); virtual;
    function LoadStr(const Index: Integer; const Param1: string = ''; const Param2: string = ''; const Param3: string = ''): string; overload; virtual;
    procedure SaveToRegistry(); virtual;
    procedure SaveToXML(); virtual;
  end;

  TABookmark = class
  private
    FBookmarks: TABookmarks;
    FXML: IXMLNode;
    function GetXML(): IXMLNode;
  protected
    property Bookmarks: TABookmarks read FBookmarks;
    property XML: IXMLNode read GetXML;
  public
    Caption: string;
    URI: string;
    procedure Assign(const Source: TABookmark); virtual;
    constructor Create(const ABookmarks: TABookmarks; const AXML: IXMLNode = nil);
    procedure LoadFromXML(); virtual;
    procedure SaveToXML(); virtual;
  end;

  TABookmarks = class
  private
    FXML: IXMLNode;
    FBookmarks: array of TABookmark;
    FDesktop: TADesktop;
    function GetBookmark(Index: Integer): TABookmark;
    function GetDataPath(): TFileName;
    function GetXML(): IXMLNode;
  protected
    property Desktop: TADesktop read FDesktop;
    property XML: IXMLNode read GetXML;
  public
    function AddBookmark(const NewBookmark: TABookmark): Boolean; virtual;
    function ByCaption(const Caption: string): TABookmark; virtual;
    procedure Clear(); virtual;
    constructor Create(const ADesktop: TADesktop);
    function Count(): Integer; virtual;
    function DeleteBookmark(const Bookmark: TABookmark): Boolean; virtual;
    destructor Destroy(); override;
    function IndexOf(const Bookmark: TABookmark): Integer; virtual;
    procedure LoadFromXML(); virtual;
    procedure MoveBookmark(const Bookmark: TABookmark; const NewIndex: Integer); virtual;
    procedure SaveToXML(); virtual;
    function UpdateBookmark(const Bookmark, NewBookmark: TABookmark): Boolean; virtual;
    property Bookmark[Index: Integer]: TABookmark read GetBookmark; default;
    property DataPath: TFileName read GetDataPath;
  end;

  TAFile = class
  private
    FFiles: TAFiles;
  protected
    FCodePage: Cardinal;
    FFilename: TFileName;
    procedure LoadFromXML(const XML: IXMLNode); virtual;
    procedure SaveToXML(const XML: IXMLNode); virtual;
    property Files: TAFiles read FFiles;
  public
    constructor Create(const AFiles: TAFiles);
    property CodePage: Cardinal read FCodePage write FCodePage;
    property Filename: TFileName read FFilename write FFilename;
  end;

  TAFiles = class(TList)
  private
    FDesktop: TADesktop;
    FMaxCount: Integer;
    FXML: IXMLNode;
    function Get(Index: Integer): TAFile; inline;
    function GetXML(): IXMLNode;
  protected
    procedure LoadFromXML(); virtual;
    procedure SaveToXML(); virtual;
    property Desktop: TADesktop read FDesktop;
    property MaxCount: Integer read FMaxCount;
    property XML: IXMLNode read GetXML;
  public
    procedure Add(const AFilename: TFileName; const ACodePage: Cardinal); reintroduce; virtual;
    procedure Clear(); override;
    constructor Create(const ADesktop: TADesktop; const AMaxCount: Integer);
    property Files[Index: Integer]: TAFile read Get; default;
  end;

  TAJobExport = class(TPExport)
  protected
    function GetXML(): IXMLNode; override;
    procedure LoadFromXML(const XML: IXMLNode); override;
    procedure SaveToXML(const XML: IXMLNode); override;
  public
    CodePage: Integer;
    ExportType: TPExportType;
    Filename: TFileName;
    Objects: TStringList;
    procedure Assign(const Source: TPItem); override;
    constructor Create(const AAItems: TPItems = nil; const AName: string = ''); override;
    destructor Destroy(); override;
  end;

  TAJobs = class(TPItems)
  private
    FAccount: TAAccount;
    FXMLDocument: IXMLDocument;
    function GetJob(Index: Integer): TAJob; inline;
  protected
    function GetXML(): IXMLNode; override;
    property Account: TAAccount read FAccount;
    property XML: IXMLNode read GetXML;
  public
    function AddJob(const NewJob: TPItem): Boolean; virtual;
    constructor Create(const AAccount: TAAccount);
    procedure Delete(const Job: TPItem); overload; virtual;
    destructor Destroy(); override;
    procedure LoadFromXML(); virtual;
    procedure SaveToXML(); virtual;
    property Job[Index: Integer]: TAJob read GetJob; default;
  end;

  TADesktop = class
  type
    TListViewKind = (lkServer, lkDatabase, lkTable, lkHosts, lkProcesses, lkStati, lkUsers, lkVariables);
  private
    FAccount: TAAccount;
    FBookmarks: TABookmarks;
    FFiles: TAFiles;
    FPath: string;
    FXML: IXMLNode;
    function GetAddress(): string;
    function GetXML(): IXMLNode;
    procedure SetAddress(AAddress: string);
  protected
    procedure Assign(const Source: TADesktop); virtual;
    procedure LoadFromXML(); virtual;
    procedure SaveToXML(); virtual;
    property Account: TAAccount read FAccount;
    property XML: IXMLNode read GetXML;
  public
    AddressMRU: TMRUList;
    BookmarksVisible: Boolean;
    ColumnWidths: array [lkServer .. lkVariables] of array [0..7] of Integer;
    DataHeight, BlobHeight: Integer;
    EditorContent: string;
    ExplorerVisible: Boolean;
    FilesFilter: string;
    FoldersHeight: Integer;
    JobsVisible: Boolean;
    LogHeight: Integer;
    LogVisible: Boolean;
    NavigatorVisible: Boolean;
    SelectorWitdth: Integer;
    SQLHistoryVisible: Boolean;
    constructor Create(const AAccount: TAAccount); overload; virtual;
    destructor Destroy(); override;
    property Address: string read GetAddress write SetAddress;
    property Bookmarks: TABookmarks read FBookmarks;
    property Files: TAFiles read FFiles;
  end;

  TAConnection = class
  private
    FXML: IXMLNode;
    FAccount: TAAccount;
    function GetXML(): IXMLNode;
  protected
    Section: string;
    procedure LoadFromXML(); virtual;
    procedure SaveToXML(); virtual;
    property XML: IXMLNode read GetXML;
  public
    Charset: string;
    Database: string;
    Host: string;
    HTTPTunnelURI: string;
    LibraryFilename: TFileName;
    LibraryType: TMySQLLibrary.TLibraryType;
    Password: string;
    PipeName: string;
    Port: Integer;
    User: string;
    procedure Assign(const Source: TAConnection); virtual;
    constructor Create(const AAccount: TAAccount); virtual;
    property Account: TAAccount read FAccount;
  end;

  TAAccount = class
  type
    TEventProc = procedure (const ClassType: TClass) of object;
    TDesktop = record
      Control: Pointer;
      AccountEventProc: TEventProc;
    end;
  private
    FDesktop: TADesktop;
    FDesktopXMLDocument: IXMLDocument;
    FHistoryXMLDocument: IXMLDocument;
    FJobs: TAJobs;
    FLastLogin: TDateTime;
    FName: string;
    FDesktops: array of TDesktop;
    FXML: IXMLNode;
    FAccounts: TAAccounts;
    Modified: Boolean;
    function GetBookmarksFilename(): TFileName;
    function GetDataPath(): TFileName;
    function GetDesktop(): TADesktop;
    function GetDesktopCount(): Integer;
    function GetDesktopFilename(): TFileName;
    function GetDesktopXML(): IXMLNode;
    function GetHistoryFilename(): TFileName;
    function GetHistoryXML(): IXMLNode;
    function GetIconFilename(): TFileName;
    function GetJobs(): TAJobs;
    function GetJobsFilename(): TFileName;
    function GetName(): string;
    function GetXML(): IXMLNode;
    procedure SetLastLogin(const ALastLogin: TDateTime);
    procedure SetName(const AName: string);
  protected
    FImageIndex: Integer;
    Section: string;
    function GetIndex(): Integer;
    procedure LoadFromXML();
    procedure SaveToXML(); virtual;
    procedure AccountEvent(const ClassType: TClass); virtual;
    function ValidDatabaseName(const ADatabaseName: string): Boolean;
    property BookmarksFilename: TFileName read GetBookmarksFilename;
    property DesktopFilename: TFileName read GetDesktopFilename;
    property DesktopXMLDocument: IXMLDocument read FDesktopXMLDocument;
    property HistoryFilename: TFileName read GetHistoryFilename;
    property HistoryXMLDocument: IXMLDocument read FHistoryXMLDocument;
    property JobsFilename: TFileName read GetJobsFilename;
    property XML: IXMLNode read GetXML;
  public
    Connection: TAConnection;
    IconFetched: Boolean;
    ManualURL: string;
    ManualURLFetched: Boolean;
    procedure Assign(const Source: TAAccount); virtual;
    constructor Create(const AAccounts: TAAccounts; const AXML: IXMLNode = nil); virtual;
    destructor Destroy(); override;
    function ExtractPath(const AAddress: string): string; virtual;
    function ExpandAddress(const APath: string): string; virtual;
    function Frame(): Pointer; virtual;
    function GetDefaultDatabase(): string; virtual;
    function JobByName(const Name: string): TAJob; virtual;
    procedure RegisterDesktop(const AControl: Pointer; const AEventProc: TEventProc); virtual;
    procedure UnRegisterDesktop(const AControl: Pointer); virtual;
    property Accounts: TAAccounts read FAccounts;
    property DataPath: TFileName read GetDataPath;
    property Desktop: TADesktop read GetDesktop;
    property DesktopCount: Integer read GetDesktopCount;
    property DesktopXML: IXMLNode read GetDesktopXML;
    property HistoryXML: IXMLNode read GetHistoryXML;
    property IconFilename: TFileName read GetIconFilename;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property Index: Integer read GetIndex;
    property Jobs: TAJobs read GetJobs;
    property LastLogin: TDateTime read FLastLogin write SetLastLogin;
    property Name: string read GetName write SetName;
  end;

  TAAccounts = class(TList)
  type
    TDBLogin = function(const Account: Pointer): Boolean of object;
  private
    DefaultAccountName: string;
    FDBLogin: TDBLogin;
    FXMLDocument: IXMLDocument;
    function GetDataPath(): TFileName;
    function GetDefault(): TAAccount; inline;
    function GetFilename(): TFileName;
    function GetXML(): IXMLNode;
    function GetFAccounts(Index: Integer): TAAccount; inline;
    procedure SetDefault(const AAccount: TAAccount);
  protected
    Section: string;
    property DataPath: TFileName read GetDataPath;
    property Filename: TFileName read GetFilename;
    property XML: IXMLNode read GetXML;
  public
    function AccountByName(const AccountName: string): TAAccount; virtual;
    function AccountByURI(const AURI: string; const DefaultAccount: TAAccount = nil): TAAccount; virtual;
    procedure AddAccount(const NewAccount: TAAccount); virtual;
    procedure AppendIconsToImageList(const AImageList: TImageList; const AAccount: TAAccount = nil); virtual;
    procedure Clear(); override;
    constructor Create(const ADBLogin: TDBLogin);
    function DeleteAccount(const AAccount: TAAccount): Boolean; virtual;
    destructor Destroy(); override;
    procedure LoadFromXML(); virtual;
    procedure SaveToXML(); virtual;
    procedure UpdateAccount(const Account, NewAccount: TAAccount); virtual;
    property Account[Index: Integer]: TAAccount read GetFAccounts; default;
    property Default: TAAccount read GetDefault write SetDefault;
    property DBLogin: TDBLogin read FDBLogin;
  end;

function EncodeVersion(const AMajor, AMinor, APatch, ABuild: Integer): Integer;
function XMLNode(const XML: IXMLNode; const Path: string; const NodeAutoCreate: Boolean = False): IXMLNode; overload;

function IsConnectedToInternet(): Boolean;
function VersionStrToVersion(VersionStr: string): Integer;
function CopyDir(const fromDir, toDir: string): Boolean;
function HostIsLocalhost(const Host: string): Boolean;

var
  Accounts: TAAccounts;
  FileFormatSettings: TFormatSettings;
  Preferences: TPPreferences;

implementation {***************************************************************}

uses
  Consts, CommCtrl, SHFolder, WinInet, ShellAPI, ImgList, ShlObj,
  StrUtils, Variants, Math,
  SysConst, ActiveX,
  RTLConsts, WinSock,
  MySQLConsts,
  CSVUtils,
  fURI;

const
  INTERNET_CONNECTION_CONFIGURED = $40;

function VersionStrToVersion(VersionStr: string): Integer;
begin
  if (Pos('.', VersionStr) = 0) then
    Result := StrToInt(VersionStr) * 10000
  else
    Result := StrToInt(copy(VersionStr, 1, Pos('.', VersionStr) - 1)) * 10000
      + VersionStrToVersion(Copy(VersionStr, Pos('.', VersionStr) + 1, Length(VersionStr) - Pos('.', VersionStr))) div 100;
end;

function IsConnectedToInternet(): Boolean;
var
  ConnectionTypes: DWord;
begin
  ConnectionTypes := INTERNET_CONNECTION_MODEM or INTERNET_CONNECTION_LAN or INTERNET_CONNECTION_PROXY or INTERNET_CONNECTION_CONFIGURED;
  Result := InternetGetConnectedState(@ConnectionTypes, 0);
end;

function CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function TryStrToWindowState(const Str: string; var WindowState: TWindowState): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'NORMAL') then WindowState := wsNormal
  else if (UpperCase(Str) = 'MINIMIZED') then WindowState := wsMinimized
  else if (UpperCase(Str) = 'MAXIMIZED') then WindowState := wsMaximized
  else Result := False;
end;

function WindowStateToStr(const WindowState: TWindowState): string;
begin
  case (WindowState) of
    wsMaximized: Result := 'Maximized';
    else Result := 'Normal';
  end;
end;

function TryStrToQuote(const Str: string; var Quote: Integer): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'NOTHING') then Quote := 0
  else if (UpperCase(Str) = 'STRINGS') then Quote := 1
  else if (UpperCase(Str) = 'ALL') then Quote := 2
  else Result := False;
end;

function QuoteToStr(const Quote: Integer): string;
begin
  case Quote of
    1: Result := 'Stings';
    2: Result := 'All';
    else Result := 'Nothing';
  end;
end;

function TryStrToSeparatorType(const Str: string; var SeparatorType: TPSeparatorType): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'STANDARD') then SeparatorType := stChar
  else if (UpperCase(Str) = 'TAB') then SeparatorType := stTab
  else Result := False;
end;

function SeparatorTypeToStr(const SeparatorType: TPSeparatorType): string;
begin
  case (SeparatorType) of
    stTab: Result := 'Tab';
    else Result := 'Standard';
  end;
end;

function TryStrToImportType(const Str: string; var ImportTypeType: TPImportType): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'INSERT') then ImportTypeType := itInsert
  else if (UpperCase(Str) = 'REPLACE') then ImportTypeType := itReplace
  else if (UpperCase(Str) = 'UPDATE') then ImportTypeType := itUpdate
  else Result := False;
end;

function ImportTypeToStr(const ImportTypeType: TPImportType): string;
begin
  case (ImportTypeType) of
    itReplace: Result := 'Replace';
    itUpdate: Result := 'Update';
    else Result := 'Insert';
  end;
end;

function StrToStyle(const Str: string): TFontStyles;
begin
  Result := [];
  if (Pos('BOLD', UpperCase(Str)) > 0) then Result := Result + [fsBold];
  if (Pos('ITALIC', UpperCase(Str)) > 0) then Result := Result + [fsItalic];
  if (Pos('UNDERLINE', UpperCase(Str)) > 0) then Result := Result + [fsUnderline];
  if (Pos('STRIKEOUT', UpperCase(Str)) > 0) then Result := Result + [fsStrikeOut];
end;

function StyleToStr(const Style: TFontStyles): string;
begin
  Result := '';

  if (fsBold in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'Bold'; end;
  if (fsItalic in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'Italic'; end;
  if (fsUnderline in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'Underline'; end;
  if (fsStrikeOut in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'StrikeOut'; end;
end;

function StrToFindOptions(const Str: string): TPFind.TOptions;
begin
  Result := [];
  if (Pos('MATCHCASE', UpperCase(Str)) > 0) then Result := Result + [foMatchCase];
  if (Pos('WHOLEWORD', UpperCase(Str)) > 0) then Result := Result + [foWholeValue];
  if (Pos('REGEXPR', UpperCase(Str)) > 0) then Result := Result + [foRegExpr];
end;

function FindOptionsToStr(const FindOptions: TPFind.TOptions): string;
begin
  Result := '';

  if (foMatchCase in FindOptions) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'MatchCase'; end;
  if (foWholeValue in FindOptions) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'WholeValue'; end;
  if (foRegExpr in FindOptions) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'RegExpr'; end;
end;

function TryStrToUpdateCheck(const Str: string; var UpdateCheckType: TPUpdateCheckType): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'NEVER') then UpdateCheckType := utNever
  else if (UpperCase(Str) = 'DAILY') then UpdateCheckType := utDaily
  else Result := False;
end;

function UpdateCheckToStr(const UpdateCheck: TPUpdateCheckType): string;
begin
  case UpdateCheck of
    utDaily: Result := 'Daily';
    else Result := 'Never';
  end;
end;

function TryStrToRowType(const Str: string; var RowType: Integer): Boolean;
begin
  Result := True;
  if (Str = '') then RowType := 0
  else if (UpperCase(Str) = 'FIXED') then RowType := 1
  else if (UpperCase(Str) = 'DYNAMIC') then RowType := 2
  else if (UpperCase(Str) = 'COMPRESSED') then RowType := 3
  else if (UpperCase(Str) = 'REDUNDANT') then RowType := 4
  else if (UpperCase(Str) = 'COMPACT') then RowType := 5
  else Result := False;
end;

function RowTypeToStr(const RowType: Integer): string;
begin
  case RowType of
    1: Result := 'Fixed';
    2: Result := 'Dynamic';
    3: Result := 'Compressed';
    4: Result := 'Redundant';
    5: Result := 'Compact';
    else Result := '';
  end;
end;

function EncodeVersion(const AMajor, AMinor, APatch, ABuild: Integer): Integer;
begin
  Result := AMajor * 100000000 + AMinor * 1000000 + APatch * 10000 + ABuild;
end;

function StrToReplaceOptions(const Str: string): TPReplace.TOptions;
begin
  Result := [];
  if (Pos('MATCHCASE', UpperCase(Str)) > 0) then Result := Result + [roMatchCase];
  if (Pos('WHOLEWORD', UpperCase(Str)) > 0) then Result := Result + [roWholeValue];
  if (Pos('REGEXPR', UpperCase(Str)) > 0) then Result := Result + [roRegExpr];
end;

function ReplaceOptionsToStr(const Options: TPReplace.TOptions): string;
begin
  Result := '';

  if (roMatchCase in Options) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'MatchCase'; end;
  if (roWholeValue in Options) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'WholeValue'; end;
  if (roRegExpr in Options) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'RegExpr'; end;
end;

function TryStrToExportType(const Str: string; var ExportType: TPExportType): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'SQLFILE') then ExportType := etSQLFile
  else if (UpperCase(Str) = 'TEXTFILE') then ExportType := etTextFile
  else if (UpperCase(Str) = 'EXCELFILE') then ExportType := etExcelFile
  else if (UpperCase(Str) = 'ACCESSFILE') then ExportType := etAccessFile
  else if (UpperCase(Str) = 'SQLITEFILE') then ExportType := etSQLiteFile
  else if (UpperCase(Str) = 'ODBC') then ExportType := etODBC
  else if (UpperCase(Str) = 'HTMLFILE') then ExportType := etHTMLFile
  else if (UpperCase(Str) = 'XMLFILE') then ExportType := etXMLFile
  else if (UpperCase(Str) = 'PDFFILE') then ExportType := etPDFFile
  else if (UpperCase(Str) = 'PRINTER') then ExportType := etPrinter
  else Result := False;
end;

function ExportTypeToStr(const ExportType: TPExportType): string;
begin
  case (ExportType) of
    etSQLFile: Result := 'SQLFile';
    etTextFile: Result := 'TextFile';
    etExcelFile: Result := 'ExcelFile';
    etAccessFile: Result := 'AccessFile';
    etSQLiteFile: Result := 'SQLiteFile';
    etODBC: Result := 'ODBC';
    etHTMLFile: Result := 'HTMLFile';
    etXMLFile: Result := 'XMLFile';
    etPDFFile: Result := 'PDFFile';
    etPrinter: Result := 'Printer';
    else raise ERangeError.CreateFmt(SPropertyOutOfRange, ['ExportType']);
  end;
end;

function ReplaceEnviromentVariables(const AStr: string): string;
var
  Len: Integer;
begin
  Len := ExpandEnvironmentStrings(PChar(AStr), nil, 0);
  SetLength(Result, Len);
  ExpandEnvironmentStrings(PChar(AStr), PChar(Result), Len);
  if (RightStr(Result, 1) = #0) then
    Delete(Result, Length(Result), 1);
end;

function XMLNode(const XML: IXMLNode; const Path: string; const NodeAutoCreate: Boolean = False): IXMLNode;
var
  ChildKey: string;
  CurrentKey: string;
begin
  if (not Assigned(XML)) then
    Result := nil
  else if (Path = '') then
    Result := XML
  else
  begin
    if (Pos('/', Path) = 0) then
    begin
      CurrentKey := Path;
      ChildKey := '';
    end
    else
    begin
      CurrentKey := Copy(Path, 1, Pos('/', Path) - 1);
      ChildKey := Path; Delete(ChildKey, 1, Length(CurrentKey) + 1);
    end;

    if (Assigned(XML.ChildNodes.FindNode(CurrentKey))) then
      Result := XMLNode(XML.ChildNodes.FindNode(CurrentKey), ChildKey, NodeAutoCreate)
    else if (NodeAutoCreate or (doNodeAutoCreate in XML.OwnerDocument.Options)) then
      Result := XMLNode(XML.AddChild(CurrentKey), ChildKey, NodeAutoCreate)
    else
      Result := nil;
  end;
end;

function GetFileIcon(const CSIDL: Integer): HIcon;
var
  FileInfo: TSHFileInfo;
  PIDL: PItemIDList;
begin
  PIDL := nil;
  SHGetFolderLocation(Application.Handle, CSIDL, 0, 0, PIDL);
  ZeroMemory(@FileInfo, SizeOf(FileInfo));
  SHGetFileInfo(PChar(PIDL), 0, FileInfo, SizeOf(FileInfo), SHGFI_PIDL or SHGFI_ICON or SHGFI_SMALLICON);
  Result := FileInfo.hIcon;
end;

function ViewStyleToInteger(const ViewStyle: TViewStyle): Integer;
begin
  Result := 2;
  case (ViewStyle) of
    vsIcon: Result := 0;
    vsSmallIcon: Result := 1;
    vsList: Result := 2;
    vsReport: Result := 3;
  end;
end;

function TryStrToViewStyle(const Str: string; var ViewStyle: TViewStyle): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'ICON') then ViewStyle := vsIcon
  else if (UpperCase(Str) = 'SMALLICON') then ViewStyle := vsSmallIcon
  else if (UpperCase(Str) = 'LIST') then ViewStyle := vsList
  else if (UpperCase(Str) = 'REPORT') then ViewStyle := vsReport
  else Result := False;
end;

function ViewStyleToStr(const ViewStyle: TViewStyle): string;
begin
  case (ViewStyle) of
    vsIcon: Result := 'Icon';
    vsList: Result := 'List';
    vsReport: Result := 'Report';
    else Result := 'SmallIcon';
  end;
end;

function IntegerToViewStyle(const Int: Integer): TViewStyle;
begin
  Result := vsList;
  case (Int) of
    0: Result := vsIcon;
    1: Result := vsSmallIcon;
    2: Result := vsList;
    3: Result := vsReport;
  end;
end;

function HostIsLocalhost(const Host: string): Boolean;
begin
  Result := (lstrcmpi(PChar(Host), PChar(LOCAL_HOST)) = 0) or (Host = '127.0.0.1') or (Host = '::1');
end;

{ TPItem **********************************************************************}

procedure TPItem.Assign(const Source: TPItem);
begin
  Assert(Assigned(Source) and (Source.ClassType = ClassType));


  FName := Source.Name;
end;

constructor TPItem.Create(const AAItems: TPItems; const AName: string = '');
begin
  inherited Create();

  FAItems := AAItems;
  FName := AName;
end;

function TPItem.GetIndex(): Integer;
begin
  Result := AItems.IndexOf(Self);
end;

function TPItem.GetXML(): IXMLNode;
begin
 raise EAbstractError.Create(SAbstractError);
end;

{ TPItems *********************************************************************}

function TPItems.Add(const AItem: TPItem): Integer;
begin
  if (InsertIndex(AItem.Name, Result)) then
    if (Result < TList(Self).Count) then
      TList(Self).Insert(Result, AItem)
    else
      TList(Self).Add(AItem);
end;

procedure TPItems.Clear();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Item[I].Free();

  inherited;
end;

constructor TPItems.Create();
begin
  inherited;
end;

destructor TPItems.Destroy();
begin

end;

function TPItems.GetItem(Index: Integer): TPItem;
begin
  Result := TPItem(Items[Index]);
end;

function TPItems.IndexByName(const Name: string): Integer;
var
  Left: Integer;
  Mid: Integer;
  Right: Integer;
begin
  Result := -1;

  Left := 0;
  Right := Count - 1;
  while (Left <= Right) do
  begin
    Mid := (Right - Left) div 2 + Left;
    case (lstrcmpi(PChar(Item[Mid].Name), PChar(Name))) of
      -1: Left := Mid + 1;
      0: begin Result := Mid; break; end;
      1: Right := Mid - 1;
    end;
  end;
end;

function TPItems.InsertIndex(const Name: string; out Index: Integer): Boolean;
var
  Left: Integer;
  Mid: Integer;
  Right: Integer;
begin
  Result := True;

  if ((Count = 0) or (lstrcmpi(PChar(Item[Count - 1].Name), PChar(Name)) < 0)) then
    Index := Count
  else
  begin
    Left := 0;
    Right := Count - 1;
    while (Left <= Right) do
    begin
      Mid := (Right - Left) div 2 + Left;
      case (lstrcmpi(PChar(Item[Mid].Name), PChar(Name))) of
        -1: begin Left := Mid + 1;  Index := Mid + 1; end;
        0: begin Result := False; Index := Mid; break; end;
        1: begin Right := Mid - 1; Index := Mid; end;
      end;
    end;

    if (Index < 0) then
      raise ERangeError.CreateFmt(SPropertyOutOfRange, ['Index']);
  end;
end;

{ TMRUList ********************************************************************}

procedure TMRUList.Add(const Value: string);
var
  I: Integer;
  Index: Integer;
begin
  if (Value <> '') then
  begin
    Index := IndexOf(Value);

    if (Index >= 0) then
      Delete(Index);

    while (Length(FValues) >= FMaxCount) do
      Delete(FMaxCount - 1);

    SetLength(FValues, Length(FValues) + 1);
    for I := Length(FValues) - 2 downto 0 do
      FValues[I + 1] := FValues[I];
    FValues[0] := Value;
  end;
end;

procedure TMRUList.Assign(const Source: TMRUList);
var
  I: Integer;
begin
  Clear();

  if (Assigned(Source)) then
  begin
    FMaxCount := Source.MaxCount;
    for I := Source.Count - 1 downto 0 do
      Add(Source.Values[I]);
  end;
end;

procedure TMRUList.Clear();
begin
  SetLength(FValues, 0);
end;

constructor TMRUList.Create(const AMaxCount: Integer);
begin
  FMaxCount := AMaxCount;

  Clear();
end;

procedure TMRUList.Delete(const Index: Integer);
var
  I: Integer;
begin
  if ((Index < 0) or (Length(FValues) <= Index)) then
    raise ERangeError.CreateRes(@SInvalidCurrentItem);

  for I := Index to Length(FValues) - 2 do
    FValues[I] := FValues[I + 1];
  SetLength(FValues, Length(FValues) - 1);
end;

destructor TMRUList.Destroy();
begin
  Clear();

  inherited;
end;

function TMRUList.GetCount(): Integer;
begin
  Result := Length(FValues);
end;

function TMRUList.GetValue(Index: Integer): string;
begin
  Result := FValues[Index];
end;

function TMRUList.IndexOf(const Value: string): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Length(FValues) - 1 do
    if (lstrcmpi(PChar(Value), PChar(FValues[I])) = 0) then
      Result := I;
end;

procedure TMRUList.LoadFromXML(const XML: IXMLNode; const NodeName: string);
var
  I: Integer;
begin
  Clear();
  for I := 0 to XML.ChildNodes.Count - 1 do
    if ((XML.ChildNodes[I].NodeName = NodeName) and (Length(FValues) < MaxCount)) then
    begin
      SetLength(FValues, Length(FValues) + 1);
      FValues[Length(FValues) - 1] := XML.ChildNodes[I].Text;
    end;
end;

procedure TMRUList.SaveToXML(const XML: IXMLNode; const NodeName: string);
var
  I: Integer;
begin
  for I := XML.ChildNodes.Count - 1 downto 0 do
    if (XML.ChildNodes[I].NodeName = NodeName) then
      XML.ChildNodes.Delete(I);
  for I := 0 to Count - 1 do
    XML.AddChild(NodeName).Text := Values[I];
end;

{ TPWindow ******************************************************************}

constructor TPWindow.Create(const APreferences: TPPreferences);
begin
  FPreferences := APreferences;

  Height := -1;
  Width := -1;
end;

procedure TPWindow.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'height'))) then TryStrToInt(XMLNode(XML, 'height').Text, Height);
  if (Assigned(XMLNode(XML, 'width'))) then TryStrToInt(XMLNode(XML, 'width').Text, Width);
end;

procedure TPWindow.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'height').Text := IntToStr(Height);
  XMLNode(XML, 'width').Text := IntToStr(Width);
end;

{ TPDatabases *****************************************************************}

constructor TPDatabases.Create(const APreferences: TPPreferences);
begin
  Height := -1;
  Left := -1;
  Top := -1;
  Width := -1;
end;

{ TPEditor ********************************************************************}

constructor TPEditor.Create(const APreferences: TPPreferences);
begin
  FPreferences := APreferences;

  AutoIndent := True;
  CodeCompletition := True;
  CodeCompletionTime := 1000;
  ConditionalCommentForeground := clTeal; ConditionalCommentBackground := clNone; ConditionalCommentStyle := [];
  CommentForeground := clGreen; CommentBackground := clNone; CommentStyle := [fsItalic];
  CurrRowBGColorEnabled := True; CurrRowBGColor := $C0FFFF;
  DataTypeForeground := clMaroon; DataTypeBackground := clNone; DataTypeStyle := [fsBold];
  FunctionForeground := clNavy; FunctionBackground := clNone; FunctionStyle := [fsBold];
  IdentifierForeground := clNone; IdentifierBackground := clNone; IdentifierStyle := [];
  KeywordForeground := clNavy; KeywordBackground := clNone; KeywordStyle := [fsBold];
  LineNumbers := True;
  LineNumbersForeground := clNavy; LineNumbersBackground := clNone; LineNumbersStyle := [];
  NumberForeground := clBlue; NumberBackground := clNone; NumberStyle := [];
  RightEdge := 80;
  StringForeground := clBlue; StringBackground := clNone; StringStyle := [];
  SymbolForeground := clNone; SymbolBackground := clNone; SymbolStyle := [];
  TabAccepted := True;
  TabToSpaces := True;
  TabWidth := 4;
  VariableForeground := clGreen; VariableBackground := clNone; VariableStyle := [];
  WordWrap := False;
end;

procedure TPEditor.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'autoindent'))) then TryStrToBool(XMLNode(XML, 'autoindent').Attributes['enabled'], AutoIndent);
  if (Assigned(XMLNode(XML, 'autocompletition'))) then TryStrToBool(XMLNode(XML, 'autocompletition').Attributes['enabled'], CodeCompletition);
  if (Assigned(XMLNode(XML, 'autocompletition/time'))) then TryStrToInt(XMLNode(XML, 'autocompletition/time').Text, CodeCompletionTime);
  if (Assigned(XMLNode(XML, 'currentrow/background'))) then TryStrToBool(XMLNode(XML, 'currentrow/background').Attributes['visible'], CurrRowBGColorEnabled);
  if (Assigned(XMLNode(XML, 'currentrow/background/color'))) then CurrRowBGColor := StringToColor(XMLNode(XML, 'currentrow/background/color').Text);
  if (Assigned(XMLNode(XML, 'linenumbers'))) then TryStrToBool(XMLNode(XML, 'linenumbers').Attributes['visible'], LineNumbers);
  if (Assigned(XMLNode(XML, 'rightedge/position'))) then TryStrToInt(XMLNode(XML, 'rightedge/position').Text, RightEdge);
  if (Assigned(XMLNode(XML, 'tabs'))) then TryStrToBool(XMLNode(XML, 'tabs').Attributes['accepted'], TabAccepted);
  if (Assigned(XMLNode(XML, 'tabs'))) then TryStrToBool(XMLNode(XML, 'tabs').Attributes['tospace'], TabToSpaces);
  if (Assigned(XMLNode(XML, 'tabs/size'))) then TryStrToInt(XMLNode(XML, 'tabs/size').Text, TabWidth);
  if (Assigned(XMLNode(XML, 'wordwrap'))) then TryStrToBool(XMLNode(XML, 'wordwrap').Text, WordWrap);
end;

procedure TPEditor.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'autoindent').Attributes['enabled'] := AutoIndent;
  XMLNode(XML, 'autocompletition').Attributes['enabled'] := CodeCompletition;
  XMLNode(XML, 'autocompletition/time').Text := IntToStr(CodeCompletionTime);
  XMLNode(XML, 'currentrow/background').Attributes['visible'] := CurrRowBGColorEnabled;
  XMLNode(XML, 'currentrow/background/color').Text := ColorToString(CurrRowBGColor);
  XMLNode(XML, 'linenumbers').Attributes['visible'] := LineNumbers;
  XMLNode(XML, 'rightedge').Attributes['visible'] := RightEdge > 0;
  XMLNode(XML, 'rightedge/position').Text := IntToStr(RightEdge);
  XMLNode(XML, 'tabs').Attributes['accepted'] := TabAccepted;
  XMLNode(XML, 'tabs').Attributes['tospace'] := TabToSpaces;
  XMLNode(XML, 'tabs/size').Text := IntToStr(TabWidth);
  XMLNode(XML, 'wordwrap').Text := BoolToStr(WordWrap, True);
end;

{ TPExport ********************************************************************}

procedure TPExport.Assign(const Source: TPItem);
begin
  Assert(Source is TPExport);

  inherited Assign(Source);

  CSVHeadline := TPExport(Source).CSVHeadline;
  CSVQuote := TPExport(Source).CSVQuote;
  CSVQuoteChar := TPExport(Source).CSVQuoteChar;
  CSVSeparator := TPExport(Source).CSVSeparator;
  CSVSeparatorType := TPExport(Source).CSVSeparatorType;
  ExcelHeadline := TPExport(Source).ExcelHeadline;
  HTMLData := TPExport(Source).HTMLData;
  HTMLStructure := TPExport(Source).HTMLStructure;
  SQLCreateDatabase := TPExport(Source).SQLCreateDatabase;
  SQLData := TPExport(Source).SQLData;
  SQLDisableKeys := TPExport(Source).SQLDisableKeys;
  SQLDropBeforeCreate := TPExport(Source).SQLDropBeforeCreate;
  SQLReplaceData := TPExport(Source).SQLReplaceData;
  SQLStructure := TPExport(Source).SQLStructure;
  SQLUseDatabase := TPExport(Source).SQLUseDatabase;
end;

constructor TPExport.Create(const AAItems: TPItems = nil; const AName: string = '');
begin
  inherited;

  CSVHeadline := True;
  CSVQuote := 1;
  CSVQuoteChar := '"';
  CSVSeparator := ',';
  CSVSeparatorType := stChar;
  ExcelHeadline := False;
  HTMLData := True;
  HTMLStructure := False;
  SQLCreateDatabase := False;
  SQLData := True;
  SQLDisableKeys := True;
  SQLDropBeforeCreate := True;
  SQLStructure := True;
  SQLReplaceData := False;
  SQLUseDatabase := False;
end;

procedure TPExport.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'csv/headline'))) then TryStrToBool(XMLNode(XML, 'csv/headline').Attributes['enabled'], CSVHeadline);
  if (Assigned(XMLNode(XML, 'csv/quote/string'))) then CSVQuoteChar := XMLNode(XML, 'csv/quote/string').Text;
  if (Assigned(XMLNode(XML, 'csv/quote/type'))) then TryStrToQuote(XMLNode(XML, 'csv/quote/type').Text, CSVQuote);
  if (Assigned(XMLNode(XML, 'csv/separator/character/string'))) then CSVSeparator := XMLNode(XML, 'csv/separator/character/string').Text;
  if (Assigned(XMLNode(XML, 'csv/separator/character/type'))) then TryStrToSeparatorType(XMLNode(XML, 'csv/separator/character/type').Text, CSVSeparatorType);
  if (Assigned(XMLNode(XML, 'excel/headline'))) then TryStrToBool(XMLNode(XML, 'excel/headline').Attributes['enabled'], ExcelHeadline);
  if (Assigned(XMLNode(XML, 'html/data'))) then TryStrToBool(XMLNode(XML, 'html/data').Attributes['enabled'], HTMLData);
  if (Assigned(XMLNode(XML, 'html/structure'))) then TryStrToBool(XMLNode(XML, 'html/structure').Attributes['enabled'], HTMLStructure);
  if (Assigned(XMLNode(XML, 'sql/data'))) then TryStrToBool(XMLNode(XML, 'sql/data').Attributes['enabled'], SQLData);
  if (Assigned(XMLNode(XML, 'sql/data'))) then TryStrToBool(XMLNode(XML, 'sql/data').Attributes['replace'], SQLReplaceData);
  if (Assigned(XMLNode(XML, 'sql/data'))) then TryStrToBool(XMLNode(XML, 'sql/data').Attributes['disablekeys'], SQLDisableKeys);
  if (Assigned(XMLNode(XML, 'sql/structure'))) then TryStrToBool(XMLNode(XML, 'sql/structure').Attributes['enabled'], SQLStructure);
  if (Assigned(XMLNode(XML, 'sql/structure'))) then TryStrToBool(XMLNode(XML, 'sql/structure').Attributes['drop'], SQLDropBeforeCreate);
  if (Assigned(XMLNode(XML, 'sql/structure/database'))) then TryStrToBool(XMLNode(XML, 'sql/structure/database').Attributes['create'], SQLCreateDatabase);
  if (Assigned(XMLNode(XML, 'sql/structure/database'))) then TryStrToBool(XMLNode(XML, 'sql/structure/database').Attributes['change'], SQLUseDatabase);
end;

procedure TPExport.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'csv/headline').Attributes['enabled'] := CSVHeadline;
  XMLNode(XML, 'csv/quote/string').Text := CSVQuoteChar;
  XMLNode(XML, 'csv/quote/type').Text := QuoteToStr(CSVQuote);
  XMLNode(XML, 'csv/separator/character/string').Text := CSVSeparator;
  XMLNode(XML, 'csv/separator/character/type').Text := SeparatorTypeToStr(CSVSeparatorType);
  XMLNode(XML, 'excel/headline').Attributes['enabled'] := ExcelHeadline;
  XMLNode(XML, 'html/data').Attributes['enabled'] := HTMLData;
  XMLNode(XML, 'html/structure').Attributes['enabled'] := HTMLStructure;
  XMLNode(XML, 'sql/data').Attributes['enabled'] := SQLData;
  XMLNode(XML, 'sql/data').Attributes['replace'] := SQLReplaceData;
  XMLNode(XML, 'sql/data').Attributes['disablekeys'] := SQLDisableKeys;
  XMLNode(XML, 'sql/structure').Attributes['enabled'] := SQLStructure;
  XMLNode(XML, 'sql/structure').Attributes['drop'] := SQLDropBeforeCreate;
  XMLNode(XML, 'sql/structure/database').Attributes['create'] := SQLCreateDatabase;
  XMLNode(XML, 'sql/structure/database').Attributes['change'] := SQLUseDatabase;
end;

{ TPFind **********************************************************************}

constructor TPFind.Create(const APreferences: TPPreferences);
begin
  inherited;

  FindTextMRU := TMRUList.Create(10);
  Left := -1;
  Options := [foMatchCase];
  Top := -1;
end;

destructor TPFind.Destroy();
begin
  FindTextMRU.Free();

  inherited;
end;

procedure TPFind.LoadFromXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  FindTextMRU.Clear();
  if (Assigned(XMLNode(XML, 'findtext/mru'))) then
    for I := XMLNode(XML, 'findtext/mru').ChildNodes.Count - 1 downto 0 do
      if (XMLNode(XML, 'findtext/mru').ChildNodes[I].NodeName = 'text') then
        FindTextMRU.Add(XMLNode(XML, 'findtext/mru').ChildNodes[I].Text);
  if (Assigned(XMLNode(XML, 'options'))) then Options := StrToFindOptions(XMLNode(XML, 'options').Text);
end;

procedure TPFind.SaveToXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  XMLNode(XML, 'findtext/mru').ChildNodes.Clear();
  for I := 0 to FindTextMRU.Count - 1 do
    XMLNode(XML, 'findtext/mru').AddChild('text').Text := FindTextMRU.Values[I];
  XMLNode(XML, 'options').Text := FindOptionsToStr(Options);
end;

{ TPImport ********************************************************************}

constructor TPImport.Create(const APreferences: TPPreferences);
begin
  FPreferences := APreferences;

  CSVHeadline := True;
  CSVQuote := 1;
  CSVQuoteChar := '"';
  CSVSeparator := ',';
  CSVSeparatorType := stChar;
  ExcelHeadline := False;
  ImportType := itInsert;
  ODBCData := True;
  ODBCObjects := True;
  ODBCRowType := 0;
  SaveErrors := True;
end;

procedure TPImport.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'csv/headline'))) then TryStrToBool(XMLNode(XML, 'csv/headline').Attributes['enabled'], CSVHeadline);
  if (Assigned(XMLNode(XML, 'csv/quote/string'))) then CSVQuoteChar := XMLNode(XML, 'csv/quote/string').Text;
  if (Assigned(XMLNode(XML, 'csv/quote/type'))) then TryStrToQuote(XMLNode(XML, 'csv/quote/type').Text, CSVQuote);
  if (Assigned(XMLNode(XML, 'csv/separator/character/string'))) then CSVSeparator := XMLNode(XML, 'csv/separator/character/string').Text;
  if (Assigned(XMLNode(XML, 'csv/separator/character/type'))) then TryStrToSeparatorType(XMLNode(XML, 'csv/separator/character/type').Text, CSVSeparatorType);
  if (Assigned(XMLNode(XML, 'data/importtype'))) then TryStrToImportType(XMLNode(XML, 'data/importtype').Text, ImportType);
  if (Assigned(XMLNode(XML, 'errors/save'))) then TryStrToBool(XMLNode(XML, 'errors/save').Text, SaveErrors);
  if (Assigned(XMLNode(XML, 'excel/headline'))) then TryStrToBool(XMLNode(XML, 'excel/headline').Attributes['enabled'], ExcelHeadline);
  if (Assigned(XMLNode(XML, 'odbc/data'))) then TryStrToBool(XMLNode(XML, 'odbc/data').Attributes['enabled'], ODBCData);
  if (Assigned(XMLNode(XML, 'odbc/objects'))) then TryStrToBool(XMLNode(XML, 'odbc/objects').Attributes['enabled'], ODBCObjects);
  if (Assigned(XMLNode(XML, 'odbc/rowformat'))) then TryStrToRowType(XMLNode(XML, 'odbc/rowformat').Text, ODBCRowType);
end;

procedure TPImport.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'csv/headline').Attributes['enabled'] := CSVHeadline;
  XMLNode(XML, 'csv/quote/string').Text := CSVQuoteChar;
  XMLNode(XML, 'csv/quote/type').Text := QuoteToStr(CSVQuote);
  XMLNode(XML, 'csv/separator/character/string').Text := CSVSeparator;
  XMLNode(XML, 'csv/separator/character/type').Text := SeparatorTypeToStr(CSVSeparatorType);
  XMLNode(XML, 'data/importtype').Text := ImportTypeToStr(ImportType);
  XMLNode(XML, 'errors/save').Text := BoolToStr(SaveErrors, True);
  XMLNode(XML, 'excel/headline').Attributes['enabled'] := ExcelHeadline;
  XMLNode(XML, 'odbc/data').Attributes['enabled'] := ODBCData;
  XMLNode(XML, 'odbc/objects').Attributes['enabled'] := ODBCObjects;
  XMLNode(XML, 'odbc/rowformat').Text := RowTypeToStr(ODBCRowType);
end;

{ TPODBC **********************************************************************}

constructor TPODBC.Create(const APreferences: TPPreferences);
begin
  inherited;

  Left := -1;
  Top := -1;
end;

{ TPPaste *********************************************************************}

constructor TPPaste.Create(const APreferences: TPPreferences);
begin
  FPreferences := APreferences;

  Data := True;
end;

procedure TPPaste.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'data'))) then TryStrToBool(XMLNode(XML, 'data').Text, Data);
end;

procedure TPPaste.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'data').Text := BoolToStr(Data, True);
end;

{ TPReplace *******************************************************************}

constructor TPReplace.Create(const APreferences: TPPreferences);
begin
  inherited;

  FindTextMRU := TMRUList.Create(10);
  ReplaceTextMRU := TMRUList.Create(10);
  Backup := True;
  Left := -1;
  Options := [roMatchCase];
  Top := -1;
end;

destructor TPReplace.Destroy();
begin
  FindTextMRU.Free();
  ReplaceTextMRU.Free();

  inherited;
end;

procedure TPReplace.LoadFromXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  if (Assigned(XMLNode(XML, 'backup'))) then TryStrToBool(XMLNode(XML, 'backup').Attributes['enabled'], Backup);
  FindTextMRU.Clear();
  if (Assigned(XMLNode(XML, 'findtext/mru'))) then
    for I := XMLNode(XML, 'findtext/mru').ChildNodes.Count - 1 downto 0 do
      if (XMLNode(XML, 'findtext/mru').ChildNodes[I].NodeName = 'text') then
        FindTextMRU.Add(XMLNode(XML, 'findtext/mru').ChildNodes[I].Text);
  if (Assigned(XMLNode(XML, 'options'))) then Options := StrToReplaceOptions(XMLNode(XML, 'options').Text);
  ReplaceTextMRU.Clear();
  if (Assigned(XMLNode(XML, 'replacetext/mru'))) then
    for I := XMLNode(XML, 'replacetext/mru').ChildNodes.Count - 1 downto 0 do
      if (XMLNode(XML, 'replacetext/mru').ChildNodes[I].NodeName = 'text') then
        ReplaceTextMRU.Add(XMLNode(XML, 'replacetext/mru').ChildNodes[I].Text);
end;

procedure TPReplace.SaveToXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  XMLNode(XML, 'backup').Attributes['enabled'] := Backup;
  XMLNode(XML, 'findtext/mru').ChildNodes.Clear();
  for I := 0 to FindTextMRU.Count - 1 do
    XMLNode(XML, 'findtext/mru').AddChild('text').Text := FindTextMRU.Values[I];
  XMLNode(XML, 'options').Text := ReplaceOptionsToStr(Options);
  XMLNode(XML, 'replacetext/mru').ChildNodes.Clear();
  for I := 0 to ReplaceTextMRU.Count - 1 do
    XMLNode(XML, 'replacetext/mru').AddChild('text').Text := ReplaceTextMRU.Values[I];
end;

{ TPServer ********************************************************************}

constructor TPServer.Create(const APreferences: TPPreferences);
begin
  inherited;

  Left := -1;
  Top := -1;
end;

{ TPSQLHelp *******************************************************************}

constructor TPSQLHelp.Create(const APreferences: TPPreferences);
begin
  inherited;

  Left := -1;
  Top := -1;
end;

procedure TPSQLHelp.LoadFromXML(const XML: IXMLNode);
begin
  inherited;

  if (Assigned(XMLNode(XML, 'left'))) then TryStrToInt(XMLNode(XML, 'left').Text, Left);
  if (Assigned(XMLNode(XML, 'top'))) then TryStrToInt(XMLNode(XML, 'top').Text, Top);
end;

procedure TPSQLHelp.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'left').Text := IntToStr(Left);
  XMLNode(XML, 'top').Text := IntToStr(Top);
end;

{ TPAccounts ******************************************************************}

constructor TPAccounts.Create(const APreferences: TPPreferences);
begin
  inherited;

  SelectOrder := 0;
end;

procedure TPAccounts.LoadFromXML(const XML: IXMLNode);
begin
  inherited;

  if (Assigned(XMLNode(XML, 'selectorder'))) then TryStrToInt(XMLNode(XML, 'selectorder').Text, SelectOrder);
end;

procedure TPAccounts.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'selectorder').Text := IntToStr(SelectOrder);
end;

{ TPTableService **************************************************************}

constructor TPTableService.Create(const APreferences: TPPreferences);
begin
  inherited;

  Analyze := False;
  Check := False;
  Flush := False;
  Optimize := False;
  Repair := False;
end;

procedure TPTableService.LoadFromXML(const XML: IXMLNode);
begin
  inherited;

  if (Assigned(XMLNode(XML, 'analyze'))) then TryStrToBool(XMLNode(XML, 'analyze').Attributes['enabled'], Analyze);
  if (Assigned(XMLNode(XML, 'check'))) then TryStrToBool(XMLNode(XML, 'check').Attributes['enabled'], Check);
  if (Assigned(XMLNode(XML, 'flush'))) then TryStrToBool(XMLNode(XML, 'flush').Attributes['enabled'], Flush);
  if (Assigned(XMLNode(XML, 'optimize'))) then TryStrToBool(XMLNode(XML, 'optimize').Attributes['enabled'], Optimize);
  if (Assigned(XMLNode(XML, 'repair'))) then TryStrToBool(XMLNode(XML, 'repair').Attributes['enabled'], Repair);
end;

procedure TPTableService.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'analyze').Attributes['enabled'] := Analyze;
  XMLNode(XML, 'check').Attributes['enabled'] := Check;
  XMLNode(XML, 'flush').Attributes['enabled'] := Flush;
  XMLNode(XML, 'optimize').Attributes['enabled'] := Optimize;
  XMLNode(XML, 'repair').Attributes['enabled'] := Repair;
end;

{ TPTransfer ******************************************************************}

{ TPLanguage ******************************************************************}

constructor TPLanguage.Create(const FileName: string);
var
  I: Integer;
  Item: Integer;
  MaxItem: Integer;
  Strings: TStringList;
begin
  inherited;

  FActiveQueryBuilderLanguageName := 'English';
  if (not FileExists(Filename)) then
    FLanguageId := LANG_NEUTRAL
  else
  begin
    FLanguageId := ReadInteger('Global', 'LanguageId', LANG_NEUTRAL);
    FActiveQueryBuilderLanguageName := ReadString('Global', 'ActiveQueryBuilderLanguage', 'English');

    Strings := TStringList.Create();

    ReadSectionValues('Strings', Strings);

    MaxItem := 0;
    for I := 0 to Strings.Count - 1 do
      if (TryStrToInt(Strings.Names[I], Item)) then
        MaxItem := Item;

    SetLength(FStrs, MaxItem + 1);

    for I := 0 to Strings.Count - 1 do
      if (TryStrToInt(Strings.Names[I], Item)) then
        FStrs[Item] := Strings.ValueFromIndex[I];

    Strings.Free();
  end;
end;

destructor TPLanguage.Destroy();
begin
  SetLength(FStrs, 0);

  inherited;
end;

function TPLanguage.GetStr(Index: Integer): string;
begin
  if ((Index >= Length(FStrs)) or (FStrs[Index] = '')) then
    Result := SysUtils.LoadStr(10000 + Index)
  else
    Result := FStrs[Index];

  Result := ReplaceStr(ReplaceStr(Trim(Result), '\n', #10), '\r', #13);
end;

{ TPPreferences ***************************************************************}

constructor TPPreferences.Create();
var
  MaxIconIndex: Integer;
  Font: TFont;
  FontSize: Integer;
  Foldername: array [0..MAX_PATH] of Char;
  I: Integer;
  NonClientMetrics: TNonClientMetrics;
  Path: string;
  StringList: TStringList;
begin
  inherited Create(KEY_ALL_ACCESS);

  FXMLDocument := nil;

  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
  if (not SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NonClientMetrics), @NonClientMetrics, 0)) then
    FontSize := 9
  else
  begin
    Font := TFont.Create();
    Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
    FontSize := Font.Size;
    Font.Free();
  end;

  WindowState := wsNormal;
  Top := 0;
  Left := 0;
  Height := 0;
  Width := 0;
  AddressBarVisible := False;
  GridFontName := 'Microsoft Sans Serif';
  GridFontColor := clWindowText;
  GridFontStyle := [];
  GridFontSize := FontSize;
  GridFontCharset := DEFAULT_CHARSET;
  GridMaxColumnWidth := 100;
  GridRowBGColorEnabled := True;
  GridCurrRowBGColor := $C0FFFF;
  GridCurrRowBGColorEnabled := True;
  GridNullBGColorEnabled := False;
  GridNullBGColor := $E0F0E0;
  GridNullText := True;
  GridShowMemoContent := False;
  GridDefaultSorting := True;
  SQLFontName := 'Courier New';
  SQLFontColor := clWindowText;
  SQLFontStyle := [];
  SQLFontSize := FontSize;
  SQLFontCharset := DEFAULT_CHARSET;
  LogFontName := 'Courier New';
  LogFontColor := clWindowText;
  LogFontStyle := [];
  LogFontSize := 8;
  LogFontCharset := DEFAULT_CHARSET;
  LogHighlighting := False;
  LogTime := False;
  LogResult := False;
  LogSize := 100 * 1024;
  LanguageFilename := 'English.ini';
  TabsVisible := False;
  ToolbarTabs := [ttObjects, ttBrowser, ttEditor];
  UpdateCheck := utNever;
  UpdateChecked := Now();


  KeyBase := SysUtils.LoadStr(1003);
  GetVersion(FVerMajor, FVerMinor, FVerPatch, FVerBuild);
  {$IFDEF Debug}
  if (SysUtils.LoadStr(1000) = '') then
    FInternetAgent := 'MySQL-Front'
  else
  {$ENDIF}
  FInternetAgent := SysUtils.LoadStr(1000) + '/' + IntToStr(VerMajor) + '.' + IntToStr(VerMinor);
  SHGetFolderPath(Application.Handle, CSIDL_PERSONAL, 0, 0, @Foldername);
  Path := IncludeTrailingPathDelimiter(PChar(@Foldername));
  if ((FileExists(ExtractFilePath(Application.ExeName) + '\Desktop.xml')) or (SHGetFolderPath(Application.Handle, CSIDL_APPDATA, 0, 0, @Foldername) <> S_OK)) then
    UserPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
  {$IFDEF Debug}
  else if (SysUtils.LoadStr(1002) = '') then
    UserPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(PChar(@Foldername)) + 'MySQL-Front')
  {$ENDIF}
  else
    UserPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(PChar(@Foldername)) + SysUtils.LoadStr(1002));

  SoundFileNavigating := '';
  if (OpenKeyReadOnly('\AppEvents\Schemes\Apps\Explorer\Navigating\.Current')) then
  begin
    if (ValueExists('')) then
      SoundFileNavigating := ReplaceEnviromentVariables(ReadString(''));

    CloseKey();
  end;


  if (DirectoryExists(PChar(@Foldername) + PathDelim + 'SQL-Front' + PathDelim)
    and not DirectoryExists(UserPath)) then
  begin
    Path := PChar(@Foldername) + PathDelim + 'SQL-Front' + PathDelim;
    CopyDir(Path, UserPath);
    StringList := TStringList.Create();
    StringList.LoadFromFile(Filename);
    StringList.Text := ReplaceStr(StringList.Text, '<session', '<account');
    StringList.Text := ReplaceStr(StringList.Text, '</session', '</account');
    StringList.SaveToFile(Filename);
    StringList.Free();
  end;


  MaxIconIndex := 0;
  for I := 1 to 200 do
    if (FindResource(HInstance, MAKEINTRESOURCE(10000 + I), RT_GROUP_ICON) > 0) then
      MaxIconIndex := I;

  FSmallImages := TImageList.Create(nil);
  FSmallImages.ColorDepth := cd32Bit;
  FSmallImages.Height := GetSystemMetrics(SM_CYSMICON);
  FSmallImages.Width := GetSystemMetrics(SM_CXSMICON);

  for I := 0 to MaxIconIndex do
    if (I = 13) then
      ImageList_AddIcon(FSmallImages.Handle, GetFileIcon(CSIDL_DRIVES))
    else if (FindResource(HInstance, MAKEINTRESOURCE(10000 + I), RT_GROUP_ICON) > 0) then
      ImageList_AddIcon(FSmallImages.Handle, LoadImage(hInstance, MAKEINTRESOURCE(10000 + I), IMAGE_ICON, GetSystemMetrics(SM_CYSMICON), GetSystemMetrics(SM_CXSMICON), LR_DEFAULTCOLOR))
    else if (I > 0) then
      ImageList_AddIcon(FSmallImages.Handle, ImageList_GetIcon(FSmallImages.Handle, 0, 0));

  FLargeImages := TImageList.Create(nil);
  FLargeImages.ColorDepth := cd32Bit;
  FLargeImages.Height := 24;
  FLargeImages.Width := 24;

  for I := 0 to MaxIconIndex do
    if (FindResource(HInstance, MAKEINTRESOURCE(10000 + I), RT_GROUP_ICON) > 0) then
      ImageList_AddIcon(FLargeImages.Handle, LoadImage(hInstance, MAKEINTRESOURCE(10000 + I), IMAGE_ICON, FLargeImages.Height, FLargeImages.Width, LR_DEFAULTCOLOR))
    else
      ImageList_AddIcon(FLargeImages.Handle, ImageList_GetIcon(FSmallImages.Handle, I, 0));


  Database := TPDatabase.Create(Self);
  Databases := TPDatabases.Create(Self);
  Editor := TPEditor.Create(Self);
  Event := TPEvent.Create(Self);
  Export := TPExport.Create();
  Field := TPField.Create(Self);
  Find := TPFind.Create(Self);
  ForeignKey := TPForeignKey.Create(Self);
  Host := TPHost.Create(Self);
  Import := TPImport.Create(Self);
  Index := TPIndex.Create(Self);
  ODBC := TPODBC.Create(Self);
  Paste := TPPaste.Create(Self);
  Replace := TPReplace.Create(Self);
  Routine := TPRoutine.Create(Self);
  Server := TPServer.Create(Self);
  Accounts := TPAccounts.Create(Self);
  SQLHelp := TPSQLHelp.Create(Self);
  Statement := TPStatement.Create(Self);
  Table := TPTable.Create(Self);
  TableService := TPTableService.Create(Self);
  Transfer := TPTransfer.Create(Self);
  Trigger := TPTrigger.Create(Self);
  User := TPUser.Create(Self);
  View := TPView.Create(Self);

  LoadFromRegistry();
  LoadFromXML();
end;

destructor TPPreferences.Destroy();
begin
  SaveToRegistry();

  Database.Free();
  Databases.Free();
  Editor.Free();
  Event.Free();
  Export.Free();
  Field.Free();
  Find.Free();
  ForeignKey.Free();
  Host.Free();
  Import.Free();
  Index.Free();
  ODBC.Free();
  Paste.Free();
  Replace.Free();
  Routine.Free();
  Server.Free();
  Accounts.Free();
  SQLHelp.Free();
  Statement.Free();
  Table.Free();
  TableService.Free();
  Transfer.Free();
  Trigger.Free();
  User.Free();
  View.Free();

  FLargeImages.Free();
  FSmallImages.Free();

  if (Assigned(FLanguage)) then
    FLanguage.Free();

  inherited;
end;

function TPPreferences.GetFilename(): TFileName;
begin
  Result := UserPath + 'Desktop.xml';
end;

function TPPreferences.GetLanguage(): TPLanguage;
begin
  if (not Assigned(FLanguage)) then
    FLanguage := TPLanguage.Create(LanguagePath + LanguageFilename);

  Result := FLanguage;
end;

function TPPreferences.GetLanguagePath(): TFileName;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName) + 'Languages');

  {$IFDEF Debug}
    if (not FileExists(Result)) then
      Result := IncludeTrailingPathDelimiter('..\Languages\');
  {$ENDIF}
end;

function TPPreferences.GetVersion(var VerMajor, VerMinor, VerPatch, VerBuild: Integer): Boolean;
var
  Buffer: PChar;
  BufferSize: Cardinal;
  FileInfo: ^VS_FIXEDFILEINFO;
  FileInfoSize: UINT;
  FileVersionAvailable: Boolean;
  Handle: Cardinal;
begin
  Result := False;
  VerMajor := -1; VerMinor := -1; VerPatch := -1; VerBuild := -1;

  BufferSize := GetFileVersionInfoSize(PChar(Application.ExeName), Handle);

  if (BufferSize > 0) then
  begin
    GetMem(Buffer, BufferSize);
    if (Assigned(Buffer)) then
    begin
      FileVersionAvailable := GetFileVersionInfo(PChar(Application.ExeName), Application.Handle, BufferSize, Buffer);
      if (FileVersionAvailable) then
        if (VerQueryValue(Buffer, '\', Pointer(FileInfo), FileInfoSize)) then
          if (FileInfoSize >= SizeOf(FileInfo^)) then
          begin
            VerMajor := FileInfo.dwFileVersionMS shr 16;
            VerMinor := FileInfo.dwFileVersionMS and $FFFF;
            VerPatch := FileInfo.dwFileVersionLS shr 16;
            VerBuild := FileInfo.dwFileVersionLS and $FFFF;
            Result := (VerMajor > 0) and (VerMinor >= 0) and (VerPatch >= 0) and (VerBuild >= 0);
          end;
    end;
    FreeMem(Buffer);
  end;
end;

function TPPreferences.GetVersionInfo(): Integer;
var
  VerBuild: Integer;
  VerMajor: Integer;
  VerMinor: Integer;
  VerPatch: Integer;
begin
  if (not GetVersion(VerMajor, VerMinor, VerPatch, VerBuild)) then
    Result := -1
  else
    Result := EncodeVersion(VerMajor, VerMinor, VerPatch, VerBuild);
end;

function TPPreferences.GetVersionStr(): string;
var
  VerBuild: Integer;
  VerMajor: Integer;
  VerMinor: Integer;
  VerPatch: Integer;
begin
  if (not GetVersion(VerMajor, VerMinor, VerPatch, VerBuild)) then
    Result := '???'
  else
    Result := IntToStr(VerMajor) + '.' + IntToStr(VerMinor) + '  (Build ' + IntToStr(VerPatch) + '.' + IntToStr(VerBuild) + ')';
end;

function TPPreferences.GetXML(): IXMLNode;
begin
  if (not Assigned(FXMLDocument)) then
  begin
    if (FileExists(Filename)) then
      try
        FXMLDocument := LoadXMLDocument(Filename);

        if (VersionStrToVersion(FXMLDocument.DocumentElement.Attributes['version']) < 10002)  then
        begin
          XMLNode(FXMLDocument.DocumentElement, 'grid/maxcolumnwidth').Text := IntToStr(100);

          FXMLDocument.DocumentElement.Attributes['version'] := '1.0.2';
        end;

        if (VersionStrToVersion(FXMLDocument.DocumentElement.Attributes['version']) < 10100)  then
        begin
          FXMLDocument.DocumentElement.ChildNodes.Delete('session');
          FXMLDocument.DocumentElement.ChildNodes.Delete('sessions');

          FXMLDocument.DocumentElement.Attributes['version'] := '1.1.0';
        end;

        if (VersionStrToVersion(FXMLDocument.DocumentElement.Attributes['version']) < 10101)  then
        begin
          if (Assigned(XMLNode(FXMLDocument.DocumentElement, 'updates/check'))
            and (UpperCase(XMLNode(FXMLDocument.DocumentElement, 'updates/check').Text) = 'STARTUP')) then
            XMLNode(FXMLDocument.DocumentElement, 'updates/check').Text := 'Daily';

          FXMLDocument.DocumentElement.Attributes['version'] := '1.1.1';
        end;
      except
        FXMLDocument := nil;
      end;

    if (not Assigned(FXMLDocument)) then
    begin
      FXMLDocument := NewXMLDocument();
      FXMLDocument.Encoding := 'utf-8';
      FXMLDocument.Node.AddChild('desktop').Attributes['version'] := '1.1.1';
    end;

    FXMLDocument.Options := FXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
  end;

  Result := FXMLDocument.DocumentElement;
end;

procedure TPPreferences.LoadFromRegistry();
var
  KeyName: string;
begin
  RootKey := HKEY_CLASSES_ROOT;

  AssociateSQL := False;
  if (OpenKeyReadOnly('.sql')) then
  begin
    if (ValueExists('')) then KeyName := ReadString('');
    CloseKey();

    if (OpenKeyReadOnly(KeyName + '\shell\open\command')) then
    begin
      AssociateSQL := Pos(UpperCase(Application.ExeName), UpperCase(ReadString(''))) > 0;
      CloseKey();
    end;
  end;
  OldAssociateSQL := AssociateSQL;

  RootKey := HKEY_CURRENT_USER;

  if (OpenKeyReadOnly(KeyBase)) then
  begin
    if (ValueExists('LanguageFile')) then LanguageFilename := ExtractFileName(ReadString('LanguageFile'));
    if (ValueExists('Path') and DirectoryExists(ReadString('Path'))) then Path := IncludeTrailingPathDelimiter(ReadString('Path'));
    if (ValueExists('SetupProgram') and FileExists(ReadString('SetupProgram'))) then SetupProgram := ReadString('SetupProgram');
    if (ValueExists('SetupProgramInstalled')) then SetupProgramInstalled := ReadBool('SetupProgramInstalled');

    CloseKey();
  end;
end;

procedure TPPreferences.LoadFromXML();
var
  Visible: Boolean;
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];

  if (Assigned(XMLNode(XML, 'addressbar'))) then TryStrToBool(XMLNode(XML, 'addressbar').Attributes['visible'], AddressBarVisible);
  if (Assigned(XMLNode(XML, 'grid/currentrow/background'))) then TryStrToBool(XMLNode(XML, 'grid/currentrow/background').Attributes['visible'], GridCurrRowBGColorEnabled);
  if (Assigned(XMLNode(XML, 'grid/currentrow/background/color'))) then GridCurrRowBGColor := StringToColor(XMLNode(XML, 'grid/currentrow/background/color').Text);
  if (Assigned(XMLNode(XML, 'grid/font/charset'))) then TryStrToInt(XMLNode(XML, 'grid/font/charset').Text, GridFontCharset);
  if (Assigned(XMLNode(XML, 'grid/font/color'))) then GridFontColor := StringToColor(XMLNode(XML, 'grid/font/color').Text);
  if (Assigned(XMLNode(XML, 'grid/font/name'))) then GridFontName := XMLNode(XML, 'grid/font/name').Text;
  if (Assigned(XMLNode(XML, 'grid/font/size'))) then TryStrToInt(XMLNode(XML, 'grid/font/size').Text, GridFontSize);
  if (Assigned(XMLNode(XML, 'grid/font/style'))) then GridFontStyle := StrToStyle(XMLNode(XML, 'grid/font/style').Text);
  if (Assigned(XMLNode(XML, 'grid/memo'))) then TryStrToBool(XMLNode(XML, 'grid/memo').Attributes['visible'], GridShowMemoContent);
  if (Assigned(XMLNode(XML, 'grid/null'))) then TryStrToBool(XMLNode(XML, 'grid/null').Attributes['visible'], GridNullText);
  if (Assigned(XMLNode(XML, 'grid/null/background'))) then TryStrToBool(XMLNode(XML, 'grid/null/background').Attributes['visible'], GridNullBGColorEnabled);
  if (Assigned(XMLNode(XML, 'grid/null/background/color'))) then GridNullBGColor := StringToColor(XMLNode(XML, 'grid/null/background/color').Text);
  if (Assigned(XMLNode(XML, 'grid/maxcolumnwidth'))) then TryStrToInt(XMLNode(XML, 'grid/maxcolumnwidth').Text, GridMaxColumnWidth);
  if (Assigned(XMLNode(XML, 'grid/row/background'))) then TryStrToBool(XMLNode(XML, 'grid/row/background').Attributes['visible'], GridRowBGColorEnabled);
  if (Assigned(XMLNode(XML, 'height'))) then TryStrToInt(XMLNode(XML, 'height').Text, Height);
  if (Assigned(XMLNode(XML, 'language/file'))) then LanguageFilename := ExtractFileName(XMLNode(XML, 'language/file').Text);
  if (Assigned(XMLNode(XML, 'left'))) then TryStrToInt(XMLNode(XML, 'left').Text, Left);
  if (Assigned(XMLNode(XML, 'log/font/charset'))) then TryStrToInt(XMLNode(XML, 'log/font/charset').Text, LogFontCharset);
  if (Assigned(XMLNode(XML, 'log/font/color'))) then LogFontColor := StringToColor(XMLNode(XML, 'log/font/color').Text);
  if (Assigned(XMLNode(XML, 'log/font/name'))) then LogFontName := XMLNode(XML, 'log/font/name').Text;
  if (Assigned(XMLNode(XML, 'log/font/size'))) then TryStrToInt(XMLNode(XML, 'log/font/size').Text, LogFontSize);
  if (Assigned(XMLNode(XML, 'log/font/style'))) then LogFontStyle := StrToStyle(XMLNode(XML, 'log/font/style').Text);
  if (Assigned(XMLNode(XML, 'log/highlighting'))) then TryStrToBool(XMLNode(XML, 'log/highlighting').Attributes['visible'], LogHighlighting);
  if (Assigned(XMLNode(XML, 'log/size'))) then TryStrToInt(XMLNode(XML, 'log/size').Text, LogSize);
  if (Assigned(XMLNode(XML, 'log/dbresult'))) then TryStrToBool(XMLNode(XML, 'log/dbresult').Attributes['visible'], LogResult);
  if (Assigned(XMLNode(XML, 'log/time'))) then TryStrToBool(XMLNode(XML, 'log/time').Attributes['visible'], LogTime);
  if (Assigned(XMLNode(XML, 'toolbar/objects')) and TryStrToBool(XMLNode(XML, 'toolbar/objects').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttObjects] else ToolbarTabs := ToolbarTabs - [ttObjects];
  if (Assigned(XMLNode(XML, 'toolbar/browser')) and TryStrToBool(XMLNode(XML, 'toolbar/browser').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttBrowser] else ToolbarTabs := ToolbarTabs - [ttBrowser];
  if (Assigned(XMLNode(XML, 'toolbar/ide')) and TryStrToBool(XMLNode(XML, 'toolbar/ide').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttIDE] else ToolbarTabs := ToolbarTabs - [ttIDE];
  if (Assigned(XMLNode(XML, 'toolbar/builder')) and TryStrToBool(XMLNode(XML, 'toolbar/builder').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttBuilder] else ToolbarTabs := ToolbarTabs - [ttBuilder];
  if (Assigned(XMLNode(XML, 'toolbar/editor')) and TryStrToBool(XMLNode(XML, 'toolbar/editor').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttEditor] else ToolbarTabs := ToolbarTabs - [ttEditor];
  if (Assigned(XMLNode(XML, 'toolbar/diagram')) and TryStrToBool(XMLNode(XML, 'toolbar/diagram').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttDiagram] else ToolbarTabs := ToolbarTabs - [ttDiagram];
  if (Assigned(XMLNode(XML, 'sql/font/charset'))) then TryStrToInt(XMLNode(XML, 'sql/font/charset').Text, SQLFontCharset);
  if (Assigned(XMLNode(XML, 'sql/font/color'))) then SQLFontColor := StringToColor(XMLNode(XML, 'sql/font/color').Text);
  if (Assigned(XMLNode(XML, 'sql/font/name'))) then SQLFontName := XMLNode(XML, 'sql/font/name').Text;
  if (Assigned(XMLNode(XML, 'sql/font/size'))) then TryStrToInt(XMLNode(XML, 'sql/font/size').Text, SQLFontSize);
  if (Assigned(XMLNode(XML, 'sql/font/style'))) then SQLFontStyle := StrToStyle(XMLNode(XML, 'sql/font/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/comment/color'))) then Editor.CommentForeground := StringToColor(XMLNode(XML, 'sql/highlighting/comment/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/comment/background/color'))) then Editor.CommentBackground := StringToColor(XMLNode(XML, 'sql/highlighting/comment/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/comment/style'))) then Editor.CommentStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/comment/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/conditional/color'))) then Editor.ConditionalCommentForeground := StringToColor(XMLNode(XML, 'sql/highlighting/conditional/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/conditional/background/color'))) then Editor.ConditionalCommentBackground := StringToColor(XMLNode(XML, 'sql/highlighting/conditional/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/conditional/style'))) then Editor.ConditionalCommentStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/conditional/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/datatype/color'))) then Editor.DataTypeForeground := StringToColor(XMLNode(XML, 'sql/highlighting/datatype/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/datatype/background/color'))) then Editor.DataTypeBackground := StringToColor(XMLNode(XML, 'sql/highlighting/datatype/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/datatype/style'))) then Editor.DataTypeStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/datatype/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/function/color'))) then Editor.FunctionForeground := StringToColor(XMLNode(XML, 'sql/highlighting/function/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/function/background/color'))) then Editor.FunctionBackground := StringToColor(XMLNode(XML, 'sql/highlighting/function/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/function/style'))) then Editor.FunctionStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/function/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/identifier/color'))) then Editor.IdentifierForeground := StringToColor(XMLNode(XML, 'sql/highlighting/identifier/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/identifier/background/color'))) then Editor.IdentifierBackground := StringToColor(XMLNode(XML, 'sql/highlighting/identifier/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/identifier/style'))) then Editor.IdentifierStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/identifier/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/keyword/color'))) then Editor.KeywordForeground := StringToColor(XMLNode(XML, 'sql/highlighting/keyword/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/keyword/background/color'))) then Editor.KeywordBackground := StringToColor(XMLNode(XML, 'sql/highlighting/keyword/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/keyword/style'))) then Editor.KeywordStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/keyword/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/linenumbers/color'))) then Editor.LineNumbersForeground := StringToColor(XMLNode(XML, 'sql/highlighting/linenumbers/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/linenumbers/background/color'))) then Editor.LineNumbersBackground := StringToColor(XMLNode(XML, 'sql/highlighting/linenumbers/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/linenumbers/style'))) then Editor.LineNumbersStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/linenumbers/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/number/color'))) then Editor.NumberForeground := StringToColor(XMLNode(XML, 'sql/highlighting/number/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/number/background/color'))) then Editor.NumberBackground := StringToColor(XMLNode(XML, 'sql/highlighting/number/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/number/style'))) then Editor.NumberStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/number/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/string/color'))) then Editor.StringForeground := StringToColor(XMLNode(XML, 'sql/highlighting/string/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/string/background/color'))) then Editor.StringBackground := StringToColor(XMLNode(XML, 'sql/highlighting/string/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/string/style'))) then Editor.StringStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/string/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/symbol/color'))) then Editor.SymbolForeground := StringToColor(XMLNode(XML, 'sql/highlighting/symbol/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/symbol/background/color'))) then Editor.SymbolBackground := StringToColor(XMLNode(XML, 'sql/highlighting/symbol/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/symbol/style'))) then Editor.SymbolStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/symbol/style').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/variable/color'))) then Editor.VariableForeground := StringToColor(XMLNode(XML, 'sql/highlighting/variable/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/variable/background/color'))) then Editor.VariableBackground := StringToColor(XMLNode(XML, 'sql/highlighting/variable/background/color').Text);
  if (Assigned(XMLNode(XML, 'sql/highlighting/variable/style'))) then Editor.VariableStyle := StrToStyle(XMLNode(XML, 'sql/highlighting/variable/style').Text);
  if (Assigned(XMLNode(XML, 'tabs'))) then TryStrToBool(XMLNode(XML, 'tabs').Attributes['visible'], TabsVisible);
  if (Assigned(XMLNode(XML, 'top'))) then TryStrToInt(XMLNode(XML, 'top').Text, Top);
  if (Assigned(XMLNode(XML, 'updates/check'))) then TryStrToUpdateCheck(XMLNode(XML, 'updates/check').Text, UpdateCheck);
  if (Assigned(XMLNode(XML, 'updates/lastcheck'))) then TryStrToDate(XMLNode(XML, 'updates/lastcheck').Text, UpdateChecked, FileFormatSettings);
  if (Assigned(XMLNode(XML, 'width'))) then TryStrToInt(XMLNode(XML, 'width').Text, Width);

  Database.LoadFromXML(XMLNode(XML, 'database'));
  Editor.LoadFromXML(XMLNode(XML, 'editor'));
  Event.LoadFromXML(XMLNode(XML, 'event'));
  Export.LoadFromXML(XMLNode(XML, 'export'));
  Field.LoadFromXML(XMLNode(XML, 'field'));
  Find.LoadFromXML(XMLNode(XML, 'find'));
  ForeignKey.LoadFromXML(XMLNode(XML, 'foreignkey'));
  Host.LoadFromXML(XMLNode(XML, 'host'));
  Import.LoadFromXML(XMLNode(XML, 'import'));
  Index.LoadFromXML(XMLNode(XML, 'index'));
  ODBC.LoadFromXML(XMLNode(XML, 'odbc'));
  Paste.LoadFromXML(XMLNode(XML, 'paste'));
  Replace.LoadFromXML(XMLNode(XML, 'replace'));
  Routine.LoadFromXML(XMLNode(XML, 'routine'));
  Server.LoadFromXML(XMLNode(XML, 'server'));
  Accounts.LoadFromXML(XMLNode(XML, 'accounts'));
  SQLHelp.LoadFromXML(XMLNode(XML, 'sqlhelp'));
  Statement.LoadFromXML(XMLNode(XML, 'statement'));
  Table.LoadFromXML(XMLNode(XML, 'table'));
  TableService.LoadFromXML(XMLNode(XML, 'tableservice'));
  Transfer.LoadFromXML(XMLNode(XML, 'transfer'));
  Trigger.LoadFromXML(XMLNode(XML, 'trigger'));
  User.LoadFromXML(XMLNode(XML, 'user'));
  View.LoadFromXML(XMLNode(XML, 'view'));


  FreeAndNil(FLanguage);
end;

function TPPreferences.LoadStr(const Index: Integer; const Param1: string = ''; const Param2: string = ''; const Param3: string = ''): string;
begin
  SetLength(Result, 100);
  if (Assigned(Language) and (Language.Strs[Index] <> '')) then
    Result := Language.Strs[Index]
  else
    Result := SysUtils.LoadStr(10000 + Index);
  if (Result = '') then
    Result := '<' + IntToStr(Index) + '>';

  Result := ReplaceStr(Result, '%1', Param1);
  Result := ReplaceStr(Result, '%2', Param2);
  Result := ReplaceStr(Result, '%3', Param3);
end;

procedure TPPreferences.SaveToRegistry();
var
  KeyName: string;
begin
  Access := KEY_ALL_ACCESS;

  if (AssociateSQL <> OldAssociateSQL) then
  begin
    RootKey := HKEY_CLASSES_ROOT;

    if (OpenKey('.sql', True)) then
    begin
      if (not ValueExists('')) then WriteString('', 'SQLFile');
      KeyName := ReadString('');
      CloseKey();
    end;

    if (not AssociateSQL) then
    begin
      if (OpenKey(KeyName + '\DefaultIcon', False)) then
      begin
        if (ValueExists('')) then
          DeleteValue('');
        CloseKey();
      end;
      if (OpenKey(KeyName + '\shell\open\command', False)) then
      begin
        if (ValueExists('')) then
          DeleteValue('');
        CloseKey();
      end;
    end
    else
    begin
      if (OpenKey(KeyName + '\DefaultIcon', True)) then
        begin WriteString('', Application.ExeName + ',0'); CloseKey(); end;
      if (OpenKey(KeyName + '\shell\open\command', True)) then
        begin WriteString('', '"' + Application.ExeName + '" "%0"'); CloseKey(); end;
    end;

    RootKey := HKEY_CURRENT_USER;
  end;

  RootKey := HKEY_CURRENT_USER;

  if (OpenKey(KeyBase, False) or (UserPath <> ExtractFilePath(Application.ExeName)) and OpenKey(KeyBase, True)) then
  begin
    if (SetupProgram <> '') then
      WriteString('SetupProgram', SetupProgram)
    else if (ValueExists('SetupProgram')) then
      DeleteValue('SetupProgram');
    if (SetupProgramInstalled) then
      WriteBool('SetupProgramInstalled', SetupProgramInstalled)
    else if (ValueExists('SetupProgramInstalled')) then
      DeleteValue('SetupProgramInstalled');
    WriteString('Path', Path);

    CloseKey();
  end;

  Access := KEY_READ;

  SaveToXML();
end;

procedure TPPreferences.SaveToXML();
var
  XML: IXMLNode;
begin
  XML := GetXML();

  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  XMLNode(XML, 'addressbar').Attributes['visible'] := AddressBarVisible;
  XMLNode(XML, 'grid/currentrow/background').Attributes['visible'] := GridCurrRowBGColorEnabled;
  XMLNode(XML, 'grid/currentrow/background/color').Text := ColorToString(GridCurrRowBGColor);
  XMLNode(XML, 'grid/font/charset').Text := IntToStr(GridFontCharset);
  XMLNode(XML, 'grid/font/color').Text := ColorToString(GridFontColor);
  XMLNode(XML, 'grid/font/name').Text := GridFontName;
  XMLNode(XML, 'grid/font/size').Text := IntToStr(GridFontSize);
  XMLNode(XML, 'grid/font/style').Text := StyleToStr(GridFontStyle);
  XMLNode(XML, 'grid/memo').Attributes['visible'] := GridShowMemoContent;
  XMLNode(XML, 'grid/null').Attributes['visible'] := GridNullText;
  XMLNode(XML, 'grid/null/background').Attributes['visible'] := GridNullBGColorEnabled;
  XMLNode(XML, 'grid/null/background/color').Text := ColorToString(GridNullBGColor);
  XMLNode(XML, 'grid/maxcolumnwidth').Text := IntToStr(GridMaxColumnWidth);
  XMLNode(XML, 'grid/row/background').Attributes['visible'] := GridRowBGColorEnabled;
  XMLNode(XML, 'height').Text := IntToStr(Height);
  XMLNode(XML, 'language/file').Text := ExtractFileName(LanguageFilename);
  XMLNode(XML, 'left').Text := IntToStr(Left);
  XMLNode(XML, 'log/font/charset').Text := IntToStr(LogFontCharset);
  XMLNode(XML, 'log/font/color').Text := ColorToString(LogFontColor);
  XMLNode(XML, 'log/font/name').Text := LogFontName;
  XMLNode(XML, 'log/font/size').Text := IntToStr(LogFontSize);
  XMLNode(XML, 'log/font/style').Text := StyleToStr(LogFontStyle);
  XMLNode(XML, 'log/highlighting').Attributes['visible'] := LogHighlighting;
  XMLNode(XML, 'log/size').Text := IntToStr(LogSize);
  XMLNode(XML, 'log/dbresult').Attributes['visible'] := LogResult;
  XMLNode(XML, 'log/time').Attributes['visible'] := LogTime;
  if (WindowState in [wsNormal, wsMaximized	]) then
    XMLNode(XML, 'windowstate').Text := WindowStateToStr(WindowState);
  XMLNode(XML, 'toolbar/objects').Attributes['visible'] := ttObjects in ToolbarTabs;
  XMLNode(XML, 'toolbar/browser').Attributes['visible'] := ttBrowser in ToolbarTabs;
  XMLNode(XML, 'toolbar/ide').Attributes['visible'] := ttIDE in ToolbarTabs;
  XMLNode(XML, 'toolbar/builder').Attributes['visible'] := ttBuilder in ToolbarTabs;
  XMLNode(XML, 'toolbar/editor').Attributes['visible'] := ttEditor in ToolbarTabs;
  XMLNode(XML, 'toolbar/diagram').Attributes['visible'] := ttDiagram in ToolbarTabs;
  XMLNode(XML, 'sql/font/charset').Text := IntToStr(SQLFontCharset);
  XMLNode(XML, 'sql/font/color').Text := ColorToString(SQLFontColor);
  XMLNode(XML, 'sql/font/name').Text := SQLFontName;
  XMLNode(XML, 'sql/font/size').Text := IntToStr(SQLFontSize);
  XMLNode(XML, 'sql/font/style').Text := StyleToStr(SQLFontStyle);
  XMLNode(XML, 'sql/highlighting/comment/color').Text := ColorToString(Editor.CommentForeground);
  XMLNode(XML, 'sql/highlighting/comment/background/color').Text := ColorToString(Editor.CommentBackground);
  XMLNode(XML, 'sql/highlighting/comment/style').Text := StyleToStr(Editor.CommentStyle);
  XMLNode(XML, 'sql/highlighting/conditional/color').Text := ColorToString(Editor.ConditionalCommentForeground);
  XMLNode(XML, 'sql/highlighting/conditional/background/color').Text := ColorToString(Editor.ConditionalCommentBackground);
  XMLNode(XML, 'sql/highlighting/conditional/style').Text := StyleToStr(Editor.ConditionalCommentStyle);
  XMLNode(XML, 'sql/highlighting/datatype/color').Text := ColorToString(Editor.DataTypeForeground);
  XMLNode(XML, 'sql/highlighting/datatype/background/color').Text := ColorToString(Editor.DataTypeBackground);
  XMLNode(XML, 'sql/highlighting/datatype/style').Text := StyleToStr(Editor.DataTypeStyle);
  XMLNode(XML, 'sql/highlighting/function/color').Text := ColorToString(Editor.FunctionForeground);
  XMLNode(XML, 'sql/highlighting/function/background/color').Text := ColorToString(Editor.FunctionBackground);
  XMLNode(XML, 'sql/highlighting/function/style').Text := StyleToStr(Editor.FunctionStyle);
  XMLNode(XML, 'sql/highlighting/identifier/color').Text := ColorToString(Editor.IdentifierForeground);
  XMLNode(XML, 'sql/highlighting/identifier/background/color').Text := ColorToString(Editor.IdentifierBackground);
  XMLNode(XML, 'sql/highlighting/identifier/style').Text := StyleToStr(Editor.IdentifierStyle);
  XMLNode(XML, 'sql/highlighting/keyword/color').Text := ColorToString(Editor.KeywordForeground);
  XMLNode(XML, 'sql/highlighting/keyword/background/color').Text := ColorToString(Editor.KeywordBackground);
  XMLNode(XML, 'sql/highlighting/keyword/style').Text := StyleToStr(Editor.KeywordStyle);
  XMLNode(XML, 'sql/highlighting/linenumbers/color').Text := ColorToString(Editor.LineNumbersForeground);
  XMLNode(XML, 'sql/highlighting/linenumbers/background/color').Text := ColorToString(Editor.LineNumbersBackground);
  XMLNode(XML, 'sql/highlighting/linenumbers/style').Text := StyleToStr(Editor.LineNumbersStyle);
  XMLNode(XML, 'sql/highlighting/number/color').Text := ColorToString(Editor.NumberForeground);
  XMLNode(XML, 'sql/highlighting/number/background/color').Text := ColorToString(Editor.NumberBackground);
  XMLNode(XML, 'sql/highlighting/number/style').Text := StyleToStr(Editor.NumberStyle);
  XMLNode(XML, 'sql/highlighting/string/color').Text := ColorToString(Editor.StringForeground);
  XMLNode(XML, 'sql/highlighting/string/background/color').Text := ColorToString(Editor.StringBackground);
  XMLNode(XML, 'sql/highlighting/string/style').Text := StyleToStr(Editor.StringStyle);
  XMLNode(XML, 'sql/highlighting/symbol/color').Text := ColorToString(Editor.SymbolForeground);
  XMLNode(XML, 'sql/highlighting/symbol/background/color').Text := ColorToString(Editor.SymbolBackground);
  XMLNode(XML, 'sql/highlighting/symbol/style').Text := StyleToStr(Editor.SymbolStyle);
  XMLNode(XML, 'sql/highlighting/variable/color').Text := ColorToString(Editor.VariableForeground);
  XMLNode(XML, 'sql/highlighting/variable/background/color').Text := ColorToString(Editor.VariableBackground);
  XMLNode(XML, 'sql/highlighting/variable/style').Text := StyleToStr(Editor.VariableStyle);
  XMLNode(XML, 'tabs').Attributes['visible'] := TabsVisible;
  XMLNode(XML, 'top').Text := IntToStr(Top);
  XMLNode(XML, 'updates/check').Text := UpdateCheckToStr(UpdateCheck);
  XMLNode(XML, 'updates/lastcheck').Text := SysUtils.DateToStr(UpdateChecked, FileFormatSettings);
  XMLNode(XML, 'width').Text := IntToStr(Width);

  Database.SaveToXML(XMLNode(XML, 'database'));
  Editor.SaveToXML(XMLNode(XML, 'editor'));
  Event.SaveToXML(XMLNode(XML, 'event'));
  Export.SaveToXML(XMLNode(XML, 'export'));
  Field.SaveToXML(XMLNode(XML, 'field'));
  Find.SaveToXML(XMLNode(XML, 'find'));
  ForeignKey.SaveToXML(XMLNode(XML, 'foreignkey'));
  Host.SaveToXML(XMLNode(XML, 'host'));
  Import.SaveToXML(XMLNode(XML, 'import'));
  Index.SaveToXML(XMLNode(XML, 'index'));
  ODBC.SaveToXML(XMLNode(XML, 'odbc'));
  Paste.SaveToXML(XMLNode(XML, 'paste'));
  Replace.SaveToXML(XMLNode(XML, 'replace'));
  Routine.SaveToXML(XMLNode(XML, 'routine'));
  Server.SaveToXML(XMLNode(XML, 'server'));
  Accounts.SaveToXML(XMLNode(XML, 'accounts'));
  SQLHelp.SaveToXML(XMLNode(XML, 'sqlhelp'));
  Statement.SaveToXML(XMLNode(XML, 'statement'));
  Table.SaveToXML(XMLNode(XML, 'table'));
  TableService.SaveToXML(XMLNode(XML, 'tableservice'));
  Transfer.SaveToXML(XMLNode(XML, 'transfer'));
  Trigger.SaveToXML(XMLNode(XML, 'trigger'));
  User.SaveToXML(XMLNode(XML, 'user'));
  View.SaveToXML(XMLNode(XML, 'view'));

  if (XML.OwnerDocument.Modified and ForceDirectories(ExtractFilePath(Filename))) then
    XML.OwnerDocument.SaveToFile(Filename);
end;

{ TABookmark ******************************************************************}

procedure TABookmark.Assign(const Source: TABookmark);
begin
  if (not Assigned(Bookmarks) and Assigned(Source.Bookmarks)) then
    FBookmarks := Source.Bookmarks;

  Caption := Source.Caption;
  URI := Source.URI;

  if (Assigned(XML)) then
    XML.Attributes['name'] := Caption;
end;

constructor TABookmark.Create(const ABookmarks: TABookmarks; const AXML: IXMLNode = nil);
begin
  FBookmarks := ABookmarks;
  FXML := AXML;

  Caption := '';
  URI := '';
end;

function TABookmark.GetXML(): IXMLNode;
var
  I: Integer;
begin
  if (not Assigned(FXML)) then
    for I := 0 to Bookmarks.XML.ChildNodes.Count - 1 do
      if ((Bookmarks.XML.ChildNodes[I].NodeName = 'bookmark') and (lstrcmpi(PChar(string(Bookmarks.XML.ChildNodes[I].Attributes['name'])), PChar(Caption)) = 0)) then
        FXML := Bookmarks.XML.ChildNodes[I];

  Result := FXML;
end;

procedure TABookmark.LoadFromXML();
begin
  if (Assigned(XML)) then
  begin
    Caption := XML.Attributes['name'];
    if (Assigned(XMLNode(XML, 'uri'))) then URI := Bookmarks.Desktop.Account.ExpandAddress(XMLNode(XML, 'uri').Text);
  end;
end;

procedure TABookmark.SaveToXML();
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  XML.Attributes['name'] := Caption;
  XMLNode(XML, 'uri').Text := Bookmarks.Desktop.Account.ExtractPath(URI);

  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];
end;

{ TABookmarks *****************************************************************}

function TABookmarks.AddBookmark(const NewBookmark: TABookmark): Boolean;
begin
  Result := IndexOf(NewBookmark) < 0;

  if (Result) then
  begin
    SetLength(FBookmarks, Count + 1);

    FBookmarks[Count - 1] := TABookmark.Create(Self, XML.AddChild('bookmark'));
    FBookmarks[Count - 1].Assign(NewBookmark);

    Desktop.Account.AccountEvent(ClassType);
  end;
end;

function TABookmarks.ByCaption(const Caption: string): TABookmark;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if (lstrcmpi(PChar(FBookmarks[I].Caption), PChar(Caption)) = 0) then
      Result := FBookmarks[I];
end;

procedure TABookmarks.Clear();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    FBookmarks[I].Free();
  SetLength(FBookmarks, 0);
end;

function TABookmarks.Count(): Integer;
begin
  Result := Length(FBookmarks);
end;

constructor TABookmarks.Create(const ADesktop: TADesktop);
begin
  inherited Create();

  FDesktop := ADesktop;

  FXML := nil;
  SetLength(FBookmarks, 0);
end;

function TABookmarks.DeleteBookmark(const Bookmark: TABookmark): Boolean;
var
  I: Integer;
  Index: Integer;
begin
  Index := IndexOf(ByCaption(Bookmark.Caption));

  Result := Index >= 0;
  if (Result) then
  begin
    XML.ChildNodes.Delete(XML.ChildNodes.IndexOf(Bookmark.XML));

    FBookmarks[Index].Free();
    for I := Index to Count - 2 do
      FBookmarks[I] := FBookmarks[I + 1];

    SetLength(FBookmarks, Count - 1);

    Desktop.Account.AccountEvent(ClassType);
  end;
end;

destructor TABookmarks.Destroy();
begin
  Clear();

  inherited;
end;

function TABookmarks.GetBookmark(Index: Integer): TABookmark;
begin
  Result := FBookmarks[Index];
end;

function TABookmarks.GetDataPath(): TFileName;
begin
  Result := Desktop.Account.DataPath;
end;

function TABookmarks.GetXML(): IXMLNode;
begin
  if (not Assigned(FXML) and Assigned(Desktop.XML)) then
    FXML := XMLNode(Desktop.XML, 'bookmarks', True);

  Result := FXML;
end;

function TABookmarks.IndexOf(const Bookmark: TABookmark): Integer;
var
  I: Integer;
begin
  Result := -1;

  if (Assigned(Bookmark)) then
    for I := 0 to Count - 1 do
      if (lstrcmpi(PChar(FBookmarks[I].Caption), PChar(Bookmark.Caption)) = 0) then
        Result := I;
end;

procedure TABookmarks.LoadFromXML();
var
  I: Integer;
begin
  Clear();

  if (Assigned(XML)) then
    for I := 0 to XML.ChildNodes.Count - 1 do
      if ((XML.ChildNodes[I].NodeName = 'bookmark') and not Assigned(ByCaption(XML.ChildNodes[I].Attributes['name']))) then
      begin
        SetLength(FBookmarks, Count + 1);
        FBookmarks[Count - 1] := TABookmark.Create(Self, XML.ChildNodes[I]);

        FBookmarks[Count - 1].LoadFromXML();
      end;
end;

procedure TABookmarks.MoveBookmark(const Bookmark: TABookmark; const NewIndex: Integer);
var
  I: Integer;
  Index: Integer;
  TempBookmark: TABookmark;
begin
  Index := IndexOf(Bookmark);
  TempBookmark := FBookmarks[Index];

  if (NewIndex <> Index) then
  begin
    XML.ChildNodes.Remove(Bookmark.XML);

    if (NewIndex < 0) then
    begin
      for I := Index to Count - 2 do
        FBookmarks[I] := FBookmarks[I + 1];

      XML.ChildNodes.Insert(0, Bookmark.XML);
    end
    else if (NewIndex < Index) then
    begin
      for I := Index downto NewIndex + 1 do
        FBookmarks[I] := FBookmarks[I - 1];

      XML.ChildNodes.Insert(NewIndex, Bookmark.XML);
    end
    else
    begin
      for I := Index to NewIndex - 1 do
        FBookmarks[I] := FBookmarks[I + 1];

      XML.ChildNodes.Insert(NewIndex, Bookmark.XML);
    end;
    if (NewIndex < 0) then
      FBookmarks[Count - 1] := TempBookmark
    else
      FBookmarks[NewIndex] := TempBookmark;

    Desktop.Account.AccountEvent(ClassType);
  end;
end;

procedure TABookmarks.SaveToXML();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Bookmark[I].SaveToXML();
end;

function TABookmarks.UpdateBookmark(const Bookmark, NewBookmark: TABookmark): Boolean;
begin
  Result := Assigned(Bookmark) and Assigned(NewBookmark);

  if (Result) then
  begin
    if (Assigned(Bookmark.XML)) then
      Bookmark.XML.Attributes['name'] := NewBookmark.Caption;

    Bookmark.Assign(NewBookmark);

    Desktop.Account.AccountEvent(ClassType);
  end;
end;

{ TAFile **********************************************************************}

constructor TAFile.Create(const AFiles: TAFiles);
begin
  inherited Create();

  FFiles := AFiles;
end;

procedure TAFile.LoadFromXML(const XML: IXMLNode);
var
  CodePage: Integer;
begin
  if (Assigned(XML)) then
  begin
    FFilename := XML.Text;
    if ((XML.Attributes['codepage'] <> Null) and TryStrToInt(XML.Attributes['codepage'], CodePage)) then FCodePage := CodePage;
  end;
end;

procedure TAFile.SaveToXML(const XML: IXMLNode);
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  XML.Text := Filename;
  if (CodePage <> CP_ACP) then
    XML.Attributes['codepage'] := IntToStr(CodePage)
  else if (XML.Attributes['codepage'] <> Null) then
    XML.Attributes['codepage'] := Null;

  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];
end;

{ TAFiles *********************************************************************}

procedure TAFiles.Add(const AFilename: TFileName; const ACodePage: Cardinal);
var
  I: Integer;
  Index: Integer;
begin
  Index := -1;

  I := 0;
  while ((I < Count) and (Index < 0)) do
    if (lstrcmpi(PChar(AFilename), PChar(Files[I].Filename)) = 0) then
      Index := I
    else
      Inc(I);

  if (Index < 0) then
  begin
    Index := 0;
    Insert(Index, TAFile.Create(Self));

    while (Count > MaxCount) do
    begin
      Files[Count - 1].Free();
      Delete(Count - 1);
    end;
  end
  else if (Index <> 0) then
    Move(Index, 0);

  Files[0].FFilename := AFilename;
  Files[0].FCodePage := ACodePage
end;

procedure TAFiles.Clear();
begin
  while (Count > 0) do
  begin
    Files[0].Free();
    Delete(0);
  end;

  inherited;
end;

constructor TAFiles.Create(const ADesktop: TADesktop; const AMaxCount: Integer);
begin
  inherited Create();

  FDesktop := ADesktop;

  FMaxCount := AMaxCount;
  FXML := nil;
end;

function TAFiles.Get(Index: Integer): TAFile;
begin
  Result := TAFile(Items[Index]);
end;

function TAFiles.GetXML(): IXMLNode;
begin
  if (not Assigned(FXML) and Assigned(Desktop.XML)) then
    FXML := XMLNode(Desktop.XML, 'editor/files', True);

  Result := FXML;
end;

procedure TAFiles.LoadFromXML();
var
  I: Integer;
begin
  Clear();

  for I := 0 to XML.ChildNodes.Count - 1 do
    if (XML.ChildNodes[I].NodeName = 'file') then
    begin
      inherited Add(TAFile.Create(Self));
      Files[Count - 1].LoadFromXML(XML.ChildNodes[I]);
    end;
end;

procedure TAFiles.SaveToXML();
var
  I: Integer;
  Node: IXMLNode;
begin
  while (XML.ChildNodes.Count > 0) do
    XML.ChildNodes.Delete(0);

  for I := 0 to Count - 1 do
  begin
    Node := XML.AddChild('file');
    Files[I].SaveToXML(Node);
  end;
end;

{ TAJob ***********************************************************************}

function TAJob.GetJobs(): TAJobs;
begin
  Assert(AItems is TAJobs);

  Result := TAJobs(AItems);
end;

{ TAJobExport *****************************************************************}

procedure TAJobExport.Assign(const Source: TPItem);
begin
  Assert(Source is TAJobExport);

  inherited Assign(Source);

  CodePage := TAJobExport(Source).CodePage;
  Filename := TAJobExport(Source).Filename;
end;

constructor TAJobExport.Create(const AAItems: TPItems = nil; const AName: string = '');
begin
  inherited;

  CodePage := CP_ACP;
  Filename := '';
  Objects := TStringList.Create();
end;

destructor TAJobExport.Destroy();
begin
  Objects.Free();

  inherited;
end;

function TAJobExport.GetXML(): IXMLNode;
var
  I: Integer;
begin
  if (not Assigned(FXML)) then
  begin
    for I := 0 to AItems.XML.ChildNodes.Count - 1 do
      if ((AItems.XML.ChildNodes[I].NodeName = 'job') and (lstrcmpi(PChar(string(AItems.XML.ChildNodes[I].Attributes['name'])), PChar(Name)) = 0)) then
        FXML := AItems.XML.ChildNodes[I];

    if (not Assigned(FXML) and (doNodeAutoCreate in AItems.XML.OwnerDocument.Options)) then
    begin
      FXML := AItems.XML.AddChild('job');
      FXML.Attributes['name'] := Name;
    end;
  end;

  Result := FXML;
end;

procedure TAJobExport.LoadFromXML(const XML: IXMLNode);
var
  Child: IXMLNode;
begin
  inherited;

  if (Assigned(XMLNode(XML, 'filename'))) then Filename := XMLNode(XML, 'filename').Text;
  if (Assigned(XMLNode(XML, 'filename')) and (XMLNode(XML, 'filename').Attributes['codepage'] <> Null)) then TryStrToInt(XMLNode(XML, 'filename').Attributes['codepage'], CodePage);
  if (Assigned(XMLNode(XML, 'type'))) then TryStrToExportType(XMLNode(XML, 'type').Text, ExportType);

  if (Assigned(XMLNode(XML, 'objects'))) then
  begin
    Objects.Clear();
    Child := XMLNode(XML, 'objects').ChildNodes.First();
    while (Assigned(Child)) do
    begin
      if (Child.NodeName = 'object') then
        Objects.Add(Jobs.Account.ExpandAddress(Child.Text));
      Child := Child.NextSibling();
    end;
  end;
end;

procedure TAJobExport.SaveToXML(const XML: IXMLNode);
var
  Child: IXMLNode;
  RemoveChild: IXMLNode;
  I: Integer;
begin
  inherited;

  XML.Attributes['type'] := 'export';

  XMLNode(XML, 'filename').Text := Filename;
  if (CodePage = CP_ACP) then XMLNode(XML, 'filename').Attributes['codepage'] := Null else XMLNode(XML, 'filename').Attributes['codepage'] := IntToStr(CodePage);
  XMLNode(XML, 'type').Text := ExportTypeToStr(ExportType);

  if (Assigned(XMLNode(XML, 'objects'))) then
  begin
    Child := XMLNode(XML, 'objects').ChildNodes.First();
    while (Assigned(Child)) do
    begin
      if (Child.NodeName <> 'object') then
        RemoveChild := nil
      else
        RemoveChild := Child;
      Child := Child.NextSibling();
      if (Assigned(RemoveChild)) then
        XMLNode(XML, 'objects').ChildNodes.Remove(RemoveChild);
    end;

    for I := 0 to Objects.Count - 1 do
      XMLNode(XML, 'objects').AddChild('object').Text := Jobs.Account.ExtractPath(Objects[I]);
  end;
end;

{ TAJobs **********************************************************************}

function TAJobs.AddJob(const NewJob: TPItem): Boolean;
var
  Job: TPItem;
begin
  Assert(NewJob is TAJobExport);

  Result := IndexByName(NewJob.Name) < 0;
  if (Result) then
  begin
    if (NewJob is TAJobExport) then
      Job := TAJobExport.Create(Self, NewJob.Name)
    else
      Job := nil;
    Job.Assign(NewJob);
    Add(Job);

    Account.AccountEvent(ClassType);

    SaveToXML();
  end;
end;

constructor TAJobs.Create(const AAccount: TAAccount);
begin
  inherited Create();

  FAccount := AAccount;
end;

procedure TAJobs.Delete(const Job: TPItem);
var
  Index: Integer;
begin
  Index := IndexOf(Job);

  XML.ChildNodes.Delete(XML.ChildNodes.IndexOf(Job.XML));

  Job.Free();
  Delete(Index);

  Account.AccountEvent(ClassType);
end;

destructor TAJobs.Destroy();
begin
  Clear();

  inherited;
end;

function TAJobs.GetJob(Index: Integer): TAJob;
begin
  Assert(Item[Index] is TAJob);

  Result := TAJob(Item[Index]);
end;

function TAJobs.GetXML(): IXMLNode;
begin
  if (not Assigned(FXMLDocument)) then
  begin
    if (FileExists(Account.JobsFilename)) then
      try
        FXMLDocument := LoadXMLDocument(Account.JobsFilename);
      except
        FXMLDocument := nil;
      end;

    if (not Assigned(FXMLDocument)) then
    begin
      FXMLDocument := NewXMLDocument();
      FXMLDocument.Encoding := 'utf-8';
      FXMLDocument.Node.AddChild('jobs').Attributes['version'] := '1.0.0';
    end;

    FXMLDocument.Options := FXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
  end;

  if (not Assigned(FXMLDocument)) then
    Result := nil
  else
    Result := FXMLDocument.DocumentElement;
end;

procedure TAJobs.LoadFromXML();
var
  Child: IXMLNode;
  Job: TPItem;
begin
  Clear();

  if (FileExists(Account.JobsFilename) and Assigned(XML)) then
  begin
    Child := XML.ChildNodes.First();
    while (Assigned(Child)) do
    begin
      if ((Child.NodeName = 'job') and (Child.Attributes['name'] <> '')) then
      begin
        if (Child.Attributes['type'] = 'export') then
          Job := TAJobExport.Create(Self, Child.Attributes['name'])
        else
          Job := nil;
        Job.LoadFromXML(Child);
        Add(Job);
      end;
      Child := Child.NextSibling();
    end;
  end;
end;

procedure TAJobs.SaveToXML();
var
  I: Integer;
begin
  if (Count = 0) then
  begin
    if (FileExists(Account.JobsFilename)) then
      DeleteFile(PChar(Account.JobsFilename));
  end
  else
  begin
    XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

    for I := 0 to Count - 1 do
      Item[I].SaveToXML(Item[I].XML);

    XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];

    if (XML.OwnerDocument.Modified) then
      XML.OwnerDocument.SaveToFile(Account.JobsFilename);
  end;
end;

{ TADesktop *******************************************************************}

procedure TADesktop.Assign(const Source: TADesktop);
var
  I: Integer;
  Kind: TListViewKind;
begin
  Address := Account.ExpandAddress(Source.Account.ExtractPath(Source.Address));
  BlobHeight := Source.BlobHeight;
  BookmarksVisible := Source.BookmarksVisible;
  for Kind := lkServer to lkVariables do
    for I := 0 to Length(ColumnWidths[Kind]) - 1 do
      ColumnWidths[Kind, I] := Source.ColumnWidths[Kind, I];
  DataHeight := Source.DataHeight;
  EditorContent := Source.EditorContent;
  ExplorerVisible := Source.ExplorerVisible;
  FilesFilter := Source.FilesFilter;
  FoldersHeight := Source.FoldersHeight;
  JobsVisible := Source.JobsVisible;
  LogHeight := Source.LogHeight;
  LogVisible := Source.LogVisible;
  NavigatorVisible := Source.NavigatorVisible;
  SelectorWitdth := Source.SelectorWitdth;
  SQLHistoryVisible := Source.SQLHistoryVisible;
end;

constructor TADesktop.Create(const AAccount: TAAccount);
var
  I: Integer;
  Kind: TListViewKind;
begin
  inherited Create();

  FAccount := AAccount;
  FXML := nil;

  AddressMRU := TMRUList.Create(10);
  BlobHeight := 100;
  BookmarksVisible := False;
  for Kind := lkServer to lkVariables do
    for I := 0 to Length(ColumnWidths[Kind]) - 1 do
      ColumnWidths[Kind][I] := ColumnTextWidth;
  DataHeight := 150;
  EditorContent := '';
  ExplorerVisible := False;
  FilesFilter := '*.sql';
  FoldersHeight := 100;
  JobsVisible := False;
  NavigatorVisible := True;
  LogHeight := 80;
  LogVisible := False;
  FPath := '/';
  SelectorWitdth := 150;
  SQLHistoryVisible := False;

  FBookmarks := TABookmarks.Create(Self);
  FFiles := TAFiles.Create(Self, 10);
end;

destructor TADesktop.Destroy();
begin
  AddressMRU.Free();
  FBookmarks.Free();
  FFiles.Free();

  inherited;
end;

function TADesktop.GetAddress(): string;
begin
  Result := Account.ExpandAddress(FPath);
end;

function TADesktop.GetXML(): IXMLNode;
begin
  if (not Assigned(FXML)) then
    FXML := Account.DesktopXML;

  Result := FXML;
end;

procedure TADesktop.LoadFromXML();
begin
  if (Assigned(XML)) then
  begin
    if (Assigned(XMLNode(XML, 'datagrid/height'))) then TryStrToInt(XMLNode(XML, 'datagrid/height').Text, DataHeight);
    if (Assigned(XMLNode(XML, 'datagrid/blob/height'))) then TryStrToInt(XMLNode(XML, 'datagrid/blob/height').Text, BlobHeight);
    if (Assigned(XMLNode(XML, 'editor/content'))) then EditorContent := XMLNode(XML, 'editor/content').Text;
    if (Assigned(XMLNode(XML, 'log/height'))) then TryStrToInt(XMLNode(XML, 'log/height').Text, LogHeight);
    if (Assigned(XMLNode(XML, 'log/visible'))) then TryStrToBool(XMLNode(XML, 'log/visible').Text, LogVisible);
    if (Assigned(XMLNode(XML, 'objects/server/widths/name'))) then TryStrToInt(XMLNode(XML, 'objects/server/widths/name').Text, ColumnWidths[lkServer][0]);
    if (Assigned(XMLNode(XML, 'objects/server/widths/size'))) then TryStrToInt(XMLNode(XML, 'objects/server/widths/size').Text, ColumnWidths[lkServer][1]);
    if (Assigned(XMLNode(XML, 'objects/server/widths/count'))) then TryStrToInt(XMLNode(XML, 'objects/server/widths/count').Text, ColumnWidths[lkServer][2]);
    if (Assigned(XMLNode(XML, 'objects/server/widths/created'))) then TryStrToInt(XMLNode(XML, 'objects/server/widths/created').Text, ColumnWidths[lkServer][3]);
    if (Assigned(XMLNode(XML, 'objects/server/widths/extras'))) then TryStrToInt(XMLNode(XML, 'objects/server/widths/extras').Text, ColumnWidths[lkServer][4]);
    if (Assigned(XMLNode(XML, 'objects/database/widths/name'))) then TryStrToInt(XMLNode(XML, 'objects/database/widths/name').Text, ColumnWidths[lkDatabase][0]);
    if (Assigned(XMLNode(XML, 'objects/database/widths/type'))) then TryStrToInt(XMLNode(XML, 'objects/database/widths/type').Text, ColumnWidths[lkDatabase][1]);
    if (Assigned(XMLNode(XML, 'objects/database/widths/recordcount'))) then TryStrToInt(XMLNode(XML, 'objects/database/widths/recordcount').Text, ColumnWidths[lkDatabase][2]);
    if (Assigned(XMLNode(XML, 'objects/database/widths/size'))) then TryStrToInt(XMLNode(XML, 'objects/database/widths/size').Text, ColumnWidths[lkDatabase][3]);
    if (Assigned(XMLNode(XML, 'objects/database/widths/updated'))) then TryStrToInt(XMLNode(XML, 'objects/database/widths/updated').Text, ColumnWidths[lkDatabase][4]);
    if (Assigned(XMLNode(XML, 'objects/database/widths/extras'))) then TryStrToInt(XMLNode(XML, 'objects/database/widths/extras').Text, ColumnWidths[lkDatabase][5]);
    if (Assigned(XMLNode(XML, 'objects/database/widths/comment'))) then TryStrToInt(XMLNode(XML, 'objects/database/widths/comment').Text, ColumnWidths[lkDatabase][6]);
    if (Assigned(XMLNode(XML, 'objects/table/widths/name'))) then TryStrToInt(XMLNode(XML, 'objects/table/widths/name').Text, ColumnWidths[lkTable][0]);
    if (Assigned(XMLNode(XML, 'objects/table/widths/type'))) then TryStrToInt(XMLNode(XML, 'objects/table/widths/type').Text, ColumnWidths[lkTable][1]);
    if (Assigned(XMLNode(XML, 'objects/table/widths/null'))) then TryStrToInt(XMLNode(XML, 'objects/table/widths/null').Text, ColumnWidths[lkTable][2]);
    if (Assigned(XMLNode(XML, 'objects/table/widths/default'))) then TryStrToInt(XMLNode(XML, 'objects/table/widths/default').Text, ColumnWidths[lkTable][3]);
    if (Assigned(XMLNode(XML, 'objects/table/widths/extras'))) then TryStrToInt(XMLNode(XML, 'objects/table/widths/extras').Text, ColumnWidths[lkTable][4]);
    if (Assigned(XMLNode(XML, 'objects/table/widths/comment'))) then TryStrToInt(XMLNode(XML, 'objects/table/widths/comment').Text, ColumnWidths[lkTable][5]);
    if (Assigned(XMLNode(XML, 'objects/hosts/widths/host'))) then TryStrToInt(XMLNode(XML, 'objects/hosts/widths/host').Text, ColumnWidths[lkHosts][0]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/id'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/id').Text, ColumnWidths[lkProcesses][0]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/user'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/user').Text, ColumnWidths[lkProcesses][1]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/host'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/host').Text, ColumnWidths[lkProcesses][2]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/database'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/database').Text, ColumnWidths[lkProcesses][3]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/command'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/command').Text, ColumnWidths[lkProcesses][4]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/statement'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/statement').Text, ColumnWidths[lkProcesses][5]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/time'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/time').Text, ColumnWidths[lkProcesses][6]);
    if (Assigned(XMLNode(XML, 'objects/processes/widths/state'))) then TryStrToInt(XMLNode(XML, 'objects/processes/widths/state').Text, ColumnWidths[lkProcesses][7]);
    if (Assigned(XMLNode(XML, 'objects/stati/widths/name'))) then TryStrToInt(XMLNode(XML, 'objects/stati/widths/name').Text, ColumnWidths[lkStati][0]);
    if (Assigned(XMLNode(XML, 'objects/stati/widths/value'))) then TryStrToInt(XMLNode(XML, 'objects/stati/widths/value').Text, ColumnWidths[lkStati][1]);
    if (Assigned(XMLNode(XML, 'objects/users/widths/name'))) then TryStrToInt(XMLNode(XML, 'objects/users/widths/name').Text, ColumnWidths[lkUsers][0]);
    if (Assigned(XMLNode(XML, 'objects/users/widths/fullname'))) then TryStrToInt(XMLNode(XML, 'objects/users/widths/fullname').Text, ColumnWidths[lkUsers][1]);
    if (Assigned(XMLNode(XML, 'objects/users/widths/comment'))) then TryStrToInt(XMLNode(XML, 'objects/users/widths/comment').Text, ColumnWidths[lkUsers][2]);
    if (Assigned(XMLNode(XML, 'objects/variables/widths/name'))) then TryStrToInt(XMLNode(XML, 'objects/variables/widths/name').Text, ColumnWidths[lkVariables][0]);
    if (Assigned(XMLNode(XML, 'objects/variables/widths/value'))) then TryStrToInt(XMLNode(XML, 'objects/variables/widths/value').Text, ColumnWidths[lkVariables][1]);
    if (Assigned(XMLNode(XML, 'path'))) then FPath := XMLNode(XML, 'path').Text;
    if (Assigned(XMLNode(XML, 'sidebar/explorer/folders/height'))) then TryStrToInt(XMLNode(XML, 'sidebar/explorer/folders/height').Text, FoldersHeight);
    if (Assigned(XMLNode(XML, 'sidebar/explorer/files/filter'))) then FilesFilter := XMLNode(XML, 'sidebar/explorer/files/filter').Text;
    if (Assigned(XMLNode(XML, 'sidebar/width'))) then TryStrToInt(XMLNode(XML, 'sidebar/width').Text, SelectorWitdth);
    if (Assigned(XMLNode(XML, 'sidebar/visible'))) then
    begin
      NavigatorVisible := UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'NAVIGATOR';
      BookmarksVisible := not NavigatorVisible and (UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'BOOKMARKS');
      ExplorerVisible := not NavigatorVisible and not BookmarksVisible and (UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'EXPLORER');
      JobsVisible := not NavigatorVisible and not BookmarksVisible and not ExplorerVisible and (UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'JOBS');
      SQLHistoryVisible := not NavigatorVisible and not BookmarksVisible and not ExplorerVisible and not JobsVisible and (UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'SQL HISTORY');
    end;

    Bookmarks.LoadFromXML();
    Files.LoadFromXML();
  end;
end;

procedure TADesktop.SaveToXML();
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  XMLNode(XML, 'datagrid/height').Text := IntToStr(DataHeight);
  XMLNode(XML, 'datagrid/blob/height').Text := IntToStr(BlobHeight);
  try
    XMLNode(XML, 'editor/content').Text := EditorContent;
  except
    XMLNode(XML, 'editor/content').Text := '';
  end;
  XMLNode(XML, 'log/height').Text := IntToStr(LogHeight);
  XMLNode(XML, 'log/visible').Text := BoolToStr(LogVisible, True);
  XMLNode(XML, 'objects/server/widths/name').Text := IntToStr(ColumnWidths[lkServer][0]);
  XMLNode(XML, 'objects/server/widths/count').Text := IntToStr(ColumnWidths[lkServer][1]);
  XMLNode(XML, 'objects/server/widths/size').Text := IntToStr(ColumnWidths[lkServer][2]);
  XMLNode(XML, 'objects/server/widths/created').Text := IntToStr(ColumnWidths[lkServer][3]);
  XMLNode(XML, 'objects/server/widths/extras').Text := IntToStr(ColumnWidths[lkServer][4]);
  XMLNode(XML, 'objects/database/widths/name').Text := IntToStr(ColumnWidths[lkDatabase][0]);
  XMLNode(XML, 'objects/database/widths/type').Text := IntToStr(ColumnWidths[lkDatabase][1]);
  XMLNode(XML, 'objects/database/widths/recordcount').Text := IntToStr(ColumnWidths[lkDatabase][2]);
  XMLNode(XML, 'objects/database/widths/size').Text := IntToStr(ColumnWidths[lkDatabase][3]);
  XMLNode(XML, 'objects/database/widths/updated').Text := IntToStr(ColumnWidths[lkDatabase][4]);
  XMLNode(XML, 'objects/database/widths/extras').Text := IntToStr(ColumnWidths[lkDatabase][5]);
  XMLNode(XML, 'objects/database/widths/comment').Text := IntToStr(ColumnWidths[lkDatabase][6]);
  XMLNode(XML, 'objects/table/widths/name').Text := IntToStr(ColumnWidths[lkTable][0]);
  XMLNode(XML, 'objects/table/widths/type').Text := IntToStr(ColumnWidths[lkTable][1]);
  XMLNode(XML, 'objects/table/widths/null').Text := IntToStr(ColumnWidths[lkTable][2]);
  XMLNode(XML, 'objects/table/widths/default').Text := IntToStr(ColumnWidths[lkTable][3]);
  XMLNode(XML, 'objects/table/widths/extras').Text := IntToStr(ColumnWidths[lkTable][4]);
  XMLNode(XML, 'objects/table/widths/comment').Text := IntToStr(ColumnWidths[lkTable][5]);
  XMLNode(XML, 'objects/hosts/widths/host').Text := IntToStr(ColumnWidths[lkHosts][0]);
  XMLNode(XML, 'objects/processes/widths/id').Text := IntToStr(ColumnWidths[lkProcesses][0]);
  XMLNode(XML, 'objects/processes/widths/user').Text := IntToStr(ColumnWidths[lkProcesses][1]);
  XMLNode(XML, 'objects/processes/widths/host').Text := IntToStr(ColumnWidths[lkProcesses][2]);
  XMLNode(XML, 'objects/processes/widths/database').Text := IntToStr(ColumnWidths[lkProcesses][3]);
  XMLNode(XML, 'objects/processes/widths/command').Text := IntToStr(ColumnWidths[lkProcesses][4]);
  XMLNode(XML, 'objects/processes/widths/statement').Text := IntToStr(ColumnWidths[lkProcesses][5]);
  XMLNode(XML, 'objects/processes/widths/time').Text := IntToStr(ColumnWidths[lkProcesses][6]);
  XMLNode(XML, 'objects/processes/widths/state').Text := IntToStr(ColumnWidths[lkProcesses][7]);
  XMLNode(XML, 'objects/stati/widths/name').Text := IntToStr(ColumnWidths[lkStati][0]);
  XMLNode(XML, 'objects/stati/widths/value').Text := IntToStr(ColumnWidths[lkStati][1]);
  XMLNode(XML, 'objects/users/widths/name').Text := IntToStr(ColumnWidths[lkUsers][0]);
  XMLNode(XML, 'objects/users/widths/fullname').Text := IntToStr(ColumnWidths[lkUsers][1]);
  XMLNode(XML, 'objects/users/widths/comment').Text := IntToStr(ColumnWidths[lkUsers][2]);
  XMLNode(XML, 'objects/variables/widths/name').Text := IntToStr(ColumnWidths[lkVariables][0]);
  XMLNode(XML, 'objects/variables/widths/value').Text := IntToStr(ColumnWidths[lkVariables][1]);
  if (FPath = '/.') then
    raise ERangeError.Create(SRangeError);
  XMLNode(XML, 'path').Text := FPath;
  XMLNode(XML, 'sidebar/explorer/folders/height').Text := IntToStr(FoldersHeight);
  XMLNode(XML, 'sidebar/explorer/files/filter').Text := FilesFilter;
  XMLNode(XML, 'sidebar/width').Text := IntToStr(SelectorWitdth);
  if (NavigatorVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'Navigator'
  else if (BookmarksVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'Bookmarks'
  else if (ExplorerVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'Explorer'
  else if (JobsVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'Jobs'
  else if (SQLHistoryVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'SQL History'
  else
    XMLNode(XML, 'sidebar/visible').Text := BoolToStr(False, True);

  Bookmarks.SaveToXML();
  Files.SaveToXML();

  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];
end;

procedure TADesktop.SetAddress(AAddress: string);
begin
  FPath := Account.ExtractPath(AAddress);

  if (FPath = '/.') then
    raise ERangeError.Create(SRangeError);
end;

{ TAConnection ****************************************************************}

procedure TAConnection.Assign(const Source: TAConnection);
begin
  Charset := Source.Charset;
  Database := Source.Database;
  Host := Source.Host;
  HTTPTunnelURI := Source.HTTPTunnelURI;
  LibraryFilename := Source.LibraryFilename;
  LibraryType := Source.LibraryType;
  Password := Source.Password;
  PipeName := Source.PipeName;
  Port := Source.Port;
  User := Source.User;
end;

constructor TAConnection.Create(const AAccount: TAAccount);
begin
  inherited Create();

  FAccount := AAccount;
  FXML := nil;

  Charset := '';
  Database := '';
  Host := '';
  HTTPTunnelURI := '';
  LibraryFilename := 'libMySQL.dll';
  LibraryType := ltBuiltIn;
  Password := '';
  PipeName := MYSQL_NAMEDPIPE;
  Port := MYSQL_PORT;
  User := '';
end;

function TAConnection.GetXML(): IXMLNode;
begin
  if (not Assigned(FXML) and Assigned(Account.XML)) then
    FXML := XMLNode(Account.XML, 'connection');

  Result := FXML;
end;

procedure TAConnection.LoadFromXML();
begin
  if (Assigned(XML)) then
  begin
    if (Assigned(XMLNode(XML, 'character_set'))) then Charset := XMLNode(XML, 'character_set').Text;
    if (Assigned(XMLNode(XML, 'database'))) then Database := XMLNode(XML, 'database').Text;
    if (Assigned(XMLNode(XML, 'host'))) then Host := XMLNode(XML, 'host').Text;
    if (Assigned(XMLNode(XML, 'library/type'))) then
      if (UpperCase(XMLNode(XML, 'library/type').Text) = 'FILE') then LibraryType := ltDLL
      else if (UpperCase(XMLNode(XML, 'library/type').Text) = 'TUNNEL') then LibraryType := ltHTTP
      else if (UpperCase(XMLNode(XML, 'library/type').Text) = 'HTTPTUNNEL') then LibraryType := ltHTTP
      else if (UpperCase(XMLNode(XML, 'library/type').Text) = 'NAMEDPIPE') then LibraryType := ltNamedPipe
      else LibraryType := ltBuiltIn;
    if (Assigned(XMLNode(XML, 'library/filename'))) then LibraryFilename := XMLNode(XML, 'library/filename').Text;
    if (Assigned(XMLNode(XML, 'library/pipename'))) then PipeName := XMLNode(XML, 'library/pipename').Text;
    if (Assigned(XMLNode(XML, 'library/tunnel_url'))) then HTTPTunnelURI := XMLNode(XML, 'library/tunnel_url').Text;
    if (Assigned(XMLNode(XML, 'password')) and (XMLNode(XML, 'password').Attributes['encode'] = 'none')) then Password := XMLNode(XML, 'password').Text;
    if (Assigned(XMLNode(XML, 'port'))) then TryStrToInt(XMLNode(XML, 'port').Text, Port);
    if (Assigned(XMLNode(XML, 'user'))) then User := XMLNode(XML, 'user').Text;
  end;
end;

procedure TAConnection.SaveToXML();
begin
  XMLNode(XML, 'character_set').Text := Charset;
  XMLNode(XML, 'database').Text := Database;
  XMLNode(XML, 'host').Text := Host;
  case (LibraryType) of
    ltDLL: XMLNode(XML, 'library/type').Text := 'File';
    ltHTTP: XMLNode(XML, 'library/type').Text := 'HTTPTunnel';
    ltNamedPipe: XMLNode(XML, 'library/type').Text := 'NamedPipe';
    else XMLNode(XML, 'library').ChildNodes.Delete('type');
  end;
  XMLNode(XML, 'library/filename').Text := LibraryFilename;
  XMLNode(XML, 'library/pipename').Text := PipeName;
  XMLNode(XML, 'library/tunnel_url').Text := HTTPTunnelURI;
  XMLNode(XML, 'password').Attributes['encode'] := 'none';
  XMLNode(XML, 'password').Text := Password;
  XMLNode(XML, 'port').Text := IntToStr(Port);
  XMLNode(XML, 'user').Text := User;
end;

{ TAAccount *******************************************************************}

procedure TAAccount.AccountEvent(const ClassType: TClass);
var
  I: Integer;
begin
  for I := 0 to Length(FDesktops) - 1 do
    if (Assigned(FDesktops[I].AccountEventProc)) then
      FDesktops[I].AccountEventProc(ClassType);
end;

procedure TAAccount.Assign(const Source: TAAccount);
begin
  if (not Assigned(Accounts)) then FAccounts := Source.Accounts;

  FLastLogin := Source.LastLogin;
  IconFetched := Source.IconFetched;
  ImageIndex := Source.ImageIndex;
  ManualURL := Source.ManualURL;
  ManualURLFetched := Source.ManualURLFetched;
  Name := Source.Name;

  Modified := True;

  Connection.Assign(Source.Connection);
  if (Assigned(Desktop) and Assigned(Source.Desktop)) then
    Desktop.Assign(Source.Desktop);
end;

constructor TAAccount.Create(const AAccounts: TAAccounts; const AXML: IXMLNode = nil);
begin
  FAccounts := AAccounts;
  FXML := AXML;

  FDesktopXMLDocument := nil;
  FHistoryXMLDocument := nil;
  FLastLogin := 0;
  IconFetched := False;
  ImageIndex := 23;
  ManualURL := '';
  ManualURLFetched := False;
  Modified := False;

  Connection := TAConnection.Create(Self);
  FDesktop := nil;
  FJobs := nil;
end;

destructor TAAccount.Destroy();
begin
  if (Assigned(FDesktop)) then FDesktop.Free();
  if (Assigned(FJobs)) then FJobs.Free();
  Connection.Free();

  inherited;
end;

function TAAccount.ExtractPath(const AAddress: string): string;
var
  URI: TUURI;
begin
  URI := TUURI.Create(AAddress);
  Result := URI.Path + URI.ExtraInfos;
  URI.Free();
end;

function TAAccount.ExpandAddress(const APath: string): string;
var
  Len: Cardinal;
  URL: array[0 .. INTERNET_MAX_URL_LENGTH] of Char;
  URLComponents: URL_COMPONENTS;
begin
  ZeroMemory(@URLComponents, SizeOf(URLComponents));
  URLComponents.dwStructSize := SizeOf(URLComponents);

  URLComponents.lpszScheme := PChar('mysql');
  URLComponents.lpszHostName := PChar(Connection.Host);
  if (Connection.Port <> MYSQL_PORT) then
    URLComponents.nPort := Connection.Port;
  URLComponents.lpszUrlPath := PChar(APath);

  Len := Length(URL);
  if (not InternetCreateUrl(URLComponents, ICU_ESCAPE, @URL, Len)) then
    RaiseLastOSError()
  else
    SetString(Result, PChar(@URL), Len);
end;

function TAAccount.Frame(): Pointer;
begin
  if (Length(FDesktops) = 0) then
    Result := nil
  else
    Result := FDesktops[0].Control;
end;

function TAAccount.GetBookmarksFilename(): TFileName;
begin
  if (not DirectoryExists(DataPath)) then
    Result := ''
  else
    Result := DataPath + 'Bookmarks.xml';
end;

function TAAccount.GetDataPath(): TFileName;
begin
  Result := Accounts.DataPath + ReplaceStr(Name, '/', '_') + PathDelim;
end;

function TAAccount.GetDefaultDatabase(): string;
var
  DatabaseNames: TCSVStrings;
  Found: Boolean;
  I: Integer;
  URI: TUURI;
begin
  Result := '';

  if (Assigned(Desktop)) then
  begin
    URI := TUURI.Create(Desktop.Address);

    if (ValidDatabaseName(URI.Database)) then
    begin
      Result := URI.Database;

      if (Connection.Database <> '') then
      begin
        SetLength(DatabaseNames, 0);
        CSVSplitValues(Connection.Database, ',', '"', DatabaseNames);

        Found := False;
        for I := 0 to Length(DatabaseNames) - 1 do
          if (lstrcmpi(PChar(DatabaseNames[I]), PChar(Result)) = 0) then
            Found := True;
        if (not Found) then
          Result := '';

        SetLength(DatabaseNames, 0);
      end;
    end;

    URI.Free();

    if (Result = '') then
    begin
      SetLength(DatabaseNames, 0);
      CSVSplitValues(Connection.Database, ',', '"', DatabaseNames);

      if (Length(DatabaseNames) = 0) then
        Result := ''
      else
        Result := DatabaseNames[0];

      SetLength(DatabaseNames, 0);
    end;
  end;
end;

function TAAccount.GetDesktop(): TADesktop;
begin
  if (not Assigned(FDesktop) and Assigned(DesktopXML)) then
    FDesktop := TADesktop.Create(Self);

  Result := FDesktop;
end;

function TAAccount.GetDesktopCount(): Integer;
begin
  Result := Length(FDesktops);
end;

function TAAccount.GetDesktopFilename(): TFileName;
begin
  if (not DirectoryExists(DataPath)) then
    Result := ''
  else
    Result := DataPath + 'Desktop.xml';
end;

function TAAccount.GetDesktopXML(): IXMLNode;
var
  Node: IXMLNode;
begin
  if (not Assigned(FDesktopXMLDocument)) then
  begin
    if (FileExists(DesktopFilename)) then
      try
        FDesktopXMLDocument := LoadXMLDocument(DesktopFilename);
      except
        FDesktopXMLDocument := nil;
      end;

    if (not Assigned(FDesktopXMLDocument)) then
    begin
      FDesktopXMLDocument := NewXMLDocument();
      FDesktopXMLDocument.Encoding := 'utf-8';
      FDesktopXMLDocument.Node.AddChild('desktop').Attributes['version'] := '1.3.1';
    end;

    if (VersionStrToVersion(FDesktopXMLDocument.DocumentElement.Attributes['version']) < 10300)  then
    begin
      Node := FDesktopXMLDocument.DocumentElement;
      if (Assigned(Node) and Assigned(XMLNode(Node, 'address'))) then
        Node.ChildNodes.Remove(XMLNode(Node, 'address'));

      FDesktopXMLDocument.DocumentElement.Attributes['version'] := '1.3';
    end;

    if (VersionStrToVersion(FDesktopXMLDocument.DocumentElement.Attributes['version']) < 10301)  then
    begin
      Node := FDesktopXMLDocument.DocumentElement;
      if (Assigned(XMLNode(Node, 'browser'))) then
        Node.ChildNodes.Remove(XMLNode(Node, 'browser'));
      Node := XMLNode(Node, 'editor');
      if (Assigned(XMLNode(Node, 'filename'))) then
        Node.ChildNodes.Remove(XMLNode(Node, 'filename'));

      FDesktopXMLDocument.DocumentElement.Attributes['version'] := '1.3.1';
    end;

    FDesktopXMLDocument.Options := FDesktopXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
  end;

  Result := FDesktopXMLDocument.DocumentElement;
end;

function TAAccount.GetHistoryFilename(): TFileName;
begin
  if (not DirectoryExists(DataPath)) then
    Result := ''
  else
    Result := DataPath + 'History.xml'
end;

function TAAccount.GetHistoryXML(): IXMLNode;
begin
  if (not Assigned(FHistoryXMLDocument)) then
  begin
    CoInitialize(nil);

    if (FileExists(HistoryFilename)) then
      try
        FHistoryXMLDocument := LoadXMLDocument(HistoryFilename);
      except
        FHistoryXMLDocument := nil;
      end;

    if (not Assigned(FHistoryXMLDocument)) then
    begin
      FHistoryXMLDocument := NewXMLDocument();
      FHistoryXMLDocument.Encoding := 'utf-8';
      FHistoryXMLDocument.Node.AddChild('history').Attributes['version'] := '1.0';
    end;

    FHistoryXMLDocument.Options := FHistoryXMLDocument.Options - [doAttrNull, doNodeAutoCreate];

    CoUninitialize();
  end;

  Result := FHistoryXMLDocument.DocumentElement;
end;

function TAAccount.GetIconFilename(): TFileName;
begin
  if (not ForceDirectories(DataPath)) then
    Result := ''
  else
    Result := DataPath + 'favicon.ico';
end;

function TAAccount.GetIndex(): Integer;
begin
  Result := Accounts.IndexOf(Self);
end;

function TAAccount.GetJobs(): TAJobs;
begin
  if (not Assigned(FJobs)) then
    FJobs := TAJobs.Create(Self);

  Result := FJobs;
end;

function TAAccount.GetJobsFilename(): TFileName;
begin
  if (not DirectoryExists(DataPath)) then
    Result := ''
  else
    Result := DataPath + 'Jobs.xml'
end;

function TAAccount.GetName(): string;
begin
  if (FName = '') and (Assigned(XML)) then
    FName := XML.Attributes['name'];

  Result := FName;
end;

function TAAccount.GetXML(): IXMLNode;
var
  I: Integer;
begin
  if (not Assigned(FXML) and Assigned(Accounts) and Assigned(Accounts.XML) and (FName <> '')) then
  begin
    for I := 0 to Accounts.XML.ChildNodes.Count - 1 do
      if ((Accounts.XML.ChildNodes[I].NodeName = 'account') and (lstrcmpi(PChar(string(Accounts.XML.ChildNodes[I].Attributes['name'])), PChar(FName)) = 0)) then
        FXML := Accounts.XML.ChildNodes[I];
    if (not Assigned(FXML) and (doNodeAutoCreate in Accounts.XML.OwnerDocument.Options)) then
    begin
      FXML := Accounts.XML.AddChild('account');
      FXML.Attributes['name'] := FName;
    end;
  end;

  Result := FXML;
end;

function TAAccount.JobByName(const Name: string): TAJob;
var
  Index: Integer;
begin
  Index := Jobs.IndexByName(Name);
  if (Index < 0) then
    Result := nil
  else
    Result := Jobs[Index];
end;

procedure TAAccount.LoadFromXML();
begin
  if (Assigned(XML)) then
  begin
    if (Assigned(XMLNode(XML, 'iconfetched'))) then TryStrToBool(XMLNode(XML, 'iconfetched').Text, IconFetched);
    if (Assigned(XMLNode(XML, 'lastlogin'))) then
      TryStrToFloat(ReplaceStr(XMLNode(XML, 'lastlogin').Text, '.', FormatSettings.DecimalSeparator), Double(FLastLogin));
    if (Assigned(XMLNode(XML, 'manualurl'))) then ManualURL := XMLNode(XML, 'manualurl').Text;
    if (Assigned(XMLNode(XML, 'manualurlfetched'))) then TryStrToBool(XMLNode(XML, 'manualurlfetched').Text, ManualURLFetched);

    Modified := False;

    Connection.LoadFromXML();
    if (Assigned(Desktop)) then
      Desktop.LoadFromXML(); // Client muss geladen sein, damit FullAddress funktioniert
    Jobs.LoadFromXML();
  end;
end;

procedure TAAccount.RegisterDesktop(const AControl: Pointer; const AEventProc: TEventProc);
begin
  SetLength(FDesktops, Length(FDesktops) + 1);
  FDesktops[Length(FDesktops) - 1].Control := AControl;
  FDesktops[Length(FDesktops) - 1].AccountEventProc := AEventProc;
end;

procedure TAAccount.SaveToXML();
begin
  if (Assigned(XML)) then
  begin
    XMLNode(XML, 'iconfetched').Text := BoolToStr(IconFetched, True);
    XMLNode(XML, 'lastlogin').Text := FloatToStr(LastLogin);
    XMLNode(XML, 'manualurl').Text := ManualURL;
    XMLNode(XML, 'manualurlfetched').Text := BoolToStr(ManualURLFetched, True);

    Connection.SaveToXML();
    if (Assigned(Desktop)) then
      Desktop.SaveToXML();

    if (ForceDirectories(DataPath)) then
    begin
      if (Assigned(DesktopXMLDocument) and DesktopXMLDocument.Modified) then
        if (ForceDirectories(ExtractFilePath(DesktopFilename))) then
          DesktopXMLDocument.SaveToFile(DesktopFilename);
      if (Assigned(HistoryXMLDocument) and HistoryXMLDocument.Modified) then
        if (ForceDirectories(ExtractFilePath(HistoryFilename))) then
          HistoryXMLDocument.SaveToFile(HistoryFilename);
      Jobs.SaveToXML();
    end;

    Modified := False;
 end;
end;

procedure TAAccount.SetLastLogin(const ALastLogin: TDateTime);
begin
  FLastLogin := ALastLogin;

  Modified := True;
end;

procedure TAAccount.SetName(const AName: string);
begin
  Assert(not Assigned(FXML) or (AName = FXML.Attributes['name']));


  FName := AName;
end;

procedure TAAccount.UnRegisterDesktop(const AControl: Pointer);
var
  I: Integer;
  J: Integer;
begin
  I := 0;
  while (I < Length(FDesktops)) do
    if (FDesktops[I].Control <> AControl) then
      Inc(I)
    else
    begin
      for J := I to Length(FDesktops) - 2 do
        FDesktops[J] := FDesktops[J + 1];
      SetLength(FDesktops, Length(FDesktops) - 1);
    end;
end;

function TAAccount.ValidDatabaseName(const ADatabaseName: string): Boolean;
var
  S: string;
  TempDatabaseName: string;
begin
  Result := False;
  S := Connection.Database;

  while (S <> '') do
    if (Pos(',', S) = 0) then
      begin
        if (S = ADatabaseName) then
          Result := True;
        S := '';
      end
    else
      begin
        TempDatabaseName := Copy(S, 1, Pos(',', S) - 1);
        Delete(S, 1, Pos(',', S));
        if (TempDatabaseName = ADatabaseName) then
          Result := True;
      end;
end;

{ TAAccounts ******************************************************************}

procedure TAAccounts.AddAccount(const NewAccount: TAAccount);
begin
  if (not Assigned(AccountByName(NewAccount.Name))) then
  begin
    Add(TAAccount.Create(Self));
    Account[Count - 1].Assign(NewAccount);

    AppendIconsToImageList(Preferences.SmallImages, NewAccount);
  end;
end;

procedure TAAccounts.AppendIconsToImageList(const AImageList: TImageList; const AAccount: TAAccount = nil);
var
  I: Integer;
  Icon: TIcon;
begin
  if (Assigned(AImageList)) then
  begin
    Icon := TIcon.Create();

    for I := 0 to Count - 1 do
      if (not Assigned(AAccount) or (Account[I] = AAccount)) then
        if (FileExists(Account[I].IconFilename)) then
          try
            Icon.LoadFromFile(Account[I].IconFilename);
            Account[I].ImageIndex := AImageList.Count;
            ImageList_AddIcon(AImageList.Handle, Icon.Handle);
          except
            Account[I].ImageIndex := 23;
          end
        else if (HostIsLocalHost(Account[I].Connection.Host)) then
          Account[I].ImageIndex := 13
        else
          Account[I].ImageIndex := 23;

    Icon.Free();
  end;
end;

procedure TAAccounts.Clear();
begin
  while (Count > 0) do
  begin
    Account[0].Free();
    Delete(0);
  end;

  inherited;
end;

constructor TAAccounts.Create(const ADBLogin: TDBLogin);
var
  Msg: string;
  StringList: TStringList;
begin
  inherited Create();

  FDBLogin := ADBLogin;

  Section := 'Accounts';

  // "Sessions" used up to version 5.1 // May 2012
  if (DirectoryExists(Preferences.UserPath + 'Sessions' + PathDelim)
    and not DirectoryExists(DataPath)
    and not CopyDir(PChar(Preferences.UserPath + 'Sessions' + PathDelim), PChar(DataPath))) then
  begin
    Msg := 'Cannot copy folder'  + #13#10
      + Preferences.UserPath + 'Sessions' + PathDelim + #13#10
      + 'to' + #13#10
      + DataPath + #13#10
      + '(Error #' + IntToStr(GetLastError()) + ': ' + SysErrorMessage(GetLastError()) + ')';
    MessageBox(0, PChar(Msg), 'ERROR', MB_OK + MB_ICONERROR);
  end;
  if (FileExists(DataPath + 'Sessions.xml') and not FileExists(Filename)) then
  begin
    if (CopyFile(PChar(DataPath + 'Sessions.xml'), PChar(Filename), False)) then
    begin
      StringList := TStringList.Create();
      StringList.LoadFromFile(Filename);
      StringList.Text := ReplaceStr(StringList.Text, '<session', '<account');
      StringList.Text := ReplaceStr(StringList.Text, '</session', '</account');
      StringList.SaveToFile(Filename);
      StringList.Free();
    end;
  end;

  LoadFromXML();

  AppendIconsToImageList(Preferences.SmallImages);
end;

function TAAccounts.DeleteAccount(const AAccount: TAAccount): Boolean;
var
  I: Integer;
  Index: Integer;
begin
  if (FileExists(AAccount.DesktopFilename)) then
    DeleteFile(PChar(AAccount.DesktopFilename));
  if (FileExists(AAccount.HistoryFilename)) then
    DeleteFile(PChar(AAccount.HistoryFilename));
  if (FileExists(AAccount.IconFilename)) then
    DeleteFile(PChar(AAccount.IconFilename));
  if (DirectoryExists(AAccount.DataPath)) then
    RemoveDirectory(PChar(AAccount.DataPath));

  for I := XML.ChildNodes.Count - 1 downto 0 do
    if ((XML.ChildNodes[I].NodeName = 'account') and (lstrcmpi(PChar(string(XML.ChildNodes[I].Attributes['name'])), PChar(AAccount.Name)) = 0)) then
      XML.ChildNodes.Remove(XML.ChildNodes[I]);

  Index := IndexOf(AAccount);

  Account[Index].Free();
  Delete(Index);

  SaveToXML();

  Result := True;
end;

destructor TAAccounts.Destroy();
begin
  SaveToXML();

  Clear();

  inherited;
end;

function TAAccounts.GetDataPath(): TFileName;
begin
  Result := Preferences.UserPath + 'Accounts' + PathDelim;
end;

function TAAccounts.GetDefault(): TAAccount;
begin
  Result := AccountByName(DefaultAccountName);
end;

function TAAccounts.GetFilename(): TFileName;
begin
  Result := DataPath + 'Accounts.xml';
end;

function TAAccounts.GetFAccounts(Index: Integer): TAAccount;
begin
  Result := TAAccount(Items[Index]);
end;

function TAAccounts.GetXML(): IXMLNode;
begin
  if (not Assigned(FXMLDocument)) then
  begin
    if (FileExists(Filename)) then
    begin
      FXMLDocument := LoadXMLDocument(Filename);
    end
    else
    begin
      FXMLDocument := NewXMLDocument();
      FXMLDocument.Encoding := 'utf-8';
      FXMLDocument.Node.AddChild('accounts').Attributes['version'] := '1.1.0';
    end;

    FXMLDocument.Options := FXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
  end;

  Result := FXMLDocument.DocumentElement;
end;

procedure TAAccounts.LoadFromXML();
var
  I: Integer;
  Index: Integer;
  J: Integer;
begin
  Clear();

  if (Assigned(XML)) then
  begin
    FXMLDocument.Options := FXMLDocument.Options - [doNodeAutoCreate];

    for I := 0 to XML.ChildNodes.Count - 1 do
    begin
      if ((XML.ChildNodes[I].NodeName = 'account') and (XML.ChildNodes[I].Attributes['name'] <> '')) then
      begin
        Index := TList(Self).Count;
        for J := TList(Self).Count - 1 downto 0 do
          if (lstrcmpi(PChar(string(XML.ChildNodes[I].Attributes['name'])), PChar(Account[J].Name)) <= 0) then
            Index := J;

        Insert(Index, TAAccount.Create(Self, XML.ChildNodes[I]));
        Account[Index].LoadFromXML();
      end;
    end;

    if (Assigned(XMLNode(XML, 'default'))) then
      DefaultAccountName := XMLNode(XML, 'default').Text;

    FXMLDocument.Options := FXMLDocument.Options + [doNodeAutoCreate];
  end;
end;

procedure TAAccounts.SaveToXML();
var
  I: Integer;
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  for I := 0 to Count - 1 do
    if (Account[I].Modified) then
      Account[I].SaveToXML();

  if (Assigned(XML)) then
    XMLNode(XML, 'default').Text := DefaultAccountName;

  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];


  if (Assigned(FXMLDocument) and FXMLDocument.Modified) then
    if (ForceDirectories(ExtractFilePath(Filename))) then
      FXMLDocument.SaveToFile(Filename);
end;

function TAAccounts.AccountByName(const AccountName: string): TAAccount;
var
  I: Integer;
begin
  Result := nil;

  for I:=0 to Count - 1 do
    if (Account[I].Name = AccountName) then
      Result := Account[I];
end;

function TAAccounts.AccountByURI(const AURI: string; const DefaultAccount: TAAccount = nil): TAAccount;
var
  Found: Integer;
  Host: string;
  I: Integer;
  Name: string;
  NewAccount: TAAccount;
  NewAccountName: string;
  URI: TUURI;
  URLComponents: TURLComponents;
begin
  Result := nil;

  if (LowerCase(Copy(AURI, 1, 8)) = 'mysql://') then
    URI := TUURI.Create(AURI)
  else
    URI := nil;

  if (Assigned(URI)) then
  begin
    Found := 0;
    for I := 0 to Count - 1 do
    begin
      ZeroMemory(@URLComponents, SizeOf(URLComponents));
      URLComponents.dwStructSize := SizeOf(URLComponents);
      if ((Account[I].Connection.LibraryType <> ltHTTP) or (lstrcmpi(PChar(Account[I].Connection.Host), LOCAL_HOST) <> 0)) then
        Host := LowerCase(Account[I].Connection.Host)
      else if (InternetCrackUrl(PChar(Account[I].Connection.HTTPTunnelURI), Length(Account[I].Connection.HTTPTunnelURI), 0, URLComponents)) then
      begin
        Inc(URLComponents.dwHostNameLength);
        GetMem(URLComponents.lpszHostName, URLComponents.dwHostNameLength * SizeOf(URLComponents.lpszHostName[0]));
        InternetCrackUrl(PChar(Account[I].Connection.HTTPTunnelURI), Length(Account[I].Connection.HTTPTunnelURI), 0, URLComponents);
        SetString(Host, URLComponents.lpszHostName, URLComponents.dwHostNameLength);
        FreeMem(URLComponents.lpszHostName);
      end
      else
        Host := LOCAL_HOST;
      if ((lstrcmpi(PChar(Host), PChar(URI.Host)) = 0) and (URI.Port = Account[I].Connection.Port)
        and ((URI.Username = '') or (lstrcmpi(PChar(URI.Username), PChar(Account[I].Connection.User)) = 0))) then
      begin
        Result := Account[I];
        Inc(Found);
        if ((Result = DefaultAccount) or (Result.DesktopCount > 0)) then
          break;
      end;
    end;

    if (Found = 0) then
    begin
      NewAccountName := URI.Host;
      if (URI.Username <> '') then
        NewAccountName := NewAccountName + ' (' + URI.Username + ')';
      Name := NewAccountName;
      I := 1;
      while (Assigned(AccountByName(Name))) do
      begin
        Inc(I);
        Name := NewAccountName + ' (' + IntToStr(I) + ')';
      end;

      NewAccount := TAAccount.Create(Self);
      NewAccount.Name := Name;
      NewAccount.Connection.Host := URI.Host;
      NewAccount.Connection.Port := URI.Port;
      NewAccount.Connection.User := URI.Username;
      NewAccount.Connection.Password := URI.Password;
      NewAccount.Connection.Database := URI.Database;
      AddAccount(NewAccount);
      NewAccount.Free();

      Result := AccountByName(NewAccountName);

      SaveToXML();
    end;

    URI.Free();
  end;
end;

procedure TAAccounts.SetDefault(const AAccount: TAAccount);
begin
  if (not Assigned(AAccount)) then
    DefaultAccountName := ''
  else
    DefaultAccountName := AAccount.Name;
end;

procedure TAAccounts.UpdateAccount(const Account, NewAccount: TAAccount);
begin
  if (Assigned(Account) and Assigned(NewAccount) and (not Assigned(AccountByName(NewAccount.Name)) or (NewAccount.Name = Account.Name))) then
  begin
    if (Assigned(Account.XML)) then
      Account.XML.Attributes['name'] := NewAccount.Name;

    if (NewAccount.Name <> Account.Name) then
      if (DirectoryExists(Account.DataPath)) then
        RenameFile(Account.DataPath, NewAccount.DataPath);

    Account.Assign(NewAccount);

    AppendIconsToImageList(Preferences.SmallImages, NewAccount);

    SaveToXML();
  end;
end;

{******************************************************************************}

initialization
  Preferences := nil;

  FileFormatSettings := TFormatSettings.Create(LOCALE_SYSTEM_DEFAULT);
  FileFormatSettings.ThousandSeparator := ',';
  FileFormatSettings.DecimalSeparator := '.';
  FileFormatSettings.DateSeparator := '/';
  FileFormatSettings.TimeSeparator := ':';
  FileFormatSettings.ListSeparator := ',';
  FileFormatSettings.ShortDateFormat := 'dd/mm/yy';
  FileFormatSettings.LongDateFormat := 'dd/mm/yyyy';
  FileFormatSettings.TimeAMString := '';
  FileFormatSettings.TimePMString := '';
  FileFormatSettings.ShortTimeFormat := 'hh:mm';
  FileFormatSettings.LongTimeFormat := 'hh:mm:ss';
end.

