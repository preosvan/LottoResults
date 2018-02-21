unit LottoModelUnit;

interface

uses
  System.Generics.Collections;

type
  TCustomItem = class
  private
    FId: Integer;
    FName: string;
  public
    constructor Create(AId: Integer; AName: string); overload;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
  end;

  TNumberType = (ntNone, ntMain, ntSupplementary);

  TNumber = class(TCustomItem)
  private
    FNumberType: TNumberType;
    FNumberValue: Integer;
  public
    //Number -> Id;
    constructor Create(AId: Integer; ANumberType: TNumberType; ANumberValue: Integer); overload;
    property NumberType: TNumberType read FNumberType write FNumberType;
    property NumberValue: Integer read FNumberValue write FNumberValue;
  end;

  TCustomList<T: class> = class(TObjectList<T>)
  private
    FOwner: TCustomItem;
  public
    constructor Create(AOwner: TCustomItem);
    destructor Destroy; override;
    property Owner: TCustomItem read FOwner;
  end;

  TNumberList = TCustomList<TNumber>;

  TDraw = class(TCustomItem)
  private
    FDate: TDateTime;
    FNumberList: TNumberList;
  public
    //DrawValue -> Name
    constructor Create(AId: Integer; AName: string; ADate: TDateTime); overload;
    destructor Destroy; override;
    property Date: TDateTime read FDate write FDate;
    property NumberList: TNumberList read FNumberList write FNumberList;
  end;

  TDrawList = TCustomList<TDraw>;

  TLottery = class(TCustomItem)
  private
    FDrawList: TDrawList;
  public
    constructor Create(AId: Integer; AName: string); overload;
    destructor Destroy; override;
    property DrawList: TDrawList read FDrawList write FDrawList;
  end;

  TLotteryList = class;

  TDataController = class
  private
    FLotteryList: TLotteryList;
  public
    procedure Load; virtual; abstract;
    procedure Save; virtual; abstract;
    property LotteryList: TLotteryList read FLotteryList write FLotteryList;
  end;

  TLotteryList = class(TCustomList<TLottery>)
  private
    FDataController: TDataController;
  public
    procedure InitDataController(ADataController: TDataController);
    procedure Load;
    procedure Save;
    property DataController: TDataController read FDataController;
  end;

implementation

uses
  System.SysUtils;

{ TCustomItem }

constructor TCustomItem.Create(AId: Integer; AName: string);
begin
  FId := AId;
  FName := AName;
end;

{ TDraw }

constructor TDraw.Create(AId: Integer; AName: string; ADate: TDateTime);
begin
  inherited Create(AId, AName);
  FDate := ADate;
  FNumberList := TNumberList.Create(Self);
end;

destructor TDraw.Destroy;
begin
  if Assigned(FNumberList) then
    FNumberList.Free;
  inherited;
end;

{ TLottery }

constructor TLottery.Create(AId: Integer; AName: string);
begin
  inherited;
  FDrawList := TDrawList.Create(Self);
end;

destructor TLottery.Destroy;
begin
  if Assigned(FDrawList) then
    FDrawList.Free;
  inherited;
end;

{ TNumber }

constructor TNumber.Create(AId: Integer; ANumberType: TNumberType;
  ANumberValue: Integer);
begin
  inherited Create(AId, '');
  FNumberType := ANumberType;
  FNumberValue := ANumberValue;
end;

{ TCustomList<T> }

constructor TCustomList<T>.Create(AOwner: TCustomItem);
begin
  FOwner := AOwner;
  inherited Create;
end;

destructor TCustomList<T>.Destroy;
begin
  Clear;
  inherited;
end;

{ TLotteryList }

procedure TLotteryList.InitDataController(ADataController: TDataController);
begin
  FDataController := ADataController;
  FDataController.LotteryList := Self;
end;

{ TTestDataController }

procedure TLotteryList.Load;
begin
  if Assigned(DataController) then
    DataController.Load;
end;

procedure TLotteryList.Save;
begin
  if Assigned(DataController) then
    DataController.Save;
end;

end.
