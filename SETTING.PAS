unit Setting;

interface

uses WinTypes, WinProcs, Classes, Forms, Controls, StdCtrls, Tabs,
  Buttons, ExtCtrls;

type
  TSettings = class(TForm)
    ButtonPanel: TPanel;
    TabSet: TTabSet;
    Notebook: TNotebook;
    OKBtn: TBitBtn;
    HelpBtn: TBitBtn;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Edit2: TEdit;
    CheckBox2: TCheckBox;
    Label5: TLabel;
    Edit3: TEdit;
    Bevel3: TBevel;
    GroupBox3: TGroupBox;
    ComboBox2: TComboBox;
    Bevel4: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    Edit4: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Edit5: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Edit6: TEdit;
    Label12: TLabel;
    CheckBox3: TCheckBox;
    Bevel5: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure TabSetClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Settings: TSettings;

implementation

{$R *.DFM}

procedure TSettings.FormCreate(Sender: TObject);
begin
  { make the number of Tabs = number of Pages,
    and have the same names }
  TabSet.Tabs := Notebook.Pages;
end;

procedure TSettings.TabSetClick(Sender: TObject);
begin
  { set visible Page to which Tab was clicked }
  Notebook.PageIndex := TabSet.TabIndex;
end;

end.
