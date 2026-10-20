program WorbyRest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  //Horse.Paginate,
  Horse.Jhonson,
  //Horse.BasicAuthentication,
  DataSet.Serialize,
  Horse.Upload,
  System.SysUtils,
  Vcl.Forms,
  unDM in 'unDM.pas' {dm: TDataModule};

var App : THorse;

begin
  App := THorse.create(9000);
  App.Use(Upload);
  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('OK');
    end);

  App.Get('/login',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMLogin : TDM;
    begin
      DMLogin := TDM.Create(nil);

      Res.Send(DMLogin.Login(req.query['user'], req.query['password']));
      Dmlogin.Free;
    end);

  App.Get('/verificacnpj',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMVerificaCNPJ : TDM;
    begin
      DMVerificaCNPJ := TDM.Create(nil);

      Res.Send(DMVerificaCNPJ.VerificaCNPJ(req.query['cnpj']));
      DMVerificaCNPJ.Free;
    end);

  App.Get('/listanfes',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMListaNfes: TDM;
    begin
      DMListaNfes := TDM.Create(nil);

      Res.Send(DMListaNfes.ListaNFes.ToJSONArrayString());

      DMListaNfes.Free;
    end);

  App.Get('/listanfes_cancelar',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMListaNfesCanc: TDM;
    begin
      DMListaNfesCanc := TDM.Create(nil);

      Res.Send(DMListaNfesCanc.ListaNFesCanc.ToJSONArrayString());

      DMListaNfesCanc.Free;
    end);

  App.Get('/listacartacorrecao',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMListaCC: TDM;
    begin
      DMListaCC := TDM.Create(nil);

      Res.Send(DMListaCC.ListaCC.ToJSONArrayString());

      DMListaCC.Free;
    end);

  App.Post('/upload',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LUploadConfig: TUploadConfig;
      sPath : string;
    begin
      sPath := ExtractFilePath(Application.ExeName)+'nfes\';
      LUploadConfig := TUploadConfig.Create(sPath);
      LUploadConfig.ForceDir := True;
      LUploadConfig.OverrideFiles := True;

      //Optional: Callback for each file received
      LUploadConfig.UploadFileCallBack :=
        procedure(Sender: TObject; AFile: TUploadFileInfo)
        begin
          Writeln('');
          Writeln('Upload file: ' + AFile.filename + ' ' + AFile.size.ToString);
        end;

      Res.Send<TUploadConfig>(LUploadConfig);
    end);

  App.Get('/enviastatus',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMEnviarStatus : TDM;
    begin
      DMEnviarStatus := TDM.Create(nil);

      if DMEnviarStatus.EnviarStatus(req.query['Status'],
                                     req.query['Lote'],
                                     req.query['RetornoNfe'],
                                     req.query['LoteRecebimento'],
                                     req.query['ProtocoloAutorizacao'],
                                     req.query['NumNfe'],
                                     req.query['Serie'],
                                     req.query['Chave'],
                                     req.query['Id']
                                    ) then
        Res.Send('OK')
      else
        Res.Send('Erro ao efetuar o Envio de Status!!!');

      DMEnviarStatus.Free;
    end);

  App.Get('/enviastatuscancelamento',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMEnviarStatusCanc : TDM;
    begin
      DMEnviarStatusCanc := TDM.Create(nil);

      if DMEnviarStatusCanc.EnviarStatusCanc(req.query['Status'],
                                     req.query['Id']) then
        Res.Send('OK')
      else
        Res.Send('Erro ao efetuar o Envio de Status!!!');

      DMEnviarStatusCanc.Free;
    end);

  App.Get('/enviastatuserro',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMEnviarStatus : TDM;
    begin
      DMEnviarStatus := TDM.Create(nil);

      if DMEnviarStatus.EnviarStatusErro(
                                     req.query['Status'],
                                     req.query['RetornoNfe'],
                                     req.query['Id']
                                    ) then
        Res.Send('OK')
      else
        Res.Send('Erro ao efetuar o Envio de Status!!!');

      DMEnviarStatus.Free;
    end);

  App.Get('/enviastatuscc',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      DMEnviarStatus : TDM;
    begin
      DMEnviarStatus := TDM.Create(nil);

      if DMEnviarStatus.EnviarStatusCC(
                                     req.query['XMLCC'],
                                     req.query['Status'],
                                     req.query['Id'],
                                     req.query['nfe_id'],
                                     req.query['retorno_cc']
                                    ) then
        Res.Send('OK')
      else
        Res.Send('Erro ao efetuar o Envio de Status!!!');

      DMEnviarStatus.Free;
    end);

  App.Start;
end.
