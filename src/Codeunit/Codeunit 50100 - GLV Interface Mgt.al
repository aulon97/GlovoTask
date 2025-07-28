codeunit 50100 "GLV Interface Mgt"
{
    trigger OnRun()
    begin

    end;

    procedure ProcessCustomer(var pInterface: Record "GLV Interface"; var pCustNo: Code[20]; var pVendNo: code[20]): Boolean
    var
        lCustomer: Record Customer;
        lInterfaceSetup: Record "GLV Interface Setup";
        lCustTemplate: Record "Customer Templ.";
        lCountryRegion: Record "Country/Region";
        lPostCode: Record "Post Code";
        lCustBankAccount: Record "Customer Bank Account";
        lSalesRecSetup: Record "Sales & Receivables Setup";
        lInStream: InStream;
        lJsonTxt, lKeysTxt, lIban : Text;
        lJsonObject: JsonObject;
        lJsonToken: JsonToken;
        lKeyList: List of [Text];
        lExternalId: Code[50];
        isForInsert: Boolean;
        lNoSeriesMgt: Codeunit "No. Series";
        lPaymentTermsCode: Code[20];
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
                                ErrorLog(pInterface, StrSubstNo('Country/Region with code %1 does not exist.', lJsonToken.AsValue().AsCode()));
                            // Error('Country/Region with code %1 does not exist.', lJsonToken.AsValue().AsCode());
                        end;
                    'postalCode':
                        if lJsonToken.AsValue().AsCode() <> '' then begin
                            if PostCodeExist(lJsonToken.AsValue().AsCode(), '') then
                                lCustomer.Validate("Post Code", lJsonToken.AsValue().AsCode())
                            else begin
                                ErrorLog(pInterface, StrSubstNo('Post Code %1 does not exist.', lJsonToken.AsValue().AsCode()));
                                exit(false);
                            end;
                            // lCustomer."Post Code" := lJsonToken.AsValue().AsText();
                        end;
                    'cityName':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            // if PostCodeExist(lCustomer."Post Code", lJsonToken.AsValue().AsText()) then
                            lCustomer.Validate(City, lJsonToken.AsValue().AsText())
                            // else begin
                            // ErrorLog(pInterface, StrSubstNo('City %1 does not exist.', lJsonToken.AsValue().AsText()));
                            // exit(false);
                            // end;
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
                    'iban':
                        if lJsonToken.AsValue().AsText() <> '' then begin
                            lIban := lJsonToken.AsValue().AsText();
                        end;
                    'partnerDealType':
                        if lJsonToken.AsValue().AsCode() <> '' then begin
                            lPaymentTermsCode := GetPaymentTerms(lJsonToken.AsValue().AsCode());
                            if lPaymentTermsCode <> '' then
                                lCustomer.Validate("Payment Terms Code", lPaymentTermsCode);
                            // if (lJsonToken.AsValue().AsText() = 'PAY_AFTER_30_DAYS') then
                            //     lCustomer."Payment Terms Code" := '30D';
                        end;
                end;
        end;
        //
        if lCustomer.Modify(true) then begin
            //
            if (lIban <> '') then begin
                lCustBankAccount.Reset();
                //if is new customer

                lCustBankAccount.SetRange("Customer No.", lCustomer."No.");
                //
                lCustBankAccount.SetRange(IBAN, lIban);
                if not lCustBankAccount.FindFirst() then begin
                    lCustBankAccount.Init();
                    lCustBankAccount."Customer No." := lCustomer."No.";
                    lCustBankAccount.IBAN := lIban;
                    lCustBankAccount.Code := CopyStr(lIban, 1, 10);
                    lCustBankAccount.Insert();
                end;
                //
            end;
        end;
        if lInterfaceSetup."Automatic Vendor Creation" then
            pVendNo := CreateVendor(lCustomer);
        //
        pCustNo := lCustomer."No.";

        //
        exit(true);
    end;

    local procedure CustomerExist(pExternalId: Code[50]): Boolean
    var
        lCustomer: Record Customer;
    begin
        lCustomer.SetRange("External Id.", pExternalId);
        if lCustomer.FindLast() then
            exit(true) else
            exit(false);
    end;

    local procedure ErrorLog(var pInterface: Record "GLV Interface"; pMessage: Text)
    begin
        pInterface.Error := pMessage;
        Error(pMessage);
    end;

    local procedure PostCodeExist(pPostCode: Code[20]; pCity: Code[30]): Boolean
    var
        lPostCode: Record "Post Code";
    begin
        lPostCode.Reset();
        if pPostCode <> '' then
            lPostCode.SetRange(Code, pPostCode);
        if pCity <> '' then
            lPostCode.SetRange(City, pCity);
        if lPostCode.FindLast() then
            exit(true) else
            exit(false);
    end;

    local procedure GetPaymentTerms(pExternalId: Code[50]): Code[20]
    var
        lPaymentTerms: Record "Payment Terms";
    begin
        lPaymentTerms.Reset();
        lPaymentTerms.SetRange("GLV External Id", pExternalId);
        if lPaymentTerms.FindLast() then
            exit(lPaymentTerms.Code) else
            exit('');
    end;

    local procedure CreateVendor(pCustomer: Record Customer): Code[20]
    var
        lPurchPaySetup: Record "Purchases & Payables Setup";
        lVendor: Record Vendor;
        lVendTemplate: Record "Vendor Templ.";
        lInterfaceSetup: Record "GLV Interface Setup";
        lNoSeries: Codeunit "No. Series";
    begin
        if not lInterfaceSetup.Get() then
            Error('Interface Setup is not defined.');
        if not lVendTemplate.Get(lInterfaceSetup."Interface Vend. Template") then
            Error('You must define a default vendor template in the Interface Setup.');
        //
        lPurchPaySetup.Get();
        if not VendorExist(pCustomer."External Id.") then begin
            lVendor.SetInsertFromTemplate(true);
            lVendor.Init();
            lVendor."No." := lNoSeries.GetNextNo(lPurchPaySetup."Vendor Nos.");
            lVendor.Validate("External Id.", pCustomer."External Id.");
            lVendor.Insert();
        end else begin
            lVendor.SetRange("External Id.", pCustomer."External Id.");
            if lVendor.FindLast then;
        end;
        lVendor.Validate(Name, pCustomer.Name);
        lVendor.Validate("Country/Region Code", pCustomer."Country/Region Code");
        lVendor.Validate("Post Code", pCustomer."Post Code");
        lVendor.Validate(City, pCustomer.City);
        lVendor.Validate(Address, pCustomer.Address);
        lVendor.Validate("Address 2", pCustomer."Address 2");
        lVendor.Validate("Phone No.", pCustomer."Phone No.");
        lVendor.Validate("E-Mail", pCustomer."E-Mail");
        lVendor.Validate("VAT Registration No.", pCustomer."VAT Registration No.");
        lVendor.Validate("Payment Method Code", pCustomer."Payment Method Code");
        if lVendor.Modify() then
            exit(lVendor."No.");
    end;

    local procedure VendorExist(pExternalId: Code[50]): Boolean
    var
        lVendor: Record Vendor;
    begin
        lVendor.SetRange("External Id.", pExternalId);
        if lVendor.FindFirst() then
            exit(true) else
            exit(false);
    end;
}