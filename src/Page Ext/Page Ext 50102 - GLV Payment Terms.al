pageextension 50102 "GLV Payment Terms" extends "Payment Terms"
{
    layout
    {
        addafter(Code)
        {
            field("GLV External Id"; Rec."GLV External Id")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the GLV External Id field.', Comment = '%';
            }
        }
    }
}