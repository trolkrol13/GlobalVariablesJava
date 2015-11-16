unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan;

type
  TMainForm = class(TForm)
    sourceTextMemo: TMemo;
    globalVarsMemo: TMemo;
    countMetricsBtn: TButton;
    rightPnl: TPanel;
    lbl1: TLabel;
    loadFileBtn: TButton;
    fileOpenDlg: TOpenDialog;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    modulesLbl: TLabel;
    variablesLbl: TLabel;
    aupLbl: TLabel;
    pupLbl: TLabel;
    rupLbl: TLabel;
    leftPnl: TPanel;
    lbl6: TLabel;
    lbl7: TLabel;
    globalVarsPnl: TPanel;
    srcPnl: TPanel;
    XPManifest1: TXPManifest;
    procedure countMetricsBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure loadFileBtnClick(Sender: TObject);
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  ClassStoreRec = record
    className: string;
    bracketsCounter: Integer;
  end;
  ClassStorageArray = array[0..20] of ClassStoreRec;

var
  MainForm: TMainForm;

const
  // Ключевые слова для поиска глобальных переменных
  globalVarConst = 'public static';
  // Ключевое слово класса
  classConst = ' class ';
  // Константа названия класса при его отсутствии (для сохранения)
  noClassConst = 'NO_CLASS';
  // На что заменяется строковые константы
  replaceStringConst = '%S';

implementation

{$R *.dfm}

// Подготовка текста для обработки
procedure PrepareText;
var
  i, strStart, strEnd, posComment: integer;
  multilineComment: Boolean;
  currString: string;
begin
  with MainForm do
  begin
    multilineComment := false;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      currString := sourceTextMemo.Lines[i];
      if (not multilineComment) then
      begin

        // Замена всех строковых констант
        while (Pos('"', currString) <> 0) do
        begin
          strStart := Pos('"', currString);
          strEnd := Pos('"', Copy(currString, strStart + 1, Length(currString) - strStart));
          if (strEnd <> 0) then
          begin
            Delete(currString, strStart, strEnd + 1);
            Insert(replaceStringConst, currString, strStart);
          end
          else
            Break;
        end;

        // Удаление однострочных комментариев
        posComment := Pos('//', currString);
        if (posComment <> 0) then
          Delete(currString, posComment, Length(currString) - posComment + 1);

        // Удаление многострочных комментариев
        posComment := Pos('/*', currString);
        if (posComment <> 0) then
        begin
          multilineComment := true;
          Delete(currString, posComment, Length(currString) - posComment + 1);
        end;
      end
      else
      begin
        posComment := Pos('*/', currString);
        if (posComment <> 0) then
        begin
          multilineComment := false;
          Delete(currString, 1, posComment + 1);
        end
        else
          currString := '';
      end;
      sourceTextMemo.Lines[i] := currString;
    end;
  end;
end;

