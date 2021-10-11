unit UAbout;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Messages, shellapi;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProductName: TLabel;
    OKButton: TButton;
    lblURL: TLabel;
    Label3: TLabel;
    StaticText1: TStaticText;
    Label1: TLabel;
    lblHotURL: TLabel;
    ProgramIcon: TImage;
    procedure lblURLClick(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure lblHotURLClick(Sender: TObject);
  protected
    procedure WndProc(var Msg : TMessage); override;
  public
  end;

var
  AboutBox: TAboutBox;

implementation
{$R *.dfm}

procedure ChangeColor(Sender : TObject; Msg : Integer);
begin
 if Sender is TLabel Then
 begin
   if (Msg = CM_MOUSELEAVE) then
   begin
     (Sender As TLabel).Font.Color:=clWindowText;
     (Sender As TLabel).Font.Style:=(Sender As TLabel).Font.Style - [fsUnderline] ;
   end;
   if (Msg = CM_MOUSEENTER) then
   begin
     (Sender As TLabel).Font.Color:=clBlue;
     (Sender As TLabel).Font.Style:=(Sender As TLabel).Font.Style + [fsUnderline] ;
   end;
 end;
end;

procedure TAboutBox.WndProc(var Msg : TMessage);
begin
    if Msg.LParam = Longint(lblHotURL) then
       ChangeColor(lblHotURL, Msg.Msg);
    if Msg.LParam = Longint(lblURL) then
       ChangeColor(lblURL, Msg.Msg);

  inherited WndProc(Msg);
end;


procedure TAboutBox.lblURLClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open',PChar(lblURL.Caption),nil,nil,SW_SHOWNORMAL);
end;

procedure TAboutBox.StaticText1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open','mailto:delphi.guide@about.com?subject=About Delphi Programming: FolderSize',nil,nil,SW_SHOWNORMAL);
end;

procedure TAboutBox.lblHotURLClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open',PChar(lblHotURL.Caption),nil,nil,SW_SHOWNORMAL);
end;

end.

