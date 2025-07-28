page 50100 "GLV Interface List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GLV Interface";
    Caption = 'Interface List';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Guid"; Rec."Guid")
                {
                    ToolTip = 'Specifies the value of the Guid field.', Comment = '%';
                    Visible = false;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field(Direction; Rec.Direction)
                {
                    ToolTip = 'Specifies the value of the Direction field.', Comment = '%';
                }
                field(Json; Rec.Json)
                {
                    ToolTip = 'Specifies the value of the Json field.', Comment = '%';
                }
                field(Error; Rec.Error)
                {
                    ToolTip = 'Specifies the value of the Error field.', Comment = '%';
                }
                field("Created at"; Rec."Created at")
                {
                    ToolTip = 'Specifies the value of the Created at field.', Comment = '%';
                }
                field("Creted By"; Rec."Creted By")
                {
                    ToolTip = 'Specifies the value of the Created By field.', Comment = '%';
                }
                field(Processed; Rec.Processed)
                {
                    ToolTip = 'Specifies the value of the Processed field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Test)
            {
                Caption = 'Get Customer';
                ApplicationArea = all;
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    lInterface: Record "GLV Interface";
                    lJsonObject: JsonObject;
                    lJsonValue: JsonValue;
                    lOutStream: OutStream;
                    lJsonText: Text;
                begin
                    //
                    lJsonObject.Add('actorExternalId', 'Aulon Test 2');
                    lJsonObject.Add('actorType', 'PARTNER');
                    lJsonObject.Add('legalName', 'XYZ LIMITED');
                    lJsonObject.Add('postalCode', 'ES-08010');
                    lJsonObject.Add('cityName', 'BARCELONA');
                    lJsonObject.Add('countryCode', 'ES');
                    lJsonObject.Add('addressLine1', 'XXXX STREET, 93');
                    lJsonValue.SetValueToNull();
                    lJsonObject.Add('addressLine2', lJsonValue);
                    lJsonObject.Add('phone', '+34123456789');
                    lJsonObject.Add('email', 'xxxxx@gmail.com');
                    lJsonObject.Add('taxId', '00000000X');
                    lJsonObject.Add('iban', 'ES0000000000000000000000');
                    lJsonObject.Add('partnerDealType', 'PAY_AFTER_30_DAYS');
                    //
                    lInterface.Init();
                    lInterface."Guid" := CreateGuid();
                    lInterface.Type := lInterface.Type::Customer;
                    lInterface.Direction := lInterface.Direction::"In";
                    lJsonObject.WriteTo(lJsonText);
                    lInterface.Json.CreateOutStream(lOutStream);
                    lOutStream.WriteText(lJsonText);
                    lInterface."Created at" := CurrentDateTime();
                    lInterface."Creted By" := UserId();
                    lInterface.Insert(true);
                    //
                    CurrPage.Update();
                end;
            }
            action(TestTransaction)
            {
                Caption = 'Get Transaction';
                ApplicationArea = all;
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    lInterface: Record "GLV Interface";
                    lJsonObject: JsonObject;
                    lJsonValue: JsonValue;
                    lOutStream: OutStream;
                    lJsonText: Text;
                begin
                    //
                    lJsonObject.Add('OrderID', '212121');
                    lJsonObject.Add('countryCode', 'ES');
                    lJsonObject.Add('cityCode', 'COR');
                    lJsonObject.Add('orderCode', 'BARCOR01');
                    lJsonObject.Add('finalStatusTimeLocal', '2024-01-10T14:55+02:00');
                    lJsonObject.Add('storeAddressId', 120112012);
                    lJsonObject.Add('campaignId', '237641b6-a875-4c36-a859-0000543c92c8');
                    lJsonObject.Add('gmy', 28.45);
                    lJsonObject.Add('commissionAmount', 7.1125);
                    lJsonObject.Add('adsGMO', 1.2);
                    lJsonObject.Add('orderDescription', 'XXXX TEST');
                    //
                    lInterface.Init();
                    lInterface."Guid" := CreateGuid();
                    lInterface.Type := lInterface.Type::Transaction;
                    lInterface.Direction := lInterface.Direction::"In";
                    lJsonObject.WriteTo(lJsonText);
                    lInterface.Json.CreateOutStream(lOutStream);
                    lOutStream.WriteText(lJsonText);
                    lInterface."Created at" := CurrentDateTime();
                    lInterface."Creted By" := UserId();
                    lInterface.Insert(true);
                    //
                    CurrPage.Update();
                end;
            }
            action(ProcessCustomer)
            {
                Caption = 'Process Customer';
                ApplicationArea = all;
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = (Rec.Type = Rec."Type"::Customer) and (not Rec.Processed);
                trigger OnAction()
                var
                    lInterfaceMgt: Codeunit "GLV Interface Mgt";
                    lCustNo, lVendNo : Code[20];
                    lMsgTxt: Text;
                begin
                    if lInterfaceMgt.ProcessCustomer(Rec, lCustNo, lVendNo) then begin
                        Rec.Processed := true;
                        Rec.Error := '';
                        Rec.Modify(true);
                        lMsgTxt := StrSubstNo('Customer %1 created!', lCustNo);
                        if lVendNo <> '' then
                            lMsgTxt += StrSubstNo(' Vendor %1 created!', lVendNo);
                        Message(lMsgTxt);
                    end;
                    CurrPage.Update();
                end;
            }
            action(ViewJson)
            {
                Caption = 'View Json';
                Image = ExportFile;
                ApplicationArea = all;
                Enabled = Rec."Has Json";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    InStream: InStream;
                    JsonTxt: Text;
                begin
                    Clear(Rec.Json);
                    Rec.CalcFields(Json);
                    Rec.Json.CreateInStream(InStream);
                    InStream.ReadText(JsonTxt);
                    // Message(JsonTxt);
                    Dialog.Message(JsonTxt);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if Rec.Json.HasValue then
            Rec."Has Json" := true;
    end;
}