// Замена всех табуляций в строке на пробелы
procedure ReplaceTabsInString(var str: string);
begin
  while (Pos(#9, str) <> 0) do
  begin
    str[Pos(#9, str)] := ' ';
  end;
end;

// Поиск глобальных переменных
procedure FindGlobalVariables(var list: TStringList);
  // "Обрезка" строки до имени переменной
  function CutStringToVarName(str: string):string;
  var
    j: Integer;
    tempVar: string;
  begin
    if (Pos('=', str) <> 0) then
    begin
      j := Pos('=', str);
      tempVar := Trim(Copy(str, 1, j-1));
    end
    else
    begin
      tempVar := str;
      Delete(tempVar, Pos(';', tempVar), 1);
      tempVar := Trim(tempVar);
    end;
    while (Pos(' ',tempVar) <> 0) do
        Delete(tempVar, 1, Pos(' ', tempVar));
    Result := tempVar;
  end;

  // "Нарезка" строки на переменные
  procedure ParseToVariables(str, className: string);
  begin
    if ((Pos(globalVarConst, str) <> 0) and (Pos('(', str) = 0)) then
    begin
      Delete(str, 1, Pos(globalVarConst, str) + Length(globalVarConst));
      while (Pos(',', str) <> 0) do
      begin
        list.Add( className +'.'+ CutStringToVarName( Copy(str, 1, Pos(',', str) - 1) ) );
        Delete(str, 1, Pos(',', str));
      end;
      list.Add(className +'.'+ CutStringToVarName(str));
    end;
  end;

var
  i, j, currClassCounter, tempInt: Integer;
  sourceString, tempString: string;
  currClass: ClassStorageArray;

begin
  with MainForm do
  begin
    currClassCounter := 0;
    currClass[currClassCounter].className := noClassConst;
    currClass[currClassCounter].bracketsCounter := 1000;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      sourceString := sourceTextMemo.Lines[i];

      // Замена табуляций пробелом
      ReplaceTabsInString(sourceString);

      // Добавление нового класса
      tempInt := Pos(classConst, ' ' + sourceString);
      if (tempInt <> 0) then
      begin
        tempString := sourceString;
        Delete(tempString, 1, tempInt + Length(classConst)-2);
        Trim(tempString);
        if (Pos(' ', tempString) = 0) then
          Insert(' ', tempString, Pos('{', tempString) - 1);
        tempString := tempString + ' ';
        Inc(currClassCounter);
        currClass[currClassCounter].className := Copy(tempString, 1, Pos(' ', tempString) - 1);
        currClass[currClassCounter].bracketsCounter := 0;
      end;

      // Обработка вложенности фигурных скобок и, соответственно, классов
      j := 1;
      while ((Pos('{', sourceString) <> 0) or (Pos('}',sourceString) <> 0)) do
      begin
        if (sourceString[j] = '{') then
        begin
          Inc(currClass[currClassCounter].bracketsCounter);
          sourceString[j] := ' ';
        end
        else
        if (sourceString[j] = '}') then
        begin
          Dec(currClass[currClassCounter].bracketsCounter);
          if (currClass[currClassCounter].bracketsCounter < 1) then
            Dec(currClassCounter);
          sourceString[j] := ' ';
        end;
        Inc(j);
      end;

      ParseToVariables(sourceString, currClass[currClassCounter].className);
    end;
  end;
end;

// Подсчёт количества модулей ("функций")
function CountModules:integer;

  // Проверка на наличие подстроки с учётом предыдущего / следующего символов
  function Check(substr, str: string):Boolean;
  const
    alph = ['a'..'z','A'..'Z','_'];
  var
    i: integer;
  begin
    Result := true;
    if (Pos(substr, str) <> 0) then
    begin
      i := Pos(substr, str);
      if (i > 1) then
        if (str[i-1] in alph) then
          Result := false;
      if (i < Length(str)) then
        if (str[i+1] in alph) then
          Result := false;
    end;
  end;

  // Проверка является ли данная строка началом модуля ("функции")
  function IsAModule(str: string):Boolean;
  var
    currStr: string;
  begin
    Result := false;
    currStr := Trim(str);
    if (Length(currStr) > 0) then
      if (currStr[Length(currStr)] = ')') or
        (
          (Pos(')', currStr) > 0) and (Pos('{', currStr) > 0) and
          (Pos('{', currStr) > Pos(')', currStr))
        )
      then
        if ((Check('if', currStr)) and (Check('for', currStr)) and
          (Check('while', currStr)) and (Check('switch', currStr)))
        then
          Result := true;
  end;
var
  i, moduleCount: integer;
begin
  with MainForm do
  begin
    moduleCount := 0;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      if (IsAModule(sourceTextMemo.Lines[i])) then
        Inc(moduleCount);
    end;
    Result := moduleCount;
  end;
end;

// Подсчёт использований глобальных переменных
function CountVarUsage(list:TStringList):integer;
var
  varUsageCounter, i, j: integer;
  currStr: string;
begin
  with MainForm do
  begin
    varUsageCounter := 0;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      currStr := sourceTextMemo.Lines[i];
      if (Pos('.', currStr) <> 0) then
      begin
        for j := 0 to list.Count - 1 do
        begin
          while (Pos(list[j], currStr) <> 0) do
          begin
            Inc(varUsageCounter);
            Delete(currStr, Pos(list[j], currStr), Length(list[j]));
          end;
        end;
      end;
    end;
    Result := varUsageCounter;
  end;
end;

// Главная подпрограмма расчёта метрик
procedure CountMetrics;
var
  globalVariablesList: TStringList;
  globalVarsCount, modulesCount, Aup, Pup, i: integer;
  Rup: Real;
begin
  Rup := 0;

  globalVariablesList := TStringList.Create;
  PrepareText;
  FindGlobalVariables(globalVariablesList);
  globalVarsCount := globalVariablesList.Count;
  modulesCount := CountModules;

  Aup := CountVarUsage(globalVariablesList);
  Pup := modulesCount * globalVarsCount;
  if (Pup <> 0) then
    Rup := Aup / Pup;

  with MainForm do
  begin
    for i := 0 to globalVariablesList.Count - 1 do
      globalVarsMemo.Lines.Add(globalVariablesList[i]);
    modulesLbl.Caption := IntToStr(modulesCount);
    variablesLbl.Caption := IntToStr(globalVarsCount);
    aupLbl.Caption := IntToStr(Aup);
    pupLbl.Caption := IntToStr(Pup);
    rupLbl.Caption := FloatToStrF(Rup, ffGeneral, 6, 4);
  end;
end;

procedure TMainForm.countMetricsBtnClick(Sender: TObject);
begin
  globalVarsMemo.Clear;
  CountMetrics;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  sourceTextMemo.Clear;
  globalVarsMemo.Clear;
end;

procedure TMainForm.loadFileBtnClick(Sender: TObject);
begin
  if (fileOpenDlg.Execute) then
    sourceTextMemo.Lines.LoadFromFile(fileOpenDlg.FileName);
end;

procedure TMainForm.MemoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^A then
  begin
    (Sender as TMemo).SelectAll;
    Key := #0;
  end;
end;

end.
