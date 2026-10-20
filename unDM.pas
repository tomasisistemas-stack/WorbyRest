unit unDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, Vcl.Forms,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.ConsoleUI.Wait, FireDAC.Phys.IBBase, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.PG, FireDAC.Phys.PGDef;

type
  Tdm = class(TDataModule)
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    fdConnectTomasi: TFDConnection;
    FDVerificaCnpj: TFDQuery;
    FDVerificaCnpjnome: TStringField;
    FDVerificaCnpjcnpj: TStringField;
    FDVerificaCnpjemail: TStringField;
    FDVerificaCnpjbloqueado: TBooleanField;
    FDVerificaCnpjbancodados: TStringField;
    FDVerificaCnpjcodigo: TIntegerField;
    FDConn: TFDConnection;
    QCons: TFDQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function Login(usuario, senha: string): string;
    function ListaNFes: TDataSet;
    function ListaNFesCanc: TDataSet;
    function AcertoEstoque(CodigoProduto, Usuario: string; QtdAcerto: Real): boolean;
    function VerificaCNPJ(cnpj: string): string;
    function EnviarStatusCC(sXMLCC, sStatus, sId, sNFE_ID, sRetornoCC : string) : boolean;
    function ListaCC: TDataSet;
    function EnviarStatusErro(sStatus, sRetornoNfe, sId: string): boolean;
    function EnviarStatusCanc(sStatus, sId : string) : boolean;
    function EnviarStatus(sStatus, sLote, sRetornoNfe,
      sLoteRecebimento, sProtocoloAutorizacao, sNumNfe, sSerie, sChave,
      sId: string): boolean;
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

function TDM.Login(usuario, senha : string):string;
begin


  FDConn.Connected;
  qCons.Close;
  qCons.sql.clear;
  qCons.sql.text := 'SELECT  ' +
                        '  codigousuario, ' +
                        '  nomecompleto, ' +
                        '  login, ' +
                        '  senha, ' +
                        '  foto, ' +
                        '  nivel ' +
                        'FROM data.usuario ' +
                        'where ' +
                        '  login =  ' + quotedstr(usuario) +
                        ' and senha =  ' + quotedstr(senha);
   qCons.Open;

   if not qCons.IsEmpty then
     Result := 'OK'
   else
     Result := 'Usuário e Senha inválidos!';
end;

function TDM.VerificaCNPJ(cnpj: string): string;
begin
  fdConnectTomasi.Connected := false;
  fdConnectTomasi.Params.Values['database'] := 'TomasiSys';
  fdConnectTomasi.Params.Values['user_name'] := 'postgres';
  fdConnectTomasi.Params.Values['password'] := '123';
  fdConnectTomasi.Params.Values['port'] := '5432';

  fdConnectTomasi.Params.Values['server'] := 'localhost';
//  fdConnectTomasi.Params.Values['server'] := '216.245.209.43';
  fdConnectTomasi.Connected := true;

  FDVerificaCnpj.Close();
  FDVerificaCnpj.sql.clear;
  FDVerificaCnpj.sql.Text := 'SELECT       ' + '  nome,      ' + '  cnpj,      ' + '  email,     ' + '  bloqueado, ' + '  bancodados,' + '  codigo     ' + 'FROM data.clientes ' + 'WHERE ' +
    '  cnpj = ' + quotedstr(cnpj);

  FDVerificaCnpj.Open;
  if FDVerificaCnpj.isempty then
    result := 'CNPJ Não Cadastrado!'
  else
  begin
    if FDVerificaCnpjbloqueado.Value = true then
      result := 'Licença Expirada. Entre em Contato com Tomasi Sistemas!'
    else
    begin
      FDConn.Connected := false;
      FDConn.Params.Database := FDVerificaCnpjbancodados.AsString;
      FDConn.Params.Values['user_name'] := 'postgres';
      FDConn.Params.Values['password'] := '123';
      FDConn.Params.Values['port'] := '5432';

      FDConn.Params.Values['server'] := 'localhost';
 //     FDConnection.Params.Values['server'] := '216.245.209.43';

      result := 'OK';
    end;
  end;
