unit FormEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterJava, SynExportHTML, SynEdit,
  SynHighlighterAny, SynHighlighterMulti, SynHighlighterPas, SynHighlighterCpp,
  SynHighlighterJScript, SynHighlighterPerl, SynHighlighterHTML,
  SynHighlighterXML, SynHighlighterLFM, SynHighlighterDiff,
  synhighlighterunixshellscript, SynHighlighterCss, SynHighlighterPHP,
  SynHighlighterTeX, SynHighlighterSQL, SynHighlighterPython, SynHighlighterVB,
  SynHighlighterBat, SynHighlighterIni, SynHighlighterPo, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ActnList, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    acCopyHtml: TAction;
    acOpen: TAction;
    acCopyText: TAction;
    ActionList1: TActionList;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    pmSchemas: TPopupMenu;
    PopupMenu1: TPopupMenu;
    SynBatSyn1: TSynBatSyn;
    SynCppSyn1: TSynCppSyn;
    SynCssSyn1: TSynCssSyn;
    SynEdit1: TSynEdit;
    SynExporterHTML1: TSynExporterHTML;
    SynFreePascalSyn1: TSynFreePascalSyn;
    SynHTMLSyn1: TSynHTMLSyn;
    SynIniSyn1: TSynIniSyn;
    SynJavaSyn1: TSynJavaSyn;
    SynJScriptSyn1: TSynJScriptSyn;
    SynLFMSyn1: TSynLFMSyn;
    SynMultiSyn1: TSynMultiSyn;
    SynPasSyn1: TSynPasSyn;
    SynPerlSyn1: TSynPerlSyn;
    SynPHPSyn1: TSynPHPSyn;
    SynPoSyn1: TSynPoSyn;
    SynPythonSyn1: TSynPythonSyn;
    SynSQLSyn1: TSynSQLSyn;
    SynTeXSyn1: TSynTeXSyn;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    SynVBSyn1: TSynVBSyn;
    SynXMLSyn1: TSynXMLSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure acCopyTextExecute(Sender: TObject);
    procedure acOpenExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure itemSchemaClick(Sender: TObject);
    procedure acCopyHtmlExecute(Sender: TObject);
    procedure acExportExecute(Sender: TObject);
    procedure pmSchemasPopup(Sender: TObject);
  private
    procedure ChangeHighlighter(const index: integer);
    procedure HtmlToClipboard(exportAsText: boolean);
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

uses dmMain;


{$R *.lfm}

{ TForm1 }

procedure TForm1.HtmlToClipboard(exportAsText: boolean);
var
  Lines: TStrings;

begin
  Self.SynExporterHTML1.ExportAsText := exportAsText;
  Self.SynExporterHTML1.CreateHTMLFragment := exportAsText;
  if (SynEdit1.SelAvail) then
  begin
    Lines := TStringList.Create;
    Lines.Text := SynEdit1.SelText;
  end
  else
  begin
    Lines := SynEdit1.Lines;
  end;
  Self.SynExporterHTML1.ExportAll(Lines);
  Self.SynExporterHTML1.CopyToClipboard;

  if (exportAsText) then
  begin
    ToolButton1.Action := acCopyText;
  end
  else
  begin
    ToolButton1.Action := acCopyHtml;
  end;
end;


procedure TForm1.acExportExecute(Sender: TObject);
begin
  Self.SynExporterHTML1.ExportAsText := True;
  Self.SynExporterHTML1.ExportAll(SynEdit1.Lines);
  Self.SynExporterHTML1.SaveToFile('prueba.html');
end;



procedure TForm1.pmSchemasPopup(Sender: TObject);
var
  i: integer;
  item: TMenuItem;
begin
  pmSchemas.Items.Clear;
  for i := 0 to SynMultiSyn1.Schemes.Count - 1 do
  begin
    item := TMenuItem.Create(Self);
    item.Caption := SynMultiSyn1.Schemes.Items[i].SchemeName;
    item.Checked := ToolButton2.ImageIndex = i;
    if (not item.Checked) then
    begin
      item.ImageIndex := i;
    end;
    item.OnClick := @itemSchemaClick;
    pmSchemas.Items.Add(item);
  end;
end;

procedure TForm1.ChangeHighlighter(const index: integer);
begin
  ToolButton2.ImageIndex := index;
  ToolButton2.Caption := SynMultiSyn1.Schemes.Items[index].SchemeName;
  SynMultiSyn1.DefaultHighlighter :=
    SynMultiSyn1.Schemes.Items[index].Highlighter;
end;

procedure TForm1.itemSchemaClick(Sender: TObject);
var
  item: TMenuItem;
begin
  item := Sender as TMenuItem;
  if (item.ImageIndex >= 0) then
  begin
    ChangeHighlighter(item.ImageIndex);
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  Self.SynEdit1.Highlighter := nil;
  CanClose := True;
end;

procedure TForm1.acCopyTextExecute(Sender: TObject);
begin
  HtmlToClipboard(True);
end;

procedure TForm1.acOpenExecute(Sender: TObject);
var
  i: integer;
  od: TOpenDialog;
  filter: string;
begin
  od := DataModule1.OpenDialog1;
  filter := '';
  for i := 0 to SynMultiSyn1.Schemes.Count - 1 do
  begin
    if (filter <> '') then
    begin
      filter := filter + '|';
    end;
    filter := filter + Self.SynMultiSyn1.Schemes.Items[i].Highlighter.DefaultFilter;
  end;
  od.Filter := filter;
  od.FilterIndex := ToolButton2.ImageIndex + 1;
  if (od.Execute) then
  begin
    SynEdit1.Lines.LoadFromFile(od.FileName);
    ChangeHighlighter(od.FilterIndex - 1);
  end;
end;


procedure TForm1.acCopyHtmlExecute(Sender: TObject);
begin
  HtmlToClipboard(False);
end;

end.
