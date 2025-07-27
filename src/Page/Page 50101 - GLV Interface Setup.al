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
            group(GroupName)
            {
                field("Interface Cust. Template"; Rec."Interface Cust. Template")
                {
                    ToolTip = 'Specifies the value of the Default Interface Customer Template field.', Comment = '%';
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