end;

function TDM.ListaNFes:TDataSet;
begin
  FDConn.Connected;
  qCons.Close;
  qCons.sql.clear;
  qCons.sql.text := 'select n.id, n.chave, n.numnfe, n.xmlnfe '+
                        'from data.nfe n '+
                        'where  '+
                        '  n.status = ''P'' '+
                        'order by n.id';
   qCons.Open;
   Result := qCons;
end;

function TDM.ListaNFesCanc:TDataSet;
begin
  FDConn.Connected;
  qCons.Close;
  qCons.sql.clear;
  qCons.sql.text := 'select n.id, n.chave, n.numnfe, n.xmlnfe, n.protocoloautorizacao '+
                        'from data.nfe n '+
                        'where n.tipo = ''S'' '+
                        '  and n.status = ''X'' '+
                        'order by n.id';
   qCons.Open;
   Result := qCons;
end;

function TDM.ListaCC:TDataSet;
begin
  FDConn.Connected;
  qCons.Close;
  qCons.sql.clear;
  qCons.sql.text := 'select '+
                    '  cc.id, '+
                    '  cc.nfe_id, '+
                    '  cc.cartacorrecao, '+
                    '  cc.xml, '+
                    '  nf.chave, '+
                    '  e.cnpj as cnpj_emit '+
                    'from '+
                    '  data.carta_correcao cc '+
                    'inner join data.nfe nf on nf.id = cc.nfe_id '+
                    'inner join data.empresa e on e.cod_empresa = nf.codfilial '+
                    'where cc.status = ''P''';
  qCons.Open;
  Result := qCons;
end;

function Tdm.AcertoEstoque(CodigoProduto, Usuario: string;
  QtdAcerto: Real): boolean;
begin

end;

function TDM.EnviarStatus(sStatus, sLote, sRetornoNfe, sLoteRecebimento, sProtocoloAutorizacao, sNumNfe, sSerie, sChave, sId : string) : boolean;
var
    sResult : string;
    sXMLNFE : TStringList;
