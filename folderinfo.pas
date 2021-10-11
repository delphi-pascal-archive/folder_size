unit folderinfo;

interface

type
  PFolderInfo = ^TFolderInfo;
  TFolderInfo = class
  private
    fName: string;
    fFileCount: integer;
    fSize: int64;
    fFullName: string;
    fFolderCount: integer;
    fParentFolderInfo : PFolderInfo;
  public
    property FullName : string read fFullName; // full folder path - "c:\dir\subdir"
    property Name : string read fName; //only folder name - "subdir"
    property FileCount : integer read fFileCount;
    property FolderCount : integer read fFolderCount;
    property Size : int64 read fSize;
    property ParentFolderInfo : PFolderInfo read fParentFolderInfo write fParentFolderInfo;

    constructor Create(const fullName : string);

    procedure AddFile(const fileSize : integer);
    procedure AddFolder;
  end;
implementation

uses SysUtils;

{ TFolderInfo }

procedure TFolderInfo.AddFile(const fileSize: integer);
begin
  fFileCount := 1 + fFileCount;
  fSize := fileSize + fSize;

  if ParentFolderInfo <> nil then ParentFolderInfo^.AddFile(fileSize);
end;

procedure TFolderInfo.AddFolder;
begin
  fFolderCount := 1 + fFolderCount;

  if ParentFolderInfo <> nil then ParentFolderInfo.AddFolder;
end;

constructor TFolderInfo.Create(const fullName : string);
begin
  fParentFolderInfo := nil;
  fFullName := fullName;
  fName := ExtractFileName(ExcludeTrailingPathDelimiter(fullName));
  fFileCount := 0;
  fFolderCount := 0;
  fSize := 0;
end;


end.
