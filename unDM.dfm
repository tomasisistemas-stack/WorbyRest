object dm: Tdm
  OldCreateOrder = False
  Height = 410
  Width = 766
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    VendorLib = 'libpq.dll'
    Left = 128
    Top = 96
  end
  object fdConnectTomasi: TFDConnection
    Params.Strings = (
      'DriverID=PG'
      'Password=123'
      'User_Name=postgres'
      'Server=localhost'
      'Database=TomasiSistemas')
    LoginPrompt = False
    Left = 128
    Top = 24
  end
  object FDVerificaCnpj: TFDQuery
    Connection = fdConnectTomasi
    SQL.Strings = (
      'SELECT nome, cnpj, email, bloqueado, bancodados, codigo'
      #9'FROM data.clientes')
    Left = 232
    Top = 16
    object FDVerificaCnpjnome: TStringField
      FieldName = 'nome'
      Origin = 'nome'
      Size = 200
    end
    object FDVerificaCnpjcnpj: TStringField
      FieldName = 'cnpj'
      Origin = 'cnpj'
    end
    object FDVerificaCnpjemail: TStringField
      FieldName = 'email'
      Origin = 'email'
      Size = 100
    end
    object FDVerificaCnpjbloqueado: TBooleanField
      FieldName = 'bloqueado'
      Origin = 'bloqueado'
    end
    object FDVerificaCnpjbancodados: TStringField
      FieldName = 'bancodados'
      Origin = 'bancodados'
      Size = 50
    end
    object FDVerificaCnpjcodigo: TIntegerField
      FieldName = 'codigo'
      Origin = 'codigo'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
  end
  object FDConn: TFDConnection
    Params.Strings = (
      'Password=123'
      'User_Name=postgres'
      'Server=localhost'
      'Database=FilhoCriador'
      'DriverID=PG')
    LoginPrompt = False
    Left = 248
    Top = 88
  end
  object QCons: TFDQuery
    Connection = FDConn
    SQL.Strings = (
      'SELECT nome, cnpj, email, bloqueado, bancodados, codigo'
      #9'FROM data.clientes')
    Left = 104
    Top = 176
  end
end