begin
    try
      FDConn.Connected;

      FDConn.StartTransaction;

      sXMLNFE := TStringList.Create;
      sXMLNFE.LoadFromFile(ExtractFilePath(Application.ExeName)+'nfes\'+sChave+'-nfe.xml');

      qCons.sql.text := 'update data.nfe '+
                        'set '+
                        '  xmlnfe = '''+sXMLNFE.Text+''', '+
                        '  status = :pstatus,'+
                        '  lote   = :plote, '+
                        '  retornonfe =:pretornonfe,'+
                        '  loterecebimento =:ploterecebimento,'+
                        '  protocoloautorizacao =:pprotocoloautorizacao,'+
                        '  numnfe =:pnumnfe, '+
                        '  serie = :pserie,'+
                        '  chave = :pchave'+
                        ' where '+
                        '  id = :pid';

     /// qCons.ParambyName('pxmlnfe').LoadFromStream(ssXMLNFe, ftblob);
      qCons.ParambyName('pstatus').asstring := trim(sStatus);
      qCons.ParambyName('plote').asstring := sLote;
      qCons.ParambyName('pretornonfe').asstring := sRetornoNfe;
      qCons.ParambyName('ploterecebimento').asstring := sLoteRecebimento;
      qCons.ParambyName('pprotocoloautorizacao').asstring := sProtocoloAutorizacao;
      qCons.ParambyName('pnumnfe').AsInteger := strtoint(sNumNfe);
      qCons.ParambyName('pserie').asstring := sSerie;
      qCons.ParambyName('pchave').asString := sChave;
      QCons.ParambyName('pid').AsInteger := strtoint(sId);
      qCons.ExecSQL;


      qCons.sql.text := 'UPDATE data.pedido set status = ''Faturado''' +
                        ' WHERE nfe_id = ' + sID;
      qCons.ExecSQL;


      FDConn.Commit;

      Result := true;
    except
       on E: Exception do
      begin
        sResult := E.Message;
        FDConn.Rollback;
        Result := false;
      end;
    end;
 end;

function TDM.EnviarStatusCanc(sStatus, sId : string) : boolean;
var
    sResult, sCodEmpresa, sNumNfe : string;
begin
    try
      FDConn.Connected;

      FDConn.StartTransaction;

      QCons.sql.text := 'select codfilial, numnfe from data.nfe where id = '+sId;
      QCons.open;
      sCodEmpresa := QCons.FieldByName('codfilial').AsString;
      sNumNfe     := QCons.FieldByName('numnfe').AsString;
      QCons.close;


      qCons.sql.text := 'update data.nfe '+
                        'set '+
                        '  status = :pstatus'+
                        ' where '+
                        '  id = :pid';

      qCons.ParambyName('pstatus').asstring := trim(sStatus);
      QCons.ParambyName('pid').AsInteger := strtoint(sId);
      qCons.ExecSQL;

      if sStatus = 'C' then
      begin
        QCons.sql.text := 'delete from data.contas where cod_empresa = ' +
          sCodEmpresa + ' and nota_referenciada=' + sNumNfe;
        QCons.ExecSQL;

        QCons.sql.text := 'UPDATE data.pedido set status = ''À Faturar''' +
          ', nfe_id = null WHERE nfe_id = ' + sId;
        QCons.ExecSQL;
      end;


      FDConn.Commit;

      Result := true;
    except
       on E: Exception do
      begin
        sResult := E.Message;
        FDConn.Rollback;
        Result := false;
      end;
    end;
 end;


function TDM.EnviarStatusErro(sStatus, sRetornoNfe, sId : string) : boolean;
var
  sResult, sCodEmpresa, sNumNfe : string;
begin
    try
      FDConn.Connected;

      FDConn.StartTransaction;

      QCons.sql.text := 'select codfilial, numnfe from data.nfe where id = '+sId;
      QCons.open;
      sCodEmpresa := QCons.FieldByName('codfilial').AsString;
      sNumNfe     := QCons.FieldByName('numnfe').AsString;
      QCons.close;


      QCons.sql.text := 'update data.nfe ' +
                        'set ' +
                        '  status = :pstatus,' +
                        '  retornonfe =:pretornonfe' +
                        ' where ' +
                        '  id = :pid';

      QCons.ParambyName('pstatus').AsString := trim(sStatus);
      QCons.ParambyName('pretornonfe').AsString := sRetornoNfe;
      QCons.ParambyName('pid').AsInteger := strtoint(sId);
      QCons.ExecSQL;

      QCons.sql.text := 'delete from data.contas where cod_empresa = ' + sCodEmpresa + ' and nota_referenciada=' + sNumNfe;
      QCons.ExecSQL;

      qCons.SQL.Text := 'UPDATE data.pedido set status = ''À Faturar''' +
                        ', nfe_id = null WHERE nfe_id = ' + sID;
      qCons.ExecSQL;

      FDConn.Commit;

      Result := true;
    except
       on E: Exception do
      begin
        sResult := E.Message;
        FDConn.Rollback;
        Result := false;
      end;
    end;
  end;

function TDM.EnviarStatusCC(sXMLCC, sStatus, sId, sNFE_ID, sRetornoCC : string) : boolean;
var
  sResult, sCodEmpresa, sNumNfe : string;
begin
    try
      FDConn.Connected;

      FDConn.StartTransaction;

      QCons.sql.text := 'update data.carta_correcao ' +
                        'set ' +
                        '  xml = '''+sXMLCC+''', '+

                        '  status = :pstatus,' +
                        '  retorno_cc = :pretorno_cc '+
                        ' where ' +
                        '  id = :pid and'+
                        ' nfe_id = :pnfe_id';

      QCons.ParambyName('pstatus').AsString := trim(sStatus);
      QCons.ParambyName('pid').AsInteger := strtoint(sId);
      QCons.ParambyName('pretorno_cc').AsString := trim(sRetornoCC);
      QCons.ParambyName('pnfe_id').AsInteger := strtoint(sNFE_ID);
      QCons.ExecSQL;

      Result := true;
    except
       on E: Exception do
      begin
        sResult := E.Message;
        FDConn.Rollback;
        Result := false;
      end;
    end;
  end;

end.
