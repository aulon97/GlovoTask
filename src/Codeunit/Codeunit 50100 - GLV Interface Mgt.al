codeunit 50100 "GLV Interface Mgt"
{
    trigger OnRun()
    begin

    end;

    procedure ProcessCustomer(pInterface: Record "GLV Interface"): Boolean
    var
        lCustomer: Record Customer;
        lInterfaceSetup: Record "GLV Interface Setup";
        lCustTemplate: Record "Customer Templ.";
        lCountryRegion: Record "Country/Region";
        lSalesRecSetup: Record "Sales & Receivables Setup";
        lInStream: InStream;
        lJsonTxt, lKeysTxt : Text;
        lJsonObject: JsonObject;
        lJsonToken: JsonToken;
        lKeyList: List of [Text];
        lExternalId: Code[50];
        isForInsert: Boolean;
        lNoSeriesMgt: Codeunit "No. Series";

    begin
        if lInterfaceSetup.Get() then;
        if not lCustTemplate.Get(lInterfaceSetup."Interface Cust. Template") then
            Error('You must define a default customer template in the Interface Setup.');
        if lSalesRecSetup.Get() then;
        //
        pInterface.Json.CreateInStream(lInStream);
        lInStream.ReadText(lJsonTxt);
        lJsonObject.ReadFrom(lJsonTxt);
        lKeyList := lJsonObject.Keys;
        lJsonObject.Get('actorExternalId', lJsonToken);
        lExternalId := lJsonToken.AsValue().AsCode();
        //
        if CustomerExist(lExternalId) then begin
            lCustomer.SetRange("External Id.", lExternalId);
            if lCustomer.FindFirst() then;
        end else begin
            lCustomer.SetInsertFromTemplate(true);
            lCustomer.Init();
            lCustomer."No." := lNoSeriesMgt.GetNextNo(lSalesRecSetup."Customer Nos.");
            lCustomer.CopyFromNewCustomerTemplate(lCustTemplate);
            lCustomer.Insert();
        end;
        //
        foreach lKeysTxt in lKeyList do begin
            lJsonObject.Get(lKeysTxt, lJsonToken);
            if not lJsonToken.AsValue().IsNull then
                case lKeysTxt of
                    'actorExternalId':
                        if lJsonToken.AsValue().AsCode() <> '' then begin
                            lCustomer."External Id." := lJsonToken.AsValue().AsCode();
                        end;
                    'legalName':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            lCustomer.Name := lJsonToken.AsValue().AsText();
                        end;
                    'countryCode':
                        if lJsonToken.AsValue().AsCode() <> '' then begin
                            if lCountryRegion.Get(lJsonToken.AsValue().AsCode()) then
                                lCustomer.Validate("Country/Region Code", lJsonToken.AsValue().AsCode())
                            else
                                Error('Country/Region with code %1 does not exist.', lJsonToken.AsValue().AsCode());
                        end;
                    // 'postalCode':
                    //     if lJsonToken.AsValue().AsInteger() <> 0 then begin
                    //         lCustomer."Post Code" := lJsonToken.AsValue().AsText();
                    //     end;
                    'cityName':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            lCustomer.City := lJsonToken.AsValue().AsText();
                        end;
                    'addressLine1':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            lCustomer."Address" := lJsonToken.AsValue().AsText();
                        end;
                    'addressLine2':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            lCustomer."Address 2" := lJsonToken.AsValue().AsText();
                        end;
                    'phone':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            lCustomer."Phone No." := lJsonToken.AsValue().AsText();
                        end;
                    'email':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            lCustomer."E-Mail" := lJsonToken.AsValue().AsText();
                        end;
                    'taxId':
                        if lJsonToken.AsValue().AsCode() <> '' then begin
                            lCustomer."VAT Registration No." := lJsonToken.AsValue().AsText();
                        end;
                    'partnerDealType':
                        if lJsonToken.AsValue().AsCode() <> '' then begin
                            if (lJsonToken.AsValue().AsText() = 'PAY_AFTER_30_DAYS') then
                                lCustomer."Payment Terms Code" := '30D';
                        end;
                end;
        end;
        //
        if lCustomer.Modify(true) then exit(true);
    end;

    local procedure CustomerExist(pExternalId: Code[50]): Boolean
    var
        lCustomer: Record Customer;
    begin
        lCustomer.SetRange("External Id.", pExternalId);
        if lCustomer.FindFirst() then
            exit(true) else
            exit(false);
    end;
}