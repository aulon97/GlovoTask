page 50101 "GLV Interface Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GLV Interface Setup";
    Caption = 'Interface Setup';
    layout
    {
        area(Content)
        {
            group(CustomerInterface)
            {
                Caption = 'Customer Interface';
                field("Interface Cust. Template"; Rec."Interface Cust. Template")
                {
                    ToolTip = 'Specifies the value of the Default Interface Customer Template field.', Comment = '%';
                }
                field("Interface Vend. Template"; Rec."Interface Vend. Template")
                {
                    ToolTip = 'Specifies the value of the Default Interface Vendor Template field.', Comment = '%';
                }
                field("Automatic Vendor Creation"; Rec."Automatic Vendor Creation")
                {
                    ToolTip = 'Specifies the value of the Automatic Vendor Creation field.', Comment = '%';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}