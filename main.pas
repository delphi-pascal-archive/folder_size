unit main;

interface

uses
  FileCtrl,  shellapi,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Buttons, TeEngine, Series,
  TeeProcs, Chart;

type
  TMainForm = class(TForm)
    pnlTop: TPanel;
    pnlFI: TPanel;
    FolderTree: TTreeView;
    ledRootFolder: TLabeledEdit;
    RefreshButton: TBitBtn;
    Chart: TChart;
    lblSelectedFolder: TStaticText;
    pnlInfo: TPanel;
    ledSizeBytes: TLabeledEdit;
    ledFiles: TLabeledEdit;
    ledFolders: TLabeledEdit;
    Splitter1: TSplitter;
    ExitButton: TSpeedButton;
    AboutButton: TSpeedButton;
    pnlTree: TPanel;
    pnlTreeTop: TPanel;
    Label1: TLabel;
    sbtnCollapse: TSpeedButton;
    sbtnExpand: TSpeedButton;
    RunExplorerButton: TSpeedButton;
    procedure RefreshButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FolderTreeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure AboutButtonClick(Sender: TObject);
    procedure sbtnCollapseClick(Sender: TObject);
    procedure sbtnExpandClick(Sender: TObject);
    procedure RunExplorerButtonClick(Sender: TObject);
  private
    fRootFolder: TFileName;
    fThreadsRunning: integer;
    procedure SetRootFolder(const Value: TFileName);

    procedure ClearFreeTree;
    procedure RefreshChart(const ParentNode : TTreeNode);
    procedure SetThreadsRunning(const Value: integer);
  public
    property RootFolder : TFileName read fRootFolder write SetRootFolder;
    property ThreadsRunning : integer read fThreadsRunning write SetThreadsRunning;
  end;

var
  MainForm: TMainForm;

implementation
{$R *.dfm}
uses searchthread, folderinfo, uabout;

function BytesFriendly(const Bytes : integer):string;
begin
  if Bytes < 1024 then
  begin
    Result := Format('%s', [IntToStr(Bytes)]) + 'B';
    Exit;
  end;
  if (Bytes >= 1024) and (Bytes < (1024 * 1024)) then
  begin
    Result :=  Format('%n', [Bytes / 1024]) + ' KB';
    Exit;
  end;
  if (Bytes >= (1024*1024)) and (Bytes < (1024 * 1024 * 1024)) then
  begin
    Result :=  Format('%n', [Bytes / (1024 * 1024)]) + ' MB';
    Exit;
  end;
  if Bytes >= (1024*1024*1024)  then
  begin
    Result :=  Format('%n', [Bytes / (1024 * 1024 * 1024)]) + ' GB';
    Exit;
  end;
end;


{ TMainForm }
procedure TMainForm.SetRootFolder(const Value: TFileName);
begin
  fRootFolder := Value;
  ledRootFolder.Text := Value;
end;

procedure TMainForm.RefreshButtonClick(Sender: TObject);
var
  newRootFolder : string;
begin
  if SelectDirectory('Specify the "root" folder to calculate its size and usage','.',newRootFolder) then
  begin
    RootFolder := newRootFolder;
    ClearFreeTree;
    RefreshChart(nil);
    //start
    Screen.Cursor := crHourglass;
    FolderTree.Items.BeginUpdate;
    TSearchThread.Create(RootFolder,nil);
  end;
end;

procedure TMainForm.ClearFreeTree;
var
  i : integer;
  tn : TTreeNode;
begin
  for i := 0 to -1 + FolderTree.Items.Count do
  begin
    tn := FolderTree.Items[i];
    TFolderInfo(tn.Data).Free;
  end;

  FolderTree.Items.Clear;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  //make sure we free memory!
  ClearFreeTree;
  Screen.Cursor := crDefault;
end;

procedure TMainForm.FolderTreeClick(Sender: TObject);
var
  tn : TTreeNode;
  fi : TFolderInfo;
begin
  tn := FolderTree.Selected;
  RunExplorerButton.Enabled := tn <> nil;
  if tn = nil then Exit;

  fi := TFolderInfo(tn.Data);

  lblSelectedFolder.Caption := fi.FullName;
  ledFolders.Text:= Format('%d',[fi.FolderCount]);
  ledFiles.Text := Format('%d',[fi.FileCount]);
  ledSizeBytes.Text := Format('%s (%d bytes)',[BytesFriendly(fi.Size),fi.Size]);

  RefreshChart(tn);
end;

procedure TMainForm.RefreshChart(const ParentNode: TTreeNode);
var
  tn : TTreeNode;
  fi : TFolderInfo;
  i:integer;
begin
  if Assigned(ParentNode) AND (ParentNode.Count > 0) then
  begin
    Chart.Title.Visible := false;
    Chart.Series[0].Clear;
    for i := 0 to ParentNode.Count - 1 do
    begin
      tn := ParentNode.Item[i];
      fi := TFolderInfo(tn.Data);
      Chart.Series[0].Add(fi.Size,Format('%s [%s]',[fi.Name, BytesFriendly(fi.Size)]));
    end;
  end
  else
  begin
    Chart.Title.Text.Text := 'The selected folder has NO subfolders!';
    Chart.Series[0].Clear;
    Chart.Title.Visible := true;
  end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  PieSeries : TPieSeries;
begin
  Chart.Title.Text.Add('Disk usage by sub-folder...');
  PieSeries := TPieSeries.Create(Chart);
  Chart.AddSeries(PieSeries);
  Chart.Legend.Alignment := laTop;
  Chart.Legend.TextStyle := ltsLeftPercent;

  RootFolder := GetCurrentDir;
  fThreadsRunning := 0;
  RunExplorerButton.Enabled := false;
end;


procedure TMainForm.SetThreadsRunning(const Value: integer);
begin
  fThreadsRunning := Value;

//  lblSelectedFolder.Caption := Format('%s %d',['Threads running: ',value]);

  if Value = 0 then
  begin
    lblSelectedFolder.Caption := 'Select a folder from the tree...';
    FolderTree.FullCollapse;
    FolderTree.Items[0].Expanded := true;
    Screen.Cursor := crDefault;
    FolderTree.Items.EndUpdate;
  end;
end;

procedure TMainForm.ExitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.AboutButtonClick(Sender: TObject);
begin
  with TAboutBox.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMainForm.sbtnCollapseClick(Sender: TObject);
begin
  FolderTree.FullCollapse;
  if FolderTree.Items.Count > 0 then FolderTree.Items[0].Expanded := true;
end;

procedure TMainForm.sbtnExpandClick(Sender: TObject);
begin
  FolderTree.FullExpand;
  if Assigned(FolderTree.Selected) then FolderTree.Selected.MakeVisible;
end;

procedure TMainForm.RunExplorerButtonClick(Sender: TObject);
var
  tn : TTreeNode;
begin
  tn := FolderTree.Selected;

  if Assigned(tn) then
  begin
    ShellExecute(Handle, 'open',PChar(TFolderInfo(tn.Data).FullName),nil,nil,SW_SHOWNORMAL);
  end;
end;

end.
