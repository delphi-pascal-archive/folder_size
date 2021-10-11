unit searchthread;

interface

uses
  main, folderinfo,
  Classes, SysUtils, ComCtrls, Windows;

type
  TSearchThread = class(TThread)
  private
    fRootFolder: string;
    fParentNode: TTreeNode;
    fFolderInfo: TFolderInfo;
    fSelfNode: TTreeNode;
  protected
    procedure Execute; override;
  public
    procedure NewFolderNode;
    procedure UpdateThreadsRunning;
    procedure Terminated(Sender : TObject);
    constructor Create(const rootFolder : string; const parentNode : TTreeNode); reintroduce;
    destructor Derstroy;
    property RootFolder : string read fRootFolder;
    property ParentNode : TTreeNode read fParentNode;
    property SelfNode : TTreeNode read fSelfNode;
    property FolderInfo : TFolderInfo read fFolderInfo;
  end;

implementation

{ TSearchThread }

constructor TSearchThread.Create(const rootFolder: string; const parentNode : TTreeNode);
begin
  inherited Create(true);
  fFolderInfo := TFolderInfo.Create(rootFolder);
  fRootFolder := IncludeTrailingPathDelimiter(rootFolder);
  fParentNode := parentNode;
  fSelfNode := nil;
  OnTerminate := Terminated;
  FreeOnTerminate := True;
  MainForm.ThreadsRunning := MainForm.ThreadsRunning + 1;
  Resume;
end;

destructor TSearchThread.Derstroy;
begin
  fFolderInfo.Free;
end;

procedure TSearchThread.Execute;
var
  Rec  : TSearchRec;
begin
  inherited;

  
  Synchronize (NewFolderNode);

  //recourse for other sub-folders
  if FindFirst (RootFolder + '*.*', faDirectory, Rec) = 0 then
  try
    repeat
      if ((Rec.Attr and faDirectory) = faDirectory) and (Rec.Name<>'.') and (Rec.Name<>'..') then
      begin
        FolderInfo.AddFolder;
        (*
        repeat
        // wait max threads = 50
        until MainForm.ThreadsRunning < 50;
        *)
        TSearchThread.Create(RootFolder + Rec.Name,SelfNode);
      end;
    until FindNext(Rec) <> 0;
  finally
    SysUtils.FindClose(Rec);
  end;

 //process files here
  if FindFirst (RootFolder + '*.*', faAnyFile - faDirectory, Rec) = 0 then
  try
    repeat
      FolderInfo.AddFile(Rec.Size);
    until FindNext(Rec) <> 0;
  finally
    SysUtils.FindClose(Rec);
  end;
end;

procedure TSearchThread.NewFolderNode;
var
  fName : string;
begin
  if ParentNode <> nil then
    fName := ExtractFileName(ExcludeTrailingPathDelimiter(FolderInfo.Name))
  else
    fName := FolderInfo.FullName;

  fSelfNode := MainForm.FolderTree.Items.AddChildObject(ParentNode,fName,FolderInfo);
  fSelfNode.MakeVisible;
  
  if ParentNode <> nil then
  begin
    FolderInfo.ParentFolderInfo := @TFolderInfo(ParentNode.Data);
  end;
end;

procedure TSearchThread.Terminated(Sender: TObject);
begin
  Synchronize(UpdateThreadsRunning);
end;

procedure TSearchThread.UpdateThreadsRunning;
begin
  MainForm.ThreadsRunning := -1 + MainForm.ThreadsRunning;
end;

end.
