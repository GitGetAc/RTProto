unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, RichMemo;

type

  { TForm1 }

  TForm1 = class(TForm)
    cboFont: TComboBox;
    cboFontSize: TComboBox;
    ImageList1: TImageList;
    FontLabel: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SizeLabel: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    RichMemo1: TRichMemo;
    ToolBar1: TToolBar;
    btnNew: TToolButton;
    btnOpen: TToolButton;
    btnSave: TToolButton;
    ToolButton1: TToolButton;
    btnBold: TToolButton;
    btnItalic: TToolButton;
    btnUnderline: TToolButton;
    ToolButton2: TToolButton;
    procedure btnBoldClick(Sender: TObject);
    procedure btnItalicClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnUnderlineClick(Sender: TObject);
    procedure cboFontSelect(Sender: TObject);
    procedure cboFontSizeSelect(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure RichMemo1Change(Sender: TObject);
    procedure PrepareToolbar();
    procedure RichMemo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  Form1: TForm1;
  Filename : String = 'Untitled';
  Filepath : String;
  Saved: Boolean;
  SelFontFormat: TFontParams;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnNewClick(Sender: TObject);
begin
  RichMemo1.Clear;
  Saved:= False;
  Filename := 'Untitled.rtf';
  Filepath := '';
  Caption :=Filename;
end;

procedure TForm1.btnBoldClick(Sender: TObject);
begin
   if (fsBold in SelFontFormat.Style = False) then
    SelFontFormat.Style:=SelFontFormat.Style + [fsBold]
  else
    SelFontFormat.Style:=SelFontFormat.Style - [fsBold];

  RichMemo1.SetTextAttributes(RichMemo1.SelStart, RichMemo1.SelLength, SelFontFormat);
end;

procedure TForm1.btnItalicClick(Sender: TObject);
begin
  if (fsItalic in SelFontFormat.Style = False) then
    SelFontFormat.Style:=SelFontFormat.Style + [fsItalic]
  else
    SelFontFormat.Style:=SelFontFormat.Style - [fsItalic];

  RichMemo1.SetTextAttributes(RichMemo1.SelStart, RichMemo1.SelLength, SelFontFormat);
end;

procedure TForm1.btnOpenClick(Sender: TObject);
var
  fs : TFileStream;
begin
   if OpenDialog1.Execute then begin
    fs := nil;
    try
      // Utf8ToAnsi is required for windows
      fs := TFileStream.Create(Utf8ToAnsi(OpenDialog1.FileName), fmOpenRead or fmShareDenyNone);
      RichMemo1.LoadRichText(fs);
      Saved := True; // since we opened a saved file
      Filename := ExtractFileName(OpenDialog1.FileName);
      Filepath := ExtractFilePath(OpenDialog1.FileName);
      Caption := Filename;
    except
    end;
    fs.Free;
  end;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
  fs : TFileStream;
begin
  if SaveDialog1.Execute then
   begin
   fs := nil;
    try
      fs := TFileStream.Create(Utf8ToAnsi(SaveDialog1.FileName), fmCreate);
      RichMemo1.SaveRichText(fs);
      Saved := True;
      Filename := ExtractFileName(SaveDialog1.FileName);
      Filepath := ExtractFilePath(SaveDialog1.FileName);
      Caption := Filename;
    except
    end;
    fs.Free;
   end;
end;

procedure TForm1.btnUnderlineClick(Sender: TObject);
begin
  if (fsUnderline in SelFontFormat.Style = False) then
    SelFontFormat.Style:=SelFontFormat.Style + [fsUnderline]
  else
    SelFontFormat.Style:=SelFontFormat.Style - [fsUnderline];

  RichMemo1.SetTextAttributes(RichMemo1.SelStart, RichMemo1.SelLength, SelFontFormat);
end;

procedure TForm1.cboFontSelect(Sender: TObject);
begin
  SelFontFormat.Name:=cboFont.Text;
  RichMemo1.SetTextAttributes(RichMemo1.SelStart, RichMemo1.SelLength, SelFontFormat);
  RichMemo1.SetFocus; // get focus to the rich memo
end;

procedure TForm1.cboFontSizeSelect(Sender: TObject);
begin
  SelFontFormat.Size:=StrToInt(cboFontSize.Text);
  RichMemo1.SetTextAttributes(RichMemo1.SelStart, RichMemo1.SelLength, SelFontFormat);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Response: Integer;
begin
    if not Saved then
    begin
    Response := MessageDlg('Save?', 'Do you wish to Save?', mtConfirmation, mbYesNoCancel, 0);

    if Response = mrYes then
     begin
      btnSaveClick(Sender); // we save it
      CanClose := True; // we let it close
     end
    else if Response = mrNo then
     begin
       CanClose := True; // we let it close (but not save)
     end
    else
     begin
       CanClose := False; // we don’t need to close
     end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  cboFont.Items.Assign(Screen.Fonts);
  cboFont.ItemIndex := 9; // Calibri style from the installed fonts from top to buttom (@ - V)
  btnNewClick(Sender);
end;

procedure TForm1.RichMemo1Change(Sender: TObject);
begin
  Saved := False;
end;

procedure TForm1.PrepareToolbar();
begin
  cboFont.Caption:=SelFontFormat.Name;
  cboFontSize.Caption:=inttostr(SelFontFormat.Size);

  if (fsBold in SelFontFormat.Style = true) then
    btnBold.Down:=True
  else
    btnBold.Down:=False;

  if (fsItalic in SelFontFormat.Style = true) then
    btnItalic.Down:=True
  else
    btnItalic.Down:=False;

  if (fsUnderline in SelFontFormat.Style = true) then
    btnUnderline.Down:=True
  else
    btnUnderline.Down:=False;
end;

procedure TForm1.RichMemo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  RichMemo1.GetTextAttributes(RichMemo1.SelStart, SelFontFormat);
  PrepareToolbar;
end;

end